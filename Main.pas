unit Main;

interface

uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Config;


type
  TPatchedJmp = record
    Addr: DWORD;
    JmpTo: DWORD;
    OrigMemory: array of Byte;
  end;

  TPatchedMem = record
    Addr: DWORD;
    OrigMemory: array of Byte;
    NewMemory: array of Byte;
  end;

  TAPMThread = class(TThread)
  private
    FShutdown: Boolean;
  public
    destructor Destroy; override;

    procedure Execute; override;
    procedure Init;

    procedure HandleHotkeys(var Msg: TMsg);
  end;

  procedure Patch;
  procedure Unpatch;

const
  APMInterval: Real = 0.95; // time after which actions are worth 1/e (in minutes)

var
  Patched, AlertMinPassed: Boolean;
  AlertMinPTime: Cardinal;
  APMCounter: array[0..11] of Real;
  APMStr: array[0..11] of String;
  APMStrLens: array[0..11] of Integer;
  LastSoundAlert, LastAPMUpdate: Cardinal;
  GameStartTime: Cardinal;
  ConfigVars: TConfRecord;
  PatchedArr: array of TPatchedJmp;
  PatchedMemArr: array of TPatchedMem;

implementation

uses Math, Token, uBWAddresses, uSpeedChanges, MMSystem, BWUtil;

procedure AddPatch(dAddr,dJmpTo: DWORD; NumNops: Integer = 0);
var
  I: Integer;
begin
  SetLength(PatchedArr,Length(PatchedArr)+1);
  with PatchedArr[Length(PatchedArr)-1] do
  begin
    Addr := dAddr;
    JmpTo := dJmpTo;
    SetLength(OrigMemory,5+NumNops);
    //WriteMem(Cardinal(@OrigMemory),dAddr,Length(OrigMemory));
    //CopyMemory(@OrigMemory, Pointer(dAddr), Length(OrigMemory));
    //ShowMessage(IntToStr(Length(OrigMemory)));
    for I := 0 to Length(OrigMemory) - 1 do
    begin
        OrigMemory[I] := Byte((Pointer(dAddr+Cardinal(I)))^)
      //ShowMessage(IntToHex(OrigMemory[I],2));
    end;
  end;
end;

procedure AddPatchedMem(dAddr: DWORD; NewMem: array of Byte);
var
  I: Integer;
begin
  SetLength(PatchedMemArr,Length(PatchedMemArr)+1);
  with PatchedMemArr[Length(PatchedMemArr)-1] do
  begin
    Addr := dAddr;
    SetLength(NewMemory, Length(NewMem));
    for I := 0 to Length(NewMem) - 1 do
      NewMemory[I] := NewMem[I];

    SetLength(OrigMemory,Length(NewMemory));
    for I := 0 to Length(OrigMemory) - 1 do
    begin
      OrigMemory[I] := Byte((Pointer(dAddr+Cardinal(I)))^);
    end;
  end;
end;

procedure TAPMThread.HandleHotkeys(var Msg: TMsg);
begin
  // wParam = hotkey ID
  if Msg.wParam = 0 then
  begin
    // VK_F8
    if Patched then
      Unpatch
    else
      Patch;
  end; 
end;

function CalcATime: Cardinal;
var
  CurTick: DWORD;
begin
  PeekMem(Offsets.GameTime,@CurTick,SizeOf(CurTick));
  Result := CurTick*42;
end;

procedure AlertAPM; stdcall;
begin
  if (GetTickCount - LastSoundAlert > 2000)
      and (not IsPaused) and (not IsObsMode)//1.16
      and (AlertMinPassed and (CalcATime - AlertMinPTime > 20000)) then
  begin
    if ConfigVars.PlaySound then
      PlaySound(PChar(ConfigVars.SoundFile), 0, SND_ASYNC or SND_NODEFAULT or SND_NOSTOP);
    LastSoundAlert := GetTickCount;
  end;
end;

procedure CalcAPM; stdcall;
var
  CurTick, TimeDiff: Cardinal;
  GameDurationFactor: Real;
  APM: Integer;
  I: Integer;
begin
  if CalcATime > LastAPMUpdate then
  begin
    // do exponential decay, thanks MasterOfChaos :)
    CurTick := CalcATime; //GetTickCount;
    TimeDiff := CurTick - LastAPMUpdate;
    for I := 0 to 11 do
      APMCounter[I] := APMCounter[I]*exp(-Timediff/(APMInterval*60000));
    LastAPMUpdate := CurTick;
  end;

  CurTick := CalcATime;
  GameDurationFactor := 1-exp(-(CurTick - GameStartTime)/(APMInterval*60000));
  if GameDurationFactor < 0.01 then GameDurationFactor := 0.01;//Prevent div by 0

  for I := 0 to Length(APMCounter) - 1 do
  begin
    if GetPlayerName(I) <> '' then
    begin
      if (I <> GetPNum) or (IsObsMode) then
        APMStr[I] := GetColoredPlayerName(I) + ': '
      else if (I = GetPNum) and (not IsObsMode) then
        APMStr[I] := #4'APM: ';
          
      APM := Trunc(APMCounter[I]/(APMInterval*GameDurationFactor));
      if (not AlertMinPassed) and
      ((APM > ConfigVars.MinAPM * 1.1) or (CurTick >= 90000)) then
      begin
        AlertMinPassed := True;
        AlertMinPTime := CurTick;
      end;

      if APM >= ConfigVars.MinAPM then
        APMStr[I] := APMStr[I] + #7 + IntToStr(APM)
      else
      begin
        APMStr[I] := APMStr[I] + #6 + IntToStr(APM);
        if (I = GetPNum) and (not IsObsMode) then
          AlertAPM;
      end;

    end
    else
      APMStr[I] := '';

    APMStrLens[I] := BWGetTextWidth(PChar(APMStr[I]));
  end;

end;

function GetElapsedTimeStr: string;
var
  Milliseconds: Cardinal;
  Seconds, Minutes, Hours: Integer;
begin

  // time format: [hh:]mm:ss
  Milliseconds := CalcATime;
  Seconds := Integer(Milliseconds div 1000);
  Minutes := Seconds div 60;
  Seconds := Seconds - (Minutes*60);
  Hours := Minutes div 60;
  Minutes := Minutes - (Hours*60);
  if Hours > 0 then // only display hours if their greater than 0
    Result := Format('%.2d:%.2d:%.2d',[Hours,Minutes,Seconds])
  else
    Result := Format('%.2d:%.2d',[Minutes,Seconds]);
end;

function GetLocalTimeStr: string;
var
  CurTime: TDateTime;
begin
  CurTime := Time;
  Result := FormatDateTime('hh:nn ampm',CurTime);
end;

function GetOnScreenTextPos(PosX, TextWidth: Integer): Integer;
begin
  if PosX + TextWidth < 640 then
    Result := PosX
  else
  begin
    Result := Floor((639 - TextWidth) / 10) * 10; // prevent jittering
  end;
end;

procedure DrawIt;
var
  I,LineNo: Integer;
  MaxAPMLen, OnScreenPos: Integer;
  GameClock, LocalClock: String;
  PreTextFormat: Cardinal;
begin
  PreTextFormat := GetCurTextFormat;
  BWFormatTextR(Offsets.bwtf_Normal);
  CalcAPM;
  if ConfigVars.EnableLiveAPM then
  begin
    if (ConfigVars.DispAllAPMs) and (IsObsMode) then
    begin
      MaxAPMLen := 0;
      for I := 0 to Length(APMStrLens) - 1 do
      begin
        if MaxAPMLen < APMStrLens[I] then
          MaxAPMLen := APMStrLens[I];
      end;
      OnScreenPos := GetOnScreenTextPos(ConfigVars.PosX,MaxAPMLen);
      LineNo := 0;
      for I := 0 to Length(APMStr) - 1 do
      begin
        if APMStr[I] <> '' then
        begin
          BWDrawText(OnScreenPos,ConfigVars.PosY+(LineNo*11),PChar(APMStr[I]));
          LineNo := LineNo + 1;
        end;
      end;
    end
    else if GetPNum <> -1 then
    begin
      OnScreenPos := GetOnScreenTextPos(ConfigVars.PosX,APMStrLens[GetPNum]);
      BWDrawText(OnScreenPos, ConfigVars.PosY,PChar(APMStr[GetPNum]));
    end;
  end;
  BWFormatTextR(Offsets.bwtf_Large);
  if ConfigVars.EnableGameClock then
  begin
    GameClock := #4+GetElapsedTimeStr+#1;
    OnScreenPos := GetOnScreenTextPos(ConfigVars.GameClockX,
                          BWGetTextWidth(PChar(GameClock)));
    BWDrawText(OnScreenPos,ConfigVars.GameClockY,PChar(GameClock));
  end;
  if ConfigVars.EnableLocalClock then
  begin
    LocalClock := #4+GetLocalTimeStr+#1;
    OnScreenPos := GetOnScreenTextPos(ConfigVars.LocalClockX,
                          BWGetTextWidth(PChar(LocalClock)));
    BWDrawText(OnScreenPos,ConfigVars.LocalClockY,PChar(LocalClock));
  end;
  BWFormatText(Offsets.bwtf_Reset);
  BWRestoreTextFormat(PreTextFormat);
end;

procedure MyDrawFxn; stdcall;
  {Code in 1.16:
  004BD504  |. E8 47F9FCFF    CALL StarCraf.0048CE50  ; overwrite
  004BD509  |. E8 D22FFBFF    CALL StarCraf.004704E0  ; jump back
  }
begin
  asm
    call dword ptr [Offsets.HOOK_DrawRepFunc] // overwritten command
    pushad
  end;
    DrawIt;
  asm
    popad
    jmp [Offsets.HOOK_DrawJmpBack]
  end;
end;

function HandleCommand(CmdStr: PChar): Boolean; stdcall;
//TODO: Fix this crazy mess of a function please
var
  Cmd, Args: PChar;
  CmdString, ArgsString: string;
begin
  Result := False;

  if Pos('/',CmdStr) = 1 then
  begin
    // it at least looks like a command, now we can process it and see if we can handle it
    CmdString := GetToken(CmdStr, ' ', 1);
    CmdString := GetToken(CmdString,'/',2); // Strip off the slash
    ArgsString := '';
    if NumToken(CmdStr, ' ') >= 1 then
      ArgsString := Copy(CmdStr, Length(CmdString) + 2, Length(CmdStr) - Length(CmdString) + 2);

    CmdString := UpperCase(CmdString);
    Cmd := AllocMem(Length(CmdString) + 1);
    StrPCopy(Cmd, CmdString);
    Args := AllocMem(Length(ArgsString) + 1);
    StrPCopy(Args,ArgsString);
    // check for specific commands now
    Result := True;
    try
      if Cmd = 'ABOUTAPM' then
        BWTextOut(#7'APMAlert v1.0'#4' by '#6'tec27')
      else if (Cmd = 'MINAPM') or (Cmd = 'SETAPM') then
      begin
        ConfigVars.MinAPM := StrToInt(Trim(Args));
        SaveAPMConf(ConfigVars);
        BWTextOut(PChar('Got new minimum APM: '#7+FloatToStr(ConfigVars.MinAPM)));
      end
      else if (Cmd = 'TOGGLESOUND') or (Cmd = 'TGLSND') then
      begin
        ConfigVars.PlaySound := not ConfigVars.PlaySound;
        SaveAPMConf(ConfigVars);
        if ConfigVars.PlaySound then
          BWTextOut('[Sound Alerts] Now '#7+'On')
        else
          BWTextOut('[Sound Alerts] Now '#6+'Off');
      end
      else if Cmd = 'SHOWAPM' then
        BWTextOut(PChar('Minimum APM: '#7+FloatToStr(ConfigVars.MinAPM)))
      else if Cmd = 'MOVEAPM' then
      begin
        ConfigVars.PosX := Integer(Pointer(Offsets.CursorX)^);
        ConfigVars.PosY := Integer(Pointer(Offsets.CursorY)^);
        SaveAPMConf(ConfigVars);
        BWTextOut(PChar('Got new box position: '#7 + IntToStr(ConfigVars.PosX) + ',' + IntToStr(ConfigVars.PosY)));
      end
      else if (Cmd = 'TOGGLEAPM') or (Cmd = 'TGLAPM') then
      begin
        ConfigVars.EnableLiveAPM := not ConfigVars.EnableLiveAPM;
        SaveAPMConf(ConfigVars);
        if ConfigVars.EnableLiveAPM then
          BWTextOut('[LiveAPM] Now '#7+'On')
        else
          BWTextOut('[LiveAPM] Now '#6+'Off');
      end
      else if Cmd = 'MOVELOCAL' then
      begin
        ConfigVars.LocalClockX := Integer(Pointer(Offsets.CursorX)^);
        ConfigVars.LocalClockY := Integer(Pointer(Offsets.CursorY)^);
        SaveAPMConf(ConfigVars);
        BWTextOut(PChar('Got new box position: '#7 +
                        IntToStr(ConfigVars.LocalClockX) + ','
                        + IntToStr(ConfigVars.LocalClockY)));
      end
      else if Cmd = 'MOVEGAME' then
      begin
        ConfigVars.GameClockX := Integer(Pointer(Offsets.CursorX)^);
        ConfigVars.GameClockY := Integer(Pointer(Offsets.CursorY)^);
        SaveAPMConf(ConfigVars);
        BWTextOut(PChar('Got new box position: '#7 +
                        IntToStr(ConfigVars.GameClockX) + ','
                        + IntToStr(ConfigVars.GameClockY)));
      end
      else if (Cmd = 'TOGGLELOCAL') or (Cmd = 'TGLLOCAL') then
      begin
        ConfigVars.EnableLocalClock := not ConfigVars.EnableLocalClock;
        SaveAPMConf(ConfigVars);
        if ConfigVars.EnableLocalClock then
          BWTextOut('[Local Clock] Now '#7+'On')
        else
          BWTextOut('[Local Clock] Now '#6+'Off');
      end
      else if (Cmd = 'TOGGLEGAME') or (Cmd = 'TGLGAME') then
      begin
        ConfigVars.EnableGameClock := not ConfigVars.EnableGameClock;
        SaveAPMConf(ConfigVars);
        if ConfigVars.EnableGameClock then
          BWTextOut('[Game Clock] Now '#7+'On')
        else
          BWTextOut('[Game Clock] Now '#6+'Off');
      end
      else if (Cmd = 'TOGGLEDISPALL') or (Cmd = 'TGLDISPALL') then
      begin
        ConfigVars.DispAllAPMs := not ConfigVars.DispAllAPMs;
        SaveAPMConf(ConfigVars);
        if ConfigVars.DispAllAPMs then
          BWTextOut('[Display All APMs] Now '#7+'On')
        else
          BWTextOut('[Display All APMs] Now '#6+'Off');
      end
      else
        Result := False; // If nothing was hit, then we never handled it
    except
      on E: Exception do
      begin
        BWTextOut(PChar('Error in command: ' + E.ClassName + ': ' + E.Message));
        Result := True; // even after an error, it was still 'handled'
      end;  
    end;
    FreeMem(Cmd);
    FreeMem(Args);
  end;
end;

procedure CommandProc; stdcall;
  // 1.16 Code:
  {
  004F31BE  |. 52             PUSH EDX                       ; /Arg1
  004F31BF  |. 8D5D 0C        LEA EBX,DWORD PTR SS:[EBP+C]   ; |
  004F31C2  |. 894D 0C        MOV DWORD PTR SS:[EBP+C],ECX   ; |
  004F31C5  |. E8 06F1FBFF    CALL StarCraf.004B22D0         ; \StarCraf.004B22D0
  }
var
  EnteredStr: PChar;
  Processed: Boolean;
begin
  asm
    pushad
    mov EnteredStr, edx
  end;
  // ok, do what you want with the string, just don't modify it if you want SC to have access to the original string

  Processed := HandleCommand(EnteredStr);

  // after we're done:
  if not Processed then
  begin
    asm
      popad
      pop ecx
      pop ebp // above two fix for delphi stuff
      call dword ptr [Offsets. HOOK_TextCommandsRepFunc] // the call that makes SC process its messages
      jmp [Offsets.HOOK_TextCommandsJmpBack]
    end;
    exit;     // Should never reach here
  end;

  // else
  asm
    popad
    pop ecx
    pop ebp // above two fix for delphi stuff
    jmp [Offsets.HOOK_TextCommandsJmpBack]
  end;
end;

procedure GotAction(ActionCode: Byte; PlayerNum: Integer);
begin
  {BWTextOut(PChar('Code: 0x' + IntToHex(ActionCode,2) + ' - Player: 0x'
                    + IntToHex(PlayerNum,8)),9);}
  if (ActionCode <> $37) and (PlayerNum < 12) then
  begin
    // anything that triggers this is not a keepalive action
    APMCounter[PlayerNum] := APMCounter[PlayerNum] + 1;
    //BWTextOut('Action.',PNum);
    {BWTextOut(PChar('Code: 0x' + IntToHex(ActionCode,2) + ' - Player: '
                    + IntToStr(PlayerNum)),9);}
  end;
end;

// This hook will be called each time an action is executed in SC
procedure SendActionHook; stdcall;
var
  ActionCode: Byte;
  ACPtr: Pointer;
  PNum: DWORD;
begin
  // 1.16 code:
  {
  00486C78  |. 52             |PUSH EDX                ; /Arg1 => 00000008
  00486C79  |. 8BDE           |MOV EBX,ESI             ; |
  00486C7B  |. E8 D0700400    |CALL StarCraf.004CDD50  ; \StarCraf.004CDD50
  }
  asm
    pushad
    mov EDX,[Offsets.SendActionPNum]
    mov EDX,[EDX]
    mov PNum,EDX
    mov ACPtr,ESI
  end;

  ActionCode := Byte(ACPtr^);
  GotAction(ActionCode,PNum);

  asm
    popad
    add ESP,8
    pop EBP
    call [Offsets.HOOK_SendActionRepFunc] // what we replaced
    jmp [Offsets.HOOK_SendActionJmpBack]
  end;
end;

procedure GameInit; stdcall;
var
  I: Integer;
begin
  GameStartTime := CalcATime;
  LastAPMUpdate := GameStartTime;
  LastSoundAlert := 0; // Sound alerts are still based off of actual timing, not game timing
  AlertMinPassed := False;
  AlertMinPTime := 0;
  
  for I := 0 to 11 do
  begin
    APMCounter[I] := 0;
    APMStr[I] := 'Starting...';
  end;
end;

procedure TAPMThread.Execute;
begin
  while not Terminated do
  begin
    if (IsInGame) and (not Patched) then
      Patch
    else if (not IsInGame) and (Patched) then
      Unpatch;
      
    Sleep(75);
  end;
end;

procedure TAPMThread.Init;
begin
  LoadAPMConf(ConfigVars);
  SetLength(PatchedArr,0);
  SetLength(PatchedMemArr,0);
  Patched := False;
  LastSoundAlert := 0;
  LastAPMUpdate := 0;
  AlertMinPassed := False;
  AlertMinPTime := 0;

  // All our possible patches
  AddPatch(Offsets.HOOK_Draw,Cardinal(@MyDrawFxn));
  AddPatch(Offsets.HOOK_TextCommands,Cardinal(@CommandProc));
  AddPatch(Offsets.HOOK_SendAction,Cardinal(@SendActionHook));
  // Text Refreshing patches, thanks Perma
  AddPatchedMem(Offsets.PTCH_TextRefresh1,[$90,$90]);
  AddPatchedMem(Offsets.PTCH_TextRefresh2,[$EB,$04]);

  Resume;
end;

destructor TAPMThread.Destroy;
begin
  FShutdown := True;
  try
    if not Terminated then
      Self.Terminate;
  finally
    inherited;
  end;
end;

procedure Patch;
const
  Nop: Byte = $90;
var
  I,J: Integer;
begin
  for I := 0 to Length(PatchedArr) - 1 do
  begin
    with PatchedArr[I] do
    begin
      JmpPatch(Addr,JmpTo);

      if Length(OrigMemory) > 5 then
      begin
        for J := 5 to Length(OrigMemory) - 1 do
           WriteMem(Addr+Cardinal(J),Cardinal(@Nop),1);
      end;
    end;
  end;

  for I := 0 to Length(PatchedMemArr) - 1 do
  begin
    with PatchedMemArr[I] do
    begin
      for J := 0 to Length(NewMemory) - 1 do
      begin
        WriteMem(Addr+Cardinal(J),Cardinal(@NewMemory[J]),1);
      end;
    end;
  end;

  Patched := True;
  
  if IsInGame then
    GameInit; // NOT GameStart, lol (although restarting games midway through was sorta fun :P )
end;

procedure Unpatch;
var
  I, J: Integer;
begin
  for I := 0 to Length(PatchedArr) - 1 do
  begin
    with PatchedArr[I] do
    begin
      for J := 0 to Length(OrigMemory) - 1 do
      begin
        WriteMem(Addr+Cardinal(J),Cardinal(@OrigMemory[J]),1);
      end;
    end;
  end;

  for I := 0 to Length(PatchedMemArr) - 1 do
  begin
    with PatchedMemArr[I] do
    begin
      for J := 0 to Length(OrigMemory) - 1 do
      begin
        WriteMem(Addr+Cardinal(J),Cardinal(@OrigMemory[J]),1);
      end;
    end;
  end;

  Patched := False;
end;

end.

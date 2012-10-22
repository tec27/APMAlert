unit uBWAddresses;

interface

type
  TOffsets = packed record
    InReplay: Cardinal; // Byte -- Need to use this with InGame to determine
    InGame: Cardinal; // Byte
    DebriefingRoom: Cardinal; // Byte, = 1 if they're currently viewing the 'scores room' after the game
    MapFilePath: Cardinal; // string
    SavedRepName: Cardinal; // string, contains name used in rep saving without '.rep'
    GameTime: Cardinal; // Dword
    RepSpeed: Cardinal; // byte, 6 for fastest
    RepSpeedMultiplier: Cardinal; // byte, x2 = 2, x4 = 4, etc.
    RepSpeedTiming: Cardinal; // byte, stores time for each frame, 42ms for fastest
    RepPaused: Cardinal; // Byte
    GamePaused: Cardinal; // Byte
    GameCompleteDlg: Cardinal; // Byte, tells whether the "Exit Replay"/"Continue Playing" dlg is up
    GameDigitalVolume: Cardinal; // Byte, 0-100 for percent volume
    TickTimeTable: Cardinal; // Table of DWords giving actual timings for speeds <= Fastest (Dwords)
    RepSelectedPlayer: Cardinal; // -1 if nothing is selected, otherwise player #
    PlayerNames: Cardinal; // 36 Bytes per player, first 24 are the string
    BuildingsControlled: Cardinal; // DW, +4*Player
    Population: Cardinal; // DW, +4*Player
    Minerals: Cardinal; //DW, +4*Player
    Vespene: Cardinal; //DW, +4*Player
    MyPNumAddr: Cardinal; // Current Player's number
    CursorX: Cardinal; // DW, X coord of the mouse cursor ingame
    CursorY: Cardinal; // DW, Y coord of the mouse cursor ingame
    PlayerColors: Cardinal; // array of player colors
    CurTextFormat: Cardinal; // DW, the current font the text is in
    bwtf_Reset: Cardinal; // reset the font
    bwtf_UltraLarge: Cardinal; // very large font
    bwtf_Large: Cardinal; // large font
    bwtf_Normal: Cardinal; // normal font
    bwtf_Mini: Cardinal; // small font
    BoxColor: Cardinal; // where to store the color when using the box drawing function
    TextRectX: Cardinal; // what x to use when checking text rect
    TextRectY: Cardinal; // what y to use when checking text rect
    TextRectLeft: Cardinal; // the left value returned by GetTextRect
    TextRectTop: Cardinal; // the top value returned by GetTextRect
    TextRectRight: Cardinal; // the right value returned by GetTextRect
    TextRectBottom: Cardinal; // the bottom value returned by GetTextRect
    TextWidth: Cardinal;  // the width of the text in the current font (GetTextWidth)
    SendActionPNum: Cardinal; // the player number in the SendAction function

    // functions
    BWFXN_CTextOut, // Centered TextOut
    BWFXN_TextOut, // TextOut
    BWFXN_DrawBox, // Box drawing function
    BWFXN_DrawText, // Draw text at x,y
    BWFXN_FormatText, // Format text with specified font
    BWFXN_RefreshText, // Refresh text in a portion of the screen
    BWFXN_GetTextRect, // Get the rect of the text in the current font
    BWFXN_GetTextWidth, // Get the width of the text in the current font
    BWFXN_SetSpeed: Cardinal; // Set the replay speed

    // Hooks
    HOOK_Draw,
    HOOK_DrawJmpBack,
    HOOK_DrawRepFunc,
    HOOK_TextCommands,
    HOOK_TextCommandsJmpBack,
    HOOK_TextCommandsRepFunc,
    HOOK_SendAction,
    HOOK_SendActionJmpBack,
    HOOK_SendActionRepFunc: Cardinal;
    
    // Patches
    PTCH_TextRefresh1,
    PTCH_TextRefresh2: Cardinal;
  end;

var
  Offsets: TOffsets;
  SCProcHandle: THandle = 0;
  SCWnd: THandle = 0;

const
  Offsets1153: TOffsets = (
    InReplay: $006D0EFC; // Byte -- Need to use this with InGame to determine
    InGame: $006D11D4; // Byte
    DebriefingRoom: $006D63A0; // Byte, = 1 if they're currently viewing the 'scores room' after the game
    MapFilePath: $0057FD24; // string
    SavedRepName: $0051BFB8; // string, contains name used in rep saving without '.rep'
    GameTime: $0057F224; // Dword
    RepSpeed: $006CDFBC; // byte, 6 for fastest
    RepSpeedMultiplier: $0050E058; // byte, x2 = 2, x4 = 4, etc.
    RepSpeedTiming: $005124F0; // byte, stores time for each frame, 42ms for fastest
    RepPaused: $006D1198; // Byte
    GamePaused: $006509AC; // Byte
    GameCompleteDlg: $00685160; // Byte, tells whether the "Exit Replay"/"Continue Playing" dlg is up
    GameDigitalVolume: $006CDFCC; // Byte, 0-100 for percent volume
    TickTimeTable: $005124D8; // Table of DWords giving actual timings for speeds <= Fastest (Dwords)
    RepSelectedPlayer: $00515400; // -1 if nothing is selected, otherwise player #
    PlayerNames: $0057EEEB; // 36 Bytes per player, first 24 are the string
    BuildingsControlled: $00581F1C; // DW, +4*Player
    Population: $00581DFC; // DW, +4*Player
    Minerals: $0057F0D8; //DW, +4*Player
    Vespene: $0057F108; //DW, +4*Player
    MyPNumAddr: $00512684; // Current Player's number
    CursorX: $006CDDAC; // DW, X coord of the mouse cursor ingame
    CursorY: $006CDDB0; // DW, Y coord of the mouse cursor ingame
    PlayerColors: $00581DBE; // array of player colors
    CurTextFormat: $006D5DBC; // DW, the current font the text is in
    bwtf_Reset: $00000000;
    bwtf_UltraLarge: $006CE0E8;
    bwtf_Large: $006CE0E4;
    bwtf_Normal: $006CE0E0;
    bwtf_Mini: $006CE0DC;
    BoxColor: $006CF494; // where to store the color when using the box drawing function
    TextRectX: $006CE0F0; // what x to use when checking text rect
    TextRectY: $006CE0C8; // what y to use when checking text rect
    TextRectLeft: $006CE0C0; // the left value returned by GetTextRect
    TextRectTop: $006CE0C2; // the top value returned by GetTextRect
    TextRectRight: $006CE0C4; // the right value returned by GetTextRect
    TextRectBottom: $006CE0C6; // the bottom value returned by GetTextRect
    TextWidth: $006CE0F0; // the width of the text in the current font (GetTextWidth)
    SendActionPNum: $0051267C; // the player number in the SendAction function

    //functions
    BWFXN_CTextOut: $0048CE90; // Centered TextOut
    BWFXN_TextOut: $0048CD90; // TextOut
    BWFXN_DrawBox: $004E1940; // Box drawing function
    BWFXN_DrawText: $004202D0; // Draw text at x,y
    BWFXN_FormatText: $0041FB50; // Format text with specified font
    BWFXN_RefreshText: $0041E0F0; // Refresh text in a portion of the screen
    BWFXN_GetTextRect: $004200F0; // Get the rect of the text in the current font
    BWFXN_GetTextWidth: $0041F940; // Get the width of the text in the current font
    BWFXN_SetSpeed: $004DE7E0; // Set The Replay Speed

    // Hooks
    HOOK_Draw: $004BD2F4;
    HOOK_DrawJmpBack: $004BD2F9;
    HOOK_DrawRepFunc: $0048CC30;
    HOOK_TextCommands: $004F3015;
    HOOK_TextCommandsJmpBack: $004F301A;
    HOOK_TextCommandsRepFunc: $004B20D0;
    HOOK_SendAction: $00486A6B;
    HOOK_SendActionJmpBack: $00486A70;
    HOOK_SendActionRepFunc: $004CDB00;

    // Patches
    PTCH_TextRefresh1: $0047F69C;
    PTCH_TextRefresh2: $0047F550;
  );

  Offsets1160: TOffsets = (
    InReplay: $006D0EF4; // Byte -- Need to use this with InGame to determine
    InGame: $006D11CC; // Byte
    DebriefingRoom: $006D6398; // Byte, = 1 if they're currently viewing the 'scores room' after the game
    MapFilePath: $0057FD1C; // string
    SavedRepName: $0051BF98; // string, contains name used in rep saving without '.rep'
    GameTime: $0057F21C; // Dword
    RepSpeed: $006CDFB4; // byte, 6 for fastest
    RepSpeedMultiplier: $0050E058; // byte, x2 = 2, x4 = 4, etc.
    RepSpeedTiming: $005124F0; // byte, stores time for each frame, 42ms for fastest
    RepPaused: $006D1190; // Byte
    GamePaused: $006509A4; // Byte
    GameCompleteDlg: $00685158; // Byte, tells whether the "Exit Replay"/"Continue Playing" dlg is up
    GameDigitalVolume: $006CDFC4; // Byte, 0-100 for percent volume
    TickTimeTable: $005124D8; // Table of DWords giving actual timings for speeds <= Fastest (Dwords)
    RepSelectedPlayer: $005153F8; // -1 if nothing is selected, otherwise player #
    PlayerNames: $0057EECB; // 36 Bytes per player, first 24 are the string
    BuildingsControlled: $00581F14; // DW, +4*Player
    Population: $00581DF4; // DW, +4*Player
    Minerals: $0057F0D0; //DW, +4*Player
    Vespene: $0057F100; //DW, +4*Player
    MyPNumAddr: $00512684; // Current Player's number
    CursorX: $006CDDA4; // DW, X coord of the mouse cursor ingame
    CursorY: $006CDDA8; // DW, Y coord of the mouse cursor ingame
    PlayerColors: $00581DB6; // array of player colors
    CurTextFormat: $006D5DB4; // DW, the current font the text is in
    bwtf_Reset: $00000000;
    bwtf_UltraLarge: $006CE0E0;
    bwtf_Large: $006CE0DC;
    bwtf_Normal: $006CE0D8;
    bwtf_Mini: $006CE0D4;
    BoxColor: $006CF48C; // where to store the color when using the box drawing function
    TextRectX: $006CE0E8; // what x to use when checking text rect
    TextRectY: $006CE0C0; // what y to use when checking text rect
    TextRectLeft: $006CE0B8; // the left value returned by GetTextRect
    TextRectTop: $006CE0BA; // the top value returned by GetTextRect
    TextRectRight: $006CE0BC; // the right value returned by GetTextRect
    TextRectBottom: $006CE0BE; // the bottom value returned by GetTextRect
    TextWidth: $006CE0E8; // the width of the text in the current font (GetTextWidth)
    SendActionPNum: $0051267C; // the player number in the SendAction function

    //functions
    BWFXN_CTextOut: $0048D0B0; // Centered TextOut
    BWFXN_TextOut: $0048CFB0; // TextOut
    BWFXN_DrawBox: $004E1B70; // Box drawing function
    BWFXN_DrawText: $004202A0; // Draw text at x,y
    BWFXN_FormatText: $0041FB20; // Format text with specified font
    BWFXN_RefreshText: $0041E0C0; // Refresh text in a portion of the screen
    BWFXN_GetTextRect: $004200C0; // Get the rect of the text in the current font
    BWFXN_GetTextWidth: $0041F910; // Get the width of the text in the current font
    BWFXN_SetSpeed: $004DEA10; // Set The Replay Speed

    // Hooks
    HOOK_Draw: $0048CF99;
    HOOK_DrawJmpBack: $0048CF9E;
    HOOK_DrawRepFunc: $0041FB20;
    HOOK_TextCommands: $004F31C5;
    HOOK_TextCommandsJmpBack: $004F31CA;
    HOOK_TextCommandsRepFunc: $004B22D0;
    HOOK_SendAction: $00486C7B;
    HOOK_SendActionJmpBack: $00486C80;
    HOOK_SendActionRepFunc: $004CDD50;

    // Patches
    PTCH_TextRefresh1: $0047F70C;
    PTCH_TextRefresh2: $0047F5C0;
  );

  Offsets1161: TOffsets = (
    InReplay: $006D0F14; // Byte -- Need to use this with InGame to determine
    InGame: $006D11EC; // Byte
    DebriefingRoom: $006D63C0; // Byte, = 1 if they're currently viewing the 'scores room' after the game
    MapFilePath: $0057FD3C; // string
    SavedRepName: $0051BFB8; // string, contains name used in rep saving without '.rep'
    GameTime: $0057F23C; // Dword
    RepSpeed: $006CDFD4; // byte, 6 for fastest
    RepSpeedMultiplier: $0050E058; // byte, x2 = 2, x4 = 4, etc.
    RepSpeedTiming: $005124F0; // byte, stores time for each frame, 42ms for fastest
    RepPaused: $006D11B0; // Byte
    GamePaused: $006509C4; // Byte
    GameCompleteDlg: $00685178; // Byte, tells whether the "Exit Replay"/"Continue Playing" dlg is up
    GameDigitalVolume: $006CDFE4; // Byte, 0-100 for percent volume
    TickTimeTable: $005124D8; // Table of DWords giving actual timings for speeds <= Fastest (Dwords)
    RepSelectedPlayer: $005153F8; // -1 if nothing is selected, otherwise player #
    PlayerNames: $0057EEEB; // 36 Bytes per player, first 24 are the string
    BuildingsControlled: $00581F34; // DW, +4*Player
    Population: $00581E14; // DW, +4*Player
    Minerals: $0057F0F0; //DW, +4*Player
    Vespene: $0057F120; //DW, +4*Player
    MyPNumAddr: $00512684; // Current Player's number
    CursorX: $006CDDC4; // DW, X coord of the mouse cursor ingame
    CursorY: $006CDDC8; // DW, Y coord of the mouse cursor ingame
    PlayerColors: $00581DD6; // array of player colors
    CurTextFormat: $006D5DDC; // DW, the current font the text is in
    bwtf_Reset: $00000000;
    bwtf_UltraLarge: $006CE100;
    bwtf_Large: $006CE0FC;
    bwtf_Normal: $006CE0F8;
    bwtf_Mini: $006CE0F4;
    BoxColor: $006CF4AC; // where to store the color when using the box drawing function
    TextRectX: $006CE108; // what x to use when checking text rect
    TextRectY: $006CE0E0; // what y to use when checking text rect
    TextRectLeft: $006CE0D8; // the left value returned by GetTextRect
    TextRectTop: $006CE0DA; // the top value returned by GetTextRect
    TextRectRight: $006CE0DC; // the right value returned by GetTextRect
    TextRectBottom: $006CE0DE; // the bottom value returned by GetTextRect
    TextWidth: $006CE108; // the width of the text in the current font (GetTextWidth)
    SendActionPNum: $0051267C; // the player number in the SendAction function

    //functions
    BWFXN_CTextOut: $0048D1C0; // Centered TextOut
    BWFXN_TextOut: $0048D0C0; // TextOut
    BWFXN_DrawBox: $004E1D20; // Box drawing function
    BWFXN_DrawText: $004202B0; // Draw text at x,y
    BWFXN_FormatText: $0041FB30; // Format text with specified font
    BWFXN_RefreshText: $0041E0D0; // Refresh text in a portion of the screen
    BWFXN_GetTextRect: $004200D0; // Get the rect of the text in the current font
    BWFXN_GetTextWidth: $0041F920; // Get the width of the text in the current font
    BWFXN_SetSpeed: $004DEB90; // Set The Replay Speed

    // Hooks
    HOOK_Draw: $0048D0A9;
    HOOK_DrawJmpBack: $0048D0AE;
    HOOK_DrawRepFunc: $0041FB30;
    HOOK_TextCommands: $004F3375;
    HOOK_TextCommandsJmpBack: $004F337A;
    HOOK_TextCommandsRepFunc: $004B23E0;
    HOOK_SendAction: $00486D8B;
    HOOK_SendActionJmpBack: $00486D90;
    HOOK_SendActionRepFunc: $004CDE70;

    // Patches
    PTCH_TextRefresh1: $0047F26C;
    PTCH_TextRefresh2: $0047F120;
  );

procedure PeekMem(Address: Cardinal; Buffer: Pointer; Size: Cardinal);
procedure PokeMem(Address: Cardinal; Buffer: Pointer; Size: Cardinal);

function ReadMapPath: string;
function ReadSavedRepName: string;
function IsInReplay: Boolean;
function IsInGame: Boolean;
function IsPaused: Boolean;
function IsGameComplete: Boolean;
function IsFastestSpeed: Boolean;
function GetPNum: Integer;
function GetPlayerName(Player: Byte): string;
function IsObsMode: Boolean;
function GetBuildingsControlled(Player: Byte): Integer;
function GetPopulation(Player: Byte): Integer;
function GetMinerals(Player: Byte): Integer;
function GetVespene(Player: Byte): Integer;
function GetCurTextFormat: Cardinal;
function GetColoredPlayerName(Player:byte):String;
function FactionColor(Faction:byte):byte;
function FactionColorCode(Faction:byte):char;

implementation

uses Windows, SysUtils;

procedure PeekMem(Address: Cardinal; Buffer: Pointer; Size: Cardinal);
var
  {ThrowawayVar: Cardinal;}
  I: Integer;
begin
  {ReadProcessMemory(SCProcHandle, Pointer(Address), Buffer,
                      Size, ThrowawayVar);}
  for I := 0 to Size - 1 do
  begin
    PByte(Cardinal(Buffer) + Cardinal(I))^ := PByte(Address + Cardinal(I))^;
  end;
end;

procedure PokeMem(Address: Cardinal; Buffer: Pointer; Size: Cardinal);
var
  {ThrowawayVar: Cardinal;}
  I: Integer;
  procedure WriteMem(MemOffset, DataPtr, DataLen: DWORD); stdcall;
  var
    OldProt, OldProt2: DWORD;
  begin
    VirtualProtect(Pointer(MemOffset), DataLen, PAGE_EXECUTE_READWRITE, @OldProt);
    VirtualProtect(Pointer(DataPtr), DataLen, PAGE_EXECUTE_READWRITE, @OldProt2);
    CopyMemory(Pointer(MemOffset), Pointer(DataPtr), DataLen);
    VirtualProtect(Pointer(DataPtr), DataLen, OldProt2, @OldProt2);
    VirtualProtect(Pointer(MemOffset), DataLen, OldProt, @OldProt);
  end;
begin
  {WriteProcessMemory(SCProcHandle,Pointer(Address),Buffer,Size,ThrowawayVar);}
  for I := 0 to Size - 1 do
  begin
    WriteMem(Address+Cardinal(I),Cardinal(Buffer)+Cardinal(I),1);
  end;
end;

function ReadMapPath: string;
var
  tempChar: Char;
  chOffset: Cardinal;
begin
  Result := '';
  chOffSet := 0;
  repeat
    PeekMem(Offsets.MapFilePath+chOffset,@tempChar,sizeof(Char));
    Result := Result + tempChar;
    Inc(chOffset);
  until tempChar = #0;
  Result := Trim(Result);
end;

function ReadSavedRepName: string;
var
  tempChar: Char;
  chOffset: Cardinal;
begin
  Result := '';
  chOffSet := 0;
  repeat
    PeekMem(Offsets.SavedRepName+chOffset,@tempChar,sizeof(Char));
    Result := Result + tempChar;
    Inc(chOffset);
  until tempChar = #0;
  Result := Trim(Result);
end;

function IsInReplay: Boolean;
var
  InRepByte: Byte;
begin
  PeekMem(Offsets.InReplay,@InRepByte,1);
  Result := (InRepByte > 0) and IsInGame;
end;

function IsInGame: Boolean;
var
  InGameByte: Byte;
begin
  PeekMem(Offsets.InGame,@InGameByte,sizeof(Byte));
  Result := (InGameByte = 1); // should be 1 for both replay and game
end;

function IsPaused: Boolean;
var
  IsRepPaused, IsGamePaused: Byte;
begin
  if IsInReplay then
  begin
    PeekMem(Offsets.RepPaused,@IsRepPaused,1);
    PeekMem(Offsets.GamePaused,@IsGamePaused,1);
    Result := (IsRepPaused or IsGamePaused) = 1;
  end
  else
  begin
    PeekMem(Offsets.GamePaused,@IsGamePaused,1);
    Result := (IsGamePaused = 1);
  end;
end;

function IsGameComplete: Boolean;
var
  IsComplete: Byte;
begin
  PeekMem(Offsets.GameCompleteDlg,@IsComplete,1);
  Result := IsComplete = 1;
end;

function IsFastestSpeed: Boolean;
var
  TickTime: Byte;
  RepSpeedByte: Byte;
begin
  PeekMem(Offsets.RepSpeedTiming,@TickTime,1);
  PeekMem(Offsets.RepSpeed,@RepSpeedByte,1);
  Result := (TickTime = 42 ) and (RepSpeedByte = 6);
end;

function GetPNum: Integer;
begin
  if IsInReplay then
  begin
    Result := Integer(Pointer(Offsets.RepSelectedPlayer)^);
    if Result > 11 then
      Result := -1;
  end
  else
    Result := Integer(Pointer(Offsets.MyPNumAddr)^);
end;

procedure FitZeroTerminatedString(var S:String); // Thanks MoC
begin
  setlength(S,StrLen(PChar(S)));
end;

function GetPlayerName(Player: byte): string; // Thanks MoC
begin
  SetLength(Result,24);
  Move(Pointer(Offsets.PlayerNames+36*Player)^,Result[1],Length(Result));
  FitZeroTerminatedString(Result);
end;

function GetBuildingsControlled(Player: Byte): Integer;
begin
  PeekMem((Player*4)+Offsets.BuildingsControlled,@Result,4);
end;

function GetPopulation(Player: Byte): Integer;
begin
  PeekMem((Player*4)+Offsets.Population,@Result,4);
end;

function GetMinerals(Player: Byte): Integer;
begin
  PeekMem((Player*4)+Offsets.Minerals,@Result,4);
end;

function GetVespene(Player: Byte): Integer;
begin
  PeekMem((Player*4)+Offsets.Vespene,@Result,4);
end;

function GetCurTextFormat: Cardinal;
begin
  PeekMem(Offsets.CurTextFormat,@Result,4);
end;

function IsObsMode: Boolean;
var
  PNum: Byte;
begin
  // we need to handle both initial obs, and "almost dead" obs
  // we also need to try to avoid annoying/hacky UMS obs accidents
  // so the conditions are: (buildings <= 1 and units <= 2 and minerals <= 50 and vespenes == 0)
  // or (buildings <= 1 and units == 0)
  PNum := Byte(GetPNum);
  if GetPNum = -1 then
    Result := IsInReplay
  else
    Result := ( (GetBuildingsControlled(PNum)<=1) and (GetPopulation(PNum)<=2) // init obs
                      and (GetMinerals(PNum)<=50) and (GetVespene(PNum)=0) )
              or ( (GetBuildingsControlled(PNum)<=1) and (GetPopulation(PNum)=0) ) // almost dead 'obs'
              or (IsInReplay);
end;

function ColorToColorCode(Color:byte):char;
begin
  case Color of
    $6F:result:=#$08;
    $A5:result:=#$0E;
    $9F:result:=#$0F;
    $A4:result:=#$10;
    $9C:result:=#$11;
    $13:result:=#$15;
    $54:result:=#$16;
    $87:result:=#$17;
    $B9:result:=#$18;
    $88:result:=#$19;
    $86:result:=#$1B;
    $33:result:=#$1C;
    $4D:result:=#$1D;
    $9A:result:=#$1E;
    $80:result:=#$1F;
    else result:=#2;
  end;
end;

function FactionColor(Faction:byte):byte;
begin
  result:=PByte(Offsets.PlayerColors+Faction)^;
end;

function FactionColorCode(Faction:byte):char;
begin
  result:=ColorToColorCode(FactionColor(Faction));
end;

function GetPlayerFaction(Player:byte):byte;
begin
  result:=Player;//PByte(Addresses.PlayerNames-1+36*Player)^;
end;

function GetColoredPlayerName(Player:byte):String;
begin
  result:=FactionColorCode(GetPlayerFaction(Player))+GetPlayerName(Player);
end;

initialization
  Offsets := Offsets1161;
finalization
end.

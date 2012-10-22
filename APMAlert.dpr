library APMAlert;

uses
  SysUtils,
  Classes,
  Windows,
  Dialogs,
  Config in 'Config.pas' {ConfigDialog},
  Main in 'Main.pas',
  BWUtil in 'BWUtil.pas',
  uBWAddresses in 'uBWAddresses.pas',
  uSpeedChanges in 'uSpeedChanges.pas';

{$E bwl}

const
  STARCRAFTBUILD: Integer = 13;
  PluginMajor = 1;
  PluginMinor = 0;
  PluginName = 'APMAlert (1.16.1)';
{
  STARCRAFTBUILD
      0 - 1.04                 
      1 - 1.08b
      2 - 1.09b
      3 - 1.10
      4 - 1.11b
      5 - 1.12b
      6 - 1.13f
      7 - 1.14
      8 - 1.15
      9 - 1.15.1
      10 - 1.15.2
      11 - 1.15.3
      12 - 1.16.0
      13 - 1.16.1
}

{$R *.res}
procedure OnInjection; // called only when we're injected into starcraft.exe
var
  APMThread: TAPMThread;
begin
  APMThread := TAPMThread.Create(True);
  APMThread.Init;
end;

procedure DllMain(reason: integer); // called every time the dll is loaded/unloaded
var
  buf : array[0..MAX_PATH] of char;
  loader : string;
begin
    case reason of
     DLL_PROCESS_ATTACH:
     begin
       GetModuleFileName(0, buf, SizeOf(buf));
       loader := buf;
       loader := ExtractFileName(loader);
       if Pos('starcraft', LowerCase(loader)) > 0 then
         OnInjection;
     end;
   end;
end;

function GetDescription:String;
begin
  Result := 'APMAlert v'+IntToStr(PluginMajor)+'.'+IntToStr(PluginMinor)+#13#10+
                'Alerts you with a sound when your APM falls below a certain level. Press F8 ingame to toggle on/off.'#13#10+
                'by tec27';
end;

type
  TBWL_ExchangeData=packed record
    PluginAPI:Integer;
    StarCraftBuild:Integer;
    NotSCBWmodule:LongBool;                //Inform user that closing BWL will shut down your plugin
    ConfigDialog:LongBool;                 //Is Configurable
  end;
//
//GET Functions for BWLauncher
//
//
procedure GetPluginAPI(var Data:TBWL_Exchangedata);cdecl;
begin
  //BWL Gets version from Resource - VersionInfo
  Data.PluginAPI := 4; //BWL 4
  Data.StarCraftBuild := STARCRAFTBUILD;    //1.15.2
  Data.ConfigDialog := True; // We display a config dialog
  Data.NotSCBWmodule := True; // No warning message
end;

procedure GetData(Name,Description,UpdateUrl:Pchar);cdecl;
begin
  //if necessary you can add Initialize function here
  //possibly check CurrentCulture (CultureInfo) to localize your DLL due to system settings
  StrPCopy(name, PluginName);
  StrPCopy(description, GetDescription);
  StrPCopy(updateurl, 'http://rockify.net/APMAlert/');
end;


//
//Functions called by BWLauncher
//
//
function OpenConfig():BOOL;cdecl;
var
  ConfigForm: TConfigDialog;
begin
  //If you set "Data.bConfigDialog = true;" at function GetPluginAPI then
  //BWLauncher will call this function if user clicks Config button

  //You'll need to make your own Window here
  // Open the config dialog
  ConfigForm:=TConfigDialog.Create(nil);
  try
    ConfigForm.ShowModal;
  finally
    ConfigForm.Free;
  end;
  Result := True;
end;

function ApplyPatchSuspended(hProcess:THandle;ProcessID:Cardinal):BOOL;cdecl;
begin
  //This function is called on suspended process
  //Durning the suspended process some modules of starcraft.exe may not yet exist.
  //the dwProcessID is not checked, its the created pi.dwProcessId

  //here is safe place to call starcraft methods to load your DLL as a module
  //hint - process shoudnt be suspended :)
  //hint - WNDPROCCALL

  //   dummy example
  //patch:array[0..0]of byte = ($90);
  //WriteProcessMemory( hProcess, Pointer($00123456), patch, sizeof(patch), nil);

  Result := True;
  //return false; //something went wrong
end;


function ApplyPatch(hProcess:THandle; ProcessID:Cardinal):BOOL;cdecl;
var
  RemoteStr, LoadLibAddr: Pointer;
  hSCProcess: THandle;
  FullDllName: string;
  hThread: Cardinal;
  buf : array[0..MAX_PATH] of char;
begin
  //This fuction is called after
  //ResumeThread(pi.hThread);
  //WaitForInputIdle(pi.hProcess, INFINITE);
  //EnableDebugPriv() - 
  //   OpenProcessToken...
  //   LookupPrivilegeValue...
  //   AdjustTokenPrivileges...
  //
  //the dwProcessID is checked by GetWindowThreadProcessId
  //so it is definitly the StarCraft

  GetModuleFileName(HInstance, buf, SizeOf(buf));
  FullDllName := buf;

  if not FileExists(FullDllName) then
    MessageBox(0, PChar('Could not find APMAlert''s BWL file!'), 'Error!', MB_ICONERROR or MB_OK);

  //hSCProcess := OpenProcess(PROCESS_ALL_ACCESS,false,ProcessID);
  hSCProcess := hProcess; // tip from MoC, I dunno why I was even using OpenProcess tbh
  {if hSCProcess = 0 then
  begin
    Result := False;
    MessageBox(0,PChar('Couldn''t Find SC Process. Error Code: ' + IntToStr(GetLastError())),'Error!', MB_OK or MB_ICONERROR);
    Exit;
  end;}

  // Our CreateRemoteThread Dll Injector :)
  LoadLibAddr := GetProcAddress(GetModuleHandle('kernel32.dll'),'LoadLibraryA');
  RemoteStr := VirtualAllocEx(hSCProcess,nil,StrLen(PChar(FullDllName)),MEM_COMMIT or MEM_RESERVE,PAGE_READWRITE);
  WriteProcessMemory(hSCProcess,RemoteStr,PChar(FullDllName),StrLen(PChar(FullDllName)),Cardinal(nil^));
  hThread := CreateRemoteThread(hSCProcess,nil,0,LoadLibAddr, RemoteStr, 0, Cardinal(nil^));
  if hThread = 0 then
    MessageBox(0,PChar('Remote thread creation failed. Error Code: ' + IntToStr(GetLastError())),'Error!', MB_OK or MB_ICONERROR);

  Result := True; //everything OK


  //return false; //something went wrong
end;

exports
  //BWL Version 4
  GetPluginAPI,
  GetData,
  OpenConfig,
  ApplyPatchSuspended,
  ApplyPatch,
  //My Functions
  DllMain;

begin
   DllProc := @DllMain;
   DllProc(DLL_PROCESS_ATTACH) ;

end.

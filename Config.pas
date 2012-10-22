unit Config;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Registry, StdCtrls, JvDialogs, XPMan, MMSystem, Buttons, ImgList,
  ComCtrls;

type
  TConfRecord = record
    PlaySound: Boolean;
    SoundFile: string;
    MinAPM: Single;
    PosX, PosY: Integer;
    EnableLiveAPM: Boolean;
    DispAllAPMs: Boolean;
    GameClockX, GameClockY: Integer;
    EnableGameClock: Boolean;
    LocalClockX, LocalClockY: Integer;
    EnableLocalClock: Boolean;
  end;

  TConfigDialog = class(TForm)
    btnSave: TButton;
    XPManifest1: TXPManifest;
    dlgOpen: TJvOpenDialog;
    btnResetDefaults: TButton;
    pcConfigBox: TPageControl;
    tsAlert: TTabSheet;
    cbPlaySound: TCheckBox;
    lblMinAPM: TLabel;
    edMinAPM: TEdit;
    edAlertSndFile: TEdit;
    btnAlertPreview: TButton;
    btnBrowse: TButton;
    lblAlertSndFile: TLabel;
    tsLiveAPM: TTabSheet;
    lblLiveAPMX: TLabel;
    lblLiveAPMY: TLabel;
    edLiveAPMX: TEdit;
    edLiveAPMY: TEdit;
    cbEnableLiveAPM: TCheckBox;
    cbDispAllAPMs: TCheckBox;
    tsGameClock: TTabSheet;
    lblGameClockX: TLabel;
    edGameClockX: TEdit;
    lblGameClockY: TLabel;
    edGameClockY: TEdit;
    cbEnableGameClock: TCheckBox;
    tsLocalClock: TTabSheet;
    cbEnableLocalClock: TCheckBox;
    lblLocalClockX: TLabel;
    edLocalClockX: TEdit;
    lblLocalClockY: TLabel;
    edLocalClockY: TEdit;
    procedure btnBrowseClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure btnResetDefaultsClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SetupConfForm(ConfRecord: TConfRecord);
  end;

procedure LoadAPMConf(var ConfRecord: TConfRecord; UseDefaults: Boolean = False);
procedure SaveAPMConf(ConfRecord: TConfRecord);
function GetSCDir: string;
function GetPluginDir: string;

var
  ConfigDialog: TConfigDialog;

implementation

{$R *.dfm}

function GetSCDir: string;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  Result := '';
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('SOFTWARE\Blizzard Entertainment\Starcraft', False) then
      Result := Reg.ReadString('InstallPath');
  finally
    Reg.CloseKey;
    Reg.Free;
  end;
end;

function GetPluginDir: string;
var
  buf: array[0..MAX_PATH] of char;
begin
  GetModuleFileName(HInstance, buf, SizeOf(buf));
  Result := ExtractFilePath(buf);
end;

procedure LoadAPMConf(var ConfRecord: TConfRecord; UseDefaults: Boolean = False);
var
  Reg: TRegistry;
begin
  with ConfRecord do
  begin
    PlaySound := True;
    SoundFile := GetPluginDir + 'alert.wav';
    MinAPM := 60.5;
    PosX := 4;
    PosY := 2;
    EnableLiveAPM := True;
    DispAllAPMs := True;
    GameClockX := 286;
    GameClockY := 2;    
    EnableGameClock := True;
    LocalClockX := 14;
    LocalClockY := 284;
    EnableLocalClock := True;
  end;
  if UseDefaults then exit;

  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('SOFTWARE\BWProgrammers\APMAlert', False) then
    begin
      if Reg.ValueExists('PlaySound') then
        ConfRecord.PlaySound := Reg.ReadBool('PlaySound');
      if Reg.ValueExists('SoundFile') then
        ConfRecord.SoundFile := Reg.ReadString('SoundFile');
      if Reg.ValueExists('MinAPM') then
        ConfRecord.MinAPM := Reg.ReadFloat('MinAPM');
      if Reg.ValueExists('PosX') then
        ConfRecord.PosX := Reg.ReadInteger('PosX');
      if Reg.ValueExists('PosY') then
        ConfRecord.PosY := Reg.ReadInteger('PosY');
      if Reg.ValueExists('EnableLiveAPM') then
        ConfRecord.EnableLiveAPM := Reg.ReadBool('EnableLiveAPM');
      if Reg.ValueExists('DispAllAPMs') then
        ConfRecord.DispAllAPMs := Reg.ReadBool('DispAllAPMs');
      if Reg.ValueExists('GameClockX') then
        ConfRecord.GameClockX := Reg.ReadInteger('GameClockX');
      if Reg.ValueExists('GameClockY') then
        ConfRecord.GameClockY := Reg.ReadInteger('GameClockY');
      if Reg.ValueExists('EnableGameClock') then
        ConfRecord.EnableGameClock := Reg.ReadBool('EnableGameClock');
      if Reg.ValueExists('LocalClockX') then
        ConfRecord.LocalClockX := Reg.ReadInteger('LocalClockX');
      if Reg.ValueExists('LocalClockY') then
        ConfRecord.LocalClockY := Reg.ReadInteger('LocalClockY');
      if Reg.ValueExists('EnableLocalClock') then
        ConfRecord.EnableLocalClock := Reg.ReadBool('EnableLocalClock');
    end;
  finally
    Reg.CloseKey;
    Reg.Free;
  end;
end;

procedure SaveAPMConf(ConfRecord: TConfRecord);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('SOFTWARE\BWProgrammers\APMAlert', True) then
    begin
      Reg.WriteBool('PlaySound', ConfRecord.PlaySound);
      Reg.WriteString('SoundFile',ConfRecord.SoundFile);
      Reg.WriteFloat('MinAPM',ConfRecord.MinAPM);
      Reg.WriteInteger('PosX',ConfRecord.PosX);
      Reg.WriteInteger('PosY',ConfRecord.PosY);
      Reg.WriteBool('EnableLiveAPM',ConfRecord.EnableLiveAPM);
      Reg.WriteBool('DispAllAPMs',ConfRecord.DispAllAPMs);
      Reg.WriteInteger('GameClockX',ConfRecord.GameClockX);
      Reg.WriteInteger('GameClockY',ConfRecord.GameClockY);
      Reg.WriteBool('EnableGameClock',ConfRecord.EnableGameClock);
      Reg.WriteInteger('LocalClockX',ConfRecord.LocalClockX);
      Reg.WriteInteger('LocalClockY',ConfRecord.LocalClockY);
      Reg.WriteBool('EnableLocalClock',ConfRecord.EnableLocalClock);
    end;
  finally
    Reg.Free;
  end;
end;

procedure TConfigDialog.btnBrowseClick(Sender: TObject);
begin
  if dlgOpen.Execute then
  begin
    edAlertSndFile.Text := dlgOpen.FileName;
  end;
end;

procedure TConfigDialog.btnResetDefaultsClick(Sender: TObject);
var
  ConfRecord: TConfRecord;
begin
  LoadAPMConf(ConfRecord, True);
  SetupConfForm(ConfRecord);
end;

procedure TConfigDialog.btnSaveClick(Sender: TObject);
var
  ConfRecord: TConfRecord;
begin
  with ConfRecord do
  begin
    PlaySound := cbPlaySound.Checked;
    SoundFile := edAlertSndFile.Text;
    MinAPM := StrToFloat(edMinAPM.Text);
    PosX := StrToInt(edLiveAPMX.Text);
    PosY := StrToInt(edLiveAPMY.Text);
    EnableLiveAPM := cbEnableLiveAPM.Checked;
    DispAllAPMs := cbDispAllAPMs.Checked;
    GameClockX := StrToInt(edGameClockX.Text);
    GameClockY := StrToInt(edGameClockY.Text);
    EnableGameClock := cbEnableGameClock.Checked;
    LocalClockX := StrToInt(edLocalClockX.Text);
    LocalClockY := StrToInt(edLocalClockY.Text);
    EnableLocalClock := cbEnableLocalClock.Checked;
  end;
  SaveAPMConf(ConfRecord);
  Self.Close;
end;

procedure TConfigDialog.SetupConfForm(ConfRecord: TConfRecord);
begin
  cbPlaySound.Checked := ConfRecord.PlaySound;
  edAlertSndFile.Text := ConfRecord.SoundFile;
  edMinAPM.Text := FloatToStr(ConfRecord.MinAPM);
  edLiveAPMX.Text := IntToStr(ConfRecord.PosX);
  edLiveAPMY.Text := IntToStr(ConfRecord.PosY);
  cbEnableLiveAPM.Checked := ConfRecord.EnableLiveAPM;
  cbDispAllAPMs.Checked := ConfRecord.DispAllAPMs;
  edGameClockX.Text := IntToStr(ConfRecord.GameClockX);
  edGameClockY.Text := IntToStr(ConfRecord.GameClockY);
  cbEnableGameClock.Checked := ConfRecord.EnableGameClock;
  edLocalClockX.Text := IntToStr(ConfRecord.LocalClockX);
  edLocalClockY.Text := IntToStr(ConfRecord.LocalClockY);
  cbEnableLocalClock.Checked := ConfRecord.EnableLocalClock;
end;

procedure TConfigDialog.FormCreate(Sender: TObject);
var
  ConfRecord: TConfRecord;
begin
  pcConfigBox.TabIndex := 0;
  dlgOpen.InitialDir := GetSCDir;
  LoadAPMConf(ConfRecord);
  SetupConfForm(ConfRecord);
end;

procedure TConfigDialog.BitBtn1Click(Sender: TObject);
begin
  sndPlaySound(PChar(edAlertSndFile.Text), SND_ASYNC);
end;

end.

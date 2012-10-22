object ConfigDialog: TConfigDialog
  Left = 444
  Top = 522
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = 'APMAlert Config'
  ClientHeight = 169
  ClientWidth = 305
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 16
  object pcConfigBox: TPageControl
    Left = 0
    Top = 0
    Width = 305
    Height = 137
    ActivePage = tsLocalClock
    Align = alTop
    TabOrder = 2
    object tsAlert: TTabSheet
      Caption = 'Alert'
      ExplicitLeft = 0
      ExplicitWidth = 0
      object lblMinAPM: TLabel
        Left = 82
        Top = 14
        Width = 90
        Height = 16
        Caption = 'Minimum APM:'
      end
      object lblAlertSndFile: TLabel
        Left = 4
        Top = 50
        Width = 72
        Height = 16
        Hint = 'The sound the plays you alert you that your APM is too low.'
        Caption = 'Alert Sound:'
        ParentShowHint = False
        ShowHint = True
      end
      object cbPlaySound: TCheckBox
        Left = 102
        Top = 78
        Width = 91
        Height = 17
        Caption = 'Play Sound'
        Checked = True
        State = cbChecked
        TabOrder = 0
      end
      object edMinAPM: TEdit
        Left = 185
        Top = 11
        Width = 34
        Height = 24
        TabOrder = 1
        Text = '60.5'
      end
      object edAlertSndFile: TEdit
        Left = 82
        Top = 48
        Width = 155
        Height = 24
        Hint = 'The sound the plays you alert you that your APM is too low.'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        Text = 'C:\Windows\Media\Ding.wav'
      end
      object btnAlertPreview: TButton
        Left = 268
        Top = 49
        Width = 25
        Height = 20
        Hint = 'Test the sound file.'
        Caption = '>'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
        OnClick = BitBtn1Click
      end
      object btnBrowse: TButton
        Left = 239
        Top = 50
        Width = 23
        Height = 19
        Caption = '..'
        TabOrder = 4
        OnClick = btnBrowseClick
      end
    end
    object tsLiveAPM: TTabSheet
      Caption = 'LiveAPM'
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object lblLiveAPMX: TLabel
        Left = 130
        Top = 16
        Width = 62
        Height = 16
        Caption = 'X Position:'
      end
      object lblLiveAPMY: TLabel
        Left = 130
        Top = 44
        Width = 64
        Height = 16
        Caption = 'Y Position:'
      end
      object edLiveAPMX: TEdit
        Left = 198
        Top = 13
        Width = 34
        Height = 24
        TabOrder = 0
        Text = '4'
      end
      object edLiveAPMY: TEdit
        Left = 198
        Top = 41
        Width = 34
        Height = 24
        TabOrder = 1
        Text = '2'
      end
      object cbEnableLiveAPM: TCheckBox
        Left = 62
        Top = 23
        Width = 62
        Height = 31
        Caption = 'Enable'
        Checked = True
        State = cbChecked
        TabOrder = 2
      end
      object cbDispAllAPMs: TCheckBox
        Left = 38
        Top = 69
        Width = 223
        Height = 31
        Caption = 'Display All APM'#39's in Replays/Obs'
        Checked = True
        State = cbChecked
        TabOrder = 3
      end
    end
    object tsGameClock: TTabSheet
      Caption = 'Game Clock'
      ImageIndex = 2
      ExplicitLeft = 0
      ExplicitWidth = 0
      object lblGameClockX: TLabel
        Left = 102
        Top = 40
        Width = 62
        Height = 16
        Caption = 'X Position:'
      end
      object lblGameClockY: TLabel
        Left = 102
        Top = 68
        Width = 64
        Height = 16
        Caption = 'Y Position:'
      end
      object edGameClockX: TEdit
        Left = 170
        Top = 37
        Width = 34
        Height = 24
        TabOrder = 0
        Text = '4'
      end
      object edGameClockY: TEdit
        Left = 170
        Top = 65
        Width = 34
        Height = 24
        TabOrder = 1
        Text = '2'
      end
      object cbEnableGameClock: TCheckBox
        Left = 121
        Top = 3
        Width = 64
        Height = 31
        Caption = 'Enable'
        Checked = True
        State = cbChecked
        TabOrder = 2
      end
    end
    object tsLocalClock: TTabSheet
      Caption = 'Local Clock'
      ImageIndex = 3
      object lblLocalClockX: TLabel
        Left = 102
        Top = 40
        Width = 62
        Height = 16
        Caption = 'X Position:'
      end
      object lblLocalClockY: TLabel
        Left = 102
        Top = 68
        Width = 64
        Height = 16
        Caption = 'Y Position:'
      end
      object cbEnableLocalClock: TCheckBox
        Left = 121
        Top = 3
        Width = 64
        Height = 31
        Caption = 'Enable'
        Checked = True
        State = cbChecked
        TabOrder = 0
      end
      object edLocalClockX: TEdit
        Left = 170
        Top = 37
        Width = 34
        Height = 24
        TabOrder = 1
        Text = '4'
      end
      object edLocalClockY: TEdit
        Left = 170
        Top = 65
        Width = 34
        Height = 24
        TabOrder = 2
        Text = '2'
      end
    end
  end
  object btnSave: TButton
    Left = 221
    Top = 143
    Width = 75
    Height = 25
    Caption = 'Save'
    TabOrder = 0
    OnClick = btnSaveClick
  end
  object btnResetDefaults: TButton
    Left = 8
    Top = 143
    Width = 113
    Height = 25
    Caption = 'Reset To Defaults'
    TabOrder = 1
    OnClick = btnResetDefaultsClick
  end
  object XPManifest1: TXPManifest
    Left = 8
    Top = 144
  end
  object dlgOpen: TJvOpenDialog
    Filter = 'Wav Files (*.wav)|*.wav|All Files|*.*'
    Options = [ofPathMustExist, ofFileMustExist, ofEnableSizing, ofDontAddToRecent]
    Title = 'Select a sound file...'
    DefBtnCaption = 'Select'
    Height = 451
    Width = 563
    Left = 48
    Top = 144
  end
end

unit LLHooks;

interface

uses Windows;

// structs/consts for LL keyboard/mouse hook
const
  LLKHF_EXTENDED  = $00000001;
  LLKHF_INJECTED  = $00000010;
  LLKHF_ALTDOWN   = $00000020;
  LLKHF_UP        = $00000080;
  WH_KEYBOARD_LL  = 13;
  WH_MOUSE_LL     = 14;

type
  pKBDLLHookStruct = ^TKBDLLHookStruct;
  {$EXTERNALSYM tagKBDLLHOOKSTRUCT}
  tagKBDLLHOOKSTRUCT = record
    vkCode      : DWORD;
    scanCode    : DWORD;
    flags       : DWORD;
    time        : DWORD;
    dwExtraInfo : DWORD;
  end;
  TKBDLLHookStruct = tagKBDLLHOOKSTRUCT;
  {$EXTERNALSYM KBDLLHOOKSTRUCT}
  KBDLLHOOKSTRUCT = tagKBDLLHOOKSTRUCT;

  pMSLLHookStruct = ^TMSLLHookStruct;
  {$EXTERNALSYM tagMSLLHOOKSTRUCT}
  tagMSLLHOOKSTRUCT = record
    pt          : TPoint;
    mouseData   : Cardinal;
    flags       : Cardinal;
    time        : Cardinal;
    dwExtraInfo : Cardinal;
  end;
  TMSLLHookStruct = tagMSLLHOOKSTRUCT;
  {$EXTERNALSYM tagMSLLHOOKSTRUCT}
  MSLLHOOKSTRUCT = tagMSLLHOOKSTRUCT;

implementation

end.

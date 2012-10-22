unit ConsoleFuncs;

interface

uses Windows, SysUtils, BWUtil, Token;

type
  TDrawnText = record
    X: DWORD;
    Y: DWORD;
    Text: PChar;
    Format: DWORD;
  end;

procedure DispText(Args: PChar);
procedure DrawText(Args: PChar);
procedure DoAbout;

var
  DrawnTextArr: array of TDrawnText;

implementation

procedure DispText(Args: PChar);
begin
  BWTextOut(#6'~~'#7'~~'#3'~~'#1' Command Worked!');
end;

procedure AddDrawnText(dX, dY: DWORD; dText: PChar; dFormat: DWORD);
begin
  SetLength(DrawnTextArr, Length(DrawnTextArr) + 1);
  with DrawnTextArr[Length(DrawnTextArr) - 1] do
  begin
    X := dX;
    Y := dY;
    Text := dText;
    Format := dFormat;
  end;
end;

function HexifyText(Text: string): string;
var
  CurChar: Integer;
  TempInt: Integer;
  WorkingStr: string;
  HexNumeric: set of Char;
  EscapedChars: set of Char;
begin
  HexNumeric := ['0'..'9', 'A'..'F', 'a'..'f'];
  EscapedChars := ['|','#'];

  CurChar := 1;
  WorkingStr := Text;
  Result := '';
  while CurChar <= Length(WorkingStr) do
  begin
    if WorkingStr[CurChar] <> '#' then
      Result := Result + WorkingStr[CurChar]
    else
    begin
      if not (WorkingStr[CurChar + 1] in EscapedChars) then // if its not a character that must be escaped
      begin
        TempInt := CurChar + 1;
        while (WorkingStr[TempInt] in HexNumeric) and (TempInt <= Length(WorkingStr)) do Inc(TempInt);
        Dec(TempInt); // TempInt will be one past the last hex char otherwise
        Result := Result + Chr(StrToInt('$' + Copy(WorkingStr, CurChar+1, TempInt - CurChar)));
        if TempInt < Length(WorkingStr) then
          CurChar := TempInt
        else
          break;
        if WorkingStr[CurChar + 1] = '|' then
          Inc(CurChar);
      end
    end;
    Inc(CurChar);
  end;

  Result := Result + #0;
end;

procedure DrawText(Args: PChar);
var
  X, Y: Integer;
  TextStr: string;
  Text: PChar;
  Size: Integer;
  Format: DWORD;
begin
  // Should be called with: X,Y,Text,[Size]
  // Hex chars may be used with #X (| to force end of a hex string)
  // '##' = '#', '#|' = '|' (so we can end hex strings on purpose)
  if NumToken(Args,',') >= 2 then
  begin
    X := StrToInt(GetToken(Args,',',1));
    Y := StrToInt(GetToken(Args,',',2));
    TextStr := HexifyText(GetToken(Args,',',3));
    Text := AllocMem(Length(TextStr) + 1);
    StrPCopy(Text,TextStr);
    if NumToken(Args,',') = 2 then
      AddDrawnText(X, Y, Text, bwtf_Normal)
    else
    begin
      Size := StrToInt(GetToken(Args,',',4));
      case Size of
        1: Format := bwtf_Mini;
        2: Format := bwtf_Normal;
        3: Format := bwtf_Large;
        4: Format := bwtf_UltraLarge;
      else
        Format := bwtf_Normal;
      end;
      AddDrawnText(X,Y,Text,Format);
    end;
  end;
end;

procedure DoAbout;
begin
  
end;

end.

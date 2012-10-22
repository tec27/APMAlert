unit uSpeedChanges;

interface

uses SysUtils, Classes, Windows;

const
  // Replay Speed Identifiers
  RS_SLOWEST: Byte  = 0;
  RS_SLOWER: Byte   = 1;
  RS_SLOW: Byte     = 2;
  RS_NORMAL: Byte   = 3;
  RS_FAST: Byte     = 4;
  RS_FASTER: Byte   = 5;
  RS_FASTEST: Byte  = 6;
  RS_X2: Byte       = 7;
  RS_X4: Byte       = 8;
  RS_X8: Byte       = 9;
  RS_X16: Byte      = 10;

type
  PSpeedChange = ^TSpeedChange;
  TSpeedChange = record
    NewSpeed: Byte;
    CurTick: Cardinal;
  end;

  TSpeedChanges = class(TList)
    private 
    function GetItem(Index: Integer): TSpeedChange;
    procedure SetItem(Index: Integer; const Value: TSpeedChange);
    function GetPItem(Index: Integer): PSpeedChange;
    procedure SetPItem(Index: Integer; const Value: PSpeedChange);
  public 
    property Items[Index:Integer]: TSpeedChange read GetItem write SetItem; default;
    property PItems[Index:Integer]: PSpeedChange read GetPItem write SetPItem;
    function AddSpeedChange(Item: TSpeedChange): Integer;
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  end;

function GetTickTimeForSpeed(Speed: Byte): Cardinal;
function ConvertSpeedTicksToRS(RepSpeed: Byte; Ticks: Byte): Byte;

implementation

function GetTickTimeForSpeed(Speed: Byte): Cardinal;
begin
  if Speed = RS_X16 then Result := 2
  else if Speed = RS_X8 then Result := 5
  else if Speed = RS_X4 then Result := 10
  else if Speed = RS_X2 then Result := 21
  else if Speed = RS_FASTEST then Result := 42
  else if Speed = RS_FASTER then Result := 48
  else if Speed = RS_FAST then Result := 56
  else if Speed = RS_NORMAL then Result := 67
  else if Speed = RS_SLOW then Result := 83
  else if Speed = RS_SLOWER then Result := 111
  else if Speed = RS_SLOWEST then Result := 167
  else Result := 42;
end;

function ConvertSpeedTicksToRS(RepSpeed: Byte; Ticks: Byte): Byte;
begin
  if RepSpeed <= 5 then Result := RepSpeed
  else
  begin
    if Ticks = 42 then
      Result := RS_FASTEST
    else if Ticks = 21 then
      Result := RS_X2
    else if Ticks = 10 then
      Result := RS_X4
    else if Ticks = 5 then
      Result := RS_X8
    else if Ticks = 2 then
      Result := RS_X16
    else Result := 11; // 11 = invalid speed
  end;
end;


function TSpeedChanges.AddSpeedChange(Item: TSpeedChange): Integer;
var 
  Relay: PSpeedChange;
begin 
  New(Relay); 
  Relay^ := Item; 
  Result := inherited Add(Relay); 
end;

function TSpeedChanges.GetItem(Index: Integer): TSpeedChange;
begin 
  Result := PSpeedChange(inherited Items[Index])^;
end;

procedure TSpeedChanges.SetItem(Index: Integer; const Value: TSpeedChange);
begin
  PSpeedChange(inherited Items[Index])^ := Value;
end;

procedure TSpeedChanges.Notify(Ptr: Pointer; Action: TListNotification);
begin 
  inherited;
  if ( Action = lnDeleted ) then 
    Dispose(Ptr); 
end;

function TSpeedChanges.GetPItem(Index: Integer): PSpeedChange;
begin 
  Result := inherited Items[Index]; 
end;

procedure TSpeedChanges.SetPItem(Index: Integer; const Value: PSpeedChange);
begin 
  inherited Items[Index] := Value; 
end;

end.

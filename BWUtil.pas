unit BWUtil;

interface

uses Windows;

procedure WriteMem(MemOffset, DataPtr, DataLen: DWORD); stdcall;
procedure JmpPatch(Location, JumpTo: DWORD); stdcall;
procedure BWCenteredTextOut(Text: PChar); stdcall; overload;
procedure BWTextOut(Text: PChar); stdcall; overload;
procedure BWDrawBox(x,y,w,h: DWORD; clr: BYTE); stdcall;
procedure BWDrawTransparentBox(x,y,w,h: DWORD; clr, midclr: BYTE); stdcall;
procedure BWDrawText(x, y: DWORD; str: PChar); stdcall;
procedure BWRestoreTextFormat(StoredFormat: DWORD); stdcall;
procedure BWFormatText(format: DWORD); stdcall;
procedure BWFormatTextR(format: DWORD); stdcall;
procedure BWDrawFormattedText(x, y: DWORD; str: PChar; format: DWORD); stdcall;
procedure BWRefreshText(x, y, x2, y2: DWORD); stdcall;
function BWGetTextRect(x, y: DWORD; str: PChar): TRect; stdcall;
function BWGetTextWidth(str: PChar): Integer; stdcall;

implementation

uses SysUtils, uBWAddresses;

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

procedure JmpPatch(Location, JumpTo: DWORD); stdcall;
var
  lgJmp: array[0..4] of Byte;
begin
  asm
    pushad
    mov	ebx, [JumpTo];
    mov	ecx, [Location];
    add	ecx, 05h
    sub	ebx, ecx
    lea	ecx, lgJmp
    mov	byte ptr [ecx], 0E9h
    mov	dword ptr [ecx+1], ebx
    popad
  end;
  WriteMem(Location, DWORD(@lgJmp), 5);
end;

procedure BWCenteredTextOut(Text: PChar); stdcall; overload;
asm
  pushad
	mov esi, [Text]
  mov eax, -1
  push 0h
  push esi
	call dword ptr [Offsets.BWFXN_CTextOut]
	popad
end;

procedure BWTextOut(Text: PChar); stdcall; overload;
asm
  pushad
  xor eax,eax
  mov edi,Text
  call dword ptr [Offsets.BWFXN_TextOut]
  popad
end;

procedure BWDrawBox(x,y,w,h: DWORD; clr: BYTE); stdcall;
// Thanks Perma
asm
  pushad
  mov cl,clr
  mov eax,[Offsets.BoxColor]
  mov byte ptr ds:[eax], cl
  push h
  push w
  push y
  push x
  call dword ptr [Offsets.BWFXN_DrawBox]
  popad
end;

procedure BWDrawTransparentBox(x,y,w,h: DWORD; clr, midclr: BYTE); stdcall;
// Thanks Zephyrix
var
  I,Z: Integer;
  bDraw: Boolean;
begin
  bDraw := True;
  for I := y to y+h-1 do    // Iterate to draw innards
  begin
    for Z := x to x+w-1 do    // Iterate
    begin
      if bDraw then
        BWDrawBox(Z,I,1,1,midclr);
      bDraw := not bDraw;
    end;    // for
    if w mod 2 = 0  then
      bDraw := not bDraw;
  end;    // for

  // draw border
  BWDrawBox(x, y, w, 2, clr);
  BWDrawBox(x, y+h, w+1, 2, clr);
  BWDrawBox(x, y, 1, h, clr);
  BWDrawBox(x+w, y, 1, h, clr);
end;

procedure BWDrawText(x, y: DWORD; str: PChar); stdcall;
asm
  pushad
  mov eax, [str]
  mov esi, x
  push y
  call dword ptr [Offsets.BWFXN_DrawText]
  popad
end;

procedure BWRestoreTextFormat(StoredFormat: DWORD); stdcall;
asm
  pushad
  mov ecx, StoredFormat
  call dword ptr [Offsets.BWFXN_FormatText]
  popad
end;

procedure BWFormatText(format: DWORD); stdcall;
asm
  pushad
  cmp format, 0
  jnz @PtrLoad
  xor ecx, ecx
  jmp @FuncCall
@PtrLoad:
  mov eax, DWORD PTR SS: [format]
  mov ecx, DWORD PTR DS: [eax]
@FuncCall:
  call dword ptr [Offsets.BWFXN_FormatText]
  popad
end;

procedure BWFormatTextR(format: DWORD); stdcall; // calls Reset first so we can change the font properly
begin
  BWFormatText(Offsets.bwtf_Reset);
  BWFormatText(format);
end;

procedure BWDrawFormattedText(x, y: DWORD; str: PChar; format: DWORD); stdcall;
begin
  BWFormatTextR(format);
  BWDrawText(x, y, str);
end;

procedure BWRefreshText(x, y, x2, y2: DWORD); stdcall;
asm
  pushad
  push x2
  mov eax, x
  mov ecx, y
  mov edx, y2
  call dword ptr [Offsets.BWFXN_RefreshText];
  popad
end;

// NOTE: This will oddly actually draw the string, which is not what we want
function BWGetTextRect(x, y: DWORD; str: PChar): TRect; stdcall;
begin
  asm
    pushad
    push ecx
    lea ecx,[esp]
    push ecx
    mov eax, [Offsets.TextRectX]
    mov edi, x
    mov dword ptr [eax],edi
    mov eax, [Offsets.TextRectY]
    mov edi, y
    mov dword ptr [eax],edi
    mov eax,[str]
    call dword ptr [Offsets.BWFXN_GetTextRect]
    pop ecx
    popad
  end;
  Result.Left := (Integer(Word(Pointer(Offsets.TextRectLeft)^)));
  Result.Top := (Integer(Word(Pointer(Offsets.TextRectTop)^)));
  Result.Right := (Integer(Word(Pointer(Offsets.TextRectRight)^)));
  Result.Bottom := (Integer(Word(Pointer(Offsets.TextRectBottom)^)));
end;

function BWGetTextWidth(str: PChar): Integer; stdcall;
begin
  asm
    pushad
    mov ecx, [Offsets.TextWidth]
    mov dword ptr ds:[ecx],0
    mov eax, [str]
    call dword ptr [Offsets.BWFXN_GetTextWidth]
    popad
  end;
  Result := (PInteger(Offsets.TextWidth))^;
end;

end.

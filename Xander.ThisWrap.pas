(*=========== (C) Copyright 2019, Alexander B. All rights reserved. ===========*)
(*                                                                             *)
(*  Module:                                                                    *)
(*    Xander.ThisWrap                                                          *)
(*                                                                             *)
(*  Description:                                                               *)
(*=============================================================================*)

unit Xander.ThisWrap;

interface

type
  TThisCall = function(PClass, PFunc: Pointer): Pointer; stdcall varargs;

const
  ThisCall: TThisCall = nil;

implementation

function __ThisCall(PClass, PFunc: Pointer): Pointer; assembler;
asm
  cmp dword [esp + 4], 0 // is PFunc nil?
  jz @A
  cmp dword [esp + 8], 0 // is PClass nil?
  jz @A

  pop edx // return address
  pop ecx // class (this) pointer
  pop eax // function for call
  push edx

  jmp eax

@A:
  or eax, -1
  ret 8
end;

initialization
  ThisCall := @__ThisCall;
end.
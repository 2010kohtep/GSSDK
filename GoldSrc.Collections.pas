(*=========== (C) Copyright 2019, Alexander B. All rights reserved. ===========*)
(*                                                                             *)
(*  Module:                                                                    *)
(*    GoldSrc.Collections                                                      *)
(*                                                                             *)
(*  License:                                                                   *)
(*    You may freely use this code provided you retain this copyright message. *)
(*                                                                             *)
(*  Description:                                                               *)
(*=============================================================================*)

unit GoldSrc.Collections;

{$POINTERMATH ON}

interface

procedure CopyConstruct(var Memory: Pointer; const Src); inline;
function UtlMemory_CalcNewAllocationCount(AllocationCount, GrowSize, NewSize, BytesItem: Integer): Integer;

type
  TUtlMemoryAlloc = function(Size: Integer): Pointer;

procedure UtlMemory_PushMemAlloc(Func: TUtlMemoryAlloc);
procedure UtlMemory_PopMemAlloc;

function malloc(Size: Integer): Pointer cdecl; external 'msvcrt';
function realloc(P: Pointer; Size: Integer): Pointer cdecl; external 'msvcrt';
procedure free(P: Pointer) cdecl; external 'msvcrt';

type
  CUtlMemory<T, I { = Integer}> = record
  public type PT = ^T;
  private
    function TI(const Value: Integer): Integer; inline;
    function GetElement(Index: Integer): PT;
  public
    FMemory: PT;
    FAllocationCount: Integer;
    FGrowSize: Integer;

    constructor Create(GrowSize: Integer; InitSize: Integer); overload;
    constructor Create(Memory: PT); overload;
    constructor Create(const Memory: PT; NumElements: Integer); overload;

    procedure Init(GrowSize: Integer = 0; InitSize: Integer = 0);
    procedure Grow(Number: Integer = 1);

    function IsExternallyAllocated: Boolean;

    property Element[Index: Integer]: PT read GetElement; default;

    property NumAllocated: Integer read FAllocationCount;
  end;

  CUtlVector<T, A { = Integer}> = record
  public type PT = ^T;
  public
    Base: CUtlMemory<T, Integer>;

    FSize: Integer;
    FElements: PT;

    procedure GrowVector(Number: Integer = 1);

    function IsValidIndex(Idx: Integer): Boolean; inline;

    function InsertBefore(Elem: Integer; const Src: T): Integer;
    procedure ShiftElementsRight(Elem: Integer; Number: Integer = 1);
    function AddToTail(const Src: T): Integer;
  end;

type
  UtlSymId_t = Word;
  TUtlSymId = UtlSymId_t;

const
  MAX_STRING_POOL_SIZE = 256;
  UTL_INVAL_SYMBOL: TUtlSymId = TUtlSymId(not 0);
  INVALID_STRING_INDEX: Cardinal = Cardinal(-1);

type
  PCUtlSymbolTable = ^CUtlSymbolTable;
  CUtlSymbolTable = record

  end;

type
  LessCtx_t = record
    UserString: PAnsiChar;
    Table: PCUtlSymbolTable;
  end;
  TLessCtx = LessCtx_t;
  PLessCtx = ^TLessCtx;

type
  CUtlSymbol = record
    FID: TUtlSymId;

    constructor Create(ID: TUtlSymId); overload;
    constructor Create(Str: PAnsiChar); overload;
    constructor Create(const Sym: CUtlSymbol); overload;

    class operator Equal(const A: CUtlSymbol; B: PAnsiChar): Boolean;
  end;

implementation

uses
  System.Generics.Collections, Xander.ThisWrap;

procedure CopyConstruct(var Memory: Pointer; const Src); inline;
begin
  PPointer(Memory)^ := @Src;
end;

{ CUtlMemory<T, I> }

function UtlMemory_CalcNewAllocationCount(AllocationCount, GrowSize, NewSize, BytesItem: Integer): Integer;
begin
  if GrowSize <> 0 then
  begin
    AllocationCount := ((1 + ((NewSize - 1) div GrowSize)) * GrowSize);
  end
  else
  begin
    if AllocationCount = 0 then
    begin
      // Compute an allocation which is at least as big as a cache line...
      AllocationCount := (31 + BytesItem) div BytesItem;
    end;

    while AllocationCount < NewSize do
    begin
      AllocationCount := AllocationCount * 2;
    end;
  end;

  Result := AllocationCount;
end;

constructor CUtlMemory<T, I>.Create(GrowSize, InitSize: Integer);
begin
  inherited;
end;

constructor CUtlMemory<T, I>.Create(Memory: PT);
begin
  inherited;
end;

constructor CUtlMemory<T, I>.Create(const Memory: PT; NumElements: Integer);
begin
  inherited;
end;

function CUtlMemory<T, I>.GetElement(Index: Integer): PT;
begin
  Result := @FMemory[Index];
end;

procedure CUtlMemory<T, I>.Grow(Number: Integer);
var
  AllocationCount: Integer;
  AllocationRequested: Integer;
begin
  if IsExternallyAllocated then
  begin
    // Can't grow a buffer whose memory was externally allocated
    Assert(False);
    Exit;
  end;

	// Make sure we have at least numallocated + num allocations.
	// Use the grow rules specified for this memory (in m_nGrowSize)
  AllocationRequested := FAllocationCount + Number;

  AllocationCount := UtlMemory_CalcNewAllocationCount(FAllocationCount, FGrowSize, AllocationRequested, SizeOf(T));

  // if m_nAllocationRequested wraps index type I, recalculate
  if Integer(TI(FAllocationCount)) < AllocationRequested then
  begin
    if (Integer(TI(FAllocationCount)) = 0) and (Integer(TI(FAllocationCount - 1)) >= AllocationRequested) then
    begin
      Dec(AllocationRequested);
    end
    else
    begin
      if Integer(TI(AllocationRequested)) <> AllocationRequested then
      begin
        // we've been asked to grow memory to a size s.t. the index type can't address the requested amount of memory
        Assert(False);
        Exit;
      end;

      while Integer(TI(FAllocationCount)) < AllocationRequested do
      begin
        FAllocationCount := (FAllocationCount + AllocationRequested) div 2;
      end;
    end;
  end;

  if FMemory <> nil then
  begin
    FMemory := realloc(PT(FMemory), AllocationCount * SizeOf(T));
    Assert(FMemory <> nil);
  end
  else
  begin
    FMemory := malloc(AllocationCount * SizeOf(T));
    Assert(FMemory <> nil);
  end;
end;

//destructor CUtlMemory<T, I>.Destroy;
//begin
//
//  inherited Destroy;
//end;

procedure CUtlMemory<T, I>.Init(GrowSize, InitSize: Integer);
begin

end;

function CUtlMemory<T, I>.IsExternallyAllocated: Boolean;
begin
  Result := FGrowSize < 0;
end;

function CUtlMemory<T, I>.TI(const Value: Integer): Integer;
var
  Mask: Integer;
begin
  Mask := High(Integer) - 1;
  Result := Value and Mask; // TODO: High(I) - 1
end;

{ CUtlVector<T, A> }

function CUtlVector<T, A>.AddToTail(const Src: T): Integer;
begin
  Result := InsertBefore(FSize, Src);
end;

procedure CUtlVector<T, A>.GrowVector(Number: Integer);
begin
  if (FSize + Number > Base.NumAllocated) then
  begin
    Base.Grow(FSize + Number - Base.NumAllocated);
  end;

  Inc(FSize, Number);
  // TODO: ResetDbgInfo()
end;

function CUtlVector<T, A>.InsertBefore(Elem: Integer; const Src: T): Integer;
var
  P: Pointer;
  Data: PT;
begin
  P := Base.Element[Elem];

  Data := malloc(SizeOf(Src));
  Data^ := Src;

  GrowVector;
  ShiftElementsRight(Elem);
  Base.Element[Elem]^ := Data^;
  //CopyConstruct(P, Src);

  Exit(Elem);
end;

function CUtlVector<T, A>.IsValidIndex(Idx: Integer): Boolean;
begin
  Result := (Idx >= 0) and (Idx < FSize);
end;

procedure CUtlVector<T, A>.ShiftElementsRight(Elem, Number: Integer);
var
  NumToMove: Integer;
begin
  Assert(IsValidIndex(Elem));
  Assert(FSize <> 0);
  Assert(Number <> 0);

  NumToMove := FSize - Elem - Number;
  if (NumToMove > 0) and (Number > 0) then
    Move(Base.Element[Elem + Number]^, Base.Element[Elem]^, NumToMove * SizeOf(T));
end;

var
  MemoryAllocatorStack: TList<TUtlMemoryAlloc>;

procedure UtlMemory_PushMemAlloc(Func: TUtlMemoryAlloc);
begin
  MemoryAllocatorStack.Add(Func);
end;

procedure UtlMemory_PopMemAlloc;
begin
  MemoryAllocatorStack.Delete(MemoryAllocatorStack.Count - 1);
end;

{ CUtlSymbol }

constructor CUtlSymbol.Create(ID: TUtlSymId);
begin
  FID := ID;
end;

constructor CUtlSymbol.Create(Str: PAnsiChar);
begin

end;

constructor CUtlSymbol.Create(const Sym: CUtlSymbol);
begin

end;

class operator CUtlSymbol.Equal(const A: CUtlSymbol; B: PAnsiChar): Boolean;
begin
  if A.FID = UTL_INVAL_SYMBOL then
    Exit(False);

  // ...

  Exit(True);
end;

initialization
  MemoryAllocatorStack := TList<TUtlMemoryAlloc>.Create;

end.

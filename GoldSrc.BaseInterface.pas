(*=========== (C) Copyright 2019, Alexander B. All rights reserved. ===========*)
(*                                                                             *)
(*  Module:                                                                    *)
(*    GoldSrc.BaseInterface                                                    *)
(*                                                                             *)
(*  License:                                                                   *)
(*    You may freely use this code provided you retain this copyright message. *)
(*                                                                             *)
(*  Description:                                                               *)
(*=============================================================================*)

unit GoldSrc.BaseInterface;

interface

type
 PCreateInterfaceFn = ^TCreateInterfaceFn;
 TCreateInterfaceFn = function(Name: PAnsiChar; ReturnCode: PInteger): Pointer; cdecl;

type
  // interface return status
  IInterfaceReturnCode =
  (
    IFACE_OK = 0,
    IFACE_FAILED
  );

{$REGION 'IBaseInterface'}
  PVIBaseInterface = ^VIBaseInterface;
  VIBaseInterface = object
  public
    Destroy: procedure(Free: Boolean); stdcall;
  end;

  IBaseInterface = ^PVIBaseInterface;
{$ENDREGION}

implementation

end.

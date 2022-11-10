(*============ (C) Copyright 2019, Alexander B. All rights reserved. ============*)
(*                                                                               *)
(*  Module:                                                                      *)
(*    GoldSrc.GoldSrc.VGUI.ServerBrowser                                         *)
(*                                                                               *)
(*  License:                                                                     *)
(*    You may freely use this code provided you retain this copyright message.   *)
(*                                                                               *)
(*  Description:                                                                 *)
(*     Binary-correct implementation of virtual tables for working with          *)
(*     serverbrowser.dll library objects.                                        *)
(*                                                                               *)
(*     In Linux, virtual methods created through multiple inheritance            *)
(*     are copied to the class table, while in Windows they                      *)
(*     are implemented in separate tables, pointers to which are written         *)
(*     into class fields. For example, if you need to use the functions of       *)
(*     IGameList, then you need to perform a special offset relative to this     *)
(*     class, which inherits the methods of this interface, and then perform a   *)
(*     dereference, as a result, a pointer to the desired interface will         *)
(*     be obtained.                                                              *)
(*===============================================================================*)

unit GoldSrc.VGUI.ServerBrowser;

{$Z4}
{$A4}

interface

uses
  Steam.API,
  GoldSrc.KeyValues,
  GoldSrc.VGUI;

type
  EMatchMakingServerResponse =
  (
    eServerResponded = 0,
    eServerFailedToRespond,
    eNoServersListedOnMasterServer // for the Internet query type, returned in response callback if no servers of this type match
  );

  serverdisplay_t = record
    ListID, ServerID: Integer;
    DoNotRefresh: Boolean;
  end;
  TServerDisplay = serverdisplay_t;
  PServerDisplay = ^TServerDisplay;

{$REGION 'IGameList'}
	InterfaceItem_e =
	(
		FILTERS = 0,
		GETNEWLIST,
		ADDSERVER,
		ADDCURRENTSERVER
	);

  PVTableIGameList = ^VTableIGameList;
  VTableIGameList = object
  public
    // returns true if the game list supports the specified ui elements
    SupportsItem: function(Item: InterfaceItem_e): Boolean; stdcall;

    // starts the servers refreshing
    StartRefresh: procedure; stdcall;

    // gets a new server list
    GetNewServerList: procedure; stdcall;

    // stops current refresh/GetNewServerList()
    StopRefresh: procedure; stdcall;

    // returns true if the list is currently refreshing servers
    IsRefreshing: function: Boolean; stdcall;

    // gets information about specified server
    GetServer: function(const ServerID: Integer): PServerDisplay; stdcall;

    // gets information about specified server from SteamMatchmakingServers interface
    GetServerInfo: function(const ServerID: Integer): PGameServerItem; stdcall;

    // called when Connect button is pressed
    OnBeginConnect: procedure; stdcall;

    // invalid server index
    GetInvalidServerListID: function: Integer; stdcall;
  end;

  IGameList = ^PVTableIGameList;
{$ENDREGION}

{$REGION 'ISteamMatchmakingServerListResponse'}
  PVTableISteamMatchmakingServerListResponse = ^VTableISteamMatchmakingServerListResponse;
  VTableISteamMatchmakingServerListResponse = object
  public
  	ServerResponded: procedure(Server: Integer); stdcall;
	  ServerFailedToRespond: procedure(Server: Integer); stdcall;
  	RefreshComplete: procedure(Response: EMatchMakingServerResponse); stdcall;
  end;

  ISteamMatchmakingServerListResponse = ^PVTableISteamMatchmakingServerListResponse;
{$ENDREGION}

{$REGION 'ISteamMatchmakingPingResponse'}
  PVTableISteamMatchmakingPingResponse = ^VTableISteamMatchmakingPingResponse;
  VTableISteamMatchmakingPingResponse = object
  public
	  ServerResponded: procedure(const Server: TGameServerItem); stdcall;
  	ServerFailedToRespond: procedure; stdcall;
  end;

  ISteamMatchmakingPingResponse = ^PVTableISteamMatchmakingPingResponse;
{$ENDREGION}

{$REGION 'ISteamMatchmakingPlayersResponse'}
  PVTableISteamMatchmakingPlayersResponse = ^VTableISteamMatchmakingPlayersResponse;
  VTableISteamMatchmakingPlayersResponse = object
  public
    AddPlayerToList: procedure(Name: PAnsiChar; Score: Integer; TimePlayed: Single); stdcall;
    PlayersFailedToRespond: procedure; stdcall;
    PlayersRefreshComplete: procedure; stdcall;
  end;

  ISteamMatchmakingPlayersResponse = ^PVTableISteamMatchmakingPlayersResponse;
{$ENDREGION}

{$REGION 'ISteamMatchmakingRulesResponse'}
  PVTableISteamMatchmakingRulesResponse = ^VTableISteamMatchmakingRulesResponse;
  VTableISteamMatchmakingRulesResponse = object
  public
    RulesResponded: procedure(Rule, Value: PAnsiChar); stdcall;
    RulesFailedToRespond: procedure; stdcall;
    RulesRefreshComplete: procedure; stdcall;
  end;

  ISteamMatchmakingRulesResponse = ^PVTableISteamMatchmakingRulesResponse;
{$ENDREGION}

{$REGION 'CBaseGamesPage'}
  PVTableCBaseGamesPage = ^VTableCBaseGamesPage;
  VTableCBaseGamesPage = object(VTablePropertyPage)
  public
    SetRefreshing: procedure(State: Boolean); stdcall;

    // loads filter settings from disk
	  LoadFilterSettings: procedure; stdcall;

    // Called by CGameList when the enter key is pressed.
    // This is overridden in the add server dialog - since there is no Connect button, the message
    // never gets handled, but we want to add a server when they dbl-click or press enter.
  	OnGameListEnterPressed: procedure; stdcall;

	  // adds a server to the favorites
	  OnAddToFavorites: procedure; stdcall;

    OnLoadModList: procedure(AppID: UInt64); stdcall;

	  GetRegionCodeToFilter: function: Integer; stdcall;

    OnItemSelected: procedure; stdcall;

    // ISteamMatchmakingServerListResponse callbacks
    ServerResponded: procedure(Server: Integer); stdcall;

    BShowServer: function(const Server: TServerDisplay): Boolean; stdcall;

    // filtering methods
    // returns true if filters passed; false if failed
    CheckPrimaryFilters: function(const Server: TGameServerItem): Boolean; stdcall;
    CheckSecondaryFilters: function(const Server: TGameServerItem): Boolean; stdcall;

    OnSaveFilter: procedure(Filter: PKeyValues); stdcall;
    OnLoadFilter: procedure(Filter: PKeyValues); stdcall;

    // called to look at game info
    OnViewGameInfo: procedure; stdcall;
    // refreshes a single server
    OnRefreshServer: procedure(ServerID: Integer); stdcall;

    OnButtonToggled: procedure(Panel: Pointer; State: Integer); stdcall;
    OnTextChanged: procedure(Panel: Pointer; Text: PAnsiChar); stdcall;
  end;

  CBaseGamesPage = ^PVTableCBaseGamesPage;
{$ENDREGION}

{$REGION 'CInternetGames'}
  PVTableCInternetGames = ^VTableCInternetGames;
  VTableCInternetGames = object(VTableCBaseGamesPage)
  public
    OnOpenContextMenu: procedure(ItemID: Integer); stdcall;
  end;

  CInternetGames = ^PVTableCInternetGames;
{$ENDREGION}

{$REGION 'CFavoriteGames'}
  PVTableCFavoriteGames = ^VTableCFavoriteGames;
  VTableCFavoriteGames = object(VTableCBaseGamesPage)
  public
    // context menu message handlers
    OnOpenContextMenu: procedure(ItemID: Integer); stdcall;
    OnRemoveFromHistory: procedure; stdcall;
    OnAddServerByName: procedure; stdcall;
  end;

  CFavoriteGames = ^PVTableCFavoriteGames;
{$ENDREGION}

{$REGION 'CServerBrowserDialog'}
  PVTableCServerBrowserDialog = ^VTableCServerBrowserDialog;
  VTableCServerBrowserDialog = object(VTableFrame)
  public
    GetCurrentConnectedServer: function: PGameServerItem; stdcall;
    // current game list change
    OnGameListChanged: procedure; stdcall;
    // receives a specified game is active, so no other game types can be displayed in server list
    OnActiveGameName: procedure(Name: PAnsiChar); stdcall;
    // notification that we connected / disconnected
    OnConnectToGame: procedure(KV: PKeyValues); stdcall;
    OnDisconnectFromGame: procedure; stdcall;
  end;

  CServerBrowserDialog = ^PVTableCServerBrowserDialog;
{$ENDREGION}

{$REGION 'CServerBrowser'}
  DCServerBrowser = object

  end;
{$ENDREGION}

implementation

end.

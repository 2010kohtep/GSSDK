(*========= (C) Copyright 2019-2020, Alexander B. All rights reserved. =========*)
(*                                                                              *)
(*  Module:                                                                     *)
(*    GoldSrc.VGUI                                                              *)
(*                                                                              *)
(*  License:                                                                    *)
(*    You may freely use this code provided you retain this copyright message.  *)
(*                                                                              *)
(*  Description:                                                                *)
(*    Provides partial SDK for Counter-Strike 1.6 VGUI library. Mostly          *)
(*    binary-correct virtual tables are presented for working with VGUI         *)
(*    objects.                                                                  *)
(*==============================================================================*)

{$DEFINE VGUI_USE_PANEL007}
{.$DEFINE VGUI_USE_PANEL009}

unit GoldSrc.VGUI;

interface

uses
  System.SysUtils,

  GoldSrc.BaseInterface,
  GoldSrc.Collections,
  GoldSrc.KeyValues,

  Xander.ThisWrap;

{.$A+} // were 1
{$Z4}

type
  EInterfaceID = (ICLIENTPANEL_STANDARD_INTERFACE = 0);

type
  DmxElementUnpackStructure_t = Pointer;
  TDmxElementUnpackStructure = DmxElementUnpackStructure_t;
  PDmxElementUnpackStructure = ^TDmxElementUnpackStructure;

  CDmxElement = Pointer;
  PCDmxElement = ^CDmxElement;

  VGUIPanel = Pointer; // Prototype since we can't define type named 'Panel' directry
  VGUILabel = Pointer;
  TextImage = Pointer;
  VPANEL = Cardinal;
  HCursor = Cardinal;
  FocusNavGroup = Pointer;
  PanelMap_t = Pointer;
  SurfacePlat = Pointer;
  PHandle = ^Integer;

  HContext = Cardinal;
  HScheme = Cardinal;
  HTexture = Cardinal;
  HPanel = Cardinal;
  HFont = Cardinal;

  HInputContext = Integer;

type
  VGUIMouseCode = (MOUSE_LEFT = 0, MOUSE_RIGHT, MOUSE_MIDDLE, MOUSE_4, MOUSE_5, MOUSE_LAST);

type
  ButtonCode_t = (KEYT_NONE = 0, KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7,
                 KEY_8, KEY_9, KEY_A, KEY_B, KEY_C, KEY_D, KEY_E, KEY_F, KEY_G,
                 KEY_H, KEY_I, KEY_J, KEY_K, KEY_L, KEY_M, KEY_N, KEY_O, KEY_P,
                 KEY_Q, KEY_R, KEY_S, KEY_T, KEY_U, KEY_V, KEY_W, KEY_X, KEY_Y,
                 KEY_Z, KEY_PAD_0, KEY_PAD_1, KEY_PAD_2, KEY_PAD_3, KEY_PAD_4,
                 KEY_PAD_5, KEY_PAD_6, KEY_PAD_7, KEY_PAD_8, KEY_PAD_9, KEY_PAD_DIVIDE,
                 KEY_PAD_MULTIPLY, KEY_PAD_MINUS, KEY_PAD_PLUS, KEY_PAD_ENTER,
                 KEY_PAD_DECIMAL, KEY_LBRACKET, KEY_RBRACKET, KEY_SEMICOLON, KEY_APOSTROPHE,
                 KEY_BACKQUOTE, KEY_COMMA, KEY_PERIOD, KEY_SLASH, KEY_BACKSLASH, KEY_MINUS,
                 KEY_EQUAL, KEY_ENTER, KEY_SPACE, KEY_BACKSPACE, KEY_TAB, KEY_CAPSLOCK,
                 KEY_NUMLOCK, KEY_ESCAPE, KEY_SCROLLLOCK, KEY_INSERT, KEY_DELETE, KEY_HOME,
                 KEY_END, KEY_PAGEUP, KEY_PAGEDOWN, KEY_BREAK, KEY_LSHIFT, KEY_RSHIFT,
                 KEY_LALT, KEY_RALT, KEY_LCONTROL, KEY_RCONTROL, KEY_LWIN, KEY_RWIN, KEY_APP,
                 KEY_UP, KEY_LEFT, KEY_DOWN, KEY_RIGHT, KEY_F1, KEY_F2, KEY_F3, KEY_F4,
                 KEY_F5, KEY_F6, KEY_F7, KEY_F8, KEY_F9, KEY_F10, KEY_F11, KEY_F12, KEY_LAST);

  KeyCode = ButtonCode_t;
  MouseCode = ButtonCode_t;

type
  SDK_Color = record
    R, G, B, A: Byte;

    class function Create(R, G, B, A: Byte): SDK_Color; static;
  end;

type
  Dar<T> = record
    Count: Integer;
    Capacity: Integer;
    Data: ^T;
  end;

const
  INVALID_PANEL = HPANEL(-1);
  INVALID_FONT = HFont(0);

type
// BuildGroup.h
  DBuildGroup = record
    _enabled: Boolean;
    _snapX, _snapY: Integer;
    _cursor_sizenwse: HCursor;
    _cursor_sizenesw: HCursor;
    _cursor_sizewe: HCursor;
    _cursor_sizens: HCursor;
    _cursor_sizeall: HCursor;
    _dragging: Boolean;
    _dragMouseCode: VGUIMouseCode;
    _dragStartPanelPos: array[0..1] of Integer;
    _dragStartCursorPos: array[0..1] of Integer;
    _currentPanel: Pointer;
    _panelDar: CUtlVector<PHandle, Integer>;
    m_pResourceName: PAnsiChar;
    m_pResourcePathID: PAnsiChar;
    m_hBuildDialog: PHandle;
    m_pBuildContext: Pointer;
    m_pParentPanel: Pointer;
    _controlGroup: CUtlVector<PHandle, Integer>;
    _groupDeltaX: CUtlVector<Integer, Integer>;
    _groupDeltaY: CUtlVector<Integer, Integer>;
    _rulerNumber: array[0..3] of VGUILabel;
    _showRulers: Boolean;
    m_RegisteredControlSettingsFiles: CUtlVector<CUtlSymbol, Integer>;
  end;

  PVBuildGroup = ^VBuildGroup;
  VBuildGroup = record
    // Toggle build mode on/off
    SetEnabled: procedure(State: Boolean); stdcall;
    // Check if buildgroup is enabled
    IsEnabled: function: Boolean; stdcall;
    // Return the currently selected panel
    GetCurrentPanel: function: VGUIPanel; stdcall;
    // Load the control settings from file
    LoadControlSettings: procedure(ControlResourceName: PAnsiChar; PathID: PAnsiChar = nil); stdcall;
    // Save control settings from file, using the same resource
    // name as what LoadControlSettings() was called with
    SaveControlSettings: function: Boolean; stdcall;
    // Serialize settings from a resource data container
    ApplySettings: procedure(ResourceData: PKeyValues); stdcall;
    // Serialize settings to a resource data container
    GetSettings: procedure(ResourceData: PKeyValues); stdcall;
    // Remove all objects in the current control group
    RemoveSettings: procedure; stdcall;
    // Set the panel from which the build group gets all it's object creation information
    SetContextPanel: procedure(ÑontextPanel: VGUIPanel); stdcall;
    //Get the panel that build group is pointed at.
    GetContextPanel: function: VGUIPanel; stdcall;
    // Get the resource file name used
    GetResourceName: function: PAnsiChar; stdcall;

    PanelAdded: procedure(Panel: VGUIPanel); stdcall;

    MousePressed: function(Code: VGUIMouseCode; Panel: VGUIPanel): Boolean; stdcall;
    MouseReleased: function(Code: VGUIMouseCode; Panel: VGUIPanel): Boolean; stdcall;

    // Get the list of panels that are currently selected
    GetControlGroup: function: Pointer; (*^CUtlVector<PHandle, Integer>;*) stdcall;

    // Toggle ruler display on/off
    ToggleRulerDisplay: procedure; stdcall;

    // Toggle visibility of ruler number labels
    SetRulerLabelsVisible: procedure(State: Boolean); stdcall;

    // Check if ruler display is activated
    HasRulersOn: function: Boolean; stdcall;

    // Draw Rulers on screen
    DrawRulers: function: Boolean; stdcall;

    CursorMoved: procedure(X, Y: Integer; Panel: VGUIPanel); stdcall;

    MouseDoublePressed: procedure(Code: VGUIMouseCode; Panel: VGUIPanel); stdcall;

    KeyCodeTyped: function(Code: VGUIMouseCode; Panel: VGUIMouseCode): Boolean; stdcall;

    ApplySchemeSettings: procedure(Scheme: Pointer); stdcall;

    GetCursor: function(Panel: VGUIPanel): HCursor; stdcall;
  end;

  PBuildGroup = ^BuildGroup;
  BuildGroup = record
    VTable: ^VBuildGroup;
    Data: DBuildGroup;
  end;

// MessageMap.h

//-----------------------------------------------------------------------------
// Purpose: parameter data type enumeration
//			used internal but the shortcut macros require this to be exposed
//-----------------------------------------------------------------------------
type
  DataType_t = (DATATYPE_VOID, DATATYPE_CONSTCHARPTR, DATATYPE_INT, DATATYPE_FLOAT,
    DATATYPE_PTR, DATATYPE_BOOL, DATATYPE_KEYVALUES, DATATYPE_CONSTWCHARPTR,
    DATATYPE_UINT64);

type
  MessageFunc_t = procedure; stdcall;

  MessageMapItem_t = record
    Name: PAnsiChar;
  {$ALIGN 16}
    Func: Pointer;
  {$ALIGN 1}

    NumParams: Integer;

    FirstParamType: DataType_t;
    FirstParamName: PAnsiChar;

    SecondParamType: DataType_t;
    SecondParamName: PAnsiChar;

    NameSymbol: Integer;
    FirstParamSymbol: Integer;
    SecondParamSymbol: Integer;
  end;
  TMessageMapItem = MessageMapItem_t;

  PPanelMessageMap = ^PanelMessageMap;
  PanelMessageMap = record
    Entries: CUtlMemory<MessageMapItem_t, Integer>;
    Processed: Boolean;
    BaseMap: PPanelMessageMap;
    ClassName: function: PAnsiChar; cdecl;
  end;

type
{$REGION 'SchemeManager'}
  PVScheme = ^VScheme;
  VScheme = record
   Destroy: procedure(Free: Boolean); stdcall;

   GetResourceString: function(StringName: PAnsiChar): PChar; stdcall;
   GetBorder: function(BorderName: PAnsiChar): Pointer; stdcall; // TODO: IBorder
   GetFont: function(FontName: PAnsiChar; Proportional: Boolean = False): HFont; stdcall;
   GetColor: function(ColorName: PAnsiChar; DefaultColor: Pointer): Pointer; stdcall; // TODO: Color
  end;

  PIScheme = ^IScheme;
  IScheme = ^PVScheme;

  PVSchemeManager = ^VSchemeManager;
  VSchemeManager = record
    Create: procedure(Dispose: Boolean); stdcall;

  	 // loads a scheme from a file
 	 // first scheme loaded becomes the default scheme, and all subsequent loaded scheme are derivitives of that
    LoadSchemeFromFile: function(FileName, Tag: PAnsiChar): HScheme; stdcall;

    // reloads the scheme from the file - should only be used during development
    ReloadSchemes: procedure; stdcall;

    // returns a handle to the default (first loaded) scheme
    GetDefaultScheme: function: HScheme; stdcall;

    // returns a handle to the scheme identified by "tag"
    GetScheme: function: HScheme; stdcall;

    GetImage: function(ImageName: PAnsiChar; HardwareFiltered: Boolean): Pointer; stdcall;
 	 GetImageID: function(ImageName: PAnsiChar; HardwareFiltered: Boolean): HTexture; stdcall;

 	// This can only be called at certain times, like during paint()
 	// It will assert-fail if you call it at the wrong time...

 	// FIXME: This interface should go away!!! It's an icky back-door
 	// If you're using this interface, try instead to cache off the information
 	// in ApplySchemeSettings
 	GetIScheme: function(Scheme: HScheme): PIScheme; stdcall;

 	// unload all schemes
 	Shutdown: procedure(Full: Boolean = True); stdcall;

 	// gets the proportional coordinates for doing screen-size independant panel layouts
 	// use these for font, image and panel size scaling (they all use the pixel height of the display for scaling)
 	GetProportionalScaledValue: function(NormalizedValue: Integer): Integer; stdcall;
 	GetProportionalNormalizedValue: function(ScaledValue: Integer): Integer; stdcall;
  end;

  ISchemeManager = ^PVSchemeManager;

const
  VGUI_SCHEME_INTERFACE_VERSION = 'VGUI_Scheme009';
{$ENDREGION}

{$REGION 'Border'}
type
  PVTableBorder = ^VTableBorder;
  VTableBorder = record
  public type
    sides_e =
    (
      SIDE_LEFT = 0,
      SIDE_TOP = 1,
      SIDE_RIGHT = 2,
      SIDE_BOTTOM = 3
    );
  public
    Paint: procedure(Panel: VPANEL); stdcall;
    Paint2: procedure(X0, Y0, X1, Y1: Integer); stdcall;
    Paint3: procedure(X0, Y0, X1, Y1: Integer; BreakSide, BreakStart, BreakStop: Integer); stdcall;
    SetInset: procedure(Left, Top, Right, Bottom: Integer); stdcall;
    GetInset: procedure(out Left, Top, Right, Bottom: Integer); stdcall;
    ApplySchemeSettings: procedure(Scheme: IScheme; InResourceData: KeyValues); stdcall;
    GetName: function: PAnsiChar; stdcall;
    SetName: procedure(Name: PAnsiChar); stdcall;
  end;

  //-----------------------------------------------------------------------------
  // Purpose: Interface to panel borders
  //			Borders have a close relationship with panels
  //			They are the edges of the panel.
  //-----------------------------------------------------------------------------
  IBorder = ^PVTableBorder;
{$ENDREGION}

{$REGION 'IImage'}
  //-----------------------------------------------------------------------------
  // Purpose: Interface to drawing an image
  //-----------------------------------------------------------------------------
  PVTableIImage = ^VTableIImage;
  VTableIImage = object
  public
    // Call to Paint the image
    // Image will draw within the current panel context at the specified position
    Paint: procedure; stdcall;

    // Set the position of the image
    SetPos: procedure(X, Y: Integer); stdcall;

    // Gets the size of the content
    GetContentSize: procedure(out Wide, Tall: Integer); stdcall;

    // Get the size the image will actually draw in (usually defaults to the content size)
    GetSize: procedure(out Wide, Tall: Integer); stdcall;

    // Sets the size of the image
    SetSize: procedure(Wide, Tall: Integer); stdcall;

    // Set the draw color
    SetColor: procedure(Col: SDK_Color); stdcall;

    // virtual destructor
    Destroy: procedure(Free: Boolean); stdcall;
  end;

  IImage = ^PVTableIImage;
{$ENDREGION}

{$REGION 'Image'}
  PVTableImage = ^VTableImage;
  VTableImage = object(VTableIImage)
  public
    // Get the position of the image
    GetPos: procedure(out x, y: Integer); stdcall;

    // set the background color
    SetBkColor: procedure(Color: SDK_Color); stdcall;

    // Get the draw color
    GetColor: function: SDK_Color; stdcall;

  {$IFDEF MSWINDOWS}
    DrawSetColor2: procedure(r, g, b, a: Integer); stdcall;
    DrawSetColor: procedure(color: SDK_Color); stdcall;
  {$ELSE}
    DrawSetColor: procedure(color: SDK_Color); stdcall;
    DrawSetColor2: procedure(r, g, b, a: Integer); stdcall;
  {$ENDIF}

    DrawFilledRect: procedure(x0, y0, x1, y1: Integer); stdcall;

    DrawOutlinedRect: procedure(x0, y0, x1, y1: Integer); stdcall;

    DrawLine: procedure(x0, y0, x1, y1: Integer); stdcall;

    DrawPolyLine: procedure(px, py: PInteger; numPoints: Integer); stdcall;

    DrawSetTextFont: procedure(font: HFont); stdcall;

  {$IFDEF MSWINDOWS}
  	DrawSetTextColor2: procedure(r, g, b, a: Integer); stdcall;
    DrawSetTextColor: procedure(color: SDK_Color); stdcall;
  {$ELSE}
    DrawSetTextColor: procedure(color: SDK_Color); stdcall;
  	DrawSetTextColor2: procedure(r, g, b, a: Integer); stdcall;
  {$ENDIF}

    DrawSetTextPos: procedure(x, y: Integer); stdcall;

  {$IFDEF MSWINDOWS}
    DrawPrintText2: procedure(x, y: Integer; str: PWideChar; strlen: Integer); stdcall;
    DrawPrintText: procedure(str: PWideChar; strlen: Integer); stdcall;
  {$ELSE}
    DrawPrintText: procedure(str: PWideChar; strlen: Integer); stdcall;
    DrawPrintText2: procedure(x, y: Integer; str: PWideChar; strlen: Integer); stdcall;
  {$ENDIF}

  {$IFDEF MSWINDOWS}
  	DrawPrintChar2: procedure(x, y: Integer; ch: WideChar); stdcall;
	  DrawPrintChar: procedure(ch: WideChar); stdcall;
  {$ELSE}
  	DrawPrintChar2: procedure(x, y: Integer; ch: WideChar); stdcall;
	  DrawPrintChar: procedure(ch: WideChar); stdcall;
  {$ENDIF}

    DrawSetTexture: procedure(id: Integer); stdcall;
    DrawTexturedRect: procedure(x0, y0, x1, y1: Integer); stdcall;
  end;

  Image = ^PVTableImage;
{$ENDREGION}

{$REGION 'IInput'}
  PVTableInput = ^VTableInput;
  VTableInput = object(VIBaseInterface)
  public
    SetMouseFocus: procedure(newMouseFocus: VPANEL); stdcall;
    SetMouseCapture: procedure(panel: VPANEL); stdcall;

    // returns the string name of a scan code
    GetKeyCodeText: procedure(code: KeyCode; buf: PAnsiChar; buflen: Integer); stdcall;

    // focus
    GetFocus: function: VPANEL; stdcall;
    GetMouseOver: function: VPANEL; stdcall;		// returns the panel the mouse is currently over, ignoring mouse capture

    // mouse state
    SetCursorPos: procedure(x, y: Integer); stdcall;
    GetCursorPos: procedure(out x, y: Integer); stdcall;
    WasMousePressed: function(code: MouseCode): Boolean; stdcall;
    WasMouseDoublePressed: function(code: MouseCode): Boolean; stdcall;
    IsMouseDown: function(code: MouseCode): Boolean; stdcall;

    // cursor override
    SetCursorOveride: procedure(cursor: HCursor); stdcall;
    GetCursorOveride: function: HCursor; stdcall;

    // key state
    WasMouseReleased: function(code: MouseCode): Integer; stdcall;
    WasKeyPressed: function(code: MouseCode): Integer; stdcall;
    IsKeyDown: function(code: MouseCode): Integer; stdcall;
    WasKeyTyped: function(code: MouseCode): Integer; stdcall;
    WasKeyReleased: function(code: MouseCode): Integer; stdcall;

    GetAppModalSurface: function: VPANEL; stdcall;
    // set the modal dialog panel.
    // all events will go only to this panel and its children.
    SetAppModalSurface: procedure(panel: VPANEL); stdcall;
    // release the modal dialog panel
    // do this when your modal dialog finishes.
    ReleaseAppModalSurface: procedure; stdcall;

    GetCursorPosition: procedure(out x, y: Integer); stdcall;

    RunFrame: procedure; stdcall;

    PanelDeleted: procedure(panel: VPANEL); stdcall;

    UpdateMouseFocus: procedure(x, y: Integer); stdcall;

    InternalCursorMoved: function(x, y: Integer): Boolean; stdcall; //expects input in surface space
    InternalMousePressed: function(code: MouseCode): Boolean; stdcall;
    InternalMouseDoublePressed: function(code: MouseCode): Boolean; stdcall;
    InternalMouseReleased: function(code: MouseCode): Boolean; stdcall;
    InternalMouseWheeled: function(delta: Integer): Boolean; stdcall;
    InternalKeyCodePressed: function(code: KeyCode): Boolean; stdcall;
    InternalKeyCodeTyped: procedure(code: KeyCode); stdcall;
    InternalKeyTyped: procedure(unichar: WideChar); stdcall;

    // Creates/ destroys "input" contexts, which contains information
    // about which controls have mouse + key focus, for example.
    CreateInputContext: function: HInputContext; stdcall;
    DestroyInputContext: procedure(context: HInputContext); stdcall;

    // Associates a particular panel with an input context
    // Associating NULL is valid; it disconnects the panel from the context
    AssociatePanelWithInputContext: procedure(context: HInputContext; pRoot: VPANEL); stdcall;

    // Activates a particular input context, use DEFAULT_INPUT_CONTEXT
    // to get the one normally used by VGUI
    ActivateInputContext: procedure(context: HInputContext); stdcall;

    // returns true if the specified panel is a child of the current modal panel
    // if no modal panel is set, then this always returns TRUE
    IsChildOfModalPanel: function(panel: VPANEL; checkModalSubTree: Boolean = True): Boolean; stdcall;

    ResetInputContext: procedure(context: HInputContext); stdcall;
  end;

  IInput = ^PVTableInput;
{$ENDREGION}

{$REGION 'PanelWrapper'}
  //-----------------------------------------------------------------------------
  // Purpose: interface from Client panels -> vgui panels
  //-----------------------------------------------------------------------------
  PVIPanel009 = ^VIPanel009;
  VIPanel009 = object(VIBaseInterface)
  public
    Init: procedure(vguiPanel: VPANEL; Panel: Pointer (*IClientPanel*)); stdcall;

    // methods
    SetPos: procedure(vguiPanel: VPANEL; X, Y: Integer); stdcall;
    GetPos: procedure(vguiPanel: VPANEL; out X, Y: Integer); stdcall; // TODO: crashes app, find the reason
    SetSize: procedure(vguiPanel: VPANEL; Wide, Tall: Integer); stdcall;
    GetSize: procedure(vguiPanel: VPANEL; out Wide, Tall: Integer); stdcall;
    SetMinimumSize: procedure(vguiPanel: VPANEL; Wide, Tall: Integer); stdcall;
    GetMinimumSize: procedure(vguiPanel: VPANEL; out Wide, Tall: Integer); stdcall;
    SetZPos: procedure(vguiPanel: VPANEL; Z: Integer); stdcall;
    GetZPos: function(vguiPanel: VPANEL): Integer; stdcall;

    GetAbsPos: procedure(vguiPanel: VPANEL; X, Y: Integer); stdcall;
    GetClipRect: procedure(vguiPanel: VPANEL; out X0, Y0, X1, Y1: Integer); stdcall;
    SetInset: procedure(vguiPanel: VPANEL; Left, Top, Right, Bottom: Integer); stdcall;
    GetInset: procedure(vguiPanel: VPANEL; out Left, Top, Right, Bottom: Integer); stdcall;

    SetVisible: procedure(vguiPanel: VPANEL; State: Boolean); stdcall;
    IsVisible: function(vguiPanel: VPANEL): Boolean; stdcall;
    SetParent: procedure(vguiPanel, newParent: VPANEL); stdcall;
    GetChildCount: function(vguiPanel: VPANEL): Integer; stdcall;
    GetChild: function(vguiPanel: VPANEL; Index: Integer): VPANEL; stdcall;
    GetChildren: function(vguiPanel: VPANEL): CUtlVector<VPANEL, Integer>; stdcall;
    GetParent: function(vguiPanel: VPANEL): VPANEL; stdcall;
    MoveToFront: procedure(vguiPanel: VPANEL); stdcall;
    MoveToBack: procedure(vguiPanel: VPANEL); stdcall;
    HasParent: function(vguiPanel, PotentialParent: VPANEL): Boolean; stdcall;
    IsPopup: function(vguiPanel: VPANEL): Boolean; stdcall;
    SetPopup: procedure(vguiPanel: VPANEL; State: Boolean); stdcall;
    IsFullyVisible: function(vguiPanel: VPANEL): Boolean; stdcall;

    // gets the scheme this panel uses
    GetScheme: function(vguiPanel: VPANEL): HScheme; stdcall;
    // gets whether or not this panel should scale with screen resolution
    IsProportional: function(vguiPanel: VPANEL): Boolean; stdcall;
    // returns true if auto-deletion flag is set
    IsAutoDeleteSet: function(vguiPanel: VPANEL): Boolean; stdcall;
    // deletes the Panel * associated with the vpanel
    DeletePanel: procedure(vguiPanel: VPANEL); stdcall;

    // input interest
    SetKeyBoardInputEnabled: procedure(vguiPanel: VPANEL; State: Boolean); stdcall;
    SetMouseInputEnabled: procedure(vguiPanel: VPANEL; State: Boolean); stdcall;
    IsKeyBoardInputEnabled: function(vguiPanel: VPANEL): Boolean; stdcall;
    IsMouseInputEnabled: function(vguiPanel: VPANEL): Boolean; stdcall;

    // calculates the panels current position within the hierarchy
    Solve: procedure(vguiPanel: VPANEL); stdcall;

    // gets names of the object (for debugging purposes)
    GetName: function(vguiPanel: VPANEL): PAnsiChar; stdcall;
    GetClassName: function(vguiPanel: VPANEL): PAnsiChar; stdcall;

    // delivers a message to the panel
    SendMessage: procedure(vguiPanel: VPANEL; Params: PKeyValues; FromPanel: VPANEL); stdcall;

    // these pass through to the IClientPanel
    Think: procedure(vguiPanel: VPANEL); stdcall;
    PerformApplySchemeSettings: procedure(vguiPanel: VPANEL); stdcall;
    PaintTraverse: procedure(vguiPanel: VPANEL; ForceRepaint: Boolean; AllowForce: Boolean = True); stdcall;
    Repaint: procedure(vguiPanel: VPANEL); stdcall;
    IsWithinTraverse: function(vguiPanel: VPANEL; X, Y: Integer; TraversePopups: Boolean): VPANEL; stdcall;
    OnChildAdded: procedure(vguiPanel, Child: VPANEL); stdcall;
    OnSizeChanged: procedure(vguiPanel: VPANEL; NewWide, NewTall: Integer); stdcall;

    InternalFocusChanged: procedure(vguiPanel: VPANEL; Lost: Boolean); stdcall;
    RequestInfo: function(vguiPanel: VPANEL; OutputData: PKeyValues): Boolean; stdcall;
    RequestFocus: procedure(vguiPanel: VPANEL; Direction: Integer = 0); stdcall;
    RequestFocusPrev: function(vguiPanel, ExistingPanel: VPANEL): Boolean; stdcall;
    RequestFocusNext: function(vguiPanel, ExistingPanel: VPANEL): Boolean; stdcall;
    GetCurrentKeyFocus: function(vguiPanel: VPANEL): VPANEL; stdcall;
    GetTabPosition: function(vguiPanel: VPANEL): Integer; stdcall;

    // used by ISurface to store platform-specific data
    Plat: function(vguiPanel: VPANEL): SurfacePlat; stdcall;
    SetPlat: procedure(vguiPanel: VPANEL; Plat: SurfacePlat); stdcall;

    // returns a pointer to the vgui controls baseclass Panel *
    // destinationModule needs to be passed in to verify that the returned Panel * is from the same module
    // it must be from the same module since Panel * vtbl may be different in each module
    GetPanel: function(vguiPanel: VPANEL; ParentName: PAnsiChar): VGUIPanel; stdcall;

    IsEnabled: function(vguiPanel: VPANEL): Boolean; stdcall;
    SetEnabled: procedure(vguiPanel: VPANEL; State: Boolean); stdcall;

    // Used by the drag/drop manager to always draw on top
    IsTopmostPopup: function(vguiPanel: VPANEL): Boolean; stdcall;
    SetTopmostPopup: procedure(vguiPanel: VPANEL; State: Boolean); stdcall;

    SetMessageContextId: procedure(vguiPanel: VPANEL;nContextId: Integer); stdcall;
    GetMessageContextId: function(vguiPanel: VPANEL): Integer; stdcall;

    GetUnpackStructure: function(vguiPanel: VPANEL): PDmxElementUnpackStructure; stdcall;
    OnUnserialized: procedure(vguiPanel: VPANEL; Element: PCDmxElement); stdcall;

  // sibling pins
    SetSiblingPin: procedure(vguiPanel: VPANEL; newSibling: VPANEL; MyCornerToPin: Byte = 0; SiblingCornerToPinTo: Byte = 0 ); stdcall;
  end;

  IPanel009 = ^PVIPanel009;

  PVIPanel007 = ^VIPanel007;
  VIPanel007 = object(VIBaseInterface)
  public
    Init: procedure(vguiPanel: VPANEL; Panel: Pointer (*IClientPanel*)); stdcall;

    // methods
    SetPos: procedure(vguiPanel: VPANEL; X, Y: Integer); stdcall;
    GetPos: procedure(vguiPanel: VPANEL; out X, Y: Integer); stdcall; // TODO: crashes app, find the reason
    SetSize: procedure(vguiPanel: VPANEL; Wide, Tall: Integer); stdcall;
    GetSize: procedure(vguiPanel: VPANEL; out Wide, Tall: Integer); stdcall;
    SetMinimumSize: procedure(vguiPanel: VPANEL; Wide, Tall: Integer); stdcall;
    GetMinimumSize: procedure(vguiPanel: VPANEL; out Wide, Tall: Integer); stdcall;
    SetZPos: procedure(vguiPanel: VPANEL; Z: Integer); stdcall;
    GetZPos: function(vguiPanel: VPANEL): Integer; stdcall;

    GetAbsPos: procedure(vguiPanel: VPANEL; X, Y: Integer); stdcall;
    GetClipRect: procedure(vguiPanel: VPANEL; out X0, Y0, X1, Y1: Integer); stdcall;
    SetInset: procedure(vguiPanel: VPANEL; Left, Top, Right, Bottom: Integer); stdcall;
    GetInset: procedure(vguiPanel: VPANEL; out Left, Top, Right, Bottom: Integer); stdcall;

    SetVisible: procedure(vguiPanel: VPANEL; State: Boolean); stdcall;
    IsVisible: function(vguiPanel: VPANEL): Boolean; stdcall;
    SetParent: procedure(vguiPanel, newParent: VPANEL); stdcall;
    GetChildCount: function(vguiPanel: VPANEL): Integer; stdcall;
    GetChild: function(vguiPanel: VPANEL; Index: Integer): VPANEL; stdcall;
    GetParent: function(vguiPanel: VPANEL): VPANEL; stdcall;
    MoveToFront: procedure(vguiPanel: VPANEL); stdcall;
    MoveToBack: procedure(vguiPanel: VPANEL); stdcall;
    HasParent: function(vguiPanel, PotentialParent: VPANEL): Boolean; stdcall;
    IsPopup: function(vguiPanel: VPANEL): Boolean; stdcall;
    SetPopup: procedure(vguiPanel: VPANEL; State: Boolean); stdcall;

    Render_GetPopupVisible: function(vguiPanel: VPANEL): Boolean; stdcall;
    Render_SetPopupVisible: procedure(vguiPanel: VPANEL; State: Boolean); stdcall;

    // gets the scheme this panel uses
    GetScheme: function(vguiPanel: VPANEL): HScheme; stdcall;
    // gets whether or not this panel should scale with screen resolution
    IsProportional: function(vguiPanel: VPANEL): Boolean; stdcall;
    // returns true if auto-deletion flag is set
    IsAutoDeleteSet: function(vguiPanel: VPANEL): Boolean; stdcall;
    // deletes the Panel * associated with the vpanel
    DeletePanel: procedure(vguiPanel: VPANEL); stdcall;

    // input interest
    SetKeyBoardInputEnabled: procedure(vguiPanel: VPANEL; State: Boolean); stdcall;
    SetMouseInputEnabled: procedure(vguiPanel: VPANEL; State: Boolean); stdcall;
    IsKeyBoardInputEnabled: function(vguiPanel: VPANEL): Boolean; stdcall;
    IsMouseInputEnabled: function(vguiPanel: VPANEL): Boolean; stdcall;

    // calculates the panels current position within the hierarchy
    Solve: procedure(vguiPanel: VPANEL); stdcall;

    // gets names of the object (for debugging purposes)
    GetName: function(vguiPanel: VPANEL): PAnsiChar; stdcall;
    GetClassName: function(vguiPanel: VPANEL): PAnsiChar; stdcall;

    // delivers a message to the panel
    SendMessage: procedure(vguiPanel: VPANEL; Params: PKeyValues; FromPanel: VPANEL); stdcall;

    // these pass through to the IClientPanel
    Think: procedure(vguiPanel: VPANEL); stdcall;
    PerformApplySchemeSettings: procedure(vguiPanel: VPANEL); stdcall;
    PaintTraverse: procedure(vguiPanel: VPANEL; ForceRepaint: Boolean; AllowForce: Boolean = True); stdcall;
    Repaint: procedure(vguiPanel: VPANEL); stdcall;
    IsWithinTraverse: function(vguiPanel: VPANEL; X, Y: Integer; TraversePopups: Boolean): VPANEL; stdcall;
    OnChildAdded: procedure(vguiPanel, Child: VPANEL); stdcall;
    OnSizeChanged: procedure(vguiPanel: VPANEL; NewWide, NewTall: Integer); stdcall;

    InternalFocusChanged: procedure(vguiPanel: VPANEL; Lost: Boolean); stdcall;
    RequestInfo: function(vguiPanel: VPANEL; OutputData: PKeyValues): Boolean; stdcall;
    RequestFocus: procedure(vguiPanel: VPANEL; Direction: Integer = 0); stdcall;
    RequestFocusPrev: function(vguiPanel, ExistingPanel: VPANEL): Boolean; stdcall;
    RequestFocusNext: function(vguiPanel, ExistingPanel: VPANEL): Boolean; stdcall;
    GetCurrentKeyFocus: function(vguiPanel: VPANEL): VPANEL; stdcall;
    GetTabPosition: function(vguiPanel: VPANEL): Integer; stdcall;

    // used by ISurface to store platform-specific data
    Plat: function(vguiPanel: VPANEL): SurfacePlat; stdcall;
    SetPlat: procedure(vguiPanel: VPANEL; Plat: SurfacePlat); stdcall;

    // returns a pointer to the vgui controls baseclass Panel *
    // destinationModule needs to be passed in to verify that the returned Panel * is from the same module
    // it must be from the same module since Panel * vtbl may be different in each module
    GetPanel: function(vguiPanel: VPANEL; ParentName: PAnsiChar): VGUIPanel; stdcall;

    IsEnabled: function(vguiPanel: VPANEL): Boolean; stdcall;
    SetEnabled: procedure(vguiPanel: VPANEL; State: Boolean); stdcall;

    Client: function(vguiPanel: VPANEL): Pointer (*IClientPanel*); stdcall;
    GetModuleName: function(vguiPanel: VPANEL): PAnsiChar; stdcall;
  end;

  IPanel007 = ^PVIPanel007;

{$IFDEF VGUI_USE_PANEL007}
type
  PVIPanel = PVIPanel007;
  VIPanel = VIPanel007;
  IPanel = IPanel007;

const
  VGUI_PANEL_INTERFACE_LIBRARY = 'vgui2.dll';
  VGUI_PANEL_INTERFACE_VERSION = 'VGUI_Panel007';
{$ELSE}
type
  PVIPanel = PVIPanel009;
  VIPanel = VIPanel009;
  IPanel = IPanel009;

const
  VGUI_PANEL_INTERFACE_LIBRARY = 'tier3.dll';
  VGUI_PANEL_INTERFACE_VERSION = 'VGUI_Panel009';
{$ENDIF}

{$ENDREGION}

{$REGION 'IClientPanel'}
type
  PVIClientPanel = ^VIClientPanel;
  VIClientPanel = object
  public
    GetVPanel: function: VPANEL; stdcall;

    // straight interface to Panel functions
    Think: procedure; stdcall;
    PerformApplySchemeSettings: procedure; stdcall;
    PaintTraverse: procedure(ForceRepaint: Boolean; AllowForce: Boolean); stdcall;
    Repaint: procedure; stdcall;
    IsWithinTraverse: function(X, Y: Integer; TraversePopups: Boolean): VPANEL; stdcall;
    GetInset: procedure(out Top, Left, Right, Bottom: Integer); stdcall;
    GetClipRect: procedure(out X0, Y0, X1, Y1: Integer); stdcall;
    OnChildAdded: procedure(Child: VPANEL); stdcall;
    OnSizeChanged: procedure(NewWide, NewTall: Integer); stdcall;

    InternalFocusChanged: procedure(Lost: Boolean); stdcall;
    RequestInfo: function(OutputData: PKeyValues): Boolean; stdcall;
    RequestFocus: procedure(Direction: Integer); stdcall;
    RequestFocusPrev: function(ExistingPanel: VPANEL): Boolean; stdcall;
    RequestFocusNext: function(ExistingPanel: VPANEL): Boolean; stdcall;
    OnMessage: procedure(Params: PKeyValues; FromPanel: VPANEL); stdcall;
    GetCurrentKeyFocus: function: VPANEL; stdcall;
    GetTabPosition: function: Integer; stdcall;

    // for debugging purposes
    GetName: function: PAnsiChar; stdcall;
    GetClassName: function: PAnsiChar; stdcall;

    // get scheme handles from panels
    GetScheme: function: HScheme; stdcall;
    // gets whether or not this panel should scale with screen resolution
    IsProportional: function: Boolean; stdcall;
    // auto-deletion
    IsAutoDeleteSet: function: Boolean; stdcall;
    // deletes this
    DeletePanel: procedure; stdcall;

    // interfaces
    QueryInterface: function(ID: EInterfaceID): Pointer; stdcall;

    // returns a pointer to the vgui controls baseclass Panel *
    GetPanel: function: VGUIPanel; stdcall;

    // returns the name of the module this panel is part of
    GetModuleName: function: PAnsiChar; stdcall;
  end;

  IClientPanel = ^PVIClientPanel;
{$ENDREGION}

{$REGION 'Panel'}
  // pin positions for auto-layout
  PinCorner_e = (PIN_TOPLEFT = 0, PIN_TOPRIGHT, PIN_BOTTOMLEFT, PIN_BOTTOMRIGHT);
  // specifies the auto-resize directions for the panel
  AutoResize_e = (AUTORESIZE_NO = 0, AUTORESIZE_RIGHT, AUTORESIZE_DOWN, AUTORESIZE_DOWNANDRIGHT);

  //-----------------------------------------------------------------------------
  // Purpose: Base interface to all vgui windows
  //			All vgui controls that receive message and/or have a physical presence
  //			on screen are be derived from Panel.
  //			This is designed as an easy-access to the vgui-functionality; for more
  //			low-level access to vgui functions use the IPanel/IClientPanel interfaces directly
  //-----------------------------------------------------------------------------
  PVTablePanel = ^VTablePanel;
  VTablePanel = object(VIClientPanel)
  public
    GetMessageMap: function: Pointer; stdcall;

    Destroy: procedure(Free: Boolean); stdcall;

    // panel visibility
    // invisible panels and their children do not drawn, updated, or receive input messages
	  SetVisible: procedure(State: Boolean); stdcall;
	  IsVisible: function: Boolean; stdcall;

  	// painting
  {$IFDEF MSWINDOWS}
    PostMessage: procedure(Target: VGUIPanel; Msg: PKeyValues; DelaySeconds: Single = 0.0); stdcall;
    PostMessageToVPanel: procedure(Target: VPANEL; Msg: PKeyValues; DelaySeconds: Single = 0.0); stdcall;
  {$ELSE}
    PostMessageToVPanel: procedure(Target: VPANEL; Msg: PKeyValues; DelaySeconds: Single = 0.0); stdcall;
  {$ENDIF}
    OnMove: procedure; stdcall;

    // panel hierarchy
    GetParent: function: VGUIPanel; stdcall;
    GetVParent: function: VPANEL; stdcall;
  {$IFDEF MSWINDOWS}
    SetParentByVPanel: procedure(NewParent: VPANEL); stdcall;
    SetParentByPanel: procedure(NewParent: VGUIPanel); stdcall;
  {$ELSE}
    SetParentByPanel: procedure(NewParent: VGUIPanel); stdcall;
    SetParentByVPanel: procedure(NewParent: VPANEL); stdcall;
  {$ENDIF}

    HasParent: function(PotentialParent: VPANEL): Boolean; stdcall;

    SetAutoDelete: procedure(State: Boolean); stdcall; // if set to true, panel automatically frees itself when parent is deleted
  {$IFDEF MSWINDOWS}
    AddActionSignalTargetByVPanel: procedure(MessageTarget: VPANEL); stdcall;
    AddActionSignalTargetByPanel: procedure(MessageTarget: VGUIPanel); stdcall;
  {$ELSE}
    AddActionSignalTargetByPanel: procedure(MessageTarget: VGUIPanel); stdcall;
    AddActionSignalTargetByVPanel: procedure(MessageTarget: VPANEL); stdcall;
  {$ENDIF}

    RemoveActionSignalTarget: procedure(OldTarget: VGUIPanel); stdcall;
    PostActionSignal: procedure(Msg: PKeyValues); // sends a message to the current actionSignalTarget(s)
    RequestInfoFromChild: function(ChildName: PAnsiChar; OutputData: PKeyValues): Boolean; stdcall;
    PostMessageToChild: procedure(ChildName: PAnsiChar; Msg: PKeyValues); stdcall;
  {$IFNDEF MSWINDOWS}
    PostMessage: procedure(Target: VGUIPanel; Msg: PKeyValues; DelaySeconds: Single = 0.0); stdcall;
  {$ENDIF}
    SetInfo: function(InputData: PKeyValues): Boolean; stdcall; // sets a specified value in the control - inverse of the above

  	// drawing state
	  SetEnabled: procedure(State: Boolean); stdcall;
	  IsEnabled: function: Boolean; stdcall;
	  IsPopup: function: Boolean; stdcall; // has a parent, but is in it's own space
    MoveToFront: procedure; stdcall;

	  SetBgColor: procedure(Color: SDK_Color); stdcall;
  	SetFgColor: procedure(Color: SDK_Color); stdcall;
	  GetBgColor: function: SDK_Color; stdcall;
    GetFgColor: function: SDK_Color; stdcall;

	  SetCursor: procedure(Cursor: HCursor); stdcall;
  	GetCursor: function: HCursor; stdcall;
  	HasFocus: function: Boolean; stdcall;
    InvalidateLayout: procedure(LayoutNow: Boolean = False; ReloadScheme: Boolean = False); stdcall;

    SetTabPosition: procedure(Position: Integer); stdcall;

	  SetBorder: procedure(Border: IBorder); stdcall;
	  GetBorder: function: IBorder; stdcall;

    SetPaintBorderEnabled: procedure(State: Boolean); stdcall;
    SetPaintBackgroundEnabled: procedure(State: Boolean); stdcall;
    SetPaintEnabled: procedure(State: Boolean); stdcall;
    SetPostChildPaintEnabled: procedure(State: Boolean); stdcall;

    GetPaintSize: procedure(out Wide, Tall: Integer); stdcall;
    SetBuildGroup: procedure(BuildGroup: BuildGroup); stdcall;
    IsBuildGroupEnabled: function: Boolean; stdcall;
    IsCursorNone: function: Boolean; stdcall;
    IsCursorOver: function: Boolean; stdcall; // returns true if the cursor is currently over the panel
    MarkForDeletion: procedure stdcall; // object will free it's memory next tick
    IsLayoutInvalid: function: Boolean; stdcall; // does this object require a perform layout?
    HasHotkey: function(Key: WideChar): VGUIPanel; stdcall;			// returns the panel that has this hotkey
    IsOpaque: function: Boolean; stdcall;

    SetSchemeByTag: procedure(Tag: PAnsiChar); stdcall;
    SetSchemeByHandle: procedure(Scheme: HScheme); stdcall;
    GetSchemeColor: function(KeyName: PAnsiChar; PScheme: IScheme): SDK_Color; stdcall;
    GetSchemeColor2: function(KeyName: PAnsiChar; DefaultColor: SDK_Color; PScheme: IScheme): SDK_Color; stdcall;

    // called when scheme settings need to be applied; called the first time before the panel is painted
    ApplySchemeSettings: procedure(PScheme: IScheme); stdcall;

    // interface to build settings
    // takes a group of settings and applies them to the control
    ApplySettings: procedure(InResourceData: PKeyValues); stdcall;

    // records the settings into the resource data
    GetSettings: procedure(OutResourceData: PKeyValues); stdcall;

    // gets a description of the resource for use in the UI
    // format: <type><whitespace | punctuation><keyname><whitespace| punctuation><type><whitespace | punctuation><keyname>...
    // unknown types as just displayed as strings in the UI (for future UI expansion)
    GetDescription: function: PAnsiChar; stdcall;

    // user configuration settings
    // this is used for any control details the user wants saved between sessions
    // eg. dialog positions, last directory opened, list column width
    ApplyUserConfigSettings: procedure(UserConfig: PKeyValues); stdcall;

    // returns user config settings for this control
    GetUserConfigSettings: procedure(UserConfig: PKeyValues); stdcall;

    // optimization, return true if this control has any user config settings
    HasUserConfigSettings: function: Boolean; stdcall;

    OnThink: procedure; stdcall;	// called every frame before painting, but only if panel is visible
    OnCommand: procedure(Command: PAnsiChar); stdcall; // called when a panel receives a command
    OnMouseCaptureLost: procedure; stdcall;	// called after the panel loses mouse capture
    OnSetFocus: procedure; stdcall; // called after the panel receives the keyboard focus
    OnKillFocus: procedure; stdcall; // called after the panel loses the keyboard focus
    OnDelete: procedure; stdcall; // called to delete the panel; Panel::OnDelete() does simply { delete this; }

    // called every frame if ivgui()->AddTickSignal() is called
    OnTick: procedure; stdcall;

    // input messages
    OnCursorMoved: procedure(X, Y: Integer); stdcall;

    OnCursorEntered: procedure; stdcall;
    OnCursorExited: procedure; stdcall;
    OnMousePressed: procedure(Code: VGUIMouseCode); stdcall;
    OnMouseDoublePressed: procedure(Code: VGUIMouseCode); stdcall;
    OnMouseReleased: procedure(Code: VGUIMouseCode); stdcall;
    OnMouseWheeled: procedure(Delta: Integer); stdcall;

    // base implementation forwards Key messages to the Panel's parent
    // - override to 'swallow' the input
    OnKeyCodePressed: procedure(Code: KeyCode); stdcall;
    OnKeyCodeTyped: procedure(Code: KeyCode); stdcall;
    OnKeyTyped: procedure(UniChar: WideChar); stdcall;
    OnKeyCodeReleased: procedure(Code: KeyCode); stdcall;
    OnKeyFocusTicked: procedure; stdcall; // every window gets key ticked events

    // forwards mouse messages to the panel's parent
    OnMouseFocusTicked: procedure; stdcall;

    // message handlers that don't go through the message pump
    PaintBackground: procedure; stdcall;
    Paint: procedure; stdcall;
    PaintBorder: procedure; stdcall;
    PaintBuildOverlay: procedure; stdcall; // the extra drawing for when in build mode
    PostChildPaint: procedure; stdcall;
    PerformLayout: procedure; stdcall;

    // this enables message mapping for this class - requires matching IMPLEMENT_PANELDESC() in the .cpp file
    GetPanelMap: function: PanelMap_t; stdcall;

    // proportional mode settings
    SetProportional: procedure(State: Boolean); stdcall;

    // input interest
    SetMouseInputEnabled: procedure(State: Boolean); stdcall;
    SetKeyBoardInputEnabled: procedure(State: Boolean); stdcall;
    IsMouseInputEnabled: function: Boolean; stdcall;
    IsKeyBoardInputEnabled: function: Boolean; stdcall;

    OnRequestFocus: procedure(SubFocus, DefaultPanel: VPANEL); stdcall;

    InternalCursorMoved: procedure(XPos, YPos: Integer); stdcall;
    InternalCursorEntered: procedure; stdcall;
    InternalCursorExited: procedure; stdcall;

    InternalMousePressed: procedure(Code: Integer); stdcall;
    InternalMouseDoublePressed: procedure(Code: Integer); stdcall;

    InternalMouseReleased: procedure(Code: Integer); stdcall;
    InternalMouseWheeled: procedure(Delta: Integer); stdcall;
    InternalKeyCodePressed: procedure(Code: Integer); stdcall;
    InternalKeyCodeTyped: procedure(Code: Integer); stdcall;
    InternalKeyTyped: procedure(UniChar: WideChar); stdcall;
    InternalKeyCodeReleased: procedure(Code: Integer); stdcall;

    InternalKeyFocusTicked: procedure; stdcall;
    InternalMouseFocusTicked: procedure; stdcall;

    InternalInvalidateLayout: procedure; stdcall;

    InternalMove: procedure; stdcall;
  end;

  PDBasicPanel = ^DBasicPanel;
  DBasicPanel = object
  public
    RegisterClass: Boolean;
    RepaintRegister: Boolean;
    OnCommandRegister: Boolean;
    OnMouseCaptureLostRegister: Boolean;
    OnSetFocusRegister: Boolean;
    OnKillFocusRegister: Boolean;
    OnDeleteRegister: Boolean;
    OnTickRegister: Boolean;
    OnCursorMovedRegister: Boolean;
    OnMouseFocusTickedRegister: Boolean;
    OnRequestFocusRegister: Boolean;
    InternalCursorMovedRegister: Boolean;
    InternalCursorEnteredRegister: Boolean;
    InternalCursorExitedRegister: Boolean;
    InternalMousePressedRegister: Boolean;
    InternalMouseDoublePressedRegister: Boolean;
    InternalMouseReleasedRegister: Boolean;
    InternalMouseWheeledRegister: Boolean;
    InternalKeyCodePressedRegister: Boolean;
    InternalKeyCodeTypedRegister: Boolean;
    InternalKeyTypedRegister: Boolean;
    InternalKeyCodeReleasedRegister: Boolean;
    InternalKeyFocusTickedRegister: Boolean;
    InternalMouseFocusTickedRegister: Boolean;
    InternalInvalidateLayoutRegister: Boolean;
    InternalMoveRegister: Boolean;

    Dummy: Word;

    _VPanel: VPANEL;
    _Cursor: HCursor;
    _MarkedForDeletion: Boolean;

    Dummy2: array[0..2] of Byte;

    _Border: IBorder;
    _NeedsRepaint: Boolean;

    Dummy3: array[0..2] of Byte;

    _BuildGroup: PBuildGroup;
    _FGColor: SDK_Color;
    _BGColor: SDK_Color;
    _PaintBorderEnabled: Boolean;
    _PaintBackgroundEnabled: Boolean;
    _PaintEnabled: Boolean;
    _PostChildPaintEnabled: Boolean;
    _PanelName: PAnsiChar;
    _NeedsLayout: Boolean;
    _NeedsSchemeUpdate: Boolean;
    _AutoDelete: Boolean;

    Dummy4: Byte;

    _TabPosition: Integer;
    ActionSignalTargetDar: Dar<Cardinal>;
    _PinCorner: PinCorner_e;
    _AutoResizeDirection: AutoResize_e;
    IScheme: Integer;
    _BuildModeFlags: Boolean;
    Proportional: Boolean;
    InPerformLayout: Boolean;

    Dummy5: Byte;

    Tooltips: Pointer;
  end;

  BasicPanel = ^PVTablePanel;
{$ENDREGION}

{$REGION 'SectionedListPanel'}
type
  // sorting function, should return true if itemID1 should be displayed before itemID2
  SectionSortFunc_t = function(List: Pointer {SectionedListPanel}; Item1, Item2: Integer): Boolean; cdecl;
  TSectionSortFunc = SectionSortFunc_t;

  PVSectionedListPanel = ^VSectionedListPanel;
  VSectionedListPanel = object(VIClientPanel)
  private type
    // adds a new column to a section
    ColumnFlags_e = set of
    (
      slHEADER_IMAGE	= $01,		// set if the header for the column is an image instead of text
      slCOLUMN_IMAGE	= $02,		// set if the column contains an image instead of text (images are looked up by index from the ImageList) (see SetImageList below)
      slCOLUMN_BRIGHT	= $04,		// set if the column text should be the bright color
      slCOLUMN_CENTER	= $08,		// set to center the text/image in the column
      slCOLUMN_RIGHT	= $10 		// set to right-align the text in the column
    );
  public

    // adds a new section; returns false if section already exists
  {$IFDEF MSWINDOWS}
    AddSection2: procedure(SectionID: Integer; Name: PWideChar; SortFunc: TSectionSortFunc = nil); stdcall;
    AddSection1: procedure(SectionID: Integer; Name: PAnsiChar; SortFunc: TSectionSortFunc = nil); stdcall;
  {$ELSE}
    AddSection1: procedure(SectionID: Integer; Name: PWideChar; SortFunc: TSectionSortFunc = nil); stdcall;
    AddSection2: procedure(SectionID: Integer; Name: PAnsiChar; SortFunc: TSectionSortFunc = nil); stdcall;
  {$ENDIF}

    // clears all the sections - leaves the items in place
    RemoveAllSections: procedure; stdcall;

    // modifies section info
    SetSectionFgColor: procedure(SectionID: Integer; Color: Cardinal); stdcall;
    // forces a section to always be visible
    SetSectionAlwaysVisible: procedure(SectionID: Integer; Visible: Boolean = True); stdcall;

    IsSectionVisible: function(SectionID: Integer): Boolean; stdcall;

  {$IFDEF MSWINDOWS}
    AddColumnToSection2: function(SectionID: Integer; ColumnName: PAnsiChar; ColumnText: PWideChar; ColumnFlags: Integer; Width: Integer; FallbackFont: Cardinal = INVALID_FONT): Boolean; stdcall;
    AddColumnToSection1: function(SectionID: Integer; ColumnName: PAnsiChar; ColumnText: PAnsiChar; ColumnFlags: Integer; Width: Integer; FallbackFont: Cardinal = INVALID_FONT): Boolean; stdcall;
  {$ELSE}
    AddColumnToSection1: function(SectionID: Integer; ColumnName: PAnsiChar; ColumnText: PAnsiChar; ColumnFlags: Integer; Width: Integer; FallbackFont: Cardinal = INVALID_FONT): Boolean; stdcall;
    AddColumnToSection2: function(SectionID: Integer; ColumnName: PAnsiChar; ColumnText: PWideChar; ColumnFlags: Integer; Width: Integer; FallbackFont: Cardinal = INVALID_FONT): Boolean; stdcall;
  {$ENDIF}

    // modifies the text in an existing column
    ModifyColumn: function(SectionID: Integer; ColumnName: PAnsiChar; ColumnText: PWideChar): Boolean; stdcall;

    // adds an item to the list; returns the itemID of the new item
    AddItem: function(SectionID: Integer; Data: PKeyValues): Integer; stdcall;

    // modifies an existing item; returns false if the item does not exist
    ModifyItem: function(ItemID: Integer; SectionID: Integer; Data: PKeyValues): Boolean; stdcall;

    // removes an item from the list; returns false if the item does not exist or is already removed
    RemoveItem: function(ItemID: Integer): Boolean; stdcall;

    // clears the list
    RemoveAll: procedure; stdcall;
    // DeleteAllItems() is deprecated, use RemoveAll();
    DeleteAllItems: procedure; //deprecated 'Use RemoveAll';

    // set the text color of an item
    SetItemFgColor: procedure(ItemID: Integer; Color: Cardinal); stdcall;

    // returns the number of columns in a section
    GetColumnCountBySection: function(SectionID: Integer): Integer; stdcall;

    // returns the name of a column by section and column index; returns NULL if there are no more columns
    // valid range of columnIndex is [0, GetColumnCountBySection)
    GetColumnNameBySection: function(sectionID: Integer; ColumnIndex: Integer): PAnsiChar; stdcall;
    GetColumnTextBySection: function(sectionID: Integer; ColumnIndex: Integer): PWideChar; stdcall;
    GetColumnFlagsBySection: function(sectionID: Integer; ColumnIndex: Integer): Integer; stdcall;
    GetColumnWidthBySection: function(sectionID: Integer; ColumnIndex: Integer): Integer; stdcall;
    GetColumnFallbackFontBySection: function(SectionID: Integer; ColumnIndex: Integer): HFont; stdcall;

    // returns the id of the currently selected item, -1 if nothing is selected
    GetSelectedItem: function: Integer; stdcall;

    // sets which item is currently selected
    SetSelectedItem: procedure(ItemID: Integer); stdcall;

    // returns the data of a selected item
    // InvalidateItem(itemID) needs to be called if the KeyValues are modified
    GetItemData: function(ItemID: Integer): PKeyValues; stdcall;

    // returns what section an item is in
    GetItemSection: function(ItemID: Integer): Integer; stdcall;

    // forces an item to redraw (use when keyvalues have been modified)
    InvalidateItem: procedure(ItemID: Integer); stdcall;

  	// returns true if the itemID is valid for use
    IsItemIDValid: function(ItemID: Integer): Boolean; stdcall;
    GetHighestItemID: function: Integer; stdcall;

    // returns the number of items (ignoring section dividers)
    GetItemCount: function: Integer; stdcall;

    // returns the item ID from the row, again ignoring section dividers - valid from [0, GetItemCount )
    GetItemIDFromRow: function(Row: Integer): Integer; stdcall;

    // gets the local coordinates of a cell
    GetCellBounds: function(ItemID: Integer; Column: Integer; var X, Y, Wide, Tall: Integer): Boolean; stdcall;

    // set up a field for editing
    EnterEditMode: procedure(ItemID: Integer; Column: Integer; EditPanel: Pointer); stdcall;

    // leaves editing mode
    LeaveEditMode: procedure; stdcall;

    // returns true if we are currently in inline editing mode
    IsInEditMode: function: Boolean; stdcall;

    // sets whether or not the vertical scrollbar should ever be displayed
    SetVerticalScrollbar: procedure(State: Boolean); stdcall;

    // returns the size required to fully draw the contents of the panel
    GetContentSize: procedure(var Wide, Tall: Integer); stdcall;

    // image handling
    SetImageList: procedure(ImageList: Pointer {ImageList}; DeleteImageListWhenDone: Boolean); stdcall;

    ScrollToItem: procedure(Item: Integer); stdcall;

    OnSliderMoved: procedure; stdcall;
  end;

  DSectionedListPanel = object(DBasicPanel)
  public
    // TODO: Implement
  end;

  SectionedListPanel = ^PVSectionedListPanel;
{$ENDREGION}

{$REGION 'VControlsListPanel'}
type
  PVControlsListPanel = ^VControlsListPanel;
  VControlsListPanel = object(VSectionedListPanel)
  public
    // Start/end capturing
    StartCaptureMode: procedure(Cursor: HCursor = 0); stdcall;
    EndCaptureMode: procedure(Cursor: HCursor = 0); stdcall;
    IsCapturing: function: Boolean; stdcall;

    // Set which item should be associated with the prompt
    SetItemOfInterest: procedure(ItemID: Integer); stdcall;
    GetItemOfInterest: function: Integer; stdcall;
  end;

  ControlsListPanel = ^PVControlsListPanel;
{$ENDREGION}

{$REGION 'Menu'}
  PVTableMenu = ^VTableMenu;
  VTableMenu = object(VTablePanel)
  public
	  // the menu.  For combo boxes, it's the edit/field, etc. etc.

  {$IFDEF MSWINDOWS}
    // Add a custom panel to the menu
    AddMenuItem8: function(Panel: Pointer (*MenuItem*)): Integer; stdcall;
  {$ENDIF}

  // Add a simple text item to the menu
  {$IFDEF MSWINDOWS}
    AddMenuItem7: function(ItemText: PAnsiChar; Target: BasicPanel; UserData: PKeyValues = nil): Integer; stdcall;
    AddMenuItem6: function(ItemText: PAnsiChar; Msg: PKeyValues; Target: BasicPanel; UserData: PKeyValues = nil): Integer; stdcall;
    AddMenuItem5: function(ItemText, Command: PAnsiChar; Target: BasicPanel; UserData: PKeyValues = nil): Integer; stdcall;

    AddMenuItem4: function(ItemName: PAnsiChar; ItemText: PWideChar; Msg: PKeyValues; Target: BasicPanel; UserData: PKeyValues = nil): Integer; stdcall;
    AddMenuItem3: function(ItemName, ItemText: PAnsiChar; Msg: PKeyValues; Target: BasicPanel; UserData: PKeyValues = nil): Integer; stdcall;

    AddMenuItem2: function(ItemName: PAnsiChar; ItemText: PWideChar; Command: PAnsiChar; Target: BasicPanel; UserData: PKeyValues = nil): Integer; stdcall;
    AddMenuItem: function(ItemName, ItemText, Command: PAnsiChar; Target: BasicPanel; UserData: PKeyValues = nil): Integer; stdcall;
  {$ELSE}
    AddMenuItem: function(ItemName, ItemText, Command: PAnsiChar; Target: BasicPanel; UserData: PKeyValues = nil): Integer; stdcall;
    AddMenuItem2: function(ItemName: PAnsiChar; ItemText: PWideChar; Command: PAnsiChar; Target: BasicPanel; UserData: PKeyValues = nil): Integer; stdcall;

    AddMenuItem3: function(ItemName, ItemText: PAnsiChar; Msg: PKeyValues; Target: BasicPanel; UserData: PKeyValues = nil): Integer; stdcall;
    AddMenuItem4: function(ItemName: PAnsiChar; ItemText: PWideChar; Msg: PKeyValues; Target: BasicPanel; UserData: PKeyValues = nil): Integer; stdcall;

    AddMenuItem5: function(ItemText, Command: PAnsiChar; Target: BasicPanel; UserData: PKeyValues = nil): Integer; stdcall;
    AddMenuItem6: function(ItemText: PAnsiChar; Msg: PKeyValues; Target: BasicPanel; UserData: PKeyValues = nil): Integer; stdcall;
    AddMenuItem7: function(ItemText: PAnsiChar; Target: BasicPanel; UserData: PKeyValues = nil): Integer; stdcall;
  {$ENDIF}

    // Add a checkable item to the menu
  {$IFDEF MSWINDOWS}
    AddCheckableMenuItem7: function(ItemText: PAnsiChar; Target: BasicPanel; UserData: PKeyValues = nil): Integer; stdcall;
    AddCheckableMenuItem6: function(ItemText: PAnsiChar; Msg: PKeyValues; Target: BasicPanel; UserData: PKeyValues = nil): Integer; stdcall;
    AddCheckableMenuItem5: function(ItemText, Command: PAnsiChar; Target: BasicPanel; UserData: PKeyValues = nil): Integer; stdcall;

    AddCheckableMenuItem4: function(ItemName: PAnsiChar; ItemText: PWideChar; Msg: PKeyValues; Target: BasicPanel; UserData: PKeyValues = nil): Integer; stdcall;
    AddCheckableMenuItem3: function(ItemName, ItemText: PAnsiChar; Msg: PKeyValues; Target: BasicPanel; UserData: PKeyValues = nil): Integer; stdcall;

    AddCheckableMenuItem2: function(ItemName: PAnsiChar; ItemText: PWideChar; Command: PAnsiChar; Target: BasicPanel; UserData: PKeyValues = nil): Integer; stdcall;
    AddCheckableMenuItem: function(ItemName, ItemText, Command: PAnsiChar; Target: BasicPanel; UserData: PKeyValues = nil): Integer; stdcall;
  {$ELSE}
    AddCheckableMenuItem: function(ItemName, ItemText, Command: PAnsiChar; Target: BasicPanel; UserData: PKeyValues = nil): Integer; stdcall;
    AddCheckableMenuItem2: function(ItemName: PAnsiChar; ItemText: PWideChar; Command: PAnsiChar; Target: BasicPanel; UserData: PKeyValues = nil): Integer; stdcall;

    AddCheckableMenuItem3: function(ItemName, ItemText: PAnsiChar; Msg: PKeyValues; Target: BasicPanel; UserData: PKeyValues = nil): Integer; stdcall;
    AddCheckableMenuItem4: function(ItemName: PAnsiChar; ItemText: PWideChar; Msg: PKeyValues; Target: BasicPanel; UserData: PKeyValues = nil): Integer; stdcall;

    AddCheckableMenuItem5: function(ItemText, Command: PAnsiChar; Target: BasicPanel; UserData: PKeyValues = nil): Integer; stdcall;
    AddCheckableMenuItem6: function(ItemText: PAnsiChar; Msg: PKeyValues; Target: BasicPanel; UserData: PKeyValues = nil): Integer; stdcall;
    AddCheckableMenuItem7: function(ItemText: PAnsiChar; Target: BasicPanel; UserData: PKeyValues = nil): Integer; stdcall;
  {$ENDIF}

    // Add a cascading menu item to the menu
  {$IFDEF MSWINDOWS}
    AddCascadingMenuItem7: function(ItemText: PAnsiChar; Target: BasicPanel; CascadeMenu: Pointer; UserData: PKeyValues = nil): Integer; stdcall;
    AddCascadingMenuItem6: function(ItemText: PAnsiChar; Msg: PKeyValues; Target: BasicPanel; CascadeMenu: Pointer; UserData: PKeyValues = nil): Integer; stdcall;
    AddCascadingMenuItem5: function(ItemText, Command: PAnsiChar; Target: BasicPanel; CascadeMenu: Pointer; UserData: PKeyValues = nil): Integer; stdcall;

    AddCascadingMenuItem4: function(ItemName: PAnsiChar; ItemText: PWideChar; Msg: PKeyValues; Target: BasicPanel; CascadeMenu: Pointer; UserData: PKeyValues = nil): Integer; stdcall;
    AddCascadingMenuItem3: function(ItemName, ItemText: PAnsiChar; Msg: PKeyValues; Target: BasicPanel; CascadeMenu: Pointer; UserData: PKeyValues = nil): Integer; stdcall;

    AddCascadingMenuItem2: function(ItemName: PAnsiChar; ItemText: PWideChar; Command: PAnsiChar; Target: BasicPanel; CascadeMenu: Pointer; UserData: PKeyValues = nil): Integer; stdcall;
    AddCascadingMenuItem: function(ItemName, ItemText, Command: PAnsiChar; Target: BasicPanel; CascadeMenu: Pointer; UserData: PKeyValues = nil): Integer; stdcall;
  {$ELSE}
    AddCascadingMenuItem: function(ItemName, ItemText, Command: PAnsiChar; Target: BasicPanel; CascadeMenu: Pointer; UserData: PKeyValues = nil): Integer; stdcall;
    AddCascadingMenuItem2: function(ItemName: PAnsiChar; ItemText: PWideChar; Command: PAnsiChar; Target: BasicPanel; CascadeMenu: Pointer; UserData: PKeyValues = nil): Integer; stdcall;

    AddCascadingMenuItem3: function(ItemName, ItemText: PAnsiChar; Msg: PKeyValues; Target: BasicPanel; CascadeMenu: Pointer; UserData: PKeyValues = nil): Integer; stdcall;
    AddCascadingMenuItem4: function(ItemName: PAnsiChar; ItemText: PWideChar; Msg: PKeyValues; Target: BasicPanel; CascadeMenu: Pointer; UserData: PKeyValues = nil): Integer; stdcall;

    AddCascadingMenuItem5: function(ItemText, Command: PAnsiChar; Target: BasicPanel; CascadeMenu: Pointer; UserData: PKeyValues = nil): Integer; stdcall;
    AddCascadingMenuItem6: function(ItemText: PAnsiChar; Msg: PKeyValues; Target: BasicPanel; CascadeMenu: Pointer; UserData: PKeyValues = nil): Integer; stdcall;
    AddCascadingMenuItem7: function(ItemText: PAnsiChar; Target: BasicPanel; CascadeMenu: Pointer; UserData: PKeyValues = nil): Integer; stdcall;
  {$ENDIF}

  {$IFNDEF MSWINDOWS}
    // Add a custom panel to the menu
    AddMenuItem8: function(Panel: Pointer (*MenuItem*)): Integer; stdcall;
  {$ENDIF}

    // Sets the values of a menu item at the specified index
  {$IFDEF MSWINDOWS}
    UpdateMenuItem2: procedure(ItemID: Integer; ItemText: PWideChar; Msg: PKeyValues; UserData: PKeyValues = nil); stdcall;
    UpdateMenuItem: procedure(ItemID: Integer; ItemText: PAnsiChar; Msg: PKeyValues; UserData: PKeyValues = nil); stdcall;
  {$ELSE}
    UpdateMenuItem: procedure(ItemID: Integer; ItemText: PAnsiChar; Msg: PKeyValues; UserData: PKeyValues = nil); stdcall;
    UpdateMenuItem2: procedure(ItemID: Integer; ItemText: PWideChar; Msg: PKeyValues; UserData: PKeyValues = nil); stdcall;
  {$ENDIF}

    IsValidMenuID: function(ItemID: Integer): Boolean; stdcall;
    GetInvalidMenuID: function: Integer; stdcall;

    GetItemUserData: function(ItemID: Integer): PKeyValues; stdcall;

  {$IFDEF MSWINDOWS}
    SetItemEnabled2: procedure(ItemID: Integer; State: Boolean); stdcall;
    SetItemEnabled: procedure(ItemName: PAnsiChar; State: Boolean); stdcall;
    SetItemVisible2: procedure(ItemID: Integer; Visible: Boolean); stdcall;
    SetItemVisible: procedure(ItemName: PAnsiChar; Visible: Boolean); stdcall;
  {$ELSE}
    SetItemEnabled: procedure(ItemName: PAnsiChar; State: Boolean); stdcall;
    SetItemEnabled2: procedure(ItemID: Integer; State: Boolean); stdcall;
    SetItemVisible: procedure(ItemName: PAnsiChar; Visible: Boolean); stdcall;
    SetItemVisible2: procedure(ItemID: Integer; Visible: Boolean); stdcall;
  {$ENDIF}

    // Clear the menu, deleting all the menu items within
    DeleteAllItems: procedure; stdcall;

    // Override the auto-width setting with a single fixed width
    SetFixedWidth: procedure(Width: Integer); stdcall;

    // sets the height of each menu item
    SetMenuItemHeight: procedure(ItemHeight: Integer); stdcall;

    // Set the max number of items visible (scrollbar appears with more)
    SetNumberOfVisibleItems: procedure(NumItems: Integer); stdcall;

    // Activates item in the menu list, as if that menu item had been selected by the user
    ActivateItem: procedure(ItemID: Integer); stdcall;
    ActivateItemByRow: procedure(Row: Integer); stdcall;

  	GetActiveItem: function: Integer; stdcall; // returns the itemID (not the row) of the active item

    // Return the number of items currently in the menu list
    GetItemCount: function: Integer; stdcall;

    // return the menuID of the n'th item in the menu list, valid from [0, GetItemCount)
    GetMenuID: function(Index: Integer): Integer; stdcall;

  	SetFont: procedure(Font: HFont); stdcall;

    OnMenuItemSelected: procedure(Panel: Pointer); stdcall;
    AddScrollBar: procedure; stdcall;
    RemoveScrollBar: procedure; stdcall;
    OnSliderMoved: procedure; stdcall;

    LayoutMenuBorder: procedure; stdcall;
    MakeItemsVisibleInScrollRange: procedure(MaxVisibleItems, NumPixelsAvailable: Integer); stdcall;

    OnKeyModeSet: procedure; stdcall;
    OnCursorEnteredMenuItem: procedure(VPanel: Integer); stdcall;
    OnCursorExitedMenuItem: procedure(VPanel: Integer); stdcall;
  end;

  Menu = ^PVTableMenu;
{$ENDREGION}

{$REGION 'CPanelListPanel'}
  PVTableCPanelListPanel = ^VTableCPanelListPanel;
  VTableCPanelListPanel = object(VTablePanel)
  public
    // DATA & ROW HANDLING
    // The list now owns the panel
    ComputeVPixelsNeeded: function: Integer; stdcall;
    AddItem: function(Panel: BasicPanel): Integer; stdcall;
    GetItemCoun: function: Integer; stdcall;
    GetItem: function(ItemIndex: Integer): BasicPanel; stdcall; // returns pointer to data the row holds
    RemoveItem: procedure(ItemIndex: Integer); stdcall; // removes an item from the table (changing the indices of all following items)
    DeleteAllItems: procedure; // clears and deletes all the memory used by the data items

    // PAINTING
    GetCellRenderer: function(Row: Integer): BasicPanel; stdcall;

    ScrollBarSliderMoved: procedure(Position: Integer); stdcall;
  end;

  CPanelListPanel = ^PVTableCPanelListPanel;
{$ENDREGION}

{$REGION 'RichText'}
  PVTableRichText = ^VTableRichText;
  VTableRichText = object(VTablePanel)
  public
    CutSelected: procedure; stdcall;
    CopySelected: procedure; stdcall;
	  OnSetText: procedure(Text: PAnsiChar); stdcall;
  	OnSliderMoved: procedure; stdcall; // respond to scroll bar events
  	OnTextClicked: procedure(Text: PWideChar); stdcall;
  end;

  RichText = ^PVTableRichText;
{$ENDREGION}

{$REGION 'ImageList'}

  PImageList = ^ImageList;
  ImageList = record
	  Images: CUtlVector<IImage, Integer>;
	  DeleteImagesWhenDone: Boolean;
  end; {$ENDREGION}

{$REGION 'ImagePanel'}
  PVTableImagePanel = ^VTableImagePanel;
  VTableImagePanel = object(VTablePanel)
  public
    SetImage: procedure(Image: IImage); stdcall;
    GetImage: function: IImage; stdcall;
  end;

  ImagePanel = ^PVTableImagePanel;
{$ENDREGION}

{$REGION 'ListPanel'}

  TSortFunc = procedure(Panel: Pointer (*ListPanel*); const Item1, Item2: ListPanelItem); stdcall;

  PVTableListPanel = ^VTableListPanel;
  VTableListPanel = object(VTablePanel)
  private type
    // COLUMN HANDLING
    // all indices are 0 based, limit of 255 columns
    // columns are resizable by default
    ColumnFlags_e = set of
    (
      lpCOLUMN_FIXEDSIZE = $01,         // set to have the column be a fixed size
      lpCOLUMN_RESIZEWITHWINDOW = $02,  // set to have the column grow with the parent dialog growing
      lpCOLUMN_IMAGE = $04,             // set if the column data is not text, but instead the index of the image to display
      lpCOLUMN_HIDDEN = $08,            // column is hidden by default
      lpCOLUMN_UNHIDABLE = $10          // column is unhidable
    );
  public
    // adds a column header
  {$IFDEF MSWINDOWS}
    AddColumnHeader2: procedure(Index: Integer; ColumnName, ColumnText: PansiChar; Width: Integer; ColumnFlags: Integer = 0);
    AddColumnHeader: procedure(Index: Integer; ColumnName, ColumnText: PAnsiChar; StartingWidth, MinWidth, MaxWidth: Integer; ColumnFlags: Integer = 0); stdcall;
  {$ELSE}
    AddColumnHeader: procedure(Index: Integer; ColumnName, ColumnText: PAnsiChar; StartingWidth, MinWidth, MaxWidth: Integer; ColumnFlags: Integer = 0); stdcall;
    AddColumnHeader2: procedure(Index: Integer; ColumnName, ColumnText: PansiChar; Width: Integer; ColumnFlags: Integer = 0);
  {$ENDIF}

    RemoveColumn: procedure(Column: Integer); stdcall; // removes a column
    FindColumn: function(ColumnName: PAnsiChar): Integer; stdcall;

    SetColumnHeaderHeight: procedure(Height: Integer); stdcall;
    SetColumnHeaderTextA: procedure(Column: Integer; Text: PAnsiChar); stdcall;
    SetColumnHeaderTextW: procedure(Column: Integer; Text: PWideChar); stdcall;
    SetColumnHeaderImage: procedure(Column: INteger; ImageListIndex: Integer); stdcall;
    SetColumnHeaderTooltip: procedure(Column: Integer; TooltipText: PAnsiChar); stdcall;

    // Get information about the column headers.
    GetNumColumnHeaders: function: Integer; stdcall;
    GetColumnHeaderText: function(Index: Integer; &Out: PansiChar; MaxLen: Integer): Boolean; stdcall;

    SetSortFunc: procedure(Column: Integer; Func: TSortFunc); stdcall;
    SetSortColumn: procedure(Column: Integer); stdcall;
    SortList: procedure; stdcall;
    SetColumnSortable: procedure(Column: Integer; Sortable: Boolean); stdcall;
    SetColumnVisible: procedure(Column: Integer; Visible: Boolean); stdcall;

    // sets whether the user can add/remove columns (defaults to off)
    SetAllowUserModificationOfColumns: procedure(Allowed: Boolean); stdcall;

    // DATA HANDLING
    // data->GetName() is used to uniquely identify an item
    // data sub items are matched against column header name to be used in the table
    AddItem: function(Data: PKeyValues; UserData: Cardinal; ScrollToItem, SortOnAdd: Boolean): Integer; stdcall; // Takes a copy of the data for use in the table. Returns the index the item is at.

    GetItemCount: function: Integer; stdcall;			// returns the number of VISIBLE items
  {$IFDEF MSWINDOWS}
    GetItem2: function(ItemID: Integer): PKeyValues; // returns pointer to data the row holds
    GetItem: function(ItemName: PAnsiChar): Integer; stdcall; // gets the row index of an item by name (data->GetName())
  {$ELSE}
    GetItem: function(ItemName: PAnsiChar): Integer; stdcall; // gets the row index of an item by name (data->GetName())
    GetItem2: function(ItemID: Integer): PKeyValues; // returns pointer to data the row holds
  {$ENDIF}
    GetItemCurrentRow: function(ItemID: Integer): Integer; stdcall; // returns -1 if invalid index or item not visible
    GetItemIDFromRow: function(CurrentRow: Integer): Integer; stdcall; // returns -1 if invalid row
    GetItemUserData: function(ItemID: Integer): Cardinal; stdcall;
    GetItemData: function(ItemID: Integer): PListPanelItem; stdcall;
    SetUserData: procedure(ItemID: Integer; UserData: Cardinal); stdcall;
    GetItemIDFromUserData: function(UserData: Cardinal): Integer; stdcall;
    ApplyItemChanges: procedure(ItemID: Integer); // applies any changes to the data, performed by modifying the return of GetItem() above
    RemoveItem: procedure(ItemID: Integer); // removes an item from the table (changing the indices of all following items)
    RereadAllItems: procedure; stdcall; // updates the view with the new data

    RemoveAll: procedure; stdcall; // clears and deletes all the memory used by the data items
    DeleteAllItems: procedure; stdcall; // obselete, use RemoveAll();

    GetCellImage: function(ItemID, Column: Integer): IImage; stdcall; //, ImagePanel *&buffer); // returns the image held by a specific cell

    // Use these until they return InvalidItemID to iterate all the items.
    FirstItem: function: Integer; stdcall;
    NextItem: function: Integer; stdcall;

    InvalidItemID: function: Integer; stdcall;
    IsValidItemID: function(ItemID: Integer): Boolean; stdcall;

    // sets whether the dataitem is visible or not
    // it is removed from the row list when it becomes invisible, but stays in the indexes
    // this is much faster than a normal remove
    SetItemVisible: procedure(ItemID: Integer; State: Boolean); stdcall;
    SetItemDisabled: procedure(ItemID: Integer; State: Boolean); stdcall;

    SetFont: procedure(Font: HFont); stdcall;

    // image handling
    SetImageList: procedure(List: PImageList; DeleteImageListWhenDone: Boolean); stdcall;

    // SELECTION

    // returns the count of selected items
    GetSelectedItemsCount: function: Integer; stdcall;

    // returns the selected item by selection index, valid in range [0, GetNumSelectedRows)
    GetSelectedItem: function(SelectionIndex: Integer): Integer; stdcall;

    // sets no item as selected
    ClearSelectedItems: procedure; stdcall;

    // adds a item to the select list
    AddSelectedItem: procedure(ItemID: Integer); stdcall;

    // sets this single item as the only selected item
    SetSingleSelectedItem: procedure(ItemID: Integer); stdcall;

    // returns the selected column, -1 for particular column selected
    GetSelectedColumn: function: Integer; stdcall;

    // whether or not to select specific cells (off by default)
    SetSelectIndividualCells: procedure(State: Boolean); stdcall;

    // sets a single cell - all other previous rows are cleared
    SetSelectedCell: procedure(Row, Column: Integer); stdcall;

    GetCellAtPos: function(X, Y: Integer; out Row, Column: Integer): Boolean; stdcall; // returns true if any found, row and column are filled out. x, y are in screen space
    GetCellBounds: function(Row, Column: Integer; out X, Y, Wide, Tall: Integer): Boolean; stdcall;

    // sets the text which is displayed when the list is empty
    SetEmptyListTextA: procedure(Text: PAnsiChar); stdcall;
    SetEmptyListTextW: procedure(Text: PWideChar); stdcall;

    // PAINTING
    GetCellRenderer: function(Row, Column: Integer): VGUIPanel; stdcall;

    OnSliderMoved: procedure; stdcall;
    OnColumnResized: procedure(Column, Delta: Integer); stdcall;
    OnSetSortColumn: procedure(Column: Integer); stdcall;
    ResizeColumnToContents: procedure(Column: Integer); stdcall;
    OpenColumnChoiceMenu: procedure; stdcall;
    OnToggleColumnVisible: procedure(Column: Integer); stdcall;

    GetRowsPerPage: function: Single; stdcall;
    GetStartItem: function: Integer; stdcall;
  end;

  ListPanel = ^PVTableListPanel;

{$ENDREGION}

{$REGION 'EditablePanel'}
  PVTableEditablePanel = ^VTableEditablePanel;
  VTableEditablePanel = object(VTablePanel)
  public
    // Load the control settings - should be done after all the children are added
    // If you pass in pPreloadedKeyValues, it won't actually load the file. That way, you can cache
    // the keyvalues outside of here if you want to prevent file accesses in the middle of the game.
    LoadControlSettings: procedure(DialogResourceName: PAnsiChar; PathID: PAnsiChar = nil; PreloadedKeyValues: PKeyValues = nil); stdcall;

    // sets the name of this dialog so it can be saved in the user config area
    // use dialogID to differentiate multiple instances of the same dialog
    LoadUserConfig: procedure(ConfigName: PAnsiChar; DialogID: Integer = 0); stdcall;
    SaveUserConfig: procedure; stdcall;

    // combines both of the above, LoadControlSettings & LoadUserConfig
    LoadControlSettingsAndUserConfig: procedure(DialogResourceName: PAnsiChar; DialogID: Integer = 0); stdcall;

    // Override to change how build mode is activated
    ActivateBuildMode: procedure; stdcall;

    // Return the buildgroup that this panel is part of.
    GetBuildGroup: function: PBuildGroup; stdcall;

    // Virtual factory for control creation
    // controlName is a string which is the same as the class name
    CreateControlByName: function(ControlName: PAnsiChar): VGUIPanel; stdcall;

    // Shortcut function to set data in child controls
    SetControlString: procedure(ControlName, Str: PAnsiChar); stdcall;
    // Shortcut function to set data in child controls
    SetControlInt: procedure(ControlName: PAnsiChar; State: Integer); stdcall;
    // Shortcut function to get data in child controls
    GetControlInt: procedure(ControlName: PAnsiChar; DefaultState: Integer); stdcall;
    // Shortcut function to get data in child controls
    // Returns a maximum of 511 characters in the string
    GetControlString: function(ControlName, DefaultString: PAnsiChar): PAnsiChar;
    // as above, but copies the result into the specified buffer instead of a static buffer
    GetControlString2: procedure(ControlName: PAnsiChar; Buf: PAnsiChar; BufSize: Integer; DefaultString: PAnsiChar); stdcall;
    // sets the enabled state of a control
    SetControlEnabled: procedure(ControlName: PAnsiChar; Enabled: Boolean); stdcall;
    SetControlVisible: procedure(ControlName: PAnsiChar; Visible: Boolean); stdcall;

    // localization variables (used in constructing UI strings)
    // after the variable is set, causes all the necessary sub-panels to update
    SetDialogVariableStr: procedure(VarName: PAnsiChar; Value: PAnsiChar);
    SetDialogVariableWStr: procedure(VarName: PAnsiChar; Value: PWideChar);
    SetDialogVariableInt: procedure(VarName: PAnsiChar; Value: Integer);
    SetDialogVariableFloat: procedure(VarName: PAnsiChar; Value: Single);

    (* INFO HANDLING
      "BuildDialog"
        input:
          "BuildGroupPtr" - pointer to the panel/dialog to edit
        returns:
          "PanelPtr" - pointer to a new BuildModeDialog()

      "ControlFactory"
        input:
          "ControlName" - class name of the control to create
        returns:
          "PanelPtr" - pointer to the newly created panel, or NULL if no such class exists
    *)
	  // registers a file in the list of control settings, so the vgui dialog can choose between them to edit
	  RegisterControlSettingsFile: procedure(DialogResourceName: PAnsiChar; PathID: PAnsiChar = nil);

    // nav group access
    GetFocusNavGroup: function: FocusNavGroup; stdcall;

    // called when default button has been set
    OnDefaultButtonSet: procedure(Button: Pointer); stdcall;
    // called when the current default button has been set
    OnCurrentDefaultButtonSet: procedure(Button: Pointer); stdcall;
    OnFindDefaultButton: procedure; stdcall;

    OnClose: procedure; stdcall;
  end;

  EditablePanel = ^PVTableEditablePanel;
{$ENDREGION}

{$REGION 'CTaskbar'}
  PVTableCTaskbar = ^VTableCTaskbar;
  VTableCTaskbar = object(VTableEditablePanel)
  public
    OnActivateModule: procedure(ModuleIndex: Integer); stdcall;
    ActivateGameUI: procedure; stdcall;
  end;

  CTaskbar = ^PVTableCTaskbar;
{$ENDREGION}

{$REGION 'PropertyPage'}
  PVTablePropertyPage = ^VTablePropertyPage;
  VTablePropertyPage = object(VTableEditablePanel)
  public
    // Called when page is loaded.  Data should be reloaded from document into controls.
    OnResetData: procedure; stdcall;

    // Called when the OK / Apply button is pressed.  Changed data should be written into document.
    OnApplyChanges: procedure; stdcall;

    // called when the page is shown/hidden
    OnPageShow: procedure; stdcall;
    OnPageHide: procedure; stdcall;

    SetPaintBorder: procedure(State: Boolean); stdcall;

    // called to be notified of the tab button used to Activate this page
    // if overridden this must be chained back to
    OnPageTabActivated: procedure(Panel: Pointer); stdcall;
  end;

  PropertyPage = ^PVTablePropertyPage;

{$ENDREGION}

{$REGION 'Label'}

	// Set how the content aligns itself within the label
	// alignment code, used to determine how the images are layed out within the Label
	Alignment =
	(
		a_northwest = 0,
		a_north,
		a_northeast,
		a_west,
		a_center,
		a_east,
		a_southwest,
		a_south,
		a_southeast
	);

	// Set whether the text is displayed bright or dull
	EColorState =
	(
		CS_NORMAL,
		CS_DULL,
		CS_BRIGHT
	);

  PVTableLabel = ^VTableLabel;
  VTableLabel = object(VTablePanel)
  public
    // Take the string and looks it up in the localization file to convert it to unicode
    SetTextByToken: procedure(TokenName: PAnsiChar); stdcall;

    // Set unicode text directly
    SetText: procedure(UnicodeString: PAnsiChar); stdcall;

    // Get the current text
    GetTextA: procedure(TextOut: PAnsiChar; BufferLen: Integer); stdcall;
    GetTextW: procedure(TextOut: PWideChar; BufLenInBytes: Integer); stdcall;

    // Content alignment
    // Get the size of the content within the label
    GetContentSize: procedure(out Wide, Tall: Integer); stdcall;

    SetContentAlignment: procedure(Alignment: Alignment); stdcall;

	  // Additional offset at the Start of the text (from whichever sides it is aligned)
  	SetTextInset: procedure(XInset, YInset: Integer); stdcall;

    // colors to use when the label is disabled
    SetDisabledFgColor1: procedure(Color: SDK_Color); stdcall;
    SetDisabledFgColor2: procedure(Color: SDK_Color); stdcall;
    GetDisabledFgColor1: function: SDK_Color; stdcall;
    GetDisabledFgColor2: function: SDK_Color; stdcall;

    SetTextColorState: procedure(State: EColorState); stdcall;

    // Font
    SetFont: procedure(Font: HFont); stdcall;
    GetFont: function: HFont; stdcall;

  	// Hotkey
	  SetHotkey: procedure(Key: WideChar); stdcall;

    // Labels can be associated with controls, and alter behaviour based on the associates behaviour
    // If the associate is disabled, so are we
    // If the associate has focus, we may alter how we draw
    // If we get a hotkey press or focus message, we forward the focus to the associate
    SetAssociatedControl: procedure(Control: VGUIPanel); stdcall;

    // Multiple image handling
    // Images are drawn from left to right across the label, ordered by index
    // By default there is a TextImage in position 0 (see GetTextImage()/SetTextImageIndex())
    AddImage: function(Image: IImage; PreOffset: Integer): Integer; stdcall;  // Return the index the image was placed in
    SetImageAtIndex: procedure(Index: Integer; Image: IImage; PreOffset: Integer); stdcall;
    SetImagePreOffset: procedure(Index: Integer; PreOffset: Integer); stdcall; // Set the offset in pixels before the image
    GetImageAtIndex: function(Index: Integer): IImage; stdcall;
    GetImageCount: function: Integer; stdcall;
    ClearImages: procedure; stdcall;
    // fixes the layout bounds of the image within the label
    SetImageBounds: procedure(Index, X, Width: Integer); stdcall;

    // Teturns a pointer to the default text image
    GetTextImage: function: TextImage; stdcall;

    // Moves where the default text image is within the image array (it starts in position 0)
    // Setting it to -1 removes it from the image list
    // Returns the index the default text image was previously in
    SetTextImageIndex: function(NewIndex: Integer): Integer; stdcall;

    SizeToContents: procedure; stdcall;

    CalculateHotkeyA: function(Text: PAnsiChar): PAnsiChar; stdcall;
    CalculateHotkeyW: function(Text: PWideChar): PWideChar; stdcall;
    ComputeAlignment: procedure(out X0, Y0, X1, Y1: Integer); stdcall;

    OnSetText: procedure(Params: PKeyValues); stdcall;
    DrawDashedLine: procedure(X0, Y, X1, Y1, DashLen, GapLen: Integer); stdcall;
    OnHotkeyPressed: procedure; stdcall;

    // makes sure that the maxIndex will be a valid index
    EnsureImageCapacity: procedure(MaxIndex: Integer); stdcall;

    OnDialogVariablesChanged: procedure(DialogVariables: PKeyValues); stdcall;
  end;

  VLabel = ^PVTableLabel;

{$ENDREGION}

{$REGION 'CBitmapImagePanel'}

  PVPanelCBitmapImagePanel = ^VPanelCBitmapImagePanel;
  VPanelCBitmapImagePanel = object(VTablePanel)
  public
  {$IFDEF MSWINDOWS}
    SetTexture: procedure(FileName: PAnsiChar); stdcall;
  {$ELSE}
    SetTexture: procedure(FileName: PAnsiChar; HardwareFiltered: Boolean = True); stdcall;
  {$ENDIF}

    // Set how the image aligns itself within the panel
    SetContentAlignment: procedure(Alignment: Alignment); stdcall;

    ComputeImagePosition: procedure(out X, Y, W, H: Integer); stdcall;
  end;

  CBitmapImagePanel = ^PVPanelCBitmapImagePanel;

{$ENDREGION}

{$REGION 'Button'}

	ActivationType_t =
	(
		ACTIVATE_ONPRESSEDANDRELEASED, // normal button behaviour
		ACTIVATE_ONPRESSED,	 // menu buttons, toggle buttons
		ACTIVATE_ONRELEASED // menu items
	);

  PVTableButton = ^VTableButton;
  VTableButton = object(VTableLabel)
  public
    // Set armed state.
    SetArmed: procedure(State: Boolean); stdcall;
    // Check armed state
    IsArmed: function: Boolean; stdcall;

    // Check depressed state
    IsDepressed: function: Boolean; stdcall;
    // Set button force depressed state.
    ForceDepressed: procedure(State: Boolean); stdcall;
    // Set button depressed state with respect to the force depressed state.
    RecalculateDepressedState: procedure; stdcall;

    // Set button selected state.
    SetSelected: procedure(State: Boolean); stdcall;
    // Check selected state
    IsSelected: function: Boolean; stdcall;

    //Set whether or not the button captures all mouse input when depressed.
    SetUseCaptureMouse: procedure(State: Boolean); stdcall;
    // Check if mouse capture is enabled.
    IsUseCaptureMouseEnabled: function: Boolean; stdcall;

    // Activate a button click.
    DoClick: procedure; stdcall;
    OnHotkey: procedure; stdcall;

    // Set button to be mouse clickable or not.
    SetMouseClickEnabled: procedure(Code: VGUIMouseCode; State: Boolean); stdcall;
    // Check if button is mouse clickable
    IsMouseClickEnabled: function(Code: VGUIMouseCode): Boolean; stdcall;

    SetButtonActivationType: procedure(ActivationType: ActivationType_t); stdcall;

    // Message targets that the button has been pressed
    FireActionSignal: procedure; stdcall;

    CanBeDefaultButton: function: Boolean; stdcall;

    // Set this button to be the button that is accessed by default when the user hits ENTER or SPACE
    SetAsDefaultButton: procedure(State: Integer); stdcall;
    // Set this button to be the button that is currently accessed by default when the user hits ENTER or SPACE
    SetAsCurrentDefaultButton: procedure(State: Integer); stdcall;

    // Set button border attribute enabled, controls display of button.
    SetButtonBorderEnabled: procedure(State: Boolean); stdcall;

    // Set default button colors.
    SetDefaultColor: procedure(FgColor, BgColor: SDK_Color); stdcall;
    // Set armed button colors
    SetArmedColor: procedure(FgColor, BgColor: SDK_Color); stdcall;
    // Set depressed button colors
    SetDepressedColor: procedure(FgColor, BgColor: SDK_Color); stdcall;

    // Get button foreground color
    GetButtonFgColor: function: SDK_Color; stdcall;
    // Get button background color
    GetButtonBgColor: function: SDK_Color; stdcall;

    // Set default button border attributes.
    SetDefaultBorder: procedure(Border: IBorder); stdcall;
    // Set depressed button border attributes.
    SetDepressedBorder: procedure(Border: IBorder); stdcall;
    // Set key focused button border attributes.
    SetKeyFocusBorder: procedure(Border: IBorder); stdcall;

  {$IFDEF MSWINDOWS}
    // Set the message to send when the button is pressed
    SetCommandMessage: procedure(Msg: PKeyValues); stdcall;
    // Set the command to send when the button is pressed
    // Set the panel to send the command to with AddActionSignalTarget()
    SetCommandString: procedure(Command: PAnsiChar); stdcall;
  {$ELSE}
    // Set the command to send when the button is pressed
    // Set the panel to send the command to with AddActionSignalTarget()
    SetCommandString: procedure(Command: PAnsiChar); stdcall;
    // Set the message to send when the button is pressed
    SetCommandMessage: procedure(Msg: PKeyValues); stdcall;
  {$ENDIF}

    DrawFocusBorder: procedure(X0, Y0, X1, Y1: Integer); stdcall;
    // Get button border attributes.
    GetBorder2: function(Depressed, Armed, Selected, KeyFocus: Boolean): IBorder; stdcall;

    OnSetState: procedure(State: Integer); stdcall;
  end;

  VButton = ^PVTableButton;

{$ENDREGION}

{$REGION 'MenuItem'}
  PVTableMenuItem = ^VTableMenuItem;
  VTableMenuItem = object(VTableButton)
  public
    // Highlight item
    ArmItem: procedure; stdcall;
    // Unhighlight item.
    DisarmItem: procedure; stdcall;

    OnKeyModeSet: procedure; stdcall;

    Init: procedure; stdcall;
  end;

  MenuItem = ^PVTableMenuItem;
{$ENDREGION}

{$REGION 'ToggleButton'}

  PVTableToggleButton = ^VTableToggleButton;
  VTableToggleButton = object(VTableButton)
  public

  end;

  ToggleButton = ^PVTableToggleButton;

{$ENDREGION}

{$REGION 'CheckButton'}

  PVTableCheckButton = ^VTableCheckButton;
  VTableCheckButton = object(VTableToggleButton)
  public
	// sets whether or not the state of the check can be changed
	// if this is set to false, then no input in the code or by the user can change it's state
  	SetCheckButtonCheckable: procedure(State: Boolean); stdcall;

  	OnCheckButtonChecked: procedure(Panel: Pointer); stdcall;
  end;

  CheckButton = ^PVTableCheckButton;

{$ENDREGION}

{$REGION 'CCvarToggleCheckButton'}
  PVTableCCvarToggleCheckButton = ^VTableCCvarToggleCheckButton;
  VTableCCvarToggleCheckButton = object(VTableCheckButton)
  public

  end;

  CCvarToggleCheckButton = ^VTableCCvarToggleCheckButton;
{$ENDREGION}

{$REGION 'CrosshairImagePanel'}
  PVTableCrosshairImagePanel = ^VTableCrosshairImagePanel;
  VTableCrosshairImagePanel = object(VTableImagePanel)
  public

  end;
{$ENDREGION}

{$REGION 'TextEntry'}

  PVTableTextEntry = ^VTableTextEntry;
  VTableTextEntry = object(VTablePanel)
  public
  {$IFDEF MSWINDOWS}
    SetTextA: procedure(Text: PAnsiChar); stdcall;
    SetTextW: procedure(Text: PWideChar); stdcall;
  {$ELSE}
    SetTextW: procedure(Text: PWideChar); stdcall;
    SetTextA: procedure(Text: PAnsiChar); stdcall;
  {$ENDIF}

  {$IFDEF MSWINDOWS}
    GetTextW: procedure(Buf: PWideChar; BufLen: Integer); stdcall;
    GetTextA: procedure(Buf: PAnsiChar; BufLen: Integer); stdcall;
  {$ELSE}
    GetTextA: procedure(Buf: PAnsiChar; BufLen: Integer); stdcall;
    GetTextW: procedure(Buf: PWideChar; BufLen: Integer); stdcall;
  {$ENDIF}

    // editing
    GotoLeft: procedure; stdcall;		// move cursor one char left
    GotoRight: procedure; stdcall;		// move cursor one char right
    GotoUp: procedure; stdcall;			// move cursor one line up
    GotoDown: procedure; stdcall;		// move cursor one line down
    GotoWordRight: procedure; stdcall;	// move cursor to Start of next word
    GotoWordLeft: procedure; stdcall;	// move cursor to Start of prev word
    GotoFirstOfLine: procedure; stdcall;	// go to Start of the current line
    GotoEndOfLine: procedure; stdcall;	// go to end of the current line
    GotoTextStart: procedure; stdcall;	// go to Start of text buffer
    GotoTextEnd: procedure; stdcall;		// go to end of text buffer

    InsertChar: procedure(Ch: WideChar); stdcall;
    InsertStringA: procedure(Text: PAnsiChar); stdcall;
    InsertStringW: procedure(Text: PWideChar); stdcall;
    Backspace: procedure; stdcall;
    Delete: procedure; stdcall;
    SelectNone: procedure; stdcall;
    OpenEditMenu: procedure; stdcall;

    CutSelected: procedure; stdcall;
    CopySelected: procedure; stdcall;
    Paste: procedure; stdcall;

    DeleteSelected: procedure; stdcall;
    Undo: procedure; stdcall;
    SaveUndoState: procedure; stdcall;
    SetFont: procedure(Font: HFont); stdcall;
    SetTextHidden: procedure(HideText: Boolean); stdcall;
    SetEditable: procedure(State: Boolean); stdcall;
    IsEditable: function: Boolean; stdcall;
    // move the cursor to line 'line', given how many pixels are in a line
    MoveCursor: procedure(Line, PixelsAcross: Integer); stdcall;

    // sets the color of the background when the control is disabled
    SetDisabledBgColor: procedure(Color: SDK_Color); stdcall;

    // set whether the box handles more than one line of entry
    SetMultiline: procedure(State: Boolean); stdcall;

    // sets visibility of scrollbar
    SetVerticalScrollbar: procedure(State: Boolean); stdcall;

    // sets whether or not the edit catches and stores ENTER key presses
    SetCatchEnterKey: procedure(State: Boolean); stdcall;

    // sets whether or not to send "TextNewLine" msgs when ENTER key is pressed
    SendNewLine: procedure(Send: Boolean); stdcall;

    // sets limit of number of characters insertable into field; set to -1 to remove maximum
    // only works with if rich-edit is NOT enabled
    SetMaximumCharCount: procedure(MaxChars: Integer); stdcall;
    GetMaximumCharCount: function: Integer; stdcall;
    SetAutoProgressOnHittingCharLimit: procedure(State: Boolean); stdcall;

    // sets whether to wrap text once maxChars is reached (on a line by line basis)
    SetWrap: procedure(Wrap: Boolean); stdcall;

    RecalculateLineBreaks: procedure; stdcall;
    LayoutVerticalScrollBarSlider: procedure; stdcall;

    ResetCursorBlink: procedure; stdcall;
    DrawChar: function(Ch: WideChar; Font: HFont; Index: Integer; X, Y: Integer): Integer; stdcall;
    DrawCursor: function(X, Y: Integer): Boolean; stdcall;

    SetCharAt: procedure(Ch: WideChar; Index: Integer); stdcall; // set the value of a char in the text buffer

    FireActionSignal: procedure; stdcall;
    GetSelectedRange: function(out X0, X1: Integer): Boolean; stdcall;
    CursorToPixelSpace: procedure(CursorPos: Integer; out X, Y: Integer); stdcall;

    PixelToCursorSpace: function(X, Y: Integer): Integer; stdcall;
    AddAnotherLine: procedure(X, Y: Integer); stdcall;
    GetYStart: function: Integer; stdcall; // works out ypixel position drawing started at

    SelectCheck: function(FromMouse: Boolean = False): Boolean; stdcall; // check if we are in text selection mode

    OnSetText: procedure(Text: PWideChar); stdcall;
    OnSliderMoved: procedure; stdcall; // respond to scroll bar events

    // Returns the character index the drawing should Start at
    GetStartDrawIndex: function(out LineBreakIndexIndex: Integer): Integer; stdcall;

    OnSetState: procedure(State: Integer); stdcall;
  end;

  VTextEntry = ^PVTableTextEntry;

{$ENDREGION}

{$REGION 'ComboBox'}

  MenuDirection_e =
	(
		LEFT,
		RIGHT,
		UP,
		DOWN,
		CURSOR,	// make the menu appear under the mouse cursor
		ALIGN_WITH_PARENT // make the menu appear under the parent
	);

  PVTableComboBox = ^VTableComboBox;
  VTableComboBox = object(VTableTextEntry)
  public
    // functions designed to be overriden
    OnShowMenu: procedure(PMenu: Menu); stdcall;
    OnHideMenu: procedure(PMenu: Menu); stdcall;

  	// Set the number of items in the drop down menu.
	  SetNumberOfEditLines: procedure(NumLines: Integer); stdcall;

  	//  Add an item to the drop down
  {$IFDEF MSWINDOWS}
  	AddItem2: function(ItemText: PWideChar; UserData: PKeyValues): Integer; stdcall;
	  AddItem: function(ItemText: PAnsiChar; UserData: PKeyValues): Integer; stdcall;
  {$ELSE}
	  AddItem: function(ItemText: PAnsiChar; UserData: PKeyValues): Integer; stdcall;
  	AddItem2: function(ItemText: PWideChar; UserData: PKeyValues): Integer; stdcall;
  {$ENDIF}

    GetItemCount: function: Integer; stdcall;

    // update the item
  {$IFDEF MSWINDOWS}
    UpdateItem2: function(ItemID: Integer; ItemText: PWideChar; UserData: PKeyValues): Pointer; stdcall;
    UpdateItem: function(ItemID: Integer; ItemText: PAnsiChar; UserData: PKeyValues): Pointer; stdcall;
  {$ELSE}
    UpdateItem: function(ItemID: Integer; ItemText: PAnsiChar; UserData: PKeyValues): Pointer; stdcall;
    UpdateItem2: function(ItemID: Integer; ItemText: PWideChar; UserData: PKeyValues): Pointer; stdcall;
  {$ENDIF}

    IsItemIDValid: function(ItemID: Integer): Boolean; stdcall;

    // set the enabled state of an item
  {$IFDEF MSWINDOWS}
    SetItemEnabled2: procedure(ItemID: Integer; State: Boolean); stdcall;
    SetItemEnabled: procedure(ItemText: PAnsiChar; State: Boolean); stdcall;
  {$ELSE}
    SetItemEnabled: procedure(ItemText: PAnsiChar; State: Boolean); stdcall;
    SetItemEnabled2: procedure(ItemID: Integer; State: Boolean); stdcall;
  {$ENDIF}

	  // deprecated, use above
  	DeleteAllItems: procedure; stdcall;

    // Sorts the items in the list - FIXME does nothing
    SortItems: procedure; stdcall;

    // Set the visiblity of the drop down menu button.
    SetDropdownButtonVisible: procedure(State: Boolean); stdcall;

    // Return true if the combobox current has the dropdown menu open
    IsDropdownVisible: function: Boolean; stdcall;

    // Activate the item in the menu list,as if that
    // menu item had been selected by the user
    ActivateItem: procedure(ItemID: Integer); stdcall;
    ActivateItemByRow: procedure(Row: Integer); stdcall;

    GetActiveItem: function: Integer; stdcall;
    GetActiveItemUserData: function: PKeyValues; stdcall;
    GetItemUserData: function(ItemID: Integer): PKeyValues; stdcall;

    // sets a custom menu to use for the dropdown
    SetMenu: procedure(PMenu: Menu); stdcall;
    GetMenu: function: Menu; stdcall;

    ShowMenu: procedure; stdcall;
    HideMenu: procedure; stdcall;
    OnMenuClose: procedure; stdcall;
    DoClick: procedure; stdcall;

    SetOpenDirection: procedure(Direction: MenuDirection_e); stdcall;

    SetUseFallbackFont: procedure(State: Boolean; Fallback: HFont); stdcall;

    OnMenuItemSelected: procedure; stdcall;
  end;

  ComboBox = ^PVTableComboBox;
{$ENDREGION}

{$REGION 'CLabeledCommandComboBox'}

  VTableCLabeledCommandComboBox = object(VTableComboBox)

  end;

{$ENDREGION}

{$REGION 'Frame'}
  PVTableFrame = ^VTableFrame;
  VTableFrame = object(VTableEditablePanel)
  public
    // Set the text in the title bar.  Set surfaceTitle=true if you want this to be the taskbar text as well.
  {$IFDEF MSWINDOWS}
    SetTitleW: procedure(Title: PWideChar; SurfaceTitle: Boolean); stdcall;
    SetTitleA: procedure(Title: PAnsiChar; SurfaceTitle: Boolean); stdcall;
  {$ELSE}
    SetTitleA: procedure(Title: PAnsiChar; SurfaceTitle: Boolean); stdcall;
    SetTitleW: procedure(Title: PWideChar; SurfaceTitle: Boolean); stdcall;
  {$ENDIF}

    // Bring the frame to the front and requests focus, ensures it's not minimized
    Activate: procedure; stdcall;

    // activates the dialog; if dialog is not currently visible it starts it minimized and flashing in the taskbar
    ActivateMinimized: procedure; stdcall;

    // closes the dialog
    Close: procedure; stdcall;
    CloseModal: procedure; stdcall;

    // Move the dialog to the center of the screen
    MoveToCenterOfScreen: procedure; stdcall;

    // Set the movability of the panel
    SetMoveable: procedure(State: Boolean); stdcall;
    // Check the movability of the panel
    IsMoveable: function: Boolean; stdcall;

    // Set the resizability of the panel
    SetSizeable: procedure(State: Boolean); stdcall;
    // Check the resizability of the panel
    IsSizeable: function: Boolean; stdcall;
    // Toggle visibility of the system menu button
    SetMenuButtonVisible: procedure(State: Boolean); stdcall;

    // Toggle visibility of the minimize button
    SetMinimizeButtonVisible: procedure(State: Boolean); stdcall;
    // Toggle visibility of the maximize button
    SetMaximizeButtonVisible: procedure(State: Boolean); stdcall;
    // Toggles visibility of the minimize-to-systray icon (defaults to false)
    SetMinimizeToSysTrayButtonVisible: procedure(State: Boolean); stdcall;

    // Toggle visibility of the close button
    SetCloseButtonVisible: procedure(State: Boolean); stdcall;

    // returns true if the dialog is currently minimized
    IsMinimized: function: Boolean; stdcall;
    // Flash the window system tray button until the frame gets focus
    FlashWindow: procedure; stdcall;
    // Stops any window flashing
    FlashWindowStop: procedure; stdcall;

    // Get the system menu
    GetSysMenu: function: Menu; stdcall;
    // Set the system menu
    SetSysMenu: procedure(MenuObj: Menu); stdcall;

    // set whether the title bar should be rendered
    SetTitleBarVisible: procedure(State: Boolean); stdcall;

    // sets the dialog to delete self on close
    SetDeleteSelfOnClose: procedure(State: Boolean); stdcall;

    // Shows the dialog in a modal fashion
    DoModal: procedure; stdcall;

    // Minimize the window on the taskbar.
    OnMinimize: procedure; stdcall;
    // Called when minimize-to-systray button is pressed (does nothing by default)
    OnMinimizeToSysTray: procedure; stdcall;

    // the frame close button was pressed
    OnCloseFrameButtonPressed: procedure; stdcall;

    // gets the default position and size on the screen to appear the first time (defaults to centered)
    GetDefaultScreenPosition: function(out X, Y, Wide, Tall: Integer): Boolean; stdcall;

    // Get the size of the panel inside the frame edges.
    GetClientArea: procedure(out X, Y, Wide, Tall: Integer); stdcall;

    InternalSetTitle: procedure(Text: PAnsiChar); stdcall;
    InternalFlashWindow: procedure; stdcall;
    OnDialogVariablesChanged: procedure(DialogVariables: PKeyValues); stdcall;
  end;

  Frame = ^PVTableFrame;

{$ENDREGION}

{$REGION 'MessageBox'}
  PVTableMessageBox = ^VTableMessageBox;
  VTableMessageBox = object(VTableFrame)
  public
    // Put the message box into a modal state
    DoModal2: procedure(FrameOver: Frame = nil); stdcall;

    // make the message box appear and in a modeless state
    ShowWindow: procedure(FrameOver: Frame = nil);

    // Set a string command to be sent when the OK button is pressed
    // Use AddActionSignalTarget() to mark yourself as a recipient of the command
  {$IFDEF MSWINDOWS}
    SetCommandMessage: procedure(Command: PKeyValues); stdcall;
    SetCommandString: procedure(Command: PAnsiChar); stdcall;
  {$ELSE}
    SetCommandString: procedure(Command: PAnsiChar); stdcall;
    SetCommandMessage: procedure(Command: PKeyValues); stdcall;
  {$ENDIF}

    // Set the visibility of the OK button.
    SetOKButtonVisible: procedure(State: Boolean); stdcall;

    // Set the text on the OK button
  {$IFDEF MSWINDOWS}
    SetOKButtonTextW: procedure(ButtonText: PWideChar); stdcall;
    SetOKButtonTextA: procedure(ButtonText: PAnsiChar); stdcall;
  {$ELSE}
    SetOKButtonTextA: procedure(ButtonText: PAnsiChar); stdcall;
    SetOKButtonTextW: procedure(ButtonText: PWideChar); stdcall;
  {$ENDIF}

    // Toggles visibility of the close box.
    DisableCloseButton: procedure(State: Boolean); stdcall;

    OnShutdownRequest: procedure; stdcall;
  end;

  VMessageBox = ^PVTableMessageBox;
{$ENDREGION}

{$REGION 'PropertySheet'}

  PVTablePropertySheet = ^VTablePropertySheet;
  VTablePropertySheet = object(VTablePanel)
  public
    // Adds a page to the sheet.  The first page added becomes the active sheet.
    AddPage: procedure(Page: BasicPanel; Title: PAnsiChar); stdcall;

    // sets the current page
    SetActivePage: procedure(Page: BasicPanel); stdcall;

    // sets the width, in pixels, of the page tab buttons.
    SetTabWidth: procedure(Pixels: Integer); stdcall;

    // Gets a pointer to the currently active page.
    GetActivePage: function: BasicPanel; stdcall;

    // Removes (but doesn't delete) all pages
    RemoveAllPage: procedure; stdcall;

    // writes out any changed data to the doc
    ApplyChanges: procedure; stdcall;

  // returns the ith panel
    GetPage: function(I: Integer): BasicPanel; stdcall;

    // deletes this panel from the sheet
    DeletePage: procedure(Panel: BasicPanel); stdcall;

	  // returns the current activated tab
    GetActiveTab: procedure; stdcall;

    // returns the title text of the tab
    GetActiveTabTitle: procedure(TextOut: PAnsiChar; BufferLen: Integer); stdcall;

    // returns the title of tab "i"
    GetTabTitle: function(I: Integer; TextOut: PAnsiChar; BufferLen: Integer): Boolean; stdcall;

    // returns the index of the active page
    GetActivePageNum: function: Integer; stdcall;

    // returns the number of pages in the sheet
    GetNumPages: function: Integer; stdcall;

    // disable the page with title "title"
    DisablePage: procedure(Title: PAnsiChar); stdcall;

    // enable the page with title "title"
    EnablePage: procedure(Title: PAnsiChar); stdcall;

    ChangeActiveTab: procedure(Index: Integer); stdcall;

    // internal message handlers
    OnTabPressed: procedure(Panel: Pointer); stdcall;
    OnTextChanged: procedure(Panel: Pointer; Text: PWideChar); stdcall;
    OnOpenContextMenu: procedure(Params: PKeyValues); stdcall;
    OnApplyButtonEnable: procedure; stdcall;

    // called when the current default button has been set
    OnCurrentDefaultButtonSet: procedure(Button: Pointer); stdcall;
    OnFindDefaultButton: procedure; stdcall;

    EnDisPage: procedure(Title: PAnsiChar; State: Boolean); stdcall;
  end;

  PropertySheet = ^PVTablePropertySheet;

{$ENDREGION}

{$REGION 'PropertyDialog'}

  PVTablePropertyDialog = ^VTablePropertyDialog;
  VTablePropertyDialog = object(VTableFrame)
  public
  	// returns a pointer to the PropertySheet this dialog encapsulates
	  GetPropertySheet: function: PropertySheet; stdcall;

    // wrapper for PropertySheet interface
    AddPage: procedure(Page: BasicPanel; Title: PAnsiChar);
    GetActivePage: function: BasicPanel; stdcall;
    ApplyChanges: procedure; stdcall;
    ResetAllData: procedure; stdcall;

    // Called when the OK button is pressed.  Simply closes the dialog.
    OnOK: function: Boolean; stdcall;
    OnApplyButtonEnable: procedure; stdcall;
  end;

  PropertyDialog = ^PVTablePropertyDialog;
{$ENDREGION}

{$REGION 'CDialogGameInfo'}

  PVTableCDialogGameInfo = ^VTableCDialogGameInfo;
  VTableCDialogGameInfo = object(VTableFrame)
  public
    ClearPlayerList: procedure; stdcall;
    SendPlayerQuery: procedure(IP: LongWord; Port: Word); stdcall;
    OnConnect: procedure; stdcall;
    OnRefresh: procedure; stdcall;
    OnButtonToggled: procedure(Panel: Pointer); stdcall;
    OnRadioButtonChecked: procedure(Panel: Pointer); stdcall;
    OnJoinServerWithPassword: procedure(Password: PAnsiChar); stdcall;
    OnConnectToGame: procedure(IP, Port: Integer); stdcall;
  end;
  CDialogGameInfo = ^PVTableCDialogGameInfo;

{$ENDREGION}

{$REGION 'vgui2::Bitmap'}
type
  PVTableBitmap = ^VTableBitmap;
  VTableBitmap = object(VTableImage)
  public
  end;

{$A4}
  DTableBitmap = object
  public
    _id: HTexture;
    _uploaded: Boolean;
    _valid: Boolean;
    _filename: PAnsiChar;
    _pos: array[0..1] of Integer;
    _color: SDK_Color;
    _filtered: Boolean;
    wide: Integer;
    tall: Integer;
  end;
{$A-}

  Bitmap = record
    VTable: PVTableBitmap;
    Data: DTableBitmap;
  end;
  {$IF SizeOf(Bitmap) <> 40} {$MESSAGE WARN 'Structure size mismatch @ Bitmap.'} {$DEFINE MSME} {$IFEND}

{$ENDREGION}

type
  TIPanel = class(TObject)
  private
    FThis: IPanel;
  public
    constructor Create(Panel: IPanel);

    procedure Init(vguiPanel: VPANEL; Panel: IClientPanel);

    // methods
    procedure SetPos(vguiPanel: VPANEL; X, Y: Integer);
    procedure GetPos(vguiPanel: VPANEL; out X, Y: Integer);
    procedure SetSize(vguiPanel: VPANEL; Wide, Tall: Integer);
    procedure GetSize(vguiPanel: VPANEL; out Wide, Tall: Integer);
    procedure SetMinimumSize(vguiPanel: VPANEL; Wide, Tall: Integer);
    procedure GetMinimumSize(vguiPanel: VPANEL; out Wide, Tall: Integer);
    procedure SetZPos(vguiPanel: VPANEL; Z: Integer);
    function GetZPos(vguiPanel: VPANEL): Integer;

    procedure GetAbsPos(vguiPanel: VPANEL; var X, Y: Integer);
    procedure GetClipRect(vguiPanel: VPANEL; out X0, Y0, X1, Y1: Integer);
    procedure SetInset(vguiPanel: VPANEL; Left, Top, Right, Bottom: Integer);
    procedure GetInset(vguiPanel: VPANEL; out Left, Top, Right, Bottom: Integer);

    procedure SetVisible(vguiPanel: VPANEL; State: Boolean);
    function IsVisible(vguiPanel: VPANEL): Boolean;
    procedure SetParent(vguiPanel, newParent: VPANEL);
    function GetChildCount(vguiPanel: VPANEL): Integer;
    function GetChild(vguiPanel: VPANEL; Index: Integer): VPANEL;
    function GetParent(vguiPanel: VPANEL): VPANEL;
    procedure MoveToFront(vguiPanel: VPANEL);
    procedure MoveToBack(vguiPanel: VPANEL);
    function HasParent(vguiPanel, PotentialParent: VPANEL): Boolean;
    function IsPopup(vguiPanel: VPANEL): Boolean;
    procedure SetPopup(vguiPanel: VPANEL; State: Boolean);

    function Render_GetPopupVisible(vguiPanel: VPANEL): Boolean;
    procedure Render_SetPopupVisible(vguiPanel: VPANEL; State: Boolean);

    // gets the scheme this panel uses
    function GetScheme(vguiPanel: VPANEL): HScheme;
    // gets whether or not this panel should scale with screen resolution
    function IsProportional(vguiPanel: VPANEL): Boolean;
    // returns true if auto-deletion flag is set
    function IsAutoDeleteSet(vguiPanel: VPANEL): Boolean;
    // deletes the Panel * associated with the vpanel
    procedure DeletePanel(vguiPanel: VPANEL);

    // input interest
    procedure SetKeyBoardInputEnabled(vguiPanel: VPANEL; State: Boolean);
    procedure SetMouseInputEnabled(vguiPanel: VPANEL; State: Boolean);
    function IsKeyBoardInputEnabled(vguiPanel: VPANEL): Boolean;
    function IsMouseInputEnabled(vguiPanel: VPANEL): Boolean;

    // calculates the panels current position within the hierarchy
    procedure Solve(vguiPanel: VPANEL);

    // gets names of the object (for debugging purposes)
    function GetName(vguiPanel: VPANEL): PAnsiChar;
    function GetClassName(vguiPanel: VPANEL): PAnsiChar;

    // delivers a message to the panel
    procedure SendMessage(vguiPanel: VPANEL; Params: PKeyValues; FromPanel: VPANEL);

    // these pass through to the IClientPanel
    procedure Think(vguiPanel: VPANEL);
    procedure PerformApplySchemeSettings(vguiPanel: VPANEL);
    procedure PaintTraverse(vguiPanel: VPANEL; ForceRepaint: Boolean; AllowForce: Boolean = True);
    procedure Repaint(vguiPanel: VPANEL);
    function IsWithinTraverse(vguiPanel: VPANEL; X, Y: Integer; TraversePopups: Boolean): VPANEL;
    procedure OnChildAdded(vguiPanel, Child: VPANEL);
    procedure OnSizeChanged(vguiPanel: VPANEL; NewWide, NewTall: Integer);

    procedure InternalFocusChanged(vguiPanel: VPANEL; Lost: Boolean);
    function RequestInfo(vguiPanel: VPANEL; OutputData: PKeyValues): Boolean;
    procedure RequestFocus(vguiPanel: VPANEL; Direction: Integer = 0);
    function RequestFocusPrev(vguiPanel, ExistingPanel: VPANEL): Boolean;
    function RequestFocusNext(vguiPanel, ExistingPanel: VPANEL): Boolean;
    function GetCurrentKeyFocus(vguiPanel: VPANEL): VPANEL;
    function GetTabPosition(vguiPanel: VPANEL): Integer;

    // used by ISurface to store platform-specific data
    function Plat(vguiPanel: VPANEL): SurfacePlat;
    procedure SetPlat(vguiPanel: VPANEL; Plat: SurfacePlat);

    // returns a pointer to the vgui controls baseclass Panel *
    // destinationModule needs to be passed in to verify that the returned Panel * is from the same module
    // it must be from the same module since Panel * vtbl may be different in each module
    function GetPanel(vguiPanel: VPANEL; DestinationModule: PAnsiChar): VGUIPanel;

    function IsEnabled(vguiPanel: VPANEL): Boolean;
    procedure SetEnabled(vguiPanel: VPANEL; State: Boolean);

    function Client(vguiPanel: VPANEL): IClientPanel;
    function GetModuleName(vguiPanel: VPANEL): PAnsiChar;
  end;

  TPanel = class(TObject)
  private
    FThis: IClientPanel;
  public
    constructor Create(Panel: Pointer);

    function GetVPanel: VPANEL;

    // straight interface to Panel functions
    procedure Think;
    procedure PerformApplySchemeSettings;
    procedure PaintTraverse(ForceRepaint: Boolean; AllowForce: Boolean);
    procedure Repaint;
    function IsWithinTraverse(X, Y: Integer; TraversePopups: Boolean): VPANEL;
    procedure GetInset(out Top, Left, Right, Bottom: Integer);
    procedure GetClipRect(out X0, Y0, X1, Y1: Integer);
    procedure OnChildAdded(Child: VPANEL);
    procedure OnSizeChanged(NewWide, NewTall: Integer);

    procedure InternalFocusChanged(Lost: Boolean);
    function RequestInfo(OutputData: PKeyValues): Boolean;
    procedure RequestFocus(Direction: Integer);
    function RequestFocusPrev(ExistingPanel: VPANEL): Boolean;
    function RequestFocusNext(ExistingPanel: VPANEL): Boolean;
    procedure OnMessage(Params: PKeyValues; FromPanel: VPANEL);
    function GetCurrentKeyFocus: VPANEL;
    function GetTabPosition: Integer;

    // for debugging purposes
    function GetName: PAnsiChar;
    function GetClassName: PAnsiChar;

    // get scheme handles from panels
    function GetScheme: HScheme;
    // gets whether or not this panel should scale with screen resolution
    function IsProportional: Boolean;
    // auto-deletion
    function IsAutoDeleteSet: Boolean;
    // deletes this
    procedure DeletePanel;

    // interfaces
    function QueryInterface(ID: EInterfaceID): Pointer;

    // returns a pointer to the vgui controls baseclass Panel *
    function GetPanel: VGUIPanel;

    // returns the name of the module this panel is part of
    function GetModuleName: PAnsiChar;
  end;

{$REGION 'IVGui'}
type
  PVVGui = ^VVGui;
  VVGui = record
    Create: procedure(Dispose: Boolean); stdcall;
    Init: function(var FactoryList: TCreateInterfaceFn; NumFactories: Integer): Boolean; stdcall;
    Shutdown: procedure; stdcall;
    Start: procedure; stdcall;
    Stop: procedure; stdcall;
    IsRunning: function: Boolean; stdcall;
    RunFrame: procedure; stdcall;
    ShutdownMessage: procedure(ShutdownID: Cardinal); stdcall;
    AllocPanel: function: VPANEL; stdcall;
    FreePanel: procedure(Panel: VPANEL); stdcall;
    DPrintf: procedure(Format: PAnsiChar); stdcall varargs;
    DPrintf2: procedure(Format: PAnsiChar); stdcall varargs;
    SpewAllActivePanelNames: procedure; stdcall;
    PanelToHandle: function(Panel: VPANEL): HPanel; stdcall;
    HandleToPanel: function(Index: Cardinal): Pointer; stdcall;
    MarkPanelForDeletion: procedure(Panel: Pointer); stdcall;
    AddTickSignal: procedure(Panel: Pointer; IntervalMilliseconds: Integer); stdcall;
    RemoveTickSignal: procedure(Panel: VPANEL);
    PostMessage: procedure(Target: Pointer; Params: PKeyValues; From: Pointer; DelaySeconds: Single = 0.0); stdcall;
    CreateContext: function: Cardinal;
    DestroyContext: procedure(Context: HContext); stdcall;
    AssociatePanelWithContext: procedure(Context: Cardinal; Root: Pointer); stdcall;
    ActivateContext: procedure(Context: HContext); stdcall;
    SetSleep: procedure(State: Boolean); stdcall;
    GetShouldVGuiControlSleep: function: Boolean; stdcall;
  end;

  IVGui = ^PVVGui;

const
  VGUI_IVGUI_INTERFACE_VERSION = 'VGUI_ivgui006';
{$ENDREGION}

{$REGION 'ILocalize'}
type
  StringIndex_t = Cardinal;
  TStringIndex = StringIndex_t;

  PVTableLocalize = ^VTableLocalize;
  VTableLocalize = record
    Destroy: procedure(Free: Boolean); stdcall;

    // adds the contents of a file to the localization table
    //!! in the next version of this, the IFileSystem * should be removed, the table should get it itself (not version safe)
    AddFile: function(FileSystem: Pointer; FileName: PAnsiChar): Boolean; stdcall;

    // Remove all strings from the table
    RemoveAll: procedure; stdcall;

    // Finds the localized text for tokenName
    Find: function(TokenName: PAnsiChar): PWideChar; stdcall;

    // converts an english string to unicode
    // returns the number of wchar_t in resulting string, including null terminator
	  ConvertANSIToUnicode: function(ANSI: PAnsiChar; Unicode: PWideChar; UnicodeBufferSizeInBytes: Integer): Integer; stdcall;

    // converts an unicode string to an english string
    // unrepresentable characters are converted to system default
    // returns the number of characters in resulting string, including null terminator
    ConvertUnicodeToANSI: function(Unicode: PWideChar; ANSI: PAnsiChar; AnsiBufferSize: Integer): Integer; stdcall;

    // finds the index of a token by token name, INVALID_STRING_INDEX if not found
    FindIndex: function(TokenName: PAnsiChar): TStringIndex; stdcall;

    // builds a localized formatted string
    // uses the format strings first: %s1, %s2, ...  unicode strings (wchar_t *)
    ConstructString: procedure(UnicodeOuput: PWideChar; UnicodeBufferSizeInBytes: Integer; FormatString: PWideChar; NumFormatParameters: Integer); cdecl varargs;
    // need to replace the existing ConstructString with this
    ConstructString2: procedure(UnicodeOutput: PWideChar; UnicodeBufferSizeInBytes: Integer; TokenName: PAnsiChar; LocalizationVariables: PKeyValues); stdcall;
    ConstructString3: procedure(UnicodeOutput: PWideChar; UnicodeBufferSizeInBytes: Integer; UnlocalizedTextSymbol: TStringIndex; LocalizationVariables: PKeyValues); stdcall;

    // gets the values by the string index
    GetNameByIndex: function(Index: TStringIndex): PAnsiChar; stdcall;
    GetValueByIndex: function(Index: TStringIndex): PWideChar; stdcall;

    ///////////////////////////////////////////////////////////////////
    // the following functions should only be used by localization editors

    // iteration functions
    GetFirstStringIndex: function: TStringIndex; stdcall;
    // returns the next index, or INVALID_STRING_INDEX if no more strings available
    GetNextStringIndex: function(Index: TStringIndex): TStringIndex; stdcall;

    // adds a single name/unicode string pair to the table
    AddString: procedure(TokenName: PAnsiChar; UnicodeString: PWideChar; FileName: PAnsiChar); stdcall;

    // changes the value of a string
    SetValueByIndex: procedure(Index: TStringIndex; NewValue: PWideChar); stdcall;

    // saves the entire contents of the token tree to the file
    SaveToFile: function(FileSystem: Pointer; FileName: PAnsiChar): Boolean; stdcall;

    // iterates the filenames
    GetLocalizationFileCount: function: Integer; stdcall;
    GetLocalizationFileName: function(Index: Integer): PAnsiChar; stdcall;

    // returns the name of the file the specified localized string is stored in
    GetFileNameByIndex: function(Index: TStringIndex): PAnsiChar; stdcall;

    // for development only, reloads localization files
    //!! in the next version of this, the IFileSystem * should be removed, the table should get it itself (not version safe)
    ReloadLocalizationFiles: procedure(FileSystem: Pointer); stdcall;

    // adds the contents of a file to the localization table
    //!! in the next version of this, the IFileSystem * should be removed, the table should get it itself (not version safe)
    // If bIncludeFallbackSearchPaths is true, then if you are running a mod, the hl2\resource\*.txt file will be added first, then the modname\resource\*.txt file...
    //virtual bool AddFileEx( IFileSystem *fileSystem, const char *fileName, char const *pPathID, bool bIncludeFallbackSearchPaths ) = 0;
  end;

  ILocalize = ^PVTableLocalize;

const
  VGUI_LOCALIZE_INTERFACE_VERSION = 'VGUI_Localize003';
{$ENDREGION}

implementation

{ TIPanel }

constructor TIPanel.Create(Panel: IPanel);
begin
  inherited Create;

  FThis := Panel;
end;

function TIPanel.Client(vguiPanel: VPANEL): IClientPanel;
begin
{$IFDEF VGUI_USE_PANEL009}
  raise Exception.Create('TIPanel.Client: Not implemented in VGUI_Panel009.');
{$ELSE}
  Result := IClientPanel(ThisCall(FThis, @FThis^.Client, vguiPanel));
{$ENDIF}
end;

procedure TIPanel.DeletePanel(vguiPanel: VPANEL);
begin
  ThisCall(FThis, @FThis^.DeletePanel, vguiPanel);
end;

procedure TIPanel.GetAbsPos(vguiPanel: VPANEL; var X, Y: Integer);
begin
  ThisCall(FThis, @FThis^.GetAbsPos, vguiPanel, @X, @Y);
end;

function TIPanel.GetChild(vguiPanel: VPANEL; Index: Integer): VPANEL;
begin
  Result := VPANEL(ThisCall(FThis, @FThis^.GetChild, vguiPanel, Index));
end;

function TIPanel.GetChildCount(vguiPanel: VPANEL): Integer;
begin
  Result := Integer(ThisCall(FThis, @FThis^.GetChildCount, vguiPanel));
end;

function TIPanel.GetClassName(vguiPanel: VPANEL): PAnsiChar;
begin
  Result := PAnsiChar(ThisCall(FThis, @FThis^.GetClassName, vguiPanel));
end;

procedure TIPanel.GetClipRect(vguiPanel: VPANEL; out X0, Y0, X1, Y1: Integer);
begin
  ThisCall(FThis, @FThis^.GetClipRect, vguiPanel, @X0, @Y0, @X1, @Y1);
end;

function TIPanel.GetCurrentKeyFocus(vguiPanel: VPANEL): VPANEL;
begin
  Result := VPANEL(ThisCall(FThis, @FThis^.GetCurrentKeyFocus, vguiPanel));
end;

procedure TIPanel.GetInset(vguiPanel: VPANEL; out Left, Top, Right,
  Bottom: Integer);
begin
  ThisCall(FThis, @FThis^.GetInset, vguiPanel, @Left, @Top, @Right, @Bottom);
end;

procedure TIPanel.GetMinimumSize(vguiPanel: VPANEL; out Wide, Tall: Integer);
begin
  ThisCall(FThis, @FThis^.GetMinimumSize, vguiPanel, @Wide, Tall);
end;

function TIPanel.GetModuleName(vguiPanel: VPANEL): PAnsiChar;
begin
{$IFDEF VGUI_USE_PANEL009}
  raise Exception.Create('TIPanel.GetModuleName: Not implemented in VGUI_Panel009.');
{$ELSE}
  Result := PAnsiChar(ThisCall(FThis, @FThis^.GetModuleName, vguiPanel));
{$ENDIF}
end;

function TIPanel.GetName(vguiPanel: VPANEL): PAnsiChar;
begin
  Result := PAnsiChar(ThisCall(FThis, @FThis^.GetName, vguiPanel));
end;

function TIPanel.GetPanel(vguiPanel: VPANEL;
  DestinationModule: PAnsiChar): VGUIPanel;
begin
  Result := PAnsiChar(ThisCall(FThis, @FThis^.GetPanel, vguiPanel, DestinationModule));
end;

function TIPanel.GetParent(vguiPanel: VPANEL): VPANEL;
begin
  Result := VPANEL(ThisCall(FThis, @FThis^.GetParent, vguiPanel));
end;

procedure TIPanel.GetPos(vguiPanel: VPANEL; out X, Y: Integer);
begin
  ThisCall(FThis, @FThis^.GetPos, vguiPanel, @X, @Y);
end;

function TIPanel.GetScheme(vguiPanel: VPANEL): HScheme;
begin
  Result := HScheme(ThisCall(FThis, @FThis^.GetScheme, vguiPanel));
end;

procedure TIPanel.GetSize(vguiPanel: VPANEL; out Wide, Tall: Integer);
begin
  ThisCall(FThis, @FThis^.GetSize, vguiPanel, @Wide, @Tall);
end;

function TIPanel.GetTabPosition(vguiPanel: VPANEL): Integer;
begin
  Result := Integer(ThisCall(FThis, @FThis^.GetTabPosition, vguiPanel));
end;

function TIPanel.GetZPos(vguiPanel: VPANEL): Integer;
begin
  Result := Integer(ThisCall(FThis, @FThis^.GetZPos, vguiPanel));
end;

function TIPanel.HasParent(vguiPanel, PotentialParent: VPANEL): Boolean;
begin
  Result := Boolean(ThisCall(FThis, @FThis^.HasParent, vguiPanel, PotentialParent));
end;

procedure TIPanel.Init(vguiPanel: VPANEL; Panel: IClientPanel);
begin
  ThisCall(FThis, @FThis^.Init, vguiPanel, Panel);
end;

procedure TIPanel.InternalFocusChanged(vguiPanel: VPANEL; Lost: Boolean);
begin
  ThisCall(FThis, @FThis^.InternalFocusChanged, vguiPanel, Lost);
end;

function TIPanel.IsAutoDeleteSet(vguiPanel: VPANEL): Boolean;
begin
  Result := Boolean(ThisCall(FThis, @FThis^.IsAutoDeleteSet, vguiPanel));
end;

function TIPanel.IsEnabled(vguiPanel: VPANEL): Boolean;
begin
  Result := Boolean(ThisCall(FThis, @FThis^.IsEnabled, vguiPanel));
end;

function TIPanel.IsKeyBoardInputEnabled(vguiPanel: VPANEL): Boolean;
begin
  Result := Boolean(ThisCall(FThis, @FThis^.IsKeyBoardInputEnabled, vguiPanel));
end;

function TIPanel.IsMouseInputEnabled(vguiPanel: VPANEL): Boolean;
begin
  Result := Boolean(ThisCall(FThis, @FThis^.IsMouseInputEnabled, vguiPanel));
end;

function TIPanel.IsPopup(vguiPanel: VPANEL): Boolean;
begin
  Result := Boolean(ThisCall(FThis, @FThis^.IsPopup, vguiPanel));
end;

function TIPanel.IsProportional(vguiPanel: VPANEL): Boolean;
begin
  Result := Boolean(ThisCall(FThis, @FThis^.IsProportional, vguiPanel));
end;

function TIPanel.IsVisible(vguiPanel: VPANEL): Boolean;
begin
  Result := Boolean(ThisCall(FThis, @FThis^.IsVisible, vguiPanel));
end;

function TIPanel.IsWithinTraverse(vguiPanel: VPANEL; X, Y: Integer;
  TraversePopups: Boolean): VPANEL;
begin
  Result := VPANEL(ThisCall(FThis, @FThis^.IsWithinTraverse, vguiPanel, X, Y, TraversePopups));
end;

procedure TIPanel.MoveToBack(vguiPanel: VPANEL);
begin
  ThisCall(FThis, @FThis^.IsWithinTraverse, vguiPanel);
end;

procedure TIPanel.MoveToFront(vguiPanel: VPANEL);
begin
  ThisCall(FThis, @FThis^.MoveToFront, vguiPanel);
end;

procedure TIPanel.OnChildAdded(vguiPanel, Child: VPANEL);
begin
  ThisCall(FThis, @FThis^.MoveToFront, vguiPanel, Child);
end;

procedure TIPanel.OnSizeChanged(vguiPanel: VPANEL; NewWide, NewTall: Integer);
begin
  ThisCall(FThis, @FThis^.MoveToFront, vguiPanel, NewWide, NewTall);
end;

procedure TIPanel.PaintTraverse(vguiPanel: VPANEL; ForceRepaint,
  AllowForce: Boolean);
begin
  ThisCall(FThis, @FThis^.PaintTraverse, vguiPanel, ForceRepaint, AllowForce);
end;

procedure TIPanel.PerformApplySchemeSettings(vguiPanel: VPANEL);
begin
  ThisCall(FThis, @FThis^.PerformApplySchemeSettings, vguiPanel);
end;

function TIPanel.Plat(vguiPanel: VPANEL): SurfacePlat;
begin
  Result := SurfacePlat(ThisCall(FThis, @FThis^.Plat, vguiPanel));
end;

function TIPanel.Render_GetPopupVisible(vguiPanel: VPANEL): Boolean;
begin
{$IFDEF VGUI_USE_PANEL009}
  raise Exception.Create('TIPanel.Render_GetPopupVisible: Not implemented in VGUI_Panel009.');
{$ELSE}
  Result := Boolean(ThisCall(FThis, @FThis^.Render_GetPopupVisible, vguiPanel));
{$ENDIF}
end;

procedure TIPanel.Render_SetPopupVisible(vguiPanel: VPANEL; State: Boolean);
begin
{$IFDEF VGUI_USE_PANEL009}
  raise Exception.Create('TIPanel.Render_SetPopupVisible: Not implemented in VGUI_Panel009.');
{$ELSE}
  ThisCall(FThis, @FThis^.Render_SetPopupVisible, vguiPanel, State);
{$ENDIF}
end;

procedure TIPanel.Repaint(vguiPanel: VPANEL);
begin
  ThisCall(FThis, @FThis^.Repaint, vguiPanel);
end;

procedure TIPanel.RequestFocus(vguiPanel: VPANEL; Direction: Integer);
begin
  ThisCall(FThis, @FThis^.RequestFocus, vguiPanel, Direction);
end;

function TIPanel.RequestFocusNext(vguiPanel, ExistingPanel: VPANEL): Boolean;
begin
  Result := Boolean(ThisCall(FThis, @FThis^.RequestFocusNext, vguiPanel, ExistingPanel));
end;

function TIPanel.RequestFocusPrev(vguiPanel, ExistingPanel: VPANEL): Boolean;
begin
  Result := Boolean(ThisCall(FThis, @FThis^.RequestFocusPrev, vguiPanel, ExistingPanel));
end;

function TIPanel.RequestInfo(vguiPanel: VPANEL;
  OutputData: PKeyValues): Boolean;
begin
  Result := Boolean(ThisCall(FThis, @FThis^.RequestInfo, vguiPanel, OutputData));
end;

procedure TIPanel.SendMessage(vguiPanel: VPANEL; Params: PKeyValues;
  FromPanel: VPANEL);
begin
  ThisCall(FThis, @FThis^.SendMessage, vguiPanel, Params, FromPanel);
end;

procedure TIPanel.SetEnabled(vguiPanel: VPANEL; State: Boolean);
begin
  ThisCall(FThis, @FThis^.SetEnabled, vguiPanel, State);
end;

procedure TIPanel.SetInset(vguiPanel: VPANEL; Left, Top, Right,
  Bottom: Integer);
begin
  ThisCall(FThis, @FThis^.SetInset, vguiPanel, Left, Top, Right, Bottom);
end;

procedure TIPanel.SetKeyBoardInputEnabled(vguiPanel: VPANEL; State: Boolean);
begin
  ThisCall(FThis, @FThis^.SetKeyBoardInputEnabled, vguiPanel);
end;

procedure TIPanel.SetMinimumSize(vguiPanel: VPANEL; Wide, Tall: Integer);
begin
  ThisCall(FThis, @FThis^.SetMinimumSize, vguiPanel, Wide, Tall);
end;

procedure TIPanel.SetMouseInputEnabled(vguiPanel: VPANEL; State: Boolean);
begin
  ThisCall(FThis, @FThis^.SetMouseInputEnabled, vguiPanel, State);
end;

procedure TIPanel.SetParent(vguiPanel, newParent: VPANEL);
begin
  ThisCall(FThis, @FThis^.SetParent, vguiPanel, newParent);
end;

procedure TIPanel.SetPlat(vguiPanel: VPANEL; Plat: SurfacePlat);
begin
  ThisCall(FThis, @FThis^.SetPlat, vguiPanel, Plat);
end;

procedure TIPanel.SetPopup(vguiPanel: VPANEL; State: Boolean);
begin
  ThisCall(FThis, @FThis^.SetPopup, vguiPanel, State);
end;

procedure TIPanel.SetPos(vguiPanel: VPANEL; X, Y: Integer);
begin
  ThisCall(FThis, @FThis^.SetPos, vguiPanel, X, Y);
end;

procedure TIPanel.SetSize(vguiPanel: VPANEL; Wide, Tall: Integer);
begin
  ThisCall(FThis, @FThis^.SetSize, vguiPanel, Wide, Tall);
end;

procedure TIPanel.SetVisible(vguiPanel: VPANEL; State: Boolean);
begin
  ThisCall(FThis, @FThis^.SetVisible, vguiPanel, State);
end;

procedure TIPanel.SetZPos(vguiPanel: VPANEL; Z: Integer);
begin
  ThisCall(FThis, @FThis^.SetZPos, vguiPanel, Z);
end;

procedure TIPanel.Solve(vguiPanel: VPANEL);
begin
  ThisCall(FThis, @FThis^.Solve, vguiPanel);
end;

procedure TIPanel.Think(vguiPanel: VPANEL);
begin
  ThisCall(FThis, @FThis^.Think, vguiPanel);
end;

{ TPanel }

constructor TPanel.Create(Panel: Pointer);
begin
  inherited Create;

  FThis := Panel;
end;

procedure TPanel.DeletePanel;
begin
  ThisCall(FThis, @FThis^.DeletePanel);
end;

function TPanel.GetClassName: PAnsiChar;
begin
  Result := ThisCall(FThis, @FThis^.GetClassName);
end;

procedure TPanel.GetClipRect(out X0, Y0, X1, Y1: Integer);
begin
  ThisCall(FThis, @FThis^.GetClipRect, X0, Y0, X1, Y1);
end;

function TPanel.GetCurrentKeyFocus: VPANEL;
begin
  Result := VPANEL(ThisCall(FThis, @FThis^.GetCurrentKeyFocus));
end;

procedure TPanel.GetInset(out Top, Left, Right, Bottom: Integer);
begin
  ThisCall(FThis, @FThis^.GetInset, Top, Left, Right, Bottom);
end;

function TPanel.GetModuleName: PAnsiChar;
begin
  Result := ThisCall(FThis, @FThis^.GetModuleName);
end;

function TPanel.GetName: PAnsiChar;
begin
  Result := ThisCall(FThis, @FThis^.GetName);
end;

function TPanel.GetPanel: VGUIPanel;
begin
  Result := ThisCall(FThis, @FThis^.GetPanel);
end;

function TPanel.GetScheme: HScheme;
begin
  Result := HScheme(ThisCall(FThis, @FThis^.GetScheme));
end;

function TPanel.GetTabPosition: Integer;
begin
  Result := Integer(ThisCall(FThis, @FThis^.GetTabPosition));
end;

function TPanel.GetVPanel: VPANEL;
begin
  Result := VPANEL(ThisCall(FThis, @FThis^.GetVPanel));
end;

procedure TPanel.InternalFocusChanged(Lost: Boolean);
begin
  ThisCall(FThis, @FThis^.InternalFocusChanged, Lost);
end;

function TPanel.IsAutoDeleteSet: Boolean;
begin
  Result := Boolean(ThisCall(FThis, @FThis^.IsAutoDeleteSet));
end;

function TPanel.IsProportional: Boolean;
begin
  Result := Boolean(ThisCall(FThis, @FThis^.IsProportional));
end;

function TPanel.IsWithinTraverse(X, Y: Integer;
  TraversePopups: Boolean): VPANEL;
begin
  Result := VPANEL(ThisCall(FThis, @FThis^.IsWithinTraverse, X, Y, TraversePopups));
end;

procedure TPanel.OnChildAdded(Child: VPANEL);
begin
  ThisCall(FThis, @FThis^.OnChildAdded, Child);
end;

procedure TPanel.OnMessage(Params: PKeyValues; FromPanel: VPANEL);
begin
  ThisCall(FThis, @FThis^.OnMessage, Params, FromPanel);
end;

procedure TPanel.OnSizeChanged(NewWide, NewTall: Integer);
begin
  ThisCall(FThis, @FThis^.OnSizeChanged, NewWide, NewTall);
end;

procedure TPanel.PaintTraverse(ForceRepaint, AllowForce: Boolean);
begin
  ThisCall(FThis, @FThis^.PaintTraverse, ForceRepaint, AllowForce);
end;

procedure TPanel.PerformApplySchemeSettings;
begin
  ThisCall(FThis, @FThis^.PerformApplySchemeSettings);
end;

function TPanel.QueryInterface(ID: EInterfaceID): Pointer;
begin
  Result := ThisCall(FThis, @FThis^.QueryInterface, ID);
end;

procedure TPanel.Repaint;
begin
  ThisCall(FThis, @FThis^.Repaint);
end;

procedure TPanel.RequestFocus(Direction: Integer);
begin
  ThisCall(FThis, @FThis^.RequestFocus, Direction);
end;

function TPanel.RequestFocusNext(ExistingPanel: VPANEL): Boolean;
begin
  Result := Boolean(ThisCall(FThis, @FThis^.RequestFocusNext, ExistingPanel));
end;

function TPanel.RequestFocusPrev(ExistingPanel: VPANEL): Boolean;
begin
  Result := Boolean(ThisCall(FThis, @FThis^.RequestFocusPrev, ExistingPanel));
end;

function TPanel.RequestInfo(OutputData: PKeyValues): Boolean;
begin
  Result := Boolean(ThisCall(FThis, @FThis^.RequestInfo, OutputData));
end;

procedure TPanel.Think;
begin
  ThisCall(FThis, @FThis^.Think);
end;

class function SDK_Color.Create(R, G, B, A: Byte): SDK_Color;
begin
  Result.R := R;
  Result.G := G;
  Result.B := B;
  Result.A := A;
end;

end.

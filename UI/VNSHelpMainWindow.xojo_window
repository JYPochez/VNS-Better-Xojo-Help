#tag DesktopWindow
Begin DesktopWindow VNSHelpMainWindow
   Backdrop        =   0
   BackgroundColor =   &cFFFFFF
   Composite       =   False
   DefaultLocation =   2
   FullScreen      =   False
   HasBackgroundColor=   False
   HasCloseButton  =   True
   HasFullScreenButton=   True
   HasMaximizeButton=   True
   HasMinimizeButton=   True
   HasTitleBar     =   True
   Height          =   620
   ImplicitInstance=   True
   MacProcID       =   0
   MaximumHeight   =   32000
   MaximumWidth    =   32000
   MenuBar         =   1888573439
   MenuBarVisible  =   True
   MinimumHeight   =   380
   MinimumWidth    =   560
   Resizeable      =   True
   Title           =   "Better Xojo Help"
   Type            =   0
   Visible         =   True
   Width           =   900
   Begin DesktopPopupMenu VersionPopup
      AllowAutoDeactivate=   True
      Enabled         =   True
      Height          =   24
      Index           =   -2147483648
      Left            =   12
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      Scope           =   0
      TabPanelIndex   =   0
      Tooltip         =   ""
      Top             =   12
      Transparent     =   False
      Visible         =   True
      Width           =   200
      InitialValue    =   ""
   End
   Begin DesktopButton BtnBack
      AllowAutoDeactivate=   True
      Bold            =   False
      Cancel          =   False
      Caption         =   "◀"
      Default         =   False
      Enabled         =   False
      Height          =   24
      Index           =   -2147483648
      Left            =   220
      LockBottom      =   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      MacButtonStyle  =   0
      Scope           =   0
      TabIndex        =   1
      TabPanelIndex   =   0
      Top             =   12
      Transparent     =   False
      Visible         =   True
      Width           =   34
   End
   Begin DesktopButton BtnForward
      AllowAutoDeactivate=   True
      Bold            =   False
      Cancel          =   False
      Caption         =   "▶"
      Default         =   False
      Enabled         =   False
      Height          =   24
      Index           =   -2147483648
      Left            =   256
      LockBottom      =   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      MacButtonStyle  =   0
      Scope           =   0
      TabIndex        =   2
      TabPanelIndex   =   0
      Top             =   12
      Transparent     =   False
      Visible         =   True
      Width           =   34
   End
   Begin DesktopPopupMenu FavoritesPopup
      AllowAutoDeactivate=   True
      Enabled         =   True
      Height          =   24
      Index           =   -2147483648
      Left            =   746
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   False
      LockRight       =   True
      LockTop         =   True
      Scope           =   0
      TabIndex        =   7
      TabPanelIndex   =   0
      Tooltip         =   ""
      Top             =   12
      Transparent     =   False
      Visible         =   True
      Width           =   150
      InitialValue    =   ""
   End
   Begin DesktopButton BtnWeb
      AllowAutoDeactivate=   True
      Bold            =   False
      Cancel          =   False
      Caption         =   "🌐"
      Default         =   False
      Enabled         =   False
      Height          =   24
      Index           =   -2147483648
      Left            =   906
      LockBottom      =   False
      LockLeft        =   False
      LockRight       =   True
      LockTop         =   True
      MacButtonStyle  =   0
      Scope           =   0
      TabIndex        =   8
      TabPanelIndex   =   0
      Top             =   12
      Transparent     =   False
      Visible         =   True
      Width           =   34
   End
   Begin DesktopPopupMenu MatchPopup
      AllowAutoDeactivate=   True
      Enabled         =   True
      Height          =   24
      Index           =   -2147483648
      Left            =   298
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      Scope           =   0
      TabIndex        =   9
      TabPanelIndex   =   0
      Tooltip         =   ""
      Top             =   12
      Transparent     =   False
      Visible         =   True
      Width           =   90
      InitialValue    =   ""
   End
   Begin DesktopSearchField SearchField
      AllowAutoDeactivate=   True
      AllowFocusRing  =   True
      AllowSpellChecking=   False
      Bold            =   False
      Enabled         =   True
      FontSize        =   0.0
      Height          =   24
      Index           =   -2147483648
      Left            =   298
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      Scope           =   0
      TabIndex        =   3
      TabPanelIndex   =   0
      TabStop         =   True
      Text            =   ""
      Tooltip         =   ""
      Top             =   12
      Transparent     =   False
      Visible         =   True
      Width           =   590
   End
   Begin DesktopLabel ResultCount
      AllowAutoDeactivate=   True
      Bold            =   False
      Enabled         =   True
      FontSize        =   11.0
      Height          =   16
      Index           =   -2147483648
      Left            =   12
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      Multiline       =   False
      Scope           =   0
      Selectable      =   False
      TabIndex        =   10
      TabPanelIndex   =   0
      Text            =   ""
      TextAlignment   =   0
      TextColor       =   &c606060
      Top             =   48
      Transparent     =   False
      Visible         =   False
      Width           =   260
   End
   Begin DesktopCanvas PlatformTypesFrame
      AllowAutoDeactivate=   True
      AllowFocus      =   False
      AllowFocusRing  =   False
      AllowTabs       =   False
      Backdrop        =   0
      Enabled         =   True
      Height          =   26
      Index           =   -2147483648
      Left            =   8
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      Scope           =   0
      TabIndex        =   18
      TabPanelIndex   =   0
      Tooltip         =   ""
      Top             =   39
      Transparent     =   False
      Visible         =   True
      Width           =   200
   End
   Begin DesktopCanvas PlatformSystemsFrame
      AllowAutoDeactivate=   True
      AllowFocus      =   False
      AllowFocusRing  =   False
      AllowTabs       =   False
      Backdrop        =   0
      Enabled         =   True
      Height          =   26
      Index           =   -2147483648
      Left            =   214
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      Scope           =   0
      TabIndex        =   19
      TabPanelIndex   =   0
      Tooltip         =   ""
      Top             =   39
      Transparent     =   False
      Visible         =   True
      Width           =   340
   End
   Begin DesktopCheckBox PlatformDesktop
      AllowAutoDeactivate=   True
      Bold            =   False
      Caption         =   "Desktop"
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   11.0
      FontUnit        =   0
      Height          =   20
      Index           =   -2147483648
      Italic          =   False
      Left            =   12
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      Scope           =   0
      TabIndex        =   20
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   42
      Transparent     =   False
      Underline       =   False
      Value           =   True
      VisualState     =   0
      Visible         =   True
      Width           =   70
   End
   Begin DesktopCheckBox PlatformWeb
      AllowAutoDeactivate=   True
      Bold            =   False
      Caption         =   "Web"
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   11.0
      FontUnit        =   0
      Height          =   20
      Index           =   -2147483648
      Italic          =   False
      Left            =   86
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      Scope           =   0
      TabIndex        =   21
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   42
      Transparent     =   False
      Underline       =   False
      Value           =   True
      VisualState     =   0
      Visible         =   True
      Width           =   50
   End
   Begin DesktopCheckBox PlatformIOS
      AllowAutoDeactivate=   True
      Bold            =   False
      Caption         =   "iOS"
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   11.0
      FontUnit        =   0
      Height          =   20
      Index           =   -2147483648
      Italic          =   False
      Left            =   140
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      Scope           =   0
      TabIndex        =   22
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   42
      Transparent     =   False
      Underline       =   False
      Value           =   True
      VisualState     =   0
      Visible         =   True
      Width           =   46
   End
   Begin DesktopCheckBox PlatformAndroid
      AllowAutoDeactivate=   True
      Bold            =   False
      Caption         =   "Android"
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   11.0
      FontUnit        =   0
      Height          =   20
      Index           =   -2147483648
      Italic          =   False
      Left            =   190
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      Scope           =   0
      TabIndex        =   23
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   42
      Transparent     =   False
      Underline       =   False
      Value           =   True
      VisualState     =   0
      Visible         =   True
      Width           =   72
   End
   Begin DesktopCheckBox PlatformMacOS
      AllowAutoDeactivate=   True
      Bold            =   False
      Caption         =   "macOS"
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   11.0
      FontUnit        =   0
      Height          =   20
      Index           =   -2147483648
      Italic          =   False
      Left            =   266
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      Scope           =   0
      TabIndex        =   24
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   42
      Transparent     =   False
      Underline       =   False
      Value           =   True
      VisualState     =   0
      Visible         =   True
      Width           =   60
   End
   Begin DesktopCheckBox PlatformWindows
      AllowAutoDeactivate=   True
      Bold            =   False
      Caption         =   "Windows"
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   11.0
      FontUnit        =   0
      Height          =   20
      Index           =   -2147483648
      Italic          =   False
      Left            =   330
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      Scope           =   0
      TabIndex        =   25
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   42
      Transparent     =   False
      Underline       =   False
      Value           =   True
      VisualState     =   0
      Visible         =   True
      Width           =   74
   End
   Begin DesktopCheckBox PlatformLinux
      AllowAutoDeactivate=   True
      Bold            =   False
      Caption         =   "Linux"
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   11.0
      FontUnit        =   0
      Height          =   20
      Index           =   -2147483648
      Italic          =   False
      Left            =   408
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      Scope           =   0
      TabIndex        =   26
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   42
      Transparent     =   False
      Underline       =   False
      Value           =   True
      VisualState     =   0
      Visible         =   True
      Width           =   56
   End
   Begin DesktopCheckBox PlatformMobile
      AllowAutoDeactivate=   True
      Bold            =   False
      Caption         =   "Mobile"
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   11.0
      FontUnit        =   0
      Height          =   20
      Index           =   -2147483648
      Italic          =   False
      Left            =   136
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      Scope           =   0
      TabIndex        =   27
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   42
      Transparent     =   False
      Underline       =   False
      Value           =   True
      VisualState     =   0
      Visible         =   True
      Width           =   64
   End
   Begin DesktopListBox TopicList
      AllowAutoDeactivate=   True
      AllowAutoHideScrollbars=   True
      AllowExpandableRows=   True
      AllowFocusRing  =   False
      AllowResizableColumns=   False
      AllowRowDragging=   False
      AllowRowReordering=   False
      Bold            =   False
      ColumnCount     =   1
      ColumnWidths    =   ""
      DefaultRowHeight=   -1
      DropIndicatorVisible=   False
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      GridLineStyle   =   0
      HasBorder       =   True
      HasHeader       =   False
      HasHorizontalScrollbar=   False
      HasVerticalScrollbar=   True
      HeadingIndex    =   -1
      Height          =   560
      Index           =   -2147483648
      InitialParent   =   ""
      InitialValue    =   ""
      Italic          =   False
      Left            =   12
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      RequiresSelection=   False
      RowSelectionType=   0
      Scope           =   0
      TabIndex        =   4
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   48
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   260
      _ScrollOffset   =   0
      _ScrollWidth    =   -1
   End
   Begin DesktopCanvas Divider
      AcceptFocus     =   "False"
      AcceptTabs      =   "False"
      AllowAutoDeactivate=   True
      AllowFocus      =   False
      AllowFocusRing  =   False
      AllowTabs       =   False
      Backdrop        =   0
      DoubleBuffer    =   "False"
      Enabled         =   True
      EraseBackground =   "True"
      Height          =   560
      Index           =   -2147483648
      InitialParent   =   ""
      Left            =   272
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      Scope           =   0
      TabIndex        =   5
      TabPanelIndex   =   0
      TabStop         =   False
      Tooltip         =   ""
      Top             =   48
      Transparent     =   False
      UseFocusRing    =   "False"
      Visible         =   True
      Width           =   6
   End
   Begin DesktopCanvas TabBar
      AcceptFocus     =   "False"
      AcceptTabs      =   "False"
      AllowAutoDeactivate=   True
      AllowFocus      =   False
      AllowFocusRing  =   False
      AllowTabs       =   False
      Backdrop        =   0
      DoubleBuffer    =   "False"
      Enabled         =   True
      EraseBackground =   "True"
      Height          =   26
      Index           =   -2147483648
      InitialParent   =   ""
      Left            =   278
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      Scope           =   0
      TabIndex        =   11
      TabPanelIndex   =   0
      TabStop         =   False
      Tooltip         =   ""
      Top             =   48
      Transparent     =   False
      UseFocusRing    =   "False"
      Visible         =   False
      Width           =   610
   End
   Begin DesktopHTMLViewer HelpViewer
      AllowAutoDeactivate=   True
      Enabled         =   True
      Height          =   560
      Index           =   -2147483648
      InitialParent   =   ""
      Left            =   278
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      Scope           =   0
      TabIndex        =   6
      TabPanelIndex   =   0
      Tooltip         =   ""
      Top             =   48
      Visible         =   True
      Width           =   610
   End
End
#tag EndDesktopWindow

#tag WindowCode
	#tag Event
		Sub Opening()
		  // Find the installed documentation sets and lay the panes out. The topic
		  // tree and the viewer stay empty until a doc-set provider exists.
		  Self.Title = kWindowTitle
		  SearchField.Hint = kSearchHint
		  // The recent-searches dropdown is a macOS affordance; the field itself
		  // works everywhere, so this is set unconditionally and simply has no
		  // effect on Windows and Linux.
		  SearchField.AllowRecentItems = True
		  SearchField.MaximumRecentItems = kMaximumRecentSearches

		  VNSHelpPreferences.Load
		  RestoreWindowBounds

		  mDividerX = VNSHelpPreferences.DividerX
		  If mDividerX <= 0 Then mDividerX = kDefaultDividerX

		  // Before LoadVersions, so the doc set it builds is created with the filter
		  // already in place rather than searched once unfiltered and then corrected.
		  ApplyPlatformChecks(VNSHelpPreferences.PlatformFilter)

		  LoadVersions
		  Layout
		End Sub
	#tag EndEvent

	#tag Event
		Sub Resized()
		  Layout
		End Sub
	#tag EndEvent

	#tag Event
		Sub Resizing()
		  // Re-lay-out live during the drag so the viewer grows in place instead of
		  // drifting until mouse-up.
		  Layout
		End Sub
	#tag EndEvent

	#tag Event
		Sub Closing()
		  Timer.CancelCallLater(AddressOf RunPendingSearch)

		  // Capture the layout on the way out so the next launch reopens where the
		  // user left off.
		  VNSHelpPreferences.RememberWindow(New Rect(Self.Left, Self.Top, Self.Width, Self.Height))
		  VNSHelpPreferences.DividerX = mDividerX

		  Var v As VNSHelpVersion = SelectedVersion
		  If v <> Nil Then VNSHelpPreferences.LastVersion = v.DisplayName
		  VNSHelpPreferences.LastPageKey = mCurrentPageKey

		  VNSHelpPreferences.Save
		End Sub
	#tag EndEvent

	#tag MenuHandler
		Function FileNewTab() As Boolean Handles FileNewTab.Action
		  NewEmptyTab

		  Return True
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function FileCloseTab() As Boolean Handles FileCloseTab.Action
		  // No-ops on the last tab rather than refusing loudly.
		  CloseTab(mActiveTab)

		  Return True
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function NavigateBack() As Boolean Handles NavigateBack.Action
		  // Each handler carries the item's own name, which is the form the IDE writes
		  // and the only one proven to bind here. An earlier Handle<Item> naming, added
		  // so that MenuBarSelected could write NavigateBack.Enabled without it
		  // resolving to the method, left Cmd+D and Cmd+[ doing nothing at all.
		  //
		  // So there is no MenuBarSelected. AutoEnable = True enables these, and each
		  // handler no-ops when it does not apply — GoToHistory bounds-checks, the other
		  // two check what they need. The toolbar buttons still grey out, and the
		  // favorites popup still reads Add or Remove, so the state stays visible.
		  GoToHistory(mHistoryPosition - 1)
		  Return True
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function NavigateForward() As Boolean Handles NavigateForward.Action
		  GoToHistory(mHistoryPosition + 1)
		  Return True
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function NavigateFavorite() As Boolean Handles NavigateFavorite.Action
		  ToggleCurrentFavorite
		  Return True
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function NavigateWeb() As Boolean Handles NavigateWeb.Action
		  OpenCurrentPageOnTheWeb
		  Return True
		End Function
	#tag EndMenuHandler

	#tag Method, Flags = &h0
		Sub ReapplySettings()
		  // Called by the settings window when something it changed affects what is on
		  // screen. Public for that reason alone.
		  If mDocSet = Nil Then Return

		  mDocSet.DeprecatedLast = VNSHelpPreferences.DeprecatedLast
		  mDocSet.PlatformFilter = VNSHelpPreferences.PlatformFilter

		  // Re-run whatever is in the field so the new ordering is visible at once.
		  If SearchField.Text.Trim <> "" Then
		    Timer.CancelCallLater(AddressOf RunPendingSearch)
		    ApplySearch(SearchField.Text)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BuildGroupMenu(base As DesktopMenuItem) As Boolean
		  // Same two commands for either frame; which group they act on comes from
		  // the canvas whose event called this, not from the menu.
		  If base = Nil Then Return False

		  // Tag set on its own line rather than through a two-argument constructor:
		  // the installed docs only show DesktopMenuItem(text), so this is the form
		  // that is certain to exist.
		  Var checkAll As New DesktopMenuItem(kMenuCheckAll)
		  checkAll.Tag = kTagCheckAll
		  base.AddMenu(checkAll)

		  Var checkNone As New DesktopMenuItem(kMenuCheckNone)
		  checkNone.Tag = kTagCheckNone
		  base.AddMenu(checkNone)

		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ApplyGroupCommand(selectedItem As DesktopMenuItem, groupMask As Integer) As Boolean
		  // Set or clear every bit of one axis, leaving the other axis alone.
		  //
		  // Clearing an axis entirely is allowed and means "stop filtering on this
		  // axis" — MatchesPlatform reads an axis with nothing ticked as unfiltered.
		  // So Check None is a reset for that group rather than a way to empty the
		  // results, which is the behaviour the row already had.
		  If selectedItem = Nil Then Return False

		  Var current As Integer = PlatformFilterFromChecks()
		  Var updated As Integer

		  Select Case selectedItem.Tag.StringValue
		  Case kTagCheckAll
		    updated = Bitwise.BitOr(current, groupMask)
		  Case kTagCheckNone
		    updated = Bitwise.BitAnd(current, Bitwise.BitXor(VNSHelpDocSet.kPlatformAll, groupMask))
		  Else
		    Return False
		  End Select

		  ApplyPlatformChecks(updated)
		  PlatformFilterChanged

		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub FrameGroup(frame As DesktopCanvas, startX As Integer, endX As Integer, top As Integer)
		  // Inset behind the boxes it encloses, so the outline clears the captions.
		  frame.Left = startX - kFramePadding
		  frame.Top = top - kFrameInset
		  frame.Width = endX - startX + kFramePadding * 2
		  frame.Height = kCheckHeight + kFrameInset * 2
		  frame.Refresh
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub LayoutPlatformRow(m As Integer)
		  // Seven checkboxes on one row, in the two groups the data actually has:
		  // project types first, then the operating systems, separated by a wider gap
		  // so the distinction reads without a label. See docs/PLATFORM_DATA.md.
		  Var x As Integer = m
		  Var top As Integer = kPlatformRowTop

		  Var typesStart As Integer = x
		  x = PlaceCheck(PlatformDesktop, x, top, kCheckDesktopWidth) + kCheckGap
		  x = PlaceCheck(PlatformWeb, x, top, kCheckWebWidth) + kCheckGap
		  Var typesEnd As Integer = PlaceCheck(PlatformMobile, x, top, kCheckMobileWidth)
		  x = typesEnd + kCheckGroupGap

		  Var systemsStart As Integer = x
		  x = PlaceCheck(PlatformMacOS, x, top, kCheckMacOSWidth) + kCheckGap
		  x = PlaceCheck(PlatformWindows, x, top, kCheckWindowsWidth) + kCheckGap
		  x = PlaceCheck(PlatformLinux, x, top, kCheckLinuxWidth) + kCheckGap
		  x = PlaceCheck(PlatformIOS, x, top, kCheckIOSWidth) + kCheckGap
		  Var systemsEnd As Integer = PlaceCheck(PlatformAndroid, x, top, kCheckAndroidWidth)

		  // A frame around each group says "these two sets mean different things"
		  // without spending a row on two labels.
		  FrameGroup(PlatformTypesFrame, typesStart, typesEnd, top)
		  FrameGroup(PlatformSystemsFrame, systemsStart, systemsEnd, top)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PlaceCheck(box As DesktopCheckBox, x As Integer, top As Integer, width As Integer) As Integer
		  // Returns the right edge, so the caller reads as a run of positions rather
		  // than as arithmetic repeated seven times.
		  box.Left = x
		  box.Top = top
		  box.Width = width
		  box.Height = kCheckHeight

		  Return x + width
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PlatformFilterFromChecks() As Integer
		  // All seven off would hide every labelled page and leave only the unlabelled
		  // ones, which reads as a broken app rather than as a filter. Treat it as no
		  // filter instead — the same thing all seven on means.
		  Var mask As Integer = 0
		  If PlatformDesktop.Value Then mask = mask + Integer(VNSHelpDocSet.ePlatform.Desktop)
		  If PlatformWeb.Value Then mask = mask + Integer(VNSHelpDocSet.ePlatform.Web)
		  If PlatformMobile.Value Then mask = mask + Integer(VNSHelpDocSet.ePlatform.Mobile)
		  If PlatformIOS.Value Then mask = mask + Integer(VNSHelpDocSet.ePlatform.iOS)
		  If PlatformAndroid.Value Then mask = mask + Integer(VNSHelpDocSet.ePlatform.Android)
		  If PlatformMacOS.Value Then mask = mask + Integer(VNSHelpDocSet.ePlatform.macOS)
		  If PlatformWindows.Value Then mask = mask + Integer(VNSHelpDocSet.ePlatform.Windows)
		  If PlatformLinux.Value Then mask = mask + Integer(VNSHelpDocSet.ePlatform.Linux)

		  If mask = 0 Then Return VNSHelpDocSet.kPlatformAll

		  Return mask
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ApplyPlatformChecks(mask As Integer)
		  // Push a stored mask back into the boxes. mSuppressPlatformChange keeps the
		  // seven resulting Value changes from each re-running the search.
		  mSuppressPlatformChange = True

		  PlatformDesktop.Value = Bitwise.BitAnd(mask, Integer(VNSHelpDocSet.ePlatform.Desktop)) <> 0
		  PlatformWeb.Value = Bitwise.BitAnd(mask, Integer(VNSHelpDocSet.ePlatform.Web)) <> 0
		  PlatformMobile.Value = Bitwise.BitAnd(mask, Integer(VNSHelpDocSet.ePlatform.Mobile)) <> 0
		  PlatformIOS.Value = Bitwise.BitAnd(mask, Integer(VNSHelpDocSet.ePlatform.iOS)) <> 0
		  PlatformAndroid.Value = Bitwise.BitAnd(mask, Integer(VNSHelpDocSet.ePlatform.Android)) <> 0
		  PlatformMacOS.Value = Bitwise.BitAnd(mask, Integer(VNSHelpDocSet.ePlatform.macOS)) <> 0
		  PlatformWindows.Value = Bitwise.BitAnd(mask, Integer(VNSHelpDocSet.ePlatform.Windows)) <> 0
		  PlatformLinux.Value = Bitwise.BitAnd(mask, Integer(VNSHelpDocSet.ePlatform.Linux)) <> 0

		  mSuppressPlatformChange = False
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub PlatformFilterChanged()
		  // One handler for all seven boxes: recompute, remember, push to the provider,
		  // then redo the search so the list answers immediately.
		  If mSuppressPlatformChange Then Return

		  Var mask As Integer = PlatformFilterFromChecks()
		  VNSHelpPreferences.PlatformFilter = mask
		  If mDocSet <> Nil Then mDocSet.PlatformFilter = mask

		  RunPendingSearch
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Layout()
		  // Toolbar row across the top, then the TOC and the viewer split at
		  // mDividerX (clamped here so neither pane can be squeezed away).
		  Var m As Integer = kMargin
		  Var w As Integer = Self.Width
		  Var h As Integer = Self.Height

		  Var minDiv As Integer = m + kMinListWidth
		  Var maxDiv As Integer = w - kMinViewerWidth - kDividerWidth - m
		  If maxDiv < minDiv Then maxDiv = minDiv
		  If mDividerX < minDiv Then mDividerX = minDiv
		  If mDividerX > maxDiv Then mDividerX = maxDiv

		  Var x As Integer = m

		  VersionPopup.Left = x
		  VersionPopup.Top = m
		  VersionPopup.Width = kVersionWidth
		  VersionPopup.Height = kToolbarHeight
		  x = x + kVersionWidth + kGap

		  BtnBack.Left = x
		  BtnBack.Top = m
		  BtnBack.Width = kNavButtonWidth
		  BtnBack.Height = kToolbarHeight
		  x = x + kNavButtonWidth + kNavGap

		  BtnForward.Left = x
		  BtnForward.Top = m
		  BtnForward.Width = kNavButtonWidth
		  BtnForward.Height = kToolbarHeight
		  x = x + kNavButtonWidth + kGap

		  // The match mode sits immediately left of the field it applies to.
		  MatchPopup.Left = x
		  MatchPopup.Top = m
		  MatchPopup.Width = kMatchPopupWidth
		  MatchPopup.Height = kToolbarHeight
		  x = x + kMatchPopupWidth + kGap

		  // The globe sits hard right, as it does in the IDE's own help window.
		  BtnWeb.Top = m
		  BtnWeb.Width = kNavButtonWidth
		  BtnWeb.Height = kToolbarHeight
		  BtnWeb.Left = w - m - kNavButtonWidth

		  FavoritesPopup.Top = m
		  FavoritesPopup.Width = kFavoritesPopupWidth
		  FavoritesPopup.Height = kToolbarHeight
		  FavoritesPopup.Left = BtnWeb.Left - kGap - kFavoritesPopupWidth

		  SearchField.Left = x
		  SearchField.Top = m
		  SearchField.Height = kToolbarHeight
		  Var searchWidth As Integer = FavoritesPopup.Left - kGap - x
		  If searchWidth < kMinSearchWidth Then searchWidth = kMinSearchWidth
		  SearchField.Width = searchWidth

		  LayoutPlatformRow(m)

		  Var contentHeight As Integer = h - kContentTop - m
		  If contentHeight < 0 Then contentHeight = 0

		  // The count sits above the list only, so the viewer keeps the full height. The
		  // space is taken only while it is showing: with no search there is nothing to
		  // say, and a permanently reserved strip would just shorten the tree.
		  Var listTop As Integer = kContentTop
		  If ResultCount.Visible Then
		    ResultCount.Left = m
		    ResultCount.Top = kContentTop
		    ResultCount.Width = mDividerX - m
		    ResultCount.Height = kResultLabelHeight
		    listTop = kContentTop + kResultLabelHeight + kResultLabelGap
		  End If

		  Var listHeight As Integer = h - listTop - m
		  If listHeight < 0 Then listHeight = 0

		  TopicList.Left = m
		  TopicList.Top = listTop
		  TopicList.Width = mDividerX - m
		  TopicList.Height = listHeight

		  Divider.Left = mDividerX
		  Divider.Top = kContentTop
		  Divider.Width = kDividerWidth
		  Divider.Height = contentHeight

		  // One tab is no tabs: the strip earns its height only once there is a choice to
		  // make, the same rule the result count follows.
		  mViewerLeft = mDividerX + kDividerWidth
		  mViewerTop = kContentTop
		  mViewerWidth = w - mViewerLeft - m

		  If TabBar.Visible Then
		    TabBar.Left = mViewerLeft
		    TabBar.Top = kContentTop
		    TabBar.Width = mViewerWidth
		    TabBar.Height = kTabBarHeight
		    mViewerTop = kContentTop + kTabBarHeight
		  End If

		  mViewerHeight = h - mViewerTop - m
		  If mViewerHeight < 0 Then mViewerHeight = 0

		  PositionViewers
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub LoadVersions()
		  // Fill the popup newest-first and select the newest. Preferences will
		  // override the selection once they exist.
		  mVersions = VNSHelpVersionScanner.Scan

		  PopulateMatchPopup

		  VersionPopup.RemoveAllRows

		  If mVersions.LastIndex < 0 Then
		    VersionPopup.Enabled = False
		    ShowMessage(kNoVersionsTitle, kNoVersionsDetail)
		    Return
		  End If

		  // A separator marks where the 2019-2020 format change falls, so the two
		  // documentation eras read as two groups without needing a label on every
		  // row. Separators occupy a row, so the version's index travels in the row
		  // tag rather than being inferred from SelectedRowIndex.
		  Var previousEra As VNSHelpVersion.eEra = VNSHelpVersion.eEra.Unknown
		  For i As Integer = 0 To mVersions.LastIndex
		    Var v As VNSHelpVersion = mVersions(i)
		    If i > 0 And v.Era <> previousEra Then VersionPopup.AddSeparator
		    VersionPopup.AddRow(v.DisplayName)
		    VersionPopup.RowTagAt(VersionPopup.LastAddedRowIndex) = i.ToString
		    previousEra = v.Era
		  Next

		  VersionPopup.Enabled = True

		  // Reopen on the release last used, when it is still installed. Otherwise
		  // fall back to the newest, which is row 0.
		  Var remembered As Integer = VNSHelpVersionScanner.IndexOfDisplayName(mVersions, _
		    VNSHelpPreferences.LastVersion)
		  SelectVersionIndex(Max(remembered, 0))

		  LoadDocSet
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SelectVersionIndex(versionIndex As Integer)
		  // Separator rows shift the popup's row numbers away from the version
		  // array, so find the row carrying this version's tag.
		  Var wanted As String = versionIndex.ToString

		  For row As Integer = 0 To VersionPopup.RowCount - 1
		    If VersionPopup.RowTagAt(row).StringValue = wanted Then
		      VersionPopup.SelectedRowIndex = row
		      Return
		    End If
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SelectedVersion() As VNSHelpVersion
		  // Read the version index out of the row tag: separator rows carry no tag,
		  // so their StringValue is empty and they resolve to Nil.
		  Var row As Integer = VersionPopup.SelectedRowIndex
		  If row < 0 Then Return Nil

		  Var tag As String = VersionPopup.RowTagAt(row).StringValue
		  If tag = "" Then Return Nil

		  Var index As Integer = VNSHelpVersion.SafeInteger(tag)
		  If index < 0 Or index > mVersions.LastIndex Then Return Nil

		  Return mVersions(index)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub RestoreWindowBounds()
		  // Reopen where the user left the window, but only where it is actually
		  // reachable: a display that has since been unplugged, or a resolution
		  // change, would otherwise put the window off-screen with no way back.
		  If Not VNSHelpPreferences.HasWindowBounds Then Return

		  Var width As Integer = Max(VNSHelpPreferences.WindowWidth, Self.MinimumWidth)
		  Var height As Integer = Max(VNSHelpPreferences.WindowHeight, Self.MinimumHeight)
		  Var left As Integer = VNSHelpPreferences.WindowLeft
		  Var top As Integer = VNSHelpPreferences.WindowTop

		  Var usable As Rect = UsableArea(left, top)
		  width = Min(width, usable.Width)
		  height = Min(height, usable.Height)
		  left = Min(Max(left, usable.Left), usable.Left + usable.Width - width)
		  top = Min(Max(top, usable.Top), usable.Top + usable.Height - height)

		  Self.Width = width
		  Self.Height = height
		  Self.Left = left
		  Self.Top = top
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function UsableArea(left As Integer, top As Integer) As Rect
		  // The available area of whichever display holds that point, falling back
		  // to the main display when the point is on none of them.
		  For i As Integer = 0 To DesktopDisplay.DisplayCount - 1
		    Var display As DesktopDisplay = DesktopDisplay.DisplayAt(i)
		    If display = Nil Then Continue

		    If left >= display.AvailableLeft And left < display.AvailableLeft + display.AvailableWidth _
		      And top >= display.AvailableTop And top < display.AvailableTop + display.AvailableHeight Then
		      Return New Rect(display.AvailableLeft, display.AvailableTop, _
		        display.AvailableWidth, display.AvailableHeight)
		    End If
		  Next

		  Var main As DesktopDisplay = DesktopDisplay.DisplayAt(0)
		  If main = Nil Then Return New Rect(0, 0, Self.Width, Self.Height)

		  Return New Rect(main.AvailableLeft, main.AvailableTop, main.AvailableWidth, main.AvailableHeight)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub RunPendingSearch()
		  ApplySearch(SearchField.Text)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ApplySearch(query As String)
		  // An empty field restores the tree; otherwise the tree is replaced by a
		  // flat, ranked result list.
		  If mDocSet = Nil Then Return

		  Var term As String = query.Trim
		  If term = "" Then
		    mSearchTerm = ""
		    mSearchTerms.RemoveAll
		    mSearchHits.RemoveAll
		    ShowResultCount(-1)
		    PopulateRootTopics
		    Return
		  End If

		  mSearchTerm = term

		  // The highlighter marks exactly the terms that were searched for, so "and"
		  // with two words highlights both and "exact" highlights the phrase.
		  Var mode As VNSHelpDocSet.eMatch = SelectedMatchMode
		  mSearchTerms = mDocSet.SearchTerms(term, mode)
		  mSearchHits = mDocSet.Search(term, mode)

		  mSuppressSelectionLoad = True
		  TopicList.RemoveAllRows

		  For i As Integer = 0 To mSearchHits.LastIndex
		    Var hit As VNSHelpSearchHit = mSearchHits(i)

		    // Occurrence count in the row, since that is what the order is based on.
		    Var label As String = hit.Title + kHitCountOpen + hit.Rank.ToString + kHitCountClose
		    If hit.Context <> "" Then label = label + kHitContextSeparator + hit.Context

		    TopicList.AddRow(label)
		    TopicList.RowTagAt(TopicList.LastAddedRowIndex) = hit.PageKey
		  Next

		  mSuppressSelectionLoad = False

		  ShowResultCount(mSearchHits.Count)

		  If mSearchHits.LastIndex < 0 Then
		    ShowMessage(kNoResultsTitle, kNoResultsPrefix + term + kNoResultsSuffix)
		    Return
		  End If

		  // Land on the best result rather than on a list still to be clicked. Set with
		  // the guard down on purpose: SelectionChanged is what loads the page, and it
		  // also records the visit, so Back works from a search exactly as from the tree.
		  TopicList.SelectedRowIndex = 0
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub LoadDocSet()
		  // Switch the whole window to the selected release: new provider, new
		  // tree, new welcome page.
		  mSuppressSelectionLoad = True
		  TopicList.RemoveAllRows
		  mSuppressSelectionLoad = False

		  mCurrentPageKey = ""
		  mPendingAnchor = ""
		  mSearchTerm = ""
		  mSearchHits.RemoveAll
		  mDocSet = Nil

		  // Page keys are provider-specific, so neither the history nor the link table
		  // survives a change of release.
		  mLinkKeys.RemoveAll
		  mLinkTitles.RemoveAll
		  mHistoryKeys.RemoveAll
		  mHistoryTitles.RemoveAll
		  mHistoryPosition = -1
		  UpdateNavigationButtons

		  Var v As VNSHelpVersion = SelectedVersion
		  If v = Nil Then
		    ShowMessage(kNoVersionsTitle, kNoVersionsDetail)
		    Return
		  End If

		  EnsureFirstTab

		  mDocSet = VNSHelpDocSet.ForVersion(v)
		  If mDocSet = Nil Then
		    // A format with no provider yet. Say so rather than showing an empty
		    // tree, which would read as a release with no documentation.
		    ShowMessage(kUnsupportedTitle, kUnsupportedPrefix + v.DisplayName + kUnsupportedSuffix)
		    Return
		  End If

		  // Settings that change how results are ordered belong on the provider, so the
		  // engine never reads the preferences itself.
		  mDocSet.DeprecatedLast = VNSHelpPreferences.DeprecatedLast
		  mDocSet.PlatformFilter = VNSHelpPreferences.PlatformFilter

		  PopulateRootTopics
		  RebuildFavoritesPopup

		  // Reopen the page last read, but only on the release it was read from —
		  // page keys are not portable between releases.
		  If VNSHelpPreferences.LastPageKey <> "" _
		    And VNSHelpPreferences.LastVersion = v.DisplayName Then
		    ShowPage(VNSHelpPreferences.LastPageKey)
		    RecordHistory(VNSHelpPreferences.LastPageKey, mDocSet.TitleForKey(VNSHelpPreferences.LastPageKey))
		  End If

		  If mCurrentPageKey = "" Then ShowWelcome(v)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub PopulateRootTopics()
		  mSuppressSelectionLoad = True
		  TopicList.RemoveAllRows

		  For Each topic As VNSHelpTopic In mDocSet.RootTopics
		    AddTopicRow(topic)
		  Next

		  mSuppressSelectionLoad = False
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddTopicRow(topic As VNSHelpTopic)
		  // Inside the RowExpanded event these calls attach the row as a child of
		  // the row being expanded, which is how the tree gains depth.
		  If topic.HasChildren Then
		    TopicList.AddExpandableRow(topic.Title)
		  Else
		    TopicList.AddRow(topic.Title)
		  End If

		  TopicList.RowTagAt(TopicList.LastAddedRowIndex) = topic.Key
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ShowTopicKey(topicKey As String, topicTitle As String)
		  If mDocSet = Nil Or topicKey = "" Then Return

		  RecordHistory(topicKey, topicTitle)

		  If Not topicKey.BeginsWith(VNSHelpDocSet.kGroupPrefix) Then
		    ShowPage(topicKey)
		    Return
		  End If

		  // A group has no page of its own. Prefer a real overview page when the
		  // format has one — a Sphinx folder's index page is written prose, better
		  // than any list we could build — and otherwise list what is inside.
		  Var overviewKey As String = mDocSet.OverviewPageKey(topicKey)
		  If overviewKey <> "" Then
		    ShowPage(overviewKey)
		    Return
		  End If

		  ShowGroupContents(topicKey, topicTitle)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ShowGroupContents(groupKey As String, groupTitle As String)
		  // Build an index of the group's children so selecting a row that has
		  // children shows what is in it rather than doing nothing.
		  Var topics() As VNSHelpTopic = mDocSet.ChildTopics(groupKey)

		  // The generated page links by position, exactly as a rewritten article link
		  // does, so both resolve through the one table.
		  mLinkKeys.RemoveAll
		  mLinkTitles.RemoveAll
		  For Each topic As VNSHelpTopic In topics
		    mLinkKeys.Add(topic.Key)
		    mLinkTitles.Add(topic.Title)
		  Next

		  DisplayFragment(VNSHelpRenderer.OverviewFragment(groupTitle, topics), groupKey)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ShowPage(pageKey As String)
		  Var baseFile As FolderItem
		  Var fragment As String = mDocSet.PageHTML(pageKey, baseFile)
		  If fragment = "" Then Return

		  // The links in the fragment carry positions in this array — see
		  // VNSHelpDocSet.LinkHref. Titles come from the key when one is needed.
		  mLinkKeys = mDocSet.LinkTargets
		  mLinkTitles.RemoveAll

		  // Scrolling has to wait until the document exists — see DocumentComplete.
		  mPendingAnchor = mDocSet.AnchorFromKey(pageKey)

		  DisplayFragment(fragment, pageKey)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DisplayFragment(fragment As String, pageKey As String)
		  mCurrentPageKey = pageKey
		  UpdateWebButton
		  RebuildFavoritesPopup

		  // The tab is named after whatever it is showing. Only overwritten when the
		  // provider can name the page: a group key has no title of its own, and the
		  // label the link carried is better than falling back to the raw key.
		  If mActiveTab >= 0 And mActiveTab <= mTabs.LastIndex Then
		    mTabs(mActiveTab).PageKey = pageKey

		    If mDocSet <> Nil Then
		      Var caption As String = mDocSet.TitleForKey(pageKey)
		      If caption <> "" Then mTabs(mActiveTab).Title = caption
		    End If

		    If TabBar.Visible Then TabBar.Refresh
		  End If

		  Var page As String = VNSHelpRenderer.Wrap(fragment, mDocSet.StyleSheet)

		  // Load a real file sitting beside the page's images. Handing the viewer a
		  // string instead leaves it unable to read those images, whatever base it
		  // is given — see VNSHelpRenderer.WriteToFile.
		  Var rendered As FolderItem = VNSHelpRenderer.WriteToFile(page, mDocSet.RenderFolder)
		  If rendered <> Nil Then
		    ActiveViewer.LoadPage(rendered)
		    Return
		  End If

		  // Nowhere to write: show the page anyway, without its images.
		  ActiveViewer.LoadPage(page, SpecialFolder.Temporary.Child(kFallbackBaseName))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub NavigatePending()
		  // Deferred out of CancelLoad: loading a new document from inside that event
		  // would re-enter the viewer while it is still deciding about the old one.
		  Var key As String = mPendingNavigationKey
		  Var title As String = mPendingNavigationTitle
		  mPendingNavigationKey = ""
		  mPendingNavigationTitle = ""

		  If key = "" Then Return

		  // A rewritten article link carries no title, so ask the provider for one —
		  // the history needs a label even when the click came from inside a page.
		  If title = "" And mDocSet <> Nil Then title = mDocSet.TitleForKey(key)

		  ShowTopicKey(key, title)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub RecordHistory(topicKey As String, topicTitle As String)
		  // What is recorded is the choice the user made, not the page it produced: a
		  // group key resolves to its overview page and re-resolving it gives the same
		  // result, so one entry serves both kinds of destination.
		  If mSuppressHistory Then Return

		  // Choosing the row you are already on is not a move.
		  If mHistoryPosition >= 0 And mHistoryPosition <= mHistoryKeys.LastIndex Then
		    If mHistoryKeys(mHistoryPosition) = topicKey Then Return
		  End If

		  // Anything ahead of here is a branch the user has just left.
		  While mHistoryKeys.LastIndex > mHistoryPosition
		    mHistoryKeys.RemoveAt(mHistoryKeys.LastIndex)
		    mHistoryTitles.RemoveAt(mHistoryTitles.LastIndex)
		  Wend

		  mHistoryKeys.Add(topicKey)
		  mHistoryTitles.Add(topicTitle)
		  mHistoryPosition = mHistoryKeys.LastIndex

		  If mHistoryKeys.Count > kMaximumHistory Then
		    mHistoryKeys.RemoveAt(0)
		    mHistoryTitles.RemoveAt(0)
		    mHistoryPosition = mHistoryPosition - 1
		  End If

		  UpdateNavigationButtons
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub GoToHistory(position As Integer)
		  // The viewer's own CanGoBack is meaningless here: navigation is driven by this
		  // window, and the viewer only ever sees one file being rewritten in place.
		  If position < 0 Or position > mHistoryKeys.LastIndex Then Return

		  mHistoryPosition = position

		  // Replaying an entry must not push it again.
		  mSuppressHistory = True
		  ShowTopicKey(mHistoryKeys(position), mHistoryTitles(position))
		  mSuppressHistory = False

		  UpdateNavigationButtons
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub UpdateNavigationButtons()
		  BtnBack.Enabled = mHistoryPosition > 0
		  BtnForward.Enabled = mHistoryPosition >= 0 And mHistoryPosition < mHistoryKeys.LastIndex
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FavoriteTopics() As VNSHelpTopic()
		  // The favorites recorded against the release on screen.
		  //
		  // Only this release's: a page key means nothing to a provider that did not issue
		  // it, so showing another release's favorites here would offer rows that cannot
		  // open. They are not lost — they come back when that release is selected.
		  Var topics() As VNSHelpTopic

		  Var v As VNSHelpVersion = SelectedVersion
		  If v = Nil Then Return topics

		  For i As Integer = 0 To VNSHelpPreferences.FavoriteCount - 1
		    If VNSHelpPreferences.FavoriteVersionAt(i) <> v.DisplayName Then Continue

		    Var title As String = VNSHelpPreferences.FavoriteTitleAt(i)
		    Var pageKey As String = VNSHelpPreferences.FavoriteKeyAt(i)
		    If title = "" Then title = pageKey

		    topics.Add(New VNSHelpTopic(pageKey, title, VNSHelpTopic.eKind.Page, False))
		  Next

		  Return topics
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ToggleCurrentFavorite()
		  // Cmd+D. The page on screen is the one acted on, so a favorite can be made from
		  // anywhere the reader can reach — a link, a search hit or the tree.
		  If mDocSet = Nil Or mCurrentPageKey = "" Then Return

		  Var v As VNSHelpVersion = SelectedVersion
		  If v = Nil Then Return

		  Var title As String = mDocSet.TitleForKey(mCurrentPageKey)
		  If title = "" Then title = mCurrentPageKey

		  Call VNSHelpPreferences.ToggleFavorite(v.DisplayName, mCurrentPageKey, title)
		  VNSHelpPreferences.Save

		  RebuildFavoritesPopup
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub OpenExternalLink(reference As String)
		  // The browser's job. The reference is a position in the same table the internal
		  // links use, so an out-of-range one simply does nothing.
		  Var index As Integer = VNSHelpVersion.SafeInteger(reference)
		  If index < 0 Or index > mLinkKeys.LastIndex Then Return

		  Var target As String = mLinkKeys(index)
		  If target.BeginsWith(VNSHelpDocSet.kExternalPrefix) Then
		    target = target.MiddleBytes(VNSHelpDocSet.kExternalPrefix.Bytes)
		  End If

		  If target <> "" Then System.GotoURL(target)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub OpenCurrentPageOnTheWeb()
		  // The globe. Only the Sphinx era offers an address — see VNSHelpDocSet.WebURL —
		  // so on the legacy era the button stays disabled rather than opening a page that
		  // is no longer served.
		  Var url As String = CurrentWebURL
		  If url <> "" Then System.GotoURL(url)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function CurrentWebURL() As String
		  If mDocSet = Nil Or mCurrentPageKey = "" Then Return ""

		  Return mDocSet.WebURL(mCurrentPageKey)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub UpdateWebButton()
		  BtnWeb.Enabled = CurrentWebURL <> ""
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub RebuildFavoritesPopup()
		  // The popup is a menu, not a chooser: row 0 is a resting label so the control
		  // always reads "Favorites", and every other row carries its action in the row
		  // tag. Tags rather than indexes because separators occupy a row of their own —
		  // the same reason VersionPopup resolves its selection through a tag.
		  mSuppressFavoriteSelection = True
		  FavoritesPopup.RemoveAllRows

		  FavoritesPopup.AddRow(kFavoritesLabel)
		  FavoritesPopup.RowTagAt(FavoritesPopup.LastAddedRowIndex) = ""

		  // Adding is offered here as well as on Cmd+D, so it never depends on whether
		  // the menu bar has had a chance to enable itself.
		  Var v As VNSHelpVersion = SelectedVersion
		  Var canFavorite As Boolean = mDocSet <> Nil And v <> Nil And mCurrentPageKey <> ""
		  If canFavorite Then
		    FavoritesPopup.AddSeparator

		    Var label As String = kFavoriteAdd
		    If VNSHelpPreferences.IsFavorite(v.DisplayName, mCurrentPageKey) Then label = kFavoriteRemove

		    FavoritesPopup.AddRow(label)
		    FavoritesPopup.RowTagAt(FavoritesPopup.LastAddedRowIndex) = kFavoriteToggleTag
		  End If

		  Var favorites() As VNSHelpTopic = FavoriteTopics
		  If favorites.LastIndex >= 0 Then FavoritesPopup.AddSeparator

		  For Each favorite As VNSHelpTopic In favorites
		    FavoritesPopup.AddRow(favorite.Title)
		    FavoritesPopup.RowTagAt(FavoritesPopup.LastAddedRowIndex) = kFavoriteGoPrefix + favorite.Key
		  Next

		  FavoritesPopup.SelectedRowIndex = 0
		  mSuppressFavoriteSelection = False
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub FavoriteChosen()
		  // Whatever was picked, the popup goes back to reading "Favorites" — it is a
		  // menu, and leaving a page title showing would make it look like a state.
		  If mDocSet = Nil Then Return

		  Var row As Integer = FavoritesPopup.SelectedRowIndex
		  If row < 0 Then Return

		  Var tag As String = FavoritesPopup.RowTagAt(row).StringValue

		  // Guarded: resetting the selection fires this event again, and while that
		  // re-entry is harmless — row 0 carries no tag — relying on it would be.
		  mSuppressFavoriteSelection = True
		  FavoritesPopup.SelectedRowIndex = 0
		  mSuppressFavoriteSelection = False

		  If tag = kFavoriteToggleTag Then
		    ToggleCurrentFavorite
		    Return
		  End If

		  If Not tag.BeginsWith(kFavoriteGoPrefix) Then Return

		  Var pageKey As String = tag.MiddleBytes(kFavoriteGoPrefix.Bytes)
		  ShowTopicKey(pageKey, mDocSet.TitleForKey(pageKey))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub PopulateMatchPopup()
		  // How multiple words in the field are combined. A single word means the same
		  // thing in all three, so the mode only starts to matter once there is a space.
		  //
		  // The mode travels in the row tag rather than the row index, as the version and
		  // favorites popups already do.
		  If MatchPopup.RowCount > 0 Then Return

		  MatchPopup.AddRow(kMatchAll)
		  MatchPopup.RowTagAt(MatchPopup.LastAddedRowIndex) = kMatchTagAll
		  MatchPopup.AddRow(kMatchAny)
		  MatchPopup.RowTagAt(MatchPopup.LastAddedRowIndex) = kMatchTagAny
		  MatchPopup.AddRow(kMatchExact)
		  MatchPopup.RowTagAt(MatchPopup.LastAddedRowIndex) = kMatchTagExact

		  Var remembered As Integer = VNSHelpPreferences.SearchMode
		  If remembered < 0 Or remembered > MatchPopup.RowCount - 1 Then remembered = 0
		  MatchPopup.SelectedRowIndex = remembered
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SelectedMatchMode() As VNSHelpDocSet.eMatch
		  Var row As Integer = MatchPopup.SelectedRowIndex
		  If row < 0 Then Return VNSHelpDocSet.eMatch.All

		  Select Case MatchPopup.RowTagAt(row).StringValue
		  Case kMatchTagAny
		    Return VNSHelpDocSet.eMatch.Any
		  Case kMatchTagExact
		    Return VNSHelpDocSet.eMatch.Exact
		  End Select

		  Return VNSHelpDocSet.eMatch.All
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ShowResultCount(total As Integer)
		  // A negative total means there is no search running, so the strip goes away and
		  // the tree gets its height back.
		  Var wasVisible As Boolean = ResultCount.Visible

		  If total < 0 Then
		    ResultCount.Visible = False
		  ElseIf total = 0 Then
		    ResultCount.Text = kResultNone
		    ResultCount.Visible = True
		  ElseIf total = 1 Then
		    ResultCount.Text = kResultOne
		    ResultCount.Visible = True
		  Else
		    ResultCount.Text = total.ToString + kResultMany
		    ResultCount.Visible = True
		  End If

		  // Only re-lay-out when the strip appears or disappears; the text changing on its
		  // own moves nothing.
		  If ResultCount.Visible <> wasVisible Then Layout
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function HandleCancelLoad(sender As DesktopHTMLViewer, URL As String) As Boolean
		  // The sender is not consulted: a click can only come from the tab on screen, so
		  // the active tab's link table is the right one by construction.
		  #Pragma Unused sender

		  // Every link in a rendered page was rewritten to carry the position of its
		  // target in a table this window holds — see VNSHelpDocSet.LinkHref. So the only
		  // URLs worth acting on are our own two schemes. Anything else is the page itself
		  // or a resource it is pulling in by itself, and has to be allowed through.
		  //
		  // External links carry bxhweb: rather than bxh: so the stylesheet can mark them
		  // with an arrow by href alone. Tested first: "bxhweb:" does not begin with
		  // "bxh:", so the two cannot be confused, but reading it first keeps that
		  // obvious rather than incidental.
		  If URL.BeginsWith(VNSHelpDocSet.kExternalScheme) Then
		    OpenExternalLink(URL.MiddleBytes(VNSHelpDocSet.kExternalScheme.Bytes))
		    Return True
		  End If

		  If Not URL.BeginsWith(VNSHelpDocSet.kLinkScheme) Then Return False

		  Var reference As String = URL.MiddleBytes(VNSHelpDocSet.kLinkScheme.Bytes)

		  // A link the provider could not resolve. Both formats produce them by the
		  // thousand — Xojo's own pages reference pages that release never shipped, and
		  // the legacy blobs carry a wiki skin full of Special: links. The click is
		  // swallowed so the viewer is not sent to a file that is not there.
		  If reference = VNSHelpDocSet.kDeadLinkMarker Then Return True

		  Var index As Integer = VNSHelpVersion.SafeInteger(reference)
		  If index < 0 Or index > mLinkKeys.LastIndex Then Return True

		  Var target As String = mLinkKeys(index)

		  // A page rendered before the external scheme existed, or one whose target was
		  // marked but not schemed. Still handled, so nothing depends on the two agreeing.
		  If target.BeginsWith(VNSHelpDocSet.kExternalPrefix) Then
		    System.GotoURL(target.MiddleBytes(VNSHelpDocSet.kExternalPrefix.Bytes))
		    Return True
		  End If

		  // Cmd-click opens it behind this tab instead. The modifier has to be read from
		  // the keyboard because CancelLoad reports only a URL.
		  If CommandKeyDown Then
		    mPendingNewTabKey = target
		    mPendingNewTabTitle = ""
		    If index <= mLinkTitles.LastIndex Then mPendingNewTabTitle = mLinkTitles(index)
		    Timer.CallLater(0, AddressOf OpenPendingTab)
		    Return True
		  End If

		  // Deferred: loading a new document from inside this event would re-enter the
		  // viewer while it is still deciding about the old one.
		  mPendingNavigationKey = target
		  mPendingNavigationTitle = ""
		  If index <= mLinkTitles.LastIndex Then mPendingNavigationTitle = mLinkTitles(index)
		  Timer.CallLater(0, AddressOf NavigatePending)

		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleDocumentComplete(sender As DesktopHTMLViewer, url As String)
		  // Keyed on the viewer that finished, not on whichever tab is in front. A tab
		  // opened in the background loads asynchronously and may well complete after the
		  // user has switched away, which would otherwise scroll and mark the wrong page.
		  #Pragma Unused url
		  Var index As Integer = TabIndexForViewer(sender)

		  // The active tab's anchor lives in the window's own field; a background tab's is
		  // still in its snapshot.
		  Var anchor As String = ""
		  If index >= 0 And index = mActiveTab Then
		    anchor = mPendingAnchor
		  ElseIf index >= 0 Then
		    anchor = mTabs(index).PendingAnchor
		  End If

		  // Marks first, then the anchor. The highlighter used to scroll to its own first
		  // match unconditionally, which for a member hit is the class name at the top of
		  // the page — so it silently undid the scroll to the member.
		  If mSearchTerms.LastIndex >= 0 Then
		    sender.ExecuteJavaScript(VNSHelpRenderer.HighlightScript(mSearchTerms, anchor = ""))
		  End If

		  If anchor <> "" Then
		    sender.ExecuteJavaScript(VNSHelpRenderer.ScrollScript(anchor))

		    If index = mActiveTab Then
		      mPendingAnchor = ""
		    ElseIf index >= 0 Then
		      mTabs(index).PendingAnchor = ""
		    End If
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function HandleNewWindow(sender As DesktopHTMLViewer, URL As String) As DesktopHTMLViewer
		  // WebKit's own context menu offers "Open Link in New Window", and this is where
		  // that arrives. Returning a viewer would let WebKit load the URL into it — but
		  // our hrefs are bxh:<n>, meaningless to anything but us, so the link is resolved
		  // here and opened as a tab through the same path Cmd-click uses. Nil then tells
		  // WebKit not to open a window of its own, because the work is already done.
		  #Pragma Unused sender

		  // An external link: the browser is the right home for it, new window or not.
		  If URL.BeginsWith(VNSHelpDocSet.kExternalScheme) Then
		    OpenExternalLink(URL.MiddleBytes(VNSHelpDocSet.kExternalScheme.Bytes))
		    Return Nil
		  End If

		  If Not URL.BeginsWith(VNSHelpDocSet.kLinkScheme) Then Return Nil

		  Var reference As String = URL.MiddleBytes(VNSHelpDocSet.kLinkScheme.Bytes)
		  If reference = VNSHelpDocSet.kDeadLinkMarker Then Return Nil

		  Var index As Integer = VNSHelpVersion.SafeInteger(reference)
		  If index < 0 Or index > mLinkKeys.LastIndex Then Return Nil

		  Var target As String = mLinkKeys(index)
		  If target.BeginsWith(VNSHelpDocSet.kExternalPrefix) Then
		    System.GotoURL(target.MiddleBytes(VNSHelpDocSet.kExternalPrefix.Bytes))
		    Return Nil
		  End If

		  // Deferred like every other navigation out of a viewer event, so the tab is
		  // built after this one has finished deciding.
		  mPendingNewTabKey = target
		  mPendingNewTabTitle = ""
		  If index <= mLinkTitles.LastIndex Then mPendingNewTabTitle = mLinkTitles(index)
		  Timer.CallLater(0, AddressOf OpenPendingTab)

		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function OnViewerNewWindow(sender As DesktopHTMLViewer, URL As String) As DesktopHTMLViewer
		  Return HandleNewWindow(sender, URL)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function TabIndexForViewer(v As DesktopHTMLViewer) As Integer
		  // One set of handlers serves every tab, so a handler's first job is working out
		  // which tab it was called for.
		  For i As Integer = 0 To mTabs.LastIndex
		    If mTabs(i).Viewer Is v Then Return i
		  Next

		  Return -1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ActiveViewer() As DesktopHTMLViewer
		  // Tab 0 is the viewer placed at design time; every later tab makes its own. The
		  // fallback matters during Opening, before any tab exists.
		  If mActiveTab >= 0 And mActiveTab <= mTabs.LastIndex Then
		    Var v As DesktopHTMLViewer = mTabs(mActiveTab).Viewer
		    If v <> Nil Then Return v
		  End If

		  Return HelpViewer
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub EnsureFirstTab()
		  // Every window has at least one tab, created before anything is shown so the
		  // save/restore of per-tab state always has somewhere to go.
		  If mTabs.LastIndex >= 0 Then Return

		  Var tab As New VNSHelpTabState
		  tab.Viewer = HelpViewer
		  mTabs.Add(tab)
		  mActiveTab = 0
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub WireViewer(v As DesktopHTMLViewer)
		  // A control created at runtime has no events of its own — they are attached
		  // here, and each handler then receives the viewer as its first parameter so one
		  // implementation can serve every tab. Pattern taken from MainWindow.WireViewer
		  // in /Users/jeanyves/xojo2015/Claude Browser.
		  AddHandler v.CancelLoad, AddressOf OnViewerCancelLoad
		  AddHandler v.DocumentComplete, AddressOf OnViewerDocumentComplete
		  AddHandler v.NewWindow, AddressOf OnViewerNewWindow
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function OnViewerCancelLoad(sender As DesktopHTMLViewer, url As String) As Boolean
		  Return HandleCancelLoad(sender, url)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub OnViewerDocumentComplete(sender As DesktopHTMLViewer, url As String)
		  HandleDocumentComplete(sender, url)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SaveActiveTab()
		  // The window keeps working from its own fields, exactly as it did before tabs
		  // existed; a tab is a snapshot of them. That is why none of the navigation, link
		  // or history code had to change to gain tabs.
		  If mActiveTab < 0 Or mActiveTab > mTabs.LastIndex Then Return

		  Var tab As VNSHelpTabState = mTabs(mActiveTab)
		  tab.PageKey = mCurrentPageKey
		  tab.PendingAnchor = mPendingAnchor
		  tab.HistoryPosition = mHistoryPosition

		  CopyStrings(mLinkKeys, tab.LinkKeys)
		  CopyStrings(mLinkTitles, tab.LinkTitles)
		  CopyStrings(mHistoryKeys, tab.HistoryKeys)
		  CopyStrings(mHistoryTitles, tab.HistoryTitles)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub RestoreActiveTab()
		  // No re-render: the tab's own viewer still holds its document, so switching is
		  // only a matter of putting its state back and showing it.
		  If mActiveTab < 0 Or mActiveTab > mTabs.LastIndex Then Return

		  Var tab As VNSHelpTabState = mTabs(mActiveTab)
		  mCurrentPageKey = tab.PageKey
		  mPendingAnchor = tab.PendingAnchor
		  mHistoryPosition = tab.HistoryPosition

		  CopyStrings(tab.LinkKeys, mLinkKeys)
		  CopyStrings(tab.LinkTitles, mLinkTitles)
		  CopyStrings(tab.HistoryKeys, mHistoryKeys)
		  CopyStrings(tab.HistoryTitles, mHistoryTitles)

		  UpdateNavigationButtons
		  UpdateWebButton
		  RebuildFavoritesPopup
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub CopyStrings(source() As String, destination() As String)
		  destination.RemoveAll
		  For Each item As String In source
		    destination.Add(item)
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub PositionViewers()
		  // Every viewer occupies the same rectangle; only the active one is visible.
		  For i As Integer = 0 To mTabs.LastIndex
		    Var v As DesktopHTMLViewer = mTabs(i).Viewer
		    If v = Nil Then Continue

		    v.Left = mViewerLeft
		    v.Top = mViewerTop
		    v.Width = mViewerWidth
		    v.Height = mViewerHeight
		    v.Visible = (i = mActiveTab)
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub OpenInNewTab(pageKey As String, title As String)
		  // Cmd-click. The tab opens behind the one being read, as a browser's does: the
		  // point of Cmd-clicking is not to lose your place.
		  If pageKey = "" Or mDocSet = Nil Then Return

		  SaveActiveTab

		  Var v As New DesktopHTMLViewer
		  Self.AddControl(v)
		  WireViewer(v)

		  Var tab As New VNSHelpTabState
		  tab.Viewer = v
		  tab.Title = title
		  mTabs.Add(tab)

		  // Rendered through the ordinary path by making it briefly active, so the link
		  // table, anchor and history are built exactly as for any other page rather than
		  // by a second, parallel implementation.
		  Var previous As Integer = mActiveTab
		  mActiveTab = mTabs.LastIndex

		  mCurrentPageKey = ""
		  mPendingAnchor = ""
		  mLinkKeys.RemoveAll
		  mLinkTitles.RemoveAll
		  mHistoryKeys.RemoveAll
		  mHistoryTitles.RemoveAll
		  mHistoryPosition = -1

		  ShowTopicKey(pageKey, title)
		  SaveActiveTab

		  mActiveTab = previous
		  RestoreActiveTab

		  SyncTabBar
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SelectTab(index As Integer)
		  If index < 0 Or index > mTabs.LastIndex Or index = mActiveTab Then Return

		  SaveActiveTab
		  mActiveTab = index
		  RestoreActiveTab

		  PositionViewers
		  TabBar.Refresh
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub CloseTab(index As Integer)
		  // The last tab is never closed: with none left there is nothing to show and no
		  // way back to a page.
		  If index < 0 Or index > mTabs.LastIndex Or mTabs.Count < 2 Then Return

		  Var v As DesktopHTMLViewer = mTabs(index).Viewer
		  mTabs.RemoveAt(index)

		  // The design-time viewer belongs to the window and is only hidden; a runtime one
		  // is ours to remove.
		  If v <> Nil And v <> HelpViewer Then
		    v.Visible = False
		    Self.RemoveControl(v)
		  End If

		  If mActiveTab > index Then mActiveTab = mActiveTab - 1
		  If mActiveTab > mTabs.LastIndex Then mActiveTab = mTabs.LastIndex

		  RestoreActiveTab
		  SyncTabBar
		  PositionViewers
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SyncTabBar()
		  Var wanted As Boolean = mTabs.Count > 1
		  If TabBar.Visible <> wanted Then
		    TabBar.Visible = wanted
		    Layout
		  Else
		    PositionViewers
		    TabBar.Refresh
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function TabWidth() As Integer
		  Var n As Integer = mTabs.Count
		  If n < 1 Then Return kTabMaxWidth

		  Var available As Integer = TabBar.Width - kNewTabWidth
		  Var tabW As Integer = available \ n
		  If tabW > kTabMaxWidth Then tabW = kTabMaxWidth
		  If tabW < kTabMinWidth Then tabW = kTabMinWidth

		  Return tabW
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function TabIndexAt(x As Integer) As Integer
		  Var tabW As Integer = TabWidth
		  If tabW <= 0 Then Return -1

		  Var i As Integer = x \ tabW
		  If i >= 0 And i <= mTabs.LastIndex Then Return i

		  Return -1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function CloseZoneAt(x As Integer) As Integer
		  // The close cross occupies the right-hand end of a tab, and only when the tab is
		  // wide enough to have drawn one.
		  Var tabW As Integer = TabWidth
		  If tabW < kTabCloseMinWidth Then Return -1

		  Var i As Integer = TabIndexAt(x)
		  If i < 0 Then Return -1

		  Var withinTab As Integer = x - i * tabW
		  If withinTab >= tabW - kTabCloseZone Then Return i

		  Return -1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub PaintTabBar(g As Graphics)
		  g.DrawingColor = kTabStripColor
		  g.FillRectangle(0, 0, g.Width, g.Height)
		  If mTabs.Count = 0 Then Return

		  Var tabW As Integer = TabWidth
		  Var showClose As Boolean = tabW >= kTabCloseMinWidth
		  Var showTitle As Boolean = tabW >= kTabTitleMinWidth

		  For i As Integer = 0 To mTabs.LastIndex
		    Var x As Integer = i * tabW

		    If i = mActiveTab Then
		      g.DrawingColor = kTabActiveColor
		    Else
		      g.DrawingColor = kTabInactiveColor
		    End If
		    g.FillRectangle(x, 0, tabW - 1, g.Height)

		    g.DrawingColor = kTabBorderColor
		    g.DrawRectangle(x, 0, tabW - 1, g.Height - 1)

		    If showTitle Then
		      g.DrawingColor = kTabTextColor
		      Var width As Integer = tabW - kTabTextInset * 2
		      If showClose Then width = tabW - kTabCloseZone - kTabTextInset
		      g.DrawText(mTabs(i).Caption, x + kTabTextInset, g.Height - kTabTextBaseline, width, True)
		    End If

		    If showClose Then
		      g.DrawingColor = kTabCloseColor
		      g.DrawText(kTabCloseGlyph, x + tabW - kTabCloseZone + 4, g.Height - kTabTextBaseline)
		    End If
		  Next

		  g.DrawingColor = kTabTextColor
		  g.DrawText(kNewTabGlyph, mTabs.Count * tabW + kTabTextInset, g.Height - kTabTextBaseline)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub NewEmptyTab()
		  // Cmd+T. A tab with nothing in it yet, brought to the front so the next thing
		  // chosen lands in it.
		  SaveActiveTab

		  Var v As New DesktopHTMLViewer
		  Self.AddControl(v)
		  WireViewer(v)

		  Var tab As New VNSHelpTabState
		  tab.Viewer = v
		  mTabs.Add(tab)

		  mActiveTab = mTabs.LastIndex
		  mCurrentPageKey = ""
		  mPendingAnchor = ""
		  mLinkKeys.RemoveAll
		  mLinkTitles.RemoveAll
		  mHistoryKeys.RemoveAll
		  mHistoryTitles.RemoveAll
		  mHistoryPosition = -1
		  UpdateNavigationButtons
		  UpdateWebButton

		  SyncTabBar
		  PositionViewers
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function CommandKeyDown() As Boolean
		  // Neither CancelLoad nor SelectionChanged reports a modifier, so the keyboard is
		  // asked directly at the moment the event arrives.
		  Return Keyboard.AsyncCommandKey
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub OpenPendingTab()
		  // Deferred out of CancelLoad for the same reason NavigatePending is: creating and
		  // loading a viewer from inside that event re-enters the one still deciding.
		  Var key As String = mPendingNewTabKey
		  Var title As String = mPendingNewTabTitle
		  mPendingNewTabKey = ""
		  mPendingNewTabTitle = ""

		  If key = "" Then Return
		  If title = "" And mDocSet <> Nil Then title = mDocSet.TitleForKey(key)

		  OpenInNewTab(key, title)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ShowWelcome(v As VNSHelpVersion)
		  Var detail As String = kWelcomePrefix + v.DisplayName + kWelcomeMiddle _
		    + mDocSet.PageCount.ToString + kWelcomeSuffix
		  ShowMessage(kWelcomeTitle, detail)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ShowMessage(heading As String, detail As String)
		  // Status page: no documentation set is loaded, or the one selected cannot
		  // be read yet.
		  //
		  // kMessageShell is generated from tools/help-message-shell.html by
		  // sync_xojo_constant.py — never hand-edit the escaped constant.
		  Var html As String = kMessageShell
		  html = html.ReplaceAll(kTokenHeading, heading)
		  html = html.ReplaceAll(kTokenDetail, detail)
		  ActiveViewer.LoadPage(html, SpecialFolder.Temporary.Child(kFallbackBaseName))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub RememberSearch(term As String)
		  // Record a term in the search field's Recent Searches menu. Pressed also
		  // fires when the user picks an existing recent item or clicks Clear, so
		  // skip terms already on the menu rather than duplicating them.
		  Var trimmed As String = term.Trim
		  If trimmed = "" Then Return

		  For Each existing As String In SearchField.RecentItems
		    If existing = trimmed Then Return
		  Next

		  SearchField.AddRecentItem(trimmed)
		End Sub
	#tag EndMethod

	#tag Property, Flags = &h21
		Private mVersions() As VNSHelpVersion
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDividerX As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDragOffsetX As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDocSet As VNSHelpDocSet
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCurrentPageKey As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPendingAnchor As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSuppressPlatformChange As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSuppressSelectionLoad As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLinkKeys() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLinkTitles() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mHistoryKeys() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mHistoryTitles() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mHistoryPosition As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSuppressHistory As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSuppressFavoriteSelection As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTabs() As VNSHelpTabState
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSelectionWantsNewTab As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPendingNewTabKey As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPendingNewTabTitle As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mActiveTab As Integer = -1
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mViewerLeft As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mViewerTop As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mViewerWidth As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mViewerHeight As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSearchHits() As VNSHelpSearchHit
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSearchTerm As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSearchTerms() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPendingNavigationKey As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPendingNavigationTitle As String
	#tag EndProperty

	#tag Constant, Name = kWindowTitle, Type = String, Dynamic = False, Default = \"Better Xojo Help", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSearchHint, Type = String, Dynamic = False, Default = \"Search the documentation…", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kNoVersionsTitle, Type = String, Dynamic = False, Default = \"No Xojo documentation found", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kNoVersionsDetail, Type = String, Dynamic = False, Default = \"Better Xojo Help reads the offline documentation that ships with each Xojo release\x2C from ~/Library/Application Support/Xojo/Xojo. Install a Xojo release that includes its documentation and reopen this window.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kWelcomeTitle, Type = String, Dynamic = False, Default = \"Choose a topic", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kWelcomePrefix, Type = String, Dynamic = False, Default = \"Xojo ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kWelcomeMiddle, Type = String, Dynamic = False, Default = \" documentation\x2C ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kWelcomeSuffix, Type = String, Dynamic = False, Default = \" pages. Pick a topic from the list on the left.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kUnsupportedTitle, Type = String, Dynamic = False, Default = \"Not readable yet", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kUnsupportedPrefix, Type = String, Dynamic = False, Default = \"Xojo ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kUnsupportedSuffix, Type = String, Dynamic = False, Default = \" stores its documentation in the older database format\x2C which this build cannot read yet. Choose a release from the upper group of the version menu.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMessageShell, Type = String, Dynamic = False, Default = \"<!DOCTYPE html>\n<html>\n<head>\n<style>\nbody {\n  font-family: -apple-system\x2C BlinkMacSystemFont\x2C Helvetica\x2C Arial\x2C sans-serif;\n  font-size: 14px;\n  line-height: 1.5;\n  color: #222;\n  margin: 24px 26px;\n}\nh1 {\n  font-size: 19px;\n  margin: 0 0 12px;\n}\np {\n  margin: 0;\n  color: #555;\n}\n</style>\n</head>\n<body>\n<h1>{{HEADING}}</h1>\n<p>{{DETAIL}}</p>\n</body>\n</html>\n", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTokenHeading, Type = String, Dynamic = False, Default = \"{{HEADING}}", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTokenDetail, Type = String, Dynamic = False, Default = \"{{DETAIL}}", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMargin, Type = Integer, Dynamic = False, Default = \"12", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kToolbarHeight, Type = Integer, Dynamic = False, Default = \"24", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPlatformRowTop, Type = Integer, Dynamic = False, Default = \"42", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFramePadding, Type = Integer, Dynamic = False, Default = \"6", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFrameInset, Type = Integer, Dynamic = False, Default = \"3", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFrameRadius, Type = Integer, Dynamic = False, Default = \"6", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCheckHeight, Type = Integer, Dynamic = False, Default = \"20", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCheckGap, Type = Integer, Dynamic = False, Default = \"4", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCheckGroupGap, Type = Integer, Dynamic = False, Default = \"22", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCheckDesktopWidth, Type = Integer, Dynamic = False, Default = \"70", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCheckWebWidth, Type = Integer, Dynamic = False, Default = \"50", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCheckMobileWidth, Type = Integer, Dynamic = False, Default = \"64", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCheckIOSWidth, Type = Integer, Dynamic = False, Default = \"46", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCheckAndroidWidth, Type = Integer, Dynamic = False, Default = \"72", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCheckMacOSWidth, Type = Integer, Dynamic = False, Default = \"60", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCheckWindowsWidth, Type = Integer, Dynamic = False, Default = \"74", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCheckLinuxWidth, Type = Integer, Dynamic = False, Default = \"56", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kContentTop, Type = Integer, Dynamic = False, Default = \"70", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kVersionWidth, Type = Integer, Dynamic = False, Default = \"200", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kNavButtonWidth, Type = Integer, Dynamic = False, Default = \"34", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kGap, Type = Integer, Dynamic = False, Default = \"8", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kNavGap, Type = Integer, Dynamic = False, Default = \"2", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kDividerWidth, Type = Integer, Dynamic = False, Default = \"6", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kDefaultDividerX, Type = Integer, Dynamic = False, Default = \"272", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMinListWidth, Type = Integer, Dynamic = False, Default = \"170", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMinViewerWidth, Type = Integer, Dynamic = False, Default = \"320", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMinSearchWidth, Type = Integer, Dynamic = False, Default = \"120", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kResultLabelHeight, Type = Integer, Dynamic = False, Default = \"16", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kResultLabelGap, Type = Integer, Dynamic = False, Default = \"4", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kResultNone, Type = String, Dynamic = False, Default = \"No results", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kResultOne, Type = String, Dynamic = False, Default = \"1 result", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kResultMany, Type = String, Dynamic = False, Default = \" results", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMaximumRecentSearches, Type = Integer, Dynamic = False, Default = \"12", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFallbackBaseName, Type = String, Dynamic = False, Default = \"page.html", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMaximumHistory, Type = Integer, Dynamic = False, Default = \"100", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMatchPopupWidth, Type = Integer, Dynamic = False, Default = \"90", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMatchAll, Type = String, Dynamic = False, Default = \"and", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMatchAny, Type = String, Dynamic = False, Default = \"or", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMatchExact, Type = String, Dynamic = False, Default = \"exact", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMatchTagAll, Type = String, Dynamic = False, Default = \"all", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMatchTagAny, Type = String, Dynamic = False, Default = \"any", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMatchTagExact, Type = String, Dynamic = False, Default = \"exact", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFavoritesLabel, Type = String, Dynamic = False, Default = \"\xE2\x98\x85 Favorites", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFavoriteAdd, Type = String, Dynamic = False, Default = \"Add this page", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFavoriteRemove, Type = String, Dynamic = False, Default = \"Remove this page", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFavoriteToggleTag, Type = String, Dynamic = False, Default = \"toggle", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFavoriteGoPrefix, Type = String, Dynamic = False, Default = \"go:", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFavoritesPopupWidth, Type = Integer, Dynamic = False, Default = \"150", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSearchDebounceMilliseconds, Type = Integer, Dynamic = False, Default = \"300", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMinimumSearchLength, Type = Integer, Dynamic = False, Default = \"3", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHitCountOpen, Type = String, Dynamic = False, Default = \"  (", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHitCountClose, Type = String, Dynamic = False, Default = \")", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHitContextSeparator, Type = String, Dynamic = False, Default = \"   \xE2\x80\x94 ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kNoResultsTitle, Type = String, Dynamic = False, Default = \"Nothing found", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kNoResultsPrefix, Type = String, Dynamic = False, Default = \"No page matches \x22", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kNoResultsSuffix, Type = String, Dynamic = False, Default = \"\x22 in this release. Search covers page titles here; the older documentation databases also search the full page text.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTabBarHeight, Type = Integer, Dynamic = False, Default = \"26", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTabMinWidth, Type = Integer, Dynamic = False, Default = \"90", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTabMaxWidth, Type = Integer, Dynamic = False, Default = \"220", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTabCloseMinWidth, Type = Integer, Dynamic = False, Default = \"120", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTabTitleMinWidth, Type = Integer, Dynamic = False, Default = \"56", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTabCloseZone, Type = Integer, Dynamic = False, Default = \"22", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kNewTabWidth, Type = Integer, Dynamic = False, Default = \"26", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTabTextInset, Type = Integer, Dynamic = False, Default = \"8", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTabTextBaseline, Type = Integer, Dynamic = False, Default = \"8", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMenuCheckAll, Type = String, Dynamic = False, Default = \"Check All", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMenuCheckNone, Type = String, Dynamic = False, Default = \"Check None", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTagCheckAll, Type = String, Dynamic = False, Default = \"checkAll", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTagCheckNone, Type = String, Dynamic = False, Default = \"checkNone", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFrameColor, Type = Color, Dynamic = False, Default = \"&cC6C6C6", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTabStripColor, Type = Color, Dynamic = False, Default = \"&cECECEC", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTabActiveColor, Type = Color, Dynamic = False, Default = \"&cFFFFFF", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTabInactiveColor, Type = Color, Dynamic = False, Default = \"&cDADADA", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTabBorderColor, Type = Color, Dynamic = False, Default = \"&cC6C6C6", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTabTextColor, Type = Color, Dynamic = False, Default = \"&c282828", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTabCloseColor, Type = Color, Dynamic = False, Default = \"&c787878", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTabCloseGlyph, Type = String, Dynamic = False, Default = \"x", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kNewTabGlyph, Type = String, Dynamic = False, Default = \"+", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kDividerColor, Type = Color, Dynamic = False, Default = \"&c8E8E93", Scope = Private
	#tag EndConstant

	#tag Note, Name = Description
		The one window: version popup + search field + navigation buttons across the top,
		topic tree on the left, documentation viewer on the right, split by a draggable
		divider.

		Layout is done in code from named constants; the IDE-time control positions only
		mirror them.
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.15.1
		Last change: 2026-07-29 12:28

		------------------------------------------------------------
		0.15.1 — 2026-07-29

		12:28  [FIX] Tabs were captioned with the raw page key — doc:api/console/index rather than Console — because nothing ever set VNSHelpTabState.Title. The assignment existed only in a draft that was replaced by the viewer-per-tab design, and OpenInNewTab was even handed a title and discarded it. DisplayFragment now names the active tab from the page it is showing, and a new tab keeps the label its link carried for the group pages the provider cannot name.

		------------------------------------------------------------
		0.15.0 — 2026-07-29

		11:03  [NEW] "Open Link in New Window" from WebKit's own context menu opens a tab. The NewWindow event hands over a URL and expects a viewer to load it into, or Nil to refuse — but our hrefs are bxh:<n> and mean nothing to WebKit, so the link is resolved here and opened through the same deferred path Cmd-click uses, and Nil is returned because the work is already done.

		------------------------------------------------------------
		0.14.1 — 2026-07-29

		11:00  [FIX] 'Each' is a reserved word in Xojo — it belongs to For Each — and using it as a local name broke the five tab-strip methods with 37 cascading errors. Renamed to tabW, which is what the Claude Browser original called tw. Renaming a borrowed variable for readability is not free.

		------------------------------------------------------------
		0.14.0 — 2026-07-29

		10:58  [NEW] Tabs. Each tab owns a DesktopHTMLViewer created at runtime with Self.AddControl and wired with AddHandler, so switching is a Visible toggle that keeps the document loaded and the scroll position intact — no re-render. Pattern taken from MainWindow.NewTab / WireViewer / SelectTab in /Users/jeanyves/xojo2015/Claude Browser.
		10:58  [NEW] The window still works from its own mCurrentPageKey, mLinkKeys, history and so on; a tab is a snapshot of those, saved on the way out and restored on the way in. That is why navigation, link resolution and history needed no changes at all to gain tabs.
		10:58  [NEW] CancelLoad and DocumentComplete became HandleCancelLoad / HandleDocumentComplete taking the viewer. Tab 0 is the design-time viewer and keeps design-time events that delegate to them; every later tab reaches them through AddHandler.
		10:58  [FIX] HandleDocumentComplete keys on the sending viewer rather than the active one. A background tab loads asynchronously and can finish after the user has switched away, which would otherwise have highlighted and scrolled the wrong page.
		10:58  [NEW] Cmd-click opens a background tab, from a link or from the topic list. Neither CancelLoad nor SelectionChanged reports a modifier, so it is read from Keyboard.AsyncCommandKey — for the list, in MouseDown, which fires first.
		10:58  [NEW] The tab strip is a hand-drawn DesktopCanvas with a "+" and per-tab close crosses, hit-tested by x \ TabWidth. It takes height only when there is more than one tab, as the result count does.
		10:58  [NEW] New Tab (Cmd+T) and Close Tab (Cmd+W). The last tab is never closed.

		------------------------------------------------------------
		0.12.2 — 2026-07-29

		10:50  [FIX] DocumentComplete marks first and scrolls to the anchor second, and tells the highlighter not to scroll when there is an anchor. Selecting TCPSocket.Listen from a search now lands on Listen rather than the top of the page.

		------------------------------------------------------------
		0.12.0 — 2026-07-25

		19:00  [NEW] A result count above the topic list while a search is running. It takes its strip of height only while showing: with no search there is nothing to say, and a permanently reserved strip would just shorten the tree for nothing. Layout is re-run only when it appears or disappears, since the text changing moves nothing.
		19:00  [COSMETIC] The count sits above the list alone, so the viewer keeps the full window height.

		------------------------------------------------------------
		0.11.0 — 2026-07-25

		18:41  [NEW] ReapplySettings, public so the settings window can call it. Pushes the preference onto the provider and re-runs whatever is in the search field, so a change to result ordering is visible at once.

		------------------------------------------------------------
		0.10.1 — 2026-07-25

		18:36  [NEW] A search selects and shows its first result rather than leaving a list to be clicked. The selection is made with mSuppressSelectionLoad down on purpose: SelectionChanged is what loads the page and records the visit, so Back works from a search exactly as it does from the tree.

		------------------------------------------------------------
		0.9.0 — 2026-07-25

		18:20  [NEW] A match-mode popup immediately left of the search field: and / or / exact, applied when the query has more than one word. Defaults to and. The mode travels in the row tag, as the version and favorites popups already do, and changing it re-runs the search at once rather than waiting for the next keystroke.
		18:20  [NEW] The highlighter marks exactly the terms that were searched for, so "and" with two words highlights both and "exact" highlights the phrase.

		------------------------------------------------------------
		0.8.3 — 2026-07-25

		17:04  [NEW] CancelLoad resolves the bxhweb: scheme through OpenExternalLink. The older form — a bxh: link whose target is marked "url:" — is still handled, so nothing depends on the scheme and the marker agreeing.

		------------------------------------------------------------
		0.8.2 — 2026-07-25

		16:52  [FIX] Cmd+D still did nothing after AutoEnable = True, so the shortcut was never the problem — the handler binding was. Each handler now carries its menu item's own name, which is the form the IDE writes and the only one proven to bind in this codebase. The Handle<Item> naming was introduced only so MenuBarSelected could write NavigateBack.Enabled without that resolving to the method.
		16:52  [BREAKING] MenuBarSelected removed. It was the sole reason for the renamed handlers, so removing it removes the conflict rather than working around it: AutoEnable = True does the enabling, and each handler no-ops when it does not apply — GoToHistory bounds-checks, the other two check what they need.
		16:52  [COSMETIC] The menu item reads a static "Toggle Favorite" rather than flipping between Add and Remove. What is given up is the menu's own grey-out and wording; the toolbar buttons still grey out and the favorites popup still reads Add this page or Remove this page, so the state stays visible where it is actually looked at.

		------------------------------------------------------------
		0.8.1 — 2026-07-25

		16:45  [FIX] Cmd+D recorded nothing. The Navigate items carried AutoEnable = False, which leaves a menu item disabled until MenuBarSelected has run — and a Cmd-key shortcut does not reliably wait for that, so the keystroke reached a disabled item and was dropped. They are AutoEnable = True now; MenuBarSelected still refines the wording and switches an item off when it does not apply.
		16:45  [BREAKING] Favorites moved from a pinned tree node to a popup menu left of the globe, at the user's request. It is a menu rather than a chooser: row 0 is a resting label so the control always reads "Favorites", and every other row carries its action in the row tag — tags rather than indexes, because a separator occupies a row of its own, the same reason VersionPopup resolves through a tag.
		16:45  [FIX] The popup offers "Add this page" / "Remove this page" itself, so adding a favorite no longer depends on the menu bar having had a chance to enable anything. That is the path that cannot fail the way Cmd+D did.
		16:45  [REFACTOR] ShowFavorites, RefreshFavoritesRow and the kFavoritesKey page all went with the tree node. A page key of "fav:" left in an older preferences file degrades to the welcome page, which is what it should do.

		------------------------------------------------------------
		0.8.0 — 2026-07-25

		16:34  [NEW] A globe button, hard right on the toolbar row as in the IDE's own help window, opening the current page on documentation.xojo.com. Disabled whenever the provider offers no address, which is always on the legacy era.
		16:34  [NEW] Favorites: a pinned "★ Favorites" node above the documentation, always present so an empty one reads as "nothing saved yet" rather than a missing feature. Its children come from the preferences rather than the provider, and selecting it shows an index of itself the way a group row does.
		16:34  [NEW] A Navigate menu — Back (Cmd+[), Forward (Cmd+]), Add to Favorites (Cmd+D) and Open on the Web. All four carry AutoEnable = False and are driven from MenuBarSelected, which also decides whether the favorite item reads Add or Remove, since one shortcut toggles and the wording is the only thing that says which way it will go.
		16:34  [FIX] The event is MenuBarSelected, not EnableMenuItems: that name is API 1 and is not on DesktopWindow at all in 2026r1.2.
		16:34  [FIX] Only this release's favorites are listed. A key from another provider would offer a row that cannot open; they come back when that release is selected.

		------------------------------------------------------------
		0.7.0 — 2026-07-25

		15:04  [NEW] CancelLoad resolves a clicked "bxh:<n>" against one link table that now serves both generated overview pages and rewritten article links; navigation is still deferred through Timer.CallLater. An external target opens with System.GotoURL (ShowURL has been deprecated since 2021r2), and an unresolvable one is swallowed so the viewer is never sent to a file that is not there.
		15:04  [NEW] Back and Forward over the window's own history stack. The viewer's CanGoBack is meaningless here: it only ever sees one file being rewritten in place. What is recorded is the choice the user made, not the page it produced, so a group key that resolves to an overview page replays identically. The stack is cleared when the release changes, because page keys are not portable between providers.
		15:04  [REFACTOR] mOverviewTopics replaced by mLinkKeys / mLinkTitles, and the window's own kInternalScheme constant dropped in favour of VNSHelpDocSet.kLinkScheme so the scheme has one definition.

		------------------------------------------------------------
		0.1.0 — 2026-07-24

		22:49  [NEW] Initial creation — control layout, Layout() from Opening/Resized/Resizing, version popup wired to VNSHelpVersionScanner, draggable divider.
		22:49  [FIX] Placeholder page rendered without its stylesheet and swallowed its heading: an unescaped "=" inside the kMessageShellHead constant truncated the value mid-tag. The shell is now generated from tools/help-message-shell.html by sync_xojo_constant.py.
		22:49  [NEW] SearchField is a DesktopSearchField with a Recent Searches menu (macOS); Pressed records the term, skipping duplicates.
		22:49  [COSMETIC] Version popup shows the bare version number and separates the two documentation eras with a separator row; the version index travels in the row tag.
	#tag EndNote
#tag EndWindowCode

#tag Events PlatformDesktop
	#tag Event
		Sub ValueChanged()
		  PlatformFilterChanged
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events PlatformTypesFrame
	#tag Event
		Function ConstructContextualMenu(base As DesktopMenuItem, x As Integer, y As Integer) As Boolean
		  #Pragma Unused x
		  #Pragma Unused y
		  Return BuildGroupMenu(base)
		End Function
	#tag EndEvent
	#tag Event
		Function ContextualMenuItemSelected(selectedItem As DesktopMenuItem) As Boolean
		  Return ApplyGroupCommand(selectedItem, VNSHelpDocSet.kPlatformTypes)
		End Function
	#tag EndEvent
	#tag Event
		Sub Paint(g As Graphics, areas() As Rect)
		  #Pragma Unused areas
		  // A hairline outline only -- no fill, so the row keeps the window's own
		  // background in both light and dark appearance.
		  g.DrawingColor = kFrameColor
		  g.PenSize = 1
		  g.DrawRoundRectangle(0, 0, g.Width - 1, g.Height - 1, kFrameRadius, kFrameRadius)
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events PlatformSystemsFrame
	#tag Event
		Function ConstructContextualMenu(base As DesktopMenuItem, x As Integer, y As Integer) As Boolean
		  #Pragma Unused x
		  #Pragma Unused y
		  Return BuildGroupMenu(base)
		End Function
	#tag EndEvent
	#tag Event
		Function ContextualMenuItemSelected(selectedItem As DesktopMenuItem) As Boolean
		  Return ApplyGroupCommand(selectedItem, VNSHelpDocSet.kPlatformSystems)
		End Function
	#tag EndEvent
	#tag Event
		Sub Paint(g As Graphics, areas() As Rect)
		  #Pragma Unused areas
		  // A hairline outline only -- no fill, so the row keeps the window's own
		  // background in both light and dark appearance.
		  g.DrawingColor = kFrameColor
		  g.PenSize = 1
		  g.DrawRoundRectangle(0, 0, g.Width - 1, g.Height - 1, kFrameRadius, kFrameRadius)
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events PlatformMobile
	#tag Event
		Sub ValueChanged()
		  PlatformFilterChanged
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events PlatformWeb
	#tag Event
		Sub ValueChanged()
		  PlatformFilterChanged
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events PlatformIOS
	#tag Event
		Sub ValueChanged()
		  PlatformFilterChanged
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events PlatformAndroid
	#tag Event
		Sub ValueChanged()
		  PlatformFilterChanged
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events PlatformMacOS
	#tag Event
		Sub ValueChanged()
		  PlatformFilterChanged
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events PlatformWindows
	#tag Event
		Sub ValueChanged()
		  PlatformFilterChanged
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events PlatformLinux
	#tag Event
		Sub ValueChanged()
		  PlatformFilterChanged
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events VersionPopup
	#tag Event
		Sub SelectionChanged(item As DesktopMenuItem)
		  #Pragma Unused item
		  // The selected row is read back through SelectedVersion, which resolves it
		  // via the row tag — separator rows make the row index unreliable.
		  LoadDocSet
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events TopicList
	#tag Event
		Function MouseDown(x As Integer, y As Integer) As Boolean
		  #Pragma Unused x
		  #Pragma Unused y
		  // Recorded here and consumed by SelectionChanged, which fires next and cannot
		  // see a modifier itself. Returning False lets the click select as usual.
		  mSelectionWantsNewTab = CommandKeyDown

		  Return False
		End Function
	#tag EndEvent
	#tag Event
		Sub SelectionChanged()
		  If mSuppressSelectionLoad Then Return

		  Var row As Integer = Me.SelectedRowIndex
		  If row < 0 Then Return

		  // MouseDown fires first and records whether Cmd was down, because
		  // SelectionChanged reports no modifier of its own.
		  If mSelectionWantsNewTab Then
		    mSelectionWantsNewTab = False
		    OpenInNewTab(Me.RowTagAt(row).StringValue, Me.CellTextAt(row, 0))
		    Return
		  End If

		  ShowTopicKey(Me.RowTagAt(row).StringValue, Me.CellTextAt(row, 0))
		End Sub
	#tag EndEvent
	#tag Event
		Sub RowExpanded(row As Integer)
		  // Children are added lazily and are discarded again on collapse, so this
		  // runs on every expansion rather than only the first.
		  If mDocSet = Nil Then Return

		  Var key As String = Me.RowTagAt(row).StringValue
		  If key = "" Then Return

		  mSuppressSelectionLoad = True

		  For Each topic As VNSHelpTopic In mDocSet.ChildTopics(key)
		    AddTopicRow(topic)
		  Next

		  mSuppressSelectionLoad = False
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events HelpViewer
	#tag Event
		Function CancelLoad(URL As String) As Boolean
		  // Tab 0's viewer is the one placed at design time, so it keeps design-time
		  // events; every later tab is wired with AddHandler. Both land here.
		  Return HandleCancelLoad(Me, URL)
		End Function
	#tag EndEvent
	#tag Event
		Sub DocumentComplete(url As String)
		  HandleDocumentComplete(Me, url)
		End Sub
	#tag EndEvent
	#tag Event
		Function NewWindow(URL As String) As DesktopHTMLViewer
		  Return HandleNewWindow(Me, URL)
		End Function
	#tag EndEvent
#tag EndEvents
#tag Events SearchField
	#tag Event
		Sub Pressed()
		  // Return, the Clear button, or a pick from the Recent Searches menu.
		  // Searches at once, ahead of any pending debounce.
		  Timer.CancelCallLater(AddressOf RunPendingSearch)
		  RememberSearch(Me.Text)
		  ApplySearch(Me.Text)
		End Sub
	#tag EndEvent
	#tag Event
		Sub TextChanged()
		  // Live search, debounced.
		  //
		  // Ranking reads the matching pages to count occurrences, so running it on
		  // every keystroke would be far too much work. Instead each keystroke
		  // restarts a short timer and only the last one searches.
		  Timer.CancelCallLater(AddressOf RunPendingSearch)

		  Var term As String = Me.Text.Trim
		  If term = "" Then
		    // Restoring the tree is cheap, so it happens immediately.
		    ApplySearch("")
		    Return
		  End If

		  // One or two characters match most of the documentation, which is never a
		  // useful result and is the most expensive case to rank.
		  If term.Length < kMinimumSearchLength Then Return

		  Timer.CallLater(kSearchDebounceMilliseconds, AddressOf RunPendingSearch)
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events Divider
	#tag Event
		Function MouseDown(x As Integer, y As Integer) As Boolean
		  #Pragma Unused y
		  mDragOffsetX = x
		  Return True
		End Function
	#tag EndEvent
	#tag Event
		Sub MouseDrag(x As Integer, y As Integer)
		  #Pragma Unused y
		  // x is relative to the divider, which Layout then moves to mDividerX —
		  // the classic self-correcting splitter idiom.
		  mDividerX = Me.Left + (x - mDragOffsetX)
		  Layout
		End Sub
	#tag EndEvent
	#tag Event
		Sub MouseEnter()
		  Me.MouseCursor = System.Cursors.SplitterEastWest
		End Sub
	#tag EndEvent
	#tag Event
		Sub MouseExit()
		  Me.MouseCursor = System.Cursors.StandardPointer
		End Sub
	#tag EndEvent
	#tag Event
		Sub Paint(g As Graphics, areas() As Rect)
		  #Pragma Unused areas
		  g.DrawingColor = kDividerColor
		  Var cx As Integer = g.Width \ 2
		  g.DrawLine(cx, 0, cx, g.Height)
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events BtnBack
	#tag Event
		Sub Pressed()
		  GoToHistory(mHistoryPosition - 1)
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events BtnForward
	#tag Event
		Sub Pressed()
		  GoToHistory(mHistoryPosition + 1)
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events BtnWeb
	#tag Event
		Sub Pressed()
		  OpenCurrentPageOnTheWeb
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events FavoritesPopup
	#tag Event
		Sub SelectionChanged(item As DesktopMenuItem)
		  #Pragma Unused item
		  // Rebuilding the popup changes its selection, so the rebuild must not be read
		  // back as a choice the user made.
		  If mSuppressFavoriteSelection Then Return

		  FavoriteChosen
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events MatchPopup
	#tag Event
		Sub SelectionChanged(item As DesktopMenuItem)
		  #Pragma Unused item
		  // Re-run at once rather than waiting for the next keystroke: changing the mode
		  // is itself the user asking for different results.
		  VNSHelpPreferences.SearchMode = Me.SelectedRowIndex
		  VNSHelpPreferences.Save

		  Timer.CancelCallLater(AddressOf RunPendingSearch)
		  ApplySearch(SearchField.Text)
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events TabBar
	#tag Event
		Sub Paint(g As Graphics, areas() As Rect)
		  #Pragma Unused areas
		  PaintTabBar(g)
		End Sub
	#tag EndEvent
	#tag Event
		Function MouseDown(x As Integer, y As Integer) As Boolean
		  #Pragma Unused y
		  // Order matters: the "+" sits past the last tab, and a close cross sits inside
		  // one, so both are tested before the tab itself.
		  Var tabW As Integer = TabWidth
		  Var plusAt As Integer = mTabs.Count * tabW
		  If x >= plusAt And x < plusAt + kNewTabWidth Then
		    NewEmptyTab
		    Return True
		  End If

		  Var closing As Integer = CloseZoneAt(x)
		  If closing >= 0 Then
		    CloseTab(closing)
		    Return True
		  End If

		  Var index As Integer = TabIndexAt(x)
		  If index >= 0 Then SelectTab(index)

		  Return True
		End Function
	#tag EndEvent
#tag EndEvents

#tag DesktopWindow
Begin DesktopWindow VNSHelpSettingsWindow
   Backdrop        =   0
   BackgroundColor =   &cFFFFFF
   Composite       =   False
   DefaultLocation =   2
   FullScreen      =   False
   HasBackgroundColor=   False
   HasCloseButton  =   True
   HasFullScreenButton=   False
   HasMaximizeButton=   False
   HasMinimizeButton=   False
   HasTitleBar     =   True
   Height          =   414
   ImplicitInstance=   True
   MacProcID       =   0
   MaximumHeight   =   32000
   MaximumWidth    =   32000
   MenuBar         =   0
   MenuBarVisible  =   True
   MinimumHeight   =   64
   MinimumWidth    =   64
   Resizeable      =   False
   Title           =   "Settings"
   Type            =   1
   Visible         =   True
   Width           =   460
   Begin DesktopLabel SettingsHeading
      AllowAutoDeactivate=   True
      Bold            =   True
      Enabled         =   True
      FontSize        =   13.0
      Height          =   20
      Index           =   -2147483648
      Left            =   24
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      Multiline       =   False
      Scope           =   0
      Selectable      =   False
      TabIndex        =   0
      TabPanelIndex   =   0
      Text            =   "Search results"
      TextAlignment   =   0
      TextColor       =   &c222222
      Top             =   24
      Transparent     =   False
      Visible         =   True
      Width           =   412
   End
   Begin DesktopCheckBox ChkDeprecatedLast
      AllowAutoDeactivate=   True
      Caption         =   "#App.kSettingDeprecatedLast"
      Enabled         =   True
      Height          =   20
      Index           =   -2147483648
      Left            =   24
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      Scope           =   0
      TabIndex        =   1
      TabPanelIndex   =   0
      Tooltip         =   ""
      Top             =   54
      Transparent     =   False
      Value           =   True
      VisualState     =   0
      Visible         =   True
      Width           =   412
   End
   Begin DesktopLabel DeprecatedExplanation
      AllowAutoDeactivate=   True
      Bold            =   False
      Enabled         =   True
      FontSize        =   11.0
      Height          =   48
      Index           =   -2147483648
      Left            =   44
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      Multiline       =   True
      Scope           =   0
      Selectable      =   False
      TabIndex        =   2
      TabPanelIndex   =   0
      Text            =   ""
      TextAlignment   =   0
      TextColor       =   &c606060
      Top             =   78
      Transparent     =   False
      Visible         =   True
      Width           =   392
   End
   Begin DesktopLabel MCPHeading
      AllowAutoDeactivate=   True
      Bold            =   True
      Enabled         =   True
      FontSize        =   0.0
      Height          =   20
      Index           =   -2147483648
      Left            =   24
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      Multiline       =   True
      Scope           =   0
      Selectable      =   False
      TabIndex        =   4
      TabPanelIndex   =   0
      Text            =   ""
      TextAlignment   =   0
      Top             =   142
      Transparent     =   False
      Visible         =   True
      Width           =   412
   End
   Begin DesktopCheckBox ChkMCPEnabled
      AllowAutoDeactivate=   True
      Bold            =   False
      Caption         =   ""
      Enabled         =   True
      FontSize        =   0.0
      Height          =   20
      Index           =   -2147483648
      Italic          =   False
      Left            =   24
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      Scope           =   0
      TabIndex        =   5
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   170
      Transparent     =   False
      Underline       =   False
      Value           =   False
      VisualState     =   0
      Visible         =   True
      Width           =   412
   End
   Begin DesktopLabel MCPPortLabel
      AllowAutoDeactivate=   True
      Bold            =   False
      Enabled         =   True
      FontSize        =   0.0
      Height          =   20
      Index           =   -2147483648
      Left            =   44
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      Multiline       =   True
      Scope           =   0
      Selectable      =   False
      TabIndex        =   6
      TabPanelIndex   =   0
      Text            =   ""
      TextAlignment   =   0
      Top             =   198
      Transparent     =   False
      Visible         =   True
      Width           =   40
   End
   Begin DesktopTextField FieldMCPPort
      AllowAutoDeactivate=   True
      AllowFocusRing  =   True
      AllowSpellChecking=   False
      AllowTabs       =   False
      Bold            =   False
      BorderStyle     =   0
      Enabled         =   True
      FontSize        =   0.0
      Height          =   22
      Hint            =   ""
      Index           =   -2147483648
      Left            =   88
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      MaximumCharactersAllowed=   5
      Password        =   False
      ReadOnly        =   False
      Scope           =   0
      TabIndex        =   7
      TabPanelIndex   =   0
      TabStop         =   True
      Text            =   ""
      TextAlignment   =   0
      Tooltip         =   ""
      Top             =   196
      Transparent     =   False
      Visible         =   True
      Width           =   80
   End
   Begin DesktopLabel MCPStatus
      AllowAutoDeactivate=   True
      Bold            =   False
      Enabled         =   True
      FontSize        =   0.0
      Height          =   20
      Index           =   -2147483648
      Left            =   180
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      Multiline       =   True
      Scope           =   0
      Selectable      =   False
      TabIndex        =   8
      TabPanelIndex   =   0
      Text            =   ""
      TextAlignment   =   0
      TextColor       =   &c606060
      Top             =   198
      Transparent     =   False
      Visible         =   True
      Width           =   256
   End
   Begin DesktopLabel MCPExplanation
      AllowAutoDeactivate=   True
      Bold            =   False
      Enabled         =   True
      FontSize        =   11.0
      Height          =   48
      Index           =   -2147483648
      Left            =   44
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      Multiline       =   True
      Scope           =   0
      Selectable      =   False
      TabIndex        =   9
      TabPanelIndex   =   0
      Text            =   ""
      TextAlignment   =   0
      TextColor       =   &c606060
      Top             =   228
      Transparent     =   False
      Visible         =   True
      Width           =   392
   End
   Begin DesktopButton BtnOpenSupportFolder
      AllowAutoDeactivate=   True
      Bold            =   False
      Cancel          =   False
      Caption         =   ""
      Default         =   False
      Enabled         =   True
      Height          =   24
      Index           =   -2147483648
      Left            =   24
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   False
      MacButtonStyle  =   0
      Scope           =   0
      TabIndex        =   10
      TabPanelIndex   =   0
      Top             =   290
      Transparent     =   False
      Visible         =   True
      Width           =   280
   End
   Begin DesktopLabel InstalledDocsNote
      AllowAutoDeactivate=   True
      Bold            =   False
      Enabled         =   True
      FontSize        =   11.0
      Height          =   32
      Index           =   -2147483648
      Left            =   24
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   False
      Multiline       =   True
      Scope           =   0
      Selectable      =   False
      TabIndex        =   11
      TabPanelIndex   =   0
      Text            =   ""
      TextAlignment   =   0
      TextColor       =   &c606060
      Top             =   320
      Transparent     =   False
      Visible         =   True
      Width           =   412
   End
   Begin DesktopButton BtnDone
      AllowAutoDeactivate=   True
      Bold            =   False
      Cancel          =   True
      Caption         =   "OK"
      Default         =   True
      Enabled         =   True
      Height          =   24
      Index           =   -2147483648
      Left            =   356
      LockBottom      =   True
      LockLeft        =   False
      LockRight       =   True
      LockTop         =   False
      MacButtonStyle  =   0
      Scope           =   0
      TabIndex        =   3
      TabPanelIndex   =   0
      Top             =   366
      Transparent     =   False
      Visible         =   True
      Width           =   80
   End
End
#tag EndDesktopWindow

	#tag Event
		Sub Opening()
		  ChkDeprecatedLast.Value = VNSHelpPreferences.DeprecatedLast
		  DeprecatedExplanation.Text = kDeprecatedExplanation

		  MCPHeading.Text = kMCPHeading
		  ChkMCPEnabled.Caption = kMCPEnabledCaption
		  MCPPortLabel.Text = kMCPPortLabel
		  MCPExplanation.Text = kMCPExplanation

		  BtnOpenSupportFolder.Caption = kOpenFolderCaption
		  InstalledDocsNote.Text = kInstalledDocsNote

		  ChkMCPEnabled.Value = VNSHelpPreferences.MCPEnabled
		  FieldMCPPort.Text = VNSHelpPreferences.MCPPort.ToString
		  ShowMCPStatus
		End Sub
	#tag EndEvent

	#tag Method, Flags = &h21
		Private Sub ShowMCPStatus()
		  // What the server is actually doing, not what the checkbox says. The two
		  // differ exactly when it matters — a port already taken leaves the box
		  // ticked and nothing listening, and without this the window would lie.
		  If Not VNSHelpMainWindow.MCPListening Then
		    If Not VNSHelpPreferences.MCPEnabled Then
		      MCPStatus.Text = kMCPStatusOff
		    ElseIf VNSHelpMainWindow.MCPErrorCode = VNSHelpMCPServer.kErrorNoLoopback Then
		      MCPStatus.Text = kMCPStatusNoLoopback
		    Else
		      MCPStatus.Text = kMCPStatusFailed
		    End If
		    Return
		  End If

		  MCPStatus.Text = kMCPStatusOn + VNSHelpPreferences.MCPPort.ToString
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ApplyPort()
		  // Read back from the preference rather than from the field: the setter is
		  // what decides whether the typed number was usable, so this shows the user
		  // the value that will actually be used.
		  VNSHelpPreferences.MCPPort = FieldMCPPort.Text.ToInteger
		  VNSHelpPreferences.Save
		  FieldMCPPort.Text = VNSHelpPreferences.MCPPort.ToString

		  VNSHelpMainWindow.ReapplySettings
		  ShowMCPStatus
		End Sub
	#tag EndMethod

	#tag Constant, Name = kOpenFolderCaption, Type = String, Dynamic = False, Default = \"Open the documentation folder\xE2\x80\xA6", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kInstalledDocsNote, Type = String, Dynamic = False, Default = \"File \xE2\x96\xB8 Install Documentation puts a set here. Remove one by deleting its folder; the app rereads them on the next launch.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kNoFolderYet, Type = String, Dynamic = False, Default = \"Nothing has been installed yet\x2C so the folder does not exist.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMCPHeading, Type = String, Dynamic = False, Default = \"MCP server", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMCPEnabledCaption, Type = String, Dynamic = False, Default = \"Serve this documentation to an AI assistant (MCP)", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMCPPortLabel, Type = String, Dynamic = False, Default = \"Port", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMCPStatusOn, Type = String, Dynamic = False, Default = \"Listening on 127.0.0.1:", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMCPStatusOff, Type = String, Dynamic = False, Default = \"Not running.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMCPStatusNoLoopback, Type = String, Dynamic = False, Default = \"No loopback interface found\x2C so it was not started.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMCPStatusFailed, Type = String, Dynamic = False, Default = \"Could not listen — that port may already be in use.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMCPExplanation, Type = String, Dynamic = False, Default = \"Lets a local assistant look things up in the documentation installed on this machine. It listens on 127.0.0.1 only\x2C never on the network\x2C and only while Better Xojo Help is running. Help ▸ MCP Setup has the client configuration.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kDeprecatedExplanation, Type = String, Dynamic = False, Default = \"A deprecated page repeats the name of whatever replaced it\x2C so counting occurrences ranks it above the page you wanted. Turn this off to rank deprecated results purely by occurrence count\x2C like everything else.", Scope = Private
	#tag EndConstant

	#tag Note, Name = Description
		The settings window.

		Each control writes its preference and applies it immediately — there is no OK
		to confirm and no Cancel to revert, because a search setting is easier to judge
		by its effect than by its name. OK only closes the window.
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.11.0
		Last change: 2026-07-25 18:41

		------------------------------------------------------------
		0.11.0 — 2026-07-25

		18:41  [NEW] Initial creation — one checkbox, for whether deprecated results sort last.
	#tag EndNote

#tag Events ChkDeprecatedLast
	#tag Event
		Sub ValueChanged()
		  // Applied at once rather than on OK: the effect on the result list is the
		  // clearest explanation of what the setting does.
		  VNSHelpPreferences.DeprecatedLast = Me.Value
		  VNSHelpPreferences.Save
		  VNSHelpMainWindow.ReapplySettings
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events ChkMCPEnabled
	#tag Event
		Sub ValueChanged()
		  VNSHelpPreferences.MCPEnabled = Me.Value
		  VNSHelpPreferences.Save
		  VNSHelpMainWindow.ReapplySettings
		  ShowMCPStatus
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events FieldMCPPort
	#tag Event
		Sub FocusLost()
		  ApplyPort
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events BtnOpenSupportFolder
	#tag Event
		Sub Pressed()
		  // Opens the folder so a set installed by hand can be removed by hand. There is
		  // deliberately no delete button: the Finder already does this well, and a
		  // mistaken click here would throw away a 190 MB download the user may have no
		  // other copy of.
		  Var folder As FolderItem = VNSHelpDocInstaller.InstalledRoot(True)
		  If folder = Nil Or Not folder.Exists Then
		    MessageBox(kNoFolderYet)
		    Return
		  End If

		  folder.Open
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events BtnDone
	#tag Event
		Sub Pressed()
		  Self.Close
		End Sub
	#tag EndEvent
#tag EndEvents

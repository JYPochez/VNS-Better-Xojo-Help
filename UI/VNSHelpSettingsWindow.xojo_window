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
   Height          =   196
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
      Top             =   148
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
		End Sub
	#tag EndEvent

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
#tag Events BtnDone
	#tag Event
		Sub Pressed()
		  Self.Close
		End Sub
	#tag EndEvent
#tag EndEvents

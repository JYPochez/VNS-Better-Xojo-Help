#tag DesktopWindow
Begin DesktopWindow VNSHelpReleasePromptWindow
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
   Height          =   192
   ImplicitInstance=   False
   MacProcID       =   0
   MaximumHeight   =   32000
   MaximumWidth    =   32000
   MenuBar         =   0
   MenuBarVisible  =   True
   MinimumHeight   =   64
   MinimumWidth    =   64
   Resizeable      =   False
   Title           =   "Install Documentation"
   Type            =   1
   Visible         =   True
   Width           =   460
   Begin DesktopLabel PromptLabel
      AllowAutoDeactivate=   True
      Bold            =   False
      Enabled         =   True
      FontSize        =   0.0
      Height          =   64
      Index           =   -2147483648
      Left            =   20
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      Multiline       =   True
      Scope           =   0
      Selectable      =   False
      TabIndex        =   0
      TabPanelIndex   =   0
      Text            =   ""
      TextAlignment   =   0
      Top             =   20
      Transparent     =   False
      Visible         =   True
      Width           =   420
   End
   Begin DesktopTextField ReleaseField
      AllowAutoDeactivate=   True
      AllowFocusRing  =   True
      AllowSpellChecking=   False
      AllowTabs       =   False
      Bold            =   False
      BorderStyle     =   0
      Enabled         =   True
      FontSize        =   0.0
      Height          =   22
      Hint            =   "2020r2.1"
      Index           =   -2147483648
      Left            =   20
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      MaximumCharactersAllowed=   12
      Password        =   False
      ReadOnly        =   False
      Scope           =   0
      TabIndex        =   1
      TabPanelIndex   =   0
      Text            =   ""
      TextAlignment   =   0
      Tooltip         =   ""
      Top             =   96
      Transparent     =   False
      Visible         =   True
      Width           =   140
   End
   Begin DesktopButton BtnPromptCancel
      AllowAutoDeactivate=   True
      Bold            =   False
      Cancel          =   True
      Caption         =   "Cancel"
      Default         =   False
      Enabled         =   True
      Height          =   24
      Index           =   -2147483648
      Left            =   264
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   False
      LockRight       =   True
      LockTop         =   False
      MacButtonStyle  =   0
      Scope           =   0
      TabIndex        =   2
      TabPanelIndex   =   0
      Top             =   144
      Transparent     =   False
      Visible         =   True
      Width           =   80
   End
   Begin DesktopButton BtnPromptOK
      AllowAutoDeactivate=   True
      Bold            =   False
      Cancel          =   False
      Caption         =   "Install"
      Default         =   True
      Enabled         =   True
      Height          =   24
      Index           =   -2147483648
      Left            =   356
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   False
      LockRight       =   True
      LockTop         =   False
      MacButtonStyle  =   0
      Scope           =   0
      TabIndex        =   3
      TabPanelIndex   =   0
      Top             =   144
      Transparent     =   False
      Visible         =   True
      Width           =   80
   End
End
#tag EndDesktopWindow

#tag WindowCode
	#tag Event
		Sub Opening()
		  PromptLabel.Text = Prompt
		  ReleaseField.Text = ReleaseValue
		  ReleaseField.SelectAll
		End Sub
	#tag EndEvent

	#tag Property, Flags = &h0
		Prompt As String
	#tag EndProperty

	#tag Property, Flags = &h0
		ReleaseValue As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Accepted As Boolean
	#tag EndProperty

	#tag Note, Name = Description
		Asks which Xojo release a documentation file belongs to.

		It exists because API 2 has no input dialog: `InputBox` is gone and
		`MessageDialog` carries no text field. Set Prompt and ReleaseValue, call
		ShowModal, then read Accepted and ReleaseValue back.

		The field is pre-filled and selected even when the release was detected, because
		detection is partial and a wrong release is invisible until the version popup
		shows the wrong number.
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.18.0
		Last change: 2026-07-30 16:14

		------------------------------------------------------------
		0.18.0 — 2026-07-30

		16:14  [NEW] Initial creation.
	#tag EndNote

#tag EndWindowCode

#tag Events BtnPromptOK
	#tag Event
		Sub Pressed()
		  ReleaseValue = ReleaseField.Text.Trim
		  Accepted = True
		  Self.Close
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events BtnPromptCancel
	#tag Event
		Sub Pressed()
		  Accepted = False
		  Self.Close
		End Sub
	#tag EndEvent
#tag EndEvents

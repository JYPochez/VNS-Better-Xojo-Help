#tag DesktopWindow
Begin DesktopWindow VNSHelpUpdateOfferWindow
   Backdrop        =   0
   BackgroundColor =   &cFFFFFF
   Composite       =   False
   DefaultLocation =   2
   FullScreen      =   False
   HasBackgroundColor=   False
   HasCloseButton  =   False
   HasFullScreenButton=   False
   HasMaximizeButton=   False
   HasMinimizeButton=   False
   HasTitleBar     =   True
   Height          =   520
   ImplicitInstance=   False
   MacProcID       =   0
   MaximumHeight   =   32000
   MaximumWidth    =   32000
   MenuBar         =   0
   MenuBarVisible  =   True
   MinimumHeight   =   360
   MinimumWidth    =   560
   Resizeable      =   True
   Title           =   "Update"
   Type            =   1
   Visible         =   True
   Width           =   660
   Begin DesktopLabel OfferHeading
      AllowAutoDeactivate=   True
      Bold            =   True
      Enabled         =   True
      FontSize        =   15.0
      Height          =   24
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
      Width           =   620
   End
   Begin DesktopLabel OfferDetail
      AllowAutoDeactivate=   True
      Bold            =   False
      Enabled         =   True
      FontSize        =   0.0
      Height          =   56
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
      TabIndex        =   1
      TabPanelIndex   =   0
      Text            =   ""
      TextAlignment   =   0
      Top             =   48
      Transparent     =   False
      Visible         =   True
      Width           =   620
   End
   Begin DesktopHTMLViewer NotesViewer
      AllowAutoDeactivate=   True
      AllowFocus      =   True
      AllowFocusRing  =   False
      AllowTabs       =   False
      Enabled         =   True
      Height          =   350
      Index           =   -2147483648
      Left            =   20
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      Renderer        =   1
      Scope           =   0
      TabIndex        =   2
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   112
      Visible         =   True
      Width           =   620
   End
   Begin DesktopButton BtnSkip
      AllowAutoDeactivate=   True
      Bold            =   False
      Cancel          =   False
      Caption         =   ""
      Default         =   False
      Enabled         =   True
      Height          =   24
      Index           =   -2147483648
      Left            =   20
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   False
      MacButtonStyle  =   0
      Scope           =   0
      TabIndex        =   3
      TabPanelIndex   =   0
      Top             =   476
      Transparent     =   False
      Visible         =   True
      Width           =   150
   End
   Begin DesktopButton BtnLater
      AllowAutoDeactivate=   True
      Bold            =   False
      Cancel          =   True
      Caption         =   ""
      Default         =   False
      Enabled         =   True
      Height          =   24
      Index           =   -2147483648
      Left            =   386
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   False
      LockRight       =   True
      LockTop         =   False
      MacButtonStyle  =   0
      Scope           =   0
      TabIndex        =   4
      TabPanelIndex   =   0
      Top             =   476
      Transparent     =   False
      Visible         =   True
      Width           =   90
   End
   Begin DesktopButton BtnInstall
      AllowAutoDeactivate=   True
      Bold            =   False
      Cancel          =   False
      Caption         =   ""
      Default         =   True
      Enabled         =   True
      Height          =   24
      Index           =   -2147483648
      Left            =   488
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   False
      LockRight       =   True
      LockTop         =   False
      MacButtonStyle  =   0
      Scope           =   0
      TabIndex        =   5
      TabPanelIndex   =   0
      Top             =   476
      Transparent     =   False
      Visible         =   True
      Width           =   152
   End
End
#tag EndDesktopWindow

#tag WindowCode
	#tag Event
		Sub Closing()
		  VNSHelpUpdateInstaller.RemoveWorkFolder(mWork)
		End Sub
	#tag EndEvent

	#tag Method, Flags = &h0
		Function Ask(heading As String, detail As String, notes As String, actionCaption As String) As VNSHelpUpdateOfferWindow.eChoice
		  // Fills the window, then shows it: New fires Opening before there is anything to show.
		  OfferHeading.Text = heading
		  OfferDetail.Text = detail
		  BtnInstall.Caption = actionCaption
		  BtnLater.Caption = kLater
		  BtnSkip.Caption = kSkip
		  If notes = "" Then notes = kNoNotes

		  mWork = VNSHelpUpdateInstaller.NewWorkFolder
		  Var file As FolderItem = VNSHelpUpdateInstaller.WriteNotes(notes, mWork)
		  If file <> Nil Then NotesViewer.LoadPage(file)

		  Self.ShowModal
		  Return mChoice
		End Function
	#tag EndMethod

	#tag Property, Flags = &h21
		Private mChoice As VNSHelpUpdateOfferWindow.eChoice = VNSHelpUpdateOfferWindow.eChoice.Later
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mWork As FolderItem
	#tag EndProperty

	#tag Constant, Name = kLater, Type = String, Dynamic = False, Default = \"Later", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSkip, Type = String, Dynamic = False, Default = \"Skip This Version", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kNoNotes, Type = String, Dynamic = False, Default = \"<p>The site has no release notes for this version.</p>", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMark, Type = String, Dynamic = False, Default = \"bxh:", Scope = Private
	#tag EndConstant

	#tag Note, Name = Description
		The update offer: the release notes of every version after the running one, read from the
		product page, and Install and Restart, Later or Skip This Version. No script runs in the
		notes, and a link in them opens in the browser.
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.24.0
		Last change: 2026-11-25 12:19

		------------------------------------------------------------
		0.24.0 — 2026-11-25

		12:19  [NEW] Initial creation (P24-4).
	#tag EndNote

	#tag Enum, Name = eChoice, Type = Integer, Flags = &h0
		Later
		  Skip
		  Act
	#tag EndEnum

#tag EndWindowCode

#tag Events NotesViewer
	#tag Event
		Function CancelLoad(URL As String) As Boolean
		  If Not URL.BeginsWith(kMark) Then Return False
		  System.GotoURL(URL.Middle(kMark.Length))
		  Return True
		End Function
	#tag EndEvent
#tag EndEvents
#tag Events BtnSkip
	#tag Event
		Sub Pressed()
		  mChoice = VNSHelpUpdateOfferWindow.eChoice.Skip
		  Self.Close
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events BtnLater
	#tag Event
		Sub Pressed()
		  Self.Close
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events BtnInstall
	#tag Event
		Sub Pressed()
		  mChoice = VNSHelpUpdateOfferWindow.eChoice.Act
		  Self.Close
		End Sub
	#tag EndEvent
#tag EndEvents

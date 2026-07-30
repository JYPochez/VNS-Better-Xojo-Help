#tag DesktopWindow
Begin DesktopWindow VNSHelpAboutWindow
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
   Height          =   268
   ImplicitInstance=   True
   MacProcID       =   0
   MaximumHeight   =   32000
   MaximumWidth    =   32000
   MenuBar         =   0
   MenuBarVisible  =   True
   MinimumHeight   =   64
   MinimumWidth    =   64
   Resizeable      =   False
   Title           =   "About Better Xojo Help"
   Type            =   1
   Visible         =   True
   Width           =   440
   Begin DesktopLabel AboutName
      AllowAutoDeactivate=   True
      Bold            =   True
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   17.0
      FontUnit        =   0
      Height          =   26
      Index           =   -2147483648
      Italic          =   False
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
      TabStop         =   True
      Text            =   "Better Xojo Help"
      TextAlignment   =   0
      TextColor       =   &c222222
      Tooltip         =   ""
      Top             =   24
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   392
   End
   Begin DesktopLabel AboutVersion
      AllowAutoDeactivate=   True
      Bold            =   False
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   11.0
      FontUnit        =   0
      Height          =   18
      Index           =   -2147483648
      Italic          =   False
      Left            =   24
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      Multiline       =   False
      Scope           =   0
      Selectable      =   True
      TabIndex        =   1
      TabPanelIndex   =   0
      TabStop         =   True
      Text            =   ""
      TextAlignment   =   0
      TextColor       =   &c606060
      Tooltip         =   ""
      Top             =   52
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   392
   End
   Begin DesktopLabel AboutDescription
      AllowAutoDeactivate=   True
      Bold            =   False
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   12.0
      FontUnit        =   0
      Height          =   72
      Index           =   -2147483648
      Italic          =   False
      Left            =   24
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
      TabStop         =   True
      Text            =   ""
      TextAlignment   =   0
      TextColor       =   &c222222
      Tooltip         =   ""
      Top             =   84
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   392
   End
   Begin DesktopLabel AboutSets
      AllowAutoDeactivate=   True
      Bold            =   False
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   11.0
      FontUnit        =   0
      Height          =   36
      Index           =   -2147483648
      Italic          =   False
      Left            =   24
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      Multiline       =   True
      Scope           =   0
      Selectable      =   True
      TabIndex        =   3
      TabPanelIndex   =   0
      TabStop         =   True
      Text            =   ""
      TextAlignment   =   0
      TextColor       =   &c606060
      Tooltip         =   ""
      Top             =   164
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   392
   End
   Begin DesktopButton BtnClose
      AllowAutoDeactivate=   True
      Bold            =   False
      Cancel          =   True
      Caption         =   "OK"
      Default         =   True
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      Height          =   24
      Index           =   -2147483648
      Italic          =   False
      Left            =   336
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   False
      LockRight       =   True
      LockTop         =   False
      MacButtonStyle  =   0
      Scope           =   0
      TabIndex        =   4
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   220
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   80
   End
End
#tag EndDesktopWindow

#tag WindowCode
	#tag Event
		Sub Opening()
		  // Everything shown here is derived, so nothing has to be kept in step by
		  // hand. The version comes from the build settings rather than a constant of
		  // its own, which would be a second place to remember to bump.
		  AboutName.Text = kAppName
		  AboutVersion.Text = kVersionPrefix + App.MajorVersion.ToString + kVersionSeparator _
		  + App.MinorVersion.ToString + kVersionSeparator + App.BugVersion.ToString
		  AboutDescription.Text = kDescription
		  AboutSets.Text = SummariseInstalledSets
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Function SummariseInstalledSets() As String
		  // A count rather than a list: the point is to show at a glance that the app
		  // found the documentation, and which release it opens on.
		  Var versions() As VNSHelpVersion = VNSHelpVersionScanner.Scan
		  
		  If versions.LastIndex < 0 Then Return kNoSets
		  
		  Var sphinx As Integer = 0
		  Var legacy As Integer = 0
		  For Each v As VNSHelpVersion In versions
		    If v.Era = VNSHelpVersion.eEra.Sphinx Then
		      sphinx = sphinx + 1
		    ElseIf v.Era = VNSHelpVersion.eEra.LegacyDB Then
		      legacy = legacy + 1
		    End If
		  Next
		  
		  Return kSetsPrefix + versions.Count.ToString + kSetsMiddle + sphinx.ToString _
		  + kSetsSphinx + legacy.ToString + kSetsLegacy + versions(0).DisplayName + kSetsSuffix
		End Function
	#tag EndMethod


	#tag Note, Name = Description
		The About box.
		
		Deliberately derived rather than declared: the version is read from the build
		settings and the documentation-set counts from a live scan, so neither can drift
		out of step with the app the way a hand-maintained string would.
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.8.4
		Last change: 2026-07-25 17:23
		
		------------------------------------------------------------
		0.8.4 — 2026-07-25
		
		17:23  [NEW] Initial creation — name, version from the build settings, and a live count of the installed documentation sets.
	#tag EndNote


	#tag Constant, Name = kAppName, Type = String, Dynamic = False, Default = \"Better Xojo Help", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kDescription, Type = String, Dynamic = False, Default = \"Browses every set of Xojo offline documentation installed on this machine\x2C from one window\x2C across the three incompatible formats Xojo has shipped. Nothing is downloaded and nothing outside this app is ever written to.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kNoSets, Type = String, Dynamic = False, Default = \"No installed documentation was found.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSetsLegacy, Type = String, Dynamic = False, Default = \" from the older database format. Opens on ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSetsMiddle, Type = String, Dynamic = False, Default = \" documentation sets: ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSetsPrefix, Type = String, Dynamic = False, Default = \"Found ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSetsSphinx, Type = String, Dynamic = False, Default = \" modern and ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSetsSuffix, Type = String, Dynamic = False, Default = \".", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kVersionPrefix, Type = String, Dynamic = False, Default = \"Version ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kVersionSeparator, Type = String, Dynamic = False, Default = \".", Scope = Private
	#tag EndConstant


#tag EndWindowCode

#tag Events BtnClose
	#tag Event
		Sub Pressed()
		  Self.Close
		End Sub
	#tag EndEvent
#tag EndEvents

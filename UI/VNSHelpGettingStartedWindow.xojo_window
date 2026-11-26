#tag DesktopWindow
Begin DesktopWindow VNSHelpGettingStartedWindow
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
   Height          =   540
   ImplicitInstance=   True
   MacProcID       =   0
   MaximumHeight   =   32000
   MaximumWidth    =   32000
   MenuBar         =   0
   MenuBarVisible  =   True
   MinimumHeight   =   320
   MinimumWidth    =   520
   Resizeable      =   True
   Title           =   ""
   Type            =   0
   Visible         =   True
   Width           =   640
   Begin DesktopTextArea GuideText
      AllowAutoDeactivate=   True
      AllowFocusRing  =   False
      AllowSpellChecking=   False
      AllowStyledText =   False
      AllowTabs       =   False
      Bold            =   False
      BorderStyle     =   1
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   13.0
      Height          =   468
      HideScrollbarHorizontal=   True
      HideScrollbarVertical=   False
      Index           =   -2147483648
      Left            =   12
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      Multiline       =   True
      ReadOnly        =   True
      Scope           =   0
      TabIndex        =   0
      TabPanelIndex   =   0
      TabStop         =   True
      Text            =   ""
      TextAlignment   =   0
      Top             =   12
      Transparent     =   False
      Visible         =   True
      Width           =   616
   End
   Begin DesktopButton BtnGuideDone
      AllowAutoDeactivate=   True
      Bold            =   False
      Cancel          =   True
      Caption         =   ""
      Default         =   True
      Enabled         =   True
      Height          =   24
      Index           =   -2147483648
      Left            =   548
      LockBottom      =   True
      LockLeft        =   False
      LockRight       =   True
      LockTop         =   False
      MacButtonStyle  =   0
      Scope           =   0
      TabIndex        =   2
      TabPanelIndex   =   0
      Top             =   492
      Transparent     =   False
      Visible         =   True
      Width           =   80
   End
End
#tag EndDesktopWindow

#tag WindowCode
	#tag Event
		Sub Opening()
		  Self.Title = kWindowTitle
		  BtnGuideDone.Caption = kDoneCaption
		  GuideText.Text = kGuideText

		  // Setting the text leaves the view at its end.
		  GuideText.SelectionStart = 0
		  GuideText.SelectionLength = 0
		  GuideText.VerticalScrollPosition = 0
		End Sub
	#tag EndEvent

	#tag Constant, Name = kWindowTitle, Type = String, Dynamic = False, Default = \"Getting Started", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kDoneCaption, Type = String, Dynamic = False, Default = \"OK", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kGuideText, Type = String, Dynamic = False, Default = \"GETTING STARTED\n\nBetter Xojo Help reads the offline documentation of every Xojo release on this computer. Choose the release in the popup at the top left.\n\n\nDOCUMENTATION INSTALLS BY ITSELF\n\nOn macOS\x2C Windows and Linux\x2C the app looks for installed Xojos when it starts. If it finds one of Xojo 2022 or later whose documentation it does not have yet\x2C it offers to install it: Install\x2C Not Now\x2C or Don\'t Ask Again. This takes a minute or more and about 400 MB of disk space for each release.\n\nWhere it looks:\n\n\xE2\x80\xA2 macOS: every Xojo application on this Mac\x2C wherever it is.\n\xE2\x80\xA2 Windows: C:\\Program Files\\Xojo.\n\xE2\x80\xA2 Linux: folders named after their release\x2C such as xojo2026r3.1\x2C in your home folder\x2C in a folder directly inside it such as Downloads\x2C or in /opt or /usr/local.\n\nDocumentation installed from Xojo itself\x2C in Preferences \xE2\x96\xB8 General \xE2\x96\xB8 Documentation\x2C also appears by itself.\n\n\nBY HAND\n\nFile \xE2\x96\xB8 Install Documentation lists what the app has\x2C and what it found but did not install. Right-click a line to install it\x2C or to delete a set this app installed. Documentation that belongs to Xojo cannot be deleted there.\n\nChoose a File\xE2\x80\xA6 installs a docs.tgz (Xojo 2022 and later) or an XojoLangRefDB (Xojo 2015 to 2021).\n\n\nLINUX: IF THE APP DOES NOT START\n\nIf double-clicking the app asks which application to open it with\x2C the app is not allowed to run. Open a terminal in its folder and type:\n\nchmod +x \"Better Xojo Help\"\n./\"Better Xojo Help\"\n\nThe first line is needed once. Some tools that unpack a zip leave this permission out.\n\n\nTHE FIRST SEARCH\n\nThe first search on a release reads all of its pages\x2C which can take several seconds. The next ones are quick.\n", Scope = Private
	#tag EndConstant

	#tag Note, Name = Description
		Help ▸ Getting Started: how documentation is found and installed on each platform,
		and what to do when a Linux copy is not allowed to run. The text is generated from
		tools/getting-started-text.txt; the README says the Linux part too, for someone who
		cannot start the app to read it here.
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.23.0
		Last change: 2026-11-24 23:46

		------------------------------------------------------------
		0.23.0 — 2026-11-24

		23:46  [NEW] Initial creation (P23-11).
	#tag EndNote

#tag EndWindowCode

#tag Events BtnGuideDone
	#tag Event
		Sub Pressed()
		  Self.Close
		End Sub
	#tag EndEvent
#tag EndEvents

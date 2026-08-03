#tag Class
Protected Class App
Inherits DesktopApplication
	#tag Event
		Sub Opening()
		  // modGTK3, vendored from Norman Palardy's SimpleLRBrowser. GTK themes can
		  // override the geometry Xojo asks for, and Xojo lays controls out in GtkFixed
		  // containers, which the GTK documentation says "ignore themes, fonts, and text
		  // direction changes". These three calls install the fixes that project uses, and
		  // it runs correctly on Linux. See P14-18.
		  //
		  // It is the last untried lever on the reading pane being drawn at the window's
		  // client origin there. Everything expressible in Xojo layout has been tried and
		  // recorded in P14-25; this reaches below it, into GTK itself.
		  #If TargetLinux
		    // Hardware acceleration off, before any viewer exists.
		    //
		    // Xojo's own documentation: "The DesktopHTMLViewer may not draw its contents
		    // properly when using it on Linux on some hardware configurations. Should this
		    // happen, turning off hardware acceleration will resolve the issue." This VM
		    // has no GPU at all — the terminal logs `VMware: No 3D enabled` and
		    // `MESA: ZINK: failed to choose pdev` — which is that configuration exactly.
		    //
		    // It is also why the pane rendered under GNOME on Wayland and went blank under
		    // XFCE on X11: the same note says acceleration is off by default on Wayland
		    // because the fault is far more common there, and therefore on by default
		    // everywhere else.
		    System.EnvironmentVariable(kWebKitAcceleration) = kOff

		    modGTK3.initGtkEntryFix
		    modGTK3.initGtkWidgetHeightFix
		    modGTK3.InitGlobalGTK3Style
		  #EndIf

		  EnableWebInspector
		End Sub
	#tag EndEvent

	#tag MenuHandler
		Function AppSettings() As Boolean Handles AppSettings.Action
		  // Named after its menu item, the only form proven to bind here.
		  VNSHelpSettingsWindow.Show

		  Return True
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function HelpAbout() As Boolean Handles HelpAbout.Action
		  // Named after the menu item, which is the only form proven to bind here — see
		  // the note on the Navigate handlers in VNSHelpMainWindow.
		  //
		  // On App rather than the window, so About still opens when no window is up, and
		  // because a DesktopApplicationMenuItem is an application concern.
		  VNSHelpAboutWindow.Show

		  Return True
		End Function
	#tag EndMenuHandler

	#tag Constant, Name = kWebKitAcceleration, Type = String, Dynamic = False, Default = \"WEBKIT_HARDWARE_ACCELERATION", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kOff, Type = String, Dynamic = False, Default = \"OFF", Scope = Private
	#tag EndConstant

	#tag Method, Flags = &h21
		Private Sub EnableWebInspector()
		  // Debug builds get the WebKit context menu with Inspect Element, so the
		  // reader's own network requests can be watched — which URL an image was
		  // actually fetched from, and why it failed.
		  //
		  // The setting is read by WebKit when a view is created, so it takes
		  // effect on the NEXT launch: run once to arm it, again to use it.
		  #If TargetMacOS Then
		    Var command As String = kInspectorDefaultsCommand

		    #If DebugBuild Then
		      command = command + kInspectorOn
		    #Else
		      command = command + kInspectorOff
		    #EndIf

		    Try
		      Var sh As New Shell
		      sh.Execute(command)
		      sh.Close
		    Catch e As RuntimeException
		      // Diagnostics only; never let this stop the app from starting.
		    End Try
		  #EndIf
		End Sub
	#tag EndMethod

	#tag Constant, Name = kInspectorDefaultsCommand, Type = String, Dynamic = False, Default = \"defaults write fr.verynicesw.betterxojohelp WebKitDebugDeveloperExtrasEnabled -bool ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kInspectorOn, Type = String, Dynamic = False, Default = \"YES", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kInspectorOff, Type = String, Dynamic = False, Default = \"NO", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFileNewTab, Type = String, Dynamic = False, Default = \"New &Tab", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kFileCloseTab, Type = String, Dynamic = False, Default = \"&Close Tab", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kAppSettings, Type = String, Dynamic = False, Default = \"Settings\xE2\x80\xA6", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kSettingDeprecatedLast, Type = String, Dynamic = False, Default = \"Show deprecated results last", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kFileInstallDocs, Type = String, Dynamic = False, Default = \"Install Documentation\xE2\x80\xA6", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kHelpMCPSetup, Type = String, Dynamic = False, Default = \"MCP Setup\xE2\x80\xA6", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kHelpAbout, Type = String, Dynamic = False, Default = \"About Better Xojo Help\xE2\x80\xA6", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kNavigateMenu, Type = String, Dynamic = False, Default = \"&Navigate", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kNavigateBack, Type = String, Dynamic = False, Default = \"&Back", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kNavigateForward, Type = String, Dynamic = False, Default = \"&Forward", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kNavigateFavorite, Type = String, Dynamic = False, Default = \"Toggle &Favorite", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kNavigateWeb, Type = String, Dynamic = False, Default = \"&Open on the Web", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kEditClear, Type = String, Dynamic = False, Default = \"&Delete", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"&Delete"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"&Delete"
	#tag EndConstant

	#tag Constant, Name = kFileQuit, Type = String, Dynamic = False, Default = \"&Quit", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"E&xit"
	#tag EndConstant

	#tag Constant, Name = kFileQuitShortcut, Type = String, Dynamic = False, Default = \"", Scope = Public
		#Tag Instance, Platform = Mac OS, Language = Default, Definition  = \"Cmd+Q"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"Ctrl+Q"
	#tag EndConstant

	#tag Note, Name = Description
		The application object.

		Holds the menu text constants the menu bar refers to as #App.kFoo, the About
		handler, and the debug-only web inspector switch. Nothing era-specific and
		nothing about documentation formats belongs here.
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.11.1
		Last change: 2026-07-25 18:48

		------------------------------------------------------------
		0.11.1 — 2026-07-25

		18:48  [COSMETIC] Back and Forward move to Cmd+Left and Cmd+Right, at the user's preference. Xojo accepts "Left" and "Right" as shortcut key names — the installed docs list 44 non-printable names, including both — so the menu item carries them directly.

		------------------------------------------------------------
		0.11.0 — 2026-07-25

		18:41  [NEW] AppSettings menu handler. A second DesktopApplicationMenuItem, so macOS files Settings in the Apple menu beside About, on Cmd+,.

		------------------------------------------------------------
		0.8.4 — 2026-07-25

		17:23  [NEW] HelpAbout menu handler, opening VNSHelpAboutWindow. On App rather than the window so About still works when no window is up, and because a DesktopApplicationMenuItem is an application concern. Named after its menu item, the only form proven to bind here.
		17:23  [NEW] Menu text constants for the Navigate menu and the About item, referenced from MainMenuBar as #App.kFoo.

		------------------------------------------------------------
		0.1.0 — 2026-07-24

		22:49  [NEW] Initial creation — Opening, the debug-only web inspector switch, and the File/Edit menu text constants.
	#tag EndNote


End Class
#tag EndClass

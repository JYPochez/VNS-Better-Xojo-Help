#tag DesktopWindow
Begin DesktopWindow VNSHelpMCPSetupWindow
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
   Title           =   "MCP Setup"
   Type            =   0
   Visible         =   True
   Width           =   640
   Begin DesktopTextArea SetupText
      AllowAutoDeactivate=   True
      AllowFocusRing  =   True
      AllowSpellChecking=   False
      AllowStyledText =   False
      AllowTabs       =   False
      Bold            =   False
      BorderStyle     =   1
      Enabled         =   True
      FontName        =   "Menlo"
      FontSize        =   11.0
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
   Begin DesktopButton BtnCopyCommand
      AllowAutoDeactivate=   True
      Bold            =   False
      Cancel          =   False
      Caption         =   ""
      Default         =   False
      Enabled         =   True
      Height          =   24
      Index           =   -2147483648
      Left            =   12
      LockBottom      =   True
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   False
      MacButtonStyle  =   0
      Scope           =   0
      TabIndex        =   1
      TabPanelIndex   =   0
      Top             =   492
      Transparent     =   False
      Visible         =   True
      Width           =   240
   End
   Begin DesktopButton BtnSetupDone
      AllowAutoDeactivate=   True
      Bold            =   False
      Cancel          =   True
      Caption         =   "OK"
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
		  // The port is substituted rather than written into the text, so the
		  // instructions match whatever the user has actually configured. Nobody
		  // notices a wrong port until a client silently fails to connect.
		  BtnCopyCommand.Caption = kCopyCaption
		  SetupText.Text = kSetupText.ReplaceAll(kPortToken, VNSHelpPreferences.MCPPort.ToString)
		End Sub
	#tag EndEvent

	#tag Method, Flags = &h21
		Private Function ClaudeCodeCommand() As String
		  Return kClaudeCodeCommand.ReplaceAll(kPortToken, VNSHelpPreferences.MCPPort.ToString)
		End Function
	#tag EndMethod

	#tag Constant, Name = kPortToken, Type = String, Dynamic = False, Default = \"{{PORT}}", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCopyCaption, Type = String, Dynamic = False, Default = \"Copy the Claude Code command", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCopied, Type = String, Dynamic = False, Default = \"Copied", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSetupText, Type = String, Dynamic = False, Default = \"Better Xojo Help can serve the documentation installed on this Mac to an AI\nassistant\x2C over MCP.\n\nTwo things are always true:\n\n  * The server listens on 127.0.0.1 only. It is never reachable from your\n    network\x2C and connections from anywhere else are refused.\n  * It runs only while Better Xojo Help is running. Quit the app and the\n    assistant loses the tools until you open it again.\n\nIf a client starts while this app is not running\x2C nothing breaks: the client\nstarts normally\x2C this one server is listed as failed to connect\x2C and its other\nservers are unaffected. You simply do not get the Xojo tools that session.\n\nSo start Better Xojo Help before the client\x2C or reconnect from the client\nafter starting it -- in Claude Code\x2C /mcp offers that. Leaving the app open\x2C\nwith the server switched on in Settings\x2C is the arrangement that needs no\nthought.\n\nOr have the client start the app for you: see STARTING THE APP AUTOMATICALLY\nbelow.\n\nTurn it on in Settings\x2C then point a client at:\n\n    http://127.0.0.1:{{PORT}}\n\n----------------------------------------------------------------------\nCLAUDE CODE\n----------------------------------------------------------------------\n\nOne command\x2C in Terminal:\n\n    claude mcp add --transport http better-xojo-help http://127.0.0.1:{{PORT}}\n\nAdd --scope user to make it available in every project rather than only the\ncurrent one. Check it with \"claude mcp list\"; remove it with\n\"claude mcp remove better-xojo-help\".\n\n----------------------------------------------------------------------\nCLAUDE DESKTOP\n----------------------------------------------------------------------\n\nClaude Desktop launches its servers as programs and does not open HTTP\nconnections itself\x2C so it needs a small bridge. mcp-remote is the usual one\x2C\nand it needs Node installed.\n\nEdit:\n\n    ~/Library/Application Support/Claude/claude_desktop_config.json\n\nand add\x2C inside \"mcpServers\":\n\n    \"better-xojo-help\": {\n      \"command\": \"npx\"\x2C\n      \"args\": [\"-y\"\x2C \"mcp-remote\"\x2C \"http://127.0.0.1:{{PORT}}\"]\n    }\n\nRestart Claude Desktop afterwards.\n\n----------------------------------------------------------------------\nOTHER CLIENTS\n----------------------------------------------------------------------\n\nAny client that speaks MCP over streamable HTTP can use the address above\ndirectly. One that expects to launch a program instead needs the same\nmcp-remote bridge shown for Claude Desktop.\n\nA note on Ollama: Ollama itself does not speak MCP -- it serves models\x2C not\ntools. Use it through a front end that does\x2C and point that front end here.\n\n----------------------------------------------------------------------\nSTARTING THE APP AUTOMATICALLY\n----------------------------------------------------------------------\n\nInstead of registering the address\x2C register the launcher script that ships\nwith the source. The client then starts *it*\x2C and it starts this app if the\nport is not already answering:\n\n    claude mcp add better-xojo-help -- /path/to/tools/bxh-mcp-launcher.py\n\nIt needs nothing installed -- Python\'s standard library only\x2C no Node and no\nnpx. It expects the app at /Applications/Better Xojo Help.app; set\nBXH_APP_PATH if you keep it somewhere else\x2C and BXH_PORT if you changed the\nport.\n\nTwo conditions\x2C and the script says so plainly if either fails: the installed\napp has to be a build that contains the MCP server\x2C and the server has to be\nswitched on in Settings. An older copy would start without ever opening the\nport.\n\nThe app starts hidden and without taking focus\x2C so nothing appears on screen\nbecause an assistant looked something up. It is there in the Dock if you want\nit. Set BXH_SHOW_APP\x3D1 if you would rather watch it start.\n\nWhen the client exits\x2C the app is asked to quit again -- but only if the\nscript is what started it. An app you opened yourself is left alone\x2C and so is\none running from the Xojo debugger. Set BXH_QUIT_ON_EXIT\x3D0 to leave it running\nin every case.\n\nOpen the app once by hand after installing it\x2C or after any update. macOS\nchecks the signature the first time a given copy is launched\x2C which took 27\nseconds here against about 1 second every time after -- long enough that a\nclient might give up waiting. That cost is paid once per copy\x2C not once per\nsession.\n\nIf the app is already running -- including from the Xojo debugger -- the\nscript notices and relays straight to it\x2C so nothing is launched twice.\n\n----------------------------------------------------------------------\nTHE TOOLS\n----------------------------------------------------------------------\n\nxojo_lookup   One class\x2C method\x2C property or event. Write a member as\n              Class.Member\x2C for example DesktopListBox.AddRow. A bare class\n              name lists that class\'s members instead.\n\nxojo_search   Words to search for\x2C matched together in any order across\n              titles and paths.\n\nBoth accept an optional \"version\" such as 2018r3. Without one they read the\nnewest documentation installed. Every answer says which release it came from\x2C\nwhich matters more than it sounds: RecordSet is current in 2018 and\ndeprecated in 2026.\n", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kClaudeCodeCommand, Type = String, Dynamic = False, Default = \"claude mcp add --transport http better-xojo-help http://127.0.0.1:{{PORT}}", Scope = Private
	#tag EndConstant

	#tag Note, Name = Description
		How to point an MCP client at this app.

		The text is generated from tools/mcp-setup-text.txt rather than hand-authored:
		it is full of commas, colons and equals signs, every one of which is structural
		in a #tag Constant line. See the sync note in CLAUDE.md.

		The port is a {{PORT}} token substituted at display time, so the instructions
		always match what is actually configured — a wrong port here would show up as a
		client that silently fails to connect.
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.17.0
		Last change: 2026-07-29 17:12

		------------------------------------------------------------
		0.17.0 — 2026-07-29

		17:12  [NEW] Initial creation.
	#tag EndNote

#tag EndWindowCode

#tag Events BtnCopyCommand
	#tag Event
		Sub Pressed()
		  // The one command most people need, on the clipboard, rather than asking them
		  // to select it out of a read-only field without mistyping the port.
		  Var board As New Clipboard
		  board.Text = ClaudeCodeCommand
		  board.Close

		  Me.Caption = kCopied
	#tag EndEvent
#tag EndEvents
#tag Events BtnSetupDone
	#tag Event
		Sub Pressed()
		  Self.Close
		End Sub
	#tag EndEvent
#tag EndEvents

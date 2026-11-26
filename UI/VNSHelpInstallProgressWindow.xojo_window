#tag DesktopWindow
Begin DesktopWindow VNSHelpInstallProgressWindow
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
   Height          =   100
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
   Width           =   420
   Begin DesktopLabel WaitLabel
      AllowAutoDeactivate=   True
      Bold            =   False
      Enabled         =   True
      FontSize        =   0.0
      Height          =   22
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
      Width           =   380
   End
   Begin DesktopProgressBar WaitBar
      Height          =   16
      Index           =   -2147483648
      Indeterminate   =   True
      Left            =   20
      LockBottom      =   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      MaximumValue    =   100
      Scope           =   0
      TabIndex        =   1
      Top             =   52
      Value           =   0.0
      Visible         =   True
      Width           =   380
   End
End
#tag EndDesktopWindow

#tag WindowCode
	#tag Event
		Function CancelClosing(appQuitting As Boolean) As Boolean
		  #Pragma Unused appQuitting
		  // Not while tar writes: the Shell would be killed and half a set left behind.
		  Return Not mDone
		End Function
	#tag EndEvent

	#tag Event
		Sub Closing()
		  Timer.CancelCallLater(AddressOf Poll)
		End Sub
	#tag EndEvent

	#tag Method, Flags = &h0
		Sub RunCommand(message As String, command As String)
		  // Runs the command in the background and returns when it has ended; ExitCode and
		  // Output then hold the result. The window closes in Poll only, never before
		  // ShowModal has shown it, however quickly the command ends.
		  WaitLabel.Text = message
		  ExitCode = kCouldNotRun

		  mShell = New Shell
		  mShell.ExecuteMode = Shell.ExecuteModes.Asynchronous
		  // Windows only, where the default would stop tar after two seconds.
		  mShell.TimeOut = kNoTimeout

		  Try
		    mShell.Execute(command)
		    mStarted = True
		  Catch e As RuntimeException
		    Output = e.Message
		  End Try

		  Timer.CallLater(kPollInterval, AddressOf Poll)
		  Self.ShowModal
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Poll()
		  If mStarted Then
		    // One more turn after the command ended, so its output is complete.
		    If mShell.IsRunning Or Not mLastTurn Then
		      If Not mShell.IsRunning Then mLastTurn = True
		      Timer.CallLater(kPollInterval, AddressOf Poll)
		      Return
		    End If

		    ExitCode = mShell.ExitCode
		    Output = mShell.Result
		  End If

		  mDone = True
		  Self.Close
		End Sub
	#tag EndMethod

	#tag Property, Flags = &h0
		ExitCode As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Output As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mShell As Shell
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mStarted As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLastTurn As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDone As Boolean
	#tag EndProperty

	#tag Note, Name = Description
		Shown while a docs.tgz is unpacked. The command runs in the background, so the app
		does not look frozen, and the window cannot be closed before it has ended.
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.23.0
		Last change: 2026-11-24 23:18

		------------------------------------------------------------
		0.23.0 — 2026-11-24

		23:18  [NEW] Initial creation (P23-6).
	#tag EndNote

	#tag Constant, Name = kPollInterval, Type = Integer, Dynamic = False, Default = \"200", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kNoTimeout, Type = Integer, Dynamic = False, Default = \"-1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCouldNotRun, Type = Integer, Dynamic = False, Default = \"-1", Scope = Private
	#tag EndConstant

#tag EndWindowCode


#tag DesktopWindow
Begin DesktopWindow VNSHelpUpdateWindow
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
   Height          =   128
   ImplicitInstance=   False
   MacProcID       =   0
   MaximumHeight   =   32000
   MaximumWidth    =   32000
   MenuBar         =   0
   MenuBarVisible  =   True
   MinimumHeight   =   64
   MinimumWidth    =   64
   Resizeable      =   False
   Title           =   "Update"
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
   Begin DesktopButton BtnCancel
      AllowAutoDeactivate=   True
      Bold            =   False
      Cancel          =   True
      Caption         =   "Cancel"
      Default         =   False
      Enabled         =   True
      Height          =   24
      Index           =   -2147483648
      Left            =   320
      LockBottom      =   True
      LockLeft        =   False
      LockRight       =   True
      LockTop         =   False
      MacButtonStyle  =   0
      Scope           =   0
      TabIndex        =   2
      TabPanelIndex   =   0
      Top             =   84
      Transparent     =   False
      Visible         =   True
      Width           =   80
   End
End
#tag EndDesktopWindow

#tag WindowCode
	#tag Event
		Sub Closing()
		  If mConnection = Nil Then Return
		  RemoveHandler mConnection.FileReceived, AddressOf HandleFile
		  RemoveHandler mConnection.Error, AddressOf HandleError
		  RemoveHandler mConnection.ReceivingProgressed, AddressOf HandleProgress
		  If Not mDone Then mConnection.Disconnect
		  mConnection = Nil
		End Sub
	#tag EndEvent

	#tag Method, Flags = &h0
		Function Download(version As String, url As String, agent As String, target As FolderItem) As Boolean
		  // Shown until the file has arrived. False with an empty Failure: the user cancelled.
		  WaitLabel.Text = kDownloading.ReplaceAll(kTokenVersion, version)
		  mConnection = New URLConnection
		  AddHandler mConnection.FileReceived, AddressOf HandleFile
		  AddHandler mConnection.Error, AddressOf HandleError
		  AddHandler mConnection.ReceivingProgressed, AddressOf HandleProgress
		  mConnection.RequestHeader(kHeaderAgent) = agent
		  mConnection.Send(kGet, url, target, kTimeout)
		  Self.ShowModal
		  Return mSucceeded
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleFile(sender As URLConnection, url As String, httpStatus As Integer, file As FolderItem)
		  #Pragma Unused sender
		  #Pragma Unused url
		  mDone = True
		  If httpStatus <> kHTTPOK Then
		    Failure = kServerAnswered + httpStatus.ToString
		  ElseIf file = Nil Or Not file.Exists Or file.Length = 0 Or (mTotal > 0 And file.Length <> mTotal) Then
		    Failure = kIncomplete
		  Else
		    mSucceeded = True
		  End If
		  Timer.CallLater(kTurn, AddressOf CloseNow)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub CloseNow()
		  // Out of the connection's event first.
		  Self.Close
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleError(sender As URLConnection, err As RuntimeException)
		  #Pragma Unused sender
		  mDone = True
		  Failure = err.Message
		  If Failure = "" Then Failure = kIncomplete
		  Timer.CallLater(kTurn, AddressOf CloseNow)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleProgress(sender As URLConnection, bytesReceived As Int64, totalBytes As Int64, newData As String)
		  #Pragma Unused sender
		  #Pragma Unused newData
		  If totalBytes <= 0 Then Return
		  mTotal = totalBytes
		  If WaitBar.Indeterminate Then WaitBar.Indeterminate = False
		  WaitBar.Value = bytesReceived * WaitBar.MaximumValue / totalBytes
		End Sub
	#tag EndMethod

	#tag Property, Flags = &h0
		Failure As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mConnection As URLConnection
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDone As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSucceeded As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTotal As Int64
	#tag EndProperty

	#tag Constant, Name = kDownloading, Type = String, Dynamic = False, Default = \"Downloading Better Xojo Help {{VERSION}}\xE2\x80\xA6", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTokenVersion, Type = String, Dynamic = False, Default = \"{{VERSION}}", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kGet, Type = String, Dynamic = False, Default = \"GET", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHeaderAgent, Type = String, Dynamic = False, Default = \"User-Agent", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTimeout, Type = Integer, Dynamic = False, Default = \"3600", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHTTPOK, Type = Integer, Dynamic = False, Default = \"200", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTurn, Type = Integer, Dynamic = False, Default = \"1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kServerAnswered, Type = String, Dynamic = False, Default = \"The site answered with HTTP ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kIncomplete, Type = String, Dynamic = False, Default = \"The download is not complete.", Scope = Private
	#tag EndConstant

	#tag Note, Name = Description
		Shown while an update downloads; Cancel stops it.
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.24.0
		Last change: 2026-11-25 12:11

		------------------------------------------------------------
		0.24.0 — 2026-11-25

		12:11  [NEW] Initial creation (P24-1).
	#tag EndNote

#tag EndWindowCode

#tag Events BtnCancel
	#tag Event
		Sub Pressed()
		  Self.Close
		End Sub
	#tag EndEvent
#tag EndEvents

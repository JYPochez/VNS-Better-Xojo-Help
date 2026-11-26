#tag Module
Protected Module VNSHelpUpdater
	#tag Method, Flags = &h1
		Protected Sub CheckAtStartup()
		  If VNSHelpPreferences.CheckUpdates Then StartCheck(False)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub CheckNow()
		  // The menu and the settings: always answers.
		  StartCheck(True)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub AskOnce()
		  // The first launch asks; the settings change the answer later.
		  If VNSHelpPreferences.UpdatesAsked Then Return

		  Var question As New MessageDialog
		  question.IconType = MessageDialog.IconTypes.Question
		  question.Message = kAskMessage
		  question.Explanation = kAskExplanation
		  question.ActionButton.Caption = kAskYes
		  question.CancelButton.Caption = kAskNo
		  question.CancelButton.Visible = True

		  VNSHelpPreferences.CheckUpdates = (question.ShowModal = question.ActionButton)
		  VNSHelpPreferences.UpdatesAsked = True
		  VNSHelpPreferences.Save
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub ReportUnfinished()
		  // The version an update was to bring, when another one starts.
		  Var expected As String = VNSHelpPreferences.PendingUpdate
		  If expected = "" Then Return
		  VNSHelpPreferences.PendingUpdate = ""
		  VNSHelpPreferences.Save
		  If VNSHelpUpdateInstaller.IsNewer(expected, RunningVersion) Then Tell(kUnfinishedMessage.ReplaceAll(kTokenVersion, expected), kUnfinishedExplanation)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function RunningVersion() As String
		  Return App.MajorVersion.ToString + kDot + App.MinorVersion.ToString + kDot + App.BugVersion.ToString
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub StartCheck(interactive As Boolean)
		  If mBusy Then
		    If interactive Then mInteractive = True
		    Return
		  End If
		  mBusy = True
		  mInteractive = interactive
		  mConnection = New URLConnection
		  AddHandler mConnection.ContentReceived, AddressOf HandlePage
		  AddHandler mConnection.Error, AddressOf HandleError
		  mConnection.RequestHeader(kHeaderAgent) = UserAgent
		  mConnection.RequestHeader(kHeaderLanguage) = kEnglish
		  mConnection.Send(kGet, VNSHelpUpdateInstaller.kProductURL, kCheckTimeout)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function UserAgent() As String
		  Return kAgentName + RunningVersion
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleError(sender As URLConnection, err As RuntimeException)
		  #Pragma Unused sender
		  EndCheck(err.Message, "")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandlePage(sender As URLConnection, url As String, httpStatus As Integer, content As String)
		  #Pragma Unused sender
		  #Pragma Unused url
		  If httpStatus <> kHTTPOK Then
		    EndCheck(kServerAnswered + httpStatus.ToString, "")
		    Return
		  End If
		  Var offered As String = VNSHelpUpdateInstaller.VersionOnPage(content)
		  If offered = "" Then
		    EndCheck(kNoVersion, "")
		  Else
		    mNotes = VNSHelpUpdateInstaller.NotesBetween(content, RunningVersion, offered)
		    EndCheck("", offered)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub EndCheck(failure As String, offered As String)
		  mFailure = failure
		  mOffered = offered
		  // Out of the connection's own event before a dialog opens.
		  Timer.CallLater(kTurn, AddressOf ShowResult)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ShowResult()
		  RemoveHandler mConnection.ContentReceived, AddressOf HandlePage
		  RemoveHandler mConnection.Error, AddressOf HandleError
		  mConnection = Nil

		  If mFailure <> "" Then
		    If mInteractive Then Tell(kFailedMessage, mFailure)
		  ElseIf Not VNSHelpUpdateInstaller.IsNewer(mOffered, RunningVersion) Then
		    If mInteractive Then Tell(kUpToDateMessage, kUpToDateExplanation.ReplaceAll(kTokenVersion, RunningVersion))
		  ElseIf mInteractive Or VNSHelpPreferences.SkippedUpdate <> mOffered Then
		    Offer(mOffered)
		  End If
		  mBusy = False
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Offer(version As String)
		  Var blocker As String = VNSHelpUpdateInstaller.Blocker
		  Var detail As String = kOfferExplanation.ReplaceAll(kTokenVersion, RunningVersion) + kSpace
		  Var caption As String
		  If blocker = "" Then
		    detail = detail + kOfferReplaces
		    caption = kOfferInstall
		  Else
		    detail = detail + blocker + kSpace + kOfferByHand
		    caption = kOfferPage
		  End If

		  Var offerWindow As New VNSHelpUpdateOfferWindow
		  Select Case offerWindow.Ask(kOfferMessage.ReplaceAll(kTokenVersion, version), detail, mNotes, caption)
		  Case VNSHelpUpdateOfferWindow.eChoice.Skip
		    VNSHelpPreferences.SkippedUpdate = version
		    VNSHelpPreferences.Save
		  Case VNSHelpUpdateOfferWindow.eChoice.Act
		    If blocker <> "" Then
		      System.GotoURL(VNSHelpUpdateInstaller.kProductURL)
		    Else
		      Install(version)
		    End If
		  End Select
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Install(version As String)
		  Var work As FolderItem = VNSHelpUpdateInstaller.NewWorkFolder
		  If work = Nil Then
		    Tell(kInstallFailed, kNoWorkFolder)
		    Return
		  End If

		  Var download As FolderItem = work.Child(kDownloadName)
		  Var waiting As New VNSHelpUpdateWindow
		  If Not waiting.Download(version, VNSHelpUpdateInstaller.DownloadURL, UserAgent, download) Then
		    VNSHelpUpdateInstaller.RemoveWorkFolder(work)
		    If waiting.Failure <> "" Then Tell(kInstallFailed, waiting.Failure)
		    Return
		  End If
		  download = New FolderItem(download.NativePath, FolderItem.PathModes.Native)

		  Var failure As String
		  Var command As String = VNSHelpUpdateInstaller.PrepareCommand(download, work, version)
		  If command <> "" Then
		    Var progress As New VNSHelpInstallProgressWindow
		    progress.Title = kWindowTitle
		    progress.RunCommand(kChecking, command)
		    If progress.ExitCode <> 0 Then failure = progress.Output.Trim
		    If progress.ExitCode <> 0 And failure = "" Then failure = kNotUnpacked
		  End If

		  Var newItems As FolderItem
		  If failure = "" Then newItems = VNSHelpUpdateInstaller.FinishPrepare(download, work, failure)
		  If newItems = Nil Then
		    VNSHelpUpdateInstaller.RemoveWorkFolder(work)
		    Tell(kInstallFailed, failure)
		    Return
		  End If

		  // Before the script starts, which waits for this process.
		  VNSHelpPreferences.PendingUpdate = version
		  VNSHelpPreferences.Save
		  If Not VNSHelpUpdateInstaller.StartSwap(newItems, work) Then
		    VNSHelpPreferences.PendingUpdate = ""
		    VNSHelpPreferences.Save
		    VNSHelpUpdateInstaller.RemoveWorkFolder(work)
		    Tell(kInstallFailed, kNotStarted)
		    Return
		  End If
		  Quit
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Tell(message As String, explanation As String)
		  Var notice As New MessageDialog
		  notice.IconType = MessageDialog.IconTypes.Note
		  notice.Message = message
		  notice.Explanation = explanation
		  Call notice.ShowModal
		End Sub
	#tag EndMethod

	#tag Property, Flags = &h21
		Private mBusy As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mConnection As URLConnection
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mFailure As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mInteractive As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mNotes As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mOffered As String
	#tag EndProperty

	#tag Constant, Name = kDot, Type = String, Dynamic = False, Default = \".", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSpace, Type = String, Dynamic = False, Default = \" ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kGet, Type = String, Dynamic = False, Default = \"GET", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHeaderAgent, Type = String, Dynamic = False, Default = \"User-Agent", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHeaderLanguage, Type = String, Dynamic = False, Default = \"Accept-Language", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kEnglish, Type = String, Dynamic = False, Default = \"en", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kAgentName, Type = String, Dynamic = False, Default = \"Better Xojo Help/", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCheckTimeout, Type = Integer, Dynamic = False, Default = \"30", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHTTPOK, Type = Integer, Dynamic = False, Default = \"200", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTurn, Type = Integer, Dynamic = False, Default = \"1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTokenVersion, Type = String, Dynamic = False, Default = \"{{VERSION}}", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kDownloadName, Type = String, Dynamic = False, Default = \"download.zip", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kWindowTitle, Type = String, Dynamic = False, Default = \"Update", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kAskMessage, Type = String, Dynamic = False, Default = \"Check for updates when Better Xojo Help starts\?", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kAskExplanation, Type = String, Dynamic = False, Default = \"It reads the Better Xojo Help page on www.verynicesw.fr to see whether a newer version is out. Nothing is installed without asking you. You can change this in Settings.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kAskYes, Type = String, Dynamic = False, Default = \"Check at Startup", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kAskNo, Type = String, Dynamic = False, Default = \"Don\'t Check", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kServerAnswered, Type = String, Dynamic = False, Default = \"The site answered with HTTP ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kNoVersion, Type = String, Dynamic = False, Default = \"The site offers no download for this system at the moment.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFailedMessage, Type = String, Dynamic = False, Default = \"Could not check for updates.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kUpToDateMessage, Type = String, Dynamic = False, Default = \"Better Xojo Help is up to date.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kUpToDateExplanation, Type = String, Dynamic = False, Default = \"Version {{VERSION}} is the newest one.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kOfferMessage, Type = String, Dynamic = False, Default = \"Better Xojo Help {{VERSION}} is available.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kOfferExplanation, Type = String, Dynamic = False, Default = \"You have version {{VERSION}}.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kOfferReplaces, Type = String, Dynamic = False, Default = \"Better Xojo Help downloads the new one from www.verynicesw.fr\x2C replaces itself and starts again.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kOfferByHand, Type = String, Dynamic = False, Default = \"You can download the new version from the site instead.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kOfferInstall, Type = String, Dynamic = False, Default = \"Install and Restart", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kOfferPage, Type = String, Dynamic = False, Default = \"Open the Site", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kInstallFailed, Type = String, Dynamic = False, Default = \"The update was not installed.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kNoWorkFolder, Type = String, Dynamic = False, Default = \"There is no room for temporary files.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kNotUnpacked, Type = String, Dynamic = False, Default = \"The download could not be unpacked.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kNotStarted, Type = String, Dynamic = False, Default = \"The update could not be started.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kChecking, Type = String, Dynamic = False, Default = \"Checking and preparing the update\xE2\x80\xA6", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kUnfinishedMessage, Type = String, Dynamic = False, Default = \"The update to {{VERSION}} did not complete.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kUnfinishedExplanation, Type = String, Dynamic = False, Default = \"Your previous version is still in place. You can try again\x2C or download the new one from the site.", Scope = Private
	#tag EndConstant

	#tag Note, Name = Description
		Checks the public product page for a newer version, at startup if the user said yes and
		from Help ▸ Check for Updates, and offers it. The work itself is VNSHelpUpdateInstaller's.
		
		A check at startup says nothing unless there is something to offer.
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.24.0
		Last change: 2026-11-25 12:11

		------------------------------------------------------------
		0.24.0 — 2026-11-25

		12:11  [NEW] Initial creation (P24-1).
	#tag EndNote

	#tag ViewBehavior
	#tag EndViewBehavior
End Module
#tag EndModule

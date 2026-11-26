#tag DesktopWindow
Begin DesktopWindow VNSHelpInstallDocsWindow
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
   Height          =   626
   ImplicitInstance=   False
   MacProcID       =   0
   MaximumHeight   =   32000
   MaximumWidth    =   32000
   MenuBar         =   0
   MenuBarVisible  =   True
   MinimumHeight   =   64
   MinimumWidth    =   64
   Resizeable      =   False
   Title           =   ""
   Type            =   1
   Visible         =   True
   Width           =   680
   Begin DesktopLabel HeadingLabel
      AllowAutoDeactivate=   True
      Bold            =   True
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
      Multiline       =   False
      Scope           =   0
      Selectable      =   False
      TabIndex        =   0
      TabPanelIndex   =   0
      Text            =   ""
      TextAlignment   =   0
      Top             =   20
      Transparent     =   False
      Visible         =   True
      Width           =   640
   End
   Begin DesktopLabel ExplanationLabel
      AllowAutoDeactivate=   True
      Bold            =   False
      Enabled         =   True
      FontSize        =   0.0
      Height          =   236
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
      Top             =   52
      Transparent     =   False
      Visible         =   True
      Width           =   640
   End
   Begin DesktopButton BtnInstallCancel
      AllowAutoDeactivate=   True
      Bold            =   False
      Cancel          =   True
      Caption         =   ""
      Default         =   False
      Enabled         =   True
      Height          =   24
      Index           =   -2147483648
      Left            =   430
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   False
      LockRight       =   True
      LockTop         =   False
      MacButtonStyle  =   0
      Scope           =   0
      TabIndex        =   2
      TabPanelIndex   =   0
      Top             =   582
      Transparent     =   False
      Visible         =   True
      Width           =   90
   End
   Begin DesktopButton BtnChooseFile
      AllowAutoDeactivate=   True
      Bold            =   False
      Cancel          =   False
      Caption         =   ""
      Default         =   True
      Enabled         =   True
      Height          =   24
      Index           =   -2147483648
      Left            =   530
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   False
      LockRight       =   True
      LockTop         =   False
      MacButtonStyle  =   0
      Scope           =   0
      TabIndex        =   3
      TabPanelIndex   =   0
      Top             =   582
      Transparent     =   False
      Visible         =   True
      Width           =   130
   End
   Begin DesktopLabel AvailableLabel
      AllowAutoDeactivate=   True
      Bold            =   True
      Enabled         =   True
      FontSize        =   0.0
      Height          =   20
      Index           =   -2147483648
      Left            =   20
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      Multiline       =   False
      Scope           =   0
      Selectable      =   False
      TabIndex        =   4
      TabPanelIndex   =   0
      Text            =   ""
      TextAlignment   =   0
      Top             =   300
      Transparent     =   False
      Visible         =   True
      Width           =   640
   End
   Begin DesktopListBox DocsList
      AllowAutoDeactivate=   True
      AllowAutoHideScrollbars=   True
      AllowExpandableRows=   False
      AllowFocusRing  =   False
      AllowResizableColumns=   False
      AllowRowDragging=   False
      AllowRowReordering=   False
      Bold            =   False
      ColumnCount     =   4
      ColumnWidths    =   "80,100,120,*"
      DefaultRowHeight=   -1
      DropIndicatorVisible=   False
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      GridLineStyle   =   0
      HasBorder       =   True
      HasHeader       =   True
      HasHorizontalScrollbar=   False
      HasVerticalScrollbar=   True
      HeadingIndex    =   -1
      Height          =   242
      Index           =   -2147483648
      InitialParent   =   ""
      InitialValue    =   ""
      Italic          =   False
      Left            =   20
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      RequiresSelection=   False
      RowSelectionType=   0
      Scope           =   0
      TabIndex        =   5
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   324
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   640
      _ScrollOffset   =   0
      _ScrollWidth    =   -1
   End
End
#tag EndDesktopWindow

#tag WindowCode
	#tag Event
		Sub Opening()
		  Self.Title = kWindowTitle
		  HeadingLabel.Text = kHeading
		  // One constant with a Windows and a Linux instance: where the files live differs
		  // by platform, and the window should name only the one the user is on.
		  ExplanationLabel.Text = kExplanation
		  BtnChooseFile.Caption = kChooseCaption
		  BtnInstallCancel.Caption = kCancelCaption

		  DocsList.HeaderAt(0) = kHeaderVersion
		  DocsList.HeaderAt(1) = kHeaderFormat
		  DocsList.HeaderAt(2) = kHeaderSource
		  DocsList.HeaderAt(3) = kHeaderFolder
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub ShowFor(owner As VNSHelpMainWindow)
		  // The list is passed here, not set as a property before ShowModal: a window made
		  // with New fires Opening at once, so anything set afterwards arrives too late and
		  // the list showed (0) in the first build.
		  mOwner = owner
		  Reload
		  Self.ShowModal
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ShortPath(path As String) As String
		  // The home folder as ~ on macOS and Linux, where that is how paths are read. Not on
		  // Windows: ~ means nothing there, and UserHome can be the OneDrive folder.
		  #If Not TargetWindows
		    Var home As FolderItem = SpecialFolder.UserHome
		    If home <> Nil And path.BeginsWith(home.NativePath) Then
		      Return kHomeMark + path.Middle(home.NativePath.Length)
		    End If
		  #EndIf
		  Return path
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BuildRowMenu(base As DesktopMenuItem, row As Integer) As Boolean
		  // Delete for a set this app installed. One of Xojo's shows a greyed line instead:
		  // an absent menu would not say why.
		  mMenuVersion = Nil
		  If row < 0 Or row > DocsList.LastRowIndex Then Return False

		  mMenuInstall = Nil
		  Var tag As Variant = DocsList.RowTagAt(row)
		  Var item As New DesktopMenuItem

		  If tag IsA VNSHelpXojoInstall Then
		    DocsList.SelectedRowIndex = row
		    mMenuInstall = tag
		    item.Text = kMenuInstall.ReplaceAll(kTokenRelease, mMenuInstall.Release)
		    base.AddMenu(item)
		    Return True
		  End If

		  If Not (tag IsA VNSHelpVersion) Then Return False

		  DocsList.SelectedRowIndex = row
		  Var clicked As VNSHelpVersion = tag

		  If clicked.Imported Then
		    mMenuVersion = clicked
		    item.Text = kMenuDelete.ReplaceAll(kTokenRelease, clicked.DisplayName)
		  Else
		    item.Text = kMenuXojoOwned
		    item.AutoEnabled = False
		    item.Enabled = False
		  End If
		  base.AddMenu(item)

		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Reload()
		  Versions = mOwner.AvailableVersions
		  mMissing = mOwner.MissingInstalls
		  FillAvailable
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InstallClicked()
		  Var chosen() As VNSHelpXojoInstall
		  chosen.Add(mMenuInstall)
		  mMenuInstall = Nil

		  Var failure As String
		  Var installed As Boolean = mOwner.InstallFound(chosen, failure)
		  Reload
		  If Not installed Then MessageBox(failure)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DeleteClicked()
		  If mMenuVersion = Nil Or mOwner = Nil Then Return

		  Var confirm As New MessageDialog
		  confirm.IconType = MessageDialog.IconTypes.Caution
		  confirm.Message = kDeleteMessage.ReplaceAll(kTokenRelease, mMenuVersion.DisplayName)
		  confirm.Explanation = kDeleteExplanation
		  confirm.ActionButton.Caption = kDeleteCaption
		  confirm.CancelButton.Caption = kCancelCaption
		  confirm.CancelButton.Visible = True
		  If confirm.ShowModal <> confirm.ActionButton Then Return

		  Var failure As String
		  Var removed As Boolean = mOwner.DeleteInstalledDocs(mMenuVersion, failure)
		  mMenuVersion = Nil

		  Reload
		  If Not removed And failure <> "" Then MessageBox(failure)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub FillAvailable()
		  // What the app already found, so the user sees whether a release is there before
		  // looking for any file — and where it was found, which is the first thing to ask
		  // someone whose documentation does not show up.
		  DocsList.RemoveAllRows

		  // First, what an installed Xojo has and this app does not: the likely reason to be here.
		  For Each install As VNSHelpXojoInstall In mMissing
		    Var archivePath As String = install.Archive.NativePath
		    DocsList.AddRow(install.Release, kFormatModern, kSourceMissing, ShortPath(archivePath))
		    DocsList.CellTooltipAt(DocsList.LastAddedRowIndex, kFolderColumn) = archivePath
		    DocsList.RowTagAt(DocsList.LastAddedRowIndex) = install
		  Next

		  // The empty case is said in the heading: in the narrow first column it was cut.
		  If Versions.Count = 0 Then
		    AvailableLabel.Text = kNoneFound
		    Return
		  End If

		  AvailableLabel.Text = kAvailableHeading.ReplaceAll(kTokenCount, Versions.Count.ToString)

		  For Each found As VNSHelpVersion In Versions
		    Var source As String = kSourceXojo
		    If found.Imported Then source = kSourceHere

		    Var folder As String = ""
		    If found.DocRoot <> Nil Then
		      folder = found.DocRoot.NativePath
		    ElseIf found.DocFile <> Nil Then
		      folder = found.DocFile.NativePath
		    End If

		    DocsList.AddRow(found.DisplayName, found.EraName, source, ShortPath(folder))
		    // The column is narrow and the paths share a long prefix; the full one is a hover away.
		    DocsList.CellTooltipAt(DocsList.LastAddedRowIndex, kFolderColumn) = folder
		    DocsList.RowTagAt(DocsList.LastAddedRowIndex) = found
		  Next
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		Accepted As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		Versions() As VNSHelpVersion
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mOwner As VNSHelpMainWindow
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMissing() As VNSHelpXojoInstall
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMenuInstall As VNSHelpXojoInstall
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMenuVersion As VNSHelpVersion
	#tag EndProperty


	#tag Note, Name = Description
		Shown first by File ▸ Install Documentation: says what the command is for and
		what it accepts, before any file dialog. Asked for by the user after a Windows user
		tried an index.html (P23): the command had no explanation at all.

		ShowModal, then read Accepted: True means Choose a File was pressed.
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.23.0
		Last change: 2026-11-24 23:18

		------------------------------------------------------------
		0.23.0 — 2026-11-24

		23:18  [NEW] Installed Xojos whose documentation is not in the app are listed first as Not installed yet; a right-click installs it (P23-6).

		------------------------------------------------------------
		0.22.2 — 2026-11-24

		23:11  [NEW] Contextual menu on the list: deletes a set installed here, after a confirmation, through the main window. Xojo's own sets show a greyed line.
		10:03  [COSMETIC] Wider (680), folders shown with the home folder as ~ on macOS and Linux, the full path as the cell's tooltip.
		10:00  [FIX] ShowFor(found) fills the list before ShowModal: set as a property after New, it arrived after Opening and the list showed (0).
		09:59  [NEW] A list of the documentation already found, with its version, format, source (from Xojo or installed here) and folder, set from the caller's Versions.
		09:56  [NEW] Initial creation. The explanation is kExplanation with a Windows and a Linux instance; its texts are kept in tools/install-docs-explanation-*.txt.
	#tag EndNote


	#tag Constant, Name = kAvailableHeading, Type = String, Dynamic = False, Default = \"Already available in this app ({{COUNT}})", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTokenCount, Type = String, Dynamic = False, Default = \"{{COUNT}}", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHeaderVersion, Type = String, Dynamic = False, Default = \"Version", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHeaderFormat, Type = String, Dynamic = False, Default = \"Format", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHeaderSource, Type = String, Dynamic = False, Default = \"Source", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHeaderFolder, Type = String, Dynamic = False, Default = \"Folder", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSourceXojo, Type = String, Dynamic = False, Default = \"From Xojo", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSourceHere, Type = String, Dynamic = False, Default = \"Installed here", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kNoneFound, Type = String, Dynamic = False, Default = \"No documentation found yet in this app", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHomeMark, Type = String, Dynamic = False, Default = \"~", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFolderColumn, Type = Integer, Dynamic = False, Default = \"3", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMenuInstall, Type = String, Dynamic = False, Default = \"Install Xojo {{RELEASE}} Documentation", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSourceMissing, Type = String, Dynamic = False, Default = \"Not installed yet", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFormatModern, Type = String, Dynamic = False, Default = \"modern docs", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMenuDelete, Type = String, Dynamic = False, Default = \"Delete Xojo {{RELEASE}} Documentation\xE2\x80\xA6", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMenuXojoOwned, Type = String, Dynamic = False, Default = \"Belongs to Xojo: cannot be deleted here", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTokenRelease, Type = String, Dynamic = False, Default = \"{{RELEASE}}", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kDeleteMessage, Type = String, Dynamic = False, Default = \"Delete the documentation of Xojo {{RELEASE}}\?", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kDeleteExplanation, Type = String, Dynamic = False, Default = \"It is removed from this app for good. The file it was installed from\x2C and any documentation installed by Xojo itself\x2C are not touched.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kDeleteCaption, Type = String, Dynamic = False, Default = \"Delete", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kWindowTitle, Type = String, Dynamic = False, Default = \"Install Documentation", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHeading, Type = String, Dynamic = False, Default = \"Install documentation from a file", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kChooseCaption, Type = String, Dynamic = False, Default = \"Choose a File\xE2\x80\xA6", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCancelCaption, Type = String, Dynamic = False, Default = \"Cancel", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kExplanation, Type = String, Dynamic = False, Default = \"Documentation installed from Xojo\x2C through Preferences \xE2\x96\xB8 General \xE2\x96\xB8 Documentation \xE2\x96\xB8 Install Local Documentation\x2C appears in the version popup by itself\x2C and in the list below: you do not need this for it.\n\nThis is for documentation you have as a file\x2C for example for a Xojo version that is no longer installed. Two kinds of file are accepted:\n\n\xE2\x80\xA2 docs.tgz\x2C the documentation of Xojo 2022 and later. It is inside the Xojo application: right-click Xojo\x2C choose Show Package Contents\x2C then open Contents/Resources/Language Reference.\n\n\xE2\x80\xA2 XojoLangRefDB\x2C the documentation of Xojo 2015 to 2021: a single file in the OfflineHelp folder of that version\x2C under ~/Library/Application Support/Xojo/Xojo/Xojo <version>.\n\nAny other file\x2C such as index.html\x2C is refused. If you cannot find either file\x2C search your disk for its name.", Scope = Private
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"Documentation installed from Xojo\x2C through Preferences \xE2\x96\xB8 General \xE2\x96\xB8 Documentation \xE2\x96\xB8 Install Local Documentation\x2C appears in the version popup by itself\x2C and in the list below: you do not need this for it.\n\nThis is for documentation you have as a file\x2C for example for a Xojo version that is no longer installed. Two kinds of file are accepted:\n\n\xE2\x80\xA2 docs.tgz\x2C the documentation of Xojo 2022 and later. It is in the Xojo installation folder\x2C usually C:\\Program Files\\Xojo\\Xojo <version>\\Xojo Resources\\Language Reference.\n\n\xE2\x80\xA2 XojoLangRefDB\x2C the documentation of Xojo 2015 to 2021: a single file in the OfflineHelp folder of that Xojo version.\n\nAny other file\x2C such as index.html\x2C is refused. If you cannot find either file\x2C search your disk for its name."
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"Documentation installed from Xojo\x2C through Preferences \xE2\x96\xB8 General \xE2\x96\xB8 Documentation \xE2\x96\xB8 Install Local Documentation\x2C appears in the version popup by itself\x2C and in the list below: you do not need this for it.\n\nThis is for documentation you have as a file\x2C for example for a Xojo version that is no longer installed. Two kinds of file are accepted:\n\n\xE2\x80\xA2 docs.tgz\x2C the documentation of Xojo 2022 and later. It is in the folder Xojo was unpacked to\x2C for example xojo2026r3.1\x2C under Xojo Resources/Language Reference.\n\n\xE2\x80\xA2 XojoLangRefDB\x2C the documentation of Xojo 2015 to 2021: a single file in the OfflineHelp folder of that Xojo version.\n\nAny other file\x2C such as index.html\x2C is refused. If you cannot find either file\x2C search your disk for its name."
	#tag EndConstant


#tag EndWindowCode

#tag Events DocsList
	#tag Event
		Function ConstructContextualMenu(base As DesktopMenuItem, x As Integer, y As Integer) As Boolean
		  // -1, -1 when asked for from the keyboard: the selected row then.
		  Var row As Integer = DocsList.SelectedRowIndex
		  If x >= 0 And y >= 0 Then row = Me.RowFromXY(x, y)

		  Return BuildRowMenu(base, row)
		End Function
	#tag EndEvent
	#tag Event
		Function ContextualMenuItemSelected(selectedItem As DesktopMenuItem) As Boolean
		  #Pragma Unused selectedItem
		  // One item only; both are Nil when it was the greyed one.
		  If mMenuInstall <> Nil Then
		    InstallClicked
		  Else
		    DeleteClicked
		  End If
		  Return True
		End Function
	#tag EndEvent
#tag EndEvents
#tag Events BtnChooseFile
	#tag Event
		Sub Pressed()
		  Accepted = True
		  Self.Close
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events BtnInstallCancel
	#tag Event
		Sub Pressed()
		  Accepted = False
		  Self.Close
		End Sub
	#tag EndEvent
#tag EndEvents

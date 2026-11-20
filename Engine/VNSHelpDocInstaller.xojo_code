#tag Module
Protected Module VNSHelpDocInstaller
	#tag Method, Flags = &h0
		Function InstalledRoot(createIt As Boolean) As FolderItem
		  // Where documentation the user installs by hand lives: one "Xojo <release>"
		  // folder per set, in the same shape Xojo uses, so VNSHelpVersion.FromInstallFolder
		  // reads it without knowing the difference.
		  //
		  // In this app's own folder, never Xojo's. Writing under
		  // ~/Library/Application Support/Xojo/Xojo is forbidden — and for the people
		  // this feature exists for, who no longer have the IDE, it may not be there at all.
		  Var support As FolderItem = SpecialFolder.ApplicationData
		  If support = Nil Then Return Nil

		  Var app As FolderItem = support.Child(kAppFolderName)
		  If app = Nil Then Return Nil
		  If Not app.Exists Then
		    If Not createIt Then Return Nil
		    Try
		      app.CreateFolder
		    Catch e As IOException
		      Return Nil
		    End Try
		  End If

		  Var docs As FolderItem = app.Child(kDocsFolderName)
		  If docs = Nil Then Return Nil
		  If Not docs.Exists Then
		    If Not createIt Then Return Nil
		    Try
		      docs.CreateFolder
		    Catch e As IOException
		      Return Nil
		    End Try
		  End If

		  Return docs
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Identify(file As FolderItem) As String
		  // The release a file belongs to, or "" when it cannot be told. Empty is a
		  // normal answer, not a failure: a 2020-era database carries no version at
		  // all, and neither do the five oldest Sphinx sets. The caller asks.
		  If file = Nil Or Not file.Exists Then Return ""

		  If IsArchive(file) Then Return IdentifyArchive(file)

		  Return IdentifyDatabase(file)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsArchive(file As FolderItem) As Boolean
		  If file = Nil Then Return False

		  Return file.Name.Lowercase.EndsWith(kArchiveSuffix)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IdentifyDatabase(file As FolderItem) As String
		  // 2015-2019 databases carry a version table:
		  //   vNumber = "2018,0300.4"  ->  2018r3
		  // The format is YYYY,RRPP.B — release x100, point x10, then a documentation
		  // build number. **2020-era databases have no version table**, measured on one
		  // dated 2020-12-14, and nothing else in them names the release.
		  Var db As New SQLiteDatabase
		  db.DatabaseFile = file

		  Try
		    db.Connect
		  Catch e As DatabaseException
		    Return ""
		  End Try

		  Var raw As String
		  Try
		    // SELECT only. This is the user's file and may be their only copy.
		    Var rows As RowSet = db.SelectSQL(kSQLVersion)
		    If rows <> Nil And Not rows.AfterLastRow Then raw = rows.ColumnAt(0).StringValue
		    If rows <> Nil Then rows.Close
		  Catch e As DatabaseException
		    raw = ""
		  Finally
		    db.Close
		  End Try

		  Return DecodeVNumber(raw)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DecodeVNumber(raw As String) As String
		  // "2015,0210.3" -> "2015r2.1";  "2016,0300.1" -> "2016r3"
		  Var comma As Integer = raw.IndexOf(kComma)
		  If comma <> 4 Then Return ""

		  Var year As String = raw.Left(4)
		  Var rest As String = raw.Middle(comma + 1)

		  Var dot As Integer = rest.IndexOf(kDot)
		  If dot >= 0 Then rest = rest.Left(dot)
		  If rest.Length <> 4 Then Return ""

		  Var release As Integer = rest.Left(2).ToInteger
		  Var point As Integer = rest.Middle(2, 2).ToInteger
		  If release <= 0 Then Return ""

		  Var out As String = year + kReleaseMarker + release.ToString

		  // Assigned first: Xojo cannot call a method on a parenthesised expression.
		  If point > 0 Then
		    Var pointNumber As Integer = point \ 10
		    out = out + kDot + pointNumber.ToString
		  End If

		  Return out
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IdentifyArchive(file As FolderItem) As String
		  // One member to stdout rather than unpacking 190 MB to look at a single page:
		  //   tar xzOf <archive> ./index.html
		  // The release is then the release-notes page the toctree links. Absent on the
		  // five oldest Sphinx sets, which link none.
		  //
		  // Note the version found is the *documentation's*: the docs.tgz inside a
		  // 2026r1.2 app bundle reports 2026r1.1, because the bundled set lags the IDE
		  // by a point release. That is the right thing to label it with.
		  Var index As String = RunShell(kTarPeek + Quoted(file.NativePath) + kTarIndexMember)
		  If index = "" Then Return ""

		  Return ReleaseFromIndex(index)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ReleaseFromIndex(indexHTML As String) As String
		  // resources/release_notes/2026r1.2.html -> 2026r1.2
		  Var at As Integer = indexHTML.IndexOf(kReleaseNotesPath)
		  If at < 0 Then Return ""

		  Var start As Integer = at + kReleaseNotesPath.Length
		  Var stop As Integer = indexHTML.IndexOf(start, kHTMLSuffix)
		  If stop < 0 Or stop - start > kMaximumReleaseLength Then Return ""

		  Var release As String = indexHTML.Middle(start, stop - start)

		  // Only what looks like a release: the same page also links notes for other
		  // versions elsewhere in the file, and a stray path would otherwise be taken
		  // as an answer.
		  If Not LooksLikeRelease(release) Then Return ""

		  Return release
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LooksLikeRelease(candidate As String) As Boolean
		  // 2026r1 or 2026r1.2 — four digits, "r", digits, optionally a dotted point.
		  If candidate.Length < 6 Or candidate.Length > 10 Then Return False

		  Var marker As Integer = candidate.IndexOf(kReleaseMarker)
		  If marker <> 4 Then Return False

		  Var year As Integer = candidate.Left(4).ToInteger
		  If year < 2000 Or year > 2100 Then Return False

		  Var tail As String = candidate.Middle(marker + 1)
		  If tail = "" Then Return False

		  For i As Integer = 0 To tail.Length - 1
		    Var ch As String = tail.Middle(i, 1)
		    If ch = kDot Then Continue
		    If kDigits.IndexOf(ch) < 0 Then Return False
		  Next

		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsInstalledHere(release As String) As Boolean
		  // True when *this app* already holds that release. Distinguished from Xojo's
		  // own copy on purpose: this one may be replaced, Xojo's may never be touched.
		  Var root As FolderItem = InstalledRoot(False)
		  If root = Nil Then Return False

		  Var target As FolderItem = root.Child(kVersionFolderPrefix + release)

		  Return target <> Nil And target.Exists
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RemoveInstalled(release As String, ByRef failure As String) As Boolean
		  // Deletes one set from this app's folder, and only from there. The guard is not
		  // decoration: this is the single place in the app that deletes documentation,
		  // and a release name arriving from a text field must never be able to reach
		  // outside the folder we own.
		  failure = ""

		  Var root As FolderItem = InstalledRoot(False)
		  If root = Nil Then Return True

		  Var target As FolderItem = root.Child(kVersionFolderPrefix + release)
		  If target = Nil Or Not target.Exists Then Return True

		  If Not target.Parent.NativePath.BeginsWith(root.NativePath) Then
		    failure = kErrorOutsideFolder
		    Return False
		  End If

		  Try
		    target.Remove
		  Catch e As IOException
		    failure = kErrorRemoveFailed
		    Return False
		  End Try

		  Return Not target.Exists
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Install(file As FolderItem, release As String, ByRef failure As String) As Boolean
		  // Put a set where the scanner will find it. failure carries a sentence for
		  // the user when this returns False.
		  failure = ""
		  If file = Nil Or Not file.Exists Then
		    failure = kErrorNoFile
		    Return False
		  End If

		  If Not LooksLikeRelease(release) Then
		    failure = kErrorBadRelease
		    Return False
		  End If

		  Var root As FolderItem = InstalledRoot(True)
		  If root = Nil Then
		    failure = kErrorNoFolder
		    Return False
		  End If

		  Var target As FolderItem = root.Child(kVersionFolderPrefix + release)
		  If target = Nil Then
		    failure = kErrorNoFolder
		    Return False
		  End If

		  If target.Exists Then
		    failure = kErrorAlreadyThere + release
		    Return False
		  End If

		  Try
		    target.CreateFolder
	    Catch e As IOException
		    failure = kErrorNoFolder
		    Return False
		  End Try

		  If IsArchive(file) Then Return InstallArchive(file, target, failure)

		  Return InstallDatabase(file, target, failure)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function InstallDatabase(file As FolderItem, target As FolderItem, ByRef failure As String) As Boolean
		  // <release>/OfflineHelp/XojoLangRefDB — the layout the scanner expects.
		  Var offline As FolderItem = target.Child(kOfflineFolderName)
		  If offline = Nil Then
		    failure = kErrorNoFolder
		    Return False
		  End If

		  Try
		    offline.CreateFolder
		    file.CopyTo(offline.Child(kDatabaseName))
		  Catch e As IOException
		    failure = kErrorCopyFailed
		    Return False
		  End Try

		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function InstallArchive(file As FolderItem, target As FolderItem, ByRef failure As String) As Boolean
		  // The archive's root *is* the Documentation folder — same 25 entries,
		  // searchindex.js included — so it untars straight into place with nothing to
		  // move afterwards.
		  Var docs As FolderItem = target.Child(kDocumentationFolderName)
		  If docs = Nil Then
		    failure = kErrorNoFolder
		    Return False
		  End If

		  Try
		    docs.CreateFolder
		  Catch e As IOException
		    failure = kErrorNoFolder
		    Return False
		  End Try

		  Call RunShell(kTarExtract + Quoted(file.NativePath) + kTarInto + Quoted(docs.NativePath))

		  // Judge by the result, not by the shell's exit code: what matters is whether
		  // the scanner will now recognise the folder.
		  Var index As FolderItem = docs.Child(kSearchIndexName)
		  If index = Nil Or Not index.Exists Then
		    failure = kErrorExtractFailed
		    Return False
		  End If

		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function RunShell(command As String) As String
		  Var sh As New Shell
		  sh.ExecuteMode = Shell.ExecuteModes.Synchronous
		  sh.Timeout = kShellTimeout

		  Try
		    sh.Execute(command)
		  Catch e As RuntimeException
		    Return ""
		  End Try

		  Return sh.Result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Quoted(path As String) As String
		  // Single quotes, with any embedded single quote closed and reopened around an
		  // escaped one. Paths here come from a file dialog and can hold anything.
		  Return kQuote + path.ReplaceAll(kQuote, kEscapedQuote) + kQuote
		End Function
	#tag EndMethod

	#tag Constant, Name = kAppFolderName, Type = String, Dynamic = False, Default = \"Better Xojo Help", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kDocsFolderName, Type = String, Dynamic = False, Default = \"Documentation", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kVersionFolderPrefix, Type = String, Dynamic = False, Default = \"Xojo ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kOfflineFolderName, Type = String, Dynamic = False, Default = \"OfflineHelp", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kDocumentationFolderName, Type = String, Dynamic = False, Default = \"Documentation", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kDatabaseName, Type = String, Dynamic = False, Default = \"XojoLangRefDB", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSearchIndexName, Type = String, Dynamic = False, Default = \"searchindex.js", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kArchiveSuffix, Type = String, Dynamic = False, Default = \".tgz", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSQLVersion, Type = String, Dynamic = False, Default = \"SELECT vNumber FROM version LIMIT 1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kReleaseNotesPath, Type = String, Dynamic = False, Default = \"resources/release_notes/", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHTMLSuffix, Type = String, Dynamic = False, Default = \".html", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTarPeek, Type = String, Dynamic = False, Default = \"/usr/bin/tar xzOf ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTarIndexMember, Type = String, Dynamic = False, Default = \" ./index.html", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTarExtract, Type = String, Dynamic = False, Default = \"/usr/bin/tar xzf ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTarInto, Type = String, Dynamic = False, Default = \" -C ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kQuote, Type = String, Dynamic = False, Default = \"'", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kEscapedQuote, Type = String, Dynamic = False, Default = \"'\\\"'\\\"'", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kComma, Type = String, Dynamic = False, Default = \"\x2C", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kDot, Type = String, Dynamic = False, Default = \".", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kReleaseMarker, Type = String, Dynamic = False, Default = \"r", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kDigits, Type = String, Dynamic = False, Default = \"0123456789", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMaximumReleaseLength, Type = Integer, Dynamic = False, Default = \"10", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kShellTimeout, Type = Integer, Dynamic = False, Default = \"600000", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kErrorNoFile, Type = String, Dynamic = False, Default = \"That file could not be read.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kErrorBadRelease, Type = String, Dynamic = False, Default = \"That is not a Xojo release number. Use the form 2020r2.1\x2E", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kErrorNoFolder, Type = String, Dynamic = False, Default = \"The documentation folder could not be created.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kErrorAlreadyThere, Type = String, Dynamic = False, Default = \"Documentation is already installed for ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kErrorOutsideFolder, Type = String, Dynamic = False, Default = \"That release name does not resolve inside this app's own folder.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kErrorRemoveFailed, Type = String, Dynamic = False, Default = \"The existing documentation could not be removed.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kErrorCopyFailed, Type = String, Dynamic = False, Default = \"The database could not be copied.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kErrorExtractFailed, Type = String, Dynamic = False, Default = \"The archive did not unpack into a readable documentation set.", Scope = Private
	#tag EndConstant

	#tag Note, Name = Description
		Installs a documentation set for someone who no longer has the Xojo IDE.

		Accepts a legacy `XojoLangRefDB` or a Sphinx-era `docs.tgz` (the archive inside a
		Xojo app bundle, at Contents/Resources/Language Reference/), identifies which
		release it belongs to where it can, and copies it into
		`ApplicationData/Better Xojo Help/Documentation/Xojo <release>/` in the same
		layout Xojo uses — so `VNSHelpVersion.FromInstallFolder` reads it unchanged.

		**Identification returns "" often enough that asking is part of the design**, not
		an error path: 2020–2021 databases carry no version table, and the five oldest
		Sphinx sets link no release-notes page. See `docs/DOC_IDENTIFICATION.md`.

		Nothing here writes anywhere near Xojo's own folders. Reading the user's database
		uses `SELECT` only — it may be their only copy.
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.18.0
		Last change: 2026-07-30 15:40

		------------------------------------------------------------
		0.18.0 — 2026-07-30

		15:40  [NEW] Initial creation. A .tgz is identified by pulling ./index.html to stdout rather than unpacking 190 MB to read one page.
	#tag EndNote


End Module
#tag EndModule

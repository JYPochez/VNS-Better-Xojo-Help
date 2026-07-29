#tag Class
Protected Class VNSHelpVersion
	#tag Method, Flags = &h0
		Shared Function FromInstallFolder(installFolder As FolderItem) As VNSHelpVersion
		  // Inspect one "Xojo <version>" folder under the Xojo application-support
		  // directory and describe the documentation set it holds, or return Nil
		  // when it holds none. Detection order matters: a few installs carry both
		  // an OfflineHelp folder and a Documentation folder, and the Sphinx site is
		  // always the better of the two.
		  If installFolder = Nil Or Not installFolder.Exists Or Not installFolder.IsFolder Then Return Nil

		  Var folderName As String = installFolder.Name
		  If Not folderName.BeginsWith(kInstallPrefix) Then Return Nil

		  Var display As String = folderName.Middle(kInstallPrefix.Length).Trim
		  If display = "" Then Return Nil

		  Var sortKey As Integer = ParseSortKey(display)
		  If sortKey = 0 Then Return Nil

		  Var v As New VNSHelpVersion
		  v.FolderName = folderName
		  v.DisplayName = display
		  v.SortKey = sortKey

		  // Modern era: a Sphinx site whose searchindex.js doubles as the
		  // full-text index, so its presence is what makes the set usable.
		  For Each relativePath As String In kSphinxFolderPaths.Split(kPathListSeparator)
		    Var docFolder As FolderItem = ResolvePath(installFolder, relativePath)
		    If docFolder = Nil Then Continue
		    Var searchIndex As FolderItem = docFolder.Child(kSearchIndexName)
		    If searchIndex <> Nil And searchIndex.Exists Then
		      v.Era = VNSHelpVersion.eEra.Sphinx
		      v.DocRoot = docFolder
		      v.DocFile = searchIndex
		      Return v
		    End If
		  Next

		  // Legacy era: a single SQLite file. Length is checked as well as existence
		  // so a truncated or empty file cannot put a version in the popup that then
		  // fails to open. (The zero-byte file in 2013r1 that first motivated this was
		  // created by one of our own survey scripts, not shipped by Xojo — the guard
		  // is still worth having, but that is not the evidence for it.)
		  // is not enough — an empty file would open and then fail on every query.
		  For Each relativePath As String In kLegacyFolderPaths.Split(kPathListSeparator)
		    Var offlineFolder As FolderItem = ResolvePath(installFolder, relativePath)
		    If offlineFolder = Nil Then Continue
		    Var legacyDB As FolderItem = offlineFolder.Child(kLegacyDBName)
		    If legacyDB <> Nil And legacyDB.Exists And legacyDB.Length > 0 Then
		      v.Era = VNSHelpVersion.eEra.LegacyDB
		      v.DocRoot = offlineFolder
		      v.DocFile = legacyDB
		      Return v
		    End If
		  Next

		  // No readable documentation. 2019r2 through 2022r1 legitimately land
		  // here: those releases shipped no local docs at all.
		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function ParseSortKey(displayName As String) As Integer
		  // "2026r1.2" -> 20260102, so a plain numeric comparison orders releases
		  // correctly. A string sort would put 2016r2 above 2016r1.1 and 2025r3.1
		  // below 2025r1. Returns 0 when the name isn't a Xojo version.
		  Var rPos As Integer = displayName.IndexOf(kReleaseSeparator)
		  If rPos <= 0 Then Return 0

		  Var year As Integer = SafeInteger(displayName.Left(rPos))
		  If year < kMinimumYear Then Return 0

		  Var tail As String = displayName.Middle(rPos + kReleaseSeparator.Length)
		  If tail = "" Then Return 0

		  Var release As Integer
		  Var point As Integer
		  Var dotPos As Integer = tail.IndexOf(kPointSeparator)
		  If dotPos < 0 Then
		    release = SafeInteger(tail)
		  Else
		    release = SafeInteger(tail.Left(dotPos))
		    point = SafeInteger(tail.Middle(dotPos + kPointSeparator.Length))
		  End If
		  If release <= 0 Then Return 0

		  Return year * kYearWeight + release * kReleaseWeight + point
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function ResolvePath(base As FolderItem, relativePath As String) As FolderItem
		  // Walk a "Xojo Resources/Language Reference" style path down from base,
		  // stopping at the first missing step so probing a layout that does not
		  // exist on this platform costs nothing.
		  If base = Nil Or Not base.Exists Then Return Nil

		  Var current As FolderItem = base
		  For Each part As String In relativePath.Split(kPathSeparator)
		    If part = "" Then Continue
		    current = current.Child(part)
		    If current = Nil Or Not current.Exists Then Return Nil
		  Next

		  If Not current.IsFolder Then Return Nil
		  Return current
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function SafeInteger(value As String) As Integer
		  // Integer.FromString raises on anything non-numeric; folder names here
		  // are user data, so treat garbage as 0 rather than letting it propagate.
		  Try
		    Return Integer.FromString(value.Trim)
		  Catch e As RuntimeException
		    Return 0
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function EraName() As String
		  // Short human label for the format this version stores its docs in.
		  Select Case Era
		  Case VNSHelpVersion.eEra.Sphinx
		    Return kEraNameSphinx
		  Case VNSHelpVersion.eEra.LegacyDB
		    Return kEraNameLegacy
		  Else
		    Return kEraNameUnknown
		  End Select
		End Function
	#tag EndMethod

	#tag Property, Flags = &h0
		FolderName As String
	#tag EndProperty

	#tag Property, Flags = &h0
		DisplayName As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Era As VNSHelpVersion.eEra
	#tag EndProperty

	#tag Property, Flags = &h0
		DocRoot As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h0
		DocFile As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h0
		SortKey As Integer
	#tag EndProperty

	#tag Constant, Name = kInstallPrefix, Type = String, Dynamic = False, Default = \"Xojo ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSphinxFolderPaths, Type = String, Dynamic = False, Default = \"Documentation|Xojo Resources/Language Reference", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kLegacyFolderPaths, Type = String, Dynamic = False, Default = \"OfflineHelp|Xojo Resources/Language Reference", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPathListSeparator, Type = String, Dynamic = False, Default = \"|", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPathSeparator, Type = String, Dynamic = False, Default = \"/", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSearchIndexName, Type = String, Dynamic = False, Default = \"searchindex.js", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kLegacyDBName, Type = String, Dynamic = False, Default = \"XojoLangRefDB", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kReleaseSeparator, Type = String, Dynamic = False, Default = \"r", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPointSeparator, Type = String, Dynamic = False, Default = \".", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kEraNameSphinx, Type = String, Dynamic = False, Default = \"modern docs", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kEraNameLegacy, Type = String, Dynamic = False, Default = \"legacy docs", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kEraNameUnknown, Type = String, Dynamic = False, Default = \"", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMinimumYear, Type = Integer, Dynamic = False, Default = \"2000", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kYearWeight, Type = Integer, Dynamic = False, Default = \"10000", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kReleaseWeight, Type = Integer, Dynamic = False, Default = \"100", Scope = Private
	#tag EndConstant

	#tag Enum, Name = eEra, Type = Integer, Flags = &h0
		Unknown
		  Sphinx
		  LegacyDB
	#tag EndEnum

	#tag Note, Name = Description
		One installed Xojo documentation set: which release it belongs to, which of the
		two supported on-disk formats it uses, and where its files are.

		Created only through the shared FromInstallFolder factory, which returns Nil for
		an install folder that carries no readable documentation.
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.8.4
		Last change: 2026-07-25 17:23

		------------------------------------------------------------
		0.8.4 — 2026-07-25

		17:23  [DOCS] Corrected the reason given for the Length > 0 guard. Xojo 2013r1 does not ship a zero-byte XojoLangRefDB — one of our own P0 survey scripts created it, as its ctime and mtime (both 2026-07-24 22:30) show against siblings dated 2013 and 2023. The guard stays because it is right; only its evidence was wrong.

		------------------------------------------------------------
		0.1.0 — 2026-07-24

		22:49  [NEW] Initial creation — era detection (Sphinx / legacy XojoLangRefDB), numeric release sort key, popup label.
		22:49  [REFACTOR] Dropped MenuLabel: the popup now shows the bare version and separates the two eras with a separator row.
		22:49  [REFACTOR] SafeInteger made public so the window can parse popup row tags.
	#tag EndNote

	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass

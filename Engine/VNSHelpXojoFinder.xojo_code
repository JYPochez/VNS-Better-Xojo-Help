#tag Module
Protected Module VNSHelpXojoFinder
	#tag Method, Flags = &h0
		Function Find() As VNSHelpXojoInstall()
		  // Every installed Xojo that ships a docs.tgz, named by its own release. Read-only:
		  // nothing inside a Xojo installation is ever changed.
		  Var found() As VNSHelpXojoInstall

		  #If TargetMacOS Then
		    For Each bundle As FolderItem In MacBundles
		      AddInstall(found, MacRelease(bundle), bundle)
		    Next
		  #Else
		    For Each root As FolderItem In InstallRoots
		      SearchFolder(found, root, kSearchDepth)
		    Next
		  #EndIf

		  Return found
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ReleaseOf(file As FolderItem) As String
		  // The release of the Xojo a chosen docs.tgz sits in, or "". The archive names the
		  // documentation it holds, which lags the IDE: 2026r3 inside Xojo 2026r3.1.
		  If file = Nil Then Return ""

		  For Each install As VNSHelpXojoInstall In Find
		    If install.Archive.NativePath = file.NativePath Then Return install.Release
		  Next

		  Return ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SearchFolder(found() As VNSHelpXojoInstall, root As FolderItem, depth As Integer)
		  // Only folders named after Xojo are looked at, and only inside those is it worth
		  // going deeper: on Linux the archive may be unpacked into a folder of its own,
		  // ~/Downloads/xojo2026r31/xojo2026r3.1 (seen on Ubuntu). The outer name is not a
		  // release, so AddInstall passes over it.
		  Try
		    For Each child As FolderItem In root.Children
		      If child = Nil Or Not child.IsFolder Or child.IsAlias Then Continue

		      Var release As String = ReleaseFromFolder(child.Name)
		      If release = "" Then Continue

		      AddInstall(found, release, child)
		      If depth > 1 Then SearchFolder(found, child, depth - 1)
		    Next
		  Catch e As RuntimeException
		    // A folder that cannot be listed offers nothing.
		  End Try
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddInstall(found() As VNSHelpXojoInstall, release As String, installation As FolderItem)
		  If release = "" Or Not VNSHelpDocInstaller.LooksLikeRelease(release) Then Return

		  // The same release twice on one computer is one offer.
		  For Each existing As VNSHelpXojoInstall In found
		    If existing.Release = release Then Return
		  Next

		  For Each relativePath As String In kArchiveFolders.Split(kListSeparator)
		    Var folder As FolderItem = VNSHelpVersion.ResolvePath(installation, relativePath)
		    If folder = Nil Then Continue

		    Var archive As FolderItem = folder.Child(kArchiveName)
		    If archive = Nil Or Not archive.Exists Then Continue

		    Var install As New VNSHelpXojoInstall
		    install.Release = release
		    install.Archive = archive
		    found.Add(install)
		    Return
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function MacBundles() As FolderItem()
		  // Spotlight knows the application wherever it is, and whatever it is called. An
		  // application on another volume, such as a backup, is not an installation.
		  Var bundles() As FolderItem

		  Var output As String = RunCommand(kFindBundles)
		  For Each line As String In output.Split(kLineFeed)
		    Var path As String = line.Trim
		    If path = "" Or path.BeginsWith(kVolumesPath) Or Not path.EndsWith(kAppSuffix) Then Continue

		    Var bundle As New FolderItem(path, FolderItem.PathModes.Native)
		    If bundle.Exists Then bundles.Add(bundle)
		  Next

		  Return bundles
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function MacRelease(bundle As FolderItem) As String
		  // 26.3.1.68444 is 2026r3.1, and 26.2.0.1 is 2026r2: the last number is the build.
		  Var infoPath As String = bundle.NativePath + kInfoPath
		  Var quotedPath As String = kQuote + infoPath.ReplaceAll(kQuote, kEscapedQuote) + kQuote
		  Var parts() As String = RunCommand(kReadDefaults + quotedPath + kVersionKey).Trim.Split(kDot)
		  If parts.Count < 2 Then Return ""

		  Var year As Integer = VNSHelpVersion.SafeInteger(parts(0))
		  Var release As Integer = VNSHelpVersion.SafeInteger(parts(1))
		  Var point As Integer = 0
		  If parts.Count > 2 Then point = VNSHelpVersion.SafeInteger(parts(2))
		  If year <= 0 Or release <= 0 Then Return ""
		  If year < kCentury Then year = year + kCentury

		  Var name As String = year.ToString + kReleaseMarker + release.ToString
		  If point > 0 Then name = name + kDot + point.ToString
		  Return name
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function InstallRoots() As FolderItem()
		  // Windows: confirmed on Windows 11, C:\Program Files\Xojo\Xojo 2026r3.1.
		  // Linux: Xojo is an archive unpacked anywhere the user likes, so the home folder, every
		  // visible folder directly in it (Downloads goes by another name in other languages),
		  // and the usual system places. Seen on Ubuntu under ~/Downloads.
		  Var roots() As FolderItem

		  #If TargetWindows Then
		    Var programs As FolderItem = VNSHelpVersion.ResolvePath(SpecialFolder.Applications, kVendorFolder)
		    If programs <> Nil Then roots.Add(programs)
		  #ElseIf TargetLinux Then
		    Var home As FolderItem = SpecialFolder.UserHome
		    If home <> Nil And home.Exists Then
		      roots.Add(home)
		      Try
		        For Each child As FolderItem In home.Children
		          If child = Nil Or Not child.IsFolder Or child.IsAlias Then Continue
		          If child.Name.BeginsWith(kDot) Then Continue
		          roots.Add(child)
		        Next
		      Catch e As RuntimeException
		        // The home folder itself is still searched.
		      End Try
		    End If

		    For Each path As String In kLinuxRoots.Split(kListSeparator)
		      Var place As New FolderItem(path, FolderItem.PathModes.Native)
		      If place.Exists And place.IsFolder Then roots.Add(place)
		    Next
		  #EndIf

		  Return roots
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ReleaseFromFolder(folderName As String) As String
		  // "Xojo 2026r3.1", and "xojo2026r3.1" should Linux write it so.
		  Var lowered As String = folderName.Lowercase
		  If Not lowered.BeginsWith(kVendorPrefix) Then Return ""

		  Return lowered.Middle(kVendorPrefix.Length).Trim
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function RunCommand(command As String) As String
		  Var finderShell As New Shell
		  finderShell.ExecuteMode = Shell.ExecuteModes.Synchronous

		  Try
		    finderShell.Execute(command)
		  Catch e As RuntimeException
		    Return ""
		  End Try

		  If finderShell.ExitCode <> 0 Then Return ""
		  Return finderShell.Result
		End Function
	#tag EndMethod

	#tag Note, Name = Description
		Finds the Xojo IDEs installed on this computer and the docs.tgz each carries, so
		the app can offer it instead of asking the user to look for the file. UI-free.
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.23.0
		Last change: 2026-11-24 23:18

		------------------------------------------------------------
		0.23.0 — 2026-11-24

		23:18  [NEW] Initial creation (P23-6). Linux searches the home folder and what is directly in it, /opt and /usr/local, two levels deep: the user's Ubuntu has it in ~/Downloads/xojo2026r31/xojo2026r3.1.
	#tag EndNote


	#tag Constant, Name = kArchiveFolders, Type = String, Dynamic = False, Default = \"Contents/Resources/Language Reference|Xojo Resources/Language Reference|Resources/Language Reference|Language Reference", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kListSeparator, Type = String, Dynamic = False, Default = \"|", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kArchiveName, Type = String, Dynamic = False, Default = \"docs.tgz", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFindBundles, Type = String, Dynamic = False, Default = \"/usr/bin/mdfind \"kMDItemCFBundleIdentifier \x3D\x3D \'com.xojo.xojo\'\"", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kReadDefaults, Type = String, Dynamic = False, Default = \"/usr/bin/defaults read ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kInfoPath, Type = String, Dynamic = False, Default = \"/Contents/Info", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kVersionKey, Type = String, Dynamic = False, Default = \" CFBundleShortVersionString", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kQuote, Type = String, Dynamic = False, Default = \"\'", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kEscapedQuote, Type = String, Dynamic = False, Default = \"\'\"\'\"\'", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kLineFeed, Type = String, Dynamic = False, Default = \"\n", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kVolumesPath, Type = String, Dynamic = False, Default = \"/Volumes/", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kAppSuffix, Type = String, Dynamic = False, Default = \".app", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kDot, Type = String, Dynamic = False, Default = \".", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kReleaseMarker, Type = String, Dynamic = False, Default = \"r", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCentury, Type = Integer, Dynamic = False, Default = \"2000", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kVendorFolder, Type = String, Dynamic = False, Default = \"Xojo", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kVendorPrefix, Type = String, Dynamic = False, Default = \"xojo", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kLinuxRoots, Type = String, Dynamic = False, Default = \"/opt|/opt/xojo|/usr/local", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSearchDepth, Type = Integer, Dynamic = False, Default = \"2", Scope = Private
	#tag EndConstant


	#tag ViewBehavior
	#tag EndViewBehavior
End Module
#tag EndModule

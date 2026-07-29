#tag Module
Protected Module VNSHelpVersionScanner
	#tag Method, Flags = &h0
		Function Scan() As VNSHelpVersion()
		  // Every installed Xojo documentation set, newest first. Install folders
		  // that carry no readable documentation are skipped, so the result is
		  // shorter than the directory listing — see CandidateRoots for why.
		  Var found() As VNSHelpVersion
		  Var seenFolders As New Dictionary

		  For Each root As FolderItem In CandidateRoots
		    For Each child As FolderItem In root.Children
		      If child = Nil Or Not child.IsFolder Then Continue

		      // Two candidate roots can resolve to the same place on some systems;
		      // key on the resolved path so a release is never listed twice.
		      Var key As String = child.NativePath
		      If seenFolders.HasKey(key) Then Continue
		      seenFolders.Value(key) = True

		      Var v As VNSHelpVersion = VNSHelpVersion.FromInstallFolder(child)
		      If v <> Nil Then found.Add(v)
		    Next
		  Next

		  Return SortedNewestFirst(found)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CandidateRoots() As FolderItem()
		  // Folders that may contain one subfolder per installed release. Only
		  // macOS is confirmed; the Windows and Linux locations are unverified, so
		  // several plausible ones are probed and AdditionalRoot lets the user
		  // point at the right place when none of them is.
		  //
		  // A root holds ~70 "Xojo <version>" folders here but only ~30 carry docs:
		  // releases 2019r2 through 2022r1 shipped none at all (documentation moved
		  // online for that stretch), and many point releases carry none either.
		  Var roots() As FolderItem

		  #If TargetMacOS
		    // CONFIRMED on this machine: ~/Library/Application Support/Xojo/Xojo,
		    // holding one "Xojo <version>" folder per release with its docs in a
		    // Documentation subfolder. macOS installs carry no Language Reference
		    // folder inside the IDE bundle.
		    AddRoot(roots, VNSHelpVersion.ResolvePath(SpecialFolder.ApplicationData, kVendorPath))

		  #ElseIf TargetWindows
		    // UNVERIFIED — no Windows machine was available to check.
		    // Program Files\Xojo is the reported layout: the forum thread
		    // "Xojo2022r2 local documentation" gives
		    // C:\Program Files\Xojo\Xojo 2022r2\Xojo Resources\Language Reference,
		    // so the per-release folders sit under Program Files\Xojo.
		    AddRoot(roots, VNSHelpVersion.ResolvePath(SpecialFolder.Applications, kVendorFolderName))
		    // The macOS layout may also be mirrored into AppData\Roaming, and a
		    // machine-wide install would use ProgramData instead.
		    AddRoot(roots, VNSHelpVersion.ResolvePath(SpecialFolder.ApplicationData, kVendorPath))
		    AddRoot(roots, VNSHelpVersion.ResolvePath(SpecialFolder.SharedApplicationData, kVendorPath))

		  #ElseIf TargetLinux
		    // UNVERIFIED — no Linux machine was available to check.
		    // SpecialFolder.Applications is Nil on Linux, so the usual /opt install
		    // location is built from a literal path instead. On Linux
		    // SpecialFolder.ApplicationData is the home folder itself, hence the
		    // hidden-folder spellings.
		    AddRoot(roots, LiteralFolder(kLinuxOptPath))
		    AddRoot(roots, VNSHelpVersion.ResolvePath(SpecialFolder.ApplicationData, kLinuxConfigPath))
		    AddRoot(roots, VNSHelpVersion.ResolvePath(SpecialFolder.ApplicationData, kLinuxHiddenPath))
		    AddRoot(roots, VNSHelpVersion.ResolvePath(SpecialFolder.ApplicationData, kVendorPath))
		  #EndIf

		  // Always probed last so a user-chosen folder can rescue an unrecognised
		  // layout without shadowing the standard one.
		  AddRoot(roots, AdditionalRoot)

		  Return roots
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddRoot(roots() As FolderItem, candidate As FolderItem)
		  If candidate = Nil Or Not candidate.Exists Or Not candidate.IsFolder Then Return

		  For Each existing As FolderItem In roots
		    If existing.NativePath = candidate.NativePath Then Return
		  Next

		  roots.Add(candidate)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function LiteralFolder(nativePath As String) As FolderItem
		  // An absolute path that has no SpecialFolder equivalent (Linux /opt).
		  // A malformed or absent path raises, so treat failure as "not there".
		  Try
		    Var f As New FolderItem(nativePath, FolderItem.PathModes.Native)
		    If f.Exists And f.IsFolder Then Return f
		  Catch e As RuntimeException
		    Return Nil
		  End Try

		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SortedNewestFirst(versions() As VNSHelpVersion) As VNSHelpVersion()
		  // SortWith sorts the numeric key array ascending and drags the object
		  // array along. Keys are unique (one per release), which SortWith requires.
		  // There is no Array.Reverse, so walk the sorted result backwards.
		  Var sorted() As VNSHelpVersion
		  If versions.LastIndex < 0 Then Return sorted

		  Var keys() As Integer
		  For Each v As VNSHelpVersion In versions
		    keys.Add(v.SortKey)
		  Next

		  keys.SortWith(versions)

		  For i As Integer = versions.LastIndex DownTo 0
		    sorted.Add(versions(i))
		  Next

		  Return sorted
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IndexOfDisplayName(versions() As VNSHelpVersion, displayName As String) As Integer
		  // Position of a remembered version in a scan result, or -1 when that
		  // release is no longer installed. Used to restore the last-used version
		  // at launch without assuming the list is unchanged since last run.
		  If displayName = "" Then Return -1

		  For i As Integer = 0 To versions.LastIndex
		    If versions(i).DisplayName = displayName Then Return i
		  Next

		  Return -1
		End Function
	#tag EndMethod

	#tag Property, Flags = &h0
		AdditionalRoot As FolderItem
	#tag EndProperty

	#tag Constant, Name = kVendorFolderName, Type = String, Dynamic = False, Default = \"Xojo", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kVendorPath, Type = String, Dynamic = False, Default = \"Xojo/Xojo", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kLinuxOptPath, Type = String, Dynamic = False, Default = \"/opt/xojo", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kLinuxConfigPath, Type = String, Dynamic = False, Default = \".config/Xojo/Xojo", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kLinuxHiddenPath, Type = String, Dynamic = False, Default = \".Xojo/Xojo", Scope = Private
	#tag EndConstant

	#tag Note, Name = Description
		Finds the Xojo documentation sets installed on this machine and orders them
		newest first, so the app can open on the most recent one.

		Holds no state: Scan re-reads the directory each time it is called.
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.1.0
		Last change: 2026-07-24 22:49

		------------------------------------------------------------
		0.1.0 — 2026-07-24

		22:49  [NEW] Initial creation — Scan / InstallRoot / IndexOfDisplayName, newest-first ordering via SortWith.
	#tag EndNote

	#tag ViewBehavior
	#tag EndViewBehavior
End Module
#tag EndModule

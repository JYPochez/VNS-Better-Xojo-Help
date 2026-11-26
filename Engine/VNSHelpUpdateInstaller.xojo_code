#tag Module
Protected Module VNSHelpUpdateInstaller
	#tag Method, Flags = &h1
		Protected Function Blocker() As String
		  // Why this copy cannot replace itself; empty when it can.
		  #If DebugBuild Then
		    Return kBlockedDebug
		  #EndIf

		  #If TargetLinux And TargetARM Then
		    // The site's Linux build is x86-64: it would not start here.
		    Return kBlockedARM
		  #EndIf

		  Var target As FolderItem = InstallFolder
		  If target = Nil Then Return kBlockedFolder
		  If target.NativePath.IndexOf(kTranslocationMarker) >= 0 Then Return kBlockedTranslocated

		  // Tried, not asked: on Windows IsWriteable says nothing about the folder's rights.
		  #Pragma BreakOnExceptions Off
		  Try
		    Var probe As FolderItem = target.Child(kProbeName + EncodeHex(Crypto.GenerateRandomBytes(4)))
		    Var stream As BinaryStream = BinaryStream.Create(probe, False)
		    stream.Close
		    probe.Remove
		  Catch e As RuntimeException
		    Return kBlockedFolder
		  End Try
		  #Pragma BreakOnExceptions Default

		  Return ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function InstallFolder() As FolderItem
		  // The folder holding the bundle on macOS, the program on Windows and Linux.
		  #If TargetMacOS Then
		    Var bundle As FolderItem = RunningBundle
		    If bundle = Nil Then Return Nil
		    Return bundle.Parent
		  #Else
		    Return App.ExecutableFile.Parent
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function RunningBundle() As FolderItem
		  // <name>.app/Contents/MacOS/<program>
		  Var item As FolderItem = App.ExecutableFile
		  For level As Integer = 1 To kLevelsToBundle
		    If item = Nil Then Return Nil
		    item = item.Parent
		  Next
		  If item = Nil Or Not item.Name.EndsWith(kAppSuffix) Then Return Nil
		  Return item
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function IsNewer(candidate As String, current As String) As Boolean
		  Var a() As String = candidate.Split(kDot)
		  Var b() As String = current.Split(kDot)
		  For i As Integer = 0 To Max(a.LastIndex, b.LastIndex)
		    Var newPart As Integer
		    Var oldPart As Integer
		    If i <= a.LastIndex Then newPart = a(i).ToInteger
		    If i <= b.LastIndex Then oldPart = b(i).ToInteger
		    If newPart <> oldPart Then Return newPart > oldPart
		  Next
		  Return False
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function PlatformName() As String
		  #If TargetMacOS Then
		    Return kPlatformMac
		  #ElseIf TargetWindows Then
		    Return kPlatformWindows
		  #Else
		    Return kPlatformLinux
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function DownloadURL() As String
		  Return kProductURL + kDownloadPath + PlatformName
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function VersionOnPage(html As String) As String
		  // The page has one link per platform: …/download/macos">  Download for macOS (v0.22.1)
		  Var start As Integer = html.IndexOf(kDownloadPath + PlatformName + kDoubleQuote)
		  If start < 0 Then Return ""
		  Var opening As Integer = html.IndexOf(start, kVersionOpening)
		  If opening < 0 Or opening - start > kLinkSpan Then Return ""
		  opening = opening + kVersionOpening.Length
		  Var closing As Integer = html.IndexOf(opening, kVersionClosing)
		  If closing < 0 Or closing - opening > kVersionSpan Then Return ""

		  Var found As String = html.Middle(opening, closing - opening).Trim
		  Var parts() As String = found.Split(kDot)
		  If parts.Count < kMinimumParts Then Return ""
		  For Each part As String In parts
		    If part = "" Or part.ToInteger.ToString <> part Then Return ""
		  Next
		  Return found
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function NotesBetween(html As String, current As String, offered As String) As String
		  // The release notes of every version after current, up to offered, in the page's own
		  // order, newest first. The page has a tab per release, holding its number, and a panel
		  // with the same index holding its notes. Empty when the page has none.
		  Var sections() As String
		  Var position As Integer = html.IndexOf(kTabMark)
		  While position >= 0
		    position = position + kTabMark.Length
		    Var quote As Integer = html.IndexOf(position, kDoubleQuote)
		    Var opened As Integer = html.IndexOf(position, kTagEnd)
		    Var closed As Integer = html.IndexOf(position, kTagStart)
		    If quote < 0 Or opened < 0 Or closed < opened Then Exit While

		    Var index As String = html.Middle(position, quote - position)
		    Var version As String = html.Middle(opened + 1, closed - opened - 1).Trim
		    If version.BeginsWith(kVersionLetter) Then version = version.Middle(1)
		    If IsNewer(version, current) And Not IsNewer(version, offered) Then
		      Var notes As String = PanelNotes(html, index)
		      If notes <> "" Then sections.Add(kSectionStart + notes + kSectionEnd)
		    End If
		    position = html.IndexOf(closed, kTabMark)
		  Wend
		  // A click is told from anything else the page loads by the scheme alone.
		  Return String.FromArray(sections, "").ReplaceAll(kWebLink, kMarkedLink)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PanelNotes(html As String, index As String) As String
		  Var panel As Integer = html.IndexOf(kPanelMark + index + kDoubleQuote)
		  If panel < 0 Then Return ""
		  Var ending As Integer = html.IndexOf(panel, kSectionEnd)
		  Var notes As Integer = html.IndexOf(panel, kNotesMark)
		  If ending < 0 Or notes < 0 Or notes > ending Then Return ""
		  notes = html.IndexOf(notes, kTagEnd) + 1
		  Var text As String = html.Middle(notes, ending - notes).Trim
		  If text.EndsWith(kDivEnd) Then text = text.Left(text.Length - kDivEnd.Length)
		  Return text
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function WriteNotes(notes As String, work As FolderItem) As FolderItem
		  If work = Nil Then Return Nil
		  Var file As FolderItem = work.Child(kNotesName)
		  If Not WriteText(file, kNotesShell.ReplaceAll(kTokenNotes, notes), False) Then Return Nil
		  Return file
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function NewWorkFolder() As FolderItem
		  // A name nobody can guess, so nothing can be waiting in it.
		  #Pragma BreakOnExceptions Off
		  Try
		    Var folder As FolderItem = SpecialFolder.Temporary.Child(kWorkPrefix + EncodeHex(Crypto.GenerateRandomBytes(8)))
		    folder.CreateFolder
		    Return New FolderItem(folder.NativePath, FolderItem.PathModes.Native)
		  Catch e As RuntimeException
		    Return Nil
		  End Try
		  #Pragma BreakOnExceptions Default
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub RemoveWorkFolder(work As FolderItem)
		  If work = Nil Then Return
		  #Pragma BreakOnExceptions Off
		  Try
		    If work.Exists Then work.RemoveFolderAndContents
		  Catch e As RuntimeException
		    // Left to the system, which empties its temporary folder.
		  End Try
		  #Pragma BreakOnExceptions Default
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function PrepareCommand(download As FolderItem, work As FolderItem, version As String) As String
		  // The command that unpacks the download into <work>/new. On macOS it also refuses
		  // anything but this application, at that version, signed by the same developer and
		  // accepted by Gatekeeper. Empty: nothing to run (Linux unpacks in FinishPrepare).
		  #If TargetMacOS Then
		    Var script As FolderItem = work.Child(kPrepareName)
		    If Not WriteText(script, kPrepareScript, False) Then Return ""
		    Return kBash + PosixQuote(script) + kSpace + PosixQuote(download) + kSpace + PosixQuote(work) + kSpace + _
		    PosixQuote(RunningBundle) + kSpace + PosixQuote(version)
		  #ElseIf TargetWindows Then
		    #Pragma Unused version
		    Var target As FolderItem = work.Child(kNewName)
		    target.CreateFolder
		    Return kWindowsTar + WindowsQuote(download) + kTarInto + WindowsQuote(target)
		  #Else
		    #Pragma Unused download
		    #Pragma Unused work
		    #Pragma Unused version
		    Return ""
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function FinishPrepare(download As FolderItem, work As FolderItem, ByRef failure As String) As FolderItem
		  // The folder whose items replace the installed ones, or Nil.
		  #Pragma BreakOnExceptions Off
		  Try
		    #If TargetLinux Then
		      Var target As FolderItem = work.Child(kNewName)
		      target.CreateFolder
		      download.Unzip(target)
		    #Else
		      #Pragma Unused download
		    #EndIf

		    Var root As New FolderItem(work.NativePath, FolderItem.PathModes.Native)
		    root = root.Child(kNewName)
		    #If TargetMacOS Then
		      If root <> Nil And root.Exists And root.Count > 0 Then Return root
		    #Else
		      Var found As FolderItem = FolderWithProgram(root)
		      If found <> Nil Then Return found
		    #EndIf
		    failure = kNoProgram
		  Catch e As RuntimeException
		    failure = e.Message
		  End Try
		  #Pragma BreakOnExceptions Default
		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FolderWithProgram(root As FolderItem) As FolderItem
		  // The archive holds the build folder, or its content.
		  If root = Nil Or Not root.Exists Then Return Nil
		  Var programName As String = App.ExecutableFile.Name
		  Var program As FolderItem = root.Child(programName)
		  If program <> Nil And program.Exists And Not program.IsFolder Then Return root
		  For Each item As FolderItem In root.Children
		    If Not item.IsFolder Then Continue
		    program = item.Child(programName)
		    If program <> Nil And program.Exists And Not program.IsFolder Then Return item
		  Next
		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function StartSwap(newItems As FolderItem, work As FolderItem) As Boolean
		  // A detached script waits for this process to end, replaces every item the package
		  // holds, putting the old ones back if one fails, and starts the app again. The
		  // caller quits.
		  Var swap As New Shell
		  swap.ExecuteMode = Shell.ExecuteModes.Synchronous
		  swap.TimeOut = kSwapTimeout

		  #If TargetWindows Then
		    Var text As String = kSwapScriptWindows
		    text = text.ReplaceAll(kTokenNew, PowerShellQuote(newItems))
		    text = text.ReplaceAll(kTokenDest, PowerShellQuote(InstallFolder))
		    text = text.ReplaceAll(kTokenLaunch, PowerShellQuote(App.ExecutableFile))
		    text = text.ReplaceAll(kTokenPID, App.ProcessID.ToString)
		    Var script As FolderItem = work.Child(kSwapNameWindows)
		    If Not WriteText(script, text, True) Then Return False

		    // A launcher, because only Start-Process outlives the Shell that runs it.
		    Var launcher As FolderItem = work.Child(kLauncherName)
		    If Not WriteText(launcher, kLauncherScript.ReplaceAll(kTokenScript, script.NativePath.ReplaceAll(kApostrophe, kApostrophe + kApostrophe)), True) Then Return False
		    swap.Execute(kPowerShell + WindowsQuote(launcher))
		  #Else
		    Var script As FolderItem = work.Child(kSwapName)
		    If Not WriteText(script, kSwapScript, False) Then Return False
		    Var launch As FolderItem
		    Var systemName As String
		    #If TargetMacOS Then
		      launch = RunningBundle
		      systemName = kSystemMac
		    #Else
		      launch = App.ExecutableFile
		      systemName = kSystemLinux
		    #EndIf
		    swap.Execute(kNohup + PosixQuote(script) + kSpace + App.ProcessID.ToString + kSpace + PosixQuote(newItems) + kSpace + _
		    PosixQuote(InstallFolder) + kSpace + PosixQuote(launch) + kSpace + systemName + kDetached)
		  #EndIf

		  Return swap.ExitCode = 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function WriteText(file As FolderItem, text As String, withMark As Boolean) As Boolean
		  // withMark: Windows PowerShell reads a script without a UTF-8 mark as ANSI.
		  If file = Nil Then Return False
		  #Pragma BreakOnExceptions Off
		  Try
		    Var stream As BinaryStream = BinaryStream.Create(file, True)
		    If withMark Then stream.Write(DecodeHex(kUTF8Mark))
		    stream.Write(text)
		    stream.Close
		    Return True
		  Catch e As RuntimeException
		    Return False
		  End Try
		  #Pragma BreakOnExceptions Default
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PosixQuote(text As String) As String
		  Return kApostrophe + text.ReplaceAll(kApostrophe, kPosixApostrophe) + kApostrophe
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PosixQuote(item As FolderItem) As String
		  // Without a closing slash, which a folder's path may carry.
		  Var path As String = item.NativePath
		  If path.Length > 1 And path.EndsWith(kSlash) Then path = path.Left(path.Length - 1)
		  Return PosixQuote(path)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PlainPath(item As FolderItem) As String
		  // A closing backslash would escape the quote that follows it.
		  Var path As String = item.NativePath
		  If path.EndsWith(kBackslash) Then path = path.Left(path.Length - 1)
		  Return path
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function WindowsQuote(item As FolderItem) As String
		  Return kDoubleQuote + PlainPath(item) + kDoubleQuote
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PowerShellQuote(item As FolderItem) As String
		  Return kApostrophe + PlainPath(item).ReplaceAll(kApostrophe, kApostrophe + kApostrophe) + kApostrophe
		End Function
	#tag EndMethod

	#tag Constant, Name = kProductURL, Type = String, Dynamic = False, Default = \"https://www.verynicesw.fr/products/better-xojo-help", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kDownloadPath, Type = String, Dynamic = False, Default = \"/download/", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTabMark, Type = String, Dynamic = False, Default = \"data-release-tab\x3D\"", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPanelMark, Type = String, Dynamic = False, Default = \"data-release-panel\x3D\"", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kNotesMark, Type = String, Dynamic = False, Default = \"<div class\x3D\"prose", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTagEnd, Type = String, Dynamic = False, Default = \">", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTagStart, Type = String, Dynamic = False, Default = \"<", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kDivEnd, Type = String, Dynamic = False, Default = \"</div>", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSectionStart, Type = String, Dynamic = False, Default = \"<section>", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSectionEnd, Type = String, Dynamic = False, Default = \"</section>", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kVersionLetter, Type = String, Dynamic = False, Default = \"v", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kWebLink, Type = String, Dynamic = False, Default = \"href\x3D\"http", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMarkedLink, Type = String, Dynamic = False, Default = \"href\x3D\"bxh:http", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kNotesName, Type = String, Dynamic = False, Default = \"notes.html", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTokenNotes, Type = String, Dynamic = False, Default = \"{{NOTES}}", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kNotesShell, Type = String, Dynamic = False, Default = \"<!DOCTYPE html>\n<html><head><meta charset\x3D\"utf-8\">\n<meta http-equiv\x3D\"Content-Security-Policy\" content\x3D\"default-src \'none\'; style-src \'unsafe-inline\'; img-src https: data:\">\n<style>\n:root { color-scheme: light dark; }\nbody { font: 13px/1.5 -apple-system\x2C \"Segoe UI\"\x2C Ubuntu\x2C sans-serif; margin: 14px 18px; color: #222; background: #fff; }\nh1 { font-size: 17px; margin: 0 0 8px; } h2 { font-size: 15px; } h3 { font-size: 14px; }\nsection + section { border-top: 1px solid #ccc; margin-top: 18px; padding-top: 14px; }\nimg { max-width: 100%; height: auto; }\ncode { font: 12px ui-monospace\x2C Menlo\x2C Consolas\x2C monospace; }\n@media (prefers-color-scheme: dark) { body { color: #e5e5e7; background: #1e1e1e; } section + section { border-color: #444; } a { color: #6cb2ff; } }\n</style></head><body>{{NOTES}}</body></html>\n", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPlatformMac, Type = String, Dynamic = False, Default = \"macos", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPlatformWindows, Type = String, Dynamic = False, Default = \"windows", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPlatformLinux, Type = String, Dynamic = False, Default = \"linux", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kVersionOpening, Type = String, Dynamic = False, Default = \"(v", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kVersionClosing, Type = String, Dynamic = False, Default = \")", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kLinkSpan, Type = Integer, Dynamic = False, Default = \"600", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kVersionSpan, Type = Integer, Dynamic = False, Default = \"20", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMinimumParts, Type = Integer, Dynamic = False, Default = \"2", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kDot, Type = String, Dynamic = False, Default = \".", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSpace, Type = String, Dynamic = False, Default = \" ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSlash, Type = String, Dynamic = False, Default = \"/", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kBackslash, Type = String, Dynamic = False, Default = \"\\", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kApostrophe, Type = String, Dynamic = False, Default = \"\'", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPosixApostrophe, Type = String, Dynamic = False, Default = \"\'\\\'\'", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kDoubleQuote, Type = String, Dynamic = False, Default = \"\"", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kAppSuffix, Type = String, Dynamic = False, Default = \".app", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kLevelsToBundle, Type = Integer, Dynamic = False, Default = \"3", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTranslocationMarker, Type = String, Dynamic = False, Default = \"/AppTranslocation/", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kProbeName, Type = String, Dynamic = False, Default = \".better-xojo-help-probe-", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kWorkPrefix, Type = String, Dynamic = False, Default = \"better-xojo-help-update-", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kNewName, Type = String, Dynamic = False, Default = \"new", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPrepareName, Type = String, Dynamic = False, Default = \"prepare.sh", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSwapName, Type = String, Dynamic = False, Default = \"swap.sh", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSwapNameWindows, Type = String, Dynamic = False, Default = \"swap.ps1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kLauncherName, Type = String, Dynamic = False, Default = \"launch.ps1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kBash, Type = String, Dynamic = False, Default = \"/bin/bash ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kWindowsTar, Type = String, Dynamic = False, Default = \"tar -xf ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTarInto, Type = String, Dynamic = False, Default = \" -C ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kNohup, Type = String, Dynamic = False, Default = \"nohup /bin/bash ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kDetached, Type = String, Dynamic = False, Default = \" >/dev/null 2>&1 </dev/null &", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSystemMac, Type = String, Dynamic = False, Default = \"mac", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSystemLinux, Type = String, Dynamic = False, Default = \"linux", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPowerShell, Type = String, Dynamic = False, Default = \"powershell.exe -NoProfile -ExecutionPolicy Bypass -File ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTokenNew, Type = String, Dynamic = False, Default = \"{{NEW}}", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTokenDest, Type = String, Dynamic = False, Default = \"{{DEST}}", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTokenLaunch, Type = String, Dynamic = False, Default = \"{{LAUNCH}}", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTokenPID, Type = String, Dynamic = False, Default = \"{{PID}}", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTokenScript, Type = String, Dynamic = False, Default = \"{{SCRIPT}}", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSwapTimeout, Type = Integer, Dynamic = False, Default = \"30000", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kUTF8Mark, Type = String, Dynamic = False, Default = \"EFBBBF", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kLauncherScript, Type = String, Dynamic = False, Default = \"Start-Process -FilePath \'powershell.exe\' -WindowStyle Hidden -ArgumentList \'-NoProfile\'\x2C\'-ExecutionPolicy\'\x2C\'Bypass\'\x2C\'-File\'\x2C\'\"{{SCRIPT}}\"\'\n", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kNoProgram, Type = String, Dynamic = False, Default = \"The download does not hold Better Xojo Help.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kBlockedDebug, Type = String, Dynamic = False, Default = \"A debug run does not replace itself.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kBlockedARM, Type = String, Dynamic = False, Default = \"The Linux download is for Intel and AMD processors (x86-64).", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kBlockedFolder, Type = String, Dynamic = False, Default = \"Better Xojo Help is in a folder it cannot write to.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kBlockedTranslocated, Type = String, Dynamic = False, Default = \"Move Better Xojo Help to your Applications folder first.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPrepareScript, Type = String, Dynamic = False, Default = \"#!/bin/bash\n# $1 downloaded file (.dmg or .zip)\x2C $2 work folder\x2C $3 running application bundle\x2C $4 offered version\nfail() { echo \"$1\"; exit 1; }\ndownload\x3D\"$1\"; work\x3D\"$2\"; running\x3D\"$3\"; offered\x3D\"$4\"\nmount\x3D\"$work/mount\"; raw\x3D\"$work/raw\"; new\x3D\"$work/new\"\nmkdir -p \"$mount\" \"$raw\" \"$new\" || fail \"The work folder could not be made.\"\nif [ \"$(head -c 2 \"$download\")\" \x3D \"PK\" ]; then\n  /usr/bin/ditto -x -k \"$download\" \"$raw\" || fail \"The download could not be unpacked.\"\nelse\n  /usr/bin/hdiutil attach -quiet -nobrowse -readonly -noautoopen -mountpoint \"$mount\" \"$download\" || fail \"The downloaded disk image could not be opened.\"\n  source_app\x3D$(/usr/bin/find \"$mount\" -maxdepth 1 -name \"*.app\" | head -n 1)\n  copied\x3D1\n  [ -n \"$source_app\" ] && /usr/bin/ditto \"$source_app\" \"$raw/Update.app\" && copied\x3D0\n  /usr/bin/hdiutil detach -quiet \"$mount\" || /usr/bin/hdiutil detach -quiet -force \"$mount\"\n  [ $copied -eq 0 ] || fail \"The application could not be copied from the disk image.\"\nfi\napp\x3D$(/usr/bin/find \"$raw\" -maxdepth 2 -name \"*.app\" -not -path \"*/__MACOSX/*\" | head -n 1)\n[ -n \"$app\" ] || fail \"The download holds no application.\"\ninfo() { /usr/bin/codesign -dvv \"$1\" 2>&1 | /usr/bin/sed -n \"s/^$2\x3D//p\" | head -n 1; }\nteam\x3D$(info \"$running\" TeamIdentifier)\ncase \"$team\" in \"\"|\"not set\") fail \"This copy is not signed by VeryNiceSW\x2C so it cannot check an update.\";; esac\n/usr/bin/codesign --verify --deep --strict \"$app\" >/dev/null 2>&1 || fail \"The signature of the download is not valid.\"\n[ \"$(info \"$app\" TeamIdentifier)\" \x3D \"$team\" ] || fail \"The download is not signed by VeryNiceSW.\"\n[ \"$(info \"$app\" Identifier)\" \x3D \"$(info \"$running\" Identifier)\" ] || fail \"The download is another application.\"\n/usr/sbin/spctl -a -t exec \"$app\" >/dev/null 2>&1 || fail \"macOS does not accept the download (notarization).\"\ngot\x3D$(/usr/libexec/PlistBuddy -c \"Print :CFBundleVersion\" \"$app/Contents/Info.plist\" 2>/dev/null)\ncase \"$got.\" in \"$offered\".*) ;; *) fail \"The download is version $got\x2C not $offered.\";; esac\nmv \"$app\" \"$new/$(basename \"$running\")\" || fail \"The update could not be prepared.\"\nexit 0\n", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSwapScript, Type = String, Dynamic = False, Default = \"#!/bin/bash\n# $1 process to wait for\x2C $2 folder of the new items\x2C $3 folder of the application\x2C $4 what to start\x2C $5 mac or linux\npid\x3D\"$1\"; new\x3D\"$2\"; dest\x3D\"$3\"; launch\x3D\"$4\"; system\x3D\"$5\"\nstart() {\n  if [ \"$system\" \x3D \"mac\" ]; then /usr/bin/open \"$launch\"; else cd \"$dest\" && nohup \"$launch\" >/dev/null 2>&1 </dev/null & fi\n}\ntries\x3D0\nwhile kill -0 \"$pid\" 2>/dev/null; do\n  tries\x3D$((tries + 1)); [ $tries -gt 120 ] && exit 1\n  sleep 0.5\ndone\nold\x3D\"$dest/.better-xojo-help-old-$pid\"\nmkdir \"$old\" || { start; exit 1; }\nshopt -s dotglob nullglob\nfailed\x3D0; moved\x3D()\nfor path in \"$new\"/*; do\n  item\x3D$(basename \"$path\")\n  case \"$item\" in .DS_Store|._*|__MACOSX) continue;; esac\n  if [ -e \"$dest/$item\" ]; then mv \"$dest/$item\" \"$old/$item\" || { failed\x3D1; break; }; fi\n  moved+\x3D(\"$item\")\n  mv \"$path\" \"$dest/$item\" || { failed\x3D1; break; }\ndone\nif [ $failed -eq 1 ]; then\n  for item in \"${moved[@]}\"; do\n    rm -rf \"${dest:\?}/$item\"\n    [ -e \"$old/$item\" ] && mv \"$old/$item\" \"$dest/$item\"\n  done\n  rmdir \"$old\"\nelse\n  [ \"$system\" \x3D \"linux\" ] && chmod +x \"$launch\"\n  rm -rf \"$old\"\nfi\nstart\nexit $failed\n", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSwapScriptWindows, Type = String, Dynamic = False, Default = \"$ErrorActionPreference \x3D \'Stop\'\n$new \x3D {{NEW}}\n$dest \x3D {{DEST}}\n$launch \x3D {{LAUNCH}}\n$old \x3D Join-Path $dest \'.better-xojo-help-old-{{PID}}\'\nfunction Move-Retry($from\x2C $to) {\n  for ($i \x3D 0; ; $i++) {\n    try { Move-Item -LiteralPath $from -Destination $to -Force; return }\n    catch { if ($i -ge 40) { throw }; Start-Sleep -Milliseconds 500 }\n  }\n}\ntry { Wait-Process -Id {{PID}} -Timeout 60 } catch { }\nif (Get-Process -Id {{PID}} -ErrorAction SilentlyContinue) { exit 1 }\n$saved \x3D @()\n$placed \x3D @()\ntry {\n  New-Item -ItemType Directory -Path $old | Out-Null\n  foreach ($item in Get-ChildItem -LiteralPath $new -Force) {\n    if ($item.Name -eq \'.DS_Store\' -or $item.Name -eq \'__MACOSX\' -or $item.Name.StartsWith(\'._\')) { continue }\n    $target \x3D Join-Path $dest $item.Name\n    if (Test-Path -LiteralPath $target) {\n      Move-Retry $target (Join-Path $old $item.Name)\n      $saved +\x3D $item.Name\n    }\n    $placed +\x3D $item.Name\n    Move-Retry $item.FullName $target\n  }\n  Remove-Item -LiteralPath $old -Recurse -Force -ErrorAction SilentlyContinue\n} catch {\n  foreach ($name in $placed) {\n    $target \x3D Join-Path $dest $name\n    if (Test-Path -LiteralPath $target) { Remove-Item -LiteralPath $target -Recurse -Force -ErrorAction SilentlyContinue }\n  }\n  foreach ($name in $saved) {\n    try { Move-Retry (Join-Path $old $name) (Join-Path $dest $name) } catch { }\n  }\n  if (-not (Get-ChildItem -LiteralPath $old -Force -ErrorAction SilentlyContinue)) { Remove-Item -LiteralPath $old -Force -ErrorAction SilentlyContinue }\n}\nStart-Process -FilePath $launch -WorkingDirectory $dest\n", Scope = Private
	#tag EndConstant

	#tag Note, Name = Description
		The app's own update, without any dialog: the version the product page offers for
		this platform, the download's check and unpacking, and the script that replaces the app.
		
		On macOS the download must be this application, signed by the same developer and
		notarized. Windows and Linux builds carry no signature, so there the https address of
		the product page is the only guarantee. No administrator rights are ever asked for.
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.24.0
		Last change: 2026-11-25 12:11

		------------------------------------------------------------
		0.24.0 — 2026-11-25

		12:11  [NEW] Initial creation (P24-1); release notes read from the page (P24-4).
	#tag EndNote

	#tag ViewBehavior
	#tag EndViewBehavior
End Module
#tag EndModule

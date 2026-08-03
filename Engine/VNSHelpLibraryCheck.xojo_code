#tag Module
Protected Module VNSHelpLibraryCheck
	#tag Method, Flags = &h0
		Function MissingLibraries() As String()
		  // Shared libraries this build needs and cannot find, newline-free names only.
		  //
		  // Linux is where this matters. Xojo's own requirements list libwebkit2gtk for
		  // DesktopHTMLViewer, libsoup for URLConnection, Pango for PDFDocument and GTK 3
		  // itself, and distributions ship different subsets — an app that starts and
		  // then shows an empty documentation pane is a miserable thing to diagnose from
		  // the outside.
		  //
		  // The list is not hardcoded. `ldd` is asked what *this* binary links against,
		  // so the answer stays right when Xojo changes its dependencies, and reports
		  // only what is genuinely absent on the machine in front of the user.
		  Var missing() As String

		  #If TargetLinux
		    Var binary As FolderItem = App.ExecutableFile
		    If binary = Nil Then Return missing

		    Var report As String = RunShell(kLddCommand + Quoted(binary.NativePath))
		    If report = "" Then Return missing

		    For Each line As String In report.Split(EndOfLine)
		      If line.IndexOf(kNotFound) < 0 Then Continue

		      Var name As String = line.Trim
		      Var arrow As Integer = name.IndexOf(kArrow)
		      If arrow >= 0 Then name = name.Left(arrow).Trim
		      If name <> "" Then missing.Add(name)
		    Next
		  #EndIf

		  Return missing
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MissingLibrariesMessage() As String
		  // A sentence for the user, or "" when there is nothing wrong. Names the
		  // packages rather than only the sonames: "libwebkit2gtk-4.1.so.0 is missing"
		  // is not something a user can act on, and "install libwebkit2gtk" is.
		  Var missing() As String = MissingLibraries
		  If missing.LastIndex < 0 Then Return ""

		  Var lines() As String
		  lines.Add(kHeading)
		  lines.Add("")

		  For Each name As String In missing
		    lines.Add(kBullet + name + Advice(name))
		  Next

		  lines.Add("")
		  lines.Add(kFooter)

		  Return String.FromArray(lines, EndOfLine)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Advice(soname As String) As String
		  // What the missing library is for, where we know. Xojo names these in its
		  // system requirements; the rest are left bare rather than guessed at.
		  Var lowered As String = soname.Lowercase

		  If lowered.IndexOf(kSoWebKit) >= 0 Then Return kForWebKit
		  If lowered.IndexOf(kSoSoup) >= 0 Then Return kForSoup
		  If lowered.IndexOf(kSoPango) >= 0 Then Return kForPango
		  If lowered.IndexOf(kSoGtk) >= 0 Then Return kForGtk

		  Return ""
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
		  Return kQuote + path.ReplaceAll(kQuote, kEscapedQuote) + kQuote
		End Function
	#tag EndMethod

	#tag Constant, Name = kLddCommand, Type = String, Dynamic = False, Default = \"/usr/bin/ldd ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kNotFound, Type = String, Dynamic = False, Default = \"not found", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kArrow, Type = String, Dynamic = False, Default = \" \x3D> ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kQuote, Type = String, Dynamic = False, Default = \"'", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kEscapedQuote, Type = String, Dynamic = False, Default = \"'\\\"'\\\"'", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kShellTimeout, Type = Integer, Dynamic = False, Default = \"20000", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kBullet, Type = String, Dynamic = False, Default = \"\xE2\x80\xA2 ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSoWebKit, Type = String, Dynamic = False, Default = \"webkit", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSoSoup, Type = String, Dynamic = False, Default = \"soup", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSoPango, Type = String, Dynamic = False, Default = \"pango", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSoGtk, Type = String, Dynamic = False, Default = \"gtk-3", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kForWebKit, Type = String, Dynamic = False, Default = \"  \xE2\x80\x94 the documentation pane will not draw without it", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kForSoup, Type = String, Dynamic = False, Default = \"  \xE2\x80\x94 needed for network access", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kForPango, Type = String, Dynamic = False, Default = \"  \xE2\x80\x94 needed for text layout", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kForGtk, Type = String, Dynamic = False, Default = \"  \xE2\x80\x94 the whole interface depends on it", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHeading, Type = String, Dynamic = False, Default = \"Some libraries this app needs are not installed\x2E", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFooter, Type = String, Dynamic = False, Default = \"Install them through your distribution's package manager. The app will run\x2C but the parts that depend on them will not work properly.", Scope = Private
	#tag EndConstant

	#tag Note, Name = Description
		Checks at startup that the shared libraries this build links against are actually
		present, and says which are missing.

		**Linux only in practice.** macOS and Windows ship what a Xojo app needs; Linux
		distributions ship different subsets, and Xojo's system requirements list
		`libwebkit2gtk` for `DesktopHTMLViewer`, `libsoup` for `URLConnection`, Pango for
		`PDFDocument` and GTK 3 for everything. Missing `libwebkit2gtk` means the
		documentation pane never draws — a symptom that looks like a bug in this app.

		**The list is not hardcoded.** `ldd` is asked what this binary links against, so
		the check cannot fall out of step with what Xojo actually requires, and it reports
		only what is genuinely absent on the user's machine.
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.19.0
		Last change: 2026-07-30 17:05

		------------------------------------------------------------
		0.19.0 — 2026-07-30

		17:05  [NEW] Initial creation.
	#tag EndNote


End Module
#tag EndModule

#tag Class
Protected Class VNSHelpDocBridge
Inherits VNSHelpMCPBridge
	#tag Method, Flags = &h0
		Function Lookup(symbol As String, release As String) As String
		  // One member's documentation as plain text.
		  //
		  // Two sources, because the two eras hold different things. Sphinx releases
		  // ship llms-full.txt, whose per-member sections are exactly what a tool
		  // response wants. The 2015–2019 databases ship no such file, and neither era
		  // anchors a *class* page — only members and sub-sections get anchors — so a
		  // bare class name falls through to a search, which answers it by listing that
		  // class's members. That is a better answer than an error, and it is what an
		  // assistant asking about "DesktopListBox" actually needs.
		  Var found As VNSHelpVersion = ResolveVersion(release)
		  If found = Nil Then Return ""

		  Var source As VNSHelpLLMSSource = SourceFor(found)
		  If source <> Nil Then
		    Var section As String = source.SectionFor(symbol)
		    If section <> "" Then Return Header(found) + section
		  End If

		  Return Search(symbol, release)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Search(query As String, release As String) As String
		  // The same search the window runs, rendered as lines rather than rows. All
		  // terms must match, which is the mode that makes a half-remembered name
		  // findable — see the search notes in CLAUDE.md.
		  Var found As VNSHelpVersion = ResolveVersion(release)
		  If found = Nil Then Return ""

		  Var docSet As VNSHelpDocSet = DocSetFor(found)
		  If docSet = Nil Then Return ""

		  Var hits() As VNSHelpSearchHit = docSet.Search(query, VNSHelpDocSet.eMatch.All)
		  If hits.LastIndex < 0 Then Return ""

		  Var lines() As String
		  lines.Add(Header(found) + kResultsFor + query)

		  Var shown As Integer = 0
		  For Each hit As VNSHelpSearchHit In hits
		    If shown >= kMaximumResults Then Exit
		    shown = shown + 1

		    Var line As String = kBullet + hit.Title
		    If hit.Context <> "" Then line = line + kContextOpen + hit.Context + kContextClose
		    If hit.Deprecated Then line = line + kDeprecatedMark
		    lines.Add(line)
		  Next

		  // Say when the list was cut. A silent truncation reads as "that is all there
		  // is", which would be a lie an assistant then repeats.
		  If hits.Count > shown Then lines.Add(kTruncated)

		  lines.Add(kLookupHint)

		  Return String.FromArray(lines, kNewLine)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ResolveVersion(release As String) As VNSHelpVersion
		  // No release named means the newest, which is what Versions is sorted to give
		  // first. A named one is matched loosely: an assistant is as likely to write
		  // "2026r1.2" as "Xojo 2026r1.2".
		  If Versions = Nil Or Versions.LastIndex < 0 Then Return Nil

		  Var wanted As String = release.Trim.Lowercase
		  If wanted = "" Then Return Versions(0)

		  For Each candidate As VNSHelpVersion In Versions
		    If candidate = Nil Then Continue
		    If candidate.DisplayName.Lowercase = wanted Then Return candidate
		    If candidate.FolderName.Lowercase = wanted Then Return candidate
		    If candidate.FolderName.Lowercase.EndsWith(wanted) Then Return candidate
		  Next

		  // An unknown release falls back to the newest rather than failing. The header
		  // on every answer says which release it actually read, so a wrong guess is
		  // visible rather than silent.
		  Return Versions(0)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DocSetFor(forVersion As VNSHelpVersion) As VNSHelpDocSet
		  // One cached at a time. A client normally asks about a single release over and
		  // over, and rebuilding the catalogue per call would make every tool call pay
		  // for the searchindex parse.
		  If forVersion = Nil Then Return Nil

		  If mCachedDocSet <> Nil And mCachedFolder = forVersion.FolderName Then Return mCachedDocSet

		  mCachedDocSet = VNSHelpDocSet.ForVersion(forVersion)
		  mCachedFolder = forVersion.FolderName
		  mCachedSource = Nil

		  Return mCachedDocSet
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SourceFor(forVersion As VNSHelpVersion) As VNSHelpLLMSSource
		  // Sphinx only: the legacy databases carry no llms-full.txt, so there is
		  // nothing to open and the caller falls through to search.
		  If forVersion = Nil Or forVersion.Era <> VNSHelpVersion.eEra.Sphinx Then Return Nil

		  Call DocSetFor(forVersion)
		  If mCachedSource = Nil Then mCachedSource = New VNSHelpLLMSSource(forVersion)

		  Return mCachedSource
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Header(forVersion As VNSHelpVersion) As String
		  // Every answer names the release it came from. An assistant holding a mix of
		  // versions has no other way to tell, and the difference matters: RowSet in
		  // 2026, RecordSet in 2018.
		  If forVersion = Nil Then Return ""

		  Return kHeaderOpen + forVersion.DisplayName + kHeaderClose
		End Function
	#tag EndMethod

	#tag Property, Flags = &h0
		Versions() As VNSHelpVersion
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCachedDocSet As VNSHelpDocSet
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCachedSource As VNSHelpLLMSSource
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCachedFolder As String
	#tag EndProperty

	#tag Constant, Name = kMaximumResults, Type = Integer, Dynamic = False, Default = \"25", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kNewLine, Type = String, Dynamic = False, Default = \"\n", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kBullet, Type = String, Dynamic = False, Default = \"- ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kContextOpen, Type = String, Dynamic = False, Default = \"  (", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kContextClose, Type = String, Dynamic = False, Default = \")", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kDeprecatedMark, Type = String, Dynamic = False, Default = \"  [deprecated]", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kResultsFor, Type = String, Dynamic = False, Default = \"Results for: ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTruncated, Type = String, Dynamic = False, Default = \"- \x2E\x2E\x2E more results were not shown.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kLookupHint, Type = String, Dynamic = False, Default = \"\nCall xojo_lookup with a Class.Member name for the full documentation of one entry.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHeaderOpen, Type = String, Dynamic = False, Default = \"Xojo ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHeaderClose, Type = String, Dynamic = False, Default = \" documentation\n\n", Scope = Private
	#tag EndConstant

	#tag Note, Name = Description
		The MCP bridge that actually reads documentation. `VNSHelpMCPBridge` handles the
		protocol and knows nothing about doc sets; this overrides its two empty hooks.

		`xojo_lookup` reads a member's section straight out of the release's
		`llms-full.txt`. A bare class name has no anchor there — only members and
		sub-sections get one — so it falls through to a search, which answers it by
		listing that class's members. That is more useful than an error.

		Every answer is headed with the release it came from. An assistant holding
		several versions has no other way to tell, and the difference is the whole point
		of this app: `RowSet` in 2026, `RecordSet` in 2018.
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.17.0
		Last change: 2026-07-29 16:52

		------------------------------------------------------------
		0.17.0 — 2026-07-29

		16:52  [NEW] Initial creation. One doc set cached at a time — a client asks about one release repeatedly, and rebuilding the catalogue per call would make every tool call pay for the searchindex parse.
	#tag EndNote

	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass

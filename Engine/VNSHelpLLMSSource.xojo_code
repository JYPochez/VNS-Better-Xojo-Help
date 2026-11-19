#tag Class
Protected Class VNSHelpLLMSSource
	#tag Method, Flags = &h0
		Sub Constructor(theVersion As VNSHelpVersion)
		  Version = theVersion
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SectionFor(symbol As String) As String
		  // The documentation for one member, as reStructuredText.
		  //
		  // llms-full.txt is the RST source of the whole set — 15 MB on 2026r1.2 —
		  // with 15 107 anchors of the form ".. _desktoplistbox.addrow:". A member's
		  // section runs from its anchor to the next one and is 300–1 500 characters,
		  // which is the right size for a tool response. Code samples come with it.
		  //
		  // See docs/LLMS_TXT.md. The .md siblings look like the obvious source and are
		  // not: they are pandoc output that still carries the HTML, 417 KB for one
		  // class page.
		  EnsureIndex
		  If mOffsets = Nil Then Return ""

		  Var key As String = symbol.Trim.Lowercase
		  If Not mOffsets.HasKey(key) Then Return ""

		  Var start As Integer = mOffsets.Value(key).IntegerValue
		  Var finish As Integer = mText.Bytes
		  If mEnds.HasKey(key) Then finish = mEnds.Value(key).IntegerValue

		  // A member section is small and is returned whole. A class page is not:
		  // DesktopListBox is 188 KB, and its Notes - the prose a caller actually
		  // wants - sit 160 KB in, past any sane truncation. Abridge instead.
		  If finish - start > kMaximumSectionBytes Then
		    Return Tidy(PageDigest(start, finish))
		  End If

		  Return Tidy(mText.MiddleBytes(start, finish - start))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SearchText(query As String, maximum As Integer) As String()
		  // Full text of the documentation prose, which the index search cannot reach.
		  //
		  // VNSHelpDocSet.Search matches titles and context lines, so a phrase that
		  // appears only in a page body is unfindable and the caller is told nothing
		  // exists. The whole file is already in memory and indexed by section, so a
		  // text scan can also name the page each hit sits in.
		  //
		  // All terms must be present in the same page, in any order - the same rule
		  // the index search uses, and for the same reason. Searching for the exact
		  // phrase is too brittle: "two resizing modes" appears in the documentation as
		  // two resizing "modes", quotes included, and an exact match finds nothing.
		  Var results() As String

		  EnsureIndex
		  If mText = "" Then Return results

		  Var terms() As String = query.Trim.Lowercase.Split(kSpace)
		  Var wanted() As String
		  For Each term As String In terms
		    If term <> "" Then wanted.Add(term)
		  Next
		  If wanted.Count = 0 Then Return results

		  EnsureSearchText
		  EnsureOrderedKeys

		  Var first As String = wanted(0)
		  Var seen As New Dictionary
		  Var position As Integer = 0

		  While results.Count < maximum
		    Var at As Integer = mSearchText.IndexOfBytes(position, first)
		    If at < 0 Then Exit
		    position = at + first.Bytes

		    Var index As Integer = PageIndexAt(at)
		    If index < 0 Then Continue

		    // One hit per page: a term repeated through a long class page would
		    // otherwise fill the answer with the same name.
		    Var key As String = mOrderedKeys(index)
		    If seen.HasKey(key) Then Continue

		    Var pageStart As Integer = mOrderedStarts(index)
		    Var pageEnd As Integer = mSearchText.Bytes
		    If index < mOrderedStarts.LastIndex Then pageEnd = mOrderedStarts(index + 1)

		    If Not PageHasAll(wanted, pageStart, pageEnd) Then Continue

		    seen.Value(key) = True
		    results.Add(key + kContextJoin + ContextAround(at, first.Bytes))
		  Wend

		  Return results
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PageHasAll(wanted() As String, pageStart As Integer, pageEnd As Integer) As Boolean
		  // Every term after the first has to appear inside this page too.
		  For i As Integer = 1 To wanted.LastIndex
		    Var at As Integer = mSearchText.IndexOfBytes(pageStart, wanted(i))
		    If at < 0 Or at >= pageEnd Then Return False
		  Next

		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub EnsureSearchText()
		  // A lowercased copy, so the scan is case-insensitive without lowercasing the
		  // needle against a mixed-case haystack.
		  //
		  // Lowercasing can change the byte length of some non-ASCII characters, which
		  // would put every offset out of step with the section index. If that happens
		  // the copy is abandoned and the search runs case-sensitively rather than
		  // returning confidently wrong locations.
		  If mSearchText <> "" Then Return

		  Var lowered As String = mText.Lowercase
		  If lowered.Bytes = mText.Bytes Then
		    mSearchText = lowered
		  Else
		    mSearchText = mText
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub EnsureOrderedKeys()
		  // The section index maps key to offset. To go the other way - offset to the
		  // page it falls in - the starts have to be in order, so they are sorted once
		  // and searched by halving. Offsets are unique, which is what SortWith needs.
		  If mOrderedStarts.Count > 0 Then Return
		  If mOffsets = Nil Then Return

		  For Each entry As DictionaryEntry In mOffsets
		    mOrderedKeys.Add(entry.Key.StringValue)
		    mOrderedStarts.Add(entry.Value.IntegerValue)
		  Next

		  mOrderedStarts.SortWith(mOrderedKeys)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PageIndexAt(offset As Integer) As Integer
		  // The page containing this offset: the last section starting at or before it.
		  If mOrderedStarts.Count = 0 Then Return -1

		  Var low As Integer = 0
		  Var high As Integer = mOrderedStarts.LastIndex
		  Var best As Integer = -1

		  While low <= high
		    Var middle As Integer = (low + high) \ 2
		    If mOrderedStarts(middle) <= offset Then
		      best = middle
		      low = middle + 1
		    Else
		      high = middle - 1
		    End If
		  Wend

		  Return best
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ContextAround(at As Integer, length As Integer) As String
		  // Enough either side to see why the hit matched, on one line.
		  Var from As Integer = at - kContextRadius
		  If from < 0 Then from = 0

		  Var upto As Integer = at + length + kContextRadius
		  If upto > mSearchText.Bytes Then upto = mSearchText.Bytes

		  Var snippet As String = mSearchText.MiddleBytes(from, upto - from)

		  Return snippet.ReplaceAll(kNewLine, kSpace).Trim
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasSymbol(symbol As String) As Boolean
		  EnsureIndex
		  If mOffsets = Nil Then Return False

		  Return mOffsets.HasKey(symbol.Trim.Lowercase)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub EnsureIndex()
		  // Read and indexed once, on first use. 15 MB is far too much to scan per
		  // request, and a release that is never asked about never pays for it.
		  If mIndexLoaded Then Return
		  mIndexLoaded = True

		  Var file As FolderItem = SourceFile
		  If file = Nil Or Not file.Exists Then Return

		  mText = ReadWholeFile(file)
		  If mText = "" Then Return

		  mOffsets = New Dictionary
		  mEnds = New Dictionary

		  // Anchors are line-anchored: ".. _name:" at the start of a line. Scanning for
		  // the marker and then checking it begins its line is far cheaper than
		  // splitting 15 MB into lines.
		  Var previousKey As String
		  Var position As Integer = 0

		  While True
		    Var at As Integer = mText.IndexOfBytes(position, kAnchorPrefix)
		    If at < 0 Then Exit

		    position = at + kAnchorPrefix.Bytes
		    If at > 0 And mText.MiddleBytes(at - 1, 1) <> kNewLine Then Continue

		    Var close As Integer = mText.IndexOfBytes(position, kAnchorSuffix)
		    If close < 0 Then Exit

		    Var name As String = mText.MiddleBytes(position, close - position)
		    If name = "" Or name.IndexOfBytes(0, kNewLine) >= 0 Then Continue

		    // The previous section stops where this one starts.
		    Var key As String = name.Lowercase
		    If previousKey <> "" Then mEnds.Value(previousKey) = at

		    mOffsets.Value(key) = close + kAnchorSuffix.Bytes
		    previousKey = key
		    position = close + kAnchorSuffix.Bytes
		  Wend

		  IndexHeadings
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub IndexHeadings()
		  // A second pass over the page titles, because anchors alone do not cover the
		  // set.
		  //
		  // Members are anchored ".. _desktoplistbox.columnwidths:" and resolve fine.
		  // Language keywords and operators are not: GetTypeInfo carries only
		  // ".. _/api/language/gettypeinfo/usage:", an anchor for its Usage subsection,
		  // so a lookup for the symbol itself found nothing and fell through to a
		  // search - which answers with an index listing instead of a signature. About
		  // a quarter of the anchors in 2026r2.1 are path-style like that.
		  //
		  // The page title is an RST heading: a rule of "=", the title, another rule.
		  // Indexing those gives the whole page, Description and Usage together, which
		  // is what the signature question actually needs.
		  // Built here rather than as a constant: an escape sequence in a constant
		  // default is rejected by the compiler.
		  Var rule As String = kNewLine + kHeadingMarker

		  Var position As Integer = 0

		  While True
		    Var at As Integer = mText.IndexOfBytes(position, rule)
		    If at < 0 Then Exit
		    position = at + rule.Bytes

		    // at points at the newline before the rule.
		    Var overlineStart As Integer = at + kNewLine.Bytes
		    Var overlineEnd As Integer = mText.IndexOfBytes(overlineStart, kNewLine)
		    If overlineEnd < 0 Then Exit
		    If Not IsRuleLine(mText.MiddleBytes(overlineStart, overlineEnd - overlineStart)) Then Continue

		    Var titleStart As Integer = overlineEnd + kNewLine.Bytes
		    Var titleEnd As Integer = mText.IndexOfBytes(titleStart, kNewLine)
		    If titleEnd < 0 Then Exit

		    Var title As String = mText.MiddleBytes(titleStart, titleEnd - titleStart).Trim
		    If title = "" Or title.Bytes > kMaximumTitleBytes Then Continue

		    // A title is only a title when a matching rule closes it; a lone rule is a
		    // horizontal separator, of which the file has many.
		    Var underlineStart As Integer = titleEnd + kNewLine.Bytes
		    Var underlineEnd As Integer = mText.IndexOfBytes(underlineStart, kNewLine)
		    If underlineEnd < 0 Then Exit
		    If Not IsRuleLine(mText.MiddleBytes(underlineStart, underlineEnd - underlineStart)) Then Continue

		    // An anchor is more precise than a page title, so an existing key wins.
		    Var key As String = title.Lowercase
		    If mOffsets.HasKey(key) Then Continue

		    mOffsets.Value(key) = overlineStart
		    mEnds.Value(key) = EndOfSectionFrom(underlineEnd + kNewLine.Bytes)
		  Wend
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IsRuleLine(line As String) As Boolean
		  // True for "=====", the RST rule that brackets a page title.
		  Var trimmed As String = line.Trim
		  If trimmed.Bytes < kMinimumRuleBytes Then Return False

		  For i As Integer = 1 To trimmed.Bytes
		    If trimmed.MiddleBytes(i - 1, 1) <> kEquals Then Return False
		  Next

		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PageDigest(start As Integer, finish As Integer) As String
		  // The opening of the page, plus its Notes section if it has one.
		  //
		  // The opening carries the description and the property and method tables,
		  // which is what "what is this class" means. Notes carries the caveats, and on
		  // DesktopListBox they sit 160 KB in - past any truncation - which is why they
		  // were missing entirely. Both are wanted, so both are returned.
		  // Cut on a line boundary. Cutting at an exact byte count landed mid-":doc:"
		  // role, and StripRole then ran forward hunting the closing backtick - eating
		  // the separator and the first line of the Notes with it.
		  Var leadEnd As Integer = start + kMaximumSectionBytes
		  If leadEnd > finish Then leadEnd = finish

		  // The framework has IndexOfBytes but no LastIndexOfBytes, so walk back to the
		  // line break. Bounded: documentation lines are short, and a run longer than
		  // this is not worth chasing.
		  Var scanned As Integer = 0
		  While leadEnd > start And scanned < kMaximumLineScan
		    If mText.MiddleBytes(leadEnd - kNewLine.Bytes, kNewLine.Bytes) = kNewLine Then Exit
		    leadEnd = leadEnd - 1
		    scanned = scanned + 1
		  Wend

		  Var lead As String = mText.MiddleBytes(start, leadEnd - start)

		  Var notes As String = NotesWithin(start, finish)
		  If notes = "" Then Return lead + kTwoNewLines + kAbridgedMark

		  Return lead + kTwoNewLines + kAbridgedMark + kTwoNewLines + notes
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function NotesWithin(start As Integer, finish As Integer) As String
		  // The page's Notes section: the title line, its underline, then prose until
		  // the horizontal rule that ends it.
		  Var marker As String = kNewLine + kNotesTitle + kNewLine
		  Var at As Integer = mText.IndexOfBytes(start, marker)
		  If at < 0 Or at >= finish Then Return ""

		  Var stop As Integer = mText.IndexOfBytes(at + marker.Bytes, kNewLine + kRuleLine + kNewLine)
		  If stop < 0 Or stop > finish Then stop = finish
		  If stop - at > kNotesMaximumBytes Then stop = at + kNotesMaximumBytes

		  Return mText.MiddleBytes(at + kNewLine.Bytes, stop - at - kNewLine.Bytes)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function EndOfSectionFrom(start As Integer) As Integer
		  // A page runs to the next page title, and deliberately not to the next
		  // anchor: a page's own subsections are anchored too, so stopping at the first
		  // anchor cut GetTypeInfo off after "Description" and lost the Usage block -
		  // the signature, which is the whole reason to look a keyword up.
		  //
		  // Capped because a long topic page is not a useful tool response. Members are
		  // unaffected: they come from the anchor pass and keep their exact bounds.
		  Var finish As Integer = mText.Bytes

		  Var nextHeading As Integer = mText.IndexOfBytes(start, kNewLine + kHeadingMarker)
		  If nextHeading >= 0 And nextHeading < finish Then finish = nextHeading

		  // The true page boundary is kept. Trimming happens at read time, where the
		  // size is known and a class page can be abridged intelligently rather than
		  // chopped at a byte count.
		  Return finish
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Tidy(section As String) As String
		  // Enough to read, not a full RST renderer. Two substitutions earn their keep:
		  // :doc:`Text</path>` and :ref:`Text<anchor>` are everywhere and reduce to
		  // their link text, and the rule lines that separate members are noise once a
		  // section has been cut out on its own.
		  Var out As String = section

		  For Each role As String In Array(kRoleDoc, kRoleRef, kRoleCode)
		    out = StripRole(out, role)
		  Next

		  out = out.ReplaceAll(kRuleLine, "")
		  out = out.ReplaceAll(kForSearch, "")
		  out = out.ReplaceAll(kCodeDirective, kCodeFence)

		  // Collapse the blank runs left behind, so a 1 000-character answer is not
		  // half empty lines.
		  While out.IndexOf(kThreeNewLines) >= 0
		    out = out.ReplaceAll(kThreeNewLines, kTwoNewLines)
		  Wend

		  Return out.Trim
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function StripRole(source As String, role As String) As String
		  // :doc:`DesktopListBox</api/...>` becomes DesktopListBox. The target is
		  // dropped rather than kept: an assistant cannot follow a path, and the name
		  // is the part that carries meaning.
		  Var out As String = source
		  Var guard As Integer = 0

		  While guard < kMaximumRoles
		    guard = guard + 1

		    Var at As Integer = out.IndexOf(role)
		    If at < 0 Then Exit

		    Var open As Integer = out.IndexOf(at, kBacktick)
		    If open < 0 Then Exit

		    Var close As Integer = out.IndexOf(open + 1, kBacktick)
		    If close < 0 Then Exit

		    Var inner As String = out.Middle(open + 1, close - open - 1)

		    // The link target sits in <…> at the end of the text. Anything before it is
		    // what the reader sees.
		    Var bracket As Integer = inner.IndexOf(kAngleOpen)
		    If bracket > 0 Then inner = inner.Left(bracket)

		    out = out.Left(at) + inner.Trim + out.Middle(close + 1)
		  Wend

		  Return out
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SourceFile() As FolderItem
		  If Version = Nil Or Version.DocRoot = Nil Then Return Nil

		  Return Version.DocRoot.Child(kSourceName)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ReadWholeFile(file As FolderItem) As String
		  Var stream As TextInputStream

		  Try
		    stream = TextInputStream.Open(file)
		    Return stream.ReadAll(Encodings.UTF8)
		  Catch e As IOException
		    Return ""
		  Finally
		    If stream <> Nil Then stream.Close
		  End Try
		End Function
	#tag EndMethod

	#tag Property, Flags = &h0
		Version As VNSHelpVersion
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mText As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mOffsets As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mEnds As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSearchText As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mOrderedKeys() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mOrderedStarts() As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mIndexLoaded As Boolean
	#tag EndProperty

	#tag Constant, Name = kSourceName, Type = String, Dynamic = False, Default = \"llms-full.txt", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kAnchorPrefix, Type = String, Dynamic = False, Default = \".. _", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kAnchorSuffix, Type = String, Dynamic = False, Default = \":", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kNewLine, Type = String, Dynamic = False, Default = \"\n", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTwoNewLines, Type = String, Dynamic = False, Default = \"\n\n", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kThreeNewLines, Type = String, Dynamic = False, Default = \"\n\n\n", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kRoleDoc, Type = String, Dynamic = False, Default = \":doc:", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kRoleRef, Type = String, Dynamic = False, Default = \":ref:", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kRoleCode, Type = String, Dynamic = False, Default = \":code:", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kBacktick, Type = String, Dynamic = False, Default = \"`", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kAngleOpen, Type = String, Dynamic = False, Default = \"<", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kRuleLine, Type = String, Dynamic = False, Default = \"----", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHeadingMarker, Type = String, Dynamic = False, Default = \"\x3D\x3D\x3D", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kEquals, Type = String, Dynamic = False, Default = \"\x3D", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMinimumRuleBytes, Type = Integer, Dynamic = False, Default = \"3", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMaximumTitleBytes, Type = Integer, Dynamic = False, Default = \"80", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMaximumSectionBytes, Type = Integer, Dynamic = False, Default = \"8000", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kNotesMaximumBytes, Type = Integer, Dynamic = False, Default = \"4000", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMaximumLineScan, Type = Integer, Dynamic = False, Default = \"400", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kContextRadius, Type = Integer, Dynamic = False, Default = \"70", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kContextJoin, Type = String, Dynamic = False, Default = \" \x2D ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSpace, Type = String, Dynamic = False, Default = \" ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kNotesTitle, Type = String, Dynamic = False, Default = \"Notes", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kAbridgedMark, Type = String, Dynamic = False, Default = \"[long page abridged: opening and Notes only. Ask for a specific member to get its full entry.]", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kForSearch, Type = String, Dynamic = False, Default = \".. rst-class:: forsearch", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCodeDirective, Type = String, Dynamic = False, Default = \".. code:: xojo", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCodeFence, Type = String, Dynamic = False, Default = \"Example:", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMaximumRoles, Type = Integer, Dynamic = False, Default = \"400", Scope = Private
	#tag EndConstant

	#tag Note, Name = Description
		Reads a release's `llms-full.txt` — the reStructuredText source of its whole
		documentation set — and hands back one member's section on demand.

		Sphinx era only. The 2015–2019 databases ship no such file; that era already has
		member-level text in `cached_descriptions`, so the legacy provider answers from
		there instead.

		Indexed lazily and once: 15 MB is far too much to scan per request, and a
		release nobody asks about never pays for it.
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.17.0
		Last change: 2026-07-29 16:52

		------------------------------------------------------------
		0.17.0 — 2026-07-29

		16:52  [NEW] Initial creation. Anchors are matched line-anchored: scanning for ".. _" and then checking it starts a line is far cheaper than splitting 15 MB into lines.
	#tag EndNote

	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass

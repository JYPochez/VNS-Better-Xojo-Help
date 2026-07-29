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

		  Return Tidy(mText.MiddleBytes(start, finish - start))
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
		End Sub
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

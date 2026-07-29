#tag Class
Protected Class VNSHelpDocSet
	#tag Method, Flags = &h0
		Shared Function ForVersion(theVersion As VNSHelpVersion) As VNSHelpDocSet
		  // The provider that can read this release's documentation, or Nil when
		  // its format is not supported yet. Nil is deliberate: the window can then
		  // say so, where an empty doc set would look like a version with no
		  // content and hide the reason.
		  If theVersion = Nil Then Return Nil

		  Select Case theVersion.Era
		  Case VNSHelpVersion.eEra.Sphinx
		    Return New VNSHelpSphinxDocSet(theVersion)
		  Case VNSHelpVersion.eEra.LegacyDB
		    Return New VNSHelpLegacyDocSet(theVersion)
		  End Select

		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(theVersion As VNSHelpVersion)
		  Version = theVersion
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function RewriteAnchorHrefs(body As String, context As String) As String
		  // Every <a> in the fragment gets its href replaced by whatever LinkHrefFor
		  // returns for it, so a click arrives at the window as a target this app can
		  // resolve rather than as a file for the viewer to fetch.
		  //
		  // Only anchors are touched, deliberately. A <link rel="icon"> or a stylesheet
		  // also carries an href, and rewriting those would turn a page load into a
		  // navigation event: the 2015 blobs each reference /favicon.ico and
		  // /opensearch_desc.php in their head.
		  //
		  // Pieces are collected and joined rather than concatenated in place. Some pages
		  // carry over 400 links and a Sphinx article body can reach 400 KB.
		  Var pieces() As String
		  Var hrefBytes As Integer = kHrefAttribute.Bytes
		  Var position As Integer = 0

		  While True
		    Var tagStart As Integer = body.IndexOfBytes(position, kAnchorTagOpen)
		    If tagStart < 0 Then
		      pieces.Add(body.MiddleBytes(position))
		      Exit
		    End If

		    Var tagEnd As Integer = body.IndexOfBytes(tagStart, kTagClose)
		    If tagEnd < 0 Then
		      pieces.Add(body.MiddleBytes(position))
		      Exit
		    End If

		    // "<a" also starts <abbr>, <address> and <area>, so the tag name has to end
		    // right there. Anything that is not an anchor, or an anchor with no usable
		    // href, is copied through as far as its closing bracket.
		    Var href As Integer = body.IndexOfBytes(tagStart, kHrefAttribute)
		    Var valueStart As Integer = href + hrefBytes
		    Var valueEnd As Integer = -1
		    If href >= 0 And href < tagEnd Then valueEnd = body.IndexOfBytes(valueStart, kQuoteChar)

		    If Not IsTagNameEnd(body.MiddleBytes(tagStart + kAnchorTagOpen.Bytes, 1)) _
		      Or valueEnd < 0 Or valueEnd > tagEnd Then
		      pieces.Add(body.MiddleBytes(position, tagEnd + 1 - position))
		      position = tagEnd + 1
		      Continue
		    End If

		    pieces.Add(body.MiddleBytes(position, valueStart - position))
		    pieces.Add(LinkHrefFor(context, body.MiddleBytes(valueStart, valueEnd - valueStart)))
		    position = valueEnd
		  Wend

		  Return String.FromArray(pieces, "")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function LinkHrefFor(context As String, reference As String) As String
		  // One href, rewritten. Overridden per format: the two eras write their links
		  // completely differently and only the provider can tell whether a reference
		  // names a page it holds. The context is whatever that provider needs to make
		  // sense of a relative reference — for Sphinx, the folder the page lives in.
		  #Pragma Unused context
		  Return reference
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function ExternalLinkHref(url As String) As String
		  // An address that belongs to the browser. It goes through the same numbered
		  // table as a page link, marked so the window can tell them apart.
		  //
		  // Routing it through the table rather than leaving it in the markup is what
		  // makes the window's CancelLoad safe: it then acts only on our own schemes and
		  // never has to guess whether an http URL arriving there is a click or a
		  // resource the page is pulling in by itself.
		  //
		  // It carries its own scheme rather than being a bxh: link with a marked target,
		  // because CSS can select on an href: a[href^="bxhweb:"]::after is what puts the
		  // arrow on exactly these anchors, with no class attribute and no second pass
		  // over the markup. The stored target keeps the marker too, so the array stays
		  // self-describing.
		  mLinkTargets.Add(kExternalPrefix + url.ReplaceAll(kEntityAmpersand, kAmpersand))

		  Var index As Integer = mLinkTargets.LastIndex
		  Return kExternalScheme + index.ToString
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function HasScheme(reference As String) As Boolean
		  // True for mailto:, http:, https:, ftp:, file:, data: and anything else
		  // carrying a scheme. A colon only counts when it comes before the first slash,
		  // so a path with a colon in a filename is still treated as a path.
		  Var colon As Integer = reference.IndexOfBytes(0, kColon)
		  If colon < 0 Then Return False

		  Var slash As Integer = reference.IndexOfBytes(0, kSlash)
		  If slash >= 0 And slash < colon Then Return False

		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IsTagNameEnd(char As String) As Boolean
		  // Whitespace, a slash or the closing bracket end a tag name. An empty string
		  // means the fragment stopped mid-tag, which is not an anchor either.
		  If char = "" Then Return False

		  Return kTagNameEnders.IndexOfBytes(0, char) >= 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RootTopics() As VNSHelpTopic()
		  Var none() As VNSHelpTopic
		  Return none
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ChildTopics(parentKey As String) As VNSHelpTopic()
		  #Pragma Unused parentKey
		  Var none() As VNSHelpTopic
		  Return none
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function PageHTML(pageKey As String, ByRef baseFile As FolderItem) As String
		  // baseFile is the file the fragment's relative references should resolve
		  // against — LoadPage resolves against a file, not a folder.
		  #Pragma Unused pageKey
		  baseFile = Nil
		  Return ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Search(query As String, mode As VNSHelpDocSet.eMatch) As VNSHelpSearchHit()
		  #Pragma Unused query
		  #Pragma Unused mode
		  Var none() As VNSHelpSearchHit
		  Return none
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SearchTerms(query As String, mode As VNSHelpDocSet.eMatch) As String()
		  // The query broken into the terms a provider should match, already lowered.
		  //
		  // Exact keeps the whole query as one term, which is what the search did before
		  // there were modes — so a single-word query behaves identically in all three.
		  Var terms() As String

		  Var trimmed As String = query.Trim.Lowercase
		  If trimmed = "" Then Return terms

		  If mode = VNSHelpDocSet.eMatch.Exact Then
		    terms.Add(trimmed)
		    Return terms
		  End If

		  For Each word As String In trimmed.Split(kSpace)
		    If word <> "" Then terms.Add(word)
		  Next

		  Return terms
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function MatchesTerms(haystack As String, terms() As String, mode As VNSHelpDocSet.eMatch) As Boolean
		  // Any means at least one term is present; All and Exact both mean every term is
		  // — Exact only ever has one, so the same walk serves both.
		  If terms.LastIndex < 0 Then Return False

		  Var lowered As String = haystack.Lowercase

		  For Each term As String In terms
		    Var found As Boolean = lowered.IndexOfBytes(0, term) >= 0

		    If mode = VNSHelpDocSet.eMatch.Any Then
		      If found Then Return True
		    ElseIf Not found Then
		      Return False
		    End If
		  Next

		  Return mode <> VNSHelpDocSet.eMatch.Any
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function TotalOccurrences(html As String, terms() As String) As Integer
		  // Every term counted, so a page carrying both halves of a two-word query ranks
		  // above one carrying either half twice as often.
		  Var total As Integer = 0
		  For Each term As String In terms
		    total = total + OccurrenceCount(html, term)
		  Next

		  Return total
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LinkTargets() As String()
		  // The page keys the last PageHTML call rewrote this page's links to, in the
		  // order those links were numbered. The window keeps the array and resolves a
		  // clicked "bxh:<n>" against it.
		  Var targets() As String
		  For Each target As String In mLinkTargets
		    targets.Add(target)
		  Next

		  Return targets
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub ResetLinkTargets()
		  // Called at the top of PageHTML: the numbering is per rendered page.
		  mLinkTargets.RemoveAll
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function LinkHref(pageKey As String) As String
		  // Register a link target and return the href to write in its place.
		  //
		  // The href carries the target's position, not the key itself. A key contains
		  // "#" and can contain characters that would need percent-encoding to survive
		  // in a URL, while a number cannot be mangled. This is the mechanism the
		  // generated overview pages already use — see VNSHelpRenderer.OverviewFragment.
		  mLinkTargets.Add(pageKey)

		  // The index goes into a variable first: a method cannot be called on a
		  // parenthesised expression, so (mLinkTargets.LastIndex).ToString would not
		  // compile.
		  Var index As Integer = mLinkTargets.LastIndex
		  Return kLinkScheme + index.ToString
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function DeadLinkHref() As String
		  // A link the markup offers but this documentation set cannot resolve. There
		  // are plenty of both kinds: Xojo's own Sphinx pages reference pages that
		  // release did not ship, and the legacy wiki blobs carry a whole navigation
		  // skin pointing at Special: and File: pages that were never captured.
		  //
		  // It stays a link so the sentence still reads as written, but it resolves to
		  // nothing — the index is out of range, so the window's CancelLoad swallows the
		  // click rather than sending the viewer to a file that is not there.
		  //
		  // A marker rather than an out-of-range number: a number has to be parsed back,
		  // and a parse that failed would land on 0, which is a real link.
		  Return kLinkScheme + kDeadLinkMarker
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TitleForKey(pageKey As String) As String
		  #Pragma Unused pageKey
		  Return ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RenderFolder() As FolderItem
		  // A folder this app owns, holding the assets a page needs. The finished
		  // page is written here so the viewer loads a real document sitting beside
		  // its own images — the only arrangement that renders local images. See
		  // VNSHelpRenderer.WriteToFile.
		  If mAssetFolder <> Nil Then Return mAssetFolder
		  If Version = Nil Then Return Nil

		  Var base As FolderItem = SpecialFolder.ApplicationData
		  If base = Nil Or Not base.Exists Then Return Nil

		  Var folder As FolderItem = EnsureFolder(base, kPreferencesFolderName)
		  folder = EnsureFolder(folder, kAssetsFolderName)
		  folder = EnsureFolder(folder, Version.DisplayName)

		  mAssetFolder = folder
		  Return mAssetFolder
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function EnsureFolder(parent As FolderItem, name As String) As FolderItem
		  If parent = Nil Or Not parent.Exists Then Return Nil

		  Var folder As FolderItem = parent.Child(name)
		  If folder = Nil Then Return Nil
		  If folder.Exists Then Return folder

		  Try
		    folder.CreateFolder
		  Catch e As IOException
		    Return Nil
		  End Try

		  Return folder
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function PlainText(html As String) As String
		  // The text of an HTML fragment, with every tag replaced by a space so
		  // words either side of a tag do not run together. Deliberately not a
		  // RegEx: this runs over 400 KB pages once per search candidate.
		  Var pieces() As String
		  Var position As Integer = 0
		  Var length As Integer = html.Bytes

		  While position < length
		    Var tagStart As Integer = html.IndexOfBytes(position, kTagOpen)
		    If tagStart < 0 Then
		      pieces.Add(html.MiddleBytes(position))
		      Exit
		    End If

		    If tagStart > position Then pieces.Add(html.MiddleBytes(position, tagStart - position))

		    Var tagEnd As Integer = html.IndexOfBytes(tagStart, kTagClose)
		    If tagEnd < 0 Then Exit

		    pieces.Add(kSpace)
		    position = tagEnd + 1
		  Wend

		  Return String.FromArray(pieces, "")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function OccurrenceCount(html As String, loweredNeedle As String) As Integer
		  // How many times the term appears in the page's text — the value results
		  // are ranked by. Counted in the text, not the markup, so a word inside a
		  // link target or a class name is not counted.
		  If loweredNeedle = "" Then Return 0

		  Var text As String = PlainText(html).Lowercase
		  Var needleBytes As Integer = loweredNeedle.Bytes
		  Var count As Integer = 0
		  Var position As Integer = 0

		  While True
		    Var hit As Integer = text.IndexOfBytes(position, loweredNeedle)
		    If hit < 0 Then Return count

		    count = count + 1
		    position = hit + needleBytes
		  Wend
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function SortedByRank(hits() As VNSHelpSearchHit) As VNSHelpSearchHit()
		  // Most occurrences first, ties keeping the order they were found in — but
		  // everything deprecated after everything that is not, however often the term
		  // appears in it. A deprecated page repeats the name of its replacement, so it
		  // scores highly on exactly the searches where it is least wanted: "list add" on
		  // 2026r1.2 put six ListBox (deprecated) members above every live one.
		  //
		  // SortWith needs unique base values, so the position is folded into the key:
		  // negating the rank turns the ascending sort into a descending one, and the
		  // penalty is far larger than any rank can reach.
		  //
		  // The window sets DeprecatedLast from the preferences. It is a property here
		  // rather than a read of VNSHelpPreferences so that Engine stays free of UI.
		  Var sorted() As VNSHelpSearchHit
		  If hits.LastIndex < 0 Then Return sorted

		  Var keys() As Integer
		  For i As Integer = 0 To hits.LastIndex
		    Var key As Integer = i - hits(i).Rank * kRankScale
		    If DeprecatedLast And hits(i).Deprecated Then key = key + kDeprecatedPenalty

		    keys.Add(key)
		  Next

		  keys.SortWith(hits)

		  For Each hit As VNSHelpSearchHit In hits
		    sorted.Add(hit)
		  Next

		  Return sorted
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function AssetAlreadyPresent(name As String) As Boolean
		  // True when this asset has already been placed in the render folder, so a
		  // page visited a second time costs nothing.
		  Var folder As FolderItem = RenderFolder
		  If folder = Nil Then Return False

		  Var target As FolderItem = folder.Child(name)
		  Return target <> Nil And target.Exists
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function WebURL(pageKey As String) As String
		  // The address of this page on Xojo's own site, or "" when there is none to
		  // offer — which is the honest answer for the legacy era, so this default stands
		  // for it. The window disables its globe on an empty string.
		  #Pragma Unused pageKey
		  Return ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StyleSheet() As String
		  // Extra CSS to apply to this set's pages, on top of the reader's own.
		  // Used to carry each release's syntax colouring for code samples.
		  Return ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function PageCount() As Integer
		  Return 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OverviewPageKey(groupKey As String) As String
		  // The page that best describes a group, or "" when the format has no
		  // such notion. Selecting a group in the tree shows this.
		  #Pragma Unused groupKey
		  Return ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AnchorFromKey(pageKey As String) As String
		  // Everything after the "#", or "" when the key names a whole page.
		  Var hash As Integer = pageKey.IndexOfBytes(0, kAnchorSeparator)
		  If hash < 0 Then Return ""
		  Return pageKey.MiddleBytes(hash + 1)
		End Function
	#tag EndMethod

	#tag Enum, Name = eMatch, Type = Integer, Flags = &h0
		All
		  Any
		  Exact
	#tag EndEnum

	#tag Property, Flags = &h0
		Version As VNSHelpVersion
	#tag EndProperty

	#tag Property, Flags = &h0
		DeprecatedLast As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mAssetFolder As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLinkTargets() As String
	#tag EndProperty

	#tag Constant, Name = kAnchorSeparator, Type = String, Dynamic = False, Default = \"#", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kLinkScheme, Type = String, Dynamic = False, Default = \"bxh:", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kDeadLinkMarker, Type = String, Dynamic = False, Default = \"x", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kExternalPrefix, Type = String, Dynamic = False, Default = \"url:", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kExternalScheme, Type = String, Dynamic = False, Default = \"bxhweb:", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kSlash, Type = String, Dynamic = False, Default = \"/", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kAmpersand, Type = String, Dynamic = False, Default = \"&", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kEntityAmpersand, Type = String, Dynamic = False, Default = \"&amp;", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kAnchorTagOpen, Type = String, Dynamic = False, Default = \"<a", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHrefAttribute, Type = String, Dynamic = False, Default = \"href\x3D\"", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kQuoteChar, Type = String, Dynamic = False, Default = \"\"", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTagNameEnders, Type = String, Dynamic = False, Default = \" \t\n\r/>", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColon, Type = String, Dynamic = False, Default = \":", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kGroupPrefix, Type = String, Dynamic = False, Default = \"dir:", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kPagePrefix, Type = String, Dynamic = False, Default = \"doc:", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kPreferencesFolderName, Type = String, Dynamic = False, Default = \"Better Xojo Help", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kAssetsFolderName, Type = String, Dynamic = False, Default = \"assets", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTagOpen, Type = String, Dynamic = False, Default = \"<", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTagClose, Type = String, Dynamic = False, Default = \">", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSpace, Type = String, Dynamic = False, Default = \" ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kRankScale, Type = Integer, Dynamic = False, Default = \"100000", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kDeprecatedPenalty, Type = Integer, Dynamic = False, Default = \"1000000000000", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMaximumResults, Type = Integer, Dynamic = False, Default = \"200", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kMaximumRanked, Type = Integer, Dynamic = False, Default = \"150", Scope = Protected
	#tag EndConstant

	#tag Note, Name = Description
		The seam that hides the documentation format from the rest of the app.

		Xojo has shipped its offline documentation in three incompatible formats. A
		subclass per supported format implements this contract, so the window never
		branches on which era it is showing. Adding a format means adding a subclass
		and one case in ForVersion — nothing else changes.

		Page keys are opaque strings carrying a "doc:" or "dir:" prefix and an
		optional "#anchor". Only the doc set that issued a key interprets it.

		This base class is abstract in intent, not in language: every method returns
		an empty result so a partially implemented subclass degrades to a blank
		panel rather than an exception.
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.11.0
		Last change: 2026-07-25 18:41

		------------------------------------------------------------
		0.11.0 — 2026-07-25

		18:41  [NEW] DeprecatedLast property gates the sort penalty. A property set from outside rather than a read of VNSHelpPreferences, so Engine stays free of UI.

		------------------------------------------------------------
		0.10.1 — 2026-07-25

		18:36  [NEW] SortedByRank puts every deprecated hit after every live one, whatever its occurrence count. A deprecated page repeats the name of its replacement, so it scores highest on exactly the searches where it is least wanted — "list add" on 2026r1.2 put six ListBox (deprecated) members, at 825 occurrences, above every live one.

		------------------------------------------------------------
		0.9.0 — 2026-07-25

		18:20  [BREAKING] Search takes a VNSHelpDocSet.eMatch. The enum is All / Any / Exact, and SearchTerms turns a query into the terms a provider should match — Exact keeps the whole query as one term, so a single-word query behaves identically in all three modes.
		18:20  [NEW] MatchesTerms and TotalOccurrences, shared by both providers: Any needs one term present, All and Exact need every one, and a page's rank sums the occurrences of each term so a page carrying both halves of a two-word query outranks one carrying either half twice.

		------------------------------------------------------------
		0.8.3 — 2026-07-25

		17:04  [NEW] An external link now carries its own scheme, bxhweb:<n>, rather than being a bxh:<n> whose stored target happens to begin "url:". The reason is the stylesheet: CSS can select on an href, so a[href^="bxhweb:"]::after marks exactly the right anchors with no class attribute and no second pass over the markup. The stored target keeps its marker too, so the table stays self-describing.

		------------------------------------------------------------
		0.8.0 — 2026-07-25

		16:34  [NEW] WebURL: the address of a page on Xojo's own site, defaulting to "" — which is the honest answer for the legacy era, whose addresses are no longer served, so the base implementation stands for it and the window's globe stays disabled.

		------------------------------------------------------------
		0.7.0 — 2026-07-25

		15:04  [NEW] RewriteAnchorHrefs: one walk over the fragment that hands every <a> href to LinkHrefFor, the single method each provider overrides. Only anchors are touched — a <link rel="icon"> carries an href too, and every 2015 blob references /favicon.ico in its head, so rewriting it would turn a page load into a navigation event.
		15:04  [NEW] LinkHref / LinkTargets: link targets travel to the window as positions in a numbered table, because a page key contains "#" and would need percent-encoding to survive in a URL. Same mechanism the generated overview pages already used.
		15:04  [NEW] ExternalLinkHref: an external address goes through that same table with a "url:" marker, so the window's CancelLoad acts only on our own scheme and never has to guess whether an incoming http URL is a click or a resource the page is fetching by itself.
		15:04  [NEW] DeadLinkHref returns "bxh:x", not "bxh:-1": a number has to be parsed back and a parse that failed would land on index 0, which is a real link.
		15:04  [REFACTOR] HasScheme moved here from VNSHelpSphinxDocSet — both providers need it and it knows nothing about either format.
		15:04  [BREAKING] ResolveLink removed. It could not work: since P2 the page is rendered as assets/<release>/page.html, so a relative href resolves against the asset folder and the real target is already gone by the time CancelLoad fires.

		------------------------------------------------------------
		0.2.0 — 2026-07-24

		23:18  [NEW] Initial creation — the six-method contract plus the ForVersion factory.
	#tag EndNote

	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass

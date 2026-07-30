#tag Class
Protected Class VNSHelpSphinxDocSet
Inherits VNSHelpDocSet
	#tag Method, Flags = &h0
		Sub Constructor(theVersion As VNSHelpVersion)
		  Super.Constructor(theVersion)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RootTopics() As VNSHelpTopic()
		  EnsureCatalog
		  Return TopicsUnder("")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ChildTopics(parentKey As String) As VNSHelpTopic()
		  EnsureCatalog

		  If Not parentKey.BeginsWith(kGroupPrefix) Then
		    Var none() As VNSHelpTopic
		    Return none
		  End If

		  Return TopicsUnder(parentKey.MiddleBytes(kGroupPrefix.Bytes))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function PageHTML(pageKey As String, ByRef baseFile As FolderItem) As String
		  // The article body only. The surrounding Read-the-Docs chrome carries a
		  // navigation sidebar that would duplicate our own tree, and references
		  // scripts on external CDNs that would stall an offline machine.
		  baseFile = Nil

		  Var containingFolder As FolderItem
		  Var pageFile As FolderItem = FileForKey(pageKey, containingFolder)
		  If pageFile = Nil Then Return ""

		  // Images are served from a folder this app owns, not from the
		  // documentation tree.
		  //
		  // LoadPage(source, base) does not simply resolve against the base: Xojo
		  // writes the HTML out as a file named index.html and loads that — the web
		  // inspector reports the stylesheet as coming from "index.html:33". So a
		  // page's relative references resolve from wherever that file was written,
		  // which is why correcting the paths twice changed nothing.
		  //
		  // DesktopCodeMirror in VNS Structure Editor v2 is the one arrangement in
		  // this codebase known to work, and it sidesteps the question entirely:
		  // make a folder, put the assets in it, pass that folder. Xojo's index.html
		  // then lands beside the assets and plain filenames resolve. Each image is
		  // copied on first use.

		  // Link targets are numbered per rendered page, so the table starts empty, and
		  // the catalog has to be loaded before a link can be checked against it.
		  EnsureCatalog
		  ResetLinkTargets

		  Var folderPath As String = FolderPathOf(DocNameFromKey(pageKey))
		  Var body As String = ArticleBody(ReadTextFile(pageFile))
		  body = RewriteImageSources(body, folderPath)
		  body = RewriteAnchorHrefs(body, folderPath)

		  baseFile = RenderFolder
		  Return body
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TitleForKey(pageKey As String) As String
		  EnsureCatalog

		  Var docName As String = DocNameFromKey(pageKey)
		  If docName = "" Then Return ""

		  Var index As Integer = IndexForDocName(docName)
		  If index < 0 Then Return ""

		  Return DisplayTitle(mTitles(index), LastSegment(docName))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function WebURL(pageKey As String) As String
		  // Taken from the page's own <link rel="canonical">, not built from the docname.
		  //
		  // They agree for all but two to five pages per release, and where they differ
		  // the tag is the correct one: it entity-escapes an apostrophe, and in 2025r1 it
		  // lowercases a folder (macOS -> macos), both of which a constructed address gets
		  // wrong. The tag is present on 99.8%-100% of pages in all 15 releases.
		  //
		  // It lives in the head, which PageHTML throws away, so it is read here
		  // instead. Re-reading the whole file costs nothing worth avoiding: this runs
		  // on a button press, not on every page render.
		  Var containingFolder As FolderItem
		  Var pageFile As FolderItem = FileForKey(pageKey, containingFolder)
		  If pageFile = Nil Then Return ""

		  Var head As String = ReadTextFile(pageFile)
		  Var marker As Integer = head.IndexOfBytes(0, kCanonicalMarker)
		  If marker < 0 Then Return ""

		  Var valueStart As Integer = head.IndexOfBytes(marker, kHrefAttributeSphinx)
		  If valueStart < 0 Then Return ""
		  valueStart = valueStart + kHrefAttributeSphinx.Bytes

		  Var valueEnd As Integer = head.IndexOfBytes(valueStart, kQuote)
		  If valueEnd < 0 Then Return ""

		  // The href is HTML, so &#39; and friends have to come back out before the
		  // address is handed to the browser.
		  Var url As String = DecodeEntities(head.MiddleBytes(valueStart, valueEnd - valueStart))
		  If Not HasScheme(url) Then Return ""

		  // The anchor is ours to add: the canonical tag names the page only.
		  Return url + AnchorSuffix(pageKey)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function AnchorSuffix(pageKey As String) As String
		  Var anchor As String = AnchorFromKey(pageKey)
		  If anchor = "" Then Return ""

		  Return kAnchorSeparator + anchor
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StyleSheet() As String
		  // The release's own pygments stylesheet, so code samples keep the colours
		  // that release shipped. Read once and remembered.
		  If mStyleSheetLoaded Then Return mStyleSheet
		  mStyleSheetLoaded = True

		  If Version = Nil Or Version.DocRoot = Nil Then Return ""

		  Var staticFolder As FolderItem = VNSHelpVersion.ResolvePath(Version.DocRoot, kStaticFolderName)
		  If staticFolder = Nil Then Return ""

		  mStyleSheet = ReadTextFile(staticFolder.Child(kPygmentsFileName))
		  Return mStyleSheet
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function PageCount() As Integer
		  EnsureCatalog
		  Return mDocNames.Count
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Search(query As String, mode As VNSHelpDocSet.eMatch) As VNSHelpSearchHit()
		  // Matches page titles and docnames, then ranks by how many times the terms
		  // actually appear in each matching page.
		  //
		  // Body text is not searched here. The shipped term index cannot support it
		  // across releases: 2026r1.2 lists 30 603 terms including "listbox", while
		  // 2022r1.1 lists 8 708 whose keys are numeric strings, with nothing beginning
		  // "list" at all. Real full-text search needs an index of our own — see P9.
		  //
		  // Two passes. The first collects every match without touching the disk; the
		  // second reads pages to count occurrences, and only for the most promising
		  // candidates. Ordering the candidates before spending that budget matters:
		  // spending it in docname order would leave which results get a real count down
		  // to where they happen to sit in the alphabet.
		  Var hits() As VNSHelpSearchHit
		  EnsureCatalog

		  Var terms() As String = SearchTerms(query, mode)
		  If terms.LastIndex < 0 Then Return hits

		  // The first term drives the ranking bands below. With Exact, or with a
		  // single-word query, that is the whole query — so the order is exactly what it
		  // was before there were modes.
		  Var leading As String = terms(0)

		  Var candidates() As Integer
		  Var order() As Integer

		  For i As Integer = 0 To mDocNames.LastIndex
		    If IsHidden(mDocNames(i)) Then Continue

		    Var title As String = DisplayTitle(mTitles(i), LastSegment(mDocNames(i)))
		    Var loweredTitle As String = title.Lowercase

		    // Title and path are matched as one haystack, so "desktop listbox" finds a
		    // page whose title carries one word and whose path carries the other.
		    If Not MatchesTerms(loweredTitle + kSpace + mDocNames(i), terms, mode) Then Continue

		    Var titleHit As Integer = loweredTitle.IndexOfBytes(0, leading)

		    // Lower sorts first: an exact title beats a title that starts with the term,
		    // which beats one that merely contains it, which beats a match in the path
		    // alone. Shorter titles win inside a band.
		    Var preference As Integer = kPreferencePathOnly
		    If loweredTitle = leading Then
		      preference = kPreferenceExact
		    ElseIf titleHit = 0 Then
		      preference = kPreferencePrefix
		    ElseIf titleHit > 0 Then
		      preference = kPreferenceContains
		    End If

		    candidates.Add(i)
		    order.Add(preference * kPreferenceScale + Min(title.Length, kPreferenceScale - 1))
		  Next

		  // No early return when nothing matched a page title: the member pass below is
		  // the only thing that can answer a query like "tcp listen", where neither the
		  // class page nor its docname carries both words but EasyTCPSocket.Listen does.
		  Var ranked As Integer = 0

		  // Before any hit is built, not merely before the member pass: page hits carry
		  // a platform label too, and the labels are filled in by this scan.
		  EnsureMemberIndex

		  If candidates.LastIndex >= 0 Then
		    SortCandidates(order, candidates)

		    For Each index As Integer In candidates
		      If hits.Count >= kMaximumResults Then Exit

		      Var occurrences As Integer = 1
		      If ranked < kMaximumRanked Then
		        ranked = ranked + 1
		        occurrences = TotalOccurrences(ArticleForDocName(mDocNames(index)), terms)
		        If occurrences = 0 Then occurrences = 1
		      End If

		      Var pageHit As New VNSHelpSearchHit(kPagePrefix + mDocNames(index), _
		        DisplayTitle(mTitles(index), LastSegment(mDocNames(index))), _
		        FolderPathOf(mDocNames(index)), occurrences, IsDeprecated(mDocNames(index)))
		      pageHit.Platforms = PlatformsForDoc(index)
		      hits.Add(pageHit)
		    Next
		  End If

		  // Members second. In this era only a deprecated member gets a page of its own;
		  // a live one is a section inside its class page, so without this pass
		  // DesktopListBox.AddRow cannot be found at all.
		  AddMemberMatches(hits, terms, mode, ranked)

		  Return SortedByRank(hits)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SortCandidates(order() As Integer, candidates() As Integer)
		  // SortWith needs unique base values, so the position breaks ties.
		  For i As Integer = 0 To order.LastIndex
		    order(i) = order(i) * kPreferenceScale + Min(i, kPreferenceScale - 1)
		  Next

		  order.SortWith(candidates)
		End Sub
	#tag EndMethod


	#tag Method, Flags = &h21
		Private Function ArticleForDocName(docName As String) As String
		  // The page body without the image handling PageHTML performs: searching
		  // must not copy assets for pages the user never opens.
		  Var containingFolder As FolderItem
		  Var pageFile As FolderItem = FileForKey(kPagePrefix + docName, containingFolder)
		  If pageFile = Nil Then Return ""

		  Return ArticleBody(ReadTextFile(pageFile))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OverviewPageKey(groupKey As String) As String
		  // A Sphinx folder documents itself through an index page, so selecting a
		  // group in the tree can show something useful.
		  EnsureCatalog

		  If Not groupKey.BeginsWith(kGroupPrefix) Then Return ""

		  Var groupPath As String = groupKey.MiddleBytes(kGroupPrefix.Bytes)
		  Var indexDocName As String = groupPath + kDocNameSeparator + kIndexDocName
		  If IndexForDocName(indexDocName) < 0 Then Return ""

		  Return kPagePrefix + indexDocName
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddMemberMatches(hits() As VNSHelpSearchHit, terms() As String, mode As VNSHelpDocSet.eMatch, ByRef ranked As Integer)
		  // A member is ranked by the occurrences on the page that documents it, which is
		  // the same text it lives in. The count is remembered per page, so a class whose
		  // members all match costs one read rather than one per member.
		  EnsureMemberIndex

		  Var pageRanks As New Dictionary

		  For m As Integer = 0 To mMemberTitles.LastIndex
		    If hits.Count >= kMaximumResults Then Return
		    If Not MatchesTerms(mMemberTitles(m), terms, mode) Then Continue

		    Var owner As String = mMemberOwners(m)
		    Var occurrences As Integer = 1

		    If pageRanks.HasKey(owner) Then
		      occurrences = pageRanks.Value(owner).IntegerValue
		    ElseIf ranked < kMaximumRanked Then
		      ranked = ranked + 1
		      occurrences = TotalOccurrences(ArticleForDocName(owner), terms)
		      If occurrences = 0 Then occurrences = 1
		      pageRanks.Value(owner) = occurrences
		    End If

		    // A member is a section of its class page, so it is available exactly where
		    // that class is. Labelling it from the owner is what lets unticking Desktop
		    // remove DesktopListBox.AddRow and not merely DesktopListBox.
		    Var memberHit As New VNSHelpSearchHit(mMemberKeys(m), mMemberTitles(m), owner, _
		      occurrences, IsDeprecated(owner))
		    memberHit.Platforms = PlatformsForDoc(IndexForDocName(owner))
		    hits.Add(memberHit)
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub EnsureMemberIndex()
		  // Every member of every class, harvested once from the pages themselves.
		  //
		  // The shipped index cannot give this: `alltitles` holds 4 576 section headings
		  // and DesktopListBox.AddAllRows is not among them. But each class page links its
		  // own sections, and that markup is stable across the era. Measured on 2026r1.2:
		  // 691 pages carrying 15 502 members, from 16 057 candidate links.
		  //
		  // Read on the first search rather than at startup: a release that is only
		  // browsed never pays for it.
		  If mMemberIndexLoaded Then Return
		  mMemberIndexLoaded = True

		  EnsureCatalog
		  If Version = Nil Or Version.DocRoot = Nil Then Return

		  For i As Integer = 0 To mDocNames.LastIndex
		    If IsHidden(mDocNames(i)) Then Continue

		    Var containingFolder As FolderItem
		    Var pageFile As FolderItem = FileForKey(kPagePrefix + mDocNames(i), containingFolder)
		    If pageFile = Nil Then Continue

		    Var html As String = ReadTextFile(pageFile)
		    HarvestMembers(i, html)
		    HarvestPlatforms(i, html)
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HarvestPlatforms(docIndex As Integer, html As String)
		  // Read the Compatibility table at the foot of a class page:
		  //
		  //   Project Types      Mobile
		  //   Operating Systems  Android
		  //
		  // Rides along with HarvestMembers on the same already-read page source
		  // rather than opening the file again — the scan is free at this point, and a
		  // second pass would double the I/O of the only expensive thing this class does.
		  //
		  // 786 of 2123 pages on 2026r1.2 carry the table. The rest keep
		  // kPlatformNone, which matches every filter — see MatchesPlatform.
		  If docIndex < 0 Or docIndex > mPlatforms.LastIndex Then Return

		  Var typesAt As Integer = html.IndexOf(kCompatTypesLabel)
		  If typesAt < 0 Then Return

		  Var systemsAt As Integer = html.IndexOf(typesAt, kCompatSystemsLabel)
		  If systemsAt < 0 Then Return

		  Var types As String = PlainText(html.Middle(typesAt + kCompatTypesLabel.Length, _
		    systemsAt - typesAt - kCompatTypesLabel.Length))

		  // The systems value runs to the end of its cell. Stopping at the row end
		  // keeps the "See also" list that follows the table out of the value.
		  Var endAt As Integer = html.IndexOf(systemsAt, kCompatRowEnd)
		  If endAt < 0 Or endAt - systemsAt > kCompatMaxCell Then endAt = Min(systemsAt + kCompatMaxCell, html.Length)

		  Var systems As String = PlainText(html.Middle(systemsAt + kCompatSystemsLabel.Length, _
		    endAt - systemsAt - kCompatSystemsLabel.Length))

		  mPlatforms(docIndex) = PlatformsFromCompatibility(types, systems)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PlatformsForDoc(docIndex As Integer) As Integer
		  // The scan runs inside EnsureMemberIndex, so a caller must have triggered
		  // that first. Search does, before it builds any hit.
		  If docIndex < 0 Or docIndex > mPlatforms.LastIndex Then Return VNSHelpDocSet.kPlatformNone

		  Return mPlatforms(docIndex)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PlainText(fragment As String) As String
		  // Strip tags and collapse whitespace, so a table cell spread over several
		  // lines of markup compares as the words it shows.
		  Var out As String
		  Var inTag As Boolean = False

		  For i As Integer = 0 To fragment.Length - 1
		    Var ch As String = fragment.Middle(i, 1)
		    If ch = "<" Then
		      inTag = True
		    ElseIf ch = ">" Then
		      inTag = False
		      out = out + " "
		    ElseIf Not inTag Then
		      out = out + ch
		    End If
		  Next

		  Return out.ReplaceAll(EndOfLine, " ").ReplaceAll(Chr(9), " ").Trim
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HarvestMembers(docIndex As Integer, html As String)
		  // The member table on a class page links each section as
		  //   <a class="reference internal" href="#desktoplistbox-addallrows">
		  //     <span class="std std-ref">AddAllRows</span></a>
		  //
		  // Two tests separate a member from a prose heading, and both are needed: a
		  // member anchors as "<page>-<member>" where a prose section anchors as the whole
		  // path (api-user-interface-…), and a member's name has no spaces where a heading
		  // reads like a sentence. Together they keep 15 502 of 16 057 links, and what they
		  // drop is "FINE PRINT", "GETTING STARTED" and the like.
		  Var docName As String = mDocNames(docIndex)
		  Var prefix As String = LastSegment(docName) + kMemberAnchorJoin
		  Var owner As String = DisplayTitle(mTitles(docIndex), LastSegment(docName))
		  Var seen As New Dictionary
		  Var position As Integer = 0

		  While True
		    Var start As Integer = html.IndexOfBytes(position, kMemberLinkOpen)
		    If start < 0 Then Return

		    Var anchorStart As Integer = start + kMemberLinkOpen.Bytes
		    Var anchorEnd As Integer = html.IndexOfBytes(anchorStart, kQuote)
		    If anchorEnd < 0 Then Return
		    position = anchorEnd

		    Var anchor As String = html.MiddleBytes(anchorStart, anchorEnd - anchorStart)
		    If Not anchor.BeginsWith(prefix) Then Continue
		    If html.MiddleBytes(anchorEnd, kMemberLinkMiddle.Bytes) <> kMemberLinkMiddle Then Continue

		    Var nameStart As Integer = anchorEnd + kMemberLinkMiddle.Bytes
		    Var nameEnd As Integer = html.IndexOfBytes(nameStart, kLessThan)
		    If nameEnd < 0 Then Return
		    position = nameEnd

		    Var name As String = html.MiddleBytes(nameStart, nameEnd - nameStart)
		    If name = "" Or name.IndexOfBytes(0, kSpace) >= 0 Then Continue
		    If seen.HasKey(anchor) Then Continue
		    seen.Value(anchor) = True

		    mMemberTitles.Add(owner + kMemberJoin + DecodeEntities(name))
		    mMemberKeys.Add(kPagePrefix + docName + kAnchorSeparator + anchor)
		    mMemberOwners.Add(docName)
		  Wend
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IsDeprecated(docName As String) As Boolean
		  // Xojo files its deprecated pages under api/deprecated/, both the classes
		  // themselves and the deprecated_class_members below them, so the path is the
		  // whole test. Their titles also say so, but the path is what cannot be reworded.
		  Return docName.IndexOfBytes(0, kDeprecatedFolder) >= 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub EnsureCatalog()
		  // Read the page list once per doc set.
		  //
		  // searchindex.js runs to 3.4 MB but the two arrays needed here total
		  // about 130 KB, and in releases before 2025r2.1 the document is a
		  // JavaScript object literal that ParseJSON would reject outright. Both
		  // problems are handled by slicing the arrays out and parsing only those.
		  If mCatalogLoaded Then Return
		  mCatalogLoaded = True

		  If Version = Nil Or Version.DocFile = Nil Then Return

		  Var raw As String = ReadTextFile(Version.DocFile)
		  If raw = "" Then Return

		  mDocNames = VNSHelpJSONSlicer.StringArray(VNSHelpJSONSlicer.ExtractArray(raw, kKeyDocNames))
		  mTitles = VNSHelpJSONSlicer.StringArray(VNSHelpJSONSlicer.ExtractArray(raw, kKeyTitles))

		  // The two arrays are positional: entry N of titles names entry N of
		  // docnames. If they ever disagree the pairing is meaningless, so drop
		  // the catalog rather than mislabel every page.
		  If mDocNames.LastIndex <> mTitles.LastIndex Then
		    Var noDocs() As String
		    Var noTitles() As String
		    mDocNames = noDocs
		    mTitles = noTitles
		    Return
		  End If

		  // Parallel to mDocNames, and every entry starts at kPlatformNone so a page
		  // never scanned — or one carrying no Compatibility table — matches every
		  // filter rather than none.
		  mPlatforms.ResizeTo(mDocNames.LastIndex)
		  For i As Integer = 0 To mPlatforms.LastIndex
		    mPlatforms(i) = VNSHelpDocSet.kPlatformNone
		  Next

		  mIndexByDocName = New Dictionary
		  For i As Integer = 0 To mDocNames.LastIndex
		    mIndexByDocName.Value(mDocNames(i)) = i
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function TopicsUnder(prefix As String) As VNSHelpTopic()
		  // One level of the tree: the immediate subfolders of `prefix` as groups,
		  // then the pages sitting directly in it. Groups come first so the tree
		  // reads as structure before content.
		  Var groups() As VNSHelpTopic
		  Var pages() As VNSHelpTopic
		  Var seenGroups As New Dictionary
		  Var groupOrder() As String
		  Var groupMatched As New Dictionary

		  // Filtering costs a full page scan, so it is only paid for when it can
		  // change something. All boxes ticked is the default and the common case, and
		  // it excludes nothing, so the tree is built exactly as before and startup
		  // stays free.
		  Var filtering As Boolean = PlatformFilter <> VNSHelpDocSet.kPlatformAll
		  If filtering Then EnsureMemberIndex

		  Var scoped As String = prefix
		  If scoped <> "" Then scoped = scoped + kDocNameSeparator
		  Var scopedLength As Integer = scoped.Bytes

		  For i As Integer = 0 To mDocNames.LastIndex
		    Var docName As String = mDocNames(i)
		    If IsHidden(docName) Then Continue
		    If scopedLength > 0 And docName.LeftBytes(scopedLength) <> scoped Then Continue

		    Var remainder As String = docName.MiddleBytes(scopedLength)
		    If remainder = "" Then Continue

		    Var keep As Boolean = Not filtering Or MatchesPlatform(mPlatforms(i))

		    // An index page describes its folder and carries no Compatibility table of
		    // its own, so it is unlabelled and matches everything. Left to count, it
		    // would keep every group alive and the tree would never narrow at all —
		    // measured: unticking everything but Desktop still showed all seven
		    // subgroups of api/user_interface. It is the folder's own description, not
		    // content, so it never justifies its group.
		    Var isIndex As Boolean = remainder = kIndexDocName Or remainder.EndsWith(kDocNameSeparator + kIndexDocName)

		    Var separator As Integer = remainder.IndexOfBytes(0, kDocNameSeparator)
		    If separator < 0 Then
		      // An index page describes its own folder, so it is shown as the
		      // group's title rather than as a sibling entry.
		      If remainder = kIndexDocName Then Continue
		      If Not keep Then Continue
		      pages.Add(New VNSHelpTopic(kPagePrefix + docName, DisplayTitle(mTitles(i), remainder), _
		        VNSHelpTopic.eKind.Page, False))
		      Continue
		    End If

		    // A group is kept when anything below it survives, however deep. The
		    // decision cannot be made when the segment is first seen — the page that
		    // justifies it may be several entries further down the list — so segments
		    // are recorded in order and marked as their descendants go by.
		    Var segment As String = remainder.LeftBytes(separator)
		    If Not seenGroups.HasKey(segment) Then
		      seenGroups.Value(segment) = True
		      groupOrder.Add(segment)
		      groupMatched.Value(segment) = False
		    End If
		    If keep And Not isIndex Then groupMatched.Value(segment) = True
		  Next

		  For Each segment As String In groupOrder
		    If filtering And Not groupMatched.Value(segment).BooleanValue Then Continue

		    Var groupPath As String = scoped + segment
		    groups.Add(New VNSHelpTopic(kGroupPrefix + groupPath, GroupTitle(groupPath, segment), _
		      VNSHelpTopic.eKind.Group, True))
		  Next

		  For Each page As VNSHelpTopic In pages
		    groups.Add(page)
		  Next

		  Return groups
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GroupTitle(groupPath As String, segment As String) As String
		  // Prefer the title of the folder's own index page — that is where Sphinx
		  // records the human name ("User Interface" rather than "user_interface").
		  Var index As Integer = IndexForDocName(groupPath + kDocNameSeparator + kIndexDocName)
		  If index >= 0 Then Return DisplayTitle(mTitles(index), segment)

		  Return Prettify(segment)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DisplayTitle(rawTitle As String, fallbackSegment As String) As String
		  // Sphinx records a page with no heading as the literal "&lt;no title&gt;",
		  // HTML-escaped, which would otherwise appear verbatim in the tree. Titles
		  // are stored escaped generally, so they are decoded for display here.
		  //
		  // Tags are stripped **before** decoding, and the order is not arbitrary:
		  // "&lt;no title&gt;" carries no real tags, so it survives stripping and is
		  // still recognised after decoding. Strip afterwards and it would decode to
		  // "<no title>", be stripped to nothing, and lose its fallback.
		  //
		  // 24 of 2123 titles on 2026r1.2 carry markup — <cite> and
		  // <span class="xref …"> — and the tree showed "<cite>Graphics</cite>"
		  // verbatim.
		  Var decoded As String = DecodeEntities(StripTags(rawTitle)).Trim
		  If decoded = "" Or decoded = kNoTitleText Then Return Prettify(fallbackSegment)

		  Return decoded
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function StripTags(value As String) As String
		  // Tags removed, nothing put in their place: a title like
		  // "value As <span …>String</span>, Size As …" has to close up rather than
		  // gain spaces before its commas. That is why this is not PlainText, which
		  // inserts a space per tag on purpose so a table cell spread over several
		  // lines of markup reads as words.
		  //
		  // Most titles have no markup at all, so the scan is skipped for them.
		  If value.IndexOf(kTagOpen) < 0 Then Return value

		  Var out() As String
		  Var inTag As Boolean = False

		  For i As Integer = 0 To value.Length - 1
		    Var ch As String = value.Middle(i, 1)
		    If ch = kTagOpen Then
		      inTag = True
		    ElseIf ch = kTagClose Then
		      inTag = False
		    ElseIf Not inTag Then
		      out.Add(ch)
		    End If
		  Next

		  Return String.FromArray(out, "")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DecodeEntities(value As String) As String
		  // The handful of entities Sphinx emits in titles. The ampersand is
		  // decoded last so a literal "&amp;lt;" does not turn into "<".
		  Var result As String = value
		  result = result.ReplaceAll(kEntityLessThan, kLessThan)
		  result = result.ReplaceAll(kEntityGreaterThan, kGreaterThan)
		  result = result.ReplaceAll(kEntityQuote, kQuote)
		  result = result.ReplaceAll(kEntityApostrophe, kApostrophe)
		  result = result.ReplaceAll(kEntityAmpersand, kAmpersand)

		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Prettify(segment As String) As String
		  // Fallback label for a folder with no index page.
		  Var words As String = segment.ReplaceAll(kUnderscore, kSpace)
		  If words = "" Then Return words

		  Return words.LeftBytes(1).Uppercase + words.MiddleBytes(1)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function LastSegment(docName As String) As String
		  Var parts() As String = docName.Split(kDocNameSeparator)
		  If parts.LastIndex < 0 Then Return docName

		  Return parts(parts.LastIndex)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IsHidden(docName As String) As Boolean
		  // Scaffolding pages that are part of the site rather than the manual.
		  If docName.BeginsWith(kUnderscore) Then Return True

		  For Each hidden As String In kHiddenDocNames.Split(kListSeparator)
		    If docName = hidden Then Return True
		  Next

		  Return False
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IndexForDocName(docName As String) As Integer
		  If mIndexByDocName = Nil Then Return -1
		  If Not mIndexByDocName.HasKey(docName) Then Return -1

		  Return mIndexByDocName.Value(docName).IntegerValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DocNameFromKey(pageKey As String) As String
		  // "doc:api/.../desktoplistbox#properties" -> "api/.../desktoplistbox"
		  If Not pageKey.BeginsWith(kPagePrefix) Then Return ""

		  Var withoutPrefix As String = pageKey.MiddleBytes(kPagePrefix.Bytes)
		  Var hash As Integer = withoutPrefix.IndexOfBytes(0, kAnchorSeparator)
		  If hash < 0 Then Return withoutPrefix

		  Return withoutPrefix.LeftBytes(hash)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FileForKey(pageKey As String, ByRef containingFolder As FolderItem) As FolderItem
		  // A docname is a slash-separated path relative to the documentation root,
		  // without the .html extension. The containing folder travels back out so
		  // the viewer can resolve the page's relative image references.
		  containingFolder = Nil

		  Var docName As String = DocNameFromKey(pageKey)
		  If docName = "" Or Version = Nil Or Version.DocRoot = Nil Then Return Nil

		  Var parts() As String = docName.Split(kDocNameSeparator)
		  If parts.LastIndex < 0 Then Return Nil

		  Var fileName As String = parts(parts.LastIndex) + kPageExtension
		  parts.RemoveAt(parts.LastIndex)

		  Var folder As FolderItem = Version.DocRoot
		  For Each part As String In parts
		    If part = "" Then Continue
		    folder = folder.Child(part)
		    If folder = Nil Or Not folder.Exists Then Return Nil
		  Next

		  Var pageFile As FolderItem = folder.Child(fileName)
		  If pageFile = Nil Or Not pageFile.Exists Then Return Nil

		  containingFolder = folder
		  Return pageFile
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function LinkHrefFor(context As String, reference As String) As String
		  // A Sphinx link is a path relative to the folder the page sits in, ending
		  // ".html", optionally with an anchor. The context is that folder.
		  //
		  // An in-page anchor is left alone: the page is written out as a real file, so
		  // the viewer scrolls it without help.
		  If reference = "" Then Return reference
		  If reference.BeginsWith(kAnchorSeparator) Then Return reference
		  If HasScheme(reference) Then Return ExternalLinkHref(reference)

		  // A relative reference that is not a page is an asset: a few tutorial pages
		  // link to the full-size version of a screenshot they also show inline. Treat it
		  // exactly as an <img> reference so it is copied beside the rendered page.
		  If reference.IndexOfBytes(0, kPageExtension) < 0 Then
		    Return LocalImageName(context, reference)
		  End If

		  Var target As String = reference
		  Var anchor As String = ""
		  Var hash As Integer = target.IndexOfBytes(0, kAnchorSeparator)
		  If hash >= 0 Then
		    anchor = target.MiddleBytes(hash)
		    target = target.LeftBytes(hash)
		  End If

		  // Docnames are unescaped while references are not — a few pages have an
		  // apostrophe or a parenthesis written as a percent escape.
		  Var docName As String = DecodePercent(RootRelativePath(context, target))
		  If docName.EndsWith(kPageExtension) Then
		    docName = docName.LeftBytes(docName.Bytes - kPageExtension.Bytes)
		  End If

		  // A page this release does not ship. Xojo's own documentation links to plenty:
		  // 2023r1.1 points at 91 pages it had already archived. Measured over all 15
		  // releases, 990 822 page links resolve and 310 do not.
		  If IndexForDocName(docName) < 0 Then Return DeadLinkHref

		  Return LinkHref(kPagePrefix + docName + anchor)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function RewriteImageSources(body As String, pageFolderPath As String) As String
		  // Copy each referenced image next to where Xojo will write the page, and
		  // replace the reference with the bare filename.
		  //
		  // Pieces are collected and joined rather than concatenated in place: a
		  // page can carry 41 images and the body runs to 400 KB.
		  Var pieces() As String
		  Var attributeBytes As Integer = kSourceAttribute.Bytes
		  Var position As Integer = 0

		  While True
		    Var found As Integer = body.IndexOfBytes(position, kSourceAttribute)
		    If found < 0 Then
		      pieces.Add(body.MiddleBytes(position))
		      Exit
		    End If

		    Var valueStart As Integer = found + attributeBytes
		    Var valueEnd As Integer = body.IndexOfBytes(valueStart, kQuote)
		    If valueEnd < 0 Then
		      pieces.Add(body.MiddleBytes(position))
		      Exit
		    End If

		    pieces.Add(body.MiddleBytes(position, valueStart - position))
		    pieces.Add(LocalImageName(pageFolderPath, _
		      body.MiddleBytes(valueStart, valueEnd - valueStart)))
		    position = valueEnd
		  Wend

		  Return String.FromArray(pieces, "")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function LocalImageName(pageFolderPath As String, reference As String) As String
		  // The reference rewritten to a filename in the asset folder, or left as
		  // it is when it cannot be resolved or copied — a missing image is better
		  // than a mangled page.
		  If reference = "" Then Return reference
		  If reference.BeginsWith(kAnchorSeparator) Then Return reference
		  If HasScheme(reference) Then Return reference

		  Var source As FolderItem = FileAtRootPath(RootRelativePath(pageFolderPath, reference))
		  If source = Nil Then Return reference

		  If Not CopyToAssets(source) Then Return reference

		  Return source.Name
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FileAtRootPath(rootRelative As String) As FolderItem
		  // Walk a root-relative path down from the documentation root. Names are
		  // percent-decoded first: a handful of images have an apostrophe in them,
		  // written as %27 in the markup.
		  If Version = Nil Or Version.DocRoot = Nil Or rootRelative = "" Then Return Nil

		  Var current As FolderItem = Version.DocRoot
		  For Each part As String In rootRelative.Split(kDocNameSeparator)
		    If part = "" Then Continue
		    current = current.Child(DecodePercent(part))
		    If current = Nil Or Not current.Exists Then Return Nil
		  Next

		  If current.IsFolder Then Return Nil
		  Return current
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function CopyToAssets(source As FolderItem) As Boolean
		  Var folder As FolderItem = RenderFolder
		  If folder = Nil Then Return False

		  If AssetAlreadyPresent(source.Name) Then Return True

		  Try
		    source.CopyTo(folder)
		  Catch e As IOException
		    Return False
		  End Try

		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DecodePercent(value As String) As String
		  If value.IndexOfBytes(0, kPercent) < 0 Then Return value

		  Var decoded As String
		  Var position As Integer = 0
		  Var length As Integer = value.Bytes

		  While position < length
		    Var char As String = value.MiddleBytes(position, 1)
		    If char = kPercent And position + 2 < length Then
		      Try
		        Var code As Integer = Integer.FromHex(value.MiddleBytes(position + 1, 2))
		        If code > 0 Then
		          decoded = decoded + Chr(code)
		          position = position + 3
		          Continue
		        End If
		      Catch e As RuntimeException
		        // Not a valid escape; fall through and keep the character as it is.
		      End Try
		    End If

		    decoded = decoded + char
		    position = position + 1
		  Wend

		  Return decoded
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FolderPathOf(docName As String) As String
		  // "api/user_interface/desktop/desktoplistbox" -> "api/user_interface/desktop"
		  Var parts() As String = docName.Split(kDocNameSeparator)
		  If parts.LastIndex < 1 Then Return ""

		  parts.RemoveAt(parts.LastIndex)
		  Return String.FromArray(parts, kDocNameSeparator)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function RootRelativePath(pageFolderPath As String, reference As String) As String
		  // Re-express a reference made from pageFolderPath as one made from the
		  // documentation root. Absolute references and in-page anchors are left
		  // exactly as they are.
		  If reference = "" Then Return reference
		  If reference.BeginsWith(kAnchorSeparator) Then Return reference
		  If reference.BeginsWith(kDocNameSeparator) Then Return reference
		  If HasScheme(reference) Then Return reference

		  Var segments() As String
		  If pageFolderPath <> "" Then segments = pageFolderPath.Split(kDocNameSeparator)

		  Var remainder As String = reference
		  While True
		    If remainder.BeginsWith(kParentPrefix) Then
		      If segments.LastIndex >= 0 Then segments.RemoveAt(segments.LastIndex)
		      remainder = remainder.MiddleBytes(kParentPrefix.Bytes)
		    ElseIf remainder.BeginsWith(kCurrentPrefix) Then
		      remainder = remainder.MiddleBytes(kCurrentPrefix.Bytes)
		    Else
		      Exit
		    End If
		  Wend

		  If segments.LastIndex < 0 Then Return remainder

		  Return String.FromArray(segments, kDocNameSeparator) + kDocNameSeparator + remainder
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ArticleBody(html As String) As String
		  // Everything between the articleBody div and the page footer. Both
		  // markers have held from 2022r1.1 through 2026r1.2.
		  //
		  // The markers deliberately contain no "=" or quote characters: those are
		  // structural inside a Xojo constant and would need escaping.
		  If html = "" Then Return ""

		  Var marker As Integer = html.IndexOfBytes(0, kArticleBodyMarker)
		  If marker < 0 Then Return html

		  Var tagEnd As Integer = html.IndexOfBytes(marker, kTagClose)
		  If tagEnd < 0 Then Return html

		  Var bodyStart As Integer = tagEnd + 1
		  Var bodyEnd As Integer = html.IndexOfBytes(bodyStart, kFooterMarker)
		  If bodyEnd < 0 Then bodyEnd = html.Bytes

		  Return html.MiddleBytes(bodyStart, bodyEnd - bodyStart)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ReadTextFile(file As FolderItem) As String
		  If file = Nil Or Not file.Exists Then Return ""

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

	#tag Property, Flags = &h21
		Private mDocNames() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTitles() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mIndexByDocName As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCatalogLoaded As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPlatforms() As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMemberIndexLoaded As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMemberTitles() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMemberKeys() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMemberOwners() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mStyleSheet As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mStyleSheetLoaded As Boolean
	#tag EndProperty


	#tag Constant, Name = kTagOpen, Type = String, Dynamic = False, Default = \"<", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCompatTypesLabel, Type = String, Dynamic = False, Default = \"Project Types", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCompatSystemsLabel, Type = String, Dynamic = False, Default = \"Operating Systems", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCompatRowEnd, Type = String, Dynamic = False, Default = \"</tr", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCompatMaxCell, Type = Integer, Dynamic = False, Default = \"300", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyDocNames, Type = String, Dynamic = False, Default = \"docnames", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyTitles, Type = String, Dynamic = False, Default = \"titles", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kDocNameSeparator, Type = String, Dynamic = False, Default = \"/", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kIndexDocName, Type = String, Dynamic = False, Default = \"index", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPageExtension, Type = String, Dynamic = False, Default = \".html", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMemberLinkOpen, Type = String, Dynamic = False, Default = \"<a class\x3D\"reference internal\" href\x3D\"#", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMemberLinkMiddle, Type = String, Dynamic = False, Default = \"\"><span class\x3D\"std std-ref\">", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMemberAnchorJoin, Type = String, Dynamic = False, Default = \"-", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMemberJoin, Type = String, Dynamic = False, Default = \".", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kDeprecatedFolder, Type = String, Dynamic = False, Default = \"api/deprecated/", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPreferenceExact, Type = Integer, Dynamic = False, Default = \"0", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPreferencePrefix, Type = Integer, Dynamic = False, Default = \"1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPreferenceContains, Type = Integer, Dynamic = False, Default = \"2", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPreferencePathOnly, Type = Integer, Dynamic = False, Default = \"3", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPreferenceScale, Type = Integer, Dynamic = False, Default = \"1000", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kStaticFolderName, Type = String, Dynamic = False, Default = \"_static", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSourceAttribute, Type = String, Dynamic = False, Default = \"src\x3D\"", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCanonicalMarker, Type = String, Dynamic = False, Default = \"rel\x3D\"canonical\"", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHrefAttributeSphinx, Type = String, Dynamic = False, Default = \"href\x3D\"", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPercent, Type = String, Dynamic = False, Default = \"%", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kParentPrefix, Type = String, Dynamic = False, Default = \"../", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCurrentPrefix, Type = String, Dynamic = False, Default = \"./", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPygmentsFileName, Type = String, Dynamic = False, Default = \"pygments.css", Scope = Private
	#tag EndConstant


	#tag Constant, Name = kArticleBodyMarker, Type = String, Dynamic = False, Default = \"articleBody", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFooterMarker, Type = String, Dynamic = False, Default = \"<footer", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTagClose, Type = String, Dynamic = False, Default = \">", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kUnderscore, Type = String, Dynamic = False, Default = \"_", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kNoTitleText, Type = String, Dynamic = False, Default = \"<no title>", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kEntityLessThan, Type = String, Dynamic = False, Default = \"&lt;", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kEntityGreaterThan, Type = String, Dynamic = False, Default = \"&gt;", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kEntityQuote, Type = String, Dynamic = False, Default = \"&quot;", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kEntityApostrophe, Type = String, Dynamic = False, Default = \"&#39;", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kLessThan, Type = String, Dynamic = False, Default = \"<", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kGreaterThan, Type = String, Dynamic = False, Default = \">", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kQuote, Type = String, Dynamic = False, Default = \"\"", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kApostrophe, Type = String, Dynamic = False, Default = \"\'", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSpace, Type = String, Dynamic = False, Default = \" ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kListSeparator, Type = String, Dynamic = False, Default = \"|", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHiddenDocNames, Type = String, Dynamic = False, Default = \"404|search|fullsearch|genindex|whitesands", Scope = Private
	#tag EndConstant

	#tag Note, Name = Description
		Reads the Sphinx documentation site shipped with Xojo 2022r1.1 and later.

		The table of contents is derived from the docnames array: a docname is a
		slash-separated path, so the paths themselves describe the tree. Folder
		names are replaced by the title of the folder's index page where there is
		one.

		Only docnames and titles are read here. The search dictionaries in the same
		file are much larger and are loaded separately, when the user first
		searches.
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.14.1
		Last change: 2026-07-29 11:00

		------------------------------------------------------------
		0.14.1 — 2026-07-29

		11:00  [FIX] Dropped kAmpersand and kEntityAmpersand, which shadowed the ones VNSHelpDocSet has held as Protected since P5. Harmless but flagged by the compiler, and a shadowed constant is a real trap the day the two stop agreeing.

		------------------------------------------------------------
		0.12.1 — 2026-07-29

		10:31  [FIX] Search returned nothing whenever no page title matched, because an early return left over from before the member pass existed — If candidates.LastIndex < 0 Then Return hits — stood between the page loop and AddMemberMatches. So "tcp listen" found nothing while "tcp" found 63, even though EasyTCPSocket.Listen and TCPSocket.Listen match both words. The page loop is now guarded instead of the whole function, so the member pass always runs.

		------------------------------------------------------------
		0.10.1 — 2026-07-25

		18:36  [NEW] Pages and members under api/deprecated/ are flagged deprecated. The path is the whole test: the titles say so too, but a path cannot be reworded.

		------------------------------------------------------------
		0.10.0 — 2026-07-25

		18:32  [NEW] Member-level search. In this era only a deprecated member gets a page of its own; a live one is a section inside its class page, so DesktopListBox.AddRow could not be found at all. EnsureMemberIndex harvests them from the pages themselves — 691 pages carrying 15 502 members on 2026r1.2 — because the shipped index cannot give them: alltitles holds 4 576 headings and AddAllRows is not among them.
		18:32  [NEW] Two tests separate a member from a prose heading, and both are needed: a member anchors as "<page>-<member>" where a prose section anchors as the whole path, and a member's name has no spaces where a heading reads like a sentence. Together they keep 15 502 of 16 057 candidate links, dropping "FINE PRINT", "GETTING STARTED" and the like.
		18:32  [PERF] The index is built on the first search rather than at startup, so a release that is only browsed never pays for it. A member is ranked by the occurrences on the page documenting it, remembered per page, so a class whose members all match costs one read rather than one per member.

		------------------------------------------------------------
		0.9.0 — 2026-07-25

		18:20  [NEW] Search honours the match mode. Title and docname are matched as one haystack, so "desktop listbox" finds a page whose title carries one word and whose path the other. Measured on 2026r1.2: and = 11 hits, or = 181, exact = 0; a single word gives an identical 82 in all three.
		18:20  [COSMETIC] The ranking bands key off the first term, which for Exact or a one-word query is the whole query — so the result order is unchanged from before there were modes.

		------------------------------------------------------------
		0.8.0 — 2026-07-25

		16:34  [NEW] WebURL reads the page's own <link rel="canonical"> rather than building an address from the docname. The tag is on 99.8%-100% of pages in all 15 releases, and where the two disagree (two to five pages per release) the tag is the correct one: it entity-escapes an apostrophe, and in 2025r1 it lowercases a folder (macOS -> macos), both of which a constructed address gets wrong. Verified by extracting it from every page of every release.

		------------------------------------------------------------
		0.7.0 — 2026-07-25

		15:04  [NEW] LinkHrefFor: a relative ".html" path plus optional anchor, resolved against the page's folder and looked up in the loaded docnames. Percent escapes are decoded first — a few pages carry an apostrophe or a parenthesis as an escape. Measured over all 15 releases: 990 822 page links resolve, 310 do not, the failures being pages Xojo references but never shipped (2023r1.1 alone points at 91 it had archived).
		15:04  [NEW] A relative reference that is not a page is an asset: a few tutorial pages link to the full-size version of a screenshot they also show inline, so it is copied beside the rendered page like any <img> reference.
		15:04  [REFACTOR] HasScheme and its kColon constant moved to VNSHelpDocSet.

		------------------------------------------------------------
		0.2.0 — 2026-07-24

		23:18  [NEW] Initial creation — catalog load, lazy tree over the docname paths, article-body extraction.
	#tag EndNote

	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass

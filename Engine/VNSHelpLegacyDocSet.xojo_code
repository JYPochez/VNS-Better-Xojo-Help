#tag Class
Protected Class VNSHelpLegacyDocSet
Inherits VNSHelpDocSet
	#tag Method, Flags = &h0
		Sub Constructor(theVersion As VNSHelpVersion)
		  Super.Constructor(theVersion)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RootTopics() As VNSHelpTopic()
		  // One group per kind of thing documented — Classes, Modules, Keywords and
		  // so on. Member kinds are deliberately absent: a property or method is
		  // reached through the class that owns it, not from a flat list of 4500.
		  Var topics() As VNSHelpTopic
		  If Not Connect Then Return topics

		  Var seen As New Dictionary
		  Var rows As RowSet

		  Try
		    rows = mDatabase.SelectSQL(kSQLDistinctTypes)
		    While rows <> Nil And Not rows.AfterLastRow
		      Var rawType As String = rows.Column(kColumnType).StringValue.Trim
		      Var normalized As String = rawType.Lowercase

		      If normalized <> "" And Not IsMemberType(normalized) And Not seen.HasKey(normalized) Then
		        seen.Value(normalized) = True
		        topics.Add(New VNSHelpTopic(kGroupPrefix + normalized, GroupTitle(normalized), _
		          VNSHelpTopic.eKind.Group, True))
		      End If

		      rows.MoveToNextRow
		    Wend
		  Catch e As DatabaseException
		    Return topics
		  Finally
		    If rows <> Nil Then rows.Close
		  End Try

		  Return SortedByTitle(topics)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ChildTopics(parentKey As String) As VNSHelpTopic()
		  Var topics() As VNSHelpTopic
		  If Not parentKey.BeginsWith(kGroupPrefix) Then Return topics
		  If Not Connect Then Return topics

		  Var groupName As String = parentKey.MiddleBytes(kGroupPrefix.Bytes)

		  // A group whose name is a type lists that type's entries; anything else is
		  // a container whose name is the owner of its members.
		  If groupName.BeginsWith(kOwnerMarker) Then
		    Return MembersOf(groupName.MiddleBytes(kOwnerMarker.Bytes))
		  End If

		  Return EntriesOfType(groupName)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function PageHTML(pageKey As String, ByRef baseFile As FolderItem) As String
		  // Blobs are already bare HTML fragments, so they need no extraction — one
		  // rendering path serves this era and the modern one.
		  baseFile = Nil
		  If Not Connect Then Return ""

		  Var title As String = TitleFromKey(pageKey)
		  If title = "" Then Return ""

		  Var pageID As Integer = PageIDForTitle(title)

		  // Roughly a third of members have no page of their own — they are
		  // documented as a section of the class page. Show the owner's page rather
		  // than nothing.
		  If pageID < 0 Then
		    Var separator As Integer = title.IndexOfBytes(0, kMemberSeparator)
		    If separator > 0 Then pageID = PageIDForTitle(title.LeftBytes(separator))
		  End If

		  If pageID < 0 Then Return ""

		  Var body As String = PageSource(pageID)
		  If body = "" Then Return ""

		  // Link targets are numbered per rendered page, so the table starts empty.
		  ResetLinkTargets
		  body = RewriteAnchorHrefs(body, "")

		  // Images are stored as blobs and referenced by bare filename, so writing
		  // them into the render folder is all that is needed — no path rewriting.
		  ExtractImages(pageID)

		  baseFile = RenderFolder
		  Return body
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TitleForKey(pageKey As String) As String
		  Return TitleFromKey(pageKey)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function PageCount() As Integer
		  If Not Connect Then Return 0

		  Var rows As RowSet
		  Try
		    rows = mDatabase.SelectSQL(kSQLCountPages)
		    If rows <> Nil And Not rows.AfterLastRow Then Return rows.ColumnAt(0).IntegerValue
		  Catch e As DatabaseException
		    Return 0
		  Finally
		    If rows <> Nil Then rows.Close
		  End Try

		  Return 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Search(query As String, mode As VNSHelpDocSet.eMatch) As VNSHelpSearchHit()
		  // Genuine full-text search: these databases ship a working FTS4 table, so
		  // unlike the Sphinx era the body of every page is searchable.
		  Var hits() As VNSHelpSearchHit
		  If Not Connect Then Return hits

		  Var terms() As String = SearchTerms(query, mode)
		  If terms.LastIndex < 0 Then Return hits

		  Var seen As New Dictionary
		  mRankedThisSearch = 0

		  // Titles first: a page named after the term is what the user usually wants, and
		  // this also catches members, which the full-text table indexes only as part of
		  // their page.
		  AddTitleMatches(hits, seen, terms, mode)
		  AddFullTextMatches(hits, seen, terms, mode)

		  Return SortedByRank(hits)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddTitleMatches(hits() As VNSHelpSearchHit, seen As Dictionary, terms() As String, mode As VNSHelpDocSet.eMatch)
		  // One LIKE query per term rather than SQL built to fit the term count. Under
		  // All, the first term narrows it in SQL and the rest are checked on the titles
		  // that come back — titles are short, and the answer is the same either way.
		  For Each term As String In terms
		    Var rows As RowSet
		    Try
		      rows = mDatabase.SelectSQL(kSQLTitleSearch, kWildcard + term + kWildcard, kMaximumResults)
		      While rows <> Nil And Not rows.AfterLastRow
		        Var title As String = rows.Column(kColumnTitle).StringValue
		        Var kind As String = rows.Column(kColumnType).StringValue

		        If title <> "" And Not seen.HasKey(title) And MatchesTerms(title, terms, mode) Then
		          seen.Value(title) = True
		          Var hit As New VNSHelpSearchHit(kPagePrefix + title, title, kind, RankFor(title, terms))
		          hit.Platforms = PlatformsForTitle(title)
		          hits.Add(hit)
		        End If

		        rows.MoveToNextRow
		      Wend
		    Catch e As DatabaseException
		      Return
		    Finally
		      If rows <> Nil Then rows.Close
		    End Try

		    // Under All every hit had to contain the first term anyway, so the remaining
		    // queries could only repeat work.
		    If mode <> VNSHelpDocSet.eMatch.Any Then Return
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PlatformsForTitle(title As String) As Integer
		  // This era ships no Compatibility table — 0 pages carry one, measured across
		  // the whole database — so the class name is the only signal there is, and it
		  // is a clean one: 2018r3 has 59 Web* classes and 51 iOS* out of 429.
		  //
		  // Everything else stays kPlatformNone and so matches every filter. That is
		  // the honest answer rather than a guess: ListBox is a desktop control, but
		  // String and Integer are not, and nothing in the data separates them.
		  //
		  // Android matches nothing at all here. Android support did not exist before
		  // 2020, so an old doc set legitimately has none — the checkbox is simply
		  // inert on these versions, which is correct and not a bug to fix.
		  If title.BeginsWith(kPrefixWeb) Then Return Integer(VNSHelpDocSet.ePlatform.Web)
		  If title.BeginsWith(kPrefixIOS) Then Return Integer(VNSHelpDocSet.ePlatform.iOS)

		  Return VNSHelpDocSet.kPlatformNone
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddFullTextMatches(hits() As VNSHelpSearchHit, seen As Dictionary, terms() As String, mode As VNSHelpDocSet.eMatch)
		  // MATCH has to sit in a subquery. Joining a virtual table on MATCH directly
		  // returns nothing at all, silently.
		  Var rows As RowSet
		  Try
		    rows = mDatabase.SelectSQL(kSQLFullTextSearch, FullTextExpression(terms, mode), kMaximumResults)
		    While rows <> Nil And Not rows.AfterLastRow
		      If hits.Count >= kMaximumResults Then Exit

		      Var title As String = TitleFromURL(rows.Column(kColumnURL).StringValue)
		      If title <> "" And Not seen.HasKey(title) Then
		        seen.Value(title) = True
		        Var hit As New VNSHelpSearchHit(kPagePrefix + title, title, kContextFullText, _
		          RankFor(title, terms))
		        hit.Platforms = PlatformsForTitle(title)
		        hits.Add(hit)
		      End If

		      rows.MoveToNextRow
		    Wend
		  Catch e As DatabaseException
		    Return
		  Finally
		    If rows <> Nil Then rows.Close
		  End Try
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FullTextExpression(terms() As String, mode As VNSHelpDocSet.eMatch) As String
		  // FTS4 supports all three modes natively — implicit AND between terms, an
		  // explicit OR, and a quoted phrase — verified against 2018r3: "listbox cell"
		  // gives 85 pages, "listbox OR cell" 287, and the quoted phrase 8.
		  //
		  // Every term is quoted, which is what makes user input safe here: inside quotes
		  // FTS treats -, : and * as ordinary characters rather than operators. A quote
		  // typed by the user is dropped, since it could only close ours.
		  Var pieces() As String
		  For Each term As String In terms
		    Var cleaned As String = term.ReplaceAll(kFullTextQuote, "").Trim
		    If cleaned <> "" Then pieces.Add(kFullTextQuote + cleaned + kFullTextQuote)
		  Next

		  If pieces.LastIndex < 0 Then Return ""

		  // Exact arrives as a single term already, so quoting it makes it a phrase.
		  If mode = VNSHelpDocSet.eMatch.Any Then Return String.FromArray(pieces, kFullTextOr)

		  Return String.FromArray(pieces, kFullTextAnd)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function RankFor(title As String, terms() As String) As Integer
		  // Occurrences in the page itself. The FTS4 table can say whether a page
		  // matches but not how often, so the count comes from the page text.
		  //
		  // Bounded per search: fetching every matching page would make a live
		  // search unusable on a two-letter term. Unranked hits still appear.
		  If mRankedThisSearch >= kMaximumRanked Then Return 1
		  mRankedThisSearch = mRankedThisSearch + 1

		  Var pageID As Integer = PageIDForTitle(title)
		  If pageID < 0 Then Return 1

		  Var occurrences As Integer = TotalOccurrences(PageSource(pageID), terms)
		  If occurrences = 0 Then Return 1

		  Return occurrences
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function TitleFromURL(url As String) As String
		  // Up to 2018r3 the url column is the bare page name; from 2019r1 it is a
		  // full address.
		  If url = "" Then Return ""
		  If Not url.BeginsWith(kDocsURLPrefix) Then Return url

		  Return url.MiddleBytes(kDocsURLPrefix.Bytes)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StyleSheet() As String
		  // These pages are MediaWiki output. Their own stylesheet was never shipped
		  // with the database, so the classes they rely on are styled here.
		  Return kMediaWikiStyle
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function EntriesOfType(typeName As String) As VNSHelpTopic()
		  // Everything of one type. An entry that owns members becomes expandable so
		  // its members hang beneath it.
		  Var topics() As VNSHelpTopic
		  Var owners As Dictionary = MemberOwners

		  Var rows As RowSet
		  Try
		    rows = mDatabase.SelectSQL(kSQLTitlesOfType, typeName)
		    While rows <> Nil And Not rows.AfterLastRow
		      Var title As String = rows.Column(kColumnTitle).StringValue
		      If title <> "" Then
		        Var hasMembers As Boolean = owners.HasKey(title.Lowercase)
		        If hasMembers Then
		          topics.Add(New VNSHelpTopic(kGroupPrefix + kOwnerMarker + title, title, _
		            VNSHelpTopic.eKind.Group, True))
		        Else
		          topics.Add(New VNSHelpTopic(kPagePrefix + title, title, VNSHelpTopic.eKind.Page, False))
		        End If
		      End If
		      rows.MoveToNextRow
		    Wend
		  Catch e As DatabaseException
		    Return topics
		  Finally
		    If rows <> Nil Then rows.Close
		  End Try

		  Return topics
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function MembersOf(owner As String) As VNSHelpTopic()
		  // The members of one class or module. Matched on the exact "Owner." prefix
		  // rather than with LIKE, because a LIKE pattern would treat the underscores
		  // that appear in many Xojo names as wildcards.
		  Var topics() As VNSHelpTopic
		  Var prefix As String = owner + kMemberSeparator

		  Var rows As RowSet
		  Try
		    // The length passed to substr must be the prefix length exactly: SQLite's
		    // substr(title, 1, n) returns n characters, so n + 1 never matches.
		    rows = mDatabase.SelectSQL(kSQLMembersOfOwner, prefix, prefix.Length, owner)
		    While rows <> Nil And Not rows.AfterLastRow
		      Var title As String = rows.Column(kColumnTitle).StringValue
		      If title <> "" Then
		        topics.Add(New VNSHelpTopic(kPagePrefix + title, MemberLabel(title, owner), _
		          VNSHelpTopic.eKind.Page, False))
		      End If
		      rows.MoveToNextRow
		    Wend
		  Catch e As DatabaseException
		    Return topics
		  Finally
		    If rows <> Nil Then rows.Close
		  End Try

		  // The owner's own page comes first, so selecting the class itself is
		  // possible even though its row is a group.
		  Var withOwner() As VNSHelpTopic
		  withOwner.Add(New VNSHelpTopic(kPagePrefix + owner, kOverviewLabel, VNSHelpTopic.eKind.Page, False))
		  For Each topic As VNSHelpTopic In topics
		    withOwner.Add(topic)
		  Next

		  Return withOwner
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function MemberOwners() As Dictionary
		  // Lower-cased names that own at least one member, so a class can be shown
		  // as expandable without a query per row.
		  If mMemberOwners <> Nil Then Return mMemberOwners

		  mMemberOwners = New Dictionary
		  Var rows As RowSet

		  Try
		    rows = mDatabase.SelectSQL(kSQLMemberOwners)
		    While rows <> Nil And Not rows.AfterLastRow
		      Var owner As String = rows.ColumnAt(0).StringValue.Trim
		      If owner <> "" Then mMemberOwners.Value(owner.Lowercase) = True
		      rows.MoveToNextRow
		    Wend
		  Catch e As DatabaseException
		    Return mMemberOwners
		  Finally
		    If rows <> Nil Then rows.Close
		  End Try

		  Return mMemberOwners
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function LinkHrefFor(context As String, reference As String) As String
		  // These pages came out of a MediaWiki, so a link to another page is a wiki
		  // path: "/String" in 2019r1, "/index.php/String" in every earlier release. No
		  // context is needed — the target is spelled out in full.
		  #Pragma Unused context
		  If reference = "" Then Return reference
		  If reference.BeginsWith(kAnchorSeparator) Then Return reference

		  // The database decides, not the shape of the reference. Both tests are needed
		  // and neither is safe on its own: a wiki title can contain a colon
		  // ("Webinar:_Deploying_iOS_Apps.html") so it cannot simply be read as a scheme,
		  // while 1 113 genuinely external addresses end in ".html" and must not be read
		  // as titles. Asking for the page first and treating external as the fallback
		  // gets all of them right.
		  If reference.BeginsWith(kSlash) Or reference.EndsWith(kPageExtension) Then
		    Var pageKey As String = PageKeyForReference(reference)
		    If pageKey <> "" Then Return LinkHref(pageKey)
		  End If

		  If HasScheme(reference) Then Return ExternalLinkHref(reference)

		  // A wiki path that names nothing this database holds, or furniture rather than
		  // documentation — the 2015 blobs still carry the skin's own stylesheet
		  // reference inside an anchor.
		  Return DeadLinkHref
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PageKeyForReference(reference As String) As String
		  // The page key a wiki path names, or "" when this database holds no such page.
		  //
		  // Answers are remembered for the life of the doc set. Every 2015 page repeats
		  // the skin's whole navigation, so one page can carry over 400 links, and
		  // without this each one would cost its own query.
		  If mLinkKeyCache = Nil Then mLinkKeyCache = New Dictionary
		  If mLinkKeyCache.HasKey(reference) Then Return mLinkKeyCache.Value(reference).StringValue

		  Var title As String = reference
		  If title.BeginsWith(kSlash) Then
		    title = title.MiddleBytes(kSlash.Bytes)
		    If title.BeginsWith(kIndexPhpPrefix) Then title = title.MiddleBytes(kIndexPhpPrefix.Bytes)
		  ElseIf title.EndsWith(kPageExtension) Then
		    title = title.LeftBytes(title.Bytes - kPageExtension.Bytes)
		  End If

		  Var anchor As String = ""
		  Var hash As Integer = title.IndexOfBytes(0, kAnchorSeparator)
		  If hash >= 0 Then
		    anchor = title.MiddleBytes(hash)
		    title = title.LeftBytes(hash)
		  End If

		  // "?title=X&action=edit" is a wiki command, not a page. A trailing
		  // "&action=edit&redlink=1" is the wiki's own mark for a page that never
		  // existed, so cutting at the ampersand leaves a title that will not be found —
		  // which is the right answer.
		  Var key As String = ""
		  If title <> "" And title.IndexOfBytes(0, kQueryMarker) < 0 Then
		    Var ampersand As Integer = title.IndexOfBytes(0, kAmpersand)
		    If ampersand >= 0 Then title = title.LeftBytes(ampersand)

		    // Titles are matched exactly as stored, without percent-decoding: the url
		    // column keeps its own escapes, so decoding first loses 455 of the 67 491
		    // links that resolve across the 15 databases.
		    If title <> "" And PageIDForTitle(title) >= 0 Then key = kPagePrefix + title + anchor
		  End If

		  mLinkKeyCache.Value(reference) = key
		  Return key
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PageIDForTitle(title As String) As Integer
		  // Page identifiers are looked up by title because the two spellings of the
		  // url column both derive from it: releases up to 2018r3 store a bare page
		  // name, 2019r1 and later a full https://docs.xojo.com/ address.
		  Var rows As RowSet
		  Var found As Integer = -1

		  Try
		    rows = mDatabase.SelectSQL(kSQLPageByTitle, title, kDocsURLPrefix + title)
		    If rows <> Nil And Not rows.AfterLastRow Then
		      found = rows.Column(kColumnID).IntegerValue

		      // A redirect names the page to show instead. Followed once only: these
		      // databases contain redirect pairs that point at each other.
		      Var instead As String = rows.Column(kColumnShowInstead).StringValue.Trim
		      If instead <> "" And instead <> title Then
		        Var target As Integer = PageIDForRedirect(instead)
		        If target >= 0 Then found = target
		      End If
		    End If
		  Catch e As DatabaseException
		    Return -1
		  Finally
		    If rows <> Nil Then rows.Close
		  End Try

		  Return found
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PageIDForRedirect(title As String) As Integer
		  Var rows As RowSet
		  Try
		    rows = mDatabase.SelectSQL(kSQLPageByTitle, title, kDocsURLPrefix + title)
		    If rows <> Nil And Not rows.AfterLastRow Then Return rows.Column(kColumnID).IntegerValue
		  Catch e As DatabaseException
		    Return -1
		  Finally
		    If rows <> Nil Then rows.Close
		  End Try

		  Return -1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PageSource(pageID As Integer) As String
		  Var rows As RowSet
		  Try
		    rows = mDatabase.SelectSQL(kSQLPageSource.ReplaceAll(kKeyColumnToken, mBlobKeyColumn), pageID)

		    // page_source is a BLOB, so StringValue returns bytes with no encoding
		    // attached. Without naming it the UTF-8 text is taken for Latin-1 and
		    // every curly quote arrives as "a€œ".
		    If rows <> Nil And Not rows.AfterLastRow Then
		      Return rows.Column(kColumnPageSource).StringValue.DefineEncoding(Encodings.UTF8)
		    End If
		  Catch e As DatabaseException
		    Return ""
		  Finally
		    If rows <> Nil Then rows.Close
		  End Try

		  Return ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ExtractImages(pageID As Integer)
		  // Write this page's images into the render folder, where the page itself is
		  // about to be written. References in the markup are bare filenames, so they
		  // resolve with no rewriting.
		  Var folder As FolderItem = RenderFolder
		  If folder = Nil Then Return

		  Var names() As String
		  Var rows As RowSet

		  Try
		    rows = mDatabase.SelectSQL(kSQLPageImages.ReplaceAll(kKeyColumnToken, mImageKeyColumn), pageID)
		    While rows <> Nil And Not rows.AfterLastRow
		      Var name As String = rows.Column(kColumnImageName).StringValue.Trim
		      If name <> "" And Not AssetAlreadyPresent(name) Then names.Add(name)
		      rows.MoveToNextRow
		    Wend
		  Catch e As DatabaseException
		    Return
		  Finally
		    If rows <> Nil Then rows.Close
		  End Try

		  For Each name As String In names
		    WriteImage(folder, name)
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub WriteImage(folder As FolderItem, name As String)
		  Var rows As RowSet
		  Var data As String

		  Try
		    rows = mDatabase.SelectSQL(kSQLImageData, name)
		    If rows = Nil Or rows.AfterLastRow Then Return
		    data = rows.Column(kColumnImageData).StringValue
		  Catch e As DatabaseException
		    Return
		  Finally
		    If rows <> Nil Then rows.Close
		  End Try

		  If data = "" Then Return

		  // img_data holds base64 text, not raw bytes — SQLite reports the column as
		  // text and the value starts "/9j/..." for a JPEG. Every image in all
		  // fifteen releases is stored this way, so writing the value straight out
		  // produced files that were valid base64 and not valid images.
		  Var decoded As String
		  Try
		    decoded = DecodeBase64(data)
		  Catch e As RuntimeException
		    Return
		  End Try

		  If decoded = "" Then Return

		  Var target As FolderItem = folder.Child(name)
		  If target = Nil Then Return

		  Var stream As BinaryStream
		  Try
		    stream = BinaryStream.Create(target, True)
		    stream.Write(decoded)
		  Catch e As IOException
		    Return
		  Finally
		    If stream <> Nil Then stream.Close
		  End Try
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Connect() As Boolean
		  // These are the user's IDE files and must not change.
		  //
		  // SQLiteDatabase has no ReadOnly property — its only properties are
		  // DatabaseFile, EncryptionKey, LibraryVersion, LoadExtensions, MetaData,
		  // Tag, ThreadYieldInterval, Timeout and WriteAheadLogging — so the
		  // connection cannot be opened read-only through the API. The guarantee is
		  // therefore upheld by this class only ever issuing SELECT, and by leaving
		  // WriteAheadLogging off so no -wal file is created beside the database.
		  If mConnected Then Return True
		  If mConnectionFailed Then Return False

		  mConnectionFailed = True
		  If Version = Nil Or Version.DocFile = Nil Or Not Version.DocFile.Exists Then Return False

		  mDatabase = New SQLiteDatabase
		  mDatabase.DatabaseFile = Version.DocFile

		  Try
		    mDatabase.Connect
		  Catch e As DatabaseException
		    mDatabase = Nil
		    Return False
		  End Try

		  DetectSchema

		  mConnected = True
		  mConnectionFailed = False
		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DetectSchema()
		  // The column naming changed mid-era: the four 2015 releases key blobs and
		  // page images on "id", everything from 2016r1.1 on uses "cached_page_id".
		  // Guessing wrong yields no page at all, so it is detected rather than
		  // assumed.
		  mBlobKeyColumn = KeyColumnOf(kTableBlobs)
		  mImageKeyColumn = KeyColumnOf(kTablePageImages)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function KeyColumnOf(tableName As String) As String
		  Var rows As RowSet
		  Var found As String = kColumnCachedPageID

		  Try
		    rows = mDatabase.SelectSQL(kSQLKeyColumn, tableName)
		    If rows <> Nil And Not rows.AfterLastRow Then found = rows.ColumnAt(0).StringValue
		  Catch e As DatabaseException
		    Return found
		  Finally
		    If rows <> Nil Then rows.Close
		  End Try

		  If found = "" Then found = kColumnCachedPageID
		  Return found
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function TitleFromKey(pageKey As String) As String
		  If Not pageKey.BeginsWith(kPagePrefix) Then Return ""

		  Var withoutPrefix As String = pageKey.MiddleBytes(kPagePrefix.Bytes)
		  Var hash As Integer = withoutPrefix.IndexOfBytes(0, kAnchorSeparator)
		  If hash < 0 Then Return withoutPrefix

		  Return withoutPrefix.LeftBytes(hash)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function MemberLabel(title As String, owner As String) As String
		  // Members are listed under their owner, so the repeated "Owner." prefix is
		  // dropped from the label.
		  Var prefix As String = owner + kMemberSeparator
		  If title.LeftBytes(prefix.Bytes) = prefix Then Return title.MiddleBytes(prefix.Bytes)

		  Return title
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IsMemberType(normalizedType As String) As Boolean
		  For Each memberType As String In kMemberTypes.Split(kListSeparator)
		    If normalizedType = memberType Then Return True
		  Next

		  Return False
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GroupTitle(normalizedType As String) As String
		  // Friendly plural for the types worth naming; anything else is shown with
		  // its first letter capitalised. The type strings are inconsistent across
		  // releases — 2015 alone carries both "class" and "Class" — which is why
		  // grouping happens on the lower-cased value.
		  Var pairs() As String = kTypeLabels.Split(kListSeparator)
		  For Each pair As String In pairs
		    Var parts() As String = pair.Split(kPairSeparator)
		    If parts.LastIndex = 1 And parts(0) = normalizedType Then Return parts(1)
		  Next

		  If normalizedType = "" Then Return normalizedType
		  Return normalizedType.LeftBytes(1).Uppercase + normalizedType.MiddleBytes(1)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SortedByTitle(topics() As VNSHelpTopic) As VNSHelpTopic()
		  // SortWith needs unique base values, so the title is suffixed with the
		  // position to break ties.
		  Var sorted() As VNSHelpTopic
		  If topics.LastIndex < 0 Then Return sorted

		  Var keys() As String
		  For i As Integer = 0 To topics.LastIndex
		    keys.Add(topics(i).Title + kListSeparator + i.ToString)
		  Next

		  keys.SortWith(topics)

		  For Each topic As VNSHelpTopic In topics
		    sorted.Add(topic)
		  Next

		  Return sorted
		End Function
	#tag EndMethod

	#tag Property, Flags = &h21
		Private mDatabase As SQLiteDatabase
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mConnected As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mConnectionFailed As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mBlobKeyColumn As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLinkKeyCache As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mImageKeyColumn As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMemberOwners As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mRankedThisSearch As Integer
	#tag EndProperty

	#tag Constant, Name = kSQLDistinctTypes, Type = String, Dynamic = False, Default = \"SELECT DISTINCT type FROM cached_descriptions", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSQLTitlesOfType, Type = String, Dynamic = False, Default = \"SELECT DISTINCT title FROM cached_descriptions WHERE lower(type) \x3D ?1 AND instr(title\x2C '.') \x3D 0 ORDER BY title", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSQLMemberOwners, Type = String, Dynamic = False, Default = \"SELECT DISTINCT lower(substr(title\x2C 1\x2C instr(title\x2C '.') - 1)) FROM cached_descriptions WHERE instr(title\x2C '.') > 1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSQLMembersOfOwner, Type = String, Dynamic = False, Default = \"SELECT DISTINCT title FROM cached_descriptions WHERE substr(title\x2C 1\x2C ?2) \x3D ?1 AND title <> ?3 ORDER BY type\x2C title", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSQLPageByTitle, Type = String, Dynamic = False, Default = \"SELECT id\x2C showInstead FROM cached_pages WHERE url \x3D ?1 OR url \x3D ?2 LIMIT 1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSQLPageSource, Type = String, Dynamic = False, Default = \"SELECT page_source FROM cached_blobs WHERE {KEY} \x3D ?1 LIMIT 1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSQLPageImages, Type = String, Dynamic = False, Default = \"SELECT img_name FROM cached_page_images WHERE {KEY} \x3D ?1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSQLImageData, Type = String, Dynamic = False, Default = \"SELECT img_data FROM cached_images WHERE img_name \x3D ?1 LIMIT 1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSQLCountPages, Type = String, Dynamic = False, Default = \"SELECT count(*) FROM cached_pages", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSQLTitleSearch, Type = String, Dynamic = False, Default = \"SELECT DISTINCT title\x2C type FROM cached_descriptions WHERE title LIKE ?1 ORDER BY length(title)\x2C title LIMIT ?2", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSQLFullTextSearch, Type = String, Dynamic = False, Default = \"SELECT url FROM cached_pages WHERE id IN (SELECT docid FROM fullText WHERE fullText MATCH ?1) LIMIT ?2", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColumnURL, Type = String, Dynamic = False, Default = \"url", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kWildcard, Type = String, Dynamic = False, Default = \"%", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFullTextQuote, Type = String, Dynamic = False, Default = \"\"", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFullTextAnd, Type = String, Dynamic = False, Default = \" AND ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFullTextOr, Type = String, Dynamic = False, Default = \" OR ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kContextFullText, Type = String, Dynamic = False, Default = \"in page text", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPrefixWeb, Type = String, Dynamic = False, Default = \"Web", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPrefixIOS, Type = String, Dynamic = False, Default = \"iOS", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSQLKeyColumn, Type = String, Dynamic = False, Default = \"SELECT name FROM pragma_table_info(?1) WHERE name IN ('cached_page_id'\x2C 'id') ORDER BY name LIMIT 1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyColumnToken, Type = String, Dynamic = False, Default = \"{KEY}", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTableBlobs, Type = String, Dynamic = False, Default = \"cached_blobs", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTablePageImages, Type = String, Dynamic = False, Default = \"cached_page_images", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColumnID, Type = String, Dynamic = False, Default = \"id", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColumnType, Type = String, Dynamic = False, Default = \"type", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColumnTitle, Type = String, Dynamic = False, Default = \"title", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColumnShowInstead, Type = String, Dynamic = False, Default = \"showInstead", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColumnPageSource, Type = String, Dynamic = False, Default = \"page_source", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColumnImageName, Type = String, Dynamic = False, Default = \"img_name", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColumnImageData, Type = String, Dynamic = False, Default = \"img_data", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kColumnCachedPageID, Type = String, Dynamic = False, Default = \"cached_page_id", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kDocsURLPrefix, Type = String, Dynamic = False, Default = \"https://docs.xojo.com/", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMemberSeparator, Type = String, Dynamic = False, Default = \".", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kIndexPhpPrefix, Type = String, Dynamic = False, Default = \"index.php/", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPageExtension, Type = String, Dynamic = False, Default = \".html", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kQueryMarker, Type = String, Dynamic = False, Default = \"?", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kOwnerMarker, Type = String, Dynamic = False, Default = \"owner:", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kListSeparator, Type = String, Dynamic = False, Default = \"|", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPairSeparator, Type = String, Dynamic = False, Default = \"\x3D", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kOverviewLabel, Type = String, Dynamic = False, Default = \"Overview", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMemberTypes, Type = String, Dynamic = False, Default = \"property|method|event|constructor|shared method|sharedmethod|shared property|sharedproperty|inherits|none", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTypeLabels, Type = String, Dynamic = False, Default = \"class\x3DClasses|module\x3DModules|interface\x3DInterfaces|datatype\x3DData types|enumeration\x3DEnumerations|keyword\x3DKeywords|operator\x3DOperators|literal\x3DLiterals|directive\x3DCompiler directives|concept\x3DConcepts|constant\x3DConstants|errormessage\x3DError messages|redirect\x3DRedirects", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMediaWikiStyle, Type = String, Dynamic = False, Default = \"/* Extra rules for the MediaWiki markup in the legacy XojoLangRefDB pages.\n   Applied on top of the reader stylesheet\x2C which handles the common tags.\n   The database ships no stylesheet of its own\x2C so anything these pages rely\n   on has to be supplied here. */\n\n/* Section headings are spans inside the heading tags. */\n.mw-headline { color: inherit; }\n\n/* Code samples are a div\x2C not a <pre>\x2C so the reader\'s pre rules miss them.\n   Indentation is literal spaces with <br/> for line breaks and no newlines at\n   all\x2C which is why pre-wrap is needed to keep the indentation. Syntax colours\n   come from inline styles in the markup\x2C so none are set here. */\ndiv.codesnippet\x2C table.codesnippet {\n  font-family: ui-monospace\x2C SFMono-Regular\x2C Menlo\x2C Consolas\x2C monospace;\n  font-size: 12.5px;\n  line-height: 1.45;\n  white-space: pre-wrap;\n  background: #f6f6f8;\n  border: 1px solid #ececf0;\n  border-radius: 5px;\n  padding: 10px 12px;\n  margin: 0 0 12px;\n  overflow-x: auto;\n}\n\n/* Links inside a sample are keywords; they should not look clickable. */\ndiv.codesnippet a\x2C table.codesnippet a {\n  color: inherit;\n  text-decoration: none;\n}\n\n/* Room for the copy button. */\ndiv.codesnippet.bxh-codehost\x2C table.codesnippet.bxh-codehost { padding-right: 64px; }\n\n/* Parameter and member tables. */\ntable.genericTable\x2C table.innerDynTable\x2C table.wikitable {\n  border-collapse: collapse;\n  margin: 0 0 14px;\n  max-width: 100%;\n}\ntable.genericTable th\x2C table.innerDynTable th\x2C table.wikitable th {\n  background: #f6f6f8;\n  font-weight: 600;\n  text-align: left;\n}\ntable.genericTable td\x2C table.genericTable th\x2C\ntable.innerDynTable td\x2C table.innerDynTable th\x2C\ntable.wikitable td\x2C table.wikitable th {\n  border: 1px solid #e2e2e2;\n  padding: 5px 8px;\n  vertical-align: top;\n}\n\n/* The page title is emitted as a class rather than an h1. */\n.titleClass\x2C .title {\n  font-size: 20px;\n  font-weight: 600;\n  margin: 0 0 12px;\n}\n\n/* Notice boxes carry a small icon and a paragraph. */\n.metadata\x2C .plainlinks {\n  background: #fff8e1;\n  border: 1px solid #f0e0a0;\n  border-radius: 5px;\n  padding: 8px 12px;\n  margin: 0 0 12px;\n}\n\n/* Inline icons (the lock and warning glyphs) must not be stretched by the\n   reader\'s img rule. */\n.image img { max-width: none; vertical-align: middle; }\n\n/* MediaWiki\'s own table of contents duplicates our tree. */\n#toc\x2C .toc { display: none; }\n\n/* Redirect hints are noise in a reader. */\n.mw-redirect { color: inherit; }\n\n.clear_both { clear: both; }\n", Scope = Private
	#tag EndConstant

	#tag Note, Name = Description
		Reads the XojoLangRefDB database shipped with Xojo 2015r2.1 through 2019r1.1.

		The pages are MediaWiki HTML stored as blobs, already bare fragments, so the
		reader needs no extraction step for them.

		Three things vary across the fifteen releases and are handled rather than
		assumed:

		1. The four 2015 releases key cached_blobs and cached_page_images on "id";
		2016r1.1 onwards use "cached_page_id". The column is detected on connect.

		2. cached_pages.url holds a bare page name up to 2018r3 and a full
		https://docs.xojo.com/ address from 2019r1. Lookups match either form.

		3. cached_page_descriptions, which the SimpleLRBrowser reference project uses
		to join a description to its page, is absent from the 2015 releases. Pages are
		therefore located by title, which works everywhere because both spellings of
		the url column derive from the title.

		The tree shows members beneath the class or module that owns them rather than
		as flat lists per type, which would put 4500 properties in one branch.
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.9.0
		Last change: 2026-07-25 18:20

		------------------------------------------------------------
		0.9.0 — 2026-07-25

		18:20  [NEW] Search honours the match mode. FTS4 supports all three natively — implicit AND, an explicit OR, and a quoted phrase — verified on 2018r3: 'listbox cell' gives 85 pages, 'listbox OR cell' 287, and the quoted phrase 8.
		18:20  [NEW] Every term is quoted in the MATCH expression, which is what makes user input safe: inside quotes FTS treats -, : and * as ordinary characters rather than operators. A quote typed by the user is dropped, since it could only close ours.
		18:20  [NEW] Title search runs one LIKE per term. Under All the first term narrows it in SQL and the rest are checked on the returned titles, which is the same answer without SQL built to fit the term count.

		------------------------------------------------------------
		0.7.0 — 2026-07-25

		15:04  [NEW] LinkHrefFor / PageKeyForReference. The plan's assumed link form, href="/ListBox", was wrong: it is "/String" in 2019r1 only, "/index.php/String" in every earlier release, and 2015r2.1-2016r3 carry the whole MediaWiki skin on top. Strip a leading slash, then "index.php/", split the anchor, reject a reference carrying "?", cut at "&" — a trailing "&action=edit&redlink=1" is the wiki's own mark for a page that never existed, so cutting there leaves a title that will not be found, which is the right answer. 1 042 659 page links resolve across the 15 databases; showInstead redirects are honoured for free because resolution goes through the same PageIDForTitle the page reader uses.
		15:04  [FIX] Titles are matched exactly as stored, without percent-decoding: the url column keeps its own escapes, so decoding first loses 455 of the 67 491 links that resolve.
		15:04  [FIX] The database decides before the shape of the reference does. Neither test is safe alone — a wiki title can contain a colon ("Webinar:_Deploying_iOS_Apps.html") and 1 113 genuinely external addresses end in ".html" — so the page lookup runs first and external is the fallback.
		15:04  [PERF] Resolutions are cached for the life of the doc set. One 2015 page carries over 400 links because each repeats the skin's whole navigation, and every one would otherwise cost its own query.

		------------------------------------------------------------
		0.5.0 — 2026-07-25

		13:29  [NEW] Initial creation — type groups, members under their owner, blob pages, images extracted to the render folder.
	#tag EndNote

	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass

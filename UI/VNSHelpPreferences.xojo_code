#tag Module
Protected Module VNSHelpPreferences
	#tag Method, Flags = &h0
		Sub Load()
		  // Read the settings file, falling back to defaults for anything missing,
		  // unreadable or out of range. A corrupt file must never stop the app from
		  // opening, so every failure path here is silent.
		  mLoaded = True

		  Var file As FolderItem = PreferencesFile(False)
		  If file = Nil Or Not file.Exists Then Return

		  Var stream As TextInputStream
		  Var contents As String

		  Try
		    stream = TextInputStream.Open(file)
		    contents = stream.ReadAll(Encodings.UTF8)
		  Catch e As IOException
		    Return
		  Finally
		    If stream <> Nil Then stream.Close
		  End Try

		  If contents.Trim = "" Then Return

		  Try
		    Var settings As Dictionary = ParseJSON(contents)
		    If settings = Nil Then Return

		    mWindowLeft = IntegerValue(settings, kKeyWindowLeft, mWindowLeft)
		    mWindowTop = IntegerValue(settings, kKeyWindowTop, mWindowTop)
		    mWindowWidth = IntegerValue(settings, kKeyWindowWidth, mWindowWidth)
		    mWindowHeight = IntegerValue(settings, kKeyWindowHeight, mWindowHeight)
		    mDividerX = IntegerValue(settings, kKeyDividerX, mDividerX)
		    mLastVersion = StringValue(settings, kKeyLastVersion)
		    mLastPageKey = StringValue(settings, kKeyLastPageKey)
		    mSearchMode = IntegerValue(settings, kKeySearchMode, mSearchMode)
		    mDeprecatedLast = BooleanValue(settings, kKeyDeprecatedLast, mDeprecatedLast)
		    LoadFavorites(settings)
		  Catch e As RuntimeException
		    // Malformed JSON: keep whatever defaults were already in place.
		    Return
		  End Try
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Save()
		  Var file As FolderItem = PreferencesFile(True)
		  If file = Nil Then Return

		  Var settings As New Dictionary
		  settings.Value(kKeyWindowLeft) = mWindowLeft
		  settings.Value(kKeyWindowTop) = mWindowTop
		  settings.Value(kKeyWindowWidth) = mWindowWidth
		  settings.Value(kKeyWindowHeight) = mWindowHeight
		  settings.Value(kKeyDividerX) = mDividerX
		  settings.Value(kKeyLastVersion) = mLastVersion
		  settings.Value(kKeyLastPageKey) = mLastPageKey
		  settings.Value(kKeySearchMode) = mSearchMode
		  settings.Value(kKeyDeprecatedLast) = mDeprecatedLast

		  // Stored as an array of objects rather than a delimited string: a page title
		  // is documentation text and can contain whatever separator we might pick.
		  Var favorites() As Variant
		  For Each favorite As Dictionary In mFavorites
		    favorites.Add(favorite)
		  Next
		  settings.Value(kKeyFavorites) = favorites

		  Var stream As TextOutputStream
		  Try
		    stream = TextOutputStream.Create(file)
		    stream.Write(GenerateJSON(settings, True))
		  Catch e As RuntimeException
		    Return
		  Finally
		    If stream <> Nil Then stream.Close
		  End Try
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub EnsureLoaded()
		  // mLoaded was already being set by Load and never read anywhere. The
		  // favorites API is reachable before the window opens, so it needs exactly
		  // the guard that flag was put there for.
		  If Not mLoaded Then Load
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RememberWindow(bounds As Rect)
		  // Ignore a minimised or zero-sized window: restoring those would open the
		  // app somewhere unusable.
		  If bounds = Nil Then Return
		  If bounds.Width < kMinimumRememberedSize Or bounds.Height < kMinimumRememberedSize Then Return

		  mWindowLeft = bounds.Left
		  mWindowTop = bounds.Top
		  mWindowWidth = bounds.Width
		  mWindowHeight = bounds.Height
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasWindowBounds() As Boolean
		  Return mWindowWidth >= kMinimumRememberedSize And mWindowHeight >= kMinimumRememberedSize
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub LoadFavorites(settings As Dictionary)
		  // Defensive like every other reader here: a corrupt or hand-edited file must
		  // not stop the app from opening, so anything that is not a usable entry is
		  // dropped silently rather than raising.
		  mFavorites.RemoveAll
		  If Not settings.HasKey(kKeyFavorites) Then Return

		  Var stored() As Variant
		  Try
		    stored = settings.Value(kKeyFavorites)
		  Catch e As RuntimeException
		    Return
		  End Try

		  For Each entry As Variant In stored
		    Var favorite As Dictionary
		    Try
		      favorite = entry
		    Catch e As RuntimeException
		      Continue
		    End Try
		    If favorite = Nil Then Continue

		    Var release As String = StringValue(favorite, kKeyFavoriteVersion)
		    Var pageKey As String = StringValue(favorite, kKeyFavoritePageKey)
		    If release = "" Or pageKey = "" Then Continue

		    AddFavorite(release, pageKey, StringValue(favorite, kKeyFavoriteTitle))
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IndexOfFavorite(release As String, pageKey As String) As Integer
		  For i As Integer = 0 To mFavorites.LastIndex
		    If StringValue(mFavorites(i), kKeyFavoriteVersion) <> release Then Continue
		    If StringValue(mFavorites(i), kKeyFavoritePageKey) = pageKey Then Return i
		  Next

		  Return -1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsFavorite(release As String, pageKey As String) As Boolean
		  EnsureLoaded
		  Return IndexOfFavorite(release, pageKey) >= 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AddFavorite(release As String, pageKey As String, title As String)
		  EnsureLoaded
		  If release = "" Or pageKey = "" Then Return
		  If IndexOfFavorite(release, pageKey) >= 0 Then Return

		  Var favorite As New Dictionary
		  favorite.Value(kKeyFavoriteVersion) = release
		  favorite.Value(kKeyFavoritePageKey) = pageKey
		  favorite.Value(kKeyFavoriteTitle) = title
		  mFavorites.Add(favorite)

		  // A bound, so a stuck key cannot grow the file without limit.
		  If mFavorites.Count > kMaximumFavorites Then mFavorites.RemoveAt(0)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RemoveFavorite(release As String, pageKey As String)
		  EnsureLoaded
		  Var index As Integer = IndexOfFavorite(release, pageKey)
		  If index >= 0 Then mFavorites.RemoveAt(index)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToggleFavorite(release As String, pageKey As String, title As String) As Boolean
		  // True when the page is a favorite afterwards, so the caller can say which way
		  // it went without asking again.
		  If IsFavorite(release, pageKey) Then
		    RemoveFavorite(release, pageKey)
		    Return False
		  End If

		  AddFavorite(release, pageKey, title)
		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FavoriteCount() As Integer
		  EnsureLoaded
		  Return mFavorites.Count
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FavoriteVersionAt(index As Integer) As String
		  EnsureLoaded
		  If index < 0 Or index > mFavorites.LastIndex Then Return ""

		  Return StringValue(mFavorites(index), kKeyFavoriteVersion)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FavoriteKeyAt(index As Integer) As String
		  EnsureLoaded
		  If index < 0 Or index > mFavorites.LastIndex Then Return ""

		  Return StringValue(mFavorites(index), kKeyFavoritePageKey)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FavoriteTitleAt(index As Integer) As String
		  EnsureLoaded
		  If index < 0 Or index > mFavorites.LastIndex Then Return ""

		  Return StringValue(mFavorites(index), kKeyFavoriteTitle)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PreferencesFile(createFolder As Boolean) As FolderItem
		  // ApplicationData/Better Xojo Help/preferences.json — the only place this
		  // app writes. The documentation it reads is left untouched.
		  Var base As FolderItem = SpecialFolder.ApplicationData
		  If base = Nil Or Not base.Exists Then Return Nil

		  Var folder As FolderItem = base.Child(kFolderName)
		  If folder = Nil Then Return Nil

		  If Not folder.Exists Then
		    If Not createFolder Then Return Nil
		    Try
		      folder.CreateFolder
		    Catch e As IOException
		      Return Nil
		    End Try
		  End If

		  Return folder.Child(kFileName)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IntegerValue(settings As Dictionary, key As String, fallback As Integer) As Integer
		  If Not settings.HasKey(key) Then Return fallback

		  Try
		    Return settings.Value(key).IntegerValue
		  Catch e As RuntimeException
		    Return fallback
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BooleanValue(settings As Dictionary, key As String, fallback As Boolean) As Boolean
		  // Defensive like the other readers here: a value of the wrong type keeps the
		  // default rather than raising.
		  If Not settings.HasKey(key) Then Return fallback

		  Try
		    Return settings.Value(key).BooleanValue
		  Catch e As RuntimeException
		    Return fallback
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function StringValue(settings As Dictionary, key As String) As String
		  If Not settings.HasKey(key) Then Return ""

		  Try
		    Return settings.Value(key).StringValue
		  Catch e As RuntimeException
		    Return ""
		  End Try
		End Function
	#tag EndMethod

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  EnsureLoaded
			  Return mDeprecatedLast
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mDeprecatedLast = value
			End Set
		#tag EndSetter
		DeprecatedLast As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mSearchMode
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  // Anything unrecognised falls back to And, which is the default.
			  If value >= 0 And value <= 2 Then mSearchMode = value
			End Set
		#tag EndSetter
		SearchMode As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mWindowLeft
			End Get
		#tag EndGetter
		WindowLeft As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mWindowTop
			End Get
		#tag EndGetter
		WindowTop As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mWindowWidth
			End Get
		#tag EndGetter
		WindowWidth As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mWindowHeight
			End Get
		#tag EndGetter
		WindowHeight As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mDividerX
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  If value >= 0 Then mDividerX = value
			End Set
		#tag EndSetter
		DividerX As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mLastVersion
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mLastVersion = value
			End Set
		#tag EndSetter
		LastVersion As String
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mLastPageKey
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mLastPageKey = value
			End Set
		#tag EndSetter
		LastPageKey As String
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mLoaded As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mWindowLeft As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mWindowTop As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mWindowWidth As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mWindowHeight As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDividerX As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLastVersion As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLastPageKey As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mFavorites() As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSearchMode As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDeprecatedLast As Boolean = True
	#tag EndProperty

	#tag Constant, Name = kFolderName, Type = String, Dynamic = False, Default = \"Better Xojo Help", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFileName, Type = String, Dynamic = False, Default = \"preferences.json", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyWindowLeft, Type = String, Dynamic = False, Default = \"windowLeft", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyWindowTop, Type = String, Dynamic = False, Default = \"windowTop", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyWindowWidth, Type = String, Dynamic = False, Default = \"windowWidth", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyWindowHeight, Type = String, Dynamic = False, Default = \"windowHeight", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyDividerX, Type = String, Dynamic = False, Default = \"dividerX", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyLastVersion, Type = String, Dynamic = False, Default = \"lastVersion", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyLastPageKey, Type = String, Dynamic = False, Default = \"lastPageKey", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyDeprecatedLast, Type = String, Dynamic = False, Default = \"deprecatedLast", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeySearchMode, Type = String, Dynamic = False, Default = \"searchMode", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyFavorites, Type = String, Dynamic = False, Default = \"favorites", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyFavoriteVersion, Type = String, Dynamic = False, Default = \"version", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyFavoritePageKey, Type = String, Dynamic = False, Default = \"pageKey", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyFavoriteTitle, Type = String, Dynamic = False, Default = \"title", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMaximumFavorites, Type = Integer, Dynamic = False, Default = \"200", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMinimumRememberedSize, Type = Integer, Dynamic = False, Default = \"200", Scope = Private
	#tag EndConstant

	#tag Note, Name = Description
		Settings that survive a relaunch: window position and size, splitter position,
		the release last shown and the page last read.

		Stored as JSON in ApplicationData/Better Xojo Help/preferences.json. This file
		is the only thing the app writes — the documentation it reads is never
		modified.

		Load is deliberately forgiving: a missing, unreadable, empty or malformed file
		leaves the defaults in place rather than raising.
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.11.0
		Last change: 2026-07-25 18:41

		------------------------------------------------------------
		0.11.0 — 2026-07-25

		18:41  [NEW] deprecatedLast, defaulting to True, plus a BooleanValue reader as defensive as the other two — a value of the wrong type keeps the default rather than raising.

		------------------------------------------------------------
		0.9.0 — 2026-07-25

		18:20  [NEW] The match mode persists, range-checked on the way in like every other value here.

		------------------------------------------------------------
		0.8.0 — 2026-07-25

		16:34  [NEW] Favorites, stored as an array of objects rather than a delimited string: a page title is documentation text and can contain whatever separator we might pick. Each entry carries the release it belongs to, because a page key means nothing to a provider that did not issue it.
		16:34  [FIX] EnsureLoaded added, and every favorites accessor goes through it. mLoaded was already being set by Load and read nowhere — the favorites API is reachable before the window opens, so it needs the guard that flag was put there for.

		------------------------------------------------------------
		0.4.0 — 2026-07-24

		23:37  [NEW] Initial creation — window bounds, splitter position, last version and last page.
	#tag EndNote

	#tag ViewBehavior
	#tag EndViewBehavior
End Module
#tag EndModule

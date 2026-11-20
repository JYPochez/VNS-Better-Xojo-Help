#tag Class
Protected Class VNSHelpTabState
	#tag Method, Flags = &h0
		Sub Constructor()
			HistoryPosition = -1
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Caption() As String
			// What the tab bar draws. The page title when there is one, since a page key
			// is not meant to be read, and a placeholder for a tab opened on nothing.
			If Title <> "" Then Return Title
			If PageKey <> "" Then Return PageKey

			Return kUntitled
		End Function
	#tag EndMethod

	#tag Property, Flags = &h0
		Viewer As DesktopHTMLViewer
	#tag EndProperty

	#tag Property, Flags = &h0
		PageKey As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Title As String
	#tag EndProperty

	#tag Property, Flags = &h0
		PendingAnchor As String
	#tag EndProperty

	#tag Property, Flags = &h0
		LinkKeys() As String
	#tag EndProperty

	#tag Property, Flags = &h0
		LinkTitles() As String
	#tag EndProperty

	#tag Property, Flags = &h0
		HistoryKeys() As String
	#tag EndProperty

	#tag Property, Flags = &h0
		HistoryTitles() As String
	#tag EndProperty

	#tag Property, Flags = &h0
		HistoryPosition As Integer = -1
	#tag EndProperty

	#tag Constant, Name = kUntitled, Type = String, Dynamic = False, Default = \"Untitled", Scope = Private
	#tag EndConstant

	#tag Note, Name = Description
		One tab: its own viewer, and the state that belongs to the page it is showing.

		**`Viewer` is the important field, and it is why this class is shaped this way.**
		Each tab owns a DesktopHTMLViewer created at runtime, so switching tabs is
		nothing more than toggling Visible — the document stays loaded, the scroll
		position survives, and nothing is re-rendered. The pattern is taken from
		BrowserTab and MainWindow.WireViewer in /Users/jeanyves/xojo2015/Claude Browser,
		which is working code in this same Xojo version:

		    Var v As New DesktopHTMLViewer
		    Self.AddControl(v)
		    AddHandler v.CancelLoad, AddressOf OnViewerCancelLoad
		    AddHandler v.DocumentComplete, AddressOf OnViewerDocumentComplete

		A runtime-created control has no event handlers of its own, so they are attached
		with AddHandler and every handler takes the viewer as its first parameter —
		`OnViewerCancelLoad(sender As DesktopHTMLViewer, url As String) As Boolean`. The
		window maps that sender back to a tab index, which is what lets one set of
		handlers serve every tab.

		The rest of the fields are the per-page state the window used to hold as its own
		properties: the link table a rendered page's `bxh:<n>` hrefs resolve against, the
		history trail behind that tab, and the anchor still to be scrolled to.

		What is deliberately NOT here: the search field, the topic list and the version
		popup are shared by every tab, the way a browser's sidebar is. A tab is a page
		being read and the trail that led to it, not a whole window.
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.13.0
		Last change: 2026-07-29 10:50

		------------------------------------------------------------
		0.13.0 — 2026-07-29

		10:50  [NEW] Initial creation — per-tab viewer, page key, title, pending anchor, link table and history.
	#tag EndNote

	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass

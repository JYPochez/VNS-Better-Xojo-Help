#tag Class
Protected Class VNSHelpSearchHit
	#tag Method, Flags = &h0
		Sub Constructor(hitPageKey As String, hitTitle As String, hitContext As String, hitRank As Integer, Optional isDeprecated As Boolean = False)
		  PageKey = hitPageKey
		  Title = hitTitle
		  Context = hitContext
		  Rank = hitRank
		  Deprecated = isDeprecated
		End Sub
	#tag EndMethod

	#tag Property, Flags = &h0
		PageKey As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Title As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Context As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Rank As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Deprecated As Boolean
	#tag EndProperty

	#tag Note, Name = Description
		One search result. Context is the group or section the hit sits in, shown
		alongside the title so results stay meaningful when several pages share a
		name. Rank orders the list: higher is a better match.
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.10.1
		Last change: 2026-07-25 18:36

		------------------------------------------------------------
		0.10.1 — 2026-07-25

		18:36  [NEW] Deprecated flag, set through an optional constructor argument so existing call sites keep working.

		------------------------------------------------------------
		0.2.0 — 2026-07-24

		23:18  [NEW] Initial creation.
	#tag EndNote

	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass

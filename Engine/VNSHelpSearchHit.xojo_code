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

	#tag Property, Flags = &h0
		Platforms As Integer
	#tag EndProperty

	#tag Note, Name = Description
		One search result. Context is the group or section the hit sits in, shown
		alongside the title so results stay meaningful when several pages share a
		name. Rank orders the list: higher is a better match.

		Platforms is a bitmask of VNSHelpDocSet.ePlatform values. Zero means the
		page says nothing about platforms — the whole language reference, 1337 of
		2123 pages on 2026r1.2 — and such a hit matches every filter. That default
		is the important one: were it treated as "no platforms" instead, unticking
		Web would hide String.
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.16.0
		Last change: 2026-07-29 14:54

		------------------------------------------------------------
		0.16.0 — 2026-07-29

		14:54  [NEW] Platforms bitmask, left at zero by the existing constructor so a provider that does not classify a hit keeps working and its hits keep matching everything.

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

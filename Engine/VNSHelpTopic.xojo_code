#tag Class
Protected Class VNSHelpTopic
	#tag Method, Flags = &h0
		Sub Constructor(topicKey As String, topicTitle As String, topicKind As VNSHelpTopic.eKind, expandable As Boolean)
		  Key = topicKey
		  Title = topicTitle
		  Kind = topicKind
		  HasChildren = expandable
		End Sub
	#tag EndMethod

	#tag Property, Flags = &h0
		Key As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Title As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Kind As VNSHelpTopic.eKind
	#tag EndProperty

	#tag Property, Flags = &h0
		HasChildren As Boolean
	#tag EndProperty

	#tag Enum, Name = eKind, Type = Integer, Flags = &h0
		Group
		  Page
		  Section
	#tag EndEnum

	#tag Note, Name = Description
		One node in the table of contents.

		Key is opaque to the UI: only the doc set that produced it knows how to turn
		it back into a page. Group nodes are containers with no page of their own;
		Page nodes load a document; Section nodes load a document and scroll to an
		anchor inside it.
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.2.0
		Last change: 2026-07-24 23:18

		------------------------------------------------------------
		0.2.0 — 2026-07-24

		23:18  [NEW] Initial creation.
	#tag EndNote

	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass

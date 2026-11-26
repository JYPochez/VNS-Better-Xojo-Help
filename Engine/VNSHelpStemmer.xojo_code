#tag Module
Protected Module VNSHelpStemmer
	#tag Method, Flags = &h0
		Function Stem(word As String) As String
		  // Sphinx's English stemmer, ported line for line from the language_data.js every
		  // Sphinx-era release ships (identical from 2022r1.1 to 2026r3.1). The shipped
		  // `terms` index stores words in this stemmed form, so a query word must be
		  // stemmed the same way before it can be looked up: "breakonexceptions" is
		  // stored as "breakonexcept". Expects a lowercased word.
		  //
		  // Checked against a Python port of the same code on the 2026r3.1 page text:
		  // every word that missed the index was a stopword or a markup fragment.
		  Var w As String = word
		  If w.Length < 3 Then Return w

		  // A leading y is a consonant; capitalised, no vowel class can match it.
		  Var first As String = w.Left(1)
		  If first = kLowerY Then w = kUpperY + w.Middle(1)

		  // Step 1a
		  Var m As RegExMatch = Find(kStep1aSsIes, w)
		  If m <> Nil Then
		    w = m.SubExpressionString(1) + m.SubExpressionString(2)
		  Else
		    m = Find(kStep1aS, w)
		    If m <> Nil Then w = m.SubExpressionString(1) + m.SubExpressionString(2)
		  End If

		  // Step 1b
		  m = Find(kStep1bEed, w)
		  If m <> Nil Then
		    If Find(kMeasureAboveZero, m.SubExpressionString(1)) <> Nil Then w = w.Left(w.Length - 1)
		  Else
		    m = Find(kStep1bEdIng, w)
		    If m <> Nil And Find(kVowelInStem, m.SubExpressionString(1)) <> Nil Then
		      w = m.SubExpressionString(1)
		      If Find(kStep1bAtBlIz, w) <> Nil Then
		        w = w + kLowerE
		      ElseIf Find(kStep1bDouble, w) <> Nil Then
		        w = w.Left(w.Length - 1)
		      ElseIf Find(kShortStem, w) <> Nil Then
		        w = w + kLowerE
		      End If
		    End If
		  End If

		  // Step 1c
		  m = Find(kStep1cY, w)
		  If m <> Nil And Find(kVowelInStem, m.SubExpressionString(1)) <> Nil Then
		    w = m.SubExpressionString(1) + kLowerI
		  End If

		  // Step 2
		  m = Find(kStep2Suffixes, w)
		  If m <> Nil And Find(kMeasureAboveZero, m.SubExpressionString(1)) <> Nil Then
		    w = m.SubExpressionString(1) + Step2Replacement(m.SubExpressionString(2))
		  End If

		  // Step 3
		  m = Find(kStep3Suffixes, w)
		  If m <> Nil And Find(kMeasureAboveZero, m.SubExpressionString(1)) <> Nil Then
		    w = m.SubExpressionString(1) + Step3Replacement(m.SubExpressionString(2))
		  End If

		  // Step 4
		  m = Find(kStep4Suffixes, w)
		  If m <> Nil Then
		    If Find(kMeasureAboveOne, m.SubExpressionString(1)) <> Nil Then w = m.SubExpressionString(1)
		  Else
		    m = Find(kStep4Ion, w)
		    If m <> Nil Then
		      Var stemmed As String = m.SubExpressionString(1) + m.SubExpressionString(2)
		      If Find(kMeasureAboveOne, stemmed) <> Nil Then w = stemmed
		    End If
		  End If

		  // Step 5
		  m = Find(kStep5E, w)
		  If m <> Nil Then
		    Var stemmed As String = m.SubExpressionString(1)
		    If Find(kMeasureAboveOne, stemmed) <> Nil _
		      Or (Find(kMeasureOne, stemmed) <> Nil And Find(kShortStem, stemmed) = Nil) Then
		      w = stemmed
		    End If
		  End If

		  If Find(kStep5Ll, w) <> Nil And Find(kMeasureAboveOne, w) <> Nil Then w = w.Left(w.Length - 1)

		  If first = kLowerY Then w = kLowerY + w.Middle(1)
		  Return w
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Find(pattern As String, subject As String) As RegExMatch
		  // Case-sensitive, unlike RegEx's default: the capitalised leading Y relies on it.
		  Var matcher As New RegEx
		  matcher.SearchPattern = pattern
		  matcher.Options.CaseSensitive = True
		  Return matcher.Search(subject)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Step2Replacement(suffix As String) As String
		  Select Case suffix
		  Case "ational"
		    Return "ate"
		  Case "tional"
		    Return "tion"
		  Case "enci"
		    Return "ence"
		  Case "anci"
		    Return "ance"
		  Case "izer"
		    Return "ize"
		  Case "bli"
		    Return "ble"
		  Case "alli"
		    Return "al"
		  Case "entli"
		    Return "ent"
		  Case "eli"
		    Return "e"
		  Case "ousli"
		    Return "ous"
		  Case "ization"
		    Return "ize"
		  Case "ation"
		    Return "ate"
		  Case "ator"
		    Return "ate"
		  Case "alism"
		    Return "al"
		  Case "iveness"
		    Return "ive"
		  Case "fulness"
		    Return "ful"
		  Case "ousness"
		    Return "ous"
		  Case "aliti"
		    Return "al"
		  Case "iviti"
		    Return "ive"
		  Case "biliti"
		    Return "ble"
		  Case "logi"
		    Return "log"
		  End Select
		  Return ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Step3Replacement(suffix As String) As String
		  Select Case suffix
		  Case "icate"
		    Return "ic"
		  Case "ative"
		    Return ""
		  Case "alize"
		    Return "al"
		  Case "iciti"
		    Return "ic"
		  Case "ical"
		    Return "ic"
		  Case "ful"
		    Return ""
		  Case "ness"
		    Return ""
		  End Select
		  Return ""
		End Function
	#tag EndMethod


	#tag Note, Name = Description
		The Porter stemmer Sphinx uses to build its search index, so a query word can be
		looked up in the `terms` table of searchindex.js. UI-free.
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.22.0
		Last change: 2026-11-20 22:21

		------------------------------------------------------------
		0.22.0 — 2026-11-20

		22:21  [NEW] Initial creation: Stem, ported from Sphinx's language_data.js and validated against a Python port on the 2026r3.1 page text.
	#tag EndNote


	#tag Constant, Name = kStep1aSsIes, Type = String, Dynamic = False, Default = \"^(.+\?)(ss|i)es$", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kStep1aS, Type = String, Dynamic = False, Default = \"^(.+\?)([^s])s$", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kStep1bEed, Type = String, Dynamic = False, Default = \"^(.+\?)eed$", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kStep1bEdIng, Type = String, Dynamic = False, Default = \"^(.+\?)(ed|ing)$", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kStep1bAtBlIz, Type = String, Dynamic = False, Default = \"(at|bl|iz)$", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kStep1bDouble, Type = String, Dynamic = False, Default = \"([^aeiouylsz])\\1$", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kStep1cY, Type = String, Dynamic = False, Default = \"^(.+\?)y$", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kStep2Suffixes, Type = String, Dynamic = False, Default = \"^(.+\?)(ational|tional|enci|anci|izer|bli|alli|entli|eli|ousli|ization|ation|ator|alism|iveness|fulness|ousness|aliti|iviti|biliti|logi)$", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kStep3Suffixes, Type = String, Dynamic = False, Default = \"^(.+\?)(icate|ative|alize|iciti|ical|ful|ness)$", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kStep4Suffixes, Type = String, Dynamic = False, Default = \"^(.+\?)(al|ance|ence|er|ic|able|ible|ant|ement|ment|ent|ou|ism|ate|iti|ous|ive|ize)$", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kStep4Ion, Type = String, Dynamic = False, Default = \"^(.+\?)(s|t)(ion)$", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kStep5E, Type = String, Dynamic = False, Default = \"^(.+\?)e$", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kStep5Ll, Type = String, Dynamic = False, Default = \"ll$", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMeasureAboveZero, Type = String, Dynamic = False, Default = \"^([^aeiou][^aeiouy]*)\?[aeiouy][aeiou]*[^aeiou][^aeiouy]*", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMeasureOne, Type = String, Dynamic = False, Default = \"^([^aeiou][^aeiouy]*)\?[aeiouy][aeiou]*[^aeiou][^aeiouy]*([aeiouy][aeiou]*)\?$", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMeasureAboveOne, Type = String, Dynamic = False, Default = \"^([^aeiou][^aeiouy]*)\?[aeiouy][aeiou]*[^aeiou][^aeiouy]*[aeiouy][aeiou]*[^aeiou][^aeiouy]*", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kVowelInStem, Type = String, Dynamic = False, Default = \"^([^aeiou][^aeiouy]*)\?[aeiouy]", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kShortStem, Type = String, Dynamic = False, Default = \"^[^aeiou][^aeiouy]*[aeiouy][^aeiouwxy]$", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kLowerY, Type = String, Dynamic = False, Default = \"y", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kUpperY, Type = String, Dynamic = False, Default = \"Y", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kLowerE, Type = String, Dynamic = False, Default = \"e", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kLowerI, Type = String, Dynamic = False, Default = \"i", Scope = Private
	#tag EndConstant


	#tag ViewBehavior
	#tag EndViewBehavior
End Module
#tag EndModule

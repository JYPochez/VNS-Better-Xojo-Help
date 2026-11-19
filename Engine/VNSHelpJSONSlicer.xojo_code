#tag Module
Protected Module VNSHelpJSONSlicer
	#tag Method, Flags = &h0
		Function ExtractArray(source As String, key As String) As String
		  // The text of the array stored under `key`, brackets included, or "" if
		  // there is no such key.
		  Return ExtractDelimited(source, key, kByteArrayOpen, kByteArrayClose)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ExtractObject(source As String, key As String) As String
		  // The text of the object stored under `key`, braces included, or "" if
		  // there is no such key.
		  Return ExtractDelimited(source, key, kByteObjectOpen, kByteObjectClose)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringArray(jsonArrayText As String) As String()
		  // Decode the text of a JSON array of strings. The values inside are
		  // always well-formed JSON even when the surrounding document is not, so
		  // ParseJSON is safe here and handles the escape sequences for us.
		  Var result() As String
		  If jsonArrayText = "" Then Return result

		  Try
		    Var parsed() As Variant = ParseJSON(jsonArrayText)
		    For Each item As Variant In parsed
		      result.Add(item.StringValue)
		    Next
		  Catch e As RuntimeException
		    // A malformed slice yields nothing rather than taking the app down.
		    Var empty() As String
		    Return empty
		  End Try

		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ExtractDelimited(source As String, key As String, openByte As Integer, closeByte As Integer) As String
		  // Locate `key` used as an object key, then return its bracketed value.
		  //
		  // The matching close is found inside a bounded slice that doubles until
		  // it fits, so the byte scanning never walks the whole document. That
		  // matters: these files run to 3.4 MB and only the first ~130 KB holds
		  // the arrays this app needs.
		  Var colonPosition As Integer = FindKeyColon(source, key)
		  If colonPosition < 0 Then Return ""

		  Var openPosition As Integer = source.IndexOfBytes(colonPosition, ByteToString(openByte))
		  If openPosition < 0 Then Return ""

		  Var sourceBytes As Integer = source.Bytes
		  Var windowSize As Integer = kInitialWindowBytes

		  While True
		    Var slice As String = source.MiddleBytes(openPosition, windowSize)
		    Var closePosition As Integer = MatchingDelimiter(slice, openByte, closeByte)
		    If closePosition >= 0 Then Return slice.LeftBytes(closePosition + 1)

		    // Either the value is bigger than the window, or the document ends
		    // before it closes. Only the first is worth retrying.
		    If openPosition + windowSize >= sourceBytes Then Return ""
		    If windowSize >= kMaximumWindowBytes Then Return ""
		    windowSize = windowSize * 2
		  Wend
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function MatchingDelimiter(slice As String, openByte As Integer, closeByte As Integer) As Integer
		  // Byte offset of the delimiter closing the one at offset 0, or -1 when
		  // the slice ends first. Quoted strings are skipped whole, so a bracket
		  // inside a title cannot be mistaken for structure — Xojo page titles do
		  // contain them.
		  Var openText As String = ByteToString(openByte)
		  Var closeText As String = ByteToString(closeByte)
		  Var depth As Integer = 0
		  Var position As Integer = 0

		  While True
		    Var quotePosition As Integer = slice.IndexOfBytes(position, kQuoteText)
		    Var openFound As Integer = slice.IndexOfBytes(position, openText)
		    Var closeFound As Integer = slice.IndexOfBytes(position, closeText)

		    Var earliest As Integer = EarliestPosition(quotePosition, openFound, closeFound)
		    If earliest < 0 Then Return -1

		    If earliest = quotePosition Then
		      Var stringEnd As Integer = EndOfString(slice, quotePosition)
		      If stringEnd < 0 Then Return -1
		      position = stringEnd + 1
		    ElseIf earliest = openFound Then
		      depth = depth + 1
		      position = openFound + 1
		    Else
		      depth = depth - 1
		      If depth = 0 Then Return closeFound
		      position = closeFound + 1
		    End If
		  Wend
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function EndOfString(slice As String, quotePosition As Integer) As Integer
		  // Byte offset of the quote closing the one at quotePosition. A quote is
		  // only an escape when preceded by an odd number of backslashes, so a
		  // value ending in a literal backslash still terminates correctly.
		  Var position As Integer = quotePosition + 1

		  While True
		    Var candidate As Integer = slice.IndexOfBytes(position, kQuoteText)
		    If candidate < 0 Then Return -1

		    Var backslashes As Integer = 0
		    Var scan As Integer = candidate - 1
		    While scan >= 0 And Asc(slice.MiddleBytes(scan, 1)) = kByteBackslash
		      backslashes = backslashes + 1
		      scan = scan - 1
		    Wend

		    If backslashes Mod 2 = 0 Then Return candidate
		    position = candidate + 1
		  Wend
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FindKeyColon(source As String, key As String) As Integer
		  // Byte offset of the colon introducing `key`'s value.
		  //
		  // Sphinx writes this file two ways: 2025r2.1 and later quote their keys
		  // (valid JSON), everything from 2022r1.1 to 2025r1 emits a bare
		  // JavaScript object literal. Try the quoted spelling first because it is
		  // unambiguous, then the bare one.
		  Var quoted As Integer = ColonAfterPattern(source, kQuoteText + key + kQuoteText, False)
		  If quoted >= 0 Then Return quoted

		  Return ColonAfterPattern(source, key, True)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ColonAfterPattern(source As String, pattern As String, requireWordStart As Boolean) As Integer
		  // Find `pattern` followed (past any spaces) by a colon.
		  //
		  // requireWordStart guards the bare-key search: "titles" occurs inside
		  // "alltitles", and alltitles is also followed by a colon, so without the
		  // preceding-character check the wrong key would be found.
		  Var patternBytes As Integer = pattern.Bytes
		  Var sourceBytes As Integer = source.Bytes
		  Var position As Integer = source.IndexOfBytes(0, pattern)

		  While position >= 0
		    Var acceptable As Boolean = True
		    If requireWordStart And position > 0 Then
		      If IsWordByte(Asc(source.MiddleBytes(position - 1, 1))) Then acceptable = False
		    End If

		    If acceptable Then
		      Var scan As Integer = position + patternBytes
		      While scan < sourceBytes And Asc(source.MiddleBytes(scan, 1)) = kByteSpace
		        scan = scan + 1
		      Wend
		      If scan < sourceBytes And Asc(source.MiddleBytes(scan, 1)) = kByteColon Then Return scan
		    End If

		    position = source.IndexOfBytes(position + 1, pattern)
		  Wend

		  Return -1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function EarliestPosition(first As Integer, second As Integer, third As Integer) As Integer
		  // Smallest non-negative of the three, or -1 when none was found.
		  Var best As Integer = -1

		  If first >= 0 Then best = first
		  If second >= 0 And (best < 0 Or second < best) Then best = second
		  If third >= 0 And (best < 0 Or third < best) Then best = third

		  Return best
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IsWordByte(value As Integer) As Boolean
		  // Characters that can appear inside a JavaScript identifier.
		  If value >= kByteDigitZero And value <= kByteDigitNine Then Return True
		  If value >= kByteUpperA And value <= kByteUpperZ Then Return True
		  If value >= kByteLowerA And value <= kByteLowerZ Then Return True
		  If value = kByteUnderscore Or value = kByteDollar Then Return True

		  Return False
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ByteToString(value As Integer) As String
		  Return Chr(value)
		End Function
	#tag EndMethod

	#tag Constant, Name = kQuoteText, Type = String, Dynamic = False, Default = \"\"", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kByteQuote, Type = Integer, Dynamic = False, Default = \"34", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kByteBackslash, Type = Integer, Dynamic = False, Default = \"92", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kByteColon, Type = Integer, Dynamic = False, Default = \"58", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kByteSpace, Type = Integer, Dynamic = False, Default = \"32", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kByteArrayOpen, Type = Integer, Dynamic = False, Default = \"91", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kByteArrayClose, Type = Integer, Dynamic = False, Default = \"93", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kByteObjectOpen, Type = Integer, Dynamic = False, Default = \"123", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kByteObjectClose, Type = Integer, Dynamic = False, Default = \"125", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kByteDigitZero, Type = Integer, Dynamic = False, Default = \"48", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kByteDigitNine, Type = Integer, Dynamic = False, Default = \"57", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kByteUpperA, Type = Integer, Dynamic = False, Default = \"65", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kByteUpperZ, Type = Integer, Dynamic = False, Default = \"90", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kByteLowerA, Type = Integer, Dynamic = False, Default = \"97", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kByteLowerZ, Type = Integer, Dynamic = False, Default = \"122", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kByteUnderscore, Type = Integer, Dynamic = False, Default = \"95", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kByteDollar, Type = Integer, Dynamic = False, Default = \"36", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kInitialWindowBytes, Type = Integer, Dynamic = False, Default = \"262144", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMaximumWindowBytes, Type = Integer, Dynamic = False, Default = \"33554432", Scope = Private
	#tag EndConstant

	#tag Note, Name = Description
		Pulls one named value out of a Sphinx searchindex.js without parsing the whole
		document.

		Two reasons this cannot simply call ParseJSON on the file:

		1. Only Xojo 2025r2.1 and later emit valid JSON. Releases 2022r1.1 through
		2025r1 write a JavaScript object literal with unquoted keys, which ParseJSON
		rejects. The values are well-formed JSON in both, so slicing a value out and
		parsing just that works everywhere.

		2. The files reach 3.4 MB while the arrays the app needs total about 130 KB.

		All scanning is byte-oriented (IndexOfBytes / MiddleBytes): the structural
		characters are ASCII, byte offsets stay consistent, and it avoids IndexOf,
		which is case-insensitive by default.
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.2.0
		Last change: 2026-07-24 23:18

		------------------------------------------------------------
		0.2.0 — 2026-07-24

		23:18  [NEW] Initial creation — ExtractArray / ExtractObject / StringArray over quoted and bare-key documents.
	#tag EndNote

	#tag ViewBehavior
	#tag EndViewBehavior
End Module
#tag EndModule

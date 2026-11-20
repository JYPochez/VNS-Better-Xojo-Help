#tag Class
Protected Class VNSHelpMCPBridge
	#tag Method, Flags = &h0
		Function Respond(requestBody As String) As String
		  // One JSON-RPC request in, one response out. An empty return means "no
		  // response is due" — a notification — which the socket turns into 202.
		  //
		  // Nothing in here raises. A malformed request from a client we do not control
		  // has to come back as a JSON-RPC error, never as an exception that takes the
		  // listener down with it.
		  // Counted before anything can fail, so a malformed request still shows up as
		  // traffic — a client sending rubbish is exactly when you want to see the
		  // meter moving.
		  CharactersIn = CharactersIn + requestBody.Length
		  Requests = Requests + 1

		  Var request As Dictionary
		  Try
		    request = ParseJSON(requestBody)
		  Catch e As RuntimeException
		    Return ErrorResponse(Nil, kCodeParseError, kMessageParseError)
		  End Try

		  If request = Nil Then Return ErrorResponse(Nil, kCodeInvalidRequest, kMessageInvalidRequest)

		  Var id As Variant = request.Lookup(kKeyId, Nil)
		  Var method As String = request.Lookup(kKeyMethod, "").StringValue

		  // A request without an id is a notification: the client is telling us
		  // something and is not waiting. "notifications/initialized" is the one that
		  // matters — answering it with a result confuses strict clients.
		  If id = Nil Then Return ""

		  Select Case method
		  Case kMethodInitialize
		    Return SuccessResponse(id, InitializeResult)
		  Case kMethodToolsList
		    Return SuccessResponse(id, ToolsListResult)
		  Case kMethodToolsCall
		    Return CallTool(id, request)
		  Case kMethodPing
		    Return SuccessResponse(id, New Dictionary)
		  End Select

		  Return ErrorResponse(id, kCodeMethodNotFound, kMessageMethodNotFound + method)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function InitializeResult() As Dictionary
		  // The protocol version is echoed from what we implement, not from what the
		  // client asked for. Claiming a client's version we have not implemented is
		  // how a handshake succeeds and every call afterwards fails.
		  Var capabilities As New Dictionary
		  capabilities.Value(kKeyTools) = New Dictionary

		  Var info As New Dictionary
		  info.Value(kKeyName) = kServerName
		  info.Value(kKeyVersion) = ServerVersion

		  Var result As New Dictionary
		  result.Value(kKeyProtocolVersion) = kProtocolVersion
		  result.Value(kKeyCapabilities) = capabilities
		  result.Value(kKeyServerInfo) = info

		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ToolsListResult() As Dictionary
		  Var tools() As Variant
		  tools.Add(ToolDefinition(kToolLookup, kToolLookupDescription, kArgSymbol, kArgSymbolDescription))
		  tools.Add(ToolDefinition(kToolSearch, kToolSearchDescription, kArgQuery, kArgQueryDescription))

		  Var result As New Dictionary
		  result.Value(kKeyTools) = tools

		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ToolDefinition(name As String, description As String, argName As String, argDescription As String) As Dictionary
		  // Both tools take one required string plus an optional version, so the schema
		  // is built from that shape rather than written out twice.
		  Var primary As New Dictionary
		  primary.Value(kKeyType) = kTypeString
		  primary.Value(kKeyDescription) = argDescription

		  Var release As New Dictionary
		  release.Value(kKeyType) = kTypeString
		  release.Value(kKeyDescription) = kArgVersionDescription

		  Var properties As New Dictionary
		  properties.Value(argName) = primary
		  properties.Value(kArgVersion) = release

		  Var required() As Variant
		  required.Add(argName)

		  Var schema As New Dictionary
		  schema.Value(kKeyType) = kTypeObject
		  schema.Value(kKeyProperties) = properties
		  schema.Value(kKeyRequired) = required

		  Var tool As New Dictionary
		  tool.Value(kKeyName) = name
		  tool.Value(kKeyDescription) = description
		  tool.Value(kKeyInputSchema) = schema

		  Return tool
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function CallTool(id As Variant, request As Dictionary) As String
		  Var params As Dictionary = DictionaryValue(request, kKeyParams)
		  If params = Nil Then Return ErrorResponse(id, kCodeInvalidParams, kMessageNoParams)

		  Var name As String = params.Lookup(kKeyName, "").StringValue
		  Var arguments As Dictionary = DictionaryValue(params, kKeyArguments)
		  If arguments = Nil Then arguments = New Dictionary

		  Var release As String = arguments.Lookup(kArgVersion, "").StringValue
		  Var text As String

		  Select Case name
		  Case kToolLookup
		    Var symbol As String = arguments.Lookup(kArgSymbol, "").StringValue
		    If symbol.Trim = "" Then Return ErrorResponse(id, kCodeInvalidParams, kMessageNoSymbol)
		    text = Lookup(symbol, release)
		  Case kToolSearch
		    Var query As String = arguments.Lookup(kArgQuery, "").StringValue
		    If query.Trim = "" Then Return ErrorResponse(id, kCodeInvalidParams, kMessageNoQuery)
		    text = Search(query, release)
		  Else
		    Return ErrorResponse(id, kCodeMethodNotFound, kMessageUnknownTool + name)
		  End Select

		  // A miss is a result, not an error: "nothing matched" is information the
		  // assistant can act on, whereas a JSON-RPC error tends to be surfaced to the
		  // user as a failure of the tool itself.
		  If text.Trim = "" Then text = kMessageNoMatch

		  Return SuccessResponse(id, ToolContent(text))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ToolContent(text As String) As Dictionary
		  Var block As New Dictionary
		  block.Value(kKeyType) = kTypeText
		  block.Value(kKeyText) = text

		  Var content() As Variant
		  content.Add(block)

		  Var result As New Dictionary
		  result.Value(kKeyContent) = content

		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Lookup(symbol As String, release As String) As String
		  // Overridden by whatever owns the documentation. The bridge deliberately
		  // knows no more than "text in, text out" so that the protocol layer can be
		  // exercised against curl before any doc set is wired to it.
		  #Pragma Unused symbol
		  #Pragma Unused release
		  Return ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Search(query As String, release As String) As String
		  #Pragma Unused query
		  #Pragma Unused release
		  Return ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DictionaryValue(source As Dictionary, key As String) As Dictionary
		  // JSON from a client we do not control: a value that should be an object may
		  // be a string, a number or absent, and casting it blind would raise.
		  If source = Nil Or Not source.HasKey(key) Then Return Nil

		  Try
		    Var nested As Dictionary = source.Value(key)
		    Return nested
		  Catch e As RuntimeException
		    Return Nil
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SuccessResponse(id As Variant, result As Dictionary) As String
		  Var response As New Dictionary
		  response.Value(kKeyJSONRPC) = kJSONRPCVersion
		  response.Value(kKeyId) = id
		  response.Value(kKeyResult) = result

		  Return Counted(GenerateJSON(response))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ErrorResponse(id As Variant, code As Integer, message As String) As String
		  Var failure As New Dictionary
		  failure.Value(kKeyCode) = code
		  failure.Value(kKeyMessage) = message

		  Var response As New Dictionary
		  response.Value(kKeyJSONRPC) = kJSONRPCVersion
		  response.Value(kKeyId) = id
		  response.Value(kKeyError) = failure

		  Return Counted(GenerateJSON(response))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Counted(payload As String) As String
		  // Both response builders funnel through here, so there is one place that can
		  // forget to count rather than one per Return.
		  CharactersOut = CharactersOut + payload.Length

		  Return payload
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function EstimatedTokensIn() As Integer
		  Return CharactersIn \ kCharactersPerToken
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function EstimatedTokensOut() As Integer
		  Return CharactersOut \ kCharactersPerToken
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ServerVersion() As String
		  // BugVersion, not SubVersion: SubVersion is what the .xojo_project file calls
		  // the third number, and App exposes it under a different name at runtime.
		  Return App.MajorVersion.ToString + kVersionSeparator + App.MinorVersion.ToString _
		    + kVersionSeparator + App.BugVersion.ToString
		End Function
	#tag EndMethod

	#tag Constant, Name = kCharactersPerToken, Type = Integer, Dynamic = False, Default = \"4", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kJSONRPCVersion, Type = String, Dynamic = False, Default = \"2.0", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kProtocolVersion, Type = String, Dynamic = False, Default = \"2024-11-05", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kServerName, Type = String, Dynamic = False, Default = \"better-xojo-help", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kVersionSeparator, Type = String, Dynamic = False, Default = \".", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyJSONRPC, Type = String, Dynamic = False, Default = \"jsonrpc", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyId, Type = String, Dynamic = False, Default = \"id", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyMethod, Type = String, Dynamic = False, Default = \"method", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyParams, Type = String, Dynamic = False, Default = \"params", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyResult, Type = String, Dynamic = False, Default = \"result", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyError, Type = String, Dynamic = False, Default = \"error", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyCode, Type = String, Dynamic = False, Default = \"code", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyMessage, Type = String, Dynamic = False, Default = \"message", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyProtocolVersion, Type = String, Dynamic = False, Default = \"protocolVersion", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyCapabilities, Type = String, Dynamic = False, Default = \"capabilities", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyServerInfo, Type = String, Dynamic = False, Default = \"serverInfo", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyTools, Type = String, Dynamic = False, Default = \"tools", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyName, Type = String, Dynamic = False, Default = \"name", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyVersion, Type = String, Dynamic = False, Default = \"version", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyDescription, Type = String, Dynamic = False, Default = \"description", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyInputSchema, Type = String, Dynamic = False, Default = \"inputSchema", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyType, Type = String, Dynamic = False, Default = \"type", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyProperties, Type = String, Dynamic = False, Default = \"properties", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyRequired, Type = String, Dynamic = False, Default = \"required", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyArguments, Type = String, Dynamic = False, Default = \"arguments", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyContent, Type = String, Dynamic = False, Default = \"content", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKeyText, Type = String, Dynamic = False, Default = \"text", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTypeString, Type = String, Dynamic = False, Default = \"string", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTypeObject, Type = String, Dynamic = False, Default = \"object", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTypeText, Type = String, Dynamic = False, Default = \"text", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMethodInitialize, Type = String, Dynamic = False, Default = \"initialize", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMethodToolsList, Type = String, Dynamic = False, Default = \"tools/list", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMethodToolsCall, Type = String, Dynamic = False, Default = \"tools/call", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMethodPing, Type = String, Dynamic = False, Default = \"ping", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kToolLookup, Type = String, Dynamic = False, Default = \"xojo_lookup", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kToolSearch, Type = String, Dynamic = False, Default = \"xojo_search", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kArgSymbol, Type = String, Dynamic = False, Default = \"symbol", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kArgQuery, Type = String, Dynamic = False, Default = \"query", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kArgVersion, Type = String, Dynamic = False, Default = \"version", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMessageParseError, Type = String, Dynamic = False, Default = \"The request body is not valid JSON.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMessageInvalidRequest, Type = String, Dynamic = False, Default = \"The request is not a JSON-RPC object.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMessageMethodNotFound, Type = String, Dynamic = False, Default = \"No such method: ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMessageUnknownTool, Type = String, Dynamic = False, Default = \"No such tool: ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMessageNoParams, Type = String, Dynamic = False, Default = \"This method needs a params object.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMessageNoSymbol, Type = String, Dynamic = False, Default = \"xojo_lookup needs a symbol\x2C for example DesktopListBox.AddRow", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMessageNoQuery, Type = String, Dynamic = False, Default = \"xojo_search needs a query.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMessageNoMatch, Type = String, Dynamic = False, Default = \"Nothing in the installed Xojo documentation matched.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kToolLookupDescription, Type = String, Dynamic = False, Default = \"Look up one Xojo class\x2C method\x2C property or event in the offline documentation installed on this machine\x2C and return its signature and description as plain text.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kToolSearchDescription, Type = String, Dynamic = False, Default = \"Search the offline Xojo documentation installed on this machine and return the matching class and member names\x2C most relevant first.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kArgSymbolDescription, Type = String, Dynamic = False, Default = \"The symbol to look up. A member is written Class.Member\x2C for example DesktopListBox.AddRow.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kArgQueryDescription, Type = String, Dynamic = False, Default = \"Words to search for. Several words are matched together\x2C in any order\x2C across titles and paths.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kArgVersionDescription, Type = String, Dynamic = False, Default = \"Optional Xojo release to read\x2C for example 2026r1.2. Defaults to the newest documentation installed.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCodeParseError, Type = Integer, Dynamic = False, Default = \"-32700", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCodeInvalidRequest, Type = Integer, Dynamic = False, Default = \"-32600", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCodeMethodNotFound, Type = Integer, Dynamic = False, Default = \"-32601", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCodeInvalidParams, Type = Integer, Dynamic = False, Default = \"-32602", Scope = Private
	#tag EndConstant

	#tag Property, Flags = &h0
		CharactersIn As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		CharactersOut As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Requests As Integer
	#tag EndProperty

	#tag Note, Name = Description
		JSON-RPC 2.0 for the MCP server: initialize, tools/list, tools/call and ping.

		It holds no documentation. Lookup and Search return empty here and are
		overridden by the subclass that owns a doc set, so the whole protocol layer can
		be exercised with curl before any documentation is wired to it — which matters
		in a project with no test suite, where the only other way to find a mistake is
		to attach a real MCP client and read its logs.

		Nothing here raises. Every input arrives from a client we do not control, so a
		malformed request comes back as a JSON-RPC error rather than as an exception
		that would take the listener down.
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.17.0
		Last change: 2026-07-29 16:02

		------------------------------------------------------------
		0.17.0 — 2026-07-29

		16:02  [NEW] Initial creation. Protocol version 2024-11-05. A request with no id returns "" so the socket answers 202 with no body, rather than sending a result to a notification.
	#tag EndNote

	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass

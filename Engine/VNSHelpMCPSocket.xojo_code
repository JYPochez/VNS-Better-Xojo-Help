#tag Class
Protected Class VNSHelpMCPSocket
Inherits TCPSocket
	#tag Event
		Sub DataAvailable()
		  // One HTTP request per connection, answered and closed.
		  //
		  // TCP does not deliver messages, it delivers bytes, so a request can arrive in
		  // pieces and this event can fire several times for one of them. Everything is
		  // accumulated and nothing is parsed until the headers are complete and the
		  // declared body has actually turned up.
		  // Second lock, independent of how the listener was bound. The server aims to
		  // listen on loopback alone, but that rests on Xojo's interface enumeration
		  // being right, and the first attempt at it silently opened the port on every
		  // interface. Checking who is actually connected does not.
		  If Not IsLocalPeer Then
		    mBuffer = ""
		    Me.Close
		    Return
		  End If

		  mBuffer = mBuffer + Me.ReadAll(Encodings.UTF8)

		  Var headerEnd As Integer = mBuffer.IndexOfBytes(0, kHeaderTerminator)
		  If headerEnd < 0 Then Return

		  Var headers As String = mBuffer.LeftBytes(headerEnd)
		  Var bodyStart As Integer = headerEnd + kHeaderTerminator.Bytes
		  Var declared As Integer = ContentLength(headers)

		  If mBuffer.Bytes - bodyStart < declared Then Return

		  Var body As String = mBuffer.MiddleBytes(bodyStart, declared)
		  mBuffer = ""

		  Respond(headers, body)
		End Sub
	#tag EndEvent

	#tag Event
		Sub SendComplete(userAborted As Boolean)
		  #Pragma Unused userAborted
		  // The response is out; now the connection can go. Connection: close was
		  // promised in the headers, and an MCP client opens a fresh one per request.
		  If mClosePending Then
		    mClosePending = False
		    Me.Close
		  End If
		End Sub
	#tag EndEvent

	#tag Event
		Sub Error(err As RuntimeException)
		  // A client that hangs up mid-request is ordinary, not exceptional: an MCP
		  // client is restarted whenever its host application is. Drop the connection
		  // and let the ServerSocket recycle it.
		  #Pragma Unused err
		  mBuffer = ""
		End Sub
	#tag EndEvent

	#tag Method, Flags = &h21
		Private Function IsLocalPeer() As Boolean
		  // Anything in 127/8, or the IPv6 loopback. An empty address is treated as
		  // local: it means the socket could not report a peer, and refusing every
		  // connection on a machine whose stack answers oddly would break the feature
		  // for no gain — the listener is still meant to be loopback-only.
		  Var peer As String = Me.RemoteAddress
		  If peer = "" Then Return True

		  If peer.BeginsWith(kLoopbackPrefix) Then Return True
		  If peer = kLoopbackV6 Then Return True
		  If peer = kLoopbackV6Mapped Then Return True

		  Return False
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Respond(headers As String, body As String)
		  // CORS preflight is answered without involving the bridge: a browser-based
		  // client sends OPTIONS before it will send anything else.
		  Var requestLine As String = headers
		  Var lineEnd As Integer = requestLine.IndexOfBytes(0, kCRLF)
		  If lineEnd >= 0 Then requestLine = requestLine.LeftBytes(lineEnd)

		  If requestLine.BeginsWith(kMethodOptions) Then
		    Send(kStatusNoContent, "", "")
		    Return
		  End If

		  // Anything that is not a POST carries no JSON-RPC. Answering with a plain
		  // 405 rather than an error object is deliberate: at that point there is no
		  // request id to answer, so a JSON-RPC error would be malformed.
		  If Not requestLine.BeginsWith(kMethodPost) Then
		    Send(kStatusMethodNotAllowed, kContentTypeText, kMessageUsePost)
		    Return
		  End If

		  If Bridge = Nil Then
		    Send(kStatusServerError, kContentTypeText, kMessageNoBridge)
		    Return
		  End If

		  // A notification has no id and therefore no reply. HTTP still needs one, so
		  // it gets 202 with an empty body, which is what the MCP spec asks for.
		  Var reply As String = Bridge.Respond(body)
		  If reply = "" Then
		    Send(kStatusAccepted, "", "")
		    Return
		  End If

		  Send(kStatusOK, kContentTypeJSON, reply)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Send(status As String, contentType As String, payload As String)
		  Var out As String = kHTTPVersion + " " + status + kCRLF

		  // Localhost only, but the header still has to be there: a client running in a
		  // browser page will not read the response without it.
		  out = out + kHeaderAllowOrigin + kCRLF
		  out = out + kHeaderAllowHeaders + kCRLF
		  out = out + kHeaderAllowMethods + kCRLF
		  If contentType <> "" Then out = out + kHeaderContentType + contentType + kCRLF

		  // Counted in bytes, not characters. A documentation excerpt carries accented
		  // text and typographic dashes, and a character count would truncate the body
		  // at the client.
		  out = out + kHeaderContentLength + payload.Bytes.ToString + kCRLF
		  out = out + kHeaderConnectionClose + kCRLF + kCRLF + payload

		  // Write, then close in SendComplete — never here. Close "resets the socket"
		  // and discards everything not yet sent, so closing straight after Write threw
		  // the response away: curl reported an empty reply from a server that had
		  // just built a correct one.
		  mClosePending = True
		  Me.Write(out)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ContentLength(headers As String) As Integer
		  // Zero when absent, which is correct for GET and OPTIONS.
		  Var lowered As String = headers.Lowercase
		  Var at As Integer = lowered.IndexOfBytes(0, kHeaderContentLengthLower)
		  If at < 0 Then Return 0

		  Var valueStart As Integer = at + kHeaderContentLengthLower.Bytes
		  Var lineEnd As Integer = headers.IndexOfBytes(valueStart, kCRLF)
		  If lineEnd < 0 Then lineEnd = headers.Bytes

		  Return headers.MiddleBytes(valueStart, lineEnd - valueStart).Trim.ToInteger
		End Function
	#tag EndMethod

	#tag Property, Flags = &h0
		Bridge As VNSHelpMCPBridge
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mBuffer As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mClosePending As Boolean
	#tag EndProperty

	#tag Constant, Name = kCRLF, Type = String, Dynamic = False, Default = \"\x0D\x0A", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHeaderTerminator, Type = String, Dynamic = False, Default = \"\x0D\x0A\x0D\x0A", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kLoopbackPrefix, Type = String, Dynamic = False, Default = \"127.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kLoopbackV6, Type = String, Dynamic = False, Default = \"::1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kLoopbackV6Mapped, Type = String, Dynamic = False, Default = \"::ffff:127.0.0.1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHTTPVersion, Type = String, Dynamic = False, Default = \"HTTP/1.1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMethodPost, Type = String, Dynamic = False, Default = \"POST", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMethodOptions, Type = String, Dynamic = False, Default = \"OPTIONS", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kStatusOK, Type = String, Dynamic = False, Default = \"200 OK", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kStatusAccepted, Type = String, Dynamic = False, Default = \"202 Accepted", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kStatusNoContent, Type = String, Dynamic = False, Default = \"204 No Content", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kStatusMethodNotAllowed, Type = String, Dynamic = False, Default = \"405 Method Not Allowed", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kStatusServerError, Type = String, Dynamic = False, Default = \"500 Internal Server Error", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kContentTypeJSON, Type = String, Dynamic = False, Default = \"application/json; charset\x3Dutf-8", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kContentTypeText, Type = String, Dynamic = False, Default = \"text/plain; charset\x3Dutf-8", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHeaderContentType, Type = String, Dynamic = False, Default = \"Content-Type: ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHeaderContentLength, Type = String, Dynamic = False, Default = \"Content-Length: ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHeaderContentLengthLower, Type = String, Dynamic = False, Default = \"content-length:", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHeaderConnectionClose, Type = String, Dynamic = False, Default = \"Connection: close", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHeaderAllowOrigin, Type = String, Dynamic = False, Default = \"Access-Control-Allow-Origin: *", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHeaderAllowHeaders, Type = String, Dynamic = False, Default = \"Access-Control-Allow-Headers: *", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHeaderAllowMethods, Type = String, Dynamic = False, Default = \"Access-Control-Allow-Methods: POST\x2C OPTIONS", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMessageUsePost, Type = String, Dynamic = False, Default = \"This endpoint speaks JSON-RPC over POST.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMessageNoBridge, Type = String, Dynamic = False, Default = \"The server has no documentation bridge attached.", Scope = Private
	#tag EndConstant

	#tag Note, Name = Description
		One HTTP connection for the MCP server. Xojo has no HTTP server class, so the
		protocol is handled here by hand: accumulate until the request is whole, hand
		the body to VNSHelpMCPBridge, write the reply and close.

		Deliberately minimal. It answers POST and OPTIONS and nothing else, because
		that is all MCP over HTTP needs, and a server that does less is a server with
		less to get wrong on a port the user has opened on their own machine.
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.17.0
		Last change: 2026-07-29 16:02

		------------------------------------------------------------
		0.17.0 — 2026-07-29

		16:02  [NEW] Initial creation. HTTP framing only — no JSON is parsed here, so the transport can be tested against curl before any MCP semantics exist.
	#tag EndNote

	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass

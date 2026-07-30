#tag Class
Protected Class VNSHelpMCPServer
Inherits ServerSocket
	#tag Event
		Function AddSocket() As TCPSocket
		  // ServerSocket asks for a socket whenever it wants one spare, not once per
		  // connection, so this must stay cheap and must not assume it is about to be
		  // used. Each one carries the bridge, because the socket itself knows nothing
		  // about documentation.
		  Var socket As New VNSHelpMCPSocket
		  socket.Bridge = Bridge

		  Return socket
		End Function
	#tag EndEvent

	#tag Event
		Sub Error(errorCode As Integer, err As RuntimeException)
		  #Pragma Unused err
		  // Remembered rather than raised. The window reads it to explain why the
		  // server did not start — a port already in use is the ordinary case, and it
		  // deserves a sentence in Settings, not a crash.
		  LastErrorCode = errorCode
		End Sub
	#tag EndEvent

	#tag Method, Flags = &h0
		Sub Constructor()
		  // No Super.Constructor: ServerSocket does not declare one.
		  //
		  // A documentation lookup is fast and infrequent — a handful of tool calls a
		  // minute from one client, not a web workload. Keeping a small pool costs
		  // nothing and avoids opening a listener wide on the user's machine.
		  Me.MaximumSocketsConnected = kMaximumConnections
		  Me.MinimumSocketsAvailable = kMinimumSpareSockets
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Start(onPort As Integer, docSetBridge As VNSHelpMCPBridge) As Boolean
		  // True when the listener came up. False leaves LastErrorCode explaining why.
		  If Me.IsListening Then Return True

		  LastErrorCode = 0
		  Bridge = docSetBridge

		  // 127.0.0.1 only, and it is not a setting. The port serves the machine's own
		  // documentation to a local assistant; binding it to a routable interface
		  // would publish it to the network for no benefit anyone has asked for.
		  // Refuse rather than fall back. Nil means "every interface" to ServerSocket,
		  // so a fallback here would put the documentation server on the local network
		  // silently — which is exactly what happened the first time this ran:
		  // lsof reported TCP *:8722 instead of 127.0.0.1:8722.
		  Var loopback As NetworkInterface = LoopbackInterface
		  If loopback = Nil Then
		    LastErrorCode = kErrorNoLoopback
		    Return False
		  End If

		  Me.NetworkInterface = loopback
		  Me.Port = onPort

		  Try
		    Me.Listen
		  Catch e As RuntimeException
		    LastErrorCode = kErrorCouldNotListen
		    Return False
		  End Try

		  Return LastErrorCode = 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Stop()
		  If Me.IsListening Then Me.StopListening

		  // Sockets already handed out are not closed by StopListening, so a client
		  // mid-request would otherwise keep a connection alive after the user
		  // switched the server off in Settings.
		  For Each connection As TCPSocket In Me.ActiveConnections
		    If connection <> Nil Then connection.Close
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function LoopbackInterface() As NetworkInterface
		  // NetworkInterface.Loopback is shared and hands back the loopback interface
		  // outright, so there is nothing to search. Two earlier attempts walked
		  // System.NetworkInterface instead: the first matched on IPAddress and found
		  // nothing on macOS, the one before that fell back to Nil and opened the port
		  // on every interface.
		  Var loopback As NetworkInterface = NetworkInterface.Loopback
		  If loopback <> Nil Then Return loopback

		  // Fallback for a stack where that comes back empty. Any 127.x address counts:
		  // the whole /8 is loopback.
		  For i As Integer = 0 To System.NetworkInterfaceCount - 1
		    Var candidate As NetworkInterface = System.NetworkInterface(i)
		    If candidate = Nil Then Continue
		    If candidate.IPAddress = kLoopbackAddress Then Return candidate
		    If candidate.IPAddress.BeginsWith(kLoopbackPrefix) Then Return candidate
		  Next

		  // Nil is handled by the caller as a refusal to listen, never as a fallback:
		  // Nil means "every interface" to ServerSocket.
		  Return Nil
		End Function
	#tag EndMethod

	#tag Property, Flags = &h0
		Bridge As VNSHelpMCPBridge
	#tag EndProperty

	#tag Property, Flags = &h0
		LastErrorCode As Integer
	#tag EndProperty

	#tag Constant, Name = kLoopbackAddress, Type = String, Dynamic = False, Default = \"127.0.0.1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kLoopbackPrefix, Type = String, Dynamic = False, Default = \"127.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kErrorNoLoopback, Type = Integer, Dynamic = False, Default = \"-2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kDefaultPort, Type = Integer, Dynamic = False, Default = \"8722", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kMaximumConnections, Type = Integer, Dynamic = False, Default = \"8", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMinimumSpareSockets, Type = Integer, Dynamic = False, Default = \"2", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kErrorCouldNotListen, Type = Integer, Dynamic = False, Default = \"-1", Scope = Public
	#tag EndConstant

	#tag Note, Name = Description
		The MCP server's listener. Binds to 127.0.0.1 only — deliberately not a
		setting, since the point is to serve this machine's own documentation to an
		assistant running on it.

		It only listens while the app is running. That was raised with the user and
		accepted (P8-6): the alternative was a separate stdio helper binary reading the
		same doc sets, which is a second thing to sign, notarise and keep in step.
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.17.0
		Last change: 2026-07-29 16:02

		------------------------------------------------------------
		0.17.0 — 2026-07-29

		16:02  [NEW] Initial creation. Start returns a Boolean and records LastErrorCode rather than raising, because "port already in use" is an ordinary outcome the settings window has to explain.
	#tag EndNote

	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass

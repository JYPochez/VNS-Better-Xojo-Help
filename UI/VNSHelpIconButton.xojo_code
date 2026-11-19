#tag Class
Protected Class VNSHelpIconButton
Inherits DesktopCanvas
	#tag Event
		Function MouseDown(x As Integer, y As Integer) As Boolean
		  #Pragma Unused x
		  #Pragma Unused y

		  If Not Me.Enabled Then Return False

		  mPressed = True
		  mInside = True
		  Me.Refresh

		  // Claiming the click is what delivers MouseDrag and MouseUp to this control.
		  Return True
		End Function
	#tag EndEvent

	#tag Event
		Sub MouseDrag(x As Integer, y As Integer)
		  // Like a native button: dragging off it releases the pressed look, and back
		  // on restores it, so letting go outside cancels the press.
		  Var inside As Boolean = Contains(x, y)
		  If inside = mInside Then Return

		  mInside = inside
		  Me.Refresh
		End Sub
	#tag EndEvent

	#tag Event
		Sub MouseUp(x As Integer, y As Integer)
		  Var released As Boolean = mPressed And Contains(x, y)

		  mPressed = False
		  mInside = False
		  Me.Refresh

		  If released And Me.Enabled Then RaiseEvent Pressed
		End Sub
	#tag EndEvent

	#tag Event
		Sub Paint(g As Graphics, areas() As Rect)
		  #Pragma Unused areas

		  // Drawn here because DesktopBevelButton paints a light face in dark mode on
		  // macOS whatever its style, and its BackgroundColor applies only on Windows
		  // and Linux. Read at paint time, so a repaint is all an appearance change needs.
		  Var dark As Boolean = Color.IsDarkMode

		  If mPressed And mInside Then
		    g.DrawingColor = If(dark, kFacePressedDark, kFacePressedLight)
		  Else
		    g.DrawingColor = If(dark, kFaceDark, kFaceLight)
		  End If
		  g.FillRoundRectangle(0, 0, g.Width, g.Height, kCorner, kCorner)

		  g.DrawingColor = If(dark, kBorderDark, kBorderLight)
		  g.DrawRoundRectangle(0, 0, g.Width, g.Height, kCorner, kCorner)

		  If Not Me.Enabled Then g.Transparency = kDisabledTransparency

		  // A caption, when set, replaces the icon — the copy button shows a tick that way.
		  If mCaption <> "" Then
		    // Not Color.TextColor, which stays black in dark mode (2026r3.1).
		    g.DrawingColor = If(dark, kTextDark, kTextLight)
		    Var textLeft As Double = (g.Width - g.TextWidth(mCaption)) / 2
		    Var baseline As Double = (g.Height + g.FontAscent) / 2 - kBaselineLift
		    g.DrawText(mCaption, textLeft, baseline)
		  ElseIf mIcon <> Nil Then
		    // Whole points, so the icon is not resampled onto half pixels.
		    g.DrawPicture(mIcon, (g.Width - mIcon.Width) \ 2, (g.Height - mIcon.Height) \ 2)
		  End If
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Function Contains(x As Integer, y As Integer) As Boolean
		  Return x >= 0 And y >= 0 And x < Me.Width And y < Me.Height
		End Function
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event Pressed()
	#tag EndHook


	#tag Note, Name = Description
		An icon button drawn on a canvas, for the toolbar and the text size buttons.

		It exists because DesktopBevelButton on macOS paints a light face in dark mode,
		with every bevel style, so a white icon on it is invisible and a dark one sits on
		a glaring white square. This one paints its own face for each appearance, a
		pressed state, and a dimmed look when disabled, and raises Pressed when a click
		is released inside it.

		The canvas does not repaint when Enabled changes, so a caller that toggles
		Enabled calls Refresh afterwards.
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.21.0
		Last change: 2026-11-19 19:13

		------------------------------------------------------------
		0.21.0 — 2026-11-19

		19:13  [NEW] Initial creation, replacing the seven DesktopBevelButtons of the main window, which stayed white in dark mode.
	#tag EndNote


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mIcon
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mIcon = value
			  Me.Refresh
			End Set
		#tag EndSetter
		Icon As Picture
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mCaption
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mCaption = value
			  Me.Refresh
			End Set
		#tag EndSetter
		Caption As String
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mCaption As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mIcon As Picture
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mInside As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPressed As Boolean
	#tag EndProperty


	#tag Constant, Name = kCorner, Type = Double, Dynamic = False, Default = \"5", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kBaselineLift, Type = Double, Dynamic = False, Default = \"1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kDisabledTransparency, Type = Double, Dynamic = False, Default = \"65", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTextLight, Type = Color, Dynamic = False, Default = \"&c222222", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTextDark, Type = Color, Dynamic = False, Default = \"&cE5E5E7", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFaceLight, Type = Color, Dynamic = False, Default = \"&cFFFFFF", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFacePressedLight, Type = Color, Dynamic = False, Default = \"&cDCDCDC", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kBorderLight, Type = Color, Dynamic = False, Default = \"&cC2C2C2", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFaceDark, Type = Color, Dynamic = False, Default = \"&c48484A", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFacePressedDark, Type = Color, Dynamic = False, Default = \"&c636366", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kBorderDark, Type = Color, Dynamic = False, Default = \"&c5E5E62", Scope = Private
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="Integer"
			EditorType="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Width"
			Visible=true
			Group="Position"
			InitialValue="22"
			Type="Integer"
			EditorType="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Height"
			Visible=true
			Group="Position"
			InitialValue="22"
			Type="Integer"
			EditorType="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockLeft"
			Visible=true
			Group="Position"
			InitialValue="False"
			Type="Boolean"
			EditorType="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockTop"
			Visible=true
			Group="Position"
			InitialValue="True"
			Type="Boolean"
			EditorType="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockRight"
			Visible=true
			Group="Position"
			InitialValue="False"
			Type="Boolean"
			EditorType="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockBottom"
			Visible=true
			Group="Position"
			InitialValue="True"
			Type="Boolean"
			EditorType="Boolean"
		#tag EndViewProperty
#tag EndViewBehavior
End Class
#tag EndClass

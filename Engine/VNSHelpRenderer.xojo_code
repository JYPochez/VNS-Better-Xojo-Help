#tag Module
Protected Module VNSHelpRenderer
	#tag Method, Flags = &h0
		Function Wrap(fragment As String, extraStyle As String) As String
		  // Build a complete page around an article fragment.
		  //
		  // Both documentation eras hand us a bare HTML fragment, so one shell
		  // serves both. Nothing outside the page is referenced, which is what
		  // keeps the reader instant and usable with no network.
		  Var page As String = kReaderShell
		  page = page.ReplaceAll(kTokenExtraStyle, extraStyle)

		  // Content is substituted last so its text is never rescanned for tokens.
		  page = page.ReplaceAll(kTokenContent, fragment)

		  Return page
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OverviewFragment(title As String, topics() As VNSHelpTopic) As String
		  // An index page for a branch of the tree, so selecting a row that has
		  // children shows what is inside it instead of doing nothing.
		  //
		  // Each entry links to its position in the list rather than to its page
		  // key. Keys contain "#" and other characters that would have to be
		  // percent-encoded to survive in a URL; an index needs no encoding at all
		  // and cannot be mangled. The window resolves it back through the same
		  // array it passed in.
		  Var items() As String

		  For i As Integer = 0 To topics.LastIndex
		    Var topic As VNSHelpTopic = topics(i)

		    Var itemClass As String = kClassPage
		    If topic.Kind = VNSHelpTopic.eKind.Group Then itemClass = kClassGroup

		    Var item As String = kOverviewItem
		    item = item.ReplaceAll(kTokenClass, itemClass)
		    item = item.ReplaceAll(kTokenIndex, i.ToString)
		    item = item.ReplaceAll(kTokenLabel, EscapeHTML(topic.Title))
		    items.Add(item)
		  Next

		  // Count via topics.Count rather than LastIndex + 1: a method cannot be
		  // called on a parenthesised expression, so (topics.LastIndex + 1).ToString
		  // does not compile.
		  Var total As Integer = topics.Count

		  Var count As String = kCountNone
		  If total = 1 Then
		    count = kCountOne
		  ElseIf total > 1 Then
		    count = total.ToString + kCountMany
		  End If

		  Var page As String = kOverviewShell
		  page = page.ReplaceAll(kTokenTitle, EscapeHTML(title))
		  page = page.ReplaceAll(kTokenCount, count)

		  // Items last, so their text is never rescanned for tokens.
		  Return page.ReplaceAll(kTokenItems, String.FromArray(items, ""))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function EscapeHTML(value As String) As String
		  // Titles come from the documentation and can carry & or angle brackets.
		  Var escaped As String = value.ReplaceAll(kAmpersand, kEntityAmpersand)
		  escaped = escaped.ReplaceAll(kLessThan, kEntityLessThan)
		  escaped = escaped.ReplaceAll(kGreaterThan, kEntityGreaterThan)
		  Return escaped
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function WriteToFile(page As String, folder As FolderItem) As FolderItem
		  // Write the finished page into the folder holding its images and return
		  // the file, so the viewer can be given a real document rather than a
		  // string.
		  //
		  // LoadPage(source, base) does not grant the page access to neighbouring
		  // files — the web inspector shows the request reaching the right URL and
		  // being refused anyway. VNSHelpWindow in VNS Structure Editor v2 renders
		  // its images by loading an actual file with LoadPage(FolderItem), which
		  // is the arrangement reproduced here.
		  If folder = Nil Or Not folder.Exists Then Return Nil

		  Var target As FolderItem = folder.Child(kRenderedPageName)
		  If target = Nil Then Return Nil

		  Var stream As TextOutputStream
		  Try
		    stream = TextOutputStream.Create(target)

		    // The shell declares UTF-8, so the bytes written must be UTF-8 too.
		    stream.Encoding = Encodings.UTF8
		    stream.Write(page)
		  Catch e As IOException
		    Return Nil
		  Finally
		    If stream <> Nil Then stream.Close
		  End Try

		  Return target
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HighlightScript(terms() As String, scrollToFirst As Boolean) As String
		  // JavaScript that marks every occurrence of every term and scrolls to the
		  // first. Each is escaped for a JavaScript string literal, since unlike a
		  // section anchor these are arbitrary text typed by the user.
		  //
		  // All of them go into one array so the script can build a single alternation:
		  // running it once per term would rescan text the previous run had already
		  // wrapped in a mark.
		  Var quoted() As String
		  For Each term As String In terms
		    If term <> "" Then quoted.Add(kQuote + EscapeForJavaScript(term) + kQuote)
		  Next

		  Var script As String = kHighlightScript.ReplaceAll(kTokenTerms, _
		    String.FromArray(quoted, kTermSeparator))

		  Var flag As String = kJavaScriptFalse
		  If scrollToFirst Then flag = kJavaScriptTrue

		  Return script.ReplaceAll(kTokenScroll, flag)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function EscapeForJavaScript(value As String) As String
		  // Make arbitrary text safe inside a double-quoted JavaScript literal.
		  //
		  // The term is the user's own typing in a local app, so this is not a
		  // privilege boundary — but an unescaped quote or backslash would break the
		  // script outright, so completeness here is a correctness matter.
		  //
		  // Backslash must go first, or it would double the backslashes this method
		  // introduces afterwards.
		  Var escaped As String = value.ReplaceAll(kBackslash, kBackslash + kBackslash)
		  escaped = escaped.ReplaceAll(kQuote, kBackslash + kQuote)

		  // U+2028 and U+2029 terminate a line in older JavaScript parsers even
		  // inside a string literal.
		  escaped = escaped.ReplaceAll(Encodings.UTF8.Chr(kLineSeparator), kEscapedLineSeparator)
		  escaped = escaped.ReplaceAll(Encodings.UTF8.Chr(kParagraphSeparator), kEscapedParagraphSeparator)

		  escaped = escaped.ReplaceAll(EndOfLine, kSpace)

		  // Defence in depth: harmless now because the script is handed to
		  // ExecuteJavaScript, but it would close a surrounding <script> element if
		  // this were ever inlined into a page instead.
		  Return escaped.ReplaceAll(kCloseTagStart, kEscapedCloseTagStart)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ScrollScript(anchor As String) As String
		  // JavaScript that scrolls the loaded page to a section anchor.
		  Return kScrollScript.ReplaceAll(kTokenAnchor, anchor)
		End Function
	#tag EndMethod

	#tag Constant, Name = kTokenExtraStyle, Type = String, Dynamic = False, Default = \"{{EXTRA_CSS}}", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTokenContent, Type = String, Dynamic = False, Default = \"{{CONTENT}}", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTokenAnchor, Type = String, Dynamic = False, Default = \"{{ANCHOR}}", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kRenderedPageName, Type = String, Dynamic = False, Default = \"page.html", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHighlightScript, Type = String, Dynamic = False, Default = \"// Highlight every occurrence of the search term in the loaded page and scroll\n// to the first one. Ported from HighlightSearch in VNSHelpWindow (VNS Structure\n// Editor v2)\x2C which runs in the same WKWebView.\n(function () {\n  // Every term at once\x2C as one alternation\x2C rather than one run per term:\n  // running twice would rescan text that the first run had already wrapped in a\n  // mark\x2C so \"list\" then \"listbox\" would leave the second split across nodes.\n  var terms \x3D [{{TERMS}}];\n  if (!terms.length) { return; }\n\n  // Whether to scroll to the first match. A member hit already has an anchor to\n  // scroll to\x2C and its first mark is usually the class name at the top of the\n  // page\x2C so scrolling here would undo it.\n  var scrollToFirst \x3D {{SCROLL}};\n\n  if (!document.getElementById(\"bxh-hlstyle\")) {\n    var style \x3D document.createElement(\"style\");\n    style.id \x3D \"bxh-hlstyle\";\n    style.textContent \x3D \"mark.bxhl{background:#ffe45e;color:inherit;border-radius:2px;padding:0 1px}\";\n    document.head.appendChild(style);\n  }\n\n  // Undo any previous run before marking again.\n  document.querySelectorAll(\"mark.bxhl\").forEach(function (m) {\n    var parent \x3D m.parentNode;\n    if (parent) {\n      parent.replaceChild(document.createTextNode(m.textContent)\x2C m);\n      parent.normalize();\n    }\n  });\n\n  var pattern \x3D new RegExp(terms.map(function (t) {\n    return t.replace(/[.*+?^${}()|[\\]\\\\]/g\x2C \"\\\\$&\");\n  }).join(\"|\")\x2C \"gi\");\n  var walker \x3D document.createTreeWalker(document.body\x2C NodeFilter.SHOW_TEXT\x2C null);\n  var nodes \x3D []\x2C node;\n  while ((node \x3D walker.nextNode())) {\n    var parent \x3D node.parentNode;\n    if (!parent) { continue; }\n    var tag \x3D parent.nodeName.toLowerCase();\n    if (tag \x3D\x3D\x3D \"script\" || tag \x3D\x3D\x3D \"style\" || tag \x3D\x3D\x3D \"mark\") { continue; }\n    pattern.lastIndex \x3D 0;\n    if (pattern.test(node.nodeValue)) { nodes.push(node); }\n  }\n\n  nodes.forEach(function (n) {\n    var span \x3D document.createElement(\"span\");\n    var escaped \x3D n.nodeValue.replace(/&/g\x2C \"&amp;\").replace(/</g\x2C \"&lt;\").replace(/>/g\x2C \"&gt;\");\n    span.innerHTML \x3D escaped.replace(pattern\x2C function (m) { return \"<mark class\x3D\\\"bxhl\\\">\" + m + \"</mark>\"; });\n    n.parentNode.replaceChild(span\x2C n);\n  });\n\n  if (scrollToFirst) {\n    var first \x3D document.querySelector(\"mark.bxhl\");\n    if (first) { first.scrollIntoView({ block: \"center\" }); }\n  }\n})();\n", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTermSeparator, Type = String, Dynamic = False, Default = \"\x2C ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTokenScroll, Type = String, Dynamic = False, Default = \"{{SCROLL}}", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kJavaScriptTrue, Type = String, Dynamic = False, Default = \"true", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kJavaScriptFalse, Type = String, Dynamic = False, Default = \"false", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTokenTerms, Type = String, Dynamic = False, Default = \"{{TERMS}}", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kLineSeparator, Type = Integer, Dynamic = False, Default = \"8232", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kParagraphSeparator, Type = Integer, Dynamic = False, Default = \"8233", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kEscapedLineSeparator, Type = String, Dynamic = False, Default = \"\\u2028", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kEscapedParagraphSeparator, Type = String, Dynamic = False, Default = \"\\u2029", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCloseTagStart, Type = String, Dynamic = False, Default = \"</", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kEscapedCloseTagStart, Type = String, Dynamic = False, Default = \"<\\/", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kBackslash, Type = String, Dynamic = False, Default = \"\\", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kQuote, Type = String, Dynamic = False, Default = \"\"", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSpace, Type = String, Dynamic = False, Default = \" ", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTokenTitle, Type = String, Dynamic = False, Default = \"{{TITLE}}", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTokenCount, Type = String, Dynamic = False, Default = \"{{COUNT}}", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTokenItems, Type = String, Dynamic = False, Default = \"{{ITEMS}}", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTokenClass, Type = String, Dynamic = False, Default = \"{{CLASS}}", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTokenIndex, Type = String, Dynamic = False, Default = \"{{INDEX}}", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kTokenLabel, Type = String, Dynamic = False, Default = \"{{LABEL}}", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kClassPage, Type = String, Dynamic = False, Default = \"bxh-page", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kClassGroup, Type = String, Dynamic = False, Default = \"bxh-group", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCountNone, Type = String, Dynamic = False, Default = \"Nothing in here.", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCountOne, Type = String, Dynamic = False, Default = \"1 entry", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCountMany, Type = String, Dynamic = False, Default = \" entries", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kAmpersand, Type = String, Dynamic = False, Default = \"&", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kLessThan, Type = String, Dynamic = False, Default = \"<", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kGreaterThan, Type = String, Dynamic = False, Default = \">", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kEntityAmpersand, Type = String, Dynamic = False, Default = \"&amp;", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kEntityLessThan, Type = String, Dynamic = False, Default = \"&lt;", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kEntityGreaterThan, Type = String, Dynamic = False, Default = \"&gt;", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kOverviewShell, Type = String, Dynamic = False, Default = \"<h1>{{TITLE}}</h1>\n<p class\x3D\"bxh-count\">{{COUNT}}</p>\n<ul class\x3D\"bxh-index\">{{ITEMS}}</ul>\n", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kOverviewItem, Type = String, Dynamic = False, Default = \"<li class\x3D\"{{CLASS}}\"><a href\x3D\"bxh:{{INDEX}}\">{{LABEL}}</a></li>\n", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kReaderShell, Type = String, Dynamic = False, Default = \"<!DOCTYPE html>\n<html>\n<head>\n<meta charset\x3D\"utf-8\">\n<style>\n/* Reader stylesheet. The Read-the-Docs chrome is stripped before this is\n   applied\x2C so only the article body is styled here. House style follows\n   VNSHelpWindow in VNS Structure Editor v2. */\n\nbody {\n  font-family: -apple-system\x2C BlinkMacSystemFont\x2C \"Segoe UI\"\x2C Helvetica\x2C Arial\x2C sans-serif;\n  font-size: 14px;\n  line-height: 1.6;\n  color: #222;\n  margin: 22px 26px;\n  max-width: 64em;\n}\n\n/* Sphinx leaves search-only text in the markup and collapses it in its own\n   theme. Without this a single API page shows ~166 stray fragments. */\n.forsearch { display: none; }\n\nh1 { font-size: 20px; margin: 0 0 14px; }\nh2 {\n  font-size: 15px;\n  color: #0a7a4b;\n  border-bottom: 1px solid #e2e2e2;\n  padding-bottom: 4px;\n  margin: 26px 0 10px;\n}\nh3 { font-size: 13.5px; color: #0a7a4b; margin: 20px 0 8px; }\nh4\x2C h5\x2C h6 { font-size: 13px; margin: 16px 0 6px; }\n\np { margin: 0 0 10px; }\n\n/* Sphinx wraps most descriptions in a blockquote; the default indent and\n   styling would make every paragraph look like a quotation. */\nblockquote { margin: 0 0 10px; padding: 0; border: 0; font-style: normal; }\n\na { color: #0b66c3; text-decoration: none; }\na:hover { text-decoration: underline; }\n\n/* Links that leave the documentation\x2C marked the way Xojo\'s own pages mark\n   them. The scheme is what identifies one: an internal link is rewritten to\n   bxh:<n> and an external one to bxhweb:<n>\x2C so this needs neither a class on\n   the anchor nor a second pass over the markup. See\n   VNSHelpDocSet.ExternalLinkHref. */\na[href^\x3D\"bxhweb:\"]::after {\n  content: \"\\2197\";\n  font-size: 0.85em;\n  color: #888;\n  margin-left: 2px;\n}\n\n/* Except inside a code sample\x2C where an anchor is a keyword rather than a\n   reference and must not grow an arrow. */\n.codesnippet a[href^\x3D\"bxhweb:\"]::after\x2C\npre a[href^\x3D\"bxhweb:\"]::after {\n  content: none;\n}\n\n/* Member signatures */\ndl { margin: 0 0 12px; }\ndt {\n  font-family: ui-monospace\x2C SFMono-Regular\x2C Menlo\x2C Consolas\x2C monospace;\n  font-weight: 600;\n  color: #0b66c3;\n  margin-top: 12px;\n}\ndd { margin: 4px 0 10px 18px; }\n\ncode\x2C tt {\n  font-family: ui-monospace\x2C SFMono-Regular\x2C Menlo\x2C Consolas\x2C monospace;\n  font-size: 12.5px;\n  background: #f6f6f8;\n  border: 1px solid #ececf0;\n  border-radius: 3px;\n  padding: 0 3px;\n}\npre {\n  font-family: ui-monospace\x2C SFMono-Regular\x2C Menlo\x2C Consolas\x2C monospace;\n  font-size: 12.5px;\n  line-height: 1.45;\n  background: #f6f6f8;\n  border: 1px solid #ececf0;\n  border-radius: 5px;\n  padding: 10px 12px;\n  overflow-x: auto;\n}\npre code\x2C pre tt\x2C .highlight code {\n  background: none;\n  border: 0;\n  padding: 0;\n  font-size: inherit;\n}\n\n/* Wide API tables scroll on their own rather than stretching the page. */\ntable {\n  border-collapse: collapse;\n  margin: 0 0 14px;\n  display: block;\n  overflow-x: auto;\n  max-width: 100%;\n}\nth\x2C td {\n  border: 1px solid #e2e2e2;\n  padding: 5px 8px;\n  text-align: left;\n  vertical-align: top;\n}\nth { background: #f6f6f8; font-weight: 600; }\ntr.row-odd td { background: #fbfbfc; }\n\nimg { max-width: 100%; height: auto; }\nhr { border: 0; border-top: 1px solid #ececf0; margin: 18px 0; }\n\n.admonition {\n  border: 1px solid #f0e0a0;\n  background: #fff8e1;\n  border-radius: 5px;\n  padding: 8px 12px;\n  margin: 0 0 12px;\n}\n.admonition-title { font-weight: 600; margin: 0 0 4px; }\n.admonition.warning\x2C .admonition.danger\x2C .admonition.error {\n  background: #fdecea;\n  border-color: #f5b5ad;\n}\n\n/* Generated index page\x2C shown when a tree row with children is selected. */\np.bxh-count { color: #777; font-size: 12.5px; margin: 0 0 14px; }\nul.bxh-index { list-style: none; margin: 0; padding: 0; columns: 2; column-gap: 28px; }\nul.bxh-index li { margin: 0 0 4px; break-inside: avoid; }\nul.bxh-index li.bxh-group > a { font-weight: 600; }\nul.bxh-index li.bxh-group > a::after { content: \" \\25B8\"; color: #999; }\n\n/* Copy button on every code pane\x2C added by the script below. */\n.bxh-codehost { position: relative; }\n.bxh-codehost > pre { padding-right: 64px; }\n.bxh-copy {\n  position: absolute;\n  top: 5px;\n  right: 6px;\n  font-family: -apple-system\x2C BlinkMacSystemFont\x2C \"Segoe UI\"\x2C Helvetica\x2C Arial\x2C sans-serif;\n  font-size: 11px;\n  line-height: 1.4;\n  padding: 1px 8px;\n  border: 1px solid #cfd6e0;\n  background: #fff;\n  border-radius: 5px;\n  color: #0b66c3;\n  cursor: pointer;\n}\n.bxh-copy:hover { background: #eef3fb; }\n.bxh-copy:active { background: #dce7f7; }\n</style>\n<style>\n/* Syntax colouring\x2C taken from the documentation set being read so code\n   samples look the way that release rendered them. */\n{{EXTRA_CSS}}\n</style>\n</head>\n<body>\n{{CONTENT}}\n<script>\n// Add a Copy button to the top-right of every code pane.\n//\n// The clipboard API is not always available on a file:// page in WKWebView\x2C\n// so this keeps the execCommand fallback used by the VNS Structure Editor\n// help window\x2C which runs in the same environment.\n(function () {\n  function copyText(pre\x2C button) {\n    var text \x3D pre.innerText;\n    if (navigator.clipboard && navigator.clipboard.writeText) {\n      navigator.clipboard.writeText(text);\n    } else {\n      var range \x3D document.createRange();\n      range.selectNodeContents(pre);\n      var selection \x3D getSelection();\n      selection.removeAllRanges();\n      selection.addRange(range);\n      try { document.execCommand(\"copy\"); } catch (e) {}\n      selection.removeAllRanges();\n    }\n    var original \x3D button.textContent;\n    button.textContent \x3D \"Copied\";\n    setTimeout(function () { button.textContent \x3D original; }\x2C 1200);\n  }\n\n  function addButton(host\x2C source) {\n    if (host.getAttribute(\"data-bxh-copy\")) { return; }\n    host.setAttribute(\"data-bxh-copy\"\x2C \"1\");\n    host.className \x3D (host.className || \"\") + \" bxh-codehost\";\n\n    var button \x3D document.createElement(\"button\");\n    button.type \x3D \"button\";\n    button.className \x3D \"bxh-copy\";\n    button.textContent \x3D \"Copy\";\n    button.addEventListener(\"click\"\x2C (function (s\x2C b) {\n      return function () { copyText(s\x2C b); };\n    })(source\x2C button));\n    host.appendChild(button);\n  }\n\n  // Sphinx pages put samples in <pre>; the legacy MediaWiki pages use\n  // div.codesnippet instead\x2C so both are handled.\n  var panes \x3D document.querySelectorAll(\"pre\");\n  for (var i \x3D 0; i < panes.length; i++) {\n    var pre \x3D panes[i];\n    var host \x3D pre.parentNode;\n    if (!host) { continue; }\n\n    // Sphinx already wraps code in div.highlight; anything else gets its own\n    // wrapper so the button has something to position against.\n    if ((host.className || \"\").indexOf(\"highlight\") < 0) {\n      var wrapper \x3D document.createElement(\"div\");\n      host.insertBefore(wrapper\x2C pre);\n      wrapper.appendChild(pre);\n      host \x3D wrapper;\n    }\n    addButton(host\x2C pre);\n  }\n\n  var snippets \x3D document.querySelectorAll(\"div.codesnippet\x2C table.codesnippet\");\n  for (var j \x3D 0; j < snippets.length; j++) {\n    // The snippet element is its own host: it already has a border and padding\x2C\n    // so wrapping it would only add a second box.\n    addButton(snippets[j]\x2C snippets[j]);\n  }\n})();\n</script>\n</body>\n</html>\n", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kScrollScript, Type = String, Dynamic = False, Default = \"// Scroll the reader to a section anchor after the page finishes loading.\n// The anchor is a Sphinx slug (letters\x2C digits and hyphens)\x2C so it is safe to\n// inline. An unknown anchor scrolls to the top rather than doing nothing.\n(function () {\n  var id \x3D \"{{ANCHOR}}\";\n  if (!id) {\n    window.scrollTo(0\x2C 0);\n    return;\n  }\n  var el \x3D document.getElementById(id);\n  if (el) {\n    el.scrollIntoView(true);\n  } else {\n    window.scrollTo(0\x2C 0);\n  }\n})();\n", Scope = Private
	#tag EndConstant

	#tag Note, Name = Description
		Turns an article fragment into a finished page for the viewer.

		kReaderShell and kScrollScript are generated from tools/help-reader-shell.html
		and tools/scroll-to-anchor.js by sync_xojo_constant.py — do not hand-edit the
		escaped constants. Run, from the tools folder:

		python3 ~/.claude/xojo_tools/sync_xojo_constant.py sync xojo_sync.json
	#tag EndNote

	#tag Note, Name = Version
		Version: 0.12.2
		Last change: 2026-07-29 10:50

		------------------------------------------------------------
		0.12.2 — 2026-07-29

		10:50  [FIX] HighlightScript takes scrollToFirst. It used to scroll to its own first match unconditionally, which for a member hit is the class name at the top of the page — so it silently undid the scroll to the member the page was opened for.

		------------------------------------------------------------
		0.9.0 — 2026-07-25

		18:20  [BREAKING] HighlightScript takes terms() rather than one term, and the script builds a single alternation from them. Running it once per term would rescan text the previous run had already wrapped in a mark, so "list" then "listbox" would leave the second split across nodes.

		------------------------------------------------------------
		0.8.3 — 2026-07-25

		17:04  [NEW] kReaderShell marks links that leave the documentation with a small arrow, as Xojo's own pages do. Selected purely by href prefix, and suppressed inside code samples where an anchor is a keyword rather than a reference. Generated from tools/help-reader-shell.html.

		------------------------------------------------------------
		0.3.0 — 2026-07-24

		23:29  [NEW] Initial creation — Wrap and ScrollScript over generated constants.
	#tag EndNote

	#tag ViewBehavior
	#tag EndViewBehavior
End Module
#tag EndModule

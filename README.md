# Better Xojo Help

Every set of Xojo offline documentation installed on your machine, browsable from one window.

![Better Xojo Help](screenshots/main-window.png?v=2)

Xojo ships documentation with each release, but the IDE only reaches the docs of the version it
belongs to, and the older releases store theirs in a format nothing opens any more. This reads all of
them — 30 releases on the machine it was built on — and lets you switch between them from a popup.

**The reason I wrote it was search.** Finding the exact thing you are after in Xojo's own help is
harder than it should be: you know the class and you know roughly what the method is called, and you
still end up scrolling. Here you type `list add`, pick `and`, and get the seven `DesktopListBox`
members that match — deprecated ones pushed to the bottom, not the top.

And it is **fast**. There is no index to build on first run — both documentation formats already ship
one, and the app reads them where they are — so results appear as you type.

Nothing leaves your machine, and nothing is written outside the app's own folder. Your Xojo
installation is only ever read.

### The difference a second word makes

`list` on 2026r1.2 — 200 results, which is the cap, and you are back to scrolling:

![Searching for one word](screenshots/search-one-word.png?v=2)

`list add`, still on `and` — 24, with every `DesktopListBox` member that adds a row at the top and
everything deprecated pushed to the bottom:

![Searching for two words](screenshots/search-two-words.png?v=2)

Both terms are highlighted throughout the page, and the result count sits above the list.

## What it does

- **Browses every installed release** from one window, opening on the newest.
- **Searches titles, paths and members**, ranked by how often the term actually appears in the page.
  On 2026r1.2 that is 15 502 members that page-level search cannot see, because in the modern
  documentation only a *deprecated* member gets a page of its own — a live one like
  `DesktopListBox.AddRow` is a section inside its class page.
- **`and` / `or` / `exact`** for multi-word queries — the popup left of the search field. `and` is
  what makes a half-remembered name findable: two words you are sure of, in any order, across the
  title and the path. A single word behaves identically in all three.
- **Deprecated results sort last**, whatever their score. A deprecated page repeats the name of its
  replacement, so counting occurrences ranks it highest exactly where it is least wanted. Switchable in
  Settings, if you would rather rank them like everything else.
- **Narrows by platform** — Desktop / Web / Mobile and macOS / Windows / Linux / iOS / Android, read
  from each page's own Compatibility table. See below.
- **Links work**, on both documentation formats, and open in the app rather than a browser.
- **Tabs.** Cmd-click a link or a topic to open one behind what you are reading, and keep reading.
- **Back and Forward**, favorites (Cmd+D), and a globe that opens the current page on
  documentation.xojo.com.
- **Installs documentation for a release you no longer have** — File ▸ Install Documentation takes an
  old `XojoLangRefDB` or a `docs.tgz` from a Xojo app bundle. See below.
- **Serves the documentation to an AI assistant** over MCP, if you switch it on. See below.
- **Works offline**, by construction: the pages are re-rendered locally with the app's own stylesheet,
  so nothing is ever fetched from a CDN.

## Narrowing by platform

Two rows of the Xojo documentation's own `Compatibility` table, as two groups of checkboxes: the
**project types** on the left, the **operating systems** on the right.

![Platform filters](screenshots/platform-filters.png?v=2)

They are separate axes and a page has to satisfy both, which is the whole point — untick `Web` and
`WebListBox.AddRow` goes, even though a web app really does run on macOS. Right-click either group
for Check All / Check None.

Pages that say nothing about platforms — the language reference, the topics, 1337 of 2123 pages on
2026r1.2 — always match, so no combination of boxes can hide `String`.

## Tabs

Cmd-clicking a link opens it in a tab behind the page you are on, so you can follow three or four
references without losing your place. Cmd+T, Cmd+W, and the `+` at the end of the strip.

![Tabs](screenshots/tabs.png?v=2)

## If you no longer have that Xojo release installed

**File ▸ Install Documentation…** takes the documentation file itself:

- an old **`XojoLangRefDB`** — one SQLite file, the whole set for 2015r2.1 to 2021r3.1
- a **`docs.tgz`** from inside a Xojo app bundle, at `Contents/Resources/Language Reference/`

It works out which release the file belongs to where the file says so, and asks where it does not —
the 2020–2021 databases carry no version number, and neither do the first few 2022 sets. Everything
lands in `~/Library/Application Support/Better Xojo Help/`, and **your Xojo installation is never
written to**. Settings has a button that opens that folder if you want to remove a set later.

## Serving the documentation to an AI assistant

Switch the MCP server on in Settings and a local assistant can look things up in the documentation
installed on this machine — Claude Code, Claude Desktop, or anything else that speaks MCP.
**Help ▸ MCP Setup** has the client configuration and a button that copies the command.

![Settings](screenshots/settings.png?v=2)

Two tools: `xojo_lookup` returns one class or member as plain text with its code samples, and
`xojo_search` matches words across titles and paths. **Every answer names the release it read**, and
any installed release can be asked for by name — which is the point of it. `RecordSet` is a live
class in 2018r3 and deprecated in 2026r1.2, and an assistant reading only the newest documentation
cannot tell you that.

It listens on **127.0.0.1 only**, refuses connections from anywhere else, and runs only while the app
is open. A launcher script in `tools/` lets your client start the app itself — hidden, in about a
second — and quit it again afterwards. The toolbar shows a status dot and a running count of calls.

## On Windows

The app is not macOS-only. Compiled from source it runs on Windows and finds the documentation Xojo
installed:

![Better Xojo Help on Windows](screenshots/windows.png?v=2)

Confirmed on **Windows 11 on ARM** against 2026r2 — that is the machine it was tested on, so an
x86-64 Windows build is expected to work but has not been run. Everything works there: the version
popup, the platform filters, tabs, and the MCP server, which is simply switched off in this shot.

**Linux is not validated.** It compiles and runs, and it finds the documentation, but the reading
pane is misplaced by GTK and the layout is unusable as it stands. Treat it as unsupported for now.

**No Windows or Linux download is provided, and none is planned.** Those builds embed a Chromium
runtime for the documentation viewer, which puts the Windows one at ~118 MB compressed — over
GitHub's 100 MB file limit, and a lot to carry for either. Build from source instead: open the
project in Xojo, pick your target, and run. There is nothing to configure.

## The three formats

Xojo has shipped its offline documentation three different ways, and hiding that is most of what this
app does.

| Era | Releases | Format |
|---|---|---|
| **Sphinx** | 2022r1 → 2026r1.2 | Read-the-Docs HTML plus a `searchindex.js` |
| **Legacy** | 2015r2.1 → 2021r3.1 | SQLite: HTML blobs and an FTS4 index |
| MediaWiki | 2013r1 → 2013r3.3 | Raw wikitext — **not supported** |

Xojo changed engine at **2022r1**. Everything before that is the legacy SQLite format, everything
from 2022r1 on is the Sphinx one, and this app reads both.

## Download

The current signed and notarised build is in [`Binaries/`](Binaries), and every version is on the
[Releases page](https://github.com/JYPochez/VNS-Better-Xojo-Help/releases). Unzip and drag to
Applications — it opens without a Gatekeeper warning, so you do not need a Xojo licence to run it.

The build is **universal** — Apple Silicon and Intel in one download.

## First: install Xojo's local documentation

**Xojo does not install its documentation by default.** If this app tells you it found nothing, that
is why — and it is worth doing once per release you care about, because each one installs its own copy
and this app reads all of them.

In Xojo: **Preferences → General → Documentation → Install Local Documentation**.

![Install Local Documentation](screenshots/install-local-docs.png?v=2)

Repeat it in each Xojo version you have installed. The docs land in
`~/Library/Application Support/Xojo/Xojo/Xojo <release>/`, which is where this app looks.

A release you have installed but never appears in the popup is one whose documentation was never
installed — every Xojo release ships a set, but you have to ask for it, once per release.

### If you cannot run that version of Xojo any more

**The two eras keep their documentation in completely different shapes**, so the answer depends on
which one you are after:

| Era | Where the documentation lives |
|---|---|
| **2022r1 and later** | `<release>/Documentation/` — a folder of about 2 000 HTML files |
| **2021r3.1 and earlier** | `<release>/OfflineHelp/XojoLangRefDB` — a single SQLite file, ~25 MB |

#### 2022r1 and later

You do not need to launch the IDE. **Every Xojo application bundle from this era carries the whole
set inside it**, at `Xojo.app/Contents/Resources/Language Reference/docs.tgz`. That archive *is* the
`Documentation` folder, so untar it into place:

```bash
VER="2025r3.1"
APP="/Applications/Xojo $VER/Xojo.app"          # wherever that release actually lives
DEST="$HOME/Library/Application Support/Xojo/Xojo/Xojo $VER/Documentation"

mkdir -p "$DEST"
tar xzf "$APP/Contents/Resources/Language Reference/docs.tgz" -C "$DEST"
```

Around 190 MB compressed, so it is not fast, but it is the only step. Verified on 2025r3.1 and
2026r1.2.

#### 2021r3.1 and earlier

**There is no archive inside these app bundles to unpack** — the trick above does not apply. What
you need is the one database file, and the only ways to get it are to let that IDE install it once,
or to copy it from a machine or backup that already has it:

```bash
VER="2019r1.1"
DEST="$HOME/Library/Application Support/Xojo/Xojo/Xojo $VER/OfflineHelp"

mkdir -p "$DEST"
cp /path/to/XojoLangRefDB "$DEST/"
```

Being a single self-contained file makes it easy to keep: back up `XojoLangRefDB` once per old
release and you can restore that documentation on any Mac, long after the IDE itself stops running.

Either way the folder name has to match the release exactly, because that is the string the version
popup reads. Restart Better Xojo Help and it appears.

## Requirements

- **macOS**, Apple Silicon or Intel — that is what the download below is.
- **Windows** works, built from source: confirmed on Windows 11 on ARM with 2026r2, once Xojo's local
  documentation was installed. No Windows download is provided — see below for why.
- **Linux** — **not validated.** It compiles and finds the documentation, but the layout is not
  usable yet. See below.
- At least one Xojo release with its **local documentation installed** — see above; this is the step
  people miss.
- Xojo 2021r3 or later to build it (the project uses API 2.0 throughout).

## Building

Open `Better Xojo Help.xojo_project` in Xojo and run. There is nothing to configure and no
dependencies to fetch.

To build a signed copy you will need your own Apple Developer ID: the signing identity and
notarisation credentials are stripped from the published project, so the Sign build step is blank
until you fill it in.

## Feedback

There is a thread on the Xojo forum — questions, bug reports and suggestions are welcome there:
[Better Xojo Help — browse every installed Xojo doc set from one window](https://forum.xojo.com/t/better-xojo-help-browse-every-installed-xojo-doc-set-from-one-window-open-source/)

## Licence

MIT — see [LICENSE](LICENSE).

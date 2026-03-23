# MD2Print — Operators Manual

Complete reference for installing, configuring, and using MD2Print.

---

## Table of Contents

1. [Installation](#1-installation)
2. [CLI Reference](#2-cli-reference)
3. [Web App Reference](#3-web-app-reference)
4. [Themes](#4-themes)
5. [Page Layout](#5-page-layout)
6. [Headers and Footers](#6-headers-and-footers)
7. [Markdown Support](#7-markdown-support)
8. [Quick Action (Finder)](#8-quick-action-finder)
9. [App Icon](#9-app-icon)
10. [File Locations](#10-file-locations)
11. [Troubleshooting](#11-troubleshooting)
12. [Uninstall](#12-uninstall)

---

## 1. Installation

### Prerequisites

- macOS 10.15 or later
- Python 3.6+ (ships with macOS)
- No additional packages or dependencies required

### Install

```bash
git clone https://github.com/kraaft007/MD2HTML.git
cd MD2HTML
chmod +x install.sh
./install.sh
```

### What the Installer Does

1. Copies `md2print.py` to `~/Documents/MD2Print/`
2. Copies `web/index.html` to `~/Documents/MD2Print/web/`
3. Creates a Finder Quick Action at `~/Library/Services/`
4. Creates `MD2Print.app` at `/Applications/`
5. Generates a custom app icon (requires PyObjC; falls back to default icon)
6. Flushes the macOS services cache so the Quick Action appears immediately

### Re-installing / Updating

Run `./install.sh` again. It overwrites existing files safely. No data is lost — the installer only copies tool files and recreates the Quick Action and app.

---

## 2. CLI Reference

### Basic Usage

```bash
python3 md2print.py <input.md> [options]
```

The CLI reads a Markdown file, converts it to print-optimized HTML, writes the output, and (by default) opens it in your browser.

### Output File Naming

| Scenario | Output path |
|---|---|
| No `-o` flag | `<input>.print.html` (same directory as input) |
| `-o report.html` | `report.html` |
| `-o /tmp/out.html` | `/tmp/out.html` |

### All Flags

```
GENERAL
  input                 Input .md file (required unless --list-themes)
  -o, --output FILE     Output .html file path
  --theme NAME          Theme: default, ocean, forest, amber, slate
  --open                Open in browser after conversion (default: yes)
  --no-open             Convert without opening browser
  --list-themes         Print available themes and exit
  -h, --help            Show help and exit

TYPOGRAPHY
  --body-size PT        Body font size in points (default: 11)
  --body-color HEX      Body text color (default: #222222)
  --h1-size PT          H1 font size (default: 22)
  --h1-color HEX        H1 color (default: #1a1a2e)
  --h2-size PT          H2 font size (default: 16)
  --h2-color HEX        H2 color (default: #2d3748)
  --h3-size PT          H3 font size (default: 13)
  --h3-color HEX        H3 color (default: #4a5568)
  --code-size PT        Code block font size (default: 9)

PAGE LAYOUT
  --margin INCHES       Set all four margins at once
  --margin-top INCHES   Top margin (default: 0.5)
  --margin-bottom INCHES Bottom margin (default: 0.5)
  --margin-left INCHES  Left margin (default: 0.5)
  --margin-right INCHES Right margin (default: 0.5)

HEADERS & FOOTERS
  --header-left         none | logo (default: none)
  --header-right        none | filename (default: filename)
  --footer-left         none | date (default: date)
  --footer-right        none | pagenum (default: pagenum)
  --logo FILE           Path to logo PNG/JPG for header-left
```

### Examples

```bash
# Basic conversion with default theme
python3 md2print.py notes.md

# Ocean theme, save to specific file
python3 md2print.py notes.md --theme ocean -o ~/Desktop/notes.html

# Custom colors on top of a theme
python3 md2print.py notes.md --theme slate --h1-color '#c0392b' --h2-color '#2980b9'

# Larger body text, tighter margins
python3 md2print.py notes.md --body-size 12 --margin 0.4

# Company logo in header, no footer
python3 md2print.py notes.md --header-left logo --logo company.png \
  --footer-left none --footer-right none

# Batch convert without opening browser
for f in docs/*.md; do
    python3 md2print.py "$f" --no-open --theme forest
done

# List available themes
python3 md2print.py --list-themes
```

### Exit Codes

| Code | Meaning |
|---|---|
| 0 | Success |
| 1 | Unknown theme, file not found, or other error |
| 2 | Missing required argument |

---

## 3. Web App Reference

### Opening the Web App

Any of these methods:

```bash
# Via the app icon
open /Applications/MD2Print.app

# Directly
open ~/Documents/MD2Print/web/index.html

# From the repo
open web/index.html
```

### Loading Markdown

Three ways to load content:

| Method | How |
|---|---|
| **File picker** | Click "Open .md File" in the sidebar |
| **Drag and drop** | Drag a `.md`, `.txt`, or `.markdown` file onto the preview area |
| **Paste** | Press Cmd+V anywhere (text must be >10 characters) |

**Tip:** Press `Cmd+Shift+.` in the file picker dialog to reveal hidden files (like `.claude/` directories).

### Settings Panel

The left sidebar contains all formatting controls. Changes apply instantly to the preview.

**Body Text**
- Font family (Georgia, System Sans, Palatino, Helvetica, Charter)
- Size (8–18 pt)
- Color (color picker)
- Line height (1.0–2.5)

**Headings (H1, H2, H3 independently)**
- Font family
- Size
- Color
- Spacing below (px)

**Code Blocks**
- Font size (6–14 pt)
- Background color

**Page Margins**
- Top, Bottom, Left, Right (inches, 0–2)

**Page Header**
- Left: None or Logo (upload PNG/JPG/SVG)
- Right: None or File Name

**Page Footer**
- Left: None or Date (MM-DD-YYYY)
- Right: None or Page number

### Theme System

**Built-in themes** (5): Default, Ocean Blue, Forest Green, Warm Amber, Slate Gray. Click a chip to apply instantly.

**Custom themes:**
- Adjust settings to your liking, then click **Save as Theme**
- Custom themes appear as dashed-border chips
- Hover a custom chip to reveal the delete button (x)
- Custom themes persist in browser localStorage

**Import / Export:**
- **Export JSON** — downloads all themes (built-in + custom) as `md2print-themes.json`
- **Import JSON** — loads custom themes from a previously exported file
- Built-in themes are never overwritten by imports

### Page Break Preview

The toggle **"Show page break lines"** draws dashed red lines at US Letter page boundaries, accounting for your current margin settings. This shows exactly where content will break when printed.

The pagination engine automatically:
- Pushes headings to the next page if there isn't room for the heading plus ~3 lines of body text
- Adds breathing room when headings land too close to the top of a page
- Keeps code blocks and tables from splitting across pages (when they fit on one page)

### Printing

Click **Print / Save as PDF** or press **Cmd+P**. The print output uses:
- Your configured margins via `@page` CSS
- Fixed-position header and footer (when enabled)
- Page-break avoidance for headings, code blocks, and table rows

**Recommended browser print settings:**
- Paper size: US Letter
- Margins: Default (let the CSS handle it)
- Background graphics: ON (for code block backgrounds)
- Headers and footers: OFF (MD2Print provides its own)

---

## 4. Themes

### Theme Properties

Each theme controls these values:

| Property | Controls | Default value |
|---|---|---|
| `bodyFont` | Body text font stack | System sans-serif |
| `bodySize` | Body font size (pt) | 11 |
| `bodyColor` | Body text color | #222222 |
| `bodyLineHeight` | Line spacing | 1.5 |
| `h1Font` | H1 font stack | System sans-serif |
| `h1Size` | H1 font size (pt) | 22 |
| `h1Color` | H1 color | #1a1a2e |
| `h1Margin` | Space below H1 (px) | 8 |
| `h2Font` / `h2Size` / `h2Color` / `h2Margin` | H2 controls | 16pt, #2d3748, 6px |
| `h3Font` / `h3Size` / `h3Color` / `h3Margin` | H3 controls | 13pt, #4a5568, 4px |
| `codeSize` | Code block font size (pt) | 9 |
| `codeBg` | Code block background | #f6f8fa |
| `marginTop` / `marginBottom` / `marginLeft` / `marginRight` | Page margins (inches) | 0.5 |

### Built-in Theme Details

**Default** — Clean, modern. System sans-serif throughout. Neutral dark headings.
```
Body: -apple-system / Segoe UI    H1: #1a1a2e    H2: #2d3748    H3: #4a5568
```

**Ocean Blue** — Professional, calm. Georgia body with Helvetica headings in blue.
```
Body: Georgia (serif)              H1: #1e3a5f    H2: #2c5282    H3: #3182ce
```

**Forest Green** — Earthy, natural. Charter body with green heading hierarchy.
```
Body: Charter (serif)              H1: #1b4332    H2: #2d6a4f    H3: #40916c
```

**Warm Amber** — Classic, warm. Palatino body with Georgia headings in amber.
```
Body: Palatino Linotype (serif)    H1: #7c4a03    H2: #b45309    H3: #d97706
```

**Slate Gray** — Minimal, corporate. Helvetica throughout in cool grays.
```
Body: Helvetica Neue               H1: #1a202c    H2: #4a5568    H3: #718096
```

### CLI Theme Overrides

Any theme property can be overridden from the command line. The override applies on top of the selected theme:

```bash
# Start with Ocean, but use a red H1
python3 md2print.py notes.md --theme ocean --h1-color '#c0392b'

# Start with Forest, increase body size
python3 md2print.py notes.md --theme forest --body-size 12.5
```

### Exporting and Sharing Themes

In the web app:
1. Configure your theme using the sidebar controls
2. Click **Save as Theme** and give it a name
3. Click **Export JSON** to download `md2print-themes.json`
4. Share the JSON file — recipients click **Import JSON** to load it

The JSON format:
```json
{
  "builtinThemes": { ... },
  "customThemes": {
    "My Corporate": {
      "bodyFont": "'Helvetica Neue', sans-serif",
      "bodySize": 11,
      "h1Color": "#003366",
      ...
    }
  },
  "exportedAt": "2026-03-23T...",
  "version": "1.0"
}
```

---

## 5. Page Layout

### Paper Size

All output targets **US Letter** (8.5 x 11 inches). This is set via `@page { size: letter; }` in the generated CSS.

### Margins

Default: 0.5 inches on all sides. Configurable per-side via CLI flags or the web app sidebar.

```bash
# Uniform margins
python3 md2print.py notes.md --margin 0.75

# Per-side control
python3 md2print.py notes.md --margin-top 1.0 --margin-bottom 0.5 \
  --margin-left 0.75 --margin-right 0.75
```

### Page Break Behavior

The generated HTML uses CSS rules to control page breaks:

| Element | Rule |
|---|---|
| Headings (H1–H3) | `page-break-after: avoid` — won't leave a heading orphaned at page bottom |
| Table rows | `page-break-inside: avoid` — rows don't split across pages |
| Code blocks | `page-break-inside: avoid` — code stays together |
| Tables | `page-break-inside: avoid` — small tables stay on one page |

The web app adds an **intelligent pagination engine** that goes further:
- Pushes headings to the next page when there isn't enough room for body text below
- Prevents code blocks and tables from splitting (when >30% would spill)
- Multi-pass algorithm stabilizes cascading shifts

---

## 6. Headers and Footers

### Available Options

| Position | Choices | Default |
|---|---|---|
| Header left | `none`, `logo` | `none` |
| Header right | `none`, `filename` | `filename` |
| Footer left | `none`, `date` | `date` (MM-DD-YYYY format) |
| Footer right | `none`, `pagenum` | `pagenum` |

### Logo

To add a logo to the header:

**CLI:**
```bash
python3 md2print.py notes.md --header-left logo --logo /path/to/logo.png
```

**Web app:** Select "Logo (PNG)" from the Header Left dropdown, then upload the image file.

The logo displays at 18px height in the top-left corner of every printed page.

### Disabling Headers/Footers

```bash
# No header, no footer
python3 md2print.py notes.md --header-left none --header-right none \
  --footer-left none --footer-right none
```

In the web app, set all four dropdowns to "None".

---

## 7. Markdown Support

### Supported Syntax

The CLI uses a **built-in pure-Python parser** (no dependencies). The web app uses **marked.js** (loaded from CDN). Both handle standard Markdown and most GFM extensions.

| Element | Syntax | Both parsers |
|---|---|---|
| Headings | `# H1` through `###### H6` | Yes |
| Paragraphs | Blank line between text blocks | Yes |
| **Bold** | `**text**` | Yes |
| *Italic* | `*text*` | Yes |
| ***Bold italic*** | `***text***` | Yes |
| Inline code | `` `code` `` | Yes |
| Fenced code blocks | ```` ``` ```` with optional language | Yes |
| Unordered lists | `- item`, `* item`, `+ item` | Yes |
| Ordered lists | `1. item` | Yes |
| Tables (GFM) | Pipe-delimited with header separator | Yes |
| Links | `[text](url)` | Yes |
| Images | `![alt](url)` | Yes |
| Blockquotes | `> text` | Yes |
| Horizontal rules | `---` or `***` | Yes |

### ASCII Art Detection

Code blocks containing box-drawing characters (`┌ ┐ └ ┘ │ ─` etc.) or dense pipe/dash patterns are automatically detected as ASCII art and rendered with:
- Slightly smaller font size (1pt less than code)
- Tighter line height (1.2)
- Zero letter spacing
- Preserved whitespace alignment

### Limitations

- Nested lists are flattened (the CLI parser does not track indent depth)
- No syntax highlighting for code blocks (plain monospace only)
- No footnotes, definition lists, or task lists
- Inline HTML in the markdown is passed through as-is

---

## 8. Quick Action (Finder)

### How It Works

1. Select one or more `.md`, `.txt`, or `.markdown` files in Finder
2. Right-click → **Quick Actions** → **Convert to Print HTML**
3. The Quick Action runs `md2print.py --no-open` on each selected file
4. Each generated `.print.html` file opens in your default browser
5. Press Cmd+P to print or save as PDF

### Supported File Types

The Quick Action accepts files with these UTI types:
- `net.daringfireball.markdown` (.md, .markdown)
- `public.plain-text` (.txt)
- `public.text`

### Output Location

Output files are created alongside the input files:
```
~/Documents/notes.md  →  ~/Documents/notes.print.html
~/Desktop/report.md   →  ~/Desktop/report.print.html
```

### Theme

The Quick Action uses the **default** theme. To use a different theme, use the CLI or web app instead.

---

## 9. App Icon

### What It Is

`MD2Print.app` is a lightweight AppleScript application that opens the web app (`~/Documents/MD2Print/web/index.html`) in your default browser.

### Location

```
/Applications/MD2Print.app
```

### Dock Access

Drag `MD2Print.app` from `/Applications/` to your Dock for one-click access.

### Icon

The installer generates a custom blue icon with "MD / → HTML / PRINT" text using macOS PyObjC. If PyObjC is not available (rare on stock macOS with Homebrew Python), it falls back to the standard AppleScript icon.

---

## 10. File Locations

### After Installation

```
/Applications/
  └── MD2Print.app                     Clickable app launcher

~/Documents/MD2Print/
  ├── md2print.py                      CLI tool
  └── web/
      └── index.html                   Web app

~/Library/Services/
  └── Convert to Print HTML.workflow/  Finder Quick Action
```

### Source Repository

```
<cloned-location>/MD2HTML/
├── md2print.py              Source CLI
├── web/
│   └── index.html           Source web app
├── install.sh               Installer script
├── README.md                Quick-start guide
├── Operators-Manual.md      This document
└── examples/
    ├── Guide-Lessons1.md    Sample markdown file
    └── Notion-Guide-Lessons1.pdf
```

### Generated Files

When converting via CLI or Quick Action, output files are created next to the input:

```
/path/to/document.md  →  /path/to/document.print.html
```

Use `-o` to override this location.

---

## 11. Troubleshooting

### Quick Action doesn't appear in Finder

The Quick Action may take a moment to register after install. Try:
```bash
# Refresh the services cache
/System/Library/CoreServices/pbs -flush

# Or restart Finder
killall Finder
```

If it still doesn't appear, log out and back in.

### Quick Action runs but nothing opens

Verify the CLI works directly:
```bash
python3 ~/Documents/MD2Print/md2print.py /path/to/test.md --no-open
```

If this fails with "python3: command not found", ensure Python 3 is installed:
```bash
python3 --version
```

### Web app won't load .md files

**"File picker won't show my files"** — Press `Cmd+Shift+.` in the file dialog to reveal hidden files and directories.

**Drag and drop doesn't work** — Ensure the file has a `.md`, `.markdown`, or `.txt` extension.

### Print output doesn't match preview

- Ensure **Background graphics** is enabled in the browser print dialog
- Set browser **Headers and footers** to OFF (use MD2Print's own)
- Set browser margins to **Default** (the CSS `@page` rule handles margins)

### Code blocks are cut off

If a code block has very long lines, they may extend past the page edge in print. The CSS uses `white-space: pre` to preserve formatting rather than wrapping. For long lines, consider wrapping them in the source markdown.

### Custom themes disappeared

Custom themes are stored in browser `localStorage`. They will be lost if you:
- Clear browser data
- Switch browsers
- Use private/incognito mode

Use **Export JSON** to back up custom themes.

---

## 12. Uninstall

Remove all installed files:

```bash
rm -rf /Applications/MD2Print.app
rm -rf ~/Documents/MD2Print
rm -rf ~/Library/Services/"Convert to Print HTML.workflow"
```

Refresh the services cache:
```bash
/System/Library/CoreServices/pbs -flush
```

This leaves no other traces on your system. The web app stores custom themes in browser localStorage under the key `md2print_custom_themes` — clear it manually if desired.

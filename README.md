# MD2Print

Convert Markdown files to print-optimized HTML with themes, headers/footers, and intelligent pagination.

Three ways to use it:

| Mode | What it does |
|---|---|
| **Quick Action** | Right-click `.md` files in Finder → "Convert to Print HTML" |
| **CLI** | `python3 md2print.py notes.md --theme ocean` |
| **Web App** | Drag-and-drop GUI with live preview and Cmd+P printing |

## Install (macOS)

```bash
git clone https://github.com/kraaft007/MD2HTML.git
cd MD2HTML
chmod +x install.sh
./install.sh
```

This copies the tool to `~/Documents/MD2Print/` and installs a Finder Quick Action.

## Quick Action (Finder)

After running `install.sh`:

1. Select one or more `.md`, `.txt`, or `.markdown` files in Finder
2. Right-click → Quick Actions → **Convert to Print HTML**
3. Each file converts and opens as print-ready HTML in your browser
4. Press **Cmd+P** to print or save as PDF

## CLI Usage

```bash
python3 md2print.py notes.md                        # Default theme, opens browser
python3 md2print.py notes.md --theme ocean           # Ocean Blue theme
python3 md2print.py notes.md --theme forest -o out.html  # Save to specific file
python3 md2print.py notes.md --no-open               # Convert without opening
python3 md2print.py --list-themes                     # Show available themes
```

### Themes

| Theme | Style |
|---|---|
| `default` | System sans-serif, neutral dark headings |
| `ocean` | Georgia body, blue heading hierarchy |
| `forest` | Charter body, green heading hierarchy |
| `amber` | Palatino body, warm amber headings |
| `slate` | Helvetica, cool gray tones |

### Style Overrides

```bash
python3 md2print.py notes.md --h1-color '#c0392b' --body-size 12
python3 md2print.py notes.md --margin 0.75 --code-size 10
python3 md2print.py notes.md --header-left logo --logo company.png
```

Run `python3 md2print.py --help` for all options.

## Web App

Open `web/index.html` in any browser (or after install: `open ~/Documents/MD2Print/web/index.html`).

- Drag and drop `.md` files or paste markdown text
- Live preview with page-break indicators
- Full theme customization panel (fonts, colors, sizes, margins)
- Save/export custom themes as JSON
- Print directly with Cmd+P

## Requirements

- **Python 3.6+** (ships with macOS) — no pip dependencies
- **macOS** for Quick Action (CLI and web app work on any OS)

## Project Structure

```
MD2HTML/
├── md2print.py          CLI converter (pure Python, zero dependencies)
├── web/
│   └── index.html       Standalone browser GUI
├── install.sh           macOS Quick Action installer
└── examples/
    ├── Guide-Lessons1.md        Sample markdown
    └── Notion-Guide-Lessons1.pdf  Sample PDF source
```

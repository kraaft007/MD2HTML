# MD2Print

Convert Markdown files to print-optimized HTML with themes, page headers/footers, and intelligent pagination.

**Zero dependencies.** Pure Python CLI + standalone browser GUI. Works on any Mac out of the box.

## Quick Start

```bash
git clone https://github.com/kraaft007/MD2HTML.git
cd MD2HTML
chmod +x install.sh
./install.sh
```

The installer sets up everything on your Mac in one step:

| What gets installed | Where |
|---|---|
| **MD2Print.app** | `/Applications/` — double-click or drag to Dock |
| **CLI tool** | `~/Documents/MD2Print/md2print.py` |
| **Web app** | `~/Documents/MD2Print/web/index.html` |
| **Quick Action** | `~/Library/Services/` — right-click in Finder |

## Four Ways to Use It

### 1. App Icon

Double-click **MD2Print** in `/Applications` to launch the web app. Drag it to your Dock for one-click access.

### 2. Quick Action (Finder)

Select one or more `.md`, `.txt`, or `.markdown` files in Finder, right-click, and choose **Quick Actions > Convert to Print HTML**. Each file is converted and opened in your browser, ready for Cmd+P.

### 3. Command Line

```bash
python3 md2print.py notes.md                          # Default theme, opens browser
python3 md2print.py notes.md --theme ocean             # Ocean Blue theme
python3 md2print.py notes.md -o report.html            # Save to specific file
python3 md2print.py notes.md --no-open                 # Convert without opening
python3 md2print.py --list-themes                      # Show all themes
```

### 4. Web App (Drag & Drop)

Open `web/index.html` in any browser. Drag in `.md` files or paste markdown text. Customize fonts, colors, margins, and headers/footers in real time. Print with Cmd+P.

## Built-in Themes

| Theme | Body Font | Heading Colors | Character |
|---|---|---|---|
| **default** | System sans-serif | Dark neutral | Clean, modern |
| **ocean** | Georgia (serif) | Blue hierarchy | Professional, calm |
| **forest** | Charter (serif) | Green hierarchy | Earthy, natural |
| **amber** | Palatino (serif) | Warm amber | Classic, warm |
| **slate** | Helvetica | Cool gray | Minimal, corporate |

## Requirements

- **macOS** with Python 3.6+ (ships with macOS)
- No `pip install`, no virtual environments, no node modules
- Quick Action and App require macOS; CLI and web app work on any OS

## Project Structure

```
MD2HTML/
├── md2print.py        CLI converter (pure Python, zero dependencies)
├── web/
│   └── index.html     Standalone browser GUI
├── install.sh         macOS one-step installer
└── examples/
    ├── Guide-Lessons1.md
    └── Notion-Guide-Lessons1.pdf
```

## Documentation

See [Operators Manual](Operators-Manual.md) for the full reference: all CLI flags, theme customization, web app features, header/footer configuration, and troubleshooting.

## License

MIT

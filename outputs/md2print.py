#!/usr/bin/env python3
"""
md2print — Convert Markdown files to print-optimized HTML.

Usage:
  python3 md2print.py input.md                          # Default theme, opens in browser
  python3 md2print.py input.md --theme ocean            # Ocean Blue theme
  python3 md2print.py input.md --theme forest -o out.html  # Save to file
  python3 md2print.py input.md --h1-color '#1e3a5f'     # Custom H1 color
  python3 md2print.py input.md --list-themes            # Show available themes

Designed to be called from Claude Code or any terminal on macOS.
Output HTML opens in default browser for Cmd+P printing.
"""

import argparse
import html
import os
import re
import sys
import webbrowser
from datetime import datetime
from pathlib import Path

# ============================================================
#  THEMES
# ============================================================
THEMES = {
    "default": {
        "body_font": "'-apple-system', 'Segoe UI', sans-serif",
        "body_size": 11, "body_color": "#222222", "body_line_height": 1.5,
        "h1_font": "'-apple-system', 'Segoe UI', sans-serif",
        "h1_size": 22, "h1_color": "#1a1a2e", "h1_margin": 8,
        "h2_font": "'-apple-system', 'Segoe UI', sans-serif",
        "h2_size": 16, "h2_color": "#2d3748", "h2_margin": 6,
        "h3_font": "'-apple-system', 'Segoe UI', sans-serif",
        "h3_size": 13, "h3_color": "#4a5568", "h3_margin": 4,
        "code_size": 9, "code_bg": "#f6f8fa",
        "margin_top": 0.5, "margin_bottom": 0.5,
        "margin_left": 0.5, "margin_right": 0.5,
    },
    "ocean": {
        "body_font": "'Georgia', serif",
        "body_size": 11, "body_color": "#1a202c", "body_line_height": 1.55,
        "h1_font": "'Helvetica Neue', Helvetica, Arial, sans-serif",
        "h1_size": 24, "h1_color": "#1e3a5f", "h1_margin": 10,
        "h2_font": "'Helvetica Neue', Helvetica, Arial, sans-serif",
        "h2_size": 17, "h2_color": "#2c5282", "h2_margin": 7,
        "h3_font": "'Helvetica Neue', Helvetica, Arial, sans-serif",
        "h3_size": 13, "h3_color": "#3182ce", "h3_margin": 4,
        "code_size": 9, "code_bg": "#edf2f7",
        "margin_top": 0.5, "margin_bottom": 0.5,
        "margin_left": 0.5, "margin_right": 0.5,
    },
    "forest": {
        "body_font": "'Charter', 'Bitstream Charter', serif",
        "body_size": 11, "body_color": "#1a2e1a", "body_line_height": 1.5,
        "h1_font": "'-apple-system', 'Segoe UI', sans-serif",
        "h1_size": 22, "h1_color": "#1b4332", "h1_margin": 8,
        "h2_font": "'-apple-system', 'Segoe UI', sans-serif",
        "h2_size": 16, "h2_color": "#2d6a4f", "h2_margin": 6,
        "h3_font": "'-apple-system', 'Segoe UI', sans-serif",
        "h3_size": 13, "h3_color": "#40916c", "h3_margin": 4,
        "code_size": 9, "code_bg": "#f0faf0",
        "margin_top": 0.5, "margin_bottom": 0.5,
        "margin_left": 0.5, "margin_right": 0.5,
    },
    "amber": {
        "body_font": "'Palatino Linotype', 'Book Antiqua', serif",
        "body_size": 11, "body_color": "#2d2418", "body_line_height": 1.55,
        "h1_font": "'Georgia', serif",
        "h1_size": 23, "h1_color": "#7c4a03", "h1_margin": 9,
        "h2_font": "'Georgia', serif",
        "h2_size": 16, "h2_color": "#b45309", "h2_margin": 6,
        "h3_font": "'Georgia', serif",
        "h3_size": 13, "h3_color": "#d97706", "h3_margin": 4,
        "code_size": 9, "code_bg": "#fef9ee",
        "margin_top": 0.5, "margin_bottom": 0.5,
        "margin_left": 0.5, "margin_right": 0.5,
    },
    "slate": {
        "body_font": "'Helvetica Neue', Helvetica, Arial, sans-serif",
        "body_size": 11, "body_color": "#2d3748", "body_line_height": 1.5,
        "h1_font": "'Helvetica Neue', Helvetica, Arial, sans-serif",
        "h1_size": 22, "h1_color": "#1a202c", "h1_margin": 8,
        "h2_font": "'Helvetica Neue', Helvetica, Arial, sans-serif",
        "h2_size": 16, "h2_color": "#4a5568", "h2_margin": 6,
        "h3_font": "'Helvetica Neue', Helvetica, Arial, sans-serif",
        "h3_size": 13, "h3_color": "#718096", "h3_margin": 4,
        "code_size": 9, "code_bg": "#edf2f7",
        "margin_top": 0.5, "margin_bottom": 0.5,
        "margin_left": 0.5, "margin_right": 0.5,
    },
}


# ============================================================
#  MARKDOWN → HTML CONVERTER (pure Python, no dependencies)
# ============================================================
def md_to_html(md_text: str) -> str:
    """Convert markdown to HTML. Handles headings, code blocks, tables,
    lists, bold, italic, inline code, links, images, blockquotes, and hr."""
    lines = md_text.split('\n')
    out = []
    i = 0
    in_list = None  # 'ul' or 'ol'

    def close_list():
        nonlocal in_list
        if in_list:
            out.append(f'</{in_list}>')
            in_list = None

    def inline(text):
        """Process inline markdown: bold, italic, code, links, images."""
        # Inline code (must be first to avoid processing inside code)
        text = re.sub(r'`([^`]+)`', r'<code>\1</code>', text)
        # Images
        text = re.sub(r'!\[([^\]]*)\]\(([^)]+)\)', r'<img src="\2" alt="\1">', text)
        # Links
        text = re.sub(r'\[([^\]]+)\]\(([^)]+)\)', r'<a href="\2">\1</a>', text)
        # Bold+italic
        text = re.sub(r'\*\*\*(.+?)\*\*\*', r'<strong><em>\1</em></strong>', text)
        # Bold
        text = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', text)
        # Italic
        text = re.sub(r'\*(.+?)\*', r'<em>\1</em>', text)
        return text

    while i < len(lines):
        line = lines[i]

        # Fenced code block
        if line.strip().startswith('```'):
            close_list()
            lang = line.strip()[3:].strip()
            code_lines = []
            i += 1
            while i < len(lines) and not lines[i].strip().startswith('```'):
                code_lines.append(lines[i])
                i += 1
            code_text = '\n'.join(code_lines)
            escaped = html.escape(code_text)
            # Detect ASCII art
            is_ascii = bool(re.search(r'[┌┐└┘├┤┬┴│─═║╔╗╚╝╠╣╦╩▲▼◄►←→↑↓]', code_text)) or \
                       (code_text.count('|') > 5 and code_text.count('-') > 10 and code_text.count('\n') > 3)
            cls = 'ascii-art' if is_ascii else (f'language-{lang}' if lang else '')
            out.append(f'<pre class="{cls}"><code>{escaped}</code></pre>')
            i += 1
            continue

        # Horizontal rule
        if re.match(r'^---+\s*$', line) or re.match(r'^\*\*\*+\s*$', line):
            close_list()
            out.append('<hr>')
            i += 1
            continue

        # Headings
        hm = re.match(r'^(#{1,6})\s+(.+)$', line)
        if hm:
            close_list()
            level = len(hm.group(1))
            text = inline(hm.group(2))
            out.append(f'<h{level}>{text}</h{level}>')
            i += 1
            continue

        # Table
        if '|' in line and i + 1 < len(lines) and re.match(r'^[\s|:-]+$', lines[i+1]):
            close_list()
            headers = [c.strip() for c in line.strip().strip('|').split('|')]
            i += 2  # skip separator
            out.append('<table><thead><tr>')
            for h in headers:
                out.append(f'<th>{inline(h)}</th>')
            out.append('</tr></thead><tbody>')
            while i < len(lines) and '|' in lines[i] and lines[i].strip():
                cells = [c.strip() for c in lines[i].strip().strip('|').split('|')]
                out.append('<tr>')
                for c in cells:
                    out.append(f'<td>{inline(c)}</td>')
                out.append('</tr>')
                i += 1
            out.append('</tbody></table>')
            continue

        # Blockquote
        if line.startswith('>'):
            close_list()
            bq_lines = []
            while i < len(lines) and lines[i].startswith('>'):
                bq_lines.append(lines[i][1:].strip())
                i += 1
            out.append(f'<blockquote><p>{inline(" ".join(bq_lines))}</p></blockquote>')
            continue

        # Unordered list
        um = re.match(r'^(\s*)[-*+]\s+(.+)$', line)
        if um:
            if in_list != 'ul':
                close_list()
                in_list = 'ul'
                out.append('<ul>')
            out.append(f'<li>{inline(um.group(2))}</li>')
            i += 1
            continue

        # Ordered list
        om = re.match(r'^(\s*)\d+\.\s+(.+)$', line)
        if om:
            if in_list != 'ol':
                close_list()
                in_list = 'ol'
                out.append('<ol>')
            out.append(f'<li>{inline(om.group(2))}</li>')
            i += 1
            continue

        # Blank line
        if not line.strip():
            close_list()
            i += 1
            continue

        # Paragraph — collect consecutive non-blank lines
        close_list()
        para_lines = []
        while i < len(lines) and lines[i].strip() and \
              not lines[i].startswith('#') and not lines[i].startswith('```') and \
              not lines[i].startswith('>') and \
              not re.match(r'^---+\s*$', lines[i]) and \
              not re.match(r'^[-*+]\s+', lines[i]) and \
              not re.match(r'^\d+\.\s+', lines[i]) and \
              not ('|' in lines[i] and i + 1 < len(lines) and '---' in lines[i+1]):
            para_lines.append(lines[i])
            i += 1
        out.append(f'<p>{inline(" ".join(para_lines))}</p>')

    close_list()
    return '\n'.join(out)


# ============================================================
#  HTML TEMPLATE
# ============================================================
def build_html(body_html: str, theme: dict, filename: str,
               header_left: str = "none", header_right: str = "filename",
               footer_left: str = "date", footer_right: str = "pagenum",
               logo_path: str = None) -> str:

    t = theme
    now = datetime.now()
    date_str = now.strftime("%m-%d-%Y")

    # Header content
    hl_html = ""
    if header_left == "logo" and logo_path:
        hl_html = f'<img src="file://{os.path.abspath(logo_path)}" alt="Logo" style="height:18px;">'

    hr_html = filename if header_right == "filename" else ""
    fl_html = f"Date: {date_str}" if footer_left == "date" else ""
    fr_html = "Page" if footer_right == "pagenum" else ""

    show_header = header_left != "none" or header_right != "none"
    show_footer = footer_left != "none" or footer_right != "none"

    return f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>{html.escape(filename)}</title>
<style>
/* Reset */
*, *::before, *::after {{ box-sizing: border-box; }}
body {{
  margin: 0; padding: 0;
  font-family: {t['body_font']};
  font-size: {t['body_size']}pt;
  color: {t['body_color']};
  line-height: {t['body_line_height']};
}}

/* Page setup */
@page {{
  size: letter;
  margin: {t['margin_top']}in {t['margin_right']}in {t['margin_bottom']}in {t['margin_left']}in;
}}

/* Content wrapper */
#content {{
  max-width: 100%;
}}

/* Headings — compact spacing */
h1 {{
  font-family: {t['h1_font']};
  font-size: {t['h1_size']}pt;
  color: {t['h1_color']};
  margin: 16px 0 {t['h1_margin']}px 0;
  line-height: 1.2; font-weight: 700;
}}
h1:first-child {{ margin-top: 0; }}
h2 {{
  font-family: {t['h2_font']};
  font-size: {t['h2_size']}pt;
  color: {t['h2_color']};
  margin: 14px 0 {t['h2_margin']}px 0;
  line-height: 1.25; font-weight: 600;
}}
h3 {{
  font-family: {t['h3_font']};
  font-size: {t['h3_size']}pt;
  color: {t['h3_color']};
  margin: 12px 0 {t['h3_margin']}px 0;
  line-height: 1.3; font-weight: 600;
}}

/* Paragraphs */
p {{ margin: 0 0 8px 0; }}

/* Lists */
ul, ol {{ margin: 4px 0 8px 0; padding-left: 24px; }}
li {{ margin-bottom: 3px; }}

/* Code blocks */
pre {{
  background: {t['code_bg']};
  border: 1px solid #e1e4e8;
  border-radius: 4px;
  padding: 10px 12px;
  font-size: {t['code_size']}pt;
  font-family: 'SF Mono', 'Fira Code', 'Cascadia Code', 'JetBrains Mono', 'Menlo', 'Monaco', 'Consolas', monospace;
  line-height: 1.4;
  overflow-x: visible;
  white-space: pre;
  word-wrap: normal;
  page-break-inside: avoid;
}}
pre.ascii-art {{
  font-size: {max(t['code_size'] - 1, 7)}pt;
  line-height: 1.2;
  letter-spacing: 0;
}}
code {{
  font-family: 'SF Mono', 'Fira Code', 'Cascadia Code', 'JetBrains Mono', 'Menlo', 'Monaco', 'Consolas', monospace;
}}
code:not(pre code) {{
  background: #f0f0f0;
  padding: 1px 4px;
  border-radius: 3px;
  font-size: 0.9em;
}}

/* Tables */
table {{
  border-collapse: collapse;
  width: 100%;
  margin: 10px 0;
  font-size: 0.9em;
  page-break-inside: avoid;
}}
th, td {{
  border: 1px solid #d0d7de;
  padding: 5px 8px;
  text-align: left;
}}
th {{ background: #f6f8fa; font-weight: 600; }}

/* Misc */
hr {{ border: none; border-top: 2px solid #ddd; margin: 16px 0; }}
blockquote {{
  border-left: 4px solid #ddd; margin: 10px 0;
  padding: 4px 14px; color: #555;
}}
img {{ max-width: 100%; }}
a {{ color: {t['h2_color']}; }}

/* Print header/footer */
.print-header, .print-footer {{
  position: fixed;
  left: 0; right: 0;
  font-size: 9px; color: #888;
  padding: 0 0.1in;
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-family: {t['body_font']};
}}
.print-header {{
  top: 0;
  height: 0.35in;
  border-bottom: 1px solid #ddd;
  {"display: flex;" if show_header else "display: none;"}
}}
.print-footer {{
  bottom: 0;
  height: 0.3in;
  border-top: 1px solid #ddd;
  {"display: flex;" if show_footer else "display: none;"}
}}
.print-header img {{ height: 16px; }}

/* Break control */
h1, h2, h3 {{ page-break-after: avoid; }}
tr {{ page-break-inside: avoid; }}

@media screen {{
  body {{ padding: 0.5in; max-width: 8.5in; margin: 0 auto; background: #fff; }}
  .print-header, .print-footer {{ display: none; }}
}}
</style>
</head>
<body>
<div class="print-header">
  <span>{hl_html}</span>
  <span>{html.escape(hr_html)}</span>
</div>
<div class="print-footer">
  <span>{html.escape(fl_html)}</span>
  <span>{html.escape(fr_html)}</span>
</div>
<div id="content">
{body_html}
</div>
</body>
</html>"""


# ============================================================
#  CLI
# ============================================================
def main():
    parser = argparse.ArgumentParser(
        description="MD2Print — Convert Markdown to print-optimized HTML",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python3 md2print.py notes.md                    # Default theme, opens browser
  python3 md2print.py notes.md --theme ocean      # Ocean Blue theme
  python3 md2print.py notes.md -o output.html     # Save to file without opening
  python3 md2print.py notes.md --h1-color '#c0392b' --body-size 12
  python3 md2print.py --list-themes               # Show all themes

Themes: default, ocean, forest, amber, slate
        """
    )
    parser.add_argument("input", nargs="?", help="Input .md file")
    parser.add_argument("-o", "--output", help="Output .html file (default: <input>.print.html)")
    parser.add_argument("--theme", default="default", help="Theme name (default, ocean, forest, amber, slate)")
    parser.add_argument("--open", action="store_true", default=True, help="Open in browser (default: yes)")
    parser.add_argument("--no-open", action="store_true", help="Don't open in browser")
    parser.add_argument("--list-themes", action="store_true", help="List available themes")

    # Override individual settings
    parser.add_argument("--body-size", type=float, help="Body font size in pt")
    parser.add_argument("--body-color", help="Body text color (hex)")
    parser.add_argument("--h1-color", help="H1 heading color (hex)")
    parser.add_argument("--h2-color", help="H2 heading color (hex)")
    parser.add_argument("--h3-color", help="H3 heading color (hex)")
    parser.add_argument("--h1-size", type=float, help="H1 font size in pt")
    parser.add_argument("--h2-size", type=float, help="H2 font size in pt")
    parser.add_argument("--h3-size", type=float, help="H3 font size in pt")
    parser.add_argument("--code-size", type=float, help="Code font size in pt")
    parser.add_argument("--margin", type=float, help="All margins in inches")
    parser.add_argument("--margin-top", type=float, help="Top margin in inches")
    parser.add_argument("--margin-bottom", type=float, help="Bottom margin in inches")
    parser.add_argument("--margin-left", type=float, help="Left margin in inches")
    parser.add_argument("--margin-right", type=float, help="Right margin in inches")
    parser.add_argument("--header-left", choices=["none", "logo"], default="none")
    parser.add_argument("--header-right", choices=["none", "filename"], default="filename")
    parser.add_argument("--footer-left", choices=["none", "date"], default="date")
    parser.add_argument("--footer-right", choices=["none", "pagenum"], default="pagenum")
    parser.add_argument("--logo", help="Path to logo PNG for header")

    args = parser.parse_args()

    if args.list_themes:
        print("Available themes:")
        for name, t in THEMES.items():
            print(f"  {name:10s}  H1: {t['h1_color']}  H2: {t['h2_color']}  H3: {t['h3_color']}  Body: {t['body_font'][:20]}")
        sys.exit(0)

    if not args.input:
        parser.error("input file is required (or use --list-themes)")

    # Load theme
    theme_name = args.theme.lower()
    if theme_name not in THEMES:
        print(f"Unknown theme '{args.theme}'. Available: {', '.join(THEMES.keys())}")
        sys.exit(1)
    theme = dict(THEMES[theme_name])

    # Apply overrides
    if args.body_size: theme['body_size'] = args.body_size
    if args.body_color: theme['body_color'] = args.body_color
    if args.h1_color: theme['h1_color'] = args.h1_color
    if args.h2_color: theme['h2_color'] = args.h2_color
    if args.h3_color: theme['h3_color'] = args.h3_color
    if args.h1_size: theme['h1_size'] = args.h1_size
    if args.h2_size: theme['h2_size'] = args.h2_size
    if args.h3_size: theme['h3_size'] = args.h3_size
    if args.code_size: theme['code_size'] = args.code_size
    if args.margin:
        theme['margin_top'] = theme['margin_bottom'] = args.margin
        theme['margin_left'] = theme['margin_right'] = args.margin
    if args.margin_top is not None: theme['margin_top'] = args.margin_top
    if args.margin_bottom is not None: theme['margin_bottom'] = args.margin_bottom
    if args.margin_left is not None: theme['margin_left'] = args.margin_left
    if args.margin_right is not None: theme['margin_right'] = args.margin_right

    # Read input
    input_path = Path(args.input)
    if not input_path.exists():
        print(f"File not found: {args.input}")
        sys.exit(1)

    md_text = input_path.read_text(encoding='utf-8')
    filename = input_path.name

    # Convert
    body_html = md_to_html(md_text)
    full_html = build_html(
        body_html, theme, filename,
        header_left=args.header_left, header_right=args.header_right,
        footer_left=args.footer_left, footer_right=args.footer_right,
        logo_path=args.logo
    )

    # Output
    if args.output:
        output_path = Path(args.output)
    else:
        output_path = input_path.with_suffix('.print.html')

    output_path.write_text(full_html, encoding='utf-8')
    print(f"Generated: {output_path}")

    if not args.no_open:
        webbrowser.open(f"file://{output_path.resolve()}")
        print("Opened in browser. Use Cmd+P to print or save as PDF.")


if __name__ == "__main__":
    main()

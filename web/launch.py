#!/usr/bin/env python3
"""
Quick Action launcher — opens md2print web app with a file pre-loaded.

Usage: python3 launch.py <file.md> [<file2.md> ...]

Creates a tiny HTML launcher that stores the markdown in localStorage,
then redirects to the web app. The web app detects the preloaded content
and renders it immediately.
"""
import json
import os
import sys
import tempfile
import webbrowser

WEBAPP = os.path.join(os.path.dirname(os.path.abspath(__file__)), "index.html")


def launch_file(filepath):
    fname = os.path.basename(filepath)
    content = open(filepath, "r", encoding="utf-8").read()
    payload = json.dumps({"filename": fname, "content": content})

    launcher_html = (
        "<!DOCTYPE html>\n"
        "<html><body><script>\n"
        "localStorage.setItem('md2print_preload', "
        + json.dumps(payload)
        + ");\n"
        "window.location.href = 'file://"
        + WEBAPP.replace("'", "\\'")
        + "';\n"
        "</script></body></html>\n"
    )

    fd, launcher_path = tempfile.mkstemp(suffix=".html", prefix="md2print_")
    with os.fdopen(fd, "w") as f:
        f.write(launcher_html)

    webbrowser.open("file://" + launcher_path)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <file.md> [<file2.md> ...]")
        sys.exit(1)

    for path in sys.argv[1:]:
        if os.path.isfile(path):
            launch_file(path)
        else:
            print(f"File not found: {path}", file=sys.stderr)

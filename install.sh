#!/bin/bash
# ============================================================
#  MD2Print — macOS Installer
#
#  Installs two things:
#    1. CLI tool  → ~/Documents/MD2Print/md2print.py
#       Web app   → ~/Documents/MD2Print/web/index.html
#    2. Quick Action → right-click .md/.txt/.markdown in Finder
#       → converts each selected file to print-ready HTML
#       → opens the HTML(s) in your default browser
#
#  Usage:
#    chmod +x install.sh && ./install.sh
#
#  After running:
#    • Right-click .md file(s) in Finder →
#      Quick Actions → "Convert to Print HTML"
#    • CLI: python3 ~/Documents/MD2Print/md2print.py <file.md>
#    • Web: open ~/Documents/MD2Print/web/index.html
# ============================================================

set -e

MD2PRINT_DIR="$HOME/Documents/MD2Print"
SERVICES_DIR="$HOME/Library/Services"
WORKFLOW_NAME="Convert to Print HTML.workflow"
WORKFLOW_PATH="$SERVICES_DIR/$WORKFLOW_NAME"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== MD2Print Installer ==="
echo ""

# 1. Create install directory
echo "Creating $MD2PRINT_DIR ..."
mkdir -p "$MD2PRINT_DIR/web"

# 2. Copy tool files
if [ -f "$SCRIPT_DIR/md2print.py" ]; then
  cp "$SCRIPT_DIR/md2print.py" "$MD2PRINT_DIR/md2print.py"
  chmod +x "$MD2PRINT_DIR/md2print.py"
  echo "  Copied md2print.py  → $MD2PRINT_DIR/"
else
  echo "  ERROR: md2print.py not found next to install.sh"
  exit 1
fi

if [ -f "$SCRIPT_DIR/web/index.html" ]; then
  cp "$SCRIPT_DIR/web/index.html" "$MD2PRINT_DIR/web/index.html"
  echo "  Copied web/index.html → $MD2PRINT_DIR/web/"
else
  echo "  WARNING: web/index.html not found — web app skipped"
fi

# 3. Create the Quick Action (Automator workflow)
echo ""
echo "Installing Quick Action: '$WORKFLOW_NAME' ..."
mkdir -p "$SERVICES_DIR"

[ -d "$WORKFLOW_PATH" ] && rm -rf "$WORKFLOW_PATH"
mkdir -p "$WORKFLOW_PATH/Contents"

# document.wflow — Automator workflow that runs md2print.py on each file
cat > "$WORKFLOW_PATH/Contents/document.wflow" << 'WFLOW_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>AMApplicationBuild</key>
	<string>523</string>
	<key>AMApplicationVersion</key>
	<string>2.10</string>
	<key>AMDocumentVersion</key>
	<integer>2</integer>
	<key>actions</key>
	<array>
		<dict>
			<key>action</key>
			<dict>
				<key>AMAccepts</key>
				<dict>
					<key>Container</key>
					<string>List</string>
					<key>Optional</key>
					<true/>
					<key>Types</key>
					<array>
						<string>com.apple.cocoa.string</string>
					</array>
				</dict>
				<key>AMActionVersion</key>
				<string>2.0.3</string>
				<key>AMApplication</key>
				<array>
					<string>Automator</string>
				</array>
				<key>AMLargeIconName</key>
				<string>Automator</string>
				<key>AMParameterProperties</key>
				<dict>
					<key>COMMAND_STRING</key>
					<dict/>
					<key>CheckedForUserDefaultShell</key>
					<dict/>
					<key>inputMethod</key>
					<dict/>
					<key>shell</key>
					<dict/>
					<key>source</key>
					<dict/>
				</dict>
				<key>AMProvides</key>
				<dict>
					<key>Container</key>
					<string>List</string>
					<key>Types</key>
					<array>
						<string>com.apple.cocoa.string</string>
					</array>
				</dict>
				<key>ActionBundlePath</key>
				<string>/System/Library/Automator/Run Shell Script.action</string>
				<key>ActionName</key>
				<string>Run Shell Script</string>
				<key>ActionParameters</key>
				<dict>
					<key>COMMAND_STRING</key>
					<string>TOOL="$HOME/Documents/MD2Print/md2print.py"
for f in "$@"; do
    case "$f" in
        *.md|*.markdown|*.txt)
            OUT=$(/usr/bin/python3 "$TOOL" "$f" --no-open 2>&amp;1 | grep "^Generated:" | sed "s/^Generated: //")
            if [ -n "$OUT" ]; then
                open "file://$OUT"
            fi
            ;;
    esac
done
</string>
					<key>CheckedForUserDefaultShell</key>
					<true/>
					<key>inputMethod</key>
					<integer>1</integer>
					<key>shell</key>
					<string>/bin/bash</string>
					<key>source</key>
					<string></string>
				</dict>
				<key>BundleIdentifier</key>
				<string>com.apple.RunShellScript</string>
				<key>CFBundleVersion</key>
				<string>2.0.3</string>
				<key>CanShowSelectedItemsWhenRun</key>
				<false/>
				<key>CanShowWhenRun</key>
				<true/>
				<key>Category</key>
				<array>
					<string>AMCategoryUtilities</string>
				</array>
				<key>Class Name</key>
				<string>RunShellScriptAction</string>
				<key>InputUUID</key>
				<string>B1A4E6A0-5A1E-4B9E-8C9F-1D2E3F4A5B6C</string>
				<key>Keywords</key>
				<array>
					<string>Shell</string>
					<string>Script</string>
					<string>Command</string>
					<string>Run</string>
					<string>Unix</string>
				</array>
				<key>OutputUUID</key>
				<string>C2B5F7B1-6B2F-5C0F-9D0A-2E3F4A5B6C7D</string>
				<key>UUID</key>
				<string>A0B4D5E6-4A0E-4A8D-8B8E-0C1D2E3F4A5B</string>
				<key>UnlocalizedApplications</key>
				<array>
					<string>Automator</string>
				</array>
			</dict>
		</dict>
	</array>
	<key>connectors</key>
	<dict/>
	<key>workflowMetaData</key>
	<dict>
		<key>applicationBundleIDsByPath</key>
		<dict/>
		<key>applicationPaths</key>
		<array/>
		<key>inputTypeIdentifier</key>
		<string>com.apple.Automator.fileSystemObject</string>
		<key>outputTypeIdentifier</key>
		<string>com.apple.Automator.nothing</string>
		<key>presentationMode</key>
		<integer>15</integer>
		<key>processesInput</key>
		<integer>0</integer>
		<key>serviceApplicationBundleID</key>
		<string>com.apple.finder</string>
		<key>serviceApplicationPath</key>
		<string>/System/Library/CoreServices/Finder.app</string>
		<key>serviceInputTypeIdentifier</key>
		<string>com.apple.Automator.fileSystemObject</string>
		<key>serviceOutputTypeIdentifier</key>
		<string>com.apple.Automator.nothing</string>
		<key>serviceProcessesInput</key>
		<integer>0</integer>
		<key>systemImageName</key>
		<string>NSTouchBarDocuments</string>
		<key>useAutomaticInputType</key>
		<integer>0</integer>
		<key>workflowTypeIdentifier</key>
		<string>com.apple.Automator.servicesMenu</string>
	</dict>
</dict>
</plist>
WFLOW_EOF

# Info.plist — file types that trigger the Quick Action
cat > "$WORKFLOW_PATH/Contents/Info.plist" << 'PLIST_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>NSServices</key>
	<array>
		<dict>
			<key>NSMenuItem</key>
			<dict>
				<key>default</key>
				<string>Convert to Print HTML</string>
			</dict>
			<key>NSMessage</key>
			<string>runWorkflowAsService</string>
			<key>NSRequiredContext</key>
			<dict>
				<key>NSTextContent</key>
				<string>FilePath</string>
			</dict>
			<key>NSSendFileTypes</key>
			<array>
				<string>net.daringfireball.markdown</string>
				<string>public.plain-text</string>
				<string>public.text</string>
			</array>
		</dict>
	</array>
</dict>
</plist>
PLIST_EOF

echo "  Quick Action installed at: $WORKFLOW_PATH"

# 4. Refresh services cache
echo ""
echo "Refreshing macOS services cache..."
/System/Library/CoreServices/pbs -flush 2>/dev/null || true

echo ""
echo "=== Installation Complete ==="
echo ""
echo "Files installed:"
echo "  CLI tool:     $MD2PRINT_DIR/md2print.py"
echo "  Web app:      $MD2PRINT_DIR/web/index.html"
echo "  Quick Action: $WORKFLOW_PATH"
echo ""
echo "Three ways to use MD2Print:"
echo ""
echo "  1. QUICK ACTION (Finder)"
echo "     Select one or more .md files → right-click →"
echo "     Quick Actions → 'Convert to Print HTML'"
echo "     Each file converts and opens as print-ready HTML."
echo ""
echo "  2. CLI"
echo "     python3 ~/Documents/MD2Print/md2print.py notes.md"
echo "     python3 ~/Documents/MD2Print/md2print.py notes.md --theme ocean"
echo "     python3 ~/Documents/MD2Print/md2print.py --list-themes"
echo ""
echo "  3. WEB APP (drag & drop)"
echo "     open ~/Documents/MD2Print/web/index.html"
echo "     Drop .md files into the browser for live-preview formatting."
echo ""

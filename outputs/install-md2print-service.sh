#!/bin/bash
# ============================================================
#  MD2Print — macOS Quick Action Installer
#
#  What this does:
#    1. Creates ~/Documents/MD2Print/ (your home for the tool)
#    2. Copies md2print.html there (if in same directory)
#    3. Installs a macOS Quick Action (right-click → "Open in MD2Print")
#       that works on .md, .txt, and .markdown files in Finder
#
#  Usage:
#    chmod +x install-md2print-service.sh
#    ./install-md2print-service.sh
#
#  After running, right-click any .md file in Finder →
#    Quick Actions → "Open in MD2Print"
# ============================================================

set -e

MD2PRINT_DIR="$HOME/Documents/MD2Print"
SERVICES_DIR="$HOME/Library/Services"
WORKFLOW_NAME="Open in MD2Print.workflow"
WORKFLOW_PATH="$SERVICES_DIR/$WORKFLOW_NAME"

echo "=== MD2Print Installer ==="
echo ""

# 1. Create MD2Print directory
echo "Creating $MD2PRINT_DIR ..."
mkdir -p "$MD2PRINT_DIR"

# 2. Copy md2print.html if present in current directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$SCRIPT_DIR/md2print.html" ]; then
  cp "$SCRIPT_DIR/md2print.html" "$MD2PRINT_DIR/md2print.html"
  echo "  Copied md2print.html → $MD2PRINT_DIR/"
else
  echo "  ⚠ md2print.html not found in current directory."
  echo "    Please copy it to $MD2PRINT_DIR/ manually."
fi

# Also copy md2print.py if present
if [ -f "$SCRIPT_DIR/md2print.py" ]; then
  cp "$SCRIPT_DIR/md2print.py" "$MD2PRINT_DIR/md2print.py"
  chmod +x "$MD2PRINT_DIR/md2print.py"
  echo "  Copied md2print.py → $MD2PRINT_DIR/"
fi

# 3. Create the Quick Action (Automator workflow)
echo ""
echo "Installing Quick Action: '$WORKFLOW_NAME' ..."
mkdir -p "$SERVICES_DIR"

# Remove old version if exists
[ -d "$WORKFLOW_PATH" ] && rm -rf "$WORKFLOW_PATH"

# Create workflow bundle structure
mkdir -p "$WORKFLOW_PATH/Contents"

# document.wflow — the Automator workflow definition
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
					<string>for f in "$@"; do
    open -a Safari "$HOME/Documents/MD2Print/md2print.html"
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

# Info.plist
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
				<string>Open in MD2Print</string>
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

# 4. Refresh services
echo ""
echo "Refreshing macOS services cache..."
/System/Library/CoreServices/pbs -flush 2>/dev/null || true

echo ""
echo "=== Installation Complete ==="
echo ""
echo "Your files:"
echo "  Tool:         $MD2PRINT_DIR/md2print.html"
echo "  CLI:          $MD2PRINT_DIR/md2print.py"
echo "  Themes:       $MD2PRINT_DIR/ (export .json files here)"
echo "  Quick Action: $WORKFLOW_PATH"
echo ""
echo "Usage:"
echo "  1. Double-click md2print.html to open in Safari"
echo "  2. Right-click any .md file → Quick Actions → 'Open in MD2Print'"
echo "  3. CLI: python3 ~/Documents/MD2Print/md2print.py <file.md>"
echo ""
echo "Note: The Quick Action opens MD2Print in Safari. You'll still"
echo "      need to drag the .md file into the tool (macOS security"
echo "      prevents auto-loading local files). A future version could"
echo "      use a local server to bypass this."
echo ""

#!/bin/bash
# ============================================================
#  MD2Print — macOS Installer
#
#  Installs everything on a fresh Mac:
#    1. CLI tool   → ~/Documents/MD2Print/md2print.py
#    2. Web app    → ~/Documents/MD2Print/web/index.html
#    3. Quick Action → right-click .md files in Finder →
#       "Convert to Print HTML" (single or multi-select)
#    4. App icon   → ~/Applications/MD2Print.app
#       (double-click or drag to Dock to launch web app)
#
#  Usage:
#    chmod +x install.sh && ./install.sh
#
#  After running:
#    • Double-click MD2Print in ~/Applications (or Dock)
#    • Right-click .md file(s) in Finder →
#      Quick Actions → "Convert to Print HTML"
#    • CLI: python3 ~/Documents/MD2Print/md2print.py <file.md>
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

# 4. Create MD2Print.app (clickable launcher for the web app)
APP_PATH="$HOME/Applications/MD2Print.app"
echo ""
echo "Creating MD2Print.app ..."
mkdir -p "$HOME/Applications"

# osacompile creates a signed AppleScript app that macOS trusts natively
[ -d "$APP_PATH" ] && rm -rf "$APP_PATH"
osacompile -o "$APP_PATH" -e 'do shell script "open $HOME/Documents/MD2Print/web/index.html"' 2>/dev/null

# Generate a custom icon using macOS PyObjC (available on all Macs)
python3 << 'ICON_PYEOF'
import os, tempfile, subprocess
try:
    from Cocoa import (NSImage, NSBitmapImageRep, NSPNGFileType, NSFont,
                       NSString, NSColor, NSMakeRect, NSMakePoint,
                       NSBezierPath, NSMakeSize,
                       NSFontAttributeName, NSForegroundColorAttributeName)

    iconset = os.path.join(tempfile.gettempdir(), "md2print.iconset")
    os.makedirs(iconset, exist_ok=True)

    sizes = {
        "icon_16x16.png": 16, "icon_16x16@2x.png": 32,
        "icon_32x32.png": 32, "icon_32x32@2x.png": 64,
        "icon_128x128.png": 128, "icon_128x128@2x.png": 256,
        "icon_256x256.png": 256, "icon_256x256@2x.png": 512,
        "icon_512x512.png": 512, "icon_512x512@2x.png": 1024,
    }

    for name, size in sizes.items():
        img = NSImage.alloc().initWithSize_(NSMakeSize(size, size))
        img.lockFocus()

        r = size * 100.0 / 512.0
        rect = NSMakeRect(0, 0, size, size)
        path = NSBezierPath.bezierPathWithRoundedRect_xRadius_yRadius_(rect, r, r)
        NSColor.colorWithCalibratedRed_green_blue_alpha_(0.29, 0.42, 0.97, 1.0).setFill()
        path.fill()

        white = NSColor.whiteColor()
        light = NSColor.colorWithCalibratedRed_green_blue_alpha_(1, 1, 1, 0.7)

        f1 = size * 0.24
        font1 = NSFont.fontWithName_size_("Helvetica Neue Bold", f1) or NSFont.boldSystemFontOfSize_(f1)
        attrs1 = {NSFontAttributeName: font1, NSForegroundColorAttributeName: white}
        s1 = NSString.stringWithString_("MD")
        sz1 = s1.sizeWithAttributes_(attrs1)
        s1.drawAtPoint_withAttributes_(NSMakePoint((size - sz1.width) / 2, size * 0.58), attrs1)

        f2 = size * 0.13
        font2 = NSFont.fontWithName_size_("Helvetica Neue", f2) or NSFont.systemFontOfSize_(f2)
        attrs2 = {NSFontAttributeName: font2, NSForegroundColorAttributeName: light}
        s2 = NSString.stringWithString_(u"\u2192 HTML")
        sz2 = s2.sizeWithAttributes_(attrs2)
        s2.drawAtPoint_withAttributes_(NSMakePoint((size - sz2.width) / 2, size * 0.38), attrs2)

        f3 = size * 0.16
        font3 = NSFont.fontWithName_size_("Helvetica Neue", f3) or NSFont.systemFontOfSize_(f3)
        attrs3 = {NSFontAttributeName: font3,
                  NSForegroundColorAttributeName: NSColor.colorWithCalibratedRed_green_blue_alpha_(1, 1, 1, 0.85)}
        s3 = NSString.stringWithString_("PRINT")
        sz3 = s3.sizeWithAttributes_(attrs3)
        s3.drawAtPoint_withAttributes_(NSMakePoint((size - sz3.width) / 2, size * 0.14), attrs3)

        img.unlockFocus()

        rep = NSBitmapImageRep.alloc().initWithData_(img.TIFFRepresentation())
        data = rep.representationUsingType_properties_(NSPNGFileType, {})
        data.writeToFile_atomically_(os.path.join(iconset, name), True)

    icns_path = os.path.expanduser("~/Applications/MD2Print.app/Contents/Resources/applet.icns")
    subprocess.run(["iconutil", "-c", "icns", iconset, "-o", icns_path], check=True)
    print("  Custom icon applied")
except Exception as e:
    print(f"  Icon generation skipped ({e}) — using default icon")
ICON_PYEOF

touch "$APP_PATH"
echo "  App installed at: $APP_PATH"

# 5. Refresh services cache
echo ""
echo "Refreshing macOS services cache..."
/System/Library/CoreServices/pbs -flush 2>/dev/null || true

echo ""
echo "=== Installation Complete ==="
echo ""
echo "Files installed:"
echo "  App:          $APP_PATH  (drag to Dock!)"
echo "  CLI tool:     $MD2PRINT_DIR/md2print.py"
echo "  Web app:      $MD2PRINT_DIR/web/index.html"
echo "  Quick Action: $WORKFLOW_PATH"
echo ""
echo "Four ways to use MD2Print:"
echo ""
echo "  1. APP ICON"
echo "     Double-click MD2Print in ~/Applications"
echo "     (drag to Dock for one-click access)"
echo ""
echo "  2. QUICK ACTION (Finder)"
echo "     Select one or more .md files → right-click →"
echo "     Quick Actions → 'Convert to Print HTML'"
echo "     Each file converts and opens as print-ready HTML."
echo ""
echo "  3. CLI"
echo "     python3 ~/Documents/MD2Print/md2print.py notes.md"
echo "     python3 ~/Documents/MD2Print/md2print.py notes.md --theme ocean"
echo "     python3 ~/Documents/MD2Print/md2print.py --list-themes"
echo ""
echo "  4. WEB APP (direct)"
echo "     open ~/Documents/MD2Print/web/index.html"
echo "     Drop .md files into the browser for live-preview formatting."
echo ""

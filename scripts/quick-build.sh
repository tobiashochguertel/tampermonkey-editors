#!/bin/bash
# Quick test script - just build and show paths

set -e

echo "🔨 Building Tampermonkey Editors..."
echo ""

cd "$(dirname "$0")/.."

# Quick build
./build_sys/mkrelease.sh -v 999

# Extract the built extensions to proper directories
echo "Extracting extensions..."
mkdir -p release/tampermonkey_editors_999.chrome_mv3
mkdir -p release/tampermonkey_editors_999.firefox_mv3

# Extract Firefox (already built as .xpi)
if [ -f "release/firefox/firefox-999.xpi" ]; then
    unzip -q release/firefox/firefox-999.xpi -d release/tampermonkey_editors_999.firefox_mv3
    
    # Create Chrome version (same code, different manifest)
    unzip -q release/firefox/firefox-999.xpi -d release/tampermonkey_editors_999.chrome_mv3
    
    # Update Chrome manifest
    cat > release/tampermonkey_editors_999.chrome_mv3/manifest.json << 'MANIFEST_EOF'
{
    "manifest_version": 3,
    "minimum_chrome_version": "102.0.0.0",
    "offline_enabled": true,
    "action": {
        "default_icon": {
            "16": "images/icon.png",
            "24": "images/icon24.png",
            "32": "images/icon32.png"
        },
        "default_title": "Tampermonkey Editors"
    },
    "icons": {
        "16": "images/icon.png",
        "24": "images/icon24.png",
        "32": "images/icon32.png",
        "48": "images/icon48.png",
        "128": "images/icon128.png"
    },
    "name": "Tampermonkey Editors",
    "short_name": "Tampermonkey Editors",
    "version": "1.0.999",
    "description": "Online editor support for Tampermonkey's userscripts",
    "default_locale": "en",
    "background": {
       "service_worker": "background.js"
    },
    "permissions": [
        "tabs",
        "webNavigation",
        "storage",
        "scripting"
    ],
    "host_permissions": [
        "https://*.vscode.dev/*"
    ],
    "options_page": "options.html"
}
MANIFEST_EOF
fi

echo ""
echo "✅ Build complete!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📂 LOAD THESE FOLDERS IN YOUR BROWSER:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "For Chrome/Edge:"
echo "  $(pwd)/release/tampermonkey_editors_999.chrome_mv3"
echo ""
echo "For Firefox:"
echo "  $(pwd)/release/tampermonkey_editors_999.firefox_mv3/manifest.json"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 Chrome: chrome://extensions/ → Load unpacked"
echo "💡 Firefox: about:debugging#/runtime/this-firefox → Load Temporary Add-on"
echo ""

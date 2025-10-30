#!/bin/bash
# Simple build script that works around mkrelease.sh issues
# This builds the extensions directly without the complex mkrelease process

set -e

echo "🔨 Building Tampermonkey Editors (Simple Build)..."
echo ""

cd "$(dirname "$0")/.."

# Make sure we're using Node 18
if command -v fnm &> /dev/null; then
    eval "$(fnm env --use-on-cd --version-file-strategy=recursive --resolve-engines --shell bash)" 2>/dev/null || true
    fnm use 2>/dev/null || true
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
echo "Using Node.js version: $(node -v)"
if [ "$NODE_VERSION" -ne 18 ]; then
    echo "⚠️  Warning: This project requires Node.js 18.x"
    echo "You have Node $(node -v). Build may fail."
    echo ""
fi

# Install dependencies with proper flags
echo "📦 Installing dependencies..."
NODE_ENV=development npm install --include=dev --silent

# Clean
echo "🧹 Cleaning previous builds..."
rm -rf out release
mkdir -p release

# Set target
export TARGET=firefox+mv3ep

# Build
echo "🔧 Building Firefox extension..."
npm run build -- -v 999 -t firefox -c off

# Package
echo "📦 Packaging..."
npm run package -- -t firefox

# Extract for development
echo "📂 Creating unpacked extensions..."
mkdir -p release/tampermonkey_editors_999.firefox_mv3
mkdir -p release/tampermonkey_editors_999.chrome_mv3

if [ -f "out/rel.xpi" ]; then
    # Extract Firefox
    unzip -q out/rel.xpi -d release/tampermonkey_editors_999.firefox_mv3
    
    # Create Chrome version (same code, different manifest)
    unzip -q out/rel.xpi -d release/tampermonkey_editors_999.chrome_mv3
    
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
else
    echo "❌ Build failed - no .xpi file created"
    exit 1
fi

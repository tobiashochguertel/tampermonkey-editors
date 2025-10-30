#!/bin/bash
# Simple build script that works around mkrelease.sh issues
# This builds the extensions directly without the complex mkrelease process

set -e

echo "🔨 Building Tampermonkey Editors (Quick Build)..."
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

# Build Firefox first
export TARGET=firefox+mv3ep
echo "🔧 Building Firefox extension..."
npm run build -- -v 999 -t firefox -c off
npm run package -- -t firefox

# Build Chrome
export TARGET=chrome+mv3
echo "🔧 Building Chrome extension..."
npm run build -- -v 999 -t chrome -c off

# Extract for development
echo "📂 Creating unpacked extensions..."
mkdir -p release/tampermonkey_editors_999.firefox_mv3
mkdir -p release/tampermonkey_editors_999.chrome_mv3

# Extract Firefox
if [ -f "out/rel.xpi" ]; then
    unzip -q out/rel.xpi -d release/tampermonkey_editors_999.firefox_mv3
    echo "✅ Firefox extension extracted"
else
    echo "❌ Firefox build failed"
    exit 1
fi

# Copy Chrome (built files are already in out/rel/)
if [ -d "out/rel" ]; then
    cp -r out/rel/* release/tampermonkey_editors_999.chrome_mv3/
    echo "✅ Chrome extension copied"
else
    echo "❌ Chrome build failed"
    exit 1
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
else
    echo "❌ Build failed - no .xpi file created"
    exit 1
fi

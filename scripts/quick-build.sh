#!/bin/bash
# Quick test script - just build and show paths

set -e

echo "🔨 Building Tampermonkey Editors..."
echo ""

cd "$(dirname "$0")/.."

# Quick build
./build_sys/mkrelease.sh -v 999

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

#!/bin/bash
set -e

# Tampermonkey Editors - Development Setup Script
# This script automates the setup process for testing the extension

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/.."

echo "🚀 Tampermonkey Editors - Development Setup"
echo "=========================================="
echo ""

# Check if running on macOS or Linux
if [[ "$OSTYPE" == "darwin"* ]]; then
    SED_CMD="sed -i ''"
    PLATFORM="macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    SED_CMD="sed -i"
    PLATFORM="Linux"
else
    echo "⚠️  Warning: Unsupported platform. This script is designed for macOS/Linux."
    SED_CMD="sed -i"
    PLATFORM="Unknown"
fi

echo "Platform: $PLATFORM"
echo ""

# Step 1: Build the extension
echo "📦 Step 1/3: Building Tampermonkey Editors extension..."
cd "$PROJECT_ROOT"

if ! command -v node &> /dev/null; then
    echo "❌ Error: Node.js is not installed."
    echo "Please install Node.js 18.x from https://nodejs.org/"
    exit 1
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -ne 18 ]; then
    echo "⚠️  Warning: This project requires Node.js 18.x, but you have $(node -v)"
    echo "Attempting to continue anyway..."
fi

# Build the extension
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install
fi

echo "Building extension..."
./build_sys/mkrelease.sh -v 999

if [ ! -d "release" ]; then
    echo "❌ Error: Build failed. No release folder created."
    exit 1
fi

echo "✅ Extension built successfully!"
echo ""

# Step 2: Setup test Tampermonkey
echo "🔧 Step 2/3: Setting up test Tampermonkey extension..."
mkdir -p other/tampermonkey
cd other/tampermonkey

if [ ! -f "tampermonkey_stable.crx" ]; then
    echo "Downloading Tampermonkey..."
    if command -v wget &> /dev/null; then
        wget https://www.tampermonkey.net/crx/tampermonkey_stable.crx
    elif command -v curl &> /dev/null; then
        curl -L -o tampermonkey_stable.crx https://www.tampermonkey.net/crx/tampermonkey_stable.crx
    else
        echo "❌ Error: Neither wget nor curl is available."
        echo "Please download manually from: https://www.tampermonkey.net/crx/tampermonkey_stable.crx"
        exit 1
    fi
fi

if [ ! -f "manifest.json" ]; then
    echo "Extracting Tampermonkey..."
    unzip -q tampermonkey_stable.crx
    
    # Modify the extension ID check
    if [[ "$PLATFORM" == "macOS" ]]; then
        sed -i '' 's/"hohmicmmlneppdcbkhepamlgfdokipcd"/"kjmbknaomholdmpocgplbkgmjdnidinh"/g' background.js 2>/dev/null || true
    else
        sed -i 's/"hohmicmmlneppdcbkhepamlgfdokipcd"/"kjmbknaomholdmpocgplbkgmjdnidinh"/g' background.js 2>/dev/null || true
    fi
fi

echo "✅ Test Tampermonkey prepared!"
echo ""

# Step 3: Show instructions
echo "📝 Step 3/3: Manual steps required..."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "NEXT STEPS - Follow these instructions:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "FOR CHROME:"
echo "-----------"
echo "1. Open Chrome and navigate to: chrome://extensions/"
echo "2. Enable 'Developer mode' (toggle in top-right corner)"
echo "3. Click 'Load unpacked' and select:"
echo "   📁 $PROJECT_ROOT/other/tampermonkey"
echo "4. Note the Tampermonkey extension ID (e.g., iomhjoeebbnlcpalefgjmleebfffgbmm)"
echo "5. Click 'Load unpacked' again and select:"
echo "   📁 $PROJECT_ROOT/release/tampermonkey_editors_999.chrome_mv3"
echo "6. Find 'Tampermonkey Editors', click 'Inspect views: service worker'"
echo "7. In the console, paste this code (replace YOUR_TM_ID):"
echo ""
echo "   chrome.storage.local.set({ 'config': { externalExtensionIds: [ 'YOUR_TM_ID' ] } })"
echo "   .then(() => { chrome.runtime.reload() });"
echo ""
echo "8. Install a test userscript in Tampermonkey"
echo "9. Click the Tampermonkey Editors icon to test!"
echo ""
echo "FOR FIREFOX:"
echo "------------"
echo "1. Open Firefox and navigate to: about:debugging#/runtime/this-firefox"
echo "2. Click 'Load Temporary Add-on'"
echo "3. Navigate to and select:"
echo "   📄 $PROJECT_ROOT/release/tampermonkey_editors_999.firefox_mv3/manifest.json"
echo "4. Install Tampermonkey from Firefox Add-ons (or use unpacked as with Chrome)"
echo "5. Follow similar configuration steps as Chrome"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "QUICK TEST:"
echo "-----------"
echo "• Right-click Tampermonkey Editors icon → Options"
echo "• Choose between 'Web Editor' or 'Desktop Editor'"
echo "• Click the extension icon to open the editor"
echo ""
echo "✨ Setup complete! Follow the manual steps above."
echo ""

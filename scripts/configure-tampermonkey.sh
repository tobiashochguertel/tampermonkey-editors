#!/bin/bash
# Auto-configuration helper for Tampermonkey Editors
# This script generates the configuration code you need to paste

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo "🔧 Tampermonkey Editors - Auto Configuration Helper"
echo "===================================================="
echo ""

if [ ! -d "release/tampermonkey_editors_999.chrome_mv3" ]; then
    echo -e "${RED}❌ Extensions not built yet!${NC}"
    echo "   Run: ./scripts/dev-setup.sh"
    exit 1
fi

echo "This script helps you configure Tampermonkey Editors to work with Tampermonkey."
echo ""
echo -e "${YELLOW}IMPORTANT: You must first load both extensions in Chrome!${NC}"
echo ""
echo "Steps:"
echo "1. Open Chrome → chrome://extensions/"
echo "2. Enable 'Developer mode'"
echo "3. Load unpacked: other/tampermonkey (test Tampermonkey)"
echo "4. Load unpacked: release/tampermonkey_editors_999.chrome_mv3"
echo ""
echo -e "${GREEN}Have you done this? (y/n)${NC}"
read -r response

if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "Please load the extensions first, then run this script again."
    exit 0
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 1: Get Tampermonkey Extension ID"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "In chrome://extensions/, find 'Tampermonkey' and look for the ID."
echo "It looks like: iomhjoeebbnlcpalefgjmleebfffgbmm (but yours will be different)"
echo ""
echo -e "${GREEN}Enter the Tampermonkey extension ID:${NC}"
read -r tm_id

if [ -z "$tm_id" ]; then
    echo -e "${RED}❌ No ID entered!${NC}"
    exit 1
fi

# Validate it looks like an extension ID (32 characters, lowercase letters)
if [[ ! "$tm_id" =~ ^[a-z]{32}$ ]]; then
    echo -e "${YELLOW}⚠️  Warning: That doesn't look like a valid extension ID${NC}"
    echo "   Extension IDs are 32 lowercase letters"
    echo "   Example: iomhjoeebbnlcpalefgjmleebfffgbmm"
    echo ""
    echo -e "${GREEN}Continue anyway? (y/n)${NC}"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2: Configure Tampermonkey Editors"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Now you need to configure Tampermonkey Editors to connect to Tampermonkey."
echo ""
echo "1. In chrome://extensions/, find 'Tampermonkey Editors'"
echo "2. Click 'Inspect views: service worker' (or 'background page')"
echo "3. This will open the DevTools console"
echo "4. Paste the following code into the console and press Enter:"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}"
cat << JSEOF
chrome.storage.local.set({ 
  'config': { 
    externalExtensionIds: [ '$tm_id' ] 
  } 
}).then(() => {
  console.log('✅ Configuration saved!');
  chrome.runtime.reload();
});
JSEOF
echo -e "${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${YELLOW}TIP: The code above is also saved to: config-tampermonkey.js${NC}"

# Save to a file for easy copying
cat > config-tampermonkey.js << JSEOF
// Tampermonkey Editors Configuration
// Paste this into the Tampermonkey Editors background console

chrome.storage.local.set({ 
  'config': { 
    externalExtensionIds: [ '$tm_id' ] 
  } 
}).then(() => {
  console.log('✅ Configuration saved!');
  chrome.runtime.reload();
});
JSEOF

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 3: Test the Extension"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "After pasting the code:"
echo ""
echo "1. Install a test userscript in Tampermonkey"
echo "   (or use an existing one)"
echo ""
echo "2. Right-click Tampermonkey Editors icon → Options"
echo "   • Choose 'Web Editor (vscode.dev)' or 'Desktop Editor (vscode://)'"
echo "   • Save"
echo ""
echo "3. Click the Tampermonkey Editors icon"
echo "   • For Web Editor: Opens vscode.dev with Tampermonkey connection"
echo "   • For Desktop Editor: Opens VS Code desktop (experimental)"
echo ""
echo -e "${GREEN}✅ Configuration complete!${NC}"
echo ""
echo "If it doesn't work:"
echo "• Check the Tampermonkey Editors console for errors"
echo "• Make sure both extensions are enabled"
echo "• Try reloading both extensions"
echo "• For vscode.dev mode: Close old tabs, open fresh ones"
echo ""

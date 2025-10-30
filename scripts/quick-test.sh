#!/bin/bash
# Quick test setup - Uses your EXISTING Tampermonkey installation
# No need to download/modify a separate Tampermonkey!

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo "🚀 Tampermonkey Editors - Quick Test Setup"
echo "==========================================="
echo ""

echo -e "${GREEN}Good news! You can use your EXISTING Tampermonkey installation!${NC}"
echo ""
echo "The extension already knows about these Tampermonkey IDs:"
echo "  • dhdgffkkebhmkfjojejmpbldmpobfkfo (Chrome Web Store)"
echo "  • gcalenpjmijncebpfijmoaglllgpjagf (Chrome Web Store Beta)"
echo "  • lcmhijbkigalmkeommnijlpobloojgfn (Edge Add-ons)"
echo "  • iikmkjmpaadaobahmlepeloendndfphd (Opera)"
echo "  • And more..."
echo ""

# Check if extensions are built
if [ ! -d "release/tampermonkey_editors_999.chrome_mv3" ]; then
    echo -e "${YELLOW}⚠️  Extensions not built yet${NC}"
    echo "   Run: ./scripts/quick-build.sh"
    echo ""
    read -p "Build now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ./scripts/quick-build.sh
    else
        exit 0
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Quick Test Steps"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Load Tampermonkey Editors in Chrome:"
echo "   • Open: chrome://extensions/"
echo "   • Enable 'Developer mode'"
echo "   • Click 'Load unpacked'"
echo "   • Select: $(pwd)/release/tampermonkey_editors_999.chrome_mv3"
echo ""
echo "2. Make sure Tampermonkey is installed and enabled"
echo "   • If not: https://chrome.google.com/webstore/detail/dhdgffkkebhmkfjojejmpbldmpobfkfo"
echo ""
echo "3. Configure Tampermonkey Editors (optional):"
echo "   • Right-click extension icon → Options"
echo "   • Choose 'Web Editor' or 'Desktop Editor'"
echo "   • Save"
echo ""
echo "4. Test it:"
echo "   • Click Tampermonkey Editors icon"
echo "   • Should open vscode.dev (web) or VS Code (desktop)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${YELLOW}IMPORTANT: Close all vscode.dev tabs before testing!${NC}"
echo "This avoids 'Extension context invalidated' errors."
echo ""
echo -e "${GREEN}That's it! No configuration needed if you have Tampermonkey from Chrome Web Store.${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔧 Advanced: Using a Custom Tampermonkey"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "If you're using a custom/unpacked Tampermonkey:"
echo ""
echo "Option 1: Use the Options Page (Recommended)"
echo "  • Right-click Tampermonkey Editors → Options"
echo "  • A new 'External Extension IDs' section will appear"
echo "  • Enter your Tampermonkey extension ID"
echo "  • Save"
echo ""
echo "Option 2: Console Configuration"
echo "  • Find your Tampermonkey ID in chrome://extensions/"
echo "  • Open Tampermonkey Editors console"
echo "  • Run:"
echo ""
echo -e "${BLUE}  chrome.storage.local.set({ 'config': { externalExtensionIds: [ 'YOUR_ID' ] } })${NC}"
echo -e "${BLUE}  .then(() => chrome.runtime.reload());${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

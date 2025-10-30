#!/bin/bash
# Quick fix script to ensure Web Editor mode is set correctly

echo ""
echo "🔧 Tampermonkey Editors - Configuration Fixer"
echo "=============================================="
echo ""
echo "This script helps fix the editor type configuration."
echo ""
echo "ISSUE: Extension might be set to 'Desktop Editor' which doesn't work yet."
echo "FIX: Set to 'Web Editor (vscode.dev)' which is fully functional."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Manual Fix (Recommended):"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Right-click Tampermonkey Editors icon → Options"
echo "2. Select 'Web Editor (vscode.dev)'"
echo "3. Click Save"
echo "4. Close ALL vscode.dev tabs"
echo "5. Click extension icon again"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Console Fix (Advanced):"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Go to: chrome://extensions/"
echo "2. Find 'Tampermonkey Editors'"
echo "3. Click 'Inspect views: service worker'"
echo "4. Paste this in the console:"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat << 'JSEOF'
// Check current config
chrome.storage.local.get('config', (result) => {
    console.log('Current config:', result);
    
    if (result.config && result.config.editorType === 'desktop') {
        console.log('⚠️  Problem found: Desktop mode is set');
        console.log('🔧 Fixing...');
        
        result.config.editorType = 'web';
        chrome.storage.local.set({ config: result.config }).then(() => {
            console.log('✅ Fixed! Set to Web Editor mode');
            chrome.runtime.reload();
        });
    } else if (result.config && result.config.editorType === 'web') {
        console.log('✅ Already set to Web Editor - configuration is correct!');
    } else {
        console.log('⚠️  No editorType set, setting to Web...');
        chrome.storage.local.set({ 
            config: { 
                editorType: 'web',
                externalExtensionIds: ['dhdgffkkebhmkfjojejmpbldmpobfkfo']
            } 
        }).then(() => {
            console.log('✅ Set to Web Editor mode');
            chrome.runtime.reload();
        });
    }
});
JSEOF
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "After fixing:"
echo "• Close ALL vscode.dev tabs"
echo "• Click Tampermonkey Editors icon"
echo "• Should open: https://vscode.dev/?connectTo=tampermonkey"
echo "• Userscripts should appear!"
echo ""

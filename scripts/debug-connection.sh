#!/bin/bash
# Debug script to check Tampermonkey Editors connection

echo ""
echo "🔍 Tampermonkey Editors - Connection Debug Helper"
echo "=================================================="
echo ""
echo "This script helps diagnose why userscripts aren't showing in vscode.dev"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 1: Check Extension Background Console"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Go to: chrome://extensions/"
echo "2. Find 'Tampermonkey Editors'"
echo "3. Click 'Inspect views: service worker'"
echo "4. Check for these log messages:"
echo ""
echo "   Expected logs:"
echo "   ✅ 'Tampermonkey Editors initialization done'"
echo "   ✅ 'Found extension dhdgffkkebhmkfjojejmpbldmpobfkfo'"
echo ""
echo "   Problem logs:"
echo "   ❌ 'unable to talk to ...'"
echo "   ❌ 'no extension to talk to'"
echo ""
echo "5. Paste this code to check configuration:"
echo ""
cat << 'JSEOF'
// Check current configuration
chrome.storage.local.get('config', (result) => {
    console.log('=== Current Configuration ===');
    console.log('Editor Type:', result.config?.editorType || 'NOT SET');
    console.log('External IDs:', result.config?.externalExtensionIds || 'NOT SET');
    console.log('Log Level:', result.config?.logLevel || 'NOT SET');
    console.log('Full config:', result.config);
});

// Check if Tampermonkey is found
console.log('\n=== Testing Tampermonkey Connection ===');
const TM_IDS = [
    'dhdgffkkebhmkfjojejmpbldmpobfkfo',  // Chrome Web Store
    'gcalenpjmijncebpfijmoaglllgpjagf',  // Beta
];

TM_IDS.forEach(id => {
    try {
        const port = chrome.runtime.connect(id);
        port.postMessage({ 
            method: 'userscripts', 
            action: 'options', 
            messageId: 'test123',
            activeUrls: ['https://vscode.dev/?connectTo=tampermonkey']
        });
        
        port.onMessage.addListener((msg) => {
            console.log(`✅ Response from ${id}:`, msg);
            if (msg && msg.allow && msg.allow.includes('list')) {
                console.log('✅ This Tampermonkey is working!');
            }
        });
        
        port.onDisconnect.addListener(() => {
            const err = chrome.runtime.lastError;
            if (err) {
                console.log(`❌ Disconnect from ${id}:`, err.message);
            }
        });
    } catch (err) {
        console.log(`❌ Cannot connect to ${id}:`, err);
    }
});
JSEOF
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2: Check vscode.dev Console"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Open vscode.dev tab: https://vscode.dev/?connectTo=tampermonkey"
echo "2. Press F12 to open DevTools"
echo "3. Go to Console tab"
echo "4. Look for our extension messages (filter by 'tampermonkey')"
echo ""
echo "   Expected:"
echo "   ✅ Messages from content.js/page.js"
echo "   ✅ '2P' or '2C' prefixed messages (our message protocol)"
echo ""
echo "   Problems:"
echo "   ❌ No messages at all = scripts not injected"
echo "   ❌ 'Extension context invalidated' = old tabs, need refresh"
echo ""
echo "5. Check Network tab:"
echo "   - Filter: 'tampermonkey'"
echo "   - Should see WebSocket or PostMessage communication"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 3: Check Script Injection"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Paste this in vscode.dev console to check if scripts loaded:"
echo ""
cat << 'JSEOF2'
// Check if our scripts were injected
console.log('Checking for Tampermonkey Editors scripts...');
console.log('Window has tampermonkey prop?', window.hasOwnProperty('tampermonkey'));
console.log('Window keys:', Object.keys(window).filter(k => k.includes('tamper')));

// Check for our event listeners
console.log('Custom events:', 
    performance.getEntriesByType('mark')
        .filter(e => e.name.includes('2P') || e.name.includes('2C'))
);

// Try to manually trigger
if (window.dispatchEvent) {
    console.log('Dispatching test event...');
    const evt = new CustomEvent('2C_8f8mn', { 
        detail: { m: 'test', a: [], r: null } 
    });
    window.dispatchEvent(evt);
}
JSEOF2
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 4: Check Tampermonkey Extension"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Go to: chrome://extensions/"
echo "2. Find 'Tampermonkey'"
echo "3. Make sure it's ENABLED ✅"
echo "4. Copy the ID (should be: dhdgffkkebhmkfjojejmpbldmpobfkfo)"
echo "5. Check Tampermonkey has userscripts installed"
echo "   - Click Tampermonkey icon → Dashboard"
echo "   - Should see at least one script"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 5: Fresh Start Procedure"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "If nothing works, try this clean start:"
echo ""
echo "1. Close ALL vscode.dev tabs"
echo "2. Reload Tampermonkey Editors extension:"
echo "   chrome://extensions/ → Tampermonkey Editors → Reload button"
echo "3. Clear extension storage:"
cat << 'JSEOF3'
chrome.storage.local.clear(() => {
    console.log('Storage cleared');
    chrome.runtime.reload();
});
JSEOF3
echo "4. Wait 2 seconds"
echo "5. Click Tampermonkey Editors icon"
echo "6. Should open fresh vscode.dev tab"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Common Issues & Solutions"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Problem: 'no extension to talk to'"
echo "Solution: Check Tampermonkey is enabled and ID is correct"
echo ""
echo "Problem: 'Extension context invalidated'"
echo "Solution: Close old tabs, reload extension, open fresh tab"
echo ""
echo "Problem: Scripts injected but no userscripts shown"
echo "Solution: Check Tampermonkey has userscripts installed"
echo ""
echo "Problem: 'editorType' is 'desktop'"
echo "Solution: Change to 'web' in options page"
echo ""
echo "Problem: Permission denied to vscode.dev"
echo "Solution: Extension needs vscode.dev permission (should be in manifest)"
echo ""

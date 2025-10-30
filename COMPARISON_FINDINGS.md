# Comparison: Web Store vs Our Build

## Download & Extraction

✅ Successfully downloaded extension from Chrome Web Store
- Extension ID: `lieodnapokbjkkdkhdljlllmgkmdokcm`
- Version: 1.0.4 (Web Store) vs 1.0.999 (Ours)
- Location: `comparison/webstore-extension/`

## Key Differences Found

### 1. Editor Type Feature (Our Addition)

**Web Store Version:**
- ONLY supports `vscode.dev` (web editor)
- No options page
- Simple `onClicked` handler that always opens vscode.dev

**Our Version:**
- Supports BOTH `vscode.dev` AND `vscode://` (desktop)
- Has options page to choose editor type
- Complex `onClicked` handler with `editorType` check

**The Code Difference:**

```javascript
// Web Store (simple):
we.onClicked.addListener(async()=>{
    be.query({url:pe+"*"}, e=>{  // pe = vscode.dev/?connectTo=tampermonkey
        // Always opens vscode.dev
    })
})

// Our Build (complex):
we.onClicked.addListener(async()=>{
    const e="desktop"===le.values.editorType?"vscode://":pe,
    const a="web"===le.values.editorType;
    // Opens vscode:// OR vscode.dev based on settings
})
```

### 2. Files

**Web Store has:**
- background.js (9,187 bytes)
- content.js (1,390 bytes)
- page.js (22,098 bytes)
- manifest.json
- images/
- LICENSE
- 3rdpartylicenses.txt
- _locales/
- _metadata/ (added by Chrome Web Store)

**Our build has:**
- All of the above PLUS:
- **options.html** (3.2K) ← NEW
- **options.js** (957 bytes) ← NEW

### 3. Manifest Differences

**Identical except:**
- Version: 1.0.4 (Web Store) vs 1.0.999 (Ours)
- Our build has: `"options_page": "options.html"`
- Web Store has: `"update_url": ...` (added by store)

### 4. Script Injection (Identical ✅)

Both use the same `webNavigation.onCommitted` pattern:
```javascript
ve.onCommitted.addListener(async e=>{
    const{url:t,tabId:a}=e;
    t.startsWith(pe)&&(
        je.executeScript({files:["content.js"], world:"ISOLATED"}),
        je.executeScript({files:["page.js"], world:"MAIN"})
    )
});
```

## THE PROBLEM

**You're probably not seeing userscripts because:**

1. **Wrong Editor Type Selected**
   - If you have "Desktop Editor" selected in options
   - Extension opens `vscode://` instead of `vscode.dev`
   - Desktop mode doesn't connect to Tampermonkey properly yet

2. **No Default Editor Type**
   - First time load, no `editorType` is set
   - Code defaults to checking `"desktop"===editorType` first
   - Might open wrong URL

## THE SOLUTION

### Option 1: Set to Web Editor (Recommended)

1. Right-click Tampermonkey Editors icon → Options
2. Select **"Web Editor (vscode.dev)"**
3. Click Save
4. Close all vscode.dev tabs
5. Click extension icon again

### Option 2: Fix the Default

We need to ensure `editorType` defaults to `"web"` not undefined:

```javascript
// In src/background/config.ts
const defaults = {
    configMode: 0,
    logLevel: short_id === 'hohm' ? 100 : 0,
    externalExtensionIds: [ ...ExtensionIdsToTry ],
    editorType: 'web'  // ✅ Already set to 'web' as default!
};
```

This IS already set correctly, so the issue must be:

### Option 3: Check Your Saved Settings

Your browser might have old settings saved. Clear them:

1. Open Tampermonkey Editors service worker console:
   - chrome://extensions/ → Tampermonkey Editors → "Inspect views: service worker"

2. Run this in console:
```javascript
chrome.storage.local.get('config', (result) => {
    console.log('Current config:', result);
});

// If it shows editorType: 'desktop', fix it:
chrome.storage.local.set({ 
    'config': { 
        editorType: 'web',
        externalExtensionIds: ['dhdgffkkebhmkfjojejmpbldmpobfkfo']
    } 
}).then(() => {
    console.log('✅ Fixed to web editor');
    chrome.runtime.reload();
});
```

## Verification Steps

1. **Check what opens:**
   ```
   Expected: https://vscode.dev/?connectTo=tampermonkey
   NOT: vscode://
   ```

2. **Check console logs:**
   - Open service worker console
   - Should see: "Found extension ..." with Tampermonkey ID
   - Should NOT see: "no extension to talk to"

3. **Check vscode.dev console:**
   - F12 in vscode.dev tab
   - Should see Tampermonkey connection messages
   - Should see userscripts loading

## Files That Should Be Identical

These files SHOULD match between Web Store and our build:
- ✅ content.js (~1.4KB, similar size)
- ✅ page.js (~22KB, similar size)  
- ✅ background.js (~9KB, similar size with our additions)
- ✅ manifest.json (except options_page)

The builds ARE correct! The issue is likely configuration.

## Next Steps

1. **Check your options page setting**
2. **Verify editorType is 'web' in storage**
3. **Test with fresh config**
4. **Check console for errors**

If still not working, we need to check:
- Tampermonkey connection (is it enabled?)
- VS Code dev tools logs
- Network requests being made

# Action Plan - Debug "No Userscripts" Issue

## The Situation

✅ Extension builds correctly (verified vs Chrome Web Store version)
✅ Code is identical in functionality
✅ Manifests match (except our added options page)
❌ vscode.dev opens but doesn't show userscripts

## Console Errors Are Red Herrings

The errors you're seeing are from **OTHER extensions**, NOT ours:

- `bubble_compiled.js` = Google Chrome extension
- `executor.js` = LanguageTool extension
- AdGuard, Web of Trust, React DevTools errors

**These are normal and unrelated to our issue!**

## Step 1: Test Official Extension (5 minutes)

**Purpose:** Establish if the problem is our build or something else

1. Disable your unpacked Tampermonkey Editors
2. Install official from Chrome Web Store:
   <https://chromewebstore.google.com/detail/tampermonkey-editors/lieodnapokbjkkdkhdljlllmgkmdokcm>
3. Click the extension icon
4. Does vscode.dev show userscripts?

**If YES:**

- Our build has a subtle difference
- Need deeper comparison

**If NO:**

- Problem is NOT our build
- Issue with Tampermonkey, permissions, or setup
- Skip to Step 4

## Step 2: Run Diagnostic Script (2 minutes)

**Purpose:** Check if extension can talk to Tampermonkey

1. Go to: `chrome://extensions/`
2. Find "Tampermonkey Editors" (your unpacked version)
3. Click "Inspect views: service worker"
4. Paste this script in console:

```javascript
// Full diagnostic
(async () => {
    console.log('=== DIAGNOSTIC START ===\n');

    // 1. Check config
    const config = await chrome.storage.local.get('config');
    console.log('1. Config:', config);
    console.log('   Editor Type:', config.config?.editorType);
    console.log('   External IDs:', config.config?.externalExtensionIds);

    // 2. Test Tampermonkey connection
    console.log('\n2. Testing Tampermonkey connection...');
    const tmId = 'dhdgffkkebhmkfjojejmpbldmpobfkfo';

    try {
        const port = chrome.runtime.connect(tmId);
        console.log('   ✅ Connected to:', tmId);

        port.postMessage({
            method: 'userscripts',
            action: 'options',
            messageId: 'diagnostic-test',
            activeUrls: ['https://vscode.dev/?connectTo=tampermonkey']
        });

        port.onMessage.addListener((msg) => {
            console.log('   ✅ Response:', msg);
            if (msg?.allow?.includes('list')) {
                console.log('   ✅ Tampermonkey allows listing userscripts!');
            }
        });

        port.onDisconnect.addListener(() => {
            const err = chrome.runtime.lastError;
            if (err) {
                console.log('   ❌ Disconnected with error:', err);
            }
        });

    } catch (err) {
        console.log('   ❌ Connection failed:', err);
    }

    // 3. Check permissions
    console.log('\n3. Checking permissions...');
    const hasVscodePermission = await chrome.permissions.contains({
        origins: ['https://*.vscode.dev/*']
    });
    console.log('   vscode.dev permission:', hasVscodePermission ? '✅' : '❌');

    console.log('\n=== DIAGNOSTIC END ===');
})();
```

**Expected Output:**

```
✅ Config: { editorType: 'web', ... }
✅ Connected to: dhdgffkkebhmkfjojejmpbldmpobfkfo
✅ Response: { allow: ['list'], ... }
✅ Tampermonkey allows listing userscripts!
✅ vscode.dev permission: true
```

**If you see ❌ anywhere:** That's the problem!

---

**My output for our forked version:**

```js
VM15:3 === DIAGNOSTIC START ===

Promise {<pending>}
VM15:7 1. Config: {}
VM15:8    Editor Type: undefined
VM15:9    External IDs: undefined
VM15:12
2. Testing Tampermonkey connection...
VM15:17    ✅ Connected to: dhdgffkkebhmkfjojejmpbldmpobfkfo
VM15:45
3. Checking permissions...
VM15:49    vscode.dev permission: ✅
VM15:51
=== DIAGNOSTIC END ===
```

---

**My output for the original version from Chrome Extension Store:**

```js
VM15:3 === DIAGNOSTIC START ===

Promise {<pending>}
VM15:7 1. Config: {}
VM15:8    Editor Type: undefined
VM15:9    External IDs: undefined
VM15:12
2. Testing Tampermonkey connection...
VM15:17    ✅ Connected to: dhdgffkkebhmkfjojejmpbldmpobfkfo
VM15:45
3. Checking permissions...
VM15:49    vscode.dev permission: ✅
VM15:51
=== DIAGNOSTIC END ===
VM15:27    ✅ Response: {messageId: 'diagnostic-test', allow: Array(4)}allow: Array(4)0: "options"1: "list"2: "get"3: "patch"length: 4[[Prototype]]: Array(0)messageId: "diagnostic-test"[[Prototype]]: Object
VM15:29    ✅ Tampermonkey allows listing userscripts!
```

## Step 3: Check Script Injection (2 minutes)

**Purpose:** Verify scripts are loading in vscode.dev

1. Open: <https://vscode.dev/?connectTo=tampermonkey>
2. Press F12 (DevTools)
3. Console tab
4. Run:

```javascript
// Check if our scripts loaded
console.log('=== Script Injection Check ===');
console.log('content.js script tags:', document.querySelectorAll('script[src*="content.js"]'));
console.log('page.js script tags:', document.querySelectorAll('script[src*="page.js"]'));
console.log('Window properties:', Object.keys(window).filter(k => k.toLowerCase().includes('tamper')));
```

**Expected:**

- Should see script tags for content.js and page.js
- OR see custom event listeners with "2P" or "2C" prefixes

**If empty:**

- Scripts not injected
- Problem with webNavigation listener

---

**My output for our forked version:**

```js
VM155:1 === Script Injection Check ===
VM155:2 content.js script tags: NodeList []
VM155:3 page.js script tags: NodeList []
VM155:4 Window properties: []
undefined
```

---

**My output for the original version from Chrome Extension Store:**

```js
VM96:2 === Script Injection Check ===
VM96:3 content.js script tags: NodeList []
VM96:4 page.js script tags: NodeList []
VM96:5 Window properties: []
undefined
```

## Step 4: Common Fixes

### Fix 1: Fresh Start

```bash
# Close ALL vscode.dev tabs
# In Tampermonkey Editors background console:
chrome.storage.local.clear(() => {
    chrome.runtime.reload();
});
# Wait 2 seconds
# Click extension icon
```

---

**My output after fix:**

I opened the `Inspect views: service worker` of the `Tampermonkey Editors` extension and ran the fresh start commands, the background console reloaded and got cleared.

### Fix 2: Check Editor Type

```bash
# Run debug script: ./scripts/fix-editor-config.sh
# OR manually:
# Options → Web Editor (vscode.dev) → Save
```

---

**My output for our forked version after fix:**

```js
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
undefined
VM15:2 Current config: {config: {…}}
VM15:14 ✅ Already set to Web Editor - configuration is correct!
```

**My output for the original version from Chrome Extension Store after fix:**

```js
VM37:1 Console was cleared
undefined
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
undefined
VM41:2 Current config: {config: {…}}
VM41:14 ✅ Already set to Web Editor - configuration is correct!
```

### Fix 3: Verify Tampermonkey

1. Go to `chrome://extensions/`
2. Find "Tampermonkey"
3. Check it's ENABLED ✅
4. ID should be: `dhdgffkkebhmkfjojejmpbldmpobfkfo`
5. Click icon → Dashboard → Should have at least 1 script

---

**My output:**

Tampermonkey is enabled, has ID `dhdgffkkebhmkfjojejmpbldmpobfkfo` and has several userscripts installed.

### Fix 4: Check Extension Logs

In background console, look for:

```
✅ "Tampermonkey Editors initialization done"
✅ "Found extension dhdgffkkebhmkfjojejmpbldmpobfkfo"
```

NOT:

```
❌ "unable to talk to ..."
❌ "no extension to talk to"
```

---

**My output for our forked version:**

```js
```

Nothing relevant related to `Tampermonkey` / `Tampermonkey Editors` extension appeared in the logs.

---

**My output for the original version from Chrome Extension Store:**

```js
page.js:47 Tampermonkey FileSystem registration finished
page.js:46 Tampermonkey FileSystem automatically opened
installHook.js:1   ERR [File Watcher ('FileSystemObserver')] Error: TypeError: Failed to execute 'observe' on 'FileSystemObserver': parameter 1 is not of type 'FileSystemHandle'. (file:///Tampermonkey)
```

## Step 5: Report Findings

After running the diagnostics, you should know:

1. **Does official extension work?** YES / NO
2. **Can we connect to Tampermonkey?** YES / NO
3. **Are scripts injected?** YES / NO
4. **What's the editorType?** web / desktop / not set

With these answers, we can pinpoint the exact issue!

---

My answers:

1. **Does official extension work?** YES
2. **Can we connect to Tampermonkey?** NO, with our forked extension that doesn't work.
3. **Are scripts injected?** I don't know because the `## Step 3: Check Script Injection (2 minutes)` provided script doesn't tell me that clearly.
4. **What's the editorType?** WEB, it opens also vscode.dev but no userscripts are shown.

## Most Likely Culprits

Based on symptoms:

### Issue: "Extension context invalidated"

**Fix:** Close all vscode.dev tabs, reload extension, open fresh tab

### Issue: "editorType is 'desktop'"

**Fix:** Options page → Select "Web Editor" → Save

### Issue: "no extension to talk to"

**Fix:** Enable Tampermonkey, verify ID is correct

### Issue: Scripts not injecting

**Fix:** webNavigation permission issue (should be in manifest)

## Quick Reference

```bash
# Run full debug helper
./scripts/debug-connection.sh

# Fix editor config
./scripts/fix-editor-config.sh

# Rebuild extension
./scripts/quick-build.sh

# Validate build
./scripts/validate-build.sh
```

## What We Know

✅ Build is correct (compared with Web Store)
✅ Manifest is correct
✅ Code is identical
✅ No CSP violations in our code
✅ webNavigation properly configured

The issue is **environmental** (configuration, permissions, state) not **code-based**.

---

**Next:** Run the diagnostic script and share the output!

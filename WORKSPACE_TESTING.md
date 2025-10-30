# Quick Testing Guide

## Three Versions Ready to Test

### 1. Upstream Original (Pure Code)
**Path:** `../tampermonkey-editors-upstream-original/out/rel/`
**Status:** Built and ready ✅
**Test this FIRST** to establish baseline

### 2. Chrome Web Store (Official)
**Path:** `../tampermonkey-editors-webstore/`
**Status:** Ready (no build needed) ✅
**Test this SECOND** to confirm official works

### 3. Main Fork (Your Changes)
**Path:** `./release/tampermonkey_editors_999.chrome_mv3/`
**Status:** Built and ready ✅
**Test this LAST** to identify issue

## Quick Test Steps

```bash
# 1. Open Chrome
chrome://extensions/

# 2. Enable Developer Mode

# 3. Load all three extensions as "Load unpacked"
#    They'll all show as "Tampermonkey Editors"

# 4. Disable all except upstream-original

# 5. Close ALL vscode.dev tabs

# 6. Click extension icon

# 7. Check if userscripts appear

# 8. Repeat for webstore and main fork
```

## Expected Results

| Version | Connects to TM | Gets Response | Shows Scripts |
|---------|---------------|---------------|---------------|
| Upstream Original | ✅ | ✅ | ✅ (expected) |
| Chrome Web Store | ✅ | ✅ | ✅ (expected) |
| Main Fork | ✅ | ❌ | ❌ (problem!) |

## Diagnostic Script

Run in background console (`Inspect views: service worker`):

```javascript
(async () => {
    const config = await chrome.storage.local.get('config');
    console.log('Config:', config);
    
    const port = chrome.runtime.connect('dhdgffkkebhmkfjojejmpbldmpobfkfo');
    port.postMessage({
        method: 'userscripts',
        action: 'options',
        messageId: 'test'
    });
    
    port.onMessage.addListener((msg) => {
        console.log('Response:', msg);
    });
})();
```

## Workspace in VS Code

Open: `/Users/tobiashochgurtel/work-dev/userscript/userscript.code-workspace`

You'll see all three folders:
- tampermonkey-editors (MAIN - Your Fork)
- tampermonkey-editors-upstream-original (Pure Upstream)  
- tampermonkey-editors-webstore (Chrome Store)

Compare files side-by-side to find differences!

---

See `../WORKSPACE_SETUP.md` for complete guide.

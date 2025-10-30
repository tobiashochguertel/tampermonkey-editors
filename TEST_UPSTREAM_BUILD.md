# Test Upstream Original Build

## Purpose

Test the PURE upstream code with ZERO modifications to establish baseline.

## The Build is Ready

The upstream original is already built in: `comparison/upstream-built/`

This is the EXACT same code as Chrome Web Store (9187 bytes match).

## Testing Steps

### 1. Load Upstream Build in Browser

```
1. Go to chrome://extensions/
2. Click "Load unpacked"
3. Navigate to:
   /Users/tobiashochgurtel/work-dev/userscript/tampermonkey-editors/comparison/upstream-built/
4. Click "Select"
```

### 2. Disable Other Versions

```
- Disable your fork
- Disable Web Store version (if installed)
- Only upstream-built should be active
```

### 3. Fresh Start

```
1. Close ALL browser tabs
2. Close ALL vscode.dev tabs
3. Reload the extension
4. Restart browser (optional but recommended)
```

### 4. Open Background Console

```
1. chrome://extensions/
2. Find "Tampermonkey Editors" (upstream build)
3. Click "Inspect views: service worker"
4. Keep console open
```

### 5. Test

```
1. Click Tampermonkey Editors icon
2. Watch background console for logs
3. Check if vscode.dev opens
4. Check if userscripts appear
```

### 6. Run Diagnostic

In background console:

```javascript
(async () => {
    console.log('=== UPSTREAM BUILD DIAGNOSTIC ===\n');
    
    // Check config
    const config = await chrome.storage.local.get('config');
    console.log('Config:', config);
    
    // Test Tampermonkey
    const tmId = 'dhdgffkkebhmkfjojejmpbldmpobfkfo';
    try {
        const port = chrome.runtime.connect(tmId);
        console.log('✅ Connected to Tampermonkey');
        
        port.postMessage({
            method: 'userscripts',
            action: 'options',
            messageId: 'upstream-test',
            activeUrls: ['https://vscode.dev/?connectTo=tampermonkey']
        });
        
        port.onMessage.addListener((msg) => {
            console.log('✅ Response:', msg);
            if (msg?.allow?.includes('list')) {
                console.log('✅ UPSTREAM BUILD WORKS!');
            }
        });
        
    } catch (err) {
        console.log('❌ Failed:', err);
    }
})();
```

## Expected Results

If upstream build WORKS:
- ✅ Opens vscode.dev
- ✅ Gets response from Tampermonkey
- ✅ Shows userscripts

Then the problem IS our changes!

If upstream build FAILS:
- Something else is wrong (environment, Tampermonkey, permissions)

## Compare Results

### Upstream Build:
- Response from Tampermonkey? YES / NO
- Userscripts shown? YES / NO

### Your Fork:
- Response from Tampermonkey? NO (confirmed)
- Userscripts shown? NO (confirmed)

## Next Steps Based on Results

### If Upstream Works:

Problem is our changes. Need to:
1. Compare our changes with upstream
2. Find which change breaks communication
3. Fix or revert that change

Suspect: The editorType config changes

### If Upstream Also Fails:

Problem is environmental:
1. Tampermonkey configuration
2. Browser permissions
3. Testing methodology
4. Extension state

## Rebuilding Upstream if Needed

```bash
cd /Users/tobiashochgurtel/work-dev/userscript/tampermonkey-editors
git checkout upstream-original
fnm use 18
npm install
npm run build
# Output in: out/rel/
```

## Files Location

- **Upstream build:** `comparison/upstream-built/`
- **Your fork build:** `release/tampermonkey_editors_999.chrome_mv3/`
- **Web Store download:** `comparison/webstore-extension/`

All three should behave the same (upstream = webstore = working)

## Report Back

After testing, report:

1. **Does upstream build show response?** YES/NO
2. **Does upstream build show userscripts?** YES/NO
3. **Any console errors?**
4. **Background console logs?**

This will tell us if the problem is our code or something else!

---

**Key Insight:**

If upstream works, we can binary search our changes to find the breaking one!

If upstream fails, we need to investigate environment/setup instead.

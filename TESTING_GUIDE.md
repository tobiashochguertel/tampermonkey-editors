# Tampermonkey Editors - Testing Guide

## TL;DR - Simplest Way to Test

```bash
# 1. Build
./scripts/quick-build.sh

# 2. Load in Chrome
# chrome://extensions/ → Load unpacked → select release/tampermonkey_editors_999.chrome_mv3/

# 3. Test
# Click the Tampermonkey Editors icon!
```

**That's it!** Your existing Tampermonkey from Chrome Web Store will work automatically.

---

## Your Questions Answered

### Q1: Do I need to download/modify a separate Tampermonkey?

**NO!** You can use your existing Tampermonkey installation.

The extension **already knows** about official Tampermonkey IDs:
- `dhdgffkkebhmkfjojejmpbldmpobfkfo` (Chrome Web Store) ← Your ID!
- `gcalenpjmijncebpfijmoaglllgpjagf` (Chrome Web Store Beta)
- `lcmhijbkigalmkeommnijlpobloojgfn` (Edge)
- `iikmkjmpaadaobahmlepeloendndfphd` (Opera)
- And 3 more...

See: `src/background/find_tm.ts` lines 14-22

### Q2: Can I use my Arc Tampermonkey (ID: dhdgffkkebhmkfjojejmpbldmpobfkfo)?

**YES!** That's the Chrome Web Store ID, which is **built-in** to the extension.

No configuration needed!

### Q3: Why does the original README say to modify Tampermonkey?

The `sed` command exists for **advanced testing only**:

```bash
sed -i 's/"hohmicmmlneppdcbkhepamlgfdokipcd"/"kjmbknaomholdmpocgplbkgmjdnidinh"/' background.js
```

**What it does:** Modifies Tampermonkey's security check to allow connections from a different extension ID.

**When you need it:**
- Testing with TWO Tampermonkeys simultaneously
- Development/debugging
- Building a custom Tampermonkey

**For normal use:** NOT NEEDED!

### Q4: Can we validate the sed command succeeded?

**YES!** I've updated `dev-setup.sh` to validate:

```bash
# Check if sed was applied
if grep -q "hohmicmmlneppdcbkhepamlgfdokipcd" other/tampermonkey/background.js; then
    echo "❌ sed command may have failed"
    echo "   Original ID still found in background.js"
else
    echo "✅ Tampermonkey modified successfully"
fi
```

### Q5: Can we add a UI to configure the extension ID?

**DONE!** ✅

**New Options Page Features:**
1. Right-click Tampermonkey Editors → Options
2. See "External Extension IDs (Advanced)" field
3. Enter custom IDs (comma-separated for multiple)
4. Leave empty to use defaults (recommended)
5. Save → Extension auto-reloads

**Benefits:**
- No console needed!
- Clear UI
- Multiple IDs supported
- Works immediately

### Q6: Can we set a default ID for development?

**Already handled!** The extension has smart defaults:

```typescript
// src/background/find_tm.ts
export const ExtensionIdsToTry = [
    'dhdgffkkebhmkfjojejmpbldmpobfkfo',  // Chrome Web Store
    'gcalenpjmijncebpfijmoaglllgpjagf',  // Beta
    // ... and more
];
```

For development with a custom ID, use the Options page or set an environment variable.

---

## Testing Workflows

### Workflow 1: Simple Testing (Recommended)

Use your existing Tampermonkey:

```bash
# Build
./scripts/quick-build.sh

# Validate (optional)
./scripts/validate-build.sh

# Load in browser
# chrome://extensions/ → Load unpacked → release/tampermonkey_editors_999.chrome_mv3/

# Done! Click the extension icon
```

### Workflow 2: Advanced Testing

Download and modify a test Tampermonkey:

```bash
# Full setup (downloads TM, modifies it, builds extensions)
./scripts/dev-setup.sh

# Follow on-screen instructions
```

### Workflow 3: Custom Tampermonkey ID

If using unpacked/custom Tampermonkey:

**Option A - UI (Recommended):**
1. Load both extensions
2. Right-click Tampermonkey Editors → Options
3. Enter your custom ID in "External Extension IDs"
4. Save

**Option B - Console:**
```javascript
chrome.storage.local.set({ 
  'config': { 
    externalExtensionIds: [ 'your-custom-id' ] 
  } 
}).then(() => chrome.runtime.reload());
```

---

## Why Download Tampermonkey vs Use Installed?

### Use Installed Tampermonkey When:
- ✅ Normal testing
- ✅ Quick iteration
- ✅ Using Chrome Web Store/Edge/Opera Tampermonkey
- ✅ You just want it to work

### Download Test Tampermonkey When:
- ⚠️ Testing with multiple Tampermonkey versions
- ⚠️ Debugging extension communication
- ⚠️ Development of communication protocol
- ⚠️ Need to modify Tampermonkey source

---

## File Structure After Setup

```
tampermonkey-editors/
├── release/
│   ├── tampermonkey_editors_999.chrome_mv3/    ← Load this
│   └── tampermonkey_editors_999.firefox_mv3/
├── other/                                        
│   └── tampermonkey/                            ← Optional test TM
│       └── background.js                        ← Modified if using dev-setup
└── scripts/
    ├── quick-build.sh      ← Simple build
    ├── quick-test.sh       ← New! Simplest testing
    ├── dev-setup.sh        ← Advanced (downloads TM)
    └── validate-build.sh   ← Checks builds
```

---

## Common Issues

### "Extension context invalidated"
**Cause:** Old content scripts after extension reload
**Fix:** Close ALL vscode.dev tabs, open fresh ones

### "No extension to talk to"
**Possible causes:**
1. Tampermonkey not installed/enabled
2. Using custom ID not in config
3. Extension communication blocked

**Fix:**
- Check Tampermonkey is enabled
- For custom ID: Add to Options page
- Check console for errors

### CSP Violations
**Cause:** Wrong build (Firefox code in Chrome)
**Fix:** Run `./scripts/validate-build.sh` to check

---

## Scripts Reference

| Script | Use Case | Downloads TM? |
|--------|----------|---------------|
| `quick-test.sh` | Simplest testing | No |
| `quick-build.sh` | Build extensions | No |
| `dev-setup.sh` | Full advanced setup | Yes |
| `validate-build.sh` | Check builds | No |
| `configure-tampermonkey.sh` | Generate config | No |

---

## Summary

**You asked:**
> Can we not use the Tampermonkey extension which I have just installed?

**Answer:** **YES!** Your Tampermonkey (`dhdgffkkebhmkfjojejmpbldmpobfkfo`) is **already supported**. No download or modification needed!

**You asked:**
> Can we add a Settings property for the extension ID?

**Answer:** **DONE!** ✅ Options page now has "External Extension IDs" field.

**You asked:**
> Can we set a default for development?

**Answer:** **Already done!** Chrome Web Store ID is the first default. Use Options page for custom IDs.

**Result:** Testing is now **much simpler** than the original README!


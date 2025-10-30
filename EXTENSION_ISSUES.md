# Extension Issues and Fixes

## Issue 1: Chrome Extension Not Working with vscode.dev ✅ FIXED

### Problem:
The extension was using Firefox-compiled code for Chrome, which used `registerContentScripts` API instead of Chrome's `webNavigation` API.

### Solution:
Build proper Chrome and Firefox extensions separately instead of converting Firefox to Chrome.

**Fixed in commit:** Build proper Chrome extension with webNavigation API

### Files Changed:
- `scripts/simple-build.sh` - Now builds both Firefox and Chrome separately
- `scripts/quick-build.sh` - Same fix needed
- `scripts/dev-setup.sh` - Same fix needed

---

## Issue 2: Desktop Mode (vscode://) Opens But Doesn't Load Script ⚠️ LIMITATION

### Problem:
When using "Desktop Editor" mode, clicking the extension icon opens `vscode://` protocol which launches VS Code desktop, but no script/file is passed to it.

### Current Behavior:
```javascript
// In background/index.ts line ~180
const mainUrl = getMainUrl(); // Returns "vscode://"  
tabs.create({ url: mainUrl, active: true }); // Just opens VS Code
```

### Why This Happens:
The `vscode://` protocol handler can accept parameters, but we're not passing any:
- `vscode://` - Just opens VS Code
- `vscode://file/path/to/file` - Opens a specific file
- `vscode://vscode.remote/ssh-remote+host/path` - Opens remote file

### Required Changes to Fix:

#### Option A: Use Temporary Files (Recommended)
```typescript
// 1. Write script content to temporary file
const tempFile = await createTempFile(scriptContent);

// 2. Open in VS Code
const url = `vscode://file/${tempFile}`;
tabs.create({ url, active: true });
```

**Pros:** Simple, works immediately
**Cons:** Files are temporary, changes might not sync back to Tampermonkey

#### Option B: VS Code Extension Integration
Create a companion VS Code extension that:
1. Registers custom URI scheme: `vscode://tampermonkey/edit?scriptId=xxx`
2. Communicates with Tampermonkey via local WebSocket/HTTP
3. Provides bidirectional sync

**Pros:** Full integration, auto-save back to Tampermonkey
**Cons:** Requires separate VS Code extension development

#### Option C: Remote Development
Use VS Code's Remote Development with local server:
1. Extension starts local server
2. Serves script files via WebDAV/HTTP
3. Opens: `vscode://vscode-remote/localhost/scripts/myscript.js`

**Pros:** Professional setup, full sync
**Cons:** Complex implementation

### Immediate Workaround for Users:

Currently, desktop mode will:
1. Open VS Code application ✅
2. NOT load any script ❌

Users need to:
1. Keep using "Web Editor" mode for now (fully functional)
2. OR manually open Tampermonkey script files in desktop VS Code

### Recommended Next Steps:

1. **Short term**: Add warning in Options page that Desktop mode is experimental
2. **Medium term**: Implement Option A (temp files)
3. **Long term**: Implement Option B (VS Code extension)

---

##Current Status:

✅ **Web Editor (vscode.dev)**: Fully functional with proper Chrome build
✅ **Options Page**: Working, can switch between modes
⚠️ **Desktop Editor**: Opens VS Code but needs integration work

---

## Testing:

### Test Web Editor:
1. Load proper Chrome extension: `release/tampermonkey_editors_999.chrome_mv3/`
2. Open Options → Select "Web Editor"
3. Click extension icon
4. Should open vscode.dev with Tampermonkey integration ✅

### Test Desktop Editor:
1. Open Options → Select "Desktop Editor"
2. Click extension icon  
3. VS Code desktop opens ✅
4. No script loads (expected limitation) ⚠️


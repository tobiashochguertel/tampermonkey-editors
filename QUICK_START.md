# Quick Start Guide - Tampermonkey Editors

## 🎯 Goal
Test the Tampermonkey Editors extension (with Web/Desktop VS Code support) in your browser.

---

## ⚡ Super Quick Method

### Option 1: Automated (Recommended)
```bash
./scripts/dev-setup.sh
```
Then follow the on-screen instructions.

### Option 2: Just Build
```bash
./scripts/quick-build.sh
```
Builds and shows you the paths to load in your browser.

---

## 📋 Step-by-Step (Chrome)

### 1️⃣ Build
```bash
./build_sys/mkrelease.sh -v 999
```

### 2️⃣ Load Extension
1. Open: `chrome://extensions/`
2. Enable: "Developer mode" (top-right toggle)
3. Click: "Load unpacked"
4. Select: `./release/tampermonkey_editors_999.chrome_mv3/`

### 3️⃣ Test
1. Right-click extension icon → "Options"
2. Choose "Web Editor" or "Desktop Editor"
3. Click "Save Settings"
4. Install any userscript via Tampermonkey
5. Click Tampermonkey Editors icon → Editor opens! 🎉

---

## 📋 Step-by-Step (Firefox)

### 1️⃣ Build
```bash
./build_sys/mkrelease.sh -v 999
```

### 2️⃣ Load Extension
1. Open: `about:debugging#/runtime/this-firefox`
2. Click: "Load Temporary Add-on"
3. Select: `./release/tampermonkey_editors_999.firefox_mv3/manifest.json`

### 3️⃣ Test
Same as Chrome steps 3️⃣ above.

---

## 🔧 Testing with Tampermonkey Integration

If you want to test the **full integration** with Tampermonkey:

### Quick Setup
```bash
# Download and prepare test Tampermonkey
mkdir -p other/tampermonkey
cd other/tampermonkey
curl -L -o tampermonkey_stable.crx https://www.tampermonkey.net/crx/tampermonkey_stable.crx
unzip tampermonkey_stable.crx

# macOS:
sed -i '' 's/"hohmicmmlneppdcbkhepamlgfdokipcd"/"kjmbknaomholdmpocgplbkgmjdnidinh"/g' background.js

# Linux:
sed -i 's/"hohmicmmlneppdcbkhepamlgfdokipcd"/"kjmbknaomholdmpocgplbkgmjdnidinh"/g' background.js

cd ../..
```

### In Chrome
1. Load `./other/tampermonkey` as unpacked extension
2. **Copy Tampermonkey's extension ID** (shows under the extension name)
3. Load Tampermonkey Editors (as described above)
4. In Tampermonkey Editors, click "Inspect views: service worker"
5. In console, run (replace `YOUR_ID`):
   ```javascript
   chrome.storage.local.set({ 'config': { externalExtensionIds: [ 'YOUR_ID' ] } })
   .then(() => { chrome.runtime.reload() });
   ```

Now the extensions can communicate!

---

## 🎨 Testing the New Features

### Test Web Editor (vscode.dev)
1. Options → Select "Web Editor" → Save
2. Click extension icon
3. ✅ Should open vscode.dev in browser

### Test Desktop Editor (VS Code)
1. Options → Select "Desktop Editor" → Save  
2. Click extension icon
3. ✅ Should launch VS Code application

---

## 🐛 Troubleshooting

### "Build failed"
- Check Node.js version: `node -v` (should be 18.x)
- Try: `rm -rf node_modules && npm install`

### "Extension won't load"
- Make sure Developer mode is enabled
- Check browser console for errors
- Try reloading: click the reload icon on extension card

### "Desktop mode doesn't work"
- Ensure VS Code is installed
- Check if `vscode://` protocol works: open terminal and run:
  ```bash
  open "vscode://"  # macOS
  xdg-open "vscode://"  # Linux
  ```

### "Can't configure Tampermonkey ID"
- Make sure you load Tampermonkey FIRST
- Copy the ID carefully (no spaces)
- Reload Tampermonkey Editors after setting config

---

## 📚 More Info

- Full details: See [README.md](./README.md)
- Implementation: See [DESKTOP_VSCODE_SUPPORT.md](./DESKTOP_VSCODE_SUPPORT.md)

---

## ✨ Tips

- **Quick rebuild**: `./scripts/quick-build.sh`
- **Watch mode**: `npm run build:watch` (auto-rebuilds on changes)
- **Browser reload**: Just click the reload icon, no need to re-add extension
- **Test both modes**: You can switch between Web/Desktop anytime in Options!

---

**Happy Testing! 🚀**

# Tampermonkey Editors

Online editor support for Tampermonkey's userscripts with both **Web Editor (vscode.dev)** and **Desktop Editor (VS Code)** support.

## ✨ New Features

- 🌐 **Web Editor**: Edit scripts in VS Code for the Web (vscode.dev)
- 💻 **Desktop Editor**: Edit scripts in VS Code Desktop application
- ⚙️ **User Preference**: Choose your preferred editor in the Options page
- 🔄 **Easy Switching**: Change between editors anytime via extension options

## 🚀 Quick Start (Recommended)

### Automated Setup

Use our automated setup script to build and prepare everything:

```bash
./scripts/dev-setup.sh
```

This script will:
1. Build the Tampermonkey Editors extension
2. Download and prepare a test Tampermonkey extension
3. Display step-by-step instructions for browser installation

**Then follow the on-screen instructions to load the extensions in your browser.**

---

## 📖 Manual Setup (Alternative)

### Step 1: Build the Extension

**Prerequisites:**
- Node.js 18.x ([download here](https://nodejs.org/))
- npm 8.0.0 or higher

**Build commands:**

```bash
# Install dependencies
npm install

# Build the extension
./build_sys/mkrelease.sh -v 999
```

The extension packages will be created in `./release/` folder:
- `tampermonkey_editors_999.chrome_mv3/` - For Chrome/Edge
- `tampermonkey_editors_999.firefox_mv3/` - For Firefox

### Step 2: Prepare Test Tampermonkey

```bash
mkdir -p other/tampermonkey
cd other/tampermonkey
wget https://www.tampermonkey.net/crx/tampermonkey_stable.crx
unzip tampermonkey_stable.crx

# For macOS:
sed -i '' 's/"hohmicmmlneppdcbkhepamlgfdokipcd"/"kjmbknaomholdmpocgplbkgmjdnidinh"/g' background.js

# For Linux:
sed -i 's/"hohmicmmlneppdcbkhepamlgfdokipcd"/"kjmbknaomholdmpocgplbkgmjdnidinh"/g' background.js
```

### Step 3A: Load in Chrome/Edge

1. **Open Extensions Page**
   - Navigate to `chrome://extensions/`
   - Enable "Developer mode" (toggle in top-right corner)

2. **Load Test Tampermonkey**
   - Click "Load unpacked"
   - Select folder: `./other/tampermonkey`
   - **Copy the extension ID** (e.g., `iomhjoeebbnlcpalefgjmleebfffgbmm`)

3. **Load Tampermonkey Editors**
   - Click "Load unpacked" again
   - Select folder: `./release/tampermonkey_editors_999.chrome_mv3`

4. **Configure Connection**
   - Find "Tampermonkey Editors" in the extensions list
   - Click "Inspect views: service worker" (opens DevTools console)
   - Paste this code (replace `YOUR_TM_ID` with the ID you copied):

   ```javascript
   chrome.storage.local.set({ 'config': { externalExtensionIds: [ 'YOUR_TM_ID' ] } })
   .then(() => {
       chrome.runtime.reload()
   });
   ```

5. **Test It**
   - Install a test userscript in Tampermonkey
   - Click the Tampermonkey Editors icon in the toolbar
   - Your chosen editor should open!

### Step 3B: Load in Firefox

1. **Open Debugging Page**
   - Navigate to `about:debugging#/runtime/this-firefox`

2. **Load Tampermonkey Editors**
   - Click "Load Temporary Add-on"
   - Navigate to and select: `./release/tampermonkey_editors_999.firefox_mv3/manifest.json`

3. **Install Tampermonkey**
   - Install from [Firefox Add-ons](https://addons.mozilla.org/firefox/addon/tampermonkey/)
   - OR use unpacked version (same as Chrome steps above)

4. **Configure Connection**
   - Similar to Chrome, configure the extension IDs in the console

5. **Test It**
   - Install a test userscript
   - Click the extension icon to open the editor

---

## ⚙️ Choosing Your Editor

1. Right-click the **Tampermonkey Editors** icon
2. Select **"Options"**
3. Choose your preferred editor:
   - **Web Editor (vscode.dev)** - Browser-based, no installation needed
   - **Desktop Editor (VS Code)** - Requires VS Code installed on your system
4. Click **"Save Settings"**
5. Extension will reload automatically

---

## 🛠️ Development

### Project Structure

```
tampermonkey-editors/
├── src/
│   ├── background/        # Background service worker
│   ├── options/          # Options page (NEW)
│   ├── tab/              # Content and page scripts
│   └── shared/           # Shared utilities
├── build_sys/            # Build configuration
├── scripts/              # Development scripts (NEW)
│   └── dev-setup.sh     # Automated setup script
├── release/              # Built extensions (generated)
└── other/                # Test dependencies
```

### Build Scripts

```bash
# Development build with watch mode
npm run build:watch

# Full release build
npm run all

# Run linter
npm run lint

# Create packages
npm run package
```

### Testing Changes

After making code changes:

```bash
# Rebuild
./build_sys/mkrelease.sh -v 999

# Reload extension in browser
# Chrome: Go to chrome://extensions/ and click the reload icon
# Firefox: Go to about:debugging and click "Reload"
```

---

## 📚 Documentation

- **[DESKTOP_VSCODE_SUPPORT.md](./DESKTOP_VSCODE_SUPPORT.md)** - Detailed implementation docs for desktop editor support
- **[Original README](./README.md)** - This file

---

## 🤝 Contributing

This is a fork of the original [Tampermonkey/tampermonkey-editors](https://github.com/Tampermonkey/tampermonkey-editors) with added desktop VS Code support.

### Making Changes

1. Make your changes in the `src/` directory
2. Test using the quick start guide above
3. Commit and push to your fork
4. Consider submitting a PR to the upstream repository

---

## 📝 License

© Jan Biniok - See LICENSE file for details

---

## 🔗 Links

- **Upstream Repository**: [Tampermonkey/tampermonkey-editors](https://github.com/Tampermonkey/tampermonkey-editors)
- **This Fork**: [tobiashochguertel/tampermonkey-editors](https://github.com/tobiashochguertel/tampermonkey-editors)
- **Tampermonkey**: [tampermonkey.net](https://www.tampermonkey.net/)
- **VS Code**: [code.visualstudio.com](https://code.visualstudio.com/)
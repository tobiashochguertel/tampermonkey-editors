# Desktop VS Code Support - Implementation Summary

## Overview

This fork adds support for opening Tampermonkey scripts in **VS Code Desktop** (via `vscode://` protocol) in addition to the existing **vscode.dev** (web editor) support. Users can choose their preferred editor through an options page.

## Changes Made

### 1. Configuration Addition (`src/background/config.ts`)

Added new configuration option `editorType`:

```typescript
type ExtensionPermanentConfig = {
    logLevel: LogLevel,
    configMode: number,
    externalExtensionIds: ExtensionIdToTry[],
    editorType: 'web' | 'desktop'  // NEW
};
```

Default value is `'web'` to maintain backward compatibility.

### 2. Background Script Updates (`src/background/index.ts`)

#### New Constants and Helper Functions

```typescript
const WEB_EDITOR_URL = 'https://vscode.dev/?connectTo=tampermonkey';
const DESKTOP_EDITOR_URL = 'vscode://';

const getMainUrl = (): string => {
    return Config.values.editorType === 'desktop' ? DESKTOP_EDITOR_URL : WEB_EDITOR_URL;
};

const isWebEditor = (): boolean => {
    return Config.values.editorType === 'web';
};
```

#### Modified Click Handler

- Checks editor type before opening
- For desktop editor: Opens `vscode://` protocol (no tab query needed)
- For web editor: Maintains existing behavior (tab query, host permissions)
- Host permission check only runs for web editor

### 3. Options Page (`src/options/`)

Created new options interface:

**options.html**: User-friendly settings page with:

- Radio button selection between Web Editor and Desktop Editor
- Descriptions for each option
- Save button with success feedback

**options.js**: Handles:

- Loading current settings from `chrome.storage.local`
- Saving user preferences
- Reloading extension to apply changes

### 4. Manifest Updates

Both `chrome_mv3.manifest.json` and `firefox_mv3.manifest.json`:

```json
"options_page": "options.html"
```

### 5. Build Configuration (`webpack.config.js`)

Added options files to CopyPlugin patterns:

```javascript
{
    from: './src/options/options.html',
    to: 'rel/options.html'
},
{
    from: './src/options/options.js',
    to: 'rel/options.js'
}
```

## How It Works

### For Web Editor (vscode.dev)

1. Extension injects content scripts into vscode.dev pages
2. Communication happens via the injected scripts
3. Requires host permissions for `*.vscode.dev`
4. Tab management (focus existing or create new)

### For Desktop Editor (VS Code)

1. Extension opens `vscode://` protocol URL
2. macOS/Windows/Linux handles protocol and launches VS Code
3. No content script injection needed
4. No host permissions required
5. Always creates new instance

## User Guide

### Changing Editor Preference

1. **Chrome**: Right-click extension icon → Options
2. **Firefox**: Right-click extension icon → Manage Extension → Options
3. Select your preferred editor type
4. Click "Save Settings"
5. Extension auto-reloads with new settings

### Desktop Editor Requirements

- VS Code Desktop must be installed
- VS Code must be registered as the `vscode://` protocol handler (happens automatically on install)

### Protocol Handler Notes

The `vscode://` protocol on macOS/Windows/Linux can:

- Open VS Code application
- Open specific files: `vscode://file/path/to/file`
- Open with extensions: `vscode://vscode.extension-id`

**Current Implementation**: Opens VS Code with basic protocol. May need enhancement to pass script content/path.

## Testing Recommendations

### Before Building

1. Ensure Node.js 18.x is installed (as per package.json engines)
2. Run: `npm install`
3. Run: `npm run build`
4. Check `out/rel/` for compiled extension

### Manual Testing

1. Load unpacked extension from `out/rel/`
2. Install Tampermonkey with test configuration (see README.md)
3. Test both editor modes:
   - **Web mode**: Should open vscode.dev in browser
   - **Desktop mode**: Should launch VS Code app

### Integration with Tampermonkey

The `?connectTo=tampermonkey` parameter in web mode enables communication between the editors extension and Tampermonkey. For desktop mode, this integration method needs verification/adaptation.

## Known Limitations & Future Work

1. **Desktop Editor Integration**: The communication protocol between Tampermonkey and desktop VS Code needs verification. The web version uses browser-based messaging; desktop may need:
   - VS Code extension for Tampermonkey integration
   - File-based communication
   - Local server approach

2. **File Handling**: Currently opens VS Code generically. Could be enhanced to:
   - Create temporary files with script content
   - Use VS Code's remote development features
   - Implement custom URI scheme parameters

3. **Platform Support**:
   - macOS: ✅ `vscode://` supported
   - Windows: ✅ `vscode://` supported
   - Linux: ✅ `vscode://` supported
   - Should work universally, but needs testing per platform

4. **Build System**: Requires Node 18.x (strict engine requirement). The changes are TypeScript-level and configuration-based, so they should compile without issues once dependencies are properly installed.

## File Summary

### Modified Files

- `src/background/config.ts` - Added editorType configuration
- `src/background/index.ts` - Added dual-mode editor support
- `build_sys/chrome_mv3.manifest.json` - Added options_page
- `build_sys/firefox_mv3.manifest.json` - Added options_page
- `webpack.config.js` - Added options files to build

### New Files

- `src/options/options.html` - Settings UI
- `src/options/options.js` - Settings logic
- `DESKTOP_VSCODE_SUPPORT.md` - This documentation

## Building and Installing

```bash
# Install dependencies (requires Node 18.x)
npm install

# Build the extension
npm run build

# Output will be in: out/rel/
# Load this directory as an unpacked extension in Chrome/Firefox
```

## Further Development Ideas

1. **Enhanced Desktop Integration**: Create a companion VS Code extension that:
   - Listens for Tampermonkey scripts
   - Provides bidirectional sync
   - Offers Tampermonkey-specific features (metadata editing, etc.)

2. **Hybrid Mode**: Allow users to choose per-script (some web, some desktop)

3. **Remote Development**: Integrate with VS Code's Remote Development extensions for advanced workflows

4. **Script Synchronization**: Implement auto-save from desktop editor back to Tampermonkey

## Credits

- Original Extension: [Tampermonkey/tampermonkey-editors](https://github.com/Tampermonkey/tampermonkey-editors)
- Fork with Desktop Support: [tobiashochguertel/tampermonkey-editors](https://github.com/tobiashochguertel/tampermonkey-editors)

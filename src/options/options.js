// Load saved settings
document.addEventListener('DOMContentLoaded', async () => {
    const result = await chrome.storage.local.get('config');
    const config = result.config || {};
    const editorType = config.editorType || 'web';
    const externalIds = config.externalExtensionIds || [];
    
    document.getElementById(`editor${editorType.charAt(0).toUpperCase() + editorType.slice(1)}`).checked = true;
    
    // Load external extension IDs
    if (externalIds.length > 0) {
        document.getElementById('extensionIds').value = externalIds.join(', ');
    }
});

// Save settings
document.getElementById('saveButton').addEventListener('click', async () => {
    const editorType = document.querySelector('input[name="editorType"]:checked').value;
    const extensionIdsInput = document.getElementById('extensionIds').value.trim();
    
    const result = await chrome.storage.local.get('config');
    const config = result.config || {};
    config.editorType = editorType;
    
    // Parse extension IDs
    if (extensionIdsInput) {
        const ids = extensionIdsInput.split(',').map(id => id.trim()).filter(id => id.length > 0);
        config.externalExtensionIds = ids;
    } else {
        // Remove custom IDs, use defaults
        delete config.externalExtensionIds;
    }
    
    await chrome.storage.local.set({ config });
    
    // Show success message
    const status = document.getElementById('status');
    status.textContent = 'Settings saved successfully!';
    status.className = 'status success';
    
    setTimeout(() => {
        status.style.display = 'none';
    }, 3000);
    
    // Reload the extension to apply changes
    chrome.runtime.reload();
});


// Load saved settings
document.addEventListener('DOMContentLoaded', async () => {
    const result = await chrome.storage.local.get('config');
    const config = result.config || {};
    const editorType = config.editorType || 'web';
    
    document.getElementById(`editor${editorType.charAt(0).toUpperCase() + editorType.slice(1)}`).checked = true;
});

// Save settings
document.getElementById('saveButton').addEventListener('click', async () => {
    const editorType = document.querySelector('input[name="editorType"]:checked').value;
    
    const result = await chrome.storage.local.get('config');
    const config = result.config || {};
    config.editorType = editorType;
    
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

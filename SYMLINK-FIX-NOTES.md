# Symlink Script Fix Summary

## Issues Fixed

### 1. **Silent Failure Problem**
**Before:** The script would silently fail by:
- Removing old symlinks successfully ✓
- Skipping new symlink creation silently ✗ (when source didn't exist)
- No clear error messages or summary

**After:** The script now:
- Checks prerequisites upfront (Admin or Developer Mode)
- Provides detailed output for each symlink operation
- Shows clear success/failure/skip status with ✓/✗ symbols
- Displays a summary at the end
- Exits with error code if failures occur

### 2. **Missing Prerequisites Check**
**Before:** No check for Admin privileges or Developer Mode until symlink creation failed

**After:** Checks upfront and exits early with clear instructions if requirements not met

### 3. **Poor Diagnostics**
**Before:** Generic warnings that were easy to miss

**After:** 
- Per-symlink status reporting
- Detailed path resolution logging
- Clear distinction between skipped (source missing) vs failed (permission issues)
- Summary statistics

## Testing Instructions

### Step 1: Run Diagnostic Script (Optional but Recommended)

On your Windows machine, run the diagnostic script first:

```powershell
# In the chezmoi source directory
pwsh test-symlink-debug.ps1
```

This will tell you:
- If you're running as Administrator
- If Developer Mode is enabled
- If symlinks can be created
- Which source paths exist/don't exist

### Step 2: Enable Developer Mode or Run as Admin

**Option A: Enable Developer Mode (Recommended)**
```powershell
# Run PowerShell as Administrator, then:
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1"
```

Or via GUI: Settings > Update & Security > For developers > Developer mode

**Option B: Run PowerShell as Administrator**
- Right-click PowerShell
- Select "Run as Administrator"

### Step 3: Apply Chezmoi Changes

```bash
# From WSL or Git Bash
cd ~/.local/share/chezmoi
chezmoi apply
```

Or if testing from Windows:

```powershell
# From PowerShell
cd $HOME\.local\share\chezmoi
chezmoi apply
```

### Step 4: Verify Results

The new script will show detailed output like:

```
=== Setting up symbolic links ===

Processing: $PROFILE.CurrentUserAllHosts
  Target: C:\Users\YourName\Documents\PowerShell\profile.ps1
  Source: C:\Users\YourName\.config\pwsh\profile.ps1
  Resolved: C:\Users\YourName\.config\pwsh\profile.ps1
  ✓ SUCCESS: Symlink created

Processing: $env:APPDATA\bottom
  Target: C:\Users\YourName\AppData\Roaming\bottom
  Source: C:\Users\YourName\.config\bottom
  Resolved: C:\Users\YourName\.config\bottom
  Removing existing symlink...
  ✓ SUCCESS: Symlink created

...

=== Symlink Setup Summary ===
  Success: 7
  Skipped: 0 (source missing)
  Failed:  0

All symbolic links created successfully!
```

## What Changed in the Script

### Key Improvements

1. **Upfront Permission Check**
   ```powershell
   $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
   $devModeEnabled = ($devMode.AllowDevelopmentWithoutDevLicense -eq 1)
   ```

2. **Per-Symlink Status Reporting**
   - Shows target, source, and resolved paths
   - Clear ✓/✗ status indicators
   - Detailed error messages

3. **Summary Statistics**
   - Success count
   - Skip count (missing sources)
   - Fail count (permission/other errors)

4. **Proper Exit Codes**
   - Exit 1 if no permission
   - Exit 1 if any symlinks failed
   - Exit 0 only if all succeeded or only skips occurred

## Files Modified

- `home/.chezmoiscripts/windows/run_onchange_after_05-setup-symlinks.ps1.tmpl` (Fixed)
- `test-symlink-debug.ps1` (New - diagnostic tool)
- `SYMLINK-FIX-NOTES.md` (This file)

## Common Issues and Solutions

### Issue: "WARNING: Cannot create symlinks!"
**Solution:** Enable Developer Mode or run as Administrator (see Step 2 above)

### Issue: "SKIPPED: Source does not exist!"
**Solution:** 
- Check if the source config files exist in `$HOME\.config\`
- Run `chezmoi apply` to ensure dotfiles are deployed first
- Verify the path in `home/.chezmoidata/env/windows.yml`

### Issue: Symlinks created but apps don't use them
**Solution:**
- Restart the application
- Some apps cache config locations on first run
- Check if the app has other config location settings

## Next Steps

1. Test the fix on your Windows machine
2. If successful, delete `test-symlink-debug.ps1` (diagnostic script)
3. Delete `SYMLINK-FIX-NOTES.md` (this file) if no longer needed
4. Commit the changes to your dotfiles repo

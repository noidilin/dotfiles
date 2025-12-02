# =============================================================================
# Diagnostic Script: Test Symlink Creation Issue
# =============================================================================
# This script helps diagnose why the symlink setup is failing
# Run this in PowerShell on Windows to understand the issue

Write-Host "=== Symlink Diagnostic Test ===" -ForegroundColor Cyan
Write-Host ""

# Test 1: Check if running as Administrator
Write-Host "[Test 1] Checking Administrator privileges..." -ForegroundColor Yellow
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) {
    Write-Host "  ✓ Running as Administrator" -ForegroundColor Green
} else {
    Write-Host "  ✗ NOT running as Administrator" -ForegroundColor Red
}
Write-Host ""

# Test 2: Check Developer Mode status
Write-Host "[Test 2] Checking Developer Mode status..." -ForegroundColor Yellow
try {
    $devMode = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -ErrorAction SilentlyContinue
    if ($devMode.AllowDevelopmentWithoutDevLicense -eq 1) {
        Write-Host "  ✓ Developer Mode is ENABLED" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Developer Mode is DISABLED" -ForegroundColor Red
    }
} catch {
    Write-Host "  ✗ Cannot determine Developer Mode status" -ForegroundColor Red
}
Write-Host ""

# Test 3: Test symlink creation capability
Write-Host "[Test 3] Testing symlink creation capability..." -ForegroundColor Yellow
$testSource = "$HOME\.config\pwsh\profile.ps1"
$testTarget = "$env:TEMP\test-symlink-$(Get-Random).ps1"

if (Test-Path $testSource) {
    Write-Host "  Source exists: $testSource" -ForegroundColor Gray
    try {
        New-Item -ItemType SymbolicLink -Path $testTarget -Target $testSource -Force -ErrorAction Stop | Out-Null
        Write-Host "  ✓ Successfully created test symlink!" -ForegroundColor Green
        Remove-Item $testTarget -Force -ErrorAction SilentlyContinue
    } catch {
        Write-Host "  ✗ FAILED to create symlink: $_" -ForegroundColor Red
        Write-Host "  Error details: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "  ✗ Source file doesn't exist: $testSource" -ForegroundColor Red
}
Write-Host ""

# Test 4: Simulate the actual symlink script logic
Write-Host "[Test 4] Simulating actual symlink script..." -ForegroundColor Yellow

$testSymlinks = @{
    "`$PROFILE.CurrentUserAllHosts" = "`$HOME\.config\pwsh\profile.ps1"
    "`$env:APPDATA\bottom" = "`$HOME\.config\bottom"
}

foreach ($symlink in $testSymlinks.GetEnumerator()) {
    Write-Host "  Testing: $($symlink.Key) -> $($symlink.Value)" -ForegroundColor Gray
    
    # Expand environment variables
    $targetPath = $ExecutionContext.InvokeCommand.ExpandString($symlink.Key)
    $sourcePath = $ExecutionContext.InvokeCommand.ExpandString($symlink.Value)
    
    Write-Host "    Expanded target: $targetPath" -ForegroundColor DarkGray
    Write-Host "    Expanded source: $sourcePath" -ForegroundColor DarkGray
    
    # Check if source exists
    if (Test-Path $sourcePath) {
        $resolvedSource = Resolve-Path $sourcePath
        Write-Host "    ✓ Source exists: $resolvedSource" -ForegroundColor Green
    } else {
        Write-Host "    ✗ Source DOES NOT exist: $sourcePath" -ForegroundColor Red
        Write-Host "    >>> THIS IS WHY SYMLINK CREATION IS SKIPPED! <<<" -ForegroundColor Magenta
    }
    Write-Host ""
}

# Test 5: Check all expected source paths
Write-Host "[Test 5] Checking all expected source paths..." -ForegroundColor Yellow
$expectedPaths = @(
    "$HOME\.config\pwsh\profile.ps1"
    "$HOME\.config\bottom"
    "$HOME\.config\rime"
    "$HOME\.config\vivid"
    "$HOME\.config\winterm\settings.json"
    "$HOME\.config\bat"
    "$HOME\.config\nvim"
)

foreach ($path in $expectedPaths) {
    if (Test-Path $path) {
        Write-Host "  ✓ $path" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $path (MISSING!)" -ForegroundColor Red
    }
}
Write-Host ""

# Recommendation
Write-Host "=== Recommendation ===" -ForegroundColor Cyan
if (-not $isAdmin) {
    $devModeEnabled = $false
    try {
        $devMode = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -ErrorAction SilentlyContinue
        $devModeEnabled = ($devMode.AllowDevelopmentWithoutDevLicense -eq 1)
    } catch {}
    
    if (-not $devModeEnabled) {
        Write-Host "You need EITHER:" -ForegroundColor Yellow
        Write-Host "  1. Run PowerShell as Administrator, OR" -ForegroundColor Yellow
        Write-Host "  2. Enable Developer Mode:" -ForegroundColor Yellow
        Write-Host "     Settings > Update & Security > For developers > Developer mode" -ForegroundColor Gray
        Write-Host ""
        Write-Host "To enable Developer Mode via PowerShell (requires Admin):" -ForegroundColor Yellow
        Write-Host '  reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1"' -ForegroundColor Gray
    }
}

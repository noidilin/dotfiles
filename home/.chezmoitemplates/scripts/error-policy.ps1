# Shared error-policy helper for package scripts.

$script:StrictMode = $false
$strictValue = [string]$env:DOTFILES_STRICT
if ($strictValue -imatch '^(1|true|yes|on)$') {
    $script:StrictMode = $true
}

$script:InstalledCount = 0
$script:SkippedCount = 0
$script:FailedCount = 0
$script:FailedItems = @()

function Add-Installed {
    $script:InstalledCount += 1
}

function Add-Skipped {
    $script:SkippedCount += 1
}

function Add-Failure {
    param(
        [string]$Manager,
        [string]$Package
    )
    $script:FailedCount += 1
    $script:FailedItems += "$Manager`:$Package"

    if ($script:StrictMode) {
        Write-Host "Strict mode enabled; stopping after failure." -ForegroundColor Red
        Write-InstallSummary
        exit 1
    }
}

function Write-InstallSummary {
    Write-Host "`nSummary: installed=$($script:InstalledCount) skipped=$($script:SkippedCount) failed=$($script:FailedCount)" -ForegroundColor White
    if ($script:FailedCount -gt 0) {
        Write-Host "Failed items:" -ForegroundColor Red
        foreach ($item in $script:FailedItems) {
            Write-Host "- $item" -ForegroundColor Red
        }
    }
}

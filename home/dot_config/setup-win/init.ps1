# =============================================================================
# DEPRECATED: This script is no longer maintained
# =============================================================================
# New approach: Bootstrap setup is documented in bootstrap guide
# - See docs/bootstrap-windows.md for step-by-step manual bootstrap process
# - After chezmoi init, everything is automated via chezmoiscripts
# =============================================================================

Write-Host "WARNING: This script is DEPRECATED!" -ForegroundColor Red
Write-Host "Please follow the manual bootstrap process in docs/bootstrap-windows.md" -ForegroundColor Yellow
Write-Host ""

Write-Host "starting init.ps1 script..." -ForegroundColor White
$SCOOP_INIT = @(
  "main/chezmoi"
  "main/pwsh"
  "main/nu"
  "extras/age"
)

Write-Host "seting up execution policy for scoop..." -ForegroundColor Gray
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

Write-Host "installing execution policy for scoop..." -ForegroundColor Gray
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

# NOTE: git need to be installed before adding bucket
Write-Host "installing git..." -ForegroundColor Gray
scoop install git

Write-Host "adding scoop bucket..." -ForegroundColor Gray
scoop bucket add extras
scoop bucket add nerd-fonts

Write-Host "installing initial apps..." -ForegroundColor Gray
scoop install @SCOOP_INIT

# TODO: recently added, not tested yet!
Write-Host "running post-install script for scoop..." -ForegroundColor Gray
reg import "$env:USERPROFILE\scoop\apps\pwsh\current\install-explorer-context.reg"
reg import "$env:USERPROFILE\scoop\apps\pwsh\current\install-file-context.reg"

Write-Host "init.ps1 script finished." -ForegroundColor Green

Write-Host "starting bun.ps1 script..." -ForegroundColor White

$BUN_PACKAGES = @(
  "@vscode/vsce"
  "tldr"
  "rimraf"
)

Write-Host "installing global bun packages..." -ForegroundColor Gray
bun add --global @BUN_PACKAGES

Write-Host "bun.ps1 script finished." -ForegroundColor Green

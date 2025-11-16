# =============================================================================
# DEPRECATED: This script is no longer maintained
# =============================================================================
# New approach: Package installation is managed via chezmoi
# - Package list: .chezmoidata.toml
# - Installation: home/.chezmoiscripts/run_onchange_after_12-install-node-packages.ps1.tmpl
# - See docs/bootstrap-windows.md for new setup process
# =============================================================================

Write-Host "WARNING: This script is DEPRECATED!" -ForegroundColor Red
Write-Host "Please use the new chezmoi-based package management system." -ForegroundColor Yellow
Write-Host "See: docs/bootstrap-windows.md" -ForegroundColor Yellow
Write-Host ""

Write-Host "starting pnpm.ps1 script..." -ForegroundColor White

$PNPM_PACKAGES = @(
  # "@vscode/vsce"
  "tldr"
  "rimraf"
  "yamlresume"
  "next-devtools-mcp"
  "chrome-devtools-mcp"
  # "yo"
  # "generator-code"
)

# Write-Host "initializing pnpm env variable..." -ForegroundColor Gray
pnpm setup

Write-Host "installing global pnpm packages..." -ForegroundColor Gray
pnpm add @PNPM_PACKAGES -g

Write-Host "pnpm.ps1 script finished." -ForegroundColor Green

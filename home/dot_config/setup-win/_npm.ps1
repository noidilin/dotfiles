Write-Host "starting npm.ps1 script..." -ForegroundColor White

$NPM_PACKAGES = @(
  "corepack@latest"
  # "@vscode/vsce"
  # "yo"
  # "generator-code"
  # "tldr"
  # "rimraf"
)

Write-Host "installing global npm packages..." -ForegroundColor Gray
npm install @NPM_PACKAGES -g

Write-Host "installing pnpm package manager..." -ForegroundColor Gray
corepack enable pnpm

Write-Host "npm.ps1 script finished." -ForegroundColor Green

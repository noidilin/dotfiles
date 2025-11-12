# WARN: Prerequisite: 
# 1. add PNPM_HOME=$XDG_DATA_HOME/pnpm/ to environment variable
# 2. add path of PNPM_HOME into PATH
# 3. `scoop install main/mise`
# 4. `mise install`, which will:
#   a. install node lts version
#   b. execute `corepack enable` after installation

Write-Host "starting pnpm.ps1 script..." -ForegroundColor White

$PNPM_PACKAGES = @(
  # "@vscode/vsce"
  "tldr"
  "rimraf"
  # "yo"
  # "generator-code"
)

# Write-Host "initializing pnpm env variable..." -ForegroundColor Gray
pnpm setup

Write-Host "installing global pnpm packages..." -ForegroundColor Gray
pnpm add @PNPM_PACKAGES -g

Write-Host "pnpm.ps1 script finished." -ForegroundColor Green

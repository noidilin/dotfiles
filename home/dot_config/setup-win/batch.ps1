Write-Host "(batch) please run this with NON-admin privileges!" -ForegroundColor Red
Pause

Write-Host "(batch) install prequisite scoop..." -ForegroundColor Yellow
# . "$HOME/.config/setup-win/init.ps1"
Invoke-WebRequest "https://raw.githubusercontent.com/noidilin/windows-dotfiles/main/dot_config/setup-win/init.ps1" | Invoke-Expression

Write-Host "(batch) setup environment variable..." -ForegroundColor Yellow
# . "$HOME/.config/setup-win/env.ps1"
Invoke-WebRequest "https://raw.githubusercontent.com/noidilin/windows-dotfiles/main/dot_config/setup-win/env.ps1" | Invoke-Expression

Write-Host "(batch) apply chezmoi dotfiles..." -ForegroundColor Yellow
chezmoi init --apply --verbose git@github.com:noidilin/windows-dotfiles.git

Write-Host "(batch) setting up symbolic link..." -ForegroundColor Yellow
# . "$HOME/.config/setup-win/symlinks.ps1"
Invoke-WebRequest "https://raw.githubusercontent.com/noidilin/windows-dotfiles/main/dot_config/setup-win/symlinks.ps1" | Invoke-Expression

Write-Host "(batch) install apps with scoop..." -ForegroundColor Yellow
# . "$HOME/.config/setup-win/scoop.ps1"
Invoke-WebRequest "https://raw.githubusercontent.com/noidilin/windows-dotfiles/main/dot_config/setup-win/scoop.ps1" | Invoke-Expression

Write-Host "(batch) install pnpm packages..." -ForegroundColor Yellow
# . "$HOME/.config/setup-win/pnpm.ps1"
Invoke-WebRequest "https://raw.githubusercontent.com/noidilin/windows-dotfiles/main/dot_config/setup-win/pnpm.ps1" | Invoke-Expression

# Write-Host "(batch) install bun packages..." -ForegroundColor Yellow
# . "$HOME/.config/setup-win/bun.ps1"
# Invoke-WebRequest "https://raw.githubusercontent.com/noidilin/windows-dotfiles/main/dot_config/setup-win/bun.ps1" | Invoke-Expression

# ISSUE: can't skip UAC prompt
Write-Host "(batch) install apps with winget..." -ForegroundColor Yellow
# . "$HOME/.config/setup-win/winget.ps1"
Invoke-WebRequest "https://raw.githubusercontent.com/noidilin/windows-dotfiles/main/dot_config/setup-win/winget.ps1" | Invoke-Expression

Write-Host "(batch) batch script finished." -ForegroundColor Red

# Ref: https://gist.github.com/mikepruett3/7ca6518051383ee14f9cf8ae63ba18a7
# kevin nitroG: https://github.com/KevinNitroG/windows-dotfiles/blob/main/dot_install/install.ps1

Write-Host "(batch) please run this with NON-admin privileges!" -ForegroundColor Red
Pause

Write-Host "(batch) install prequisite scoop..." -ForegroundColor Yellow
# . "$HOME/.install/init.ps1"
Invoke-WebRequest "https://raw.githubusercontent.com/noidilin/windows-dotfiles/main/dot_install/init.ps1" | Invoke-Expression

Write-Host "(batch) setup environment variable..." -ForegroundColor Yellow
# . "$HOME/.install/env.ps1"
Invoke-WebRequest "https://raw.githubusercontent.com/noidilin/windows-dotfiles/main/dot_install/env.ps1" | Invoke-Expression

Write-Host "(batch) apply chezmoi dotfiles..." -ForegroundColor Yellow
chezmoi init --apply --verbose git@github.com:noidilin/windows-dotfiles.git

Write-Host "(batch) setting up symbolic link..." -ForegroundColor Yellow
# . "$HOME/.install/symlinks.ps1"
Invoke-WebRequest "https://raw.githubusercontent.com/noidilin/windows-dotfiles/main/dot_install/symlinks.ps1" | Invoke-Expression

Write-Host "(batch) install apps with scoop..." -ForegroundColor Yellow
# . "$HOME/.install/scoop.ps1"
Invoke-WebRequest "https://raw.githubusercontent.com/noidilin/windows-dotfiles/main/dot_install/scoop.ps1" | Invoke-Expression

Write-Host "(batch) install pnpm packages..." -ForegroundColor Yellow
# . "$HOME/.install/pnpm.ps1"
Invoke-WebRequest "https://raw.githubusercontent.com/noidilin/windows-dotfiles/main/dot_install/pnpm.ps1" | Invoke-Expression

# Write-Host "(batch) install bun packages..." -ForegroundColor Yellow
# . "$HOME/.install/bun.ps1"
# Invoke-WebRequest "https://raw.githubusercontent.com/noidilin/windows-dotfiles/main/dot_install/bun.ps1" | Invoke-Expression

# ISSUE: can't skip UAC prompt
Write-Host "(batch) install apps with winget..." -ForegroundColor Yellow
# . "$HOME/.install/winget.ps1"
Invoke-WebRequest "https://raw.githubusercontent.com/noidilin/windows-dotfiles/main/dot_install/winget.ps1" | Invoke-Expression

Write-Host "(batch) batch script finished." -ForegroundColor Red

Write-Host "starting symlinks.ps1 script..." -ForegroundColor White

# linked files (destination => source)
$symlinks = @{
    $PROFILE.CurrentUserAllHosts = "$HOME\.config\pwsh\profile.ps1"
    "$env:APPDATA\bottom" = "$HOME\.config\bottom"
    "$env:APPDATA\Rime" = "$HOME\.config\rime"
    "$env:APPDATA\vivid" = "$HOME\.config\vivid"
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" = "$HOME\.config\winterm\settings.json"
    # make sure my config is used even $env:BAT_CONFIG_DIR is changed by bat scoop bucket
    "$HOME\scoop\persist\bat" = "$HOME\.config\bat"
    # for vscode-neovim, since it currently (2024-11-27) won't launch neovim from XDG_CONFIG_HOME
    "$env:LOCALAPPDATA\nvim"                                                                      = "$HOME\.config\nvim"
    # "$HOME\AppData\Local\fastfetch"                                                                 = ".\fastfetch"
}

Write-Host "creating symbolic links..." -ForegroundColor Gray
foreach ($symlink in $symlinks.GetEnumerator()) {
    Get-Item -Path $symlink.Key -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    New-Item -ItemType SymbolicLink -Path $symlink.Key -Target (Resolve-Path $symlink.Value) -Force | Out-Null
}

Write-Host "symlinks.ps1 script finished." -ForegroundColor Green

$env:EDITOR = "nvim"
$env:PAGER = "delta"

$env:CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense" # optional
$env:CC = 'gcc'

# dev path
$env:PNPM_HOME = "$HOME\.dev\pnpm"
$env:BUN_INSTALL_GLOBAL_DIR = "$HOME\.dev\bun\install\global"
$env:BUN_INSTALL_BIN = "$HOME\.dev\bun\bin"
$env:BUN_INSTALL_CACHE_DIR = "$HOME\.dev\bun\install\cache"
$env:CARGO_HOME = "$HOME\.dev\cargo"
$env:RUSTUP_HOME = "$HOME\.dev\rustup"
## UV configuration - force all storage to follow XDG-like structure on Windows
$env:UV_CONFIG_FILE =  "$HOME\.config\uv\uv.toml"
$env:UV_CACHE_DIR = "$HOME\.dev\uv\cache"
$env:UV_PYTHON_INSTALL_DIR = "$HOME\.dev\uv\python"
$env:UV_TOOL_DIR = "$HOME\.dev\uv\tools"
$env:UV_TOOL_BIN_DIR = "$HOME\.dev\uv\bin"

$env:PATH += ";$HOME\.dev\uv\bin"
$env:PATH += ";$HOME\.dev\pnpm"
$env:PATH += ";$HOME\.dev\bun\bin"

# shell cli
$env:EZA_CONFIG_DIR = "$HOME\.config\eza"
$env:BAT_CONFIG_DIR = "$HOME\.config\bat"
$env:YAZI_CONFIG_HOME = "$HOME\.config\yazi"
$env:YAZI_FILE_ONE = "$HOME\scoop\apps\git\current\usr\bin\file.exe"

# key
# $env:ANTHROPIC_API_KEY = Get-Content -Path "$HOME\.config\api\ANTHROPIC_API_KEY"
# $env:OPENAI_API_KEY = Get-Content -Path "$HOME\.config\api\OPENAI_API_KEY"

Import-Module PSReadLine

. "$HOME\.config\pwsh\scripts\PSReadLine.ps1"
. "$HOME\.config\pwsh\scripts\fzf.ps1"
. "$HOME\.config\pwsh\scripts\eza.ps1"
. "$HOME\.config\pwsh\scripts\commands.ps1"

if (Get-Command "starship" -ErrorAction SilentlyContinue) {
  Invoke-Expression (& starship init powershell)
}

if (Get-Command "zoxide" -ErrorAction SilentlyContinue) {
  Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

if (Get-Command "chezmoi" -ErrorAction SilentlyContinue) {
  Invoke-Expression (& { (chezmoi completion powershell | Out-String) })
}

if (Get-Command "carapace" -ErrorAction SilentlyContinue) {
  Invoke-Expression (& { (carapace _carapace | Out-String) })
}

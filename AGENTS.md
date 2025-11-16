# Agent Guidelines for Chezmoi Dotfiles

## Repository Structure
- This is a **chezmoi-managed dotfiles repository** for multi-platform use
- Config files are in `home/dot_config/`, scripts in `home/.chezmoiscripts/`
- Use `chezmoi` commands to manage files: `chezmoi add`, `chezmoi apply`, `chezmoi edit`
- Encrypted files use age encryption (see `home/.chezmoi.toml.tmpl` for config)
- Platform-specific files are filtered via `home/.chezmoiignore`

## Supported Platforms
- **Windows**: Primary platform with full configuration
- **Linux (Arch)**: Selective sync via WSL2, excludes Windows-specific tools
- **macOS**: Configured but not actively used (see `.chezmoiignore` for exclusions)

## Commands
- **Apply changes**: `chezmoi apply`
- **Add encrypted file**: `chezmoi add --encrypt <file>`
- **Test changes**: manually verify after `chezmoi apply` in target directory
- **Install scripts**:
  - Windows: `pwsh home/.chezmoiscripts/run_once_before_decrypt-private-key.ps1.tmpl`
  - Arch Linux: Auto-runs `.chezmoiscripts/run_onchange_install-packages-arch.sh.tmpl`

## Environment & Tools
- **Platforms**: Windows (primary), Linux/Arch (WSL2)
- **Shells**: Nushell (nu) is primary on all platforms, PowerShell (pwsh) on Windows only
- **XDG directories**: 
  - Windows: `XDG_CONFIG_HOME=$HOME\.config`, `XDG_DATA_HOME=$HOME\.local\share`, `XDG_CACHE_HOME=$HOME\.cache`
  - Linux: `XDG_CONFIG_HOME=~/.config`, `XDG_DATA_HOME=~/.local/share`, `XDG_CACHE_HOME=~/.cache`
- **Available tools**: fd, sd, grep, ripgrep, ast-grep, imagemagick, yazi, lazygit, mise, bat, eza, fzf, bottom, delta

## Platform-Specific Configs
- **Windows-only**: Flow Launcher, WinTerm, GlazeWM, Rime, PowerShell, setup-win scripts
- **Cross-platform**: Nushell, Git, Starship, CLI tools (bat, eza, yazi, etc.), OpenCode
- **Linux setup**: See `docs/arch-wsl-setup.md` for Arch Linux WSL2 initialization

## Code Style
- **Shell scripts**: Use `.ps1` for PowerShell (Windows), `.sh` for bash (Linux), `.nu` for Nushell (all platforms)
- **Line endings**: LF for `.sh` files (see `.editorconfig`)
- **Markdown**: MD013 (line length) disabled (see `.markdownlint-cli2.yaml`)
- **Naming**: Use descriptive function names with verb-noun pattern (e.g., `Update-Stylus`, `Delete-TempData`)

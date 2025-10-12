# Agent Guidelines for Chezmoi Dotfiles

## Repository Structure
- This is a **chezmoi-managed dotfiles repository** for Windows
- Config files are in `home/dot_config/`, scripts in `home/dot_install/`
- Use `chezmoi` commands to manage files: `chezmoi add`, `chezmoi apply`, `chezmoi edit`
- Encrypted files use age encryption (see `.chezmoi.toml.tmpl` for config)

## Commands
- **Apply changes**: `chezmoi apply`
- **Add encrypted file**: `chezmoi add --encrypt <file>`
- **Test changes**: manually verify after `chezmoi apply` in target directory
- **Install scripts**: `pwsh home/dot_install/init.ps1` (or `batch.ps1`, `scoop.ps1`, etc.)

## Environment & Tools
- **Platform**: Windows only
- **Shells**: Nushell (nu) is primary, PowerShell (pwsh) as fallback
- **XDG directories**: `XDG_CONFIG_HOME=$HOME\.config`, `XDG_DATA_HOME=$HOME\.local\share`, `XDG_CACHE_HOME=$HOME\.cache`
- **Available tools**: fd, sd, grep, ripgrep, ast-grep, imagemagick, yazi, lazygit, mise

## Code Style
- **Shell scripts**: Use `.ps1` for PowerShell, `.nu` for Nushell
- **Line endings**: LF for `.sh` files (see `.editorconfig`)
- **Markdown**: MD013 (line length) disabled (see `.markdownlint-cli2.yaml`)
- **Naming**: Use descriptive function names with verb-noun pattern (e.g., `Update-Stylus`, `Delete-TempData`)

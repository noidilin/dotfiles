# Agent Guidelines for Chezmoi Dotfiles

## Repository Structure
- This is a **chezmoi-managed dotfiles repository** for multi-platform use
- Config files are in `home/dot_config/`, scripts in `home/.chezmoiscripts/`
- Use `chezmoi` commands to manage files: `chezmoi add`, `chezmoi apply`, `chezmoi edit`
- Encrypted files use age encryption (see `home/.chezmoi.toml.tmpl` for config)
- Platform-specific files are filtered via `home/.chezmoiignore`

## Supported Platforms
- **Windows**: Primary platform with full configuration
- **Linux (Arch WSL2)**: CLI tools only, uses Windows interop for SSH/GPG
- **Linux (Arch Native)**: Planned support with desktop environment (minimal setup for now)
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

## Script Execution Order

### Execution Phases

Scripts run in this order during `chezmoi apply`:

1. **run_once_before_*** → Prerequisites (before applying dotfiles)
2. **run_onchange_before_*** → Dynamic prerequisites (before applying dotfiles)
3. **[Apply dotfiles to target directories]**
4. **run_onchange_after_*** → Declarative configs (after dotfiles exist)
5. **run_once_after_*** → One-time system setup (after dotfiles exist)

### Current Implementation

#### Phase 1: run_once_before (Prerequisites)

| # | Script | Platform | Purpose |
|---|--------|----------|---------|
| 01 | decrypt-private-key | Cross-platform | Decrypt age key and set permissions (icacls on Windows, chmod on Linux) |
| 02 | install-yay | Arch Linux | Install yay AUR helper from source (required for AUR packages) |
| 02 | setup-env-variables | Windows | Set XDG Base Directory variables in Registry (makes env vars available before dotfiles are applied) |
| 03 | install-mise | Arch Linux | Install mise via official installer to ~/.local/bin (for latest versions) |

#### Phase 1.5: run_before (SSH Setup for Externals)

| # | Script | Platform | Purpose |
|---|--------|----------|---------|
| 05 | apply-ssh-config | macOS | Manually render SSH/git/1Password configs using `chezmoi execute-template` (needed for .chezmoiexternals SSH cloning) |
| 05 | apply-ssh-config | Windows | Manually render git/1Password configs using `chezmoi execute-template` (needed for .chezmoiexternals SSH cloning) |

**Note:** WSL2 does not need this script because it uses Windows SSH via interop (`ssh.exe`), which reads Windows SSH configuration.

#### Phase 2: run_onchange_after (Declarative Packages)

| # | Script | Platform | Purpose | Triggers |
|---|--------|----------|---------|----------|
| 02 | setup-symlinks | Windows | Create symlinks for non-XDG apps | `windows.yml` changes |
| 10 | install-system-packages | Cross-platform | Scoop (Windows) or Pacman (Linux) | Package list changes |
| 20 | install-additional-packages | Windows | WinGet packages | Package list changes |
| 30 | install-mise-tools | Cross-platform | Runtime version managers | `mise.yml` changes |
| 40 | install-language-packages | Cross-platform | pnpm/uv/cargo/yay packages | Package list changes |

### Script Type Selection Guide

**Use `run_once_*` when:**
- System-level settings that rarely change (e.g., Registry variables)
- Expensive operations that should only run once
- Manual re-run is acceptable for updates

**Use `run_onchange_*` when:**
- Script depends on declarative config files (e.g., package lists in `.chezmoidata/`)
- Should automatically respond to config changes
- Script is idempotent (safe to re-run)

**Use `*_before_*` when:**
- Script doesn't depend on dotfiles being in target location
- Must run before dotfiles are applied (e.g., decrypt keys)

**Use `*_after_*` when:**
- Script depends on dotfiles already existing in target location
- Reads/uses dotfiles as source (e.g., symlinks, reading configs)

### Platform-Specific Wrappers

Scripts use templating to select platform-specific implementations:

```
run_onchange_after_10-install-system-packages.sh.tmpl
├── Windows: install-scoop-packages.ps1
└── Linux: install-packages-arch.sh (pacman)
```

Common package data is unified in `.chezmoidata/pkg-manager/common.yml` and merged with platform-specific package lists.

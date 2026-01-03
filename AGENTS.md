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

## Chezmoi Template Indentation Style Guide

### Core Principles

1. **Template markers** (`{{-`, `{{`, `-}}`, `}}`): Indent by **2 spaces per nesting level** to show control flow structure
2. **Content inside templates**: Align with surrounding context (ignore template nesting depth)
3. **Preserve context alignment**: Content should maintain its natural indentation (TOML sections, PowerShell blocks, etc.)

### Template Marker Indentation Rules

```toml
{{- if condition }}          ← Level 0: flush left (top-level block)
  content here               ← Content: aligned with context (e.g., 2 spaces for TOML section)
{{-   if nested }}            ← Level 1: 2 spaces (nested block)
  content here               ← Content: still aligned with context (not double-indented!)
{{-   end }}                  ← Level 1: 2 spaces (closing nested block)
{{- else if other }}          ← Level 0: flush left (same level as opening if)
  content here
{{- end }}                    ← Level 0: flush left (closing top-level block)
```

**Key rules:**

- Top-level blocks: **0 spaces** (flush left)
- Nested blocks: **+2 spaces per level** (relative to parent block)
- `else if` and `else`: **Same indentation as opening `if`**
- `end`: **Same indentation as corresponding opening block**
- **Content**: Ignores template nesting, follows target file format conventions

### Whitespace Trimming

- **Control flow blocks**: Use `{{-` and `-}}` for consistent output formatting
- **Content interpolation**: Use `{{` and `}}` (no dashes) when outputting variables/content
- **Comments**: Can use `{{/* */}}` without dashes for visual separators

### Examples

#### Example 1: TOML Config with Nested Conditions

```toml
[user]
  name = noidilin
  email = linganinja.0120@gmail.com
{{- if eq .osId "windows" }}
  signingkey = {{ onepasswordRead "op://dev/github-win/public key" | trim }}
{{- else if eq .osId "linux-arch" }}
{{-   if eq .archEnv "wsl" }}
  signingkey = {{ onepasswordRead "op://dev/github-win/public key" | trim }}
{{-   else }}
  signingkey = {{ onepasswordRead "op://dev/github-arch/public key" | trim }}
{{-   end }}
{{- else if eq .osId "darwin" }}
  signingkey = {{ onepasswordRead "op://dev/github-mac/public key" | trim }}
{{- end }}
```

**Note:** `signingkey` stays at 2 spaces (TOML section indentation), regardless of template nesting.

#### Example 2: PowerShell Script with Range Loop

```powershell
{{- if not .symlinks.windows }}
Write-Host "No symlink definitions found. Skipping." -ForegroundColor Yellow
return
{{- else }}
$symlinkItems = @(
{{-   range .symlinks.windows }}
    @{
        Target = "{{ .target }}"
        Source = "{{ .source }}"
    }
{{-   end }}
)
{{- end }}
```

**Note:** `range` block indented (2 spaces), but PowerShell array content uses natural 4-space indentation.

#### Example 3: Complex Nested Conditions

```toml
{{- range $name, $config := .mise.tools }}      ← Level 0
{{-   if eq $name "node" }}                     ← Level 1: 2 spaces
node = { version = "{{ $config.version }}" }    ← Content: flush left (TOML top-level)
{{-   else if eq $name "rust" }}                ← Level 1: 2 spaces
{{-     if eq $.chezmoi.os "windows" }}         ← Level 2: 4 spaces
rust = { version = "{{ $config.windows.version }}" }
{{-     else if eq $.chezmoi.os "linux" }}      ← Level 2: 4 spaces
rust = { version = "{{ $config.linux.version }}" }
{{-     end }}                                  ← Level 2: 4 spaces
{{-   end }}                                    ← Level 1: 2 spaces
{{- end }}                                      ← Level 0
```

**Note:** Clear visual hierarchy shows nesting depth (0 → 2 → 4 spaces for markers), but content stays flush left.

#### Example 4: Bash Script

```bash
{{- if .pkgs.cargo }}
printf "Installing cargo packages...\n"
{{-   range .pkgs.cargo }}
install_cargo_package "{{ . }}"
{{-   end }}
{{- else }}
printf "No cargo packages declared (skipping)\n"
{{- end }}
```

**Note:** Bash commands at natural indentation (0 for top-level), template markers show structure.

### Common Patterns to Avoid

**❌ Incorrect: Mixing indentation styles**

```toml
{{- if condition }}
{{-   if nested }}          ← Indented (good)
  content
{{- else if other }}        ← NOT indented (inconsistent!)
  content
{{-   end }}
{{- end }}
```

**✓ Correct: Consistent indentation**

```toml
{{- if condition }}
{{-   if nested }}          ← Level 1: 2 spaces
  content
{{-   else if other }}      ← Level 1: 2 spaces
  content
{{-   end }}                ← Level 1: 2 spaces
{{- end }}
```

**❌ Incorrect: Double-indenting content**

```toml
[user]
{{- if eq .osId "windows" }}
{{-   if nested }}
    signingkey = value      ← Wrong! (4 spaces = 2 for section + 2 for nested template)
{{-   end }}
{{- end }}
```

**✓ Correct: Content ignores template nesting**

```toml
[user]
{{- if eq .osId "windows" }}
{{-   if nested }}
  signingkey = value        ← Correct! (2 spaces = TOML section indentation only)
{{-   end }}
{{- end }}
```

### Target File Format Conventions

When writing content, follow these indentation conventions:

- **TOML**: 2 spaces for sections/keys
- **YAML**: 2 spaces per level
- **Bash scripts**: 4 spaces per block (per `.editorconfig`)
- **PowerShell scripts**: 4 spaces per block
- **Nushell scripts**: 4 spaces per block

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

Common package data is unified in `.chezmoidata/pm/common.yml` and merged with platform-specific package lists.

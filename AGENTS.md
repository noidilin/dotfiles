# Agent Guidelines for Chezmoi Dotfiles

## Repository Structure

- A chezmoi-managed dotfiles repo that supports windows, arch WSL2, arch linux, macOS
- Config files are in `home/dot_config/`
  - `age` encryption support is configured in `home/.chezmoi.toml.tmpl`, but there are currently no repo-managed encrypted secrets in this repository
  - Platform-specific files are filtered via `home/.chezmoiignore`
- Nushell (nu) is primary shell on all platforms

---

## Environment & Tools

### Environment Variable Architecture

Environment variables are configured in **three independent layers** with a **unified source of truth**:

- Single Source of Truth: `.chezmoidata/env.yml`
- Shared Template: `.chezmoitemplates/env`
  - used by both chezmoi scriptEnv and mise config to ensure consistency

### Environment Variables Definitions

- chezmoi: env vars
  - **Location:** `.chezmoi.toml.tmpl` → `[scriptEnv]` section
  - **Usage:** Automatically available to all scripts in `.chezmoiscripts/`
  - **Note:** Scripts access mise-managed tools via `mise exec --` prefix, not PATH
- mise: env vars, paths
  - **Location:** `~/.config/mise/config.toml` → `[[env]]` section
  - **Usage:** Active when mise shell integration is enabled (via `mise activate`)
  - **Note**: Inherit environment variables from system, not chezmoi
- nushell: env vars, paths
  - **Location:** `~/.config/nushell/env/*.nu`
  - **Purpose:** Provides environment variables for interactive nushell sessions
  - **Usage:** Loaded when launching interactive nushell shell
  - **Note:** Maintains independent PATH management as fallback for non-mise contexts

---

## Script Execution Order

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

> [!NOTE]
> WSL2 does not need setup SSH because it uses Windows SSH via interop (`ssh.exe`), which reads Windows SSH configuration.

> [!NOTE]
> Windows and macOS Rime/Fcitx5 setup has been migrated to their respective init scripts (`init/win.ps1` and `init/darwin.sh`) for better bootstrap experience. Arch Linux retains the chezmoi script for potential future native desktop setup.

### Platform-Specific Wrappers

Scripts use templating to select platform-specific implementations:

```
run_onchange_after_10-install-system-packages.sh.tmpl
├── Windows: install-scoop-packages.ps1
└── Linux: install-packages-arch.sh (pacman)
```

Common package data is unified in `.chezmoidata/pm/common.yml` and merged with platform-specific package lists.

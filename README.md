# dotfile

Multi-platform dotfiles managed with chezmoi.

## Quick Start

Automated bootstrap scripts are available for all supported platforms. These scripts will install all prerequisites, configure 1Password, and apply your dotfiles automatically.

**Prerequisites for all platforms:**

- Internet access and GitHub connectivity
- Age passphrase ready (for decrypting encrypted files)
- 1Password account (for SSH authentication)

**After bootstrap completes:**

- Restart your shell to load new configurations
- Chezmoi will automatically run remaining setup scripts
- Check `~/.config` for your configurations

---

### Windows

```powershell
irm https://raw.githubusercontent.com/noidilin/dotfiles/main/init/win.ps1 | iex
```

**What it does:**

- Installs Scoop package manager
- Installs bootstrap tools (git, chezmoi, age, gsudo)
- Enables Developer Mode and symlink privileges
- Installs and configures 1Password
- Runs `chezmoi init --apply`
- Downloads Rime language model (optional)

**Time:** ~10-15 minutes (includes manual 1Password setup and symlink configuration)

---

### macOS

> [!CAUTION]
> This script must be run locally (not via pipe) because:
>
> - Homebrew installation needs to prompt for sudo password
> - 1Password configuration requires manual steps with user interaction
> - Script pauses at checkpoints and waits for your input

```bash
curl -fsSL https://raw.githubusercontent.com/noidilin/dotfiles/main/init/darwin.sh > init.sh && bash init.sh
```

**What it does:**

- Installs Homebrew package manager
- Installs bootstrap tools (git, chezmoi, age)
- Installs and configures 1Password
- Runs `chezmoi init --apply`
- Installs Fcitx5-Rime and optionally downloads the Rime language model

**Time:** ~5-10 minutes (includes Xcode CLT installation and manual 1Password setup)

> [!TIP]
> The host name displayed in terminal can be further set with
> `sudo scutil --set HostName <new host name>`

---

### Arch Linux (WSL2)

> [!NOTE]
> **Prerequisites:** This script assumes you've already completed Windows setup using `init/win.ps1`,
> which installs and configures 1Password. WSL2 accesses 1Password via Windows interop.

```bash
curl -fsSL https://raw.githubusercontent.com/noidilin/dotfiles/main/init/wsl.sh | bash
```

**What it does:**

- Verifies 1Password access via Windows interop
- Updates system packages
- Installs bootstrap tools (git, base-devel, openssh, chezmoi, age, yay)
- Runs `chezmoi init --apply`

**Time:** ~5-10 minutes (includes yay AUR helper build)

---

## Supported Platforms

- **Windows**: Primary platform with full configuration
- **Arch Linux (WSL2)**: CLI tools only, uses Windows interop for SSH/GPG
- **Arch Linux (Native)**: Planned support with desktop environment (minimal setup for now)
- **macOS**: Configured but not actively used

Configs are automatically filtered based on platform and environment detection via chezmoi templates.

## How It Works

### Bootstrap Scripts (`init/`)

**Recommended:** Use the automated bootstrap scripts (see [Quick Start](#quick-start) above).

- `init/win.ps1` - Windows bootstrap automation
- `init/darwin.sh` - macOS bootstrap automation  
- `init/wsl.sh` - Arch Linux WSL2 bootstrap automation

These scripts handle initial setup before chezmoi can run.

### Chezmoi Scripts (`home/.chezmoiscripts/`)

After dotfiles are applied, chezmoi automatically runs platform-specific scripts to install packages and configure your system:

**Execution order:**

1. `run_once_before_*` - Prerequisites (decrypt keys, install package managers)
2. `run_onchange_before_*` - Dynamic prerequisites (SSH config setup)
3. **[Dotfiles applied to target directories]**
4. `run_onchange_after_*` - Declarative package installation (responds to config changes)
5. `run_once_after_*` - One-time system setup

**Package installation:**

- `10-*-pkgs` - System packages (Scoop/Homebrew/Pacman)
- `20-mise-tools` - Runtime version managers (Node, Python, etc.)
- `21-cargo-pkgs` - Rust packages
- `22-pnpm-pkgs` - Node.js global packages
- `23-uv-pkgs` - Python packages

Package lists are defined in `home/.chezmoidata/pm/*.yml` and automatically installed when changed.

> [!NOTE]
> **XDG Base Directory Support**
>
> Dotfiles follow XDG Base Directory specification:
>
> - `XDG_CONFIG_HOME` = `~/.config` (configuration files)
> - `XDG_DATA_HOME` = `~/.local/share` (data files)
> - `XDG_CACHE_HOME` = `~/.cache` (cache files)
>
> Most modern CLI tools respect these variables. For apps that don't (like some GUI apps), symlinks are created via `run_onchange_after_05-setup-symlinks.ps1` (Windows only).

### Legacy Setup Scripts (Deprecated)

The `home/dot_config/setup-win/` directory (target: `~/.config/setup-win/`) contains legacy manual setup scripts. These are now superseded by the automated bootstrap + chezmoi workflow but are kept for reference.

If automation cannot be used, follow `docs/bootstrap-windows.md` for a manual bootstrap sequence.

---

## Age Bootstrap Status

> [!CAUTION]
> This repo currently contains no repo-managed encrypted secrets. The existing `age` bootstrap/config/scripts remain in place as legacy support for a previous secret-management workflow and for possible future use. Normal `chezmoi` setup should not require these files unless encrypted secrets are added back to the repo.

Reference: [Encryption - chezmoi](https://www.chezmoi.io/user-guide/frequently-asked-questions/encryption/)

The current `age` bootstrap stack is still present in the repo:

1. `home/.chezmoi.toml.tmpl`
   Configures `chezmoi` to use `age` with a local identity file.
2. `home/chezmoi-crypto-key.txt.age`
   Stores a passphrase-protected bootstrap copy of the `age` identity.
3. `home/.chezmoiscripts/*/run_once_before_01-decrypt-private-key.*`
   Restores the local identity file on a fresh machine before normal `chezmoi` processing.

This setup only matters if encrypted files are added back to the repo with `chezmoi add --encrypt`.

### Historical Workflow

The old workflow was:

1. Generate an `age` private key for `chezmoi` secret encryption.
2. Save an encrypted bootstrap copy of that key in the repo.
3. Use bootstrap scripts to restore the key on a new machine.
4. Add encrypted files with `chezmoi add --encrypt {file}`.

In other words, the bootstrap remains documented here so the existing config and scripts are understandable, but it is not currently needed for any checked-in secret files.

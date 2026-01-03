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
- Installs bootstrap tools (chezmoi, age, openssh, vivid, gsudo)
- Enables Developer Mode and symlink privileges
- Installs and configures 1Password
- Runs `chezmoi init --apply`

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
- Installs bootstrap tools (git, chezmoi, age, vivid)
- Installs and configures 1Password
- Runs `chezmoi init --apply`

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
- Installs bootstrap tools (git, chezmoi, age, vivid, yay)
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

The `home/.local/etc/setup-win/` directory contains legacy manual setup scripts. These are now superseded by the automated bootstrap + chezmoi workflow but are kept for reference.

---

## Setup age Keys

Since I stored some api keys for AI chat bot in my dotfiles, I encrypted it with `chezmoi` using `age` encryption. However, `chezmoi` needs to setup a `age` private key first to encrypt and decrypt the secret files.

reference: [Encryption - chezmoi](https://www.chezmoi.io/user-guide/frequently-asked-questions/encryption/)

The strategy:

### 1. Generate an age private key, which will be used to encrypt and decrypt secrets

```sh
chezmoi cd ~
age-keygen | age --armor --passphrase > key.txt.age
```

> [!TIP]
> The mysterious key.txt
> The 'key.txt' will be the private key to encrypt and decrypt files processed with `chezmoi add --encrypt {file}`
> I can further encrypt this private key with a passphrase to safely save it to remote repo.
> The passphrase will be used to decrypt the private key when setting up a new device.

### 2. Setup `chezmoi` script template to decrypt the private key if needed

```sh
# pseudo code
# check if the key exist
# `mkdir` for the key's parent dir
# `chezmoi age decrypt --output {private-key} --passphrase {encrypted-private-key}`
# set private key permission `chmod 600 {private-key}`
```

### 3. Configure `chezmoi.toml` to use the private key, and `age` encryption

```toml
encryption = "age"
[age.identity]: private key path
[age.recipient]: public key of the private key
```

### 4. Add my secret files with encryption

```sh
chezmoi add --encrypt {file}
```

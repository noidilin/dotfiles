# Bootstrap Arch Linux System

Complete guide to set up Arch Linux (WSL2 or bare metal) with dotfiles managed by chezmoi.

## Prerequisites

- Arch Linux installed (WSL2 or bare metal)
- Internet connection
- GitHub repository access (SSH or HTTPS)
- Age encryption key (if using encrypted files)

## Initial Setup Process

### Step 1: Update System

```bash
sudo pacman -Syu
```

### Step 2: Install Essential Bootstrap Tools

Needed tools:

- sudo: add command for normal user
- neovim: edit `sudoers` file with
  - `EDITOR=nano visudo`
- openssh: setup ssh
- git: initialize chezmoi repo
- chezmoi:
  - which: setup script (check nushell)
  - age: decryption
- vivid: command used by nushell config

```bash
sudo pacman -S neovim openssh git chezmoi which age vivid
```

### Step 3: Setup Age Encryption Key (Optional)

If you have encrypted files in your dotfiles (API keys, secrets):

**Option A: Copy from existing system (e.g., Windows WSL)**

```bash
mkdir -p ~/.config
cp /mnt/c/Users/noid/.config/.age-key.txt ~/.config/.age-key.txt
chmod 600 ~/.config/.age-key.txt
```

**Option B: Decrypt from repository**

```bash
# You'll need the passphrase used to encrypt the key
mkdir -p ~/.config
age --decrypt /path/to/age-key.txt.age > ~/.config/.age-key.txt
chmod 600 ~/.config/.age-key.txt
```

**Option C: Skip if no encrypted files**

If you don't have encrypted files, skip this step.

### Step 4: Initialize Chezmoi

Clone and apply dotfiles repository:

```bash
# For SSH (recommended)
chezmoi init --apply git@github.com:noidilin/dotfiles.git

# Or for HTTPS
chezmoi init --apply https://github.com/noidilin/dotfiles.git
```

**What happens next:**
Chezmoi will automatically run installation scripts:

1. **Decrypt age keys** (if encrypted files exist)
2. **Install packages via pacman** (CLI tools, editors, GUI apps)
3. **Install Node.js global packages** (via pnpm/bun, if mise is configured)
4. **Set Nushell as default shell**

This process may take 10-20 minutes depending on your internet connection.

## Post-Installation

### Verify Installation

```bash
# Check installed packages
pacman -Q | grep -E '(nushell|starship|mise|yazi|lazygit)'

# Check mise and runtime versions
mise doctor
mise list

# Check Node.js global packages (if applicable)
pnpm list -g
```

### Restart Shell

Log out and log back in, or run:

```bash
exec nu
```

### Configure Git Credentials

If using SSH (recommended):

```bash
# Generate SSH key if you don't have one
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy public key
cat ~/.ssh/id_ed25519.pub

# Add to GitHub: https://github.com/settings/keys
```

## What Gets Installed?

### Packages Installed Automatically

The installation script (`run_onchange_install-packages-arch.sh.tmpl`) installs:

**Core Shells & Prompt:**

- nushell
- starship

**CLI Tools:**

- bat, eza, fd, ripgrep, sd, fzf, zoxide
- yazi, lazygit, bottom
- mise, git-delta
- age, fastfetch, atuin, carapace-bin
- imagemagick, ast-grep
- 7zip, ffmpeg, jq, wget, unzip, unrar, gzip, poppler, pastel, vivid, gh, openssh

**Editors:**

- neovim
- code (VSCode)

**GUI Apps (if specified):**

- obs-studio
- obsidian (from AUR, if configured)

**Development Toolchain:**

- mise (runtime version manager)
- base-devel (gcc, make, etc.)

### Configuration Files Synced

- Git configuration (`.gitconfig`, `.gitignore`)
- Nushell (shell, env, aliases, completions)
- Starship prompt
- CLI tool configs (bat, eza, yazi, lazygit, bottom, delta, etc.)
- Mise runtime configuration
- OpenCode configuration
- Encrypted API keys (if age key is set up)

### Windows-Specific Configs NOT Synced

The following are automatically excluded via `.chezmoiignore`:

- Flow Launcher
- Windows Terminal (winterm)
- GlazeWM
- Rime input method
- PowerShell configs
- FlexASIO
- Windows setup scripts

## Updating Configuration

### Add New Package

1. Edit `.chezmoidata.toml`:

   ```bash
   chezmoi edit .chezmoidata.toml
   ```

2. Add package to appropriate section:
   - `packages.cli.common.tools` - Cross-platform CLI tools
   - `packages.cli.linux.pacman` - Linux-specific tools
   - `packages.gui.linux.pacman` - GUI applications

3. Apply changes:

   ```bash
   chezmoi apply
   ```

### Update Existing Files

```bash
# Edit file in chezmoi source
chezmoi edit ~/.config/nushell/config.nu

# Preview changes
chezmoi diff

# Apply changes
chezmoi apply
```

### Sync from Repository

```bash
# Pull latest changes
chezmoi update -v

# Or manually
cd $(chezmoi source-path)
git pull
chezmoi apply
```

## Troubleshooting

### Package Installation Failed

Run the installation script manually:

```bash
bash $(chezmoi source-path)/home/.chezmoiscripts/run_onchange_install-packages-arch.sh.tmpl
```

### Nushell Not Set as Default

```bash
# Check current shell
echo $SHELL

# Set manually
nu_path=$(which nu)
echo "$nu_path" | sudo tee -a /etc/shells
chsh -s "$nu_path"
```

### Encrypted Files Not Decrypting

Verify age key is properly installed:

```bash
ls -la ~/.config/.age-key.txt
# Should show: -rw------- (permissions 600)

# Test decryption
chezmoi decrypt ~/.config/api/encrypted_ANTHROPIC_API_KEY.age
```

### Mise Tools Not Found

Restart terminal or activate mise:

```bash
mise activate
```

### Force Re-run Scripts

To force chezmoiscripts to run again:

```bash
# Remove script state
chezmoi state delete-bucket --bucket=scriptState

# Re-apply
chezmoi apply
```

## Advanced Usage

### Install AUR Packages

For AUR packages (like `obsidian`), use an AUR helper:

```bash
# Install yay
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

# Install AUR packages
yay -S obsidian visual-studio-code-bin
```

### Customize Package Lists

Edit `.chezmoidata.toml` to:

- Add/remove packages
- Change mise runtime versions
- Add AUR packages (install manually or via helper)

### WSL-Specific Configuration

For WSL2 users, some additional setup may be needed:

```bash
# Access Windows files
cd /mnt/c/Users/noid

# Use Windows binaries (if needed)
export PATH="$PATH:/mnt/c/Windows/System32"
```

## File Structure

```
~/.local/share/chezmoi/           # Chezmoi source directory
├── .chezmoidata.toml             # Package/config data
├── home/
│   ├── .chezmoiscripts/
│   │   ├── run_onchange_install-packages-arch.sh.tmpl
│   │   └── run_onchange_after_12-install-node-packages.sh.tmpl
│   └── dot_config/
│       ├── nushell/
│       ├── starship.toml
│       ├── mise/
│       └── ...
└── docs/
    └── bootstrap-arch.md         # This file
```

## XDG Base Directory

Arch Linux follows XDG standards by default:

- `XDG_CONFIG_HOME` = `~/.config`
- `XDG_DATA_HOME` = `~/.local/share`
- `XDG_CACHE_HOME` = `~/.cache`

These are set in Nushell environment configuration.

## Next Steps

- Customize Nushell configs in `~/.config/nushell/`
- Install additional AUR packages
- Configure mise runtimes: `mise install`
- Set up SSH keys for GitHub
- Read [Windows bootstrap guide](./bootstrap-windows.md) for dual-boot setups

## Resources

- [Chezmoi Documentation](https://www.chezmoi.io/)
- [Arch Wiki](https://wiki.archlinux.org/)
- [Nushell Book](https://www.nushell.sh/book/)
- [Mise Documentation](https://mise.jdx.dev/)

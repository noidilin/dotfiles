# Arch Linux WSL2 Setup Guide

This guide walks you through setting up your dotfiles on Arch Linux WSL2 using chezmoi with selective syncing from your Windows configuration.

## Prerequisites

- Arch Linux installed in WSL2
- Access to your Windows home directory from WSL
- GitHub repository with your chezmoi dotfiles

## Initial Setup

### 1. Install Chezmoi and Age

```bash
sudo pacman -S chezmoi age
```

### 2. Copy Age Encryption Key

Your encrypted API keys (ANTHROPIC_API_KEY, TAVILY_API_KEY) require the age encryption key to decrypt.

**Option A: Copy from Windows (if age key is already in Windows .config)**

```bash
mkdir -p ~/.config
cp /mnt/c/Users/noid/.config/.age-key.txt ~/.config/.age-key.txt
chmod 600 ~/.config/.age-key.txt
```

**Option B: Copy from chezmoi source**

If you have the encrypted age key in your chezmoi repo:

```bash
# First, you'll need to decrypt age-key.txt.age manually
# You'll need the passphrase that was used to encrypt it
mkdir -p ~/.config
age --decrypt /path/to/age-key.txt.age > ~/.config/.age-key.txt
chmod 600 ~/.config/.age-key.txt
```

### 3. Initialize Chezmoi from GitHub

Replace `YOUR-USERNAME` and `YOUR-REPO` with your GitHub details:

```bash
chezmoi init https://github.com/YOUR-USERNAME/YOUR-REPO.git
```

### 4. Preview What Will Be Applied

Before applying, check what files will be synced:

```bash
chezmoi diff
```

This shows you exactly what configs will be applied to your Arch system. You should see:
- ✅ Nushell configs
- ✅ Git, Starship, CLI tools (bat, eza, yazi, lazygit, etc.)
- ✅ Encrypted API keys
- ❌ Windows-specific configs (Flow Launcher, WinTerm, PowerShell, etc.) - these should NOT appear

### 5. Apply Dotfiles

```bash
chezmoi apply -v
```

The `-v` flag shows verbose output so you can see what's being applied.

### 6. Automatic Package Installation

The installation script `.chezmoiscripts/run_onchange_install-packages-arch.sh.tmpl` will automatically run and install:

- **Shell**: Nushell, Starship
- **CLI tools**: bat, eza, fd, ripgrep, sd, fzf, zoxide
- **File managers**: yazi, lazygit, bottom
- **Dev tools**: mise, git-delta
- **Utilities**: age, fastfetch, atuin, carapace, imagemagick, ast-grep

The script will also set Nushell as your default shell.

### 7. Restart Your Shell

After the setup completes:

```bash
# Log out and log back in to WSL, or run:
exec nu
```

## What Gets Synced?

### Configs Synced to Arch Linux

- Git configuration and ignore patterns
- Starship prompt configuration
- Nushell configuration (config, env, aliases, tools)
- CLI tool configs: bat, eza, bottom, delta, yazi, lazygit, superfile, mise
- OpenCode configuration and themes
- Encrypted API keys (ANTHROPIC_API_KEY, TAVILY_API_KEY)
- Shell utilities: carapace, fastfetch, vivid, harper-ls

### Configs NOT Synced to Arch Linux

The following Windows-specific configs are automatically excluded via `.chezmoiignore`:

- Flow Launcher (Windows app launcher)
- Windows Terminal (winterm)
- GlazeWM (Windows window manager)
- Rime input method (Windows IME)
- PowerShell configurations
- Windows setup scripts
- FlexASIO audio configuration
- VSCode CSS customizations

## Managing Your Dotfiles

### Viewing Status

```bash
# Check what's managed by chezmoi
chezmoi managed

# See differences between repo and system
chezmoi diff
```

### Adding New Files

```bash
# Add a new config file
chezmoi add ~/.config/some-tool/config.toml

# Add an encrypted file
chezmoi add --encrypt ~/.config/api/SECRET_KEY
```

### Updating from Repository

```bash
# Pull latest changes from GitHub
chezmoi update -v
```

### Pushing Changes

After editing configs in Arch:

```bash
# Open file in editor (edits the source in chezmoi repo)
chezmoi edit ~/.config/nushell/config.nu

# Or add changes from your home directory
chezmoi add ~/.config/nushell/config.nu

# Commit and push to GitHub
cd $(chezmoi source-path)
git add .
git commit -m "Update nushell config from Arch"
git push
```

## Troubleshooting

### Encrypted Files Not Decrypting

Check that your age key is properly installed:

```bash
ls -la ~/.config/.age-key.txt
# Should show: -rw------- (permissions 600)
```

Test decryption:

```bash
chezmoi decrypt ~/.config/api/encrypted_ANTHROPIC_API_KEY.age
```

### Package Installation Failed

If the automatic package installation script fails, run it manually:

```bash
bash $(chezmoi source-path)/.chezmoiscripts/run_onchange_install-packages-arch.sh.tmpl
```

### Nushell Not Set as Default Shell

```bash
# Check current shell
echo $SHELL

# Manually set nushell
nu_path=$(which nu)
echo "$nu_path" | sudo tee -a /etc/shells
chsh -s "$nu_path"
```

### Files from Windows Appearing in Arch

Check your `.chezmoiignore` file:

```bash
chezmoi cat-config
```

Ensure Windows-specific paths are properly excluded for Linux.

## XDG Base Directory Structure

The configs use XDG base directories:

- `XDG_CONFIG_HOME` = `~/.config`
- `XDG_DATA_HOME` = `~/.local/share`
- `XDG_CACHE_HOME` = `~/.cache`

These are already set up in the Nushell environment configuration.

## Next Steps

1. **Customize for Arch**: Edit configs specific to your Arch setup
2. **Install AUR packages**: Use `yay` or `paru` for additional tools
3. **Test encrypted APIs**: Verify your API keys work in Arch
4. **Sync back to Windows**: Push changes from Arch back to your repo

## Additional Resources

- [Chezmoi Documentation](https://www.chezmoi.io/)
- [Age Encryption](https://github.com/FiloSottile/age)
- [Nushell Book](https://www.nushell.sh/book/)

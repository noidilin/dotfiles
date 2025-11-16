# Bootstrap Fresh Windows System

Complete guide to set up a fresh Windows machine with dotfiles managed by chezmoi.

## Prerequisites

- Windows 10 or Windows 11
- PowerShell 5.1+ (built-in)
- Administrator access (for some operations)
- Git credentials configured (SSH or HTTPS)

## Initial Setup Process

### Step 1: Install Scoop

Open PowerShell (non-admin) and run:

```powershell
# Set execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Install Scoop
irm get.scoop.sh | iex
```

### Step 2: Install Git

Git is required before adding Scoop buckets:

```powershell
scoop install git
```

### Step 3: Add Scoop Buckets

```powershell
scoop bucket add extras
scoop bucket add nerd-fonts
```

### Step 4: Install Bootstrap Tools

Install essential tools needed for chezmoi initialization:

```powershell
scoop install chezmoi age nu pwsh
```

**Tools installed:**
- `chezmoi` - Dotfiles manager
- `age` - Encryption tool for private files
- `nu` - Nushell (primary shell)
- `pwsh` - PowerShell Core

### Step 5: Initialize Chezmoi

Clone and apply dotfiles repository:

```powershell
# For SSH (recommended)
chezmoi init --apply git@github.com:noidilin/dotfiles.git

# Or for HTTPS
chezmoi init --apply https://github.com/noidilin/dotfiles.git
```

**What happens next:**
Chezmoi will automatically run installation scripts in this order:

1. **Decrypt age encryption keys** (you'll be prompted for passphrase)
2. **Setup environment variables** (XDG paths, etc.)
3. **Create symbolic links** (for apps that don't support XDG)
4. **Install Scoop packages** (CLI tools, fonts, editors, GUI apps)
5. **Install WinGet packages** (system apps)
6. **Install Node.js global packages** (via pnpm/bun)

This process may take 15-30 minutes depending on your internet connection.

## Post-Installation

### Verify Installation

Check that essential tools are installed:

```powershell
# Check Scoop packages
scoop list

# Check WinGet packages
winget list

# Check mise and runtime versions
mise doctor
mise list

# Check Node.js global packages
pnpm list -g
```

### Set Nushell as Default (Optional)

To use Nushell in Windows Terminal by default:

1. Open Windows Terminal settings
2. Go to "Startup" → "Default profile"
3. Select "Nushell"

### Configure Git Credentials

If using SSH (recommended):

```powershell
# Generate SSH key if you don't have one
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy public key to clipboard
Get-Content ~/.ssh/id_ed25519.pub | Set-Clipboard

# Add to GitHub: https://github.com/settings/keys
```

### Manual Steps Required

Some applications may require manual configuration:

1. **PowerToys** - Configure keyboard shortcuts
2. **GlazeWM** - Window manager (config already linked)
3. **Rime Input** - IME configuration (config already linked)
4. **FlexASIO** - Audio driver (config already linked)

## Updating Configuration

### Add New Package

1. Edit `.chezmoidata.toml` in your source directory:
   ```powershell
   chezmoi edit .chezmoidata.toml
   ```

2. Add package to appropriate section (e.g., `packages.cli.windows.scoop`)

3. Apply changes:
   ```powershell
   chezmoi apply
   ```

The package will be automatically installed on next `chezmoi apply`.

### Update Existing Files

```powershell
# Edit file in chezmoi source directory
chezmoi edit ~/.config/nushell/config.nu

# Preview changes before applying
chezmoi diff

# Apply changes
chezmoi apply
```

### Sync from Repository

```powershell
# Pull latest changes from git
chezmoi update

# Or manually:
cd $(chezmoi source-path)
git pull
chezmoi apply
```

## Troubleshooting

### Symbolic Links Fail

**Error:** "You do not have sufficient privilege to perform this operation"

**Solutions:**
1. Run PowerShell as Administrator (one-time setup)
2. Or enable Windows Developer Mode:
   - Settings → Update & Security → For developers → Developer Mode

### Scoop Install Fails

**Error:** "Could not find manifest for..."

**Solution:** Ensure buckets are added:
```powershell
scoop bucket list
scoop bucket add extras
scoop bucket add nerd-fonts
```

### WinGet Requires UAC

WinGet installations may trigger User Account Control (UAC) prompts. Click "Yes" to allow installation.

### Mise Tools Not Found

**Error:** "command not found" after installing via mise

**Solution:** Restart terminal or run:
```powershell
mise activate
```

### Chezmoi Scripts Don't Run

**Issue:** Scripts only run once (`run_once_*`) or when data changes (`run_onchange_*`)

**Solution:** To force re-run:
```powershell
# Remove script state
chezmoi state delete-bucket --bucket=scriptState

# Re-apply
chezmoi apply
```

## Advanced Usage

### Customize Package Installation

Modify `.chezmoidata.toml` to:
- Add/remove packages
- Change mise runtime versions
- Modify environment variables
- Add/remove symbolic links

### Bootstrap on Multiple Machines

1. Install Scoop + bootstrap tools (Steps 1-4)
2. Run `chezmoi init --apply`
3. All configurations sync automatically

### Exclude Certain Files/Platforms

Edit `.chezmoiignore` to exclude files from certain platforms.

## File Structure

```
~/.local/share/chezmoi/           # Chezmoi source directory
├── .chezmoidata.toml             # Package/config data (single source of truth)
├── home/
│   ├── .chezmoiscripts/          # Installation scripts
│   │   ├── run_once_after_02-setup-env-variables.ps1.tmpl
│   │   ├── run_once_after_03-setup-symlinks.ps1.tmpl
│   │   ├── run_onchange_after_10-install-scoop-packages.ps1.tmpl
│   │   ├── run_onchange_after_11-install-winget-packages.ps1.tmpl
│   │   └── run_onchange_after_12-install-node-packages.ps1.tmpl
│   └── dot_config/               # Configuration files
│       ├── nushell/
│       ├── pwsh/
│       ├── starship.toml
│       └── ...
└── docs/
    └── bootstrap-windows.md      # This file
```

## Next Steps

- Explore `~/.config` for all configuration files
- Customize shell configs in `~/.config/nushell/` or `~/.config/pwsh/`
- Add personal scripts to `~/.local/bin/`
- Read [Arch Linux bootstrap guide](./bootstrap-arch.md) for WSL2 setup

## Resources

- [Chezmoi Documentation](https://www.chezmoi.io/)
- [Scoop Documentation](https://scoop.sh/)
- [Mise Documentation](https://mise.jdx.dev/)
- [Nushell Documentation](https://www.nushell.sh/)

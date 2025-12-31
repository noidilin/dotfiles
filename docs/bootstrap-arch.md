# Bootstrap Arch Linux WSL2 (Pre-flight Checklist)

Preparation steps required before running `chezmoi init --apply <repo>` on Arch Linux running in WSL2.

**Note:** This guide is specifically for WSL2. For bare metal Arch Linux, see the macOS guide for native SSH configuration.

## Prerequisites

### 0. Verify WSL Interop is Enabled

Ensure `/etc/wsl.conf` has Windows interop enabled:

```bash
# Check current settings
cat /etc/wsl.conf
```

Should contain:
```ini
[interop]
enabled = true
appendWindowsPath = true
```

If missing or incorrect, create/edit `/etc/wsl.conf`:
```bash
sudo tee /etc/wsl.conf > /dev/null <<EOF
[interop]
enabled = true
appendWindowsPath = true
EOF
```

Then restart WSL:
```powershell
# In Windows PowerShell
wsl --shutdown
```

### 1. System Requirements

- Arch Linux installation with sudo-enabled user and internet access
- GitHub access (will be configured via 1Password SSH)
- Optional: age secret key if the repo encrypts files

## Preparation Steps

### 2. Install 1Password on Windows (Required)

**WSL2 accesses 1Password via Windows interop** - you cannot use a Linux-native 1Password installation.

#### 2.1 Install 1Password Desktop App (Windows)

Download and install from: https://1password.com/downloads/windows/

**Required settings in 1Password for Windows:**
1. Enable biometric unlock: `Settings → Security → Unlock using Windows Hello`
2. Enable CLI integration: `Settings → Developer → ✓ Integrate with 1Password CLI`
3. Enable SSH agent: `Settings → Developer → ✓ Use the SSH agent`

#### 2.2 Install 1Password CLI (Windows)

```powershell
# In Windows PowerShell (NOT WSL2)
winget install --id AgileBits.1PasswordCLI
```

#### 2.3 Verify from WSL2

```bash
# In WSL2 - test that op.exe is accessible via interop
op.exe --version
# Should output: 2.31.1 (or similar)

# Test authentication (will prompt for biometric unlock if needed)
op.exe whoami
# Should show your 1Password account details

# Test reading a secret (optional verification)
op.exe read "op://dev/github-win/public key"
# Should output your SSH public key
```

**Important Notes:**
- WSL2 uses `op.exe` (Windows CLI) via interop, **NOT** a Linux `op` binary
- Do **NOT** install 1Password CLI in Linux (e.g., via `pacman -S 1password-cli`)
- Chezmoi is automatically configured to use `op.exe` on WSL2 (see `.chezmoi.toml.tmpl`)
- Templates using `onepasswordRead` will call `op.exe` and leverage Windows biometric unlock

#### 2.4 Create or Verify GitHub SSH Key in 1Password

The dotfiles use the `github-win` SSH key from 1Password (shared between Windows and WSL2).

Verify the key exists:
```bash
# In WSL2
op.exe item get "github-win" --fields "public key"
```

If it doesn't exist, create it:
```bash
# Generate SSH key in 1Password
op.exe item create \
  --category="SSH Key" \
  --title="github-win" \
  --vault="dev" \
  --generate-password=ssh

# Get the public key
op.exe item get "github-win" --fields "public key"
```

Add the public key to GitHub:
```bash
# Option 1: Using GitHub CLI (if installed)
gh auth login
op.exe item get "github-win" --fields "public key" | gh ssh-key add - --title "github-win-wsl2"

# Option 2: Manual (copy output and paste at https://github.com/settings/keys)
op.exe item get "github-win" --fields "public key"
```

### 3. Update System and Install Bootstrap Packages

```bash
# Update the system
sudo pacman -Syu

# Install required bootstrap packages
sudo pacman -S --needed git openssh chezmoi age vivid which
```

Tools installed:
- `git` and `openssh` for cloning via SSH or HTTPS
- `chezmoi` to apply the dotfiles repo
- `age` for decrypting encrypted files
- `vivid` and `which`, used by shell configs/scripts during the first apply

### 4. Provide the age key (if applicable)

Copy the age key from Windows:

```bash
mkdir -p ~/.config
cp /mnt/c/Users/$USER/.config/.age-key.txt ~/.config/.age-key.txt
chmod 600 ~/.config/.age-key.txt
```

## Run Chezmoi

**IMPORTANT:** Use HTTPS (not SSH) for the initial clone:

```bash
# Initialize chezmoi with HTTPS
chezmoi init --apply https://github.com/noidilin/dotfiles.git
```

**What happens during `chezmoi apply`:**

1. **Phase 0** - Configuration loaded:
   - `.chezmoi.toml.tmpl` configures `op.exe` for 1Password CLI access
   - Templates using `onepasswordRead` will use Windows 1Password via interop

2. **Phase 5** - Files and externals are applied:
   - Git config applied with `core.sshCommand = ssh.exe` (Windows SSH interop)
   - 1Password agent.toml configuration applied
   - `.chezmoiexternals` clone via SSH using `ssh.exe` and Windows 1Password agent
   - All dotfiles applied to home directory

3. **Phase 6** - `run_after_*` scripts run:
   - Package installation (pacman, yay, mise)
   - Environment setup

**Note:** WSL2 doesn't need a `run_before` script for SSH setup because:
- `ssh.exe` uses Windows SSH configuration (not `~/.ssh/config` on Linux)
- 1Password SSH agent runs on Windows and is accessed via named pipe interop
- Git config is applied automatically before externals clone

## Troubleshooting

### `op.exe` or `ssh.exe` not found

**Symptom:** Error during `chezmoi init --apply`:
```
 ERROR: op.exe not found - Windows 1Password CLI is required
```

**Solutions:**
1. Verify WSL interop is enabled (see Prerequisites → Step 0)
2. Restart WSL: `wsl --shutdown` (in Windows PowerShell)
3. Ensure Windows `PATH` includes `op.exe`:
   ```powershell
   # In Windows PowerShell
   where.exe op
   # Should show: C:\Users\<user>\AppData\Local\Microsoft\WinGet\Links\op.exe
   ```

### `onepasswordRead` template errors

**Symptom:** Error during `chezmoi apply`:
```
error calling onepasswordRead: op.exe signin --raw: exit status 1
```

**Solutions:**
1. Ensure 1Password (Windows) is running and unlocked
2. Enable CLI integration: `1Password Settings → Developer → ✓ Integrate with 1Password CLI`
3. Test manually: `op.exe whoami` (should prompt for biometric unlock)
4. Check config: `chezmoi dump-config | grep -A3 onepassword`
   - Should show: `"command": "op.exe"` on WSL2

### SSH authentication fails during externals clone

**Symptom:** Error during `chezmoi apply`:
```
git@github.com: Permission denied (publickey)
```

**Solutions:**
1. Verify 1Password SSH agent is enabled: `1Password Settings → Developer → ✓ Use the SSH agent`
2. Test SSH connection: `ssh.exe -T git@github.com`
   - Should prompt for biometric unlock and show: "Hi <username>! You've successfully authenticated"
3. Verify key is in 1Password: `op.exe item get "github-win" --fields "public key"`
4. Ensure key is added to GitHub: https://github.com/settings/keys

### WSL interop not working

**Symptom:** Commands like `op.exe` or `ssh.exe` fail with "command not found"

**Solutions:**
1. Check `/etc/wsl.conf`:
   ```bash
   cat /etc/wsl.conf
   ```
   Should have:
   ```ini
   [interop]
   enabled = true
   appendWindowsPath = true
   ```
2. Restart WSL: `wsl --shutdown` (in Windows PowerShell)
3. Test Windows PATH access: `echo $PATH | grep -i windows`
   - Should show Windows paths like `/mnt/c/Windows/...`

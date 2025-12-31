# Bootstrap macOS (Pre-flight Checklist)

Preparation steps required before running `chezmoi init --apply <repo>` on macOS.

## Prerequisites

- macOS with Homebrew installed
- GitHub access (SSH key or HTTPS credentials)
- Optional: age secret key if the repo encrypts files

## Preparation Steps

1. **Install Homebrew** (if not already installed)

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Install required bootstrap packages**

   ```bash
   brew install chezmoi age vivid
   ```

   - `chezmoi` applies the dotfiles repo
   - `age` decrypts encrypted files
   - `vivid` is used by shell configs

3. **Install and configure 1Password (Required for SSH authentication)**

   This dotfiles repo uses SSH URLs for external repositories (nvim, wezterm, yazi). You must configure 1Password SSH agent before running `chezmoi init`.

   ```bash
   # Install 1Password
   brew install --cask 1password
   ```

   After installation:
   - Launch 1Password and sign in to your account
   - Go to **Settings → Developer**
   - Check ☑ **"Use the SSH agent"**
   - (Optional) Configure authorization preferences

   Verify the SSH key exists in 1Password:
   ```bash
   # Check if github-mac key exists
   op item get "github-mac" --fields "public key"
   ```

   If the key doesn't exist, create one:
   ```bash
   op item create --category="SSH Key" --title="github-mac" --vault="dev" --generate-password=ssh
   ```

   Add the public key to GitHub:
   ```bash
   # First time: authenticate with GitHub CLI
   brew install gh
   gh auth login

   # Upload SSH key to GitHub
   op item get "github-mac" --fields "public key" | gh ssh-key add - --title "$(hostname)"
   ```

4. **Provide the age key (if applicable)**

   Copy an existing key or decrypt the repository-provided key:

   ```bash
   # Copy from another machine
   mkdir -p ~/.config
   # Copy from your backup location
   cp /path/to/.age-key.txt ~/.config/.age-key.txt
   chmod 600 ~/.config/.age-key.txt
   ```

---

## Run Chezmoi

**IMPORTANT:** Use HTTPS (not SSH) for the initial clone:

```bash
# Initialize chezmoi with HTTPS
chezmoi init --apply https://github.com/noidilin/dotfiles.git
```

**What happens during `chezmoi apply`:**

1. **Phase 4** - `run_before_05-apply-ssh-config.sh` runs automatically:
   - Applies `~/.ssh/config` with 1Password agent socket path
   - Applies git config with GPG SSH signing configuration
   - Applies 1Password agent.toml configuration
   - Verifies 1Password SSH agent is running

2. **Phase 5** - Files and externals are applied:
   - `.chezmoiexternals` clone via SSH (works because SSH is now configured!)
   - All dotfiles applied to home directory

3. **Phase 6** - `run_after_*` scripts run:
   - Package installation (Homebrew, mise)
   - Environment setup

**That's it!** The automated script handles SSH configuration before externals clone.

---

## Troubleshooting

### SSH agent socket not found

If you see: `⚠ 1Password SSH agent not found`

**Solution:**
1. Open 1Password app
2. Go to Settings → Developer
3. Ensure "Use the SSH agent" is checked
4. Restart the terminal

### Permission denied when cloning externals

**Solution:**
1. Test SSH connection: `ssh -T git@github.com`
2. You should see a 1Password authorization prompt
3. Approve the connection
4. Re-run `chezmoi apply`

### 1Password CLI not found

**Solution:**
```bash
brew install 1password-cli
```

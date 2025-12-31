# Bootstrap Windows (Pre-flight Checklist)

Preparation steps required before running `chezmoi init --apply <repo>` on Windows 10/11.

## Prerequisites

- Windows user with PowerShell 5.1+ and internet access
- Ability to run PowerShell commands with Administrator rights **or** Developer Mode enabled (needed for symlink creation later). After enabling Developer Mode, sign out/in (or reboot) and run `whoami /priv | Select-String CreateSymbolic` to confirm `SeCreateSymbolicLinkPrivilege` shows as Enabled.
- GitHub access (SSH key or HTTPS credentials)
- Optional: age secret key if the repo encrypts files

## Preparation Steps

1. **Open PowerShell (non-admin) and allow scripts**

   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. **Install Scoop (package manager used for bootstrap tools)**

   ```powershell
   irm get.scoop.sh | iex
   ```

3. **Install Git (required before adding Scoop buckets)**

   ```powershell
   scoop install git
   ```

4. **Add required Scoop buckets**

   ```powershell
   scoop bucket add extras
   scoop bucket add nerd-fonts
   scoop bucket add wezterm-alt-icon https://github.com/ocodo/wezterm-alt-windows-icon-builds.git
   ```

5. **Install the tooling Chezmoi relies on during its first run**

   ```powershell
   scoop install chezmoi age openssh vivid
   ```

    - `chezmoi` applies the dotfiles
    - `age` decrypts encrypted files
    - `openssh` provides SSH client utilities
    - `vivid` is referenced by shell configs applied during bootstrap

6. **Install and configure 1Password (Required for SSH authentication)**

   This dotfiles repo uses SSH URLs for external repositories (nvim, wezterm, yazi). You must configure 1Password SSH agent before running `chezmoi init`.

   ```powershell
   # Install 1Password desktop app
   winget install AgileBits.1Password
   ```

   After installation:
   - Launch 1Password and sign in to your account
   - Go to **Settings → Developer**
   - Check ☑ **"Use the SSH agent"**
   - (Optional) Configure authorization preferences

   Verify the SSH key exists in 1Password:
   ```powershell
   # Check if github-win key exists
   op item get "github-win" --fields "public key"
   ```

   If the key doesn't exist, create one:
   ```powershell
   op item create --category="SSH Key" --title="github-win" --vault="dev" --generate-password=ssh
   ```

   Add the public key to GitHub:
   ```powershell
   # First time: authenticate with GitHub CLI
   gh auth login

   # Upload SSH key to GitHub
   op item get "github-win" --fields "public key" | gh ssh-key add - --title "$env:COMPUTERNAME"
   ```

7. **Provide the age key (if applicable)**
    - Copy an existing key into `$env:USERPROFILE\.config\.age-key.txt`, or
    - Decrypt `age-key.txt.age` from the repo using `age --decrypt` and save it with permissions restricted to your user account.

### Verify Developer Mode grants symlink privileges

> source: [Allow Users to Create Symbolic Links in Windows | Eu, Mircea](https://neacsu.net/posts/win_symlinks/)

1. Execute `secpol.msc`
2. Navigate to **Local Policies -> User Rights Assignment -> Create symbolic links**
3. Click on **Add User or Group** -> **Object Types...**
4. Check **Groups** option
5. Type 'Users' in the text field, then press **Cehck Names** button
6. **OK** -> **Apply** -> **OK**
7. Enable developer mode in windows system settings
8. Open a new PowerShell session (non-admin) and confirm the privilege is attached:

   ```powershell
   whoami /priv | Select-String CreateSymbolic
   ```

   The output should list `SeCreateSymbolicLinkPrivilege` with the state `Enabled`. If it does not, sign out/in (or reboot) and rerun the command.

---

## Run Chezmoi

**IMPORTANT:** Use HTTPS (not SSH) for the initial clone:

```powershell
# Initialize chezmoi with HTTPS
chezmoi init --apply https://github.com/noidilin/dotfiles.git
```

**What happens during `chezmoi apply`:**

1. **Phase 4** - `run_before_05-apply-ssh-config.ps1` runs automatically:
   - Applies SSH configuration for 1Password agent
   - Applies 1Password agent.toml configuration
   - Verifies 1Password SSH agent is running

2. **Phase 5** - Files and externals are applied:
   - `.chezmoiexternals` clone via SSH (works because SSH is now configured!)
   - All dotfiles applied to home directory

3. **Phase 6** - `run_after_*` scripts run:
   - Package installation (Scoop, WinGet, mise)
   - Environment setup

**That's it!** No manual intervention needed. The automated script handles SSH configuration before externals clone.

# Bootstrap Windows (Pre-flight Checklist)

Preparation steps required before running `chezmoi init --apply <repo>` on Windows 10/11.

## Prerequisites

- Windows user with PowerShell 5.1+ and internet access
- Ability to run PowerShell commands with Administrator rights **or** Developer Mode enabled (needed for symlink creation later)
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

5. **Install the mandatory bootstrap tools**

   Install the tooling Chezmoi relies on during its first run:

   ```powershell
   scoop install chezmoi age openssh vivid
   ```

   - `chezmoi` applies the dotfiles
   - `age` decrypts encrypted files
   - `openssh` provides SSH client utilities
   - `vivid` is referenced by shell configs applied during bootstrap

6. **Provide the age key (if applicable)**

   - Copy an existing key into `$env:USERPROFILE\.config\.age-key.txt`, or
   - Decrypt `age-key.txt.age` from the repo using `age --decrypt` and save it with permissions restricted to your user account.

7. **Confirm GitHub connectivity**

   ```powershell
   ssh -T git@github.com    # or test HTTPS credentials
   ```

## Run Chezmoi

With prerequisites in place, initialize and apply the repository:

```powershell
chezmoi init --apply git@github.com:noidilin/dotfiles.git
# or
chezmoi init --apply https://github.com/noidilin/dotfiles.git
```

Chezmoi will handle every subsequent action (symlink setup, Scoop/WinGet/mise installs, Nushell/Pwsh configuration, etc.), so no further manual prep is required before running the command above.

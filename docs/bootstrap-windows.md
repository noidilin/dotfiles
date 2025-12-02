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

6. **Provide the age key (if applicable)**
    - Copy an existing key into `$env:USERPROFILE\.config\.age-key.txt`, or
    - Decrypt `age-key.txt.age` from the repo using `age --decrypt` and save it with permissions restricted to your user account.

7. **Confirm GitHub connectivity**

   ```powershell
   ssh -T git@github.com    # or test HTTPS credentials
   ```

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

With prerequisites in place, initialize and apply the repository:

```powershell
chezmoi init --apply git@github.com:noidilin/dotfiles.git
# or
chezmoi init --apply https://github.com/noidilin/dotfiles.git
```

Chezmoi will handle every subsequent action (symlink setup, Scoop/WinGet/mise installs, Nushell/Pwsh configuration, etc.), so no further manual prep is required before running the command above.

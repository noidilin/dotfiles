# Chezmoi Scripts Order

## What happens during `chezmoi apply` in Windows

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

## What happens during `chezmoi apply` in WSL2

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

## What happens during `chezmoi apply` in MacOs

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

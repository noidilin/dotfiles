# Bootstrap Arch Linux (Pre-flight Checklist)

Preparation steps required before running `chezmoi init --apply <repo>` on Arch Linux (bare metal or WSL).

## Prerequisites

- Arch Linux installation with sudo-enabled user and internet access
- GitHub access (SSH key or HTTPS credentials)
- Optional: age secret key if the repo encrypts files

## Preparation Steps

1. **Update the system**

   ```bash
   sudo pacman -Syu
   ```

2. **Install required bootstrap packages**

   Tools needed before `chezmoi init`:

   - `git` and `openssh` for cloning via SSH or HTTPS
   - `chezmoi` to apply the dotfiles repo
   - `age` for decrypting encrypted files
   - `vivid` and `which`, used by shell configs/scripts during the first apply

   ```bash
   sudo pacman -S --needed git openssh chezmoi age vivid which
   ```

3. **Provide the age key (if applicable)**

   Copy an existing key or decrypt the repository-provided key so Chezmoi can read encrypted files.

   ```bash
   # Copy from another machine (example: Windows user directory)
   mkdir -p ~/.config
   cp /mnt/c/Users/<user>/.config/.age-key.txt ~/.config/.age-key.txt
   chmod 600 ~/.config/.age-key.txt

   # OR decrypt the bundled key
   age --decrypt /path/to/age-key.txt.age > ~/.config/.age-key.txt
   chmod 600 ~/.config/.age-key.txt
   ```

4. **Confirm GitHub connectivity**

   ```bash
   ssh -T git@github.com    # or test HTTPS credentials
   ```

## Run Chezmoi

With the prerequisites satisfied, initialize and apply the repository:

```bash
chezmoi init --apply git@github.com:noidilin/dotfiles.git
# or
chezmoi init --apply https://github.com/noidilin/dotfiles.git
```

Chezmoi will take care of every subsequent step (package installs, shell setup, runtime tools, etc.), so no additional manual prep is required.

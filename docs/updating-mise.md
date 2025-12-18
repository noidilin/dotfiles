# Updating mise

mise is managed differently per platform for optimal update frequency.

## Platform-Specific Management

### Linux (Arch)

**Installation Method**: Official installer to `~/.local/bin/mise`

mise on Arch Linux pacman lags weeks to months behind releases. To ensure access to the latest features and Node LTS upgrades, we use the official installer instead.

```bash
# Check version
mise --version

# Update to latest
mise self-update

# Update to specific version
mise self-update --version 2025.12.11

# Reinstall (if needed)
rm ~/.local/bin/mise && chezmoi apply
```

**Location**: `~/.local/bin/mise`  
**Update frequency**: Immediate (same day as release)

---

### Windows

**Installation Method**: Scoop package manager

Scoop's main bucket updates mise within 24-48 hours of new releases, which is acceptable for most use cases.

```powershell
# Check version
mise --version

# Update via Scoop (recommended)
scoop update mise

# Alternative: Self-update
mise self-update
```

**Location**: `%USERPROFILE%\scoop\apps\mise\current\mise.exe`  
**Update frequency**: 1-2 days after release

---

### macOS

**Installation Method**: Homebrew package manager

Homebrew formulae typically update within 24-48 hours of new releases.

```bash
# Check version
mise --version

# Update via Homebrew (recommended)
brew upgrade mise

# Alternative: Self-update
mise self-update
```

**Location**: `/opt/homebrew/bin/mise` (Apple Silicon) or `/usr/local/bin/mise` (Intel)  
**Update frequency**: 1-2 days after release

---

## Checking for Updates

### Current Version
```bash
mise --version
```

### Latest Release
- GitHub: https://github.com/jdx/mise/releases/latest
- Or use API:
```bash
curl -s https://api.github.com/repos/jdx/mise/releases/latest | jq -r .tag_name
```

---

## Troubleshooting

### mise command not found after update

**Linux**: Restart your shell to reload PATH
```bash
exec nu
```

**Windows**: Restart terminal or run
```powershell
refreshenv
```

**macOS**: Restart shell or source config
```bash
exec $SHELL
```

### Update fails with permission error

**Linux**: Ensure `~/.local/bin/mise` is owned by you
```bash
ls -la ~/.local/bin/mise
# Should show your username, not root
```

**Windows**: Run Scoop update without admin privileges (Scoop doesn't need admin)

**macOS**: Homebrew shouldn't require sudo for updates

---

## Version History

Mise releases can be found at:
- **Releases**: https://github.com/jdx/mise/releases
- **Changelog**: https://github.com/jdx/mise/blob/main/CHANGELOG.md

---

## Migration Notes

This dotfiles repo was migrated from package-manager-based mise to:
- **Linux**: Official installer (for latest versions)
- **Windows**: Scoop (fast enough, easier management)
- **macOS**: Homebrew (fast enough, standard for macOS)

See `home/.chezmoiscripts/arch/run_once_before_03-install-mise.sh.tmpl` for Linux installation details.

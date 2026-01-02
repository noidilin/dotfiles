# Updating mise

mise is managed differently per platform for optimal update frequency:

- **Linux**: Official installer (for latest versions)
- **Windows**: Scoop (fast enough, easier management)
- **macOS**: Homebrew (fast enough, standard for macOS)

See `home/.chezmoiscripts/arch/run_once_before_03-install-mise.sh.tmpl` for Linux installation details.

## Platform-Specific Management

### Arch Linux (Official installer)

**Update frequency**: Immediate (same day as release)

mise on Arch Linux pacman lags weeks to months behind releases.
To ensure access to the latest features and Node LTS upgrades, we use the official installer instead.

```bash
# Update to latest
mise self-update
```

---

### Windows (Scoop)

**Update frequency**: 1-2 days after release

```powershell
# Update via Scoop (recommended)
scoop update mise
```

---

### macOS (Homebrew)

**Update frequency**: 1-2 days after release

```bash
# Update via Homebrew (recommended)
brew upgrade mise
```

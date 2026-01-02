# Dev Setup

## Mise Installation

mise is managed differently per platform for optimal update frequency:

- **Linux**: Official installer (for latest versions)
- **Windows**: Scoop (fast enough, easier management)
- **macOS**: Homebrew (fast enough, standard for macOS)

See `home/.chezmoiscripts/arch/run_once_before_03-install-mise.sh.tmpl` for Linux installation details.

### Arch Linux (Official installer)

**Update frequency**: Immediate (same day as release)

mise on Arch Linux pacman lags weeks to months behind releases.
To ensure access to the latest features and Node LTS upgrades, we use the official installer instead.

```bash
# Update to latest
mise self-update
```

### Windows (Scoop)

**Update frequency**: 1-2 days after release

```powershell
# Update via Scoop (recommended)
scoop update mise
```

### macOS (Homebrew)

**Update frequency**: 1-2 days after release

```bash
# Update via Homebrew (recommended)
brew upgrade mise
```

---

## ~/.dev Directory

### Complete Directory Structure

```txt
~/.dev/
├── bun/           # Bun JavaScript runtime & package manager
├── cargo/         # Rust package manager & installed tools
├── pnpm/          # Fast, disk space efficient npm alternative
├── rustup/        # Rust toolchain installer & version manager
└── uv/            # Python package & tool manager (newly configured)
```

### Architecture Pattern Advantages

1. **Clean separation** from system packages
2. **Easy backup** - one directory contains all dev tools
3. **Easy cleanup** - can delete entire .dev for fresh start
4. **Consistent organization** across different languages
5. **No conflicts** with system packages or other users
6. **Version control friendly** - easy to exclude in backups

### Tool Relationships & Workflow

```txt
┌─────────────────────────────────────────────────┐
│           Version Managers (mise)               │
│  Manages: Python, Node, Rust, Bun versions      │
└─────────────────────────────────────────────────┘
                       │
        ┌──────────────┼──────────────┐
        │              │              │
   ┌────▼────┐    ┌────▼────┐   ┌─────▼───┐
   │ Python  │    │   Node  │   │  Rust   │
   └────┬────┘    └────┬────┘   └────┬────┘
        │              │             │ 
   ┌────▼────┐    ┌────▼────┐   ┌────▼────┐
   │   uv    │    │  pnpm   │   │  cargo  │
   │ (tools) │    │  bun    │   │ rustup  │
   └─────────┘    └─────────┘   └─────────┘
```

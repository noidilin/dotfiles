# Analysis: ~/.dev Directory Structure

Your ~/.dev directory is a **well-organized centralized location** for storing development tools and package managers, keeping them separate from system directories and XDG standard locations. This is an excellent practice for managing development environments!

## Complete Directory Structure

```
~/.dev/
├── bun/           # Bun JavaScript runtime & package manager
├── cargo/         # Rust package manager & installed tools
├── pnpm/          # Fast, disk space efficient npm alternative
├── rustup/        # Rust toolchain installer & version manager
└── uv/            # Python package & tool manager (newly configured)
```

---

## Detailed Analysis of Each Directory

### 1. **bun/** - Bun JavaScript Runtime & Package Manager

**Purpose:** Stores Bun's global package installations and cache.

**Structure:**

```
~/.dev/bun/
└── install/
    ├── cache/       # Downloaded package cache (655 KB)
    └── global/      # Globally installed packages
```

**Environment Variables:**

- BUN_INSTALL_GLOBAL_DIR → ~/.dev/bun/install/global
- BUN_INSTALL_BIN → ~/.dev/bun/bin (executables, in PATH)
- BUN_INSTALL_CACHE_DIR → ~/.dev/bun/install/cache

**What Bun Does:**

- Alternative JavaScript runtime (faster than Node.js)
- Built-in package manager (alternative to npm/yarn/pnpm)
- Bundler, transpiler, and test runner
- Compatible with Node.js and npm packages

**Example Usage:**

``` bash
bun add <package>          # Add dependency to project
bun install -g <package>   # Install globally → ~/.dev/bun/
bun run script.js          # Execute JavaScript
```

---

### 2. **cargo/** - Rust Package Manager & Tools

**Purpose:** Stores Rust packages installed via cargo install and package registry cache.

**Structure:**

```
~/.dev/cargo/
├── .crates.toml           # Installed crate metadata (TOML format)
├── .crates2.json          # Installed crate metadata (JSON format)
├── .global-cache          # Global cache metadata (65.5 KB)
├── .package-cache         # Package cache lock files
├── .package-cache-mutate  # Cache mutation lock
├── bin/                   # Installed binaries (15 executables)
│   ├── cargo.exe
│   ├── cargo-clippy.exe   # Linter
│   ├── cargo-fmt.exe      # Formatter
│   ├── rust-analyzer.exe  # LSP server
│   └── ... (11 more)
└── registry/              # Downloaded crate registry
```

**Environment Variables:**

- CARGO_HOME → ~/.dev/cargo

**What Cargo Does:**

- Rust's official package manager
- Build system for Rust projects
- Manages dependencies and crates (Rust packages)
- Installs command-line tools written in Rust

**Common Rust Tools Installed:**

- cargo - Package manager & build tool
- clippy - Linter for catching common mistakes
- rustfmt - Code formatter
- rust-analyzer - Language server for IDEs
- rls - Older Rust Language Server

**Example Usage:**

``` bash
cargo install ripgrep      # Install tool → ~/.dev/cargo/bin/
cargo build                # Build Rust project
cargo clippy               # Lint code
```

---

### 3. **pnpm/** - Fast, Disk-Efficient npm Alternative

**Purpose:** Stores globally installed npm packages using efficient hard-link-based storage.

**Structure:**

```
~/.dev/pnpm/
├── global/                         # Global node_modules
├── store/                          # Content-addressable package store
└── [executable wrappers]           # Cross-platform executable wrappers
    ├── chrome-devtools-mcp         # Unix wrapper
    ├── chrome-devtools-mcp.CMD     # Windows CMD wrapper
    ├── chrome-devtools-mcp.ps1     # PowerShell wrapper
    ├── next-devtools-mcp
    ├── rimraf                      # File deletion utility
    ├── tldr                        # Simplified man pages
    └── yamlresume                  # Resume generator
```

**Environment Variables:**

- PNPM_HOME → ~/.dev/pnpm (in PATH)

**What pnpm Does:**

- Fast, disk space efficient package manager for Node.js
- Uses hard links to share packages across projects
- **Saves disk space:** One copy of each package version shared globally
- Strict dependency resolution (prevents phantom dependencies)

**Installed Global Tools:**

- chrome-devtools-mcp - Chrome DevTools MCP server
- ext-devtools-mcp - Next.js DevTools MCP server
- rimraf - Cross-platform rm -rf utility
- yamlresume - Resume builder from YAML

**Why pnpm Over npm/yarn?**

- **3x faster** installations
- **~2/3 less disk space** used
- Monorepo-friendly
- Strict by default (better dependency management)

**Example Usage:**

``` bash
pnpm add <package>         # Add to project
pnpm add -g <tool>         # Install globally → ~/.dev/pnpm/
pnpm install               # Install dependencies
```

---

### 4. **rustup/** - Rust Toolchain Version Manager

**Purpose:** Manages multiple Rust compiler versions and cross-compilation targets.

**Structure:**

```
~/.dev/rustup/
├── downloads/             # Downloaded installer artifacts
├── settings.toml          # Rustup configuration
├── tmp/                   # Temporary files during installation
├── toolchains/            # Installed Rust toolchain versions
│   └── stable-x86_64-pc-windows-gnu/
└── update-hashes/         # Update verification hashes
```

**Configuration (settings.toml):**

``` toml
version = "12"
default_toolchain = "stable-x86_64-pc-windows-gnu"
profile = "default"
```

**Environment Variables:**

- RUSTUP_HOME → ~/.dev/rustup

**What Rustup Does:**

- Manages Rust toolchain versions (stable, beta, nightly)
- Handles cross-compilation targets
- Updates Rust compiler and tools
- Similar to vm (Node), pyenv (Python),

**Current Setup:**

- **Toolchain:** stable-x86_64-pc-windows-gnu
  - stable = Latest stable release
  - x86_64 = 64-bit architecture
  - pc-windows-gnu = Windows with GNU toolchain (MinGW)

**Why GNU vs MSVC?**

- **GNU (MinGW):** Better compatibility with Unix tools, easier cross-compilation
- **MSVC:** Better Windows integration, required for some Windows-specific features

**Example Usage:**

``` bash
rustup update              # Update Rust toolchain
rustup default stable      # Set default version
rustup target add <target> # Add cross-compilation target
rustup toolchain list      # List installed versions
```

---

### 5. **uv/** - Python Package & Tool Manager (Fully Configured!)

**Purpose:** Stores Python tools, cache, and managed Python installations using XDG-like structure on Windows.

**Structure:**

```
~/.dev/uv/
├── bin/                   # Tool executables (symlinks)
├── cache/                 # Package cache (wheels, builds, etc.)
│   ├── archive-v0/        # Downloaded source distributions
│   ├── built-wheels-v3/   # Wheels built from source
│   ├── wheels-v5/         # Downloaded pre-built wheels
│   ├── interpreter-v4/    # Python interpreter info cache
│   └── simple-v18/        # PyPI Simple API cache
├── python/                # Python installations (if used - currently using mise)
└── tools/                 # Tool virtual environments
    ├── .gitignore
    └── .lock
```

**Environment Variables (Complete XDG Setup):**

- `UV_CONFIG_FILE` → `~/.config/uv/uv.toml` (forces config location on Windows)
- `UV_CACHE_DIR` → `~/.dev/uv/cache` (package cache)
- `UV_PYTHON_INSTALL_DIR` → `~/.dev/uv/python` (Python installations)
- `UV_TOOL_DIR` → `~/.dev/uv/tools` (tool environments)
- `UV_TOOL_BIN_DIR` → `~/.dev/uv/bin` (tool executables, in PATH)

**Configuration File (`~/.config/uv/uv.toml`):**

```toml
# Global UV configuration
# Based on mise integration and .dev directory structure

# Use system Python (from mise) for global operations
python-preference = "system"

# Link mode for tool installations
# Options: "symlink" (default), "copy", "hardlink"
link-mode = "symlink"
```

**What uv Does:**

- **Blazingly fast** Python package installer (written in Rust)
- Replaces pip, pip-tools, pipx, poetry, pyenv (partially)
- Manages Python tools in isolated environments
- Creates and manages virtual environments
- 10-100x faster than traditional Python tools

**Comparison with mise:**

- **mise** manages Python **versions** (3.11, 3.12, 3.14, etc.)
- **uv** manages Python **packages and tools** (ruff, black, pytest, etc.)
- They work **together** perfectly!

**Why the Complete Environment Variable Setup?**

UV on Windows **does not** automatically respect XDG environment variables (`$XDG_CONFIG_HOME`, `$XDG_DATA_HOME`, `$XDG_CACHE_HOME`). It uses Windows Known Folders by default:

| Type | Windows Default | Our Override |
|------|----------------|--------------|
| Config | `%APPDATA%\uv\uv.toml` | `~/.config/uv/uv.toml` ✅ |
| Cache | `%LOCALAPPDATA%\uv\cache` | `~/.dev/uv/cache` ✅ |
| Data | `%APPDATA%\uv\data\` | `~/.dev/uv/` ✅ |

By explicitly setting `UV_*` environment variables, we force UV to follow our XDG-like structure on Windows, keeping configuration in `~/.config/` and runtime data in `~/.dev/`.

**Example Usage:**

```bash
uv tool install ruff       # Install Python tool → ~/.dev/uv/
uvx black --version        # Run tool without installing
uv venv                    # Create virtual environment
uv add requests            # Add dependency to project
uv cache dir               # Show cache location
uv python dir              # Show Python install location
```

---

## Architecture Pattern Analysis

### **Centralized Development Tools Strategy**

Your ~/.dev directory follows an excellent pattern:

**Advantages:**

1. **Clean separation** from system packages
2. **Easy backup** - one directory contains all dev tools
3. **Easy cleanup** - can delete entire .dev for fresh start
4. **Consistent organization** across different languages
5. **No conflicts** with system packages or other users
6. **Version control friendly** - easy to exclude in backups

**Comparison with Standard Locations:**

| Tool | Standard Location | Your Location | Benefit |
|------|------------------|---------------|---------|
| Cargo | ~/.cargo | ~/.dev/cargo | Centralized |
| Rustup | ~/.rustup | ~/.dev/rustup | Centralized |
| pnpm | ~/AppData/Local/pnpm | ~/.dev/pnpm | Centralized |
| Bun | ~/.bun | ~/.dev/bun | Centralized |
| UV | ~/.local/share/uv | ~/.dev/uv | Centralized |

---

## 📈 Storage Analysis

Let me estimate the typical sizes:

```
~/.dev/
├── bun/          ~1-10 MB    (cache: 655 KB, packages vary)
├── cargo/        ~100-500 MB (15 tools + registry cache)
├── pnpm/         ~50-200 MB  (5 tools + shared store)
├── rustup/       ~500 MB-1 GB (one complete toolchain)
└── uv/           ~10-100 MB  (varies by installed tools)

Total: ~700 MB - 2 GB (reasonable for development)
```

**Largest Components:**

1. **rustup** - Full Rust compiler toolchain (~500 MB+)
2. **cargo** - Rust tools and registry cache
3. **pnpm** - Node packages (but efficient storage)

---

## Tool Relationships & Workflow

### **Language Ecosystem Map:**

```
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

### **Package Manager Hierarchy:**

**Python:**

- mise → Installs Python 3.14.0
- uv → Manages packages & tools using mise's Python

**JavaScript:**

- mise → Installs Node.js 24 LTS
- pnpm → Manages npm packages efficiently
- bun → Alternative runtime + package manager

**Rust:**

- mise → Installs Rust stable-gnu
- rustup → Manages Rust toolchains (via mise)
- cargo → Installs Rust packages/tools

---

## Summary Visualization

```
~/.dev/ - Your Development Tools Hub
│
├── JavaScript Ecosystem
│   ├── pnpm/      Fast npm package manager (5 tools)
│   └── bun/       Modern JS runtime + bundler
│
├── Rust Ecosystem  
│   ├── cargo/     Package manager (15 tools)
│   └── rustup/    Toolchain manager (stable-gnu)
│
└── Python Ecosystem
    └── uv/        Fast package & tool manager (NEW!)

Pattern: All tools in one place, managed via mise
Size: ~700 MB - 2 GB total
Tools: 20+ globally installed CLI tools
```

---

## Key Insights

### **Your Development Stack:**

1. **Version Management:** mise (multi-language)
2. **Python Tools:** uv (fast, modern)
3. **Node Packages:** pnpm (efficient)
4. **Alternative JS Runtime:** bun (fast)
5. **Rust Tools:** cargo (standard)
6. **Rust Versions:** rustup (via mise)

### **Philosophy:**

- **Fast tools:** uv, pnpm, bun (all written in Rust/Zig for speed)
- **Efficiency:** pnpm saves disk space, uv is 10-100x faster
- **Clean:** Everything in ~/.dev/, not scattered
- **Modern:** Latest tooling (mise, uv, bun)

---

## Recommendations

Your setup is excellent! Here are optional enhancements:

1. **Consider adding to .dev/:**
   - go/ - If you use Go: GOPATH=~/.dev/go
   - gem/ - If you use Ruby: GEM_HOME=~/.dev/gem
   - composer/ - If you use PHP: COMPOSER_HOME=~/.dev/composer

2. **Backup strategy:**

   ``` bash

   # Backup only configuration, not binaries

   tar -czf dev-backup.tar.gz ~/.dev/*/settings.toml ~/.dev/*/.crates*.* ~/.dev/uv/tools/.lock
   ```

3. **Cleanup commands:**

   ```bash
   cargo cache --autoclean      # Clean cargo cache
   pnpm store prune             # Remove unused packages
   uv cache clean               # Clean uv cache
   ```

---

## 🔧 Windows-Specific Configuration: UV XDG Setup

### **The Challenge**

On Windows, UV does **not** automatically respect XDG environment variables like `$XDG_CONFIG_HOME`, `$XDG_DATA_HOME`, or `$XDG_CACHE_HOME`. Instead, it uses the Windows Known Folder API by default, storing data in:

- Config: `%APPDATA%\uv\` (`C:\Users\USERNAME\AppData\Roaming\uv\`)
- Cache: `%LOCALAPPDATA%\uv\cache\`
- Data: `%APPDATA%\uv\data\`

This breaks the XDG-like organization pattern used for other tools in the `~/.dev/` directory.

### **The Solution**

Force UV to use XDG-like paths by explicitly setting **UV-specific environment variables** in `~/.config/nushell/env/dev.nu`:

```nushell
# UV configuration - force all storage to follow XDG-like structure on Windows
$env.UV_CONFIG_FILE = ($env.XDG_CONFIG_HOME | path join 'uv' 'uv.toml')
$env.UV_CACHE_DIR = ($nu.home-path | path join '.dev' 'uv' 'cache')
$env.UV_PYTHON_INSTALL_DIR = ($nu.home-path | path join '.dev' 'uv' 'python')
$env.UV_TOOL_DIR = ($nu.home-path | path join '.dev' 'uv' 'tools')
$env.UV_TOOL_BIN_DIR = ($nu.home-path | path join '.dev' 'uv' 'bin')
```

### **Why Each Variable Matters**

| Variable | Purpose | Critical? |
|----------|---------|-----------|
| `UV_CONFIG_FILE` | Points to `~/.config/uv/uv.toml` | ⚠️ **YES** - Without this, UV won't read your config! |
| `UV_CACHE_DIR` | Package cache location | ✅ Keeps cache in `.dev/` |
| `UV_PYTHON_INSTALL_DIR` | Managed Python installations | ✅ Consistency (even if using mise) |
| `UV_TOOL_DIR` | Tool virtual environments | ✅ Centralized tools |
| `UV_TOOL_BIN_DIR` | Tool executables | ✅ Added to PATH |

### **Most Critical: `UV_CONFIG_FILE`**

The `UV_CONFIG_FILE` variable is **essential** because:

**Without it:**
```
UV looks in: %APPDATA%\uv\uv.toml
Your config is at: ~/.config/uv/uv.toml
Result: Config NOT FOUND → Settings IGNORED ❌
```

**With it:**
```
UV_CONFIG_FILE = ~/.config/uv/uv.toml
UV reads from: ~/.config/uv/uv.toml
Result: Config FOUND → Settings APPLIED ✅
```

### **Directory Structure Achieved**

```
~/
├── .config/
│   └── uv/
│       └── uv.toml                   # Configuration (XDG convention)
│           python-preference = "system"
│           link-mode = "symlink"
│
└── .dev/
    └── uv/
        ├── bin/                      # Tool executables
        ├── cache/                    # Package cache
        │   ├── archive-v0/
        │   ├── interpreter-v4/
        │   ├── sdists-v9/
        │   ├── simple-v18/
        │   └── wheels-v5/
        ├── python/                   # Python installations (empty - using mise)
        └── tools/                    # Tool environments
```

### **Benefits**

1. ✅ **XDG Compliant:** Config in `~/.config/` (industry standard)
2. ✅ **Centralized Runtime Data:** All data in `~/.dev/` (easy management)
3. ✅ **Consistent Pattern:** Matches cargo, pnpm, bun, rustup
4. ✅ **No Windows AppData Clutter:** Clean organization
5. ✅ **Portable:** Easy to backup/restore entire `.dev/` directory
6. ✅ **Discoverable:** All UV data in predictable locations

### **Verification Commands**

After configuration, verify everything is set up correctly:

```bash
# Check UV recognizes the directories
uv cache dir                          # Should show: ~/.dev/uv/cache
uv python dir                         # Should show: ~/.dev/uv/python
uv tool dir                           # Should show: ~/.dev/uv/tools
uv tool dir --bin                     # Should show: ~/.dev/uv/bin

# Check environment variables
echo $env.UV_CONFIG_FILE              # Should show: ~/.config/uv/uv.toml
echo $env.UV_CACHE_DIR                # Should show: ~/.dev/uv/cache
echo $env.UV_PYTHON_INSTALL_DIR       # Should show: ~/.dev/uv/python
echo $env.UV_TOOL_DIR                 # Should show: ~/.dev/uv/tools
echo $env.UV_TOOL_BIN_DIR             # Should show: ~/.dev/uv/bin

# Test tool installation
uv tool install ruff                  # Install test tool
ruff --version                        # Verify execution
uv tool uninstall ruff                # Cleanup
```

### **Platform Differences**

| Platform | XDG Support | Configuration Needed |
|----------|-------------|---------------------|
| **Unix/macOS** | ✅ Native | UV respects `$XDG_*` automatically |
| **Windows** | ❌ None | Must set `UV_*` variables explicitly |

This is why Windows users must explicitly configure all UV storage locations via environment variables, while Unix/macOS users can rely on XDG variables being respected automatically.

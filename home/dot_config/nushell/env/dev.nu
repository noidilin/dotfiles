# dev path
$env.PNPM_HOME = ($nu.home-path | path join '.dev' 'pnpm')
$env.BUN_INSTALL_GLOBAL_DIR = ($nu.home-path | path join '.dev' 'bun' 'install' 'global')
$env.BUN_INSTALL_BIN = ($nu.home-path | path join '.dev' 'bun' 'bin')
$env.BUN_INSTALL_CACHE_DIR = ($nu.home-path | path join '.dev' 'bun' 'install' 'cache')
$env.CARGO_HOME = ($nu.home-path | path join '.dev' 'cargo')
$env.RUSTUP_HOME = ($nu.home-path | path join '.dev' 'rustup')
$env.GOPATH = ($nu.home-path | path join '.dev' 'go')
$env.GOBIN = ($nu.home-path | path join '.dev' 'go' 'bin')

# UV configuration - force all storage to follow XDG-like structure on Windows
$env.UV_CONFIG_FILE = ($env.XDG_CONFIG_HOME | path join 'uv' 'uv.toml')
$env.UV_CACHE_DIR = ($nu.home-path | path join '.dev' 'uv' 'cache')
$env.UV_PYTHON_INSTALL_DIR = ($nu.home-path | path join '.dev' 'uv' 'python')
$env.UV_TOOL_DIR = ($nu.home-path | path join '.dev' 'uv' 'tools')
$env.UV_TOOL_BIN_DIR = ($nu.home-path | path join '.dev' 'uv' 'bin')

$env.PATH = ($env.PATH
  | prepend $env.GOBIN
  | prepend $env.UV_TOOL_BIN_DIR
  | prepend $env.BUN_INSTALL_BIN
  | prepend $env.PNPM_HOME
  | prepend ($nu.home-path | path join '.local' 'bin')
  | uniq
)

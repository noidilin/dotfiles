# dev path - set up provider cache dir in terraform config
$env.TF_CLI_CONFIG_FILE = ($nu.home-dir | path join ".config" "terraform" "config.tfrc")

# dev path - npm, pnpm, yarn, bun
$env.NPM_CONFIG_CACHE = ($nu.home-dir | path join ".dev" "npm" "cache")
$env.NPM_CONFIG_USERCONFIG = ($nu.home-dir | path join ".dev" "npm" "npmrc")
$env.NPM_CONFIG_PREFIX = ($nu.home-dir | path join ".dev" "npm" "prefix")
$env.NPM_BIN_HOME = ($nu.home-dir | path join ".dev" "npm" "prefix" "bin")
$env.PNPM_HOME = ($nu.home-dir | path join ".dev" "pnpm")
$env.PNPM_BIN = ($nu.home-dir | path join ".dev" "pnpm" "bin")
$env.YARN_CACHE_FOLDER = ($nu.home-dir | path join ".dev" "yarn" "cache")
$env.YARN_GLOBAL_FOLDER = ($nu.home-dir | path join ".dev" "yarn" "global")
$env.YARN_BIN_HOME = ($nu.home-dir | path join ".dev" "yarn" "bin")
$env.BUN_INSTALL_GLOBAL_DIR = ($nu.home-dir | path join ".dev" "bun" "install" "global")
$env.BUN_INSTALL_BIN = ($nu.home-dir | path join ".dev" "bun" "bin")
$env.BUN_INSTALL_CACHE_DIR = ($nu.home-dir | path join ".dev" "bun" "install" "cache")

# dev path - rust, go
$env.CARGO_HOME = ($nu.home-dir | path join ".dev" "cargo")
$env.RUSTUP_HOME = ($nu.home-dir | path join ".dev" "rustup")
$env.GOPATH = ($nu.home-dir | path join ".dev" "go")
$env.GOBIN = ($nu.home-dir | path join ".dev" "go" "bin")

# dev path - UV (force all storage to follow XDG-like structure on Windows)
$env.UV_CONFIG_FILE = ($nu.home-dir | path join ".config" "uv" "uv.toml")
$env.UV_CACHE_DIR = ($nu.home-dir | path join ".dev" "uv" "cache")
$env.UV_PYTHON_INSTALL_DIR = ($nu.home-dir | path join ".dev" "uv" "python")
$env.UV_TOOL_DIR = ($nu.home-dir | path join ".dev" "uv" "tools")
$env.UV_TOOL_BIN_DIR = ($nu.home-dir | path join ".dev" "uv" "bin")

# other tools
$env.WAKATIME_HOME = ($nu.home-dir | path join ".config" "wakatime")
$env.BLENDER_USER_RESOURCES = ($nu.home-dir | path join ".local" "etc" "blender")
$env.MASON_BIN_HOME = ($nu.home-dir | path join ".local" "share" "nvim" "mason" "bin")

$env.PATH = ($env.PATH
  | prepend $env.GOBIN
  | prepend $env.UV_TOOL_BIN_DIR
  | prepend $env.BUN_INSTALL_BIN
  | prepend $env.YARN_BIN_HOME
  | prepend $env.NPM_BIN_HOME
  | prepend $env.PNPM_HOME
  | prepend $env.PNPM_BIN
  | prepend $env.MASON_BIN_HOME
  | prepend $env.XDG_BIN_HOME
)

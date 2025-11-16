# dev path
$env.PNPM_HOME = ($nu.home-path | path join '.dev' 'pnpm')
$env.BUN_INSTALL_GLOBAL_DIR = ($nu.home-path | path join '.dev' 'bun' 'install' 'global')
$env.BUN_INSTALL_BIN = ($nu.home-path | path join '.dev' 'bun' 'bin')
$env.BUN_INSTALL_CACHE_DIR = ($nu.home-path | path join '.dev' 'bun' 'install' 'cache')
$env.CARGO_HOME = ($nu.home-path | path join '.dev' 'cargo')
$env.RUSTUP_HOME = ($nu.home-path | path join '.dev' 'rustup')

$env.PATH = ($env.PATH | prepend $env.PNPM_HOME | prepend $env.BUN_INSTALL_BIN)

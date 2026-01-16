const CONFIG_DIR = ($nu.default-config-dir | path join 'config')
use $CONFIG_DIR [ 'completions' 'theme' 'menus' 'keybindings' 'os' ]

$env.config = {
  buffer_editor: nvim
  show_banner: false
  edit_mode: vi
  cursor_shape: { vi_normal: block vi_insert: line }
  highlight_resolved_externals: true # highlighting of external commands in the repl resolved by which
  completions: (completions)
  color_config: (theme)
  menus: (menus)
  keybindings: (keybindings)
  shell_integration: { osc133: false }
}

# ------------------
# BUG: Cursor flashing / teleporting on typing in a nushell prompt on windows
# Issue #2779 · wez/wezterm (https://github.com/wez/wezterm/issues/2779)
# HACK: nushell replicates prompt line with every keystroke on wezterm
# Issue #5585 · nushell/nushell (https://github.com/nushell/nushell/issues/5585#issuecomment-2138885215)

# env
const ENV_DIR = ($nu.default-config-dir | path join 'env')

load-env (os init-os-env)
source ($ENV_DIR | path join 'xdg.nu')
source ($ENV_DIR | path join 'dev.nu')
source ($ENV_DIR | path join 'shell.nu')
source ($ENV_DIR | path join 'fzf.nu')
source ($ENV_DIR | path join 'key.nu')

# lib loads before vender autoload
const NU_LIB_DIRS = [
  ($nu.default-config-dir | path join 'lib' 'tools')
  ($nu.default-config-dir | path join 'lib' 'modules')
  ($nu.default-config-dir | path join 'lib' 'scripts')
]

source zoxide.nu
source mise.nu
source carapace.nu
source starship.nu

const CONFIG_DIR = ($nu.default-config-dir | path join 'config')
const ENV_DIR = ($nu.default-config-dir | path join 'env')

source ($ENV_DIR | path join 'shell.nu')
source ($ENV_DIR | path join 'fzf.nu')
source ($ENV_DIR | path join 'key.nu')

use $CONFIG_DIR [ 'completions' 'theme' 'menus' 'keybindings' ]
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

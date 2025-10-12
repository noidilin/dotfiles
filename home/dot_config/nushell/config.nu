const CONFIG_DIR = ($nu.default-config-dir | path join 'config')

# list import modules based on mod.nu file
use $CONFIG_DIR [ 'completions' 'theme' 'menus' 'keybindings' ]

$env.config = {
  show_banner: false
  edit_mode: vi
  cursor_shape: { vi_normal: block vi_insert: line }
  # highlighting of external commands in the repl resolved by which.
  highlight_resolved_externals: true

  completions: (completions)
  color_config: (theme)
  menus: (menus)
  keybindings: (keybindings)
}

# BUG: Cursor flashing / teleporting on typing in a nushell prompt on windows
# Issue #2779 · wez/wezterm (https://github.com/wez/wezterm/issues/2779)
# HACK: nushell replicates prompt line with every keystroke on wezterm
# Issue #5585 · nushell/nushell (https://github.com/nushell/nushell/issues/5585#issuecomment-2138885215)
$env.config.shell_integration.osc133 = false

# conflict with starship
# $env.PROMPT_INDICATOR = $"(ansi purple_bold)> (ansi reset)"
$env.PROMPT_INDICATOR_VI_NORMAL = ''
$env.PROMPT_INDICATOR_VI_INSERT = ''
# $env.PROMPT_MULTILINE_INDICATOR = {|| "::: " }

const NU_LIB_DIRS = [
  ($nu.default-config-dir | path join 'scripts')
]

# scripts in $NU_LIB_DIRS
source alias.nu
source commands.nu
source mocha-update.nu
source pbr-move-preview.nu

# use $ENV_DIR atuin ATUIN_INIT_PATH
# source $ATUIN_INIT_PATH
# hide ATUIN_INIT_PATH

use $ENV_DIR mise MISE_INIT_PATH
source $MISE_INIT_PATH
hide MISE_INIT_PATH

use $ENV_DIR zoxide ZOXIDE_INIT_PATH
source $ZOXIDE_INIT_PATH
hide ZOXIDE_INIT_PATH

use $ENV_DIR carapace CARAPACE_INIT_PATH
source $CARAPACE_INIT_PATH
hide CARAPACE_INIT_PATH

use $ENV_DIR starship STARSHIP_INIT_PATH
use $STARSHIP_INIT_PATH
hide STARSHIP_INIT_PATH

const CONFIG_DIR = ($nu.default-config-dir | path join 'config')
const ENV_DIR = ($nu.default-config-dir | path join 'env')

# Environment Variables
$env.EDITOR = 'nvim'
$env.PAGER = 'delta'
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
$env.LS_COLORS = (vivid generate ($env.XDG_CONFIG_HOME | path join 'vivid' 'themes' 'color-fatigue.yml') | str trim)
$env.CC = 'gcc'

source ($ENV_DIR | path join 'fzf.nu')
source ($ENV_DIR | path join 'key.nu')

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
$env.PROMPT_INDICATOR_VI_NORMAL = ''
$env.PROMPT_INDICATOR_VI_INSERT = ''

# Initialize external tools (first-time setup)
# These functions generate cached init files in $nu.cache-dir
# use $ENV_DIR os init-os-env
# use $ENV_DIR atuin init-atuin
use $ENV_DIR mise init-mise
use $ENV_DIR zoxide init-zoxide
use $ENV_DIR carapace init-carapace
use $ENV_DIR starship init-starship

# Run init functions to ensure cache files exist
# init-os-env | load-env
# init-atuin 
init-mise
init-zoxide
init-carapace
init-starship

# Hide the init functions as they're only needed once
# hide init-os-env
# hide init-atuin
hide init-mise
hide init-zoxide
hide init-carapace
hide init-starship

# Load external tool integrations (from cached init files)
# Using 'source' for compatibility with generated init files
# (These files define commands/aliases directly without proper module exports)
source ($nu.cache-dir | path join 'mise' 'init.nu')
source ($nu.cache-dir | path join 'zoxide' 'init.nu')
source ($nu.cache-dir | path join 'carapace' 'init.nu')
source ($nu.cache-dir | path join 'starship' 'init.nu')

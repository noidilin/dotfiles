const CONFIG_DIR = ($nu.default-config-dir | path join 'config')

# Environment Variables
$env.EDITOR = 'nvim'
$env.PAGER = 'delta'
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
$env.LS_COLORS = (vivid generate ($env.XDG_CONFIG_HOME | path join 'vivid' 'themes' 'color-fatigue.yml') | str trim)
$env.CC = 'gcc'

# FZF Configuration
$env.FZF_DEFAULT_COMMAND = "fd --hidden --strip-cwd-prefix --exclude .git"
$env.FZF_CTRL_T_COMMAND = "fd --type file --hidden --strip-cwd-prefix --exclude .git"
$env.FZF_ALT_C_COMMAND = "fd --type directory --hidden --strip-cwd-prefix --exclude .git"
$env.FZF_DEFAULT_OPTS = "
--color=fg:#878787,fg+:#b3b3b3,bg:-1,bg+:-1 \n
--color=hl:#a69f91,hl+:#dad5c8,info:#414141,marker:#8e8b85 \n
--color=prompt:#eaeaea,spinner:#6c6a65,pointer:#8e8b85,header:#b3b3b3 \n
--color=border:#2a2a2a,label:#b3b3b3,query:#cccccc \n
--padding='2' --margin='2' --layout=reverse --info='right' \n
--prompt='> ' --marker='>' --pointer='◆' --separator='─' --scrollbar='│'  \n
--border='rounded' --border-label='fzf' --border-label-pos='0'  \n
--cycle --scroll-off=5 \n
--preview-window=right,60%,border-left \n
--bind ctrl-u:preview-half-page-up \n
--bind ctrl-d:preview-half-page-down \n
--bind ctrl-f:preview-page-down \n
--bind ctrl-b:preview-page-up \n
--bind ctrl-g:preview-top \n
--bind ctrl-h:preview-bottom \n
--bind alt-w:toggle-preview-wrap \n
--bind ctrl-e:toggle-preview \n
"
$env.FZF_CTRL_T_OPTS = "--height 80% --preview 'bat -n --color=always --line-range=:500 {}'"
$env.FZF_ALT_C_OPTS = "--height 80% --preview 'eza --tree --level=2 --color=always {} '"

# API Keys
$env.ANTHROPIC_API_KEY = (open ($env.USERPROFILE | path join '.config' 'api' 'ANTHROPIC_API_KEY') | str trim)
$env.TAVILY_API_KEY = (open ($env.USERPROFILE | path join '.config' 'api' 'TAVILY_API_KEY') | str trim)

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

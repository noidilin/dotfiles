$env.EDITOR = 'nvim'
$env.PAGER = 'delta'

$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
$env.LS_COLORS = (vivid generate ($env.XDG_CONFIG_HOME | path join 'vivid' 'themes' 'color-fatigue.yml') | str trim)
$env.CC = 'gcc'

# conflict with starship
$env.PROMPT_INDICATOR_VI_NORMAL = ''
$env.PROMPT_INDICATOR_VI_INSERT = ''


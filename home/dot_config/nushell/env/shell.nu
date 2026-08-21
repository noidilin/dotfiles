# eza reads exactly one $EZA_CONFIG_DIR/theme.yml, so the variant picks the dir
$env.EZA_CONFIG_DIR = ($nu.home-dir | path join '.config' 'eza' (if ($env.ACHROMA_VARIANT? | default 'dark') == 'light' { 'achroma-light' } else { 'achroma' }))
# lazygit layers the variant theme fragment over the shared config
$env.LG_CONFIG_FILE = ([
  ($env.XDG_CONFIG_HOME | path join 'lazygit' 'config.yml')
  ($env.XDG_CONFIG_HOME | path join 'lazygit' (if ($env.ACHROMA_VARIANT? | default 'dark') == 'light' { 'theme-achroma-light.yml' } else { 'theme-achroma.yml' }))
] | str join ',')
# gh-dash reads the variant render directly
$env.GH_DASH_CONFIG = ($env.XDG_CONFIG_HOME | path join 'gh-dash' (if ($env.ACHROMA_VARIANT? | default 'dark') == 'light' { 'config-achroma-light.yml' } else { 'config-achroma.yml' }))
$env.BAT_CONFIG_DIR = ($nu.home-dir | path join '.config' 'bat')
$env.YAZI_CONFIG_HOME = ($nu.home-dir | path join '.config' 'yazi')

$env.EDITOR = 'nvim'
$env.PAGER = 'delta'

$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
# achroma variant resolved in env/variant.nu (sourced earlier in config.nu)
let vivid_theme = (if ($env.ACHROMA_VARIANT? | default 'dark') == 'light' { 'achroma-light.yml' } else { 'achroma.yml' })
$env.LS_COLORS = (vivid generate ($env.XDG_CONFIG_HOME | path join 'vivid' 'themes' $vivid_theme) | str trim)
$env.CC = 'gcc'

# conflict with starship
$env.PROMPT_INDICATOR_VI_NORMAL = ''
$env.PROMPT_INDICATOR_VI_INSERT = ''


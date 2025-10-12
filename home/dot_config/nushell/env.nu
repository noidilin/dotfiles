$env.EDITOR = 'nvim'
# $env.VISUAL = 'code'
$env.PAGER = 'delta'
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' # optional
$env.LS_COLORS = (vivid generate ($env.XDG_CONFIG_HOME | path join 'vivid' 'themes' 'color-fatigue.yml') | str trim)
$env.CC = 'gcc' # for tree-sitter

export const ENV_DIR = ($nu.default-config-dir | path join 'env')

# To load from a custom file you can use:
source ($ENV_DIR | path join 'fzf.nu')
source ($ENV_DIR | path join 'key.nu')

# use $ENV_DIR os init-os-env
# init-os-env | load-env
# hide init-os-env

# use $ENV_DIR atuin init-atuin
# init-atuin
# hide init-atuin

use $ENV_DIR mise init-mise
init-mise
hide init-mise

use $ENV_DIR zoxide init-zoxide
init-zoxide
hide init-zoxide

use $ENV_DIR carapace init-carapace
init-carapace
hide init-carapace

use $ENV_DIR starship init-starship
init-starship
hide init-starship

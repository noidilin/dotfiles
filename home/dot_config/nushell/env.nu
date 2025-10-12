export const ENV_DIR = ($nu.default-config-dir | path join 'env')

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

const cache_file = ($nu.cache-dir | path join 'carapace' 'init.nu')

mkdir ($cache_file | path dirname)
carapace _carapace nushell | save -f $cache_file

source $cache_file

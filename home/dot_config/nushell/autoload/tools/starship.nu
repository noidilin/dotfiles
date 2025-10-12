const cache_file = ($nu.cache-dir | path join 'starship' 'init.nu')

mkdir ($cache_file | path dirname)
starship init nu | save -f $cache_file

source $cache_file

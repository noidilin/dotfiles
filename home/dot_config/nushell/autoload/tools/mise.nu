const cache_file = ($nu.cache-dir | path join 'mise' 'init.nu')

mkdir ($cache_file | path dirname)
mise activate nu | save -f $cache_file

source $cache_file

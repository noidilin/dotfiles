const cache_file = ($nu.cache-dir | path join 'zoxide' 'init.nu')

mkdir ($cache_file | path dirname)
zoxide init nushell --hook prompt | save -f $cache_file

source $cache_file

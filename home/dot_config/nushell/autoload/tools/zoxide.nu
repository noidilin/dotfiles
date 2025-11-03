const init_file = ($nu.data-dir | path join 'vendor' 'autoload' 'zoxide.nu')
mkdir ($init_file | path dirname)

zoxide init nushell --hook prompt | save -f $init_file

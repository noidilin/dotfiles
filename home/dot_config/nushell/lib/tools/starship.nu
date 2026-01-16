const init_file = ($nu.data-dir | path join 'vendor' 'autoload' 'starship.nu')
mkdir ($init_file | path dirname)

starship init nu | save -f $init_file

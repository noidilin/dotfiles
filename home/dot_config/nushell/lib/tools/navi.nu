const init_file = ($nu.data-dir | path join 'vendor' 'autoload' 'navi.nu')
mkdir ($init_file | path dirname)

navi widget nushell | save -f $init_file

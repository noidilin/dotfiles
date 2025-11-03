const init_file = ($nu.data-dir | path join 'vendor' 'autoload' 'mise.nu')
mkdir ($init_file | path dirname)

mise activate nu | save -f $init_file

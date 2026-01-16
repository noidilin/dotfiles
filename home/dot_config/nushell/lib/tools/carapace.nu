const init_file = ($nu.data-dir | path join 'vendor' 'autoload' 'carapace.nu')
mkdir ($init_file | path dirname)

carapace _carapace nushell | save -f $init_file

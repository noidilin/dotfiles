def --env yz [...args] {
	let tmp = (mktemp -t "yazi-cwd.XXXXXX")
	yazi ...$args --cwd-file $tmp
	let cwd = (open $tmp)
	if $cwd != "" and $cwd != $env.PWD {
		cd $cwd
	}
	rm -fp $tmp
}

def clean-shada [] {
  ls ($env.XDG_STATE_HOME | path join 'nvim-data' 'shada' ) | get name | each {|file| rm -fv $file}
}

export def init-os-env [] {
	use std

  match $nu.os-info.name {
    "macos" => {
      with-env { PATH: $env.PATH } {
        std path add '/opt/homebrew/bin'
        std path add '/usr/local/bin'
        std path add '/usr/bin'
        std path add '/bin'
        { PATH: $env.PATH }
      }
    }
    "windows" => {
      with-env { PATH: $env.PATH } {
        std path add '~/.local/bin'
        {
          PATH: $env.PATH
          YAZI_FILE_ONE: ($nu.home-path | path join 'scoop' 'apps' 'git' 'current' 'usr' 'bin' 'file.exe')
        }
      }
    }
    "linux" => {
      { PATH: $env.PATH }
    }
    "android" => {
      { PATH: $env.PATH }
    }
    _ => {
        { PATH: $env.PATH }
		}
	}
}

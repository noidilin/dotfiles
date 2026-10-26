def wezterm-bin [] {
  let in_wsl = (($env.WSL_DISTRO_NAME? != null) or ($env.WSL_INTEROP? != null))

  if $in_wsl and ((which wezterm.exe | length) > 0) {
    return "wezterm.exe"
  }

  for c in ["wezterm", "wezterm.exe"] {
    if ((which $c | length) > 0) { return $c }
  }

  error make { msg: "WezTerm not found in PATH (tried wezterm and wezterm.exe)" }
}

def nvim-outside-project [file: path] {
  cd $nu.temp-dir
  ^nvim $file
}

# Dump current pane scrollback into a temp file, open in nvim
def wlog [
  --lines: int = 0
] {
  let wez = (wezterm-bin)
  let ts  = (date now | format date "%Y%m%d-%H%M%S")
  let tmp = ($nu.temp-dir | path join $"wezterm-scrollback-($ts).txt")

  if $lines > 0 {
    ^($wez) cli get-text --start-line (0 - $lines) | save --raw --force $tmp
  } else {
    ^($wez) cli get-text --start-line 5000 | save --raw --force $tmp
  }

  nvim-outside-project $tmp
  rm -f $tmp
}

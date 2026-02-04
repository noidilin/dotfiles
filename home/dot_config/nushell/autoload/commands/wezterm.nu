# Returns the best wezterm executable name for this environment
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

# `^` char means run this as an external command, not as nushell data (tables, records, lists)
# Dump current pane scrollback into a temp file, open in nvim
def wlog [
  --lines: int = 0
] {
  let wez = (wezterm-bin)

  do {
    # Run everything in a neutral folder so your project sessions don't get touched
    cd $nu.temp-dir

    let ts  = (date now | format date "%Y%m%d-%H%M%S")
    let tmp = $"wezterm-scrollback-($ts).txt"

    if $lines > 0 {
      ^($wez) cli get-text --start-line (-$lines) | save --raw --force $tmp
    } else {
      ^($wez) cli get-text --start-line 5000 | save --raw --force $tmp
    }

    # Open *from the temp directory* so any “last session” is associated with temp, not your repo
    ^nvim $tmp
    rm -f $tmp
  }
}

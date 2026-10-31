def "herdr-shell is-standalone-ghostty" [] {
    ($env.TERM? | default "") == "xterm-ghostty"
}

def --env "herdr-shell autostart" [] {
    if not $nu.is-interactive { return }
    if (($env.HERDR_ENV? | default "") | is-not-empty) { return }
    if (($env.ZELLIJ? | default "") | is-not-empty) { return }
    if not (herdr-shell is-standalone-ghostty) { return }
    if (which herdr | is-empty) { return }

    ^herdr
    exit
}

def --env "herdr-shell init" [] {
    herdr-shell autostart
}

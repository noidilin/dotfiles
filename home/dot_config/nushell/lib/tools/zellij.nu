def "zellij-shell is-standalone-ghostty" [] {
    ($env.TERM? | default "") == "xterm-ghostty"
}

const ZELLIJ_AUTO_SESSION = "main"

def --env "zellij-shell autostart" [] {
    if not $nu.is-interactive { return }
    if (($env.ZELLIJ? | default "") | is-not-empty) { return }
    if not (zellij-shell is-standalone-ghostty) { return }
    if (which zellij | is-empty) { return }

    $env.ZELLIJ_AUTO_ATTACH = ($env.ZELLIJ_AUTO_ATTACH? | default "true")
    $env.ZELLIJ_AUTO_EXIT = ($env.ZELLIJ_AUTO_EXIT? | default "true")

    if $env.ZELLIJ_AUTO_ATTACH == "true" {
        ^zellij attach -c $ZELLIJ_AUTO_SESSION
    } else {
        ^zellij --session $ZELLIJ_AUTO_SESSION
    }

    if $env.ZELLIJ_AUTO_EXIT == "true" {
        exit
    }
}

def --env "zellij-shell init" [] {
    zellij-shell autostart
}

# OmniWM's quake terminal embeds libghostty, so GHOSTTY_BIN_DIR points into
# OmniWM.app instead of Ghostty.app. Panes inside herdr inherit it too, hence
# the HERDR_ENV check in autostart.
def "zellij-shell is-quake-terminal" [] {
    ($env.GHOSTTY_BIN_DIR? | default "") | str contains "OmniWM.app"
}

const ZELLIJ_AUTO_SESSION = "main"

def --env "zellij-shell autostart" [] {
    if not $nu.is-interactive { return }
    if (($env.ZELLIJ? | default "") | is-not-empty) { return }
    if (($env.HERDR_ENV? | default "") | is-not-empty) { return }
    if not (zellij-shell is-quake-terminal) { return }
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

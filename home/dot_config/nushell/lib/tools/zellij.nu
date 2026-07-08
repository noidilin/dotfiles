# Zellij integration for Nushell.
#
# Scope:
# - shell-side auto-start when launched from Ghostty
# - no custom project/session switching; rely on official Zellij attach/session-manager

# True for shells launched by Ghostty. TERM is the most reliable signal; keep
# env fallbacks for config experiments and older/current custom setups.
def "zellij-shell is-ghostty" [] {
    let term = ($env.TERM? | default "")
    let term_program = ($env.TERM_PROGRAM? | default "" | str lowercase)
    let terminal = ($env.TERMINAL? | default "" | str lowercase)

    ($term == "xterm-ghostty") or ($term_program == "ghostty") or ($terminal == "ghostty")
}

const ZELLIJ_AUTO_SESSION = "main"

# Official/community-style autostart flow for shells launched by Ghostty:
# if not already inside Zellij, attach to the main session or create it.
# This intentionally does not use the local bin/zj-* project/session scripts.
def --env "zellij-shell autostart" [] {
    if not $nu.is-interactive { return }
    if (($env.ZELLIJ? | default "") | is-not-empty) { return }
    if not (zellij-shell is-ghostty) { return }
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

# Main entrypoint called from config.nu.
def --env "zellij-shell init" [] {
    zellij-shell autostart
}

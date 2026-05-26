# Zellij session detection and tab rename side effects.

use cache.nu

# True when this shell is running inside a Zellij pane and the CLI is available.
# Do not cache this in exported env vars: child shells inherit them and can skip
# activation after the surrounding Zellij/session state changes.
export def is-active [] {
    (($env.ZELLIJ? | default "") | is-not-empty) and ((which zellij | is-not-empty))
}

# Rename the focused Zellij tab, with a tiny process-local env cache to avoid
# repeating the same action every prompt.
export def --env set-name [name: string] {
    if not (is-active) { return }
    if ($name | is-empty) { return }

    if (cache tab-name-is-current $name) { return }

    let result = (^zellij action rename-tab $name | complete)
    if $result.exit_code == 0 {
        cache remember-tab-name $name
    }
}

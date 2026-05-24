# Automatic tab naming from the working directory / git repository.

use format.nu shorten

# Compute the automatic tab name. Prefer the git repository root basename, then
# the cwd leaf, then a stable fallback.
export def --env auto-name [] {
    let cwd = ($env.PWD? | default (pwd))

    # Cache per directory. `git rev-parse` is the hot path when this runs from
    # prompt hooks; cwd changes are the only normal reason the automatic name
    # needs recomputing.
    if (($env.ZELLIJ_TAB_AUTO_PWD? | default "") == $cwd) {
        let cached = ($env.ZELLIJ_TAB_AUTO_NAME? | default "")
        if ($cached | is-not-empty) { return $cached }
    }

    let git_root = (^git -C $cwd rev-parse --show-toplevel | complete)

    let raw_name = if $git_root.exit_code == 0 and (($git_root.stdout | str trim) | is-not-empty) {
        $git_root.stdout | str trim | path basename
    } else {
        $cwd | path basename
    }

    let name = shorten (if ($raw_name | is-empty) { "main" } else { $raw_name })
    $env.ZELLIJ_TAB_AUTO_PWD = $cwd
    $env.ZELLIJ_TAB_AUTO_NAME = $name
    $name
}

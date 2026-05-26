# Automatic tab naming from the working directory / git repository.

use format.nu shorten
use cache.nu

# Compute the automatic tab name. Prefer the git repository root basename, then
# the cwd leaf, then a stable fallback.
export def --env auto-name [cwd?: string] {
    let cwd = ($cwd | default ($env.PWD? | default (pwd)))

    let cached = (cache auto-name $cwd)
    if $cached != null { return $cached }

    let git_root = if (which git | is-empty) {
        { exit_code: 1, stdout: "" }
    } else {
        ^git -C $cwd rev-parse --show-toplevel | complete
    }

    let raw_name = if $git_root.exit_code == 0 and (($git_root.stdout | str trim) | is-not-empty) {
        $git_root.stdout | str trim | path basename
    } else {
        $cwd | path basename
    }

    let name = shorten (if ($raw_name | is-empty) { "main" } else { $raw_name })
    cache remember-auto-name $cwd $name
    $name
}

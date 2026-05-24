# Zellij tab auto-renaming for Nushell.
#
# Public facade for:
# - automatic names from cwd/git state
# - transient foreground-process labels
# - Zellij rename side effects
# - hook installation

use session.nu
use naming.nu
use process.nu

# Refresh automatic naming unless the user locked a manual name.
export def --env "ztab refresh" [] {
    hide-env ZELLIJ_TAB_PROCESS --ignore-errors
    if (($env.ZELLIJ_TAB_NAME_MANUAL? | default "") | is-not-empty) { return }
    if not (session is-active) { return }
    session set-name (naming auto-name)
}

# Mark the tab with the foreground process name until the prompt returns.
export def --env "ztab mark-processing" [] {
    if (($env.ZELLIJ_TAB_NAME_MANUAL? | default "") | is-not-empty) { return }
    if not (session is-active) { return }

    let name = (process process-name (commandline))
    if ($name | is-empty) { return }

    $env.ZELLIJ_TAB_PROCESS = $name
    session set-name $name
}

# Manually lock the current tab name until `ztab auto` is used.
export def --env "ztab name" [name: string] {
    $env.ZELLIJ_TAB_NAME_MANUAL = $name
    session set-name $name
}

# Return to automatic tab naming and refresh immediately.
export def --env "ztab auto" [] {
    hide-env ZELLIJ_TAB_NAME_MANUAL --ignore-errors
    ztab refresh
}

# Install dynamic tab-renaming hooks. Hooks are appended, not overwritten, so
# Starship, zoxide, and future integrations can coexist.
export def --env "ztab install-hooks" [] {
    # Avoid exported env-var guards here: they are inherited by nested shells and
    # can make a fresh shell skip installing hooks entirely.
    let hooks = ($env.config | get -o hooks | default {})
    let pre_prompt = ($hooks | get -o pre_prompt | default [])
    let pre_execution = ($hooks | get -o pre_execution | default [])
    let env_change = ($hooks | get -o env_change | default {})
    let pwd_hooks = ($env_change | get -o PWD | default [])

    let hooks = ($hooks
        | upsert pre_prompt ($pre_prompt | append {|| ztab refresh })
        | upsert pre_execution ($pre_execution | append {|| ztab mark-processing })
        | upsert env_change ($env_change
            | upsert PWD ($pwd_hooks | append {|_before, _after| ztab refresh })
        )
    )

    $env.config = ($env.config | upsert hooks $hooks)
}

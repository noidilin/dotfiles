# Zellij shell-status integration for Nushell.
#
# Public facade for shell-event-driven Zellij output:
# - automatic tab names from cwd/git state
# - transient foreground-process tab labels
# - worktree labels published to zjstatus
# - hook installation
#
# The public command prefix remains `ztab` for muscle memory, but this module is
# broader than tab naming.

use events.nu
use cache.nu

# Refresh prompt-derived state. This runs before each prompt and should avoid
# cwd-specific side effects such as Git/worktree probing.
export def --env "ztab refresh-prompt" [] {
    events prompt
}

# Refresh cwd-derived state. This is intended for env_change.PWD, so worktree
# status updates follow directory changes instead of prompt polling.
export def --env "ztab refresh-cwd" [cwd?: string] {
    events cwd $cwd
}

# Backward-compatible manual refresh: update all automatic Zellij state.
export def --env "ztab refresh" [] {
    ztab refresh-cwd
}

# Mark the tab with the foreground process name until the prompt returns.
export def --env "ztab mark-processing" [] {
    events pre-execution (commandline)
}

# Manually lock the current tab name until `ztab auto` is used.
export def --env "ztab name" [name: string] {
    events set-manual-name $name
}

# Return to automatic tab naming and refresh immediately.
export def --env "ztab auto" [] {
    events restore-auto
}

# Install dynamic tab-renaming/status hooks. Hooks are appended, not overwritten,
# so Starship, zoxide, and future integrations can coexist.
export def --env "ztab install-hooks" [] {
    # Idempotent per process: config.nu can be re-sourced in the same shell, but
    # nested shells still install their own hooks.
    if (cache hooks-installed) { return }

    let hooks = ($env.config | get -o hooks | default {})
    let pre_prompt = ($hooks | get -o pre_prompt | default [])
    let pre_execution = ($hooks | get -o pre_execution | default [])
    let env_change = ($hooks | get -o env_change | default {})
    let pwd_hooks = ($env_change | get -o PWD | default [])

    let hooks = ($hooks
        | upsert pre_prompt ($pre_prompt | append {|| ztab refresh-prompt })
        | upsert pre_execution ($pre_execution | append {|| ztab mark-processing })
        | upsert env_change ($env_change
            | upsert PWD ($pwd_hooks | append {|_before, after| ztab refresh-cwd $after })
        )
    )

    $env.config = ($env.config | upsert hooks $hooks)
    cache remember-hooks-installed
}

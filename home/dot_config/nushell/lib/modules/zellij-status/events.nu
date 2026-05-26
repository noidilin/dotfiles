# Event-oriented decisions for Zellij shell output.
#
# This module owns the ordering invariants for shell events. Public ztab
# commands delegate here so Manual Tab Name, Foreground Process Label,
# Automatic Tab Name, and Worktree Status rules stay local.

use session.nu
use tab-name.nu
use process.nu
use worktree-publisher.nu

# A Manual Tab Name suppresses tab renames, but not Worktree Status updates.
def manual-tab-name-active [] {
    (($env.ZELLIJ_TAB_NAME_MANUAL? | default "") | is-not-empty)
}

# Refresh prompt-derived state. This clears any Foreground Process Label and,
# when automatic naming is active, restores the Automatic Tab Name.
export def --env prompt [] {
    hide-env ZELLIJ_TAB_PROCESS --ignore-errors
    if (manual-tab-name-active) { return }
    if not (session is-active) { return }

    session set-name (tab-name auto-name)
}

# Refresh cwd-derived state. Worktree Status always follows cwd changes;
# Automatic Tab Name follows cwd only when no Manual Tab Name is active.
export def --env cwd [cwd?: string] {
    let cwd = ($cwd | default ($env.PWD? | default (pwd)))
    worktree-publisher publish $cwd

    if (manual-tab-name-active) { return }
    if not (session is-active) { return }

    session set-name (tab-name auto-name $cwd)
}

# Mark the tab with a Foreground Process Label until the next prompt.
export def --env pre-execution [command: string] {
    if (manual-tab-name-active) { return }
    if not (session is-active) { return }

    let name = (process process-name $command)
    if ($name | is-empty) { return }

    $env.ZELLIJ_TAB_PROCESS = $name
    session set-name $name
}

# Set a Manual Tab Name until automatic naming is restored.
export def --env set-manual-name [name: string] {
    $env.ZELLIJ_TAB_NAME_MANUAL = $name
    session set-name $name
}

# Restore automatic naming and immediately refresh cwd-derived state.
export def --env restore-auto [] {
    hide-env ZELLIJ_TAB_NAME_MANUAL --ignore-errors
    cwd
}

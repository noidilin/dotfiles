# Publish the focused pane's cwd-derived worktree label to zjstatus.
#
# This module owns the safe status transport path: shell hooks provide cwd,
# the git adapter derives display text, and we push that text through zjstatus'
# pipe input. Do not add Zellij pane queries here.

use session.nu
use cache.nu

# Resolve the sibling Zellij config directory from XDG paths.
def zellij-config-dir [] {
    ($env.XDG_CONFIG_HOME? | default ($env.HOME | path join ".config") | path join "zellij")
}

# zjstatus' tiny pipe protocol uses `::` as separators and line-oriented input.
# Keep the displayed label valid even if a branch/worktree name contains odd text.
export def sanitize [text: string] {
    $text
    | str replace --all "\n" " "
    | str replace --all "::" "∷"
    | str trim
}

# Build the zjstatus pipe payload for the worktree segment.
export def pipe-payload [label: string] {
    $"zjstatus::pipe::worktree::($label)"
}

# Pure decision point for duplicate suppression and payload formatting.
export def plan-pipe-update [label: string, is_current: bool] {
    let should_publish = not $is_current

    {
        should_publish: $should_publish
        payload: (if $should_publish { pipe-payload $label } else { "" })
        label: $label
    }
}

# Push the focused shell's cwd-derived worktree label into zjstatus.
# This avoids relying on zjstatus command polling, whose process cwd is not the
# currently-focused pane's cwd.
export def --env publish [cwd?: string] {
    if not (session is-active) { return }

    let command = (zellij-config-dir | path join "bin" "zjstatus-worktree")
    if not ($command | path exists) { return }

    let cwd = ($cwd | default ($env.PWD? | default (pwd)))
    let result = (^$command $cwd | complete)
    let label = if $result.exit_code == 0 { sanitize $result.stdout } else { "" }

    let update = (plan-pipe-update $label (cache worktree-label-is-current $label))

    if not $update.should_publish { return }

    let pipe_result = (^zellij pipe --name zjstatus -- $update.payload | complete)
    if $pipe_result.exit_code == 0 {
        cache remember-worktree-label $update.label
    }
}

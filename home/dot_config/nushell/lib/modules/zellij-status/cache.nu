# Process-local env caches for Zellij tab state.
#
# Exported env vars are inherited by child shells, so every cached value is
# trusted only when its paired pid matches the current Nushell process.

def process-cache-id [] {
    $nu.pid | into string
}

export def auto-name [cwd: string] {
    if (($env.ZELLIJ_TAB_AUTO_CACHE_PID? | default "") != (process-cache-id)) { return null }
    if (($env.ZELLIJ_TAB_AUTO_PWD? | default "") != $cwd) { return null }

    let cached = ($env.ZELLIJ_TAB_AUTO_NAME? | default "")
    if ($cached | is-empty) { null } else { $cached }
}

export def --env remember-auto-name [cwd: string, name: string] {
    $env.ZELLIJ_TAB_AUTO_PWD = $cwd
    $env.ZELLIJ_TAB_AUTO_NAME = $name
    $env.ZELLIJ_TAB_AUTO_CACHE_PID = (process-cache-id)
}

export def tab-name-is-current [name: string] {
    (($env.ZELLIJ_LAST_TAB_NAME_PID? | default "") == (process-cache-id)) and (($env.ZELLIJ_LAST_TAB_NAME? | default "") == $name)
}

export def --env remember-tab-name [name: string] {
    $env.ZELLIJ_LAST_TAB_NAME = $name
    $env.ZELLIJ_LAST_TAB_NAME_PID = (process-cache-id)
}

export def hooks-installed [] {
    (($env.ZTAB_HOOKS_INSTALLED_PID? | default "") == (process-cache-id))
}

export def --env remember-hooks-installed [] {
    $env.ZTAB_HOOKS_INSTALLED_PID = (process-cache-id)
}

export def worktree-pipe-is-current [payload: string] {
    (($env.ZJSTATUS_WORKTREE_LAST_PID? | default "") == (process-cache-id)) and (($env.ZJSTATUS_WORKTREE_LAST_PIPE? | default "__zjstatus_unset__") == $payload)
}

export def --env remember-worktree-pipe [label: string, payload: string] {
    $env.ZJSTATUS_WORKTREE_LAST = $label
    $env.ZJSTATUS_WORKTREE_LAST_PIPE = $payload
    $env.ZJSTATUS_WORKTREE_LAST_PID = (process-cache-id)
}

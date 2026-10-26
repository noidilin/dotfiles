use session.nu
use tab-name.nu
use process.nu

def manual-tab-name-active [] {
    (($env.ZELLIJ_TAB_NAME_MANUAL? | default "") | is-not-empty)
}

export def --env prompt [] {
    hide-env ZELLIJ_TAB_PROCESS --ignore-errors
    if (manual-tab-name-active) { return }
    if not (session is-active) { return }

    session set-name (tab-name auto-name)
}

export def --env cwd [cwd?: string] {
    let cwd = ($cwd | default ($env.PWD? | default (pwd)))

    if (manual-tab-name-active) { return }
    if not (session is-active) { return }

    session set-name (tab-name auto-name $cwd)
}

export def --env pre-execution [command: string] {
    if (manual-tab-name-active) { return }
    if not (session is-active) { return }

    let name = (process process-name $command)
    if ($name | is-empty) { return }

    $env.ZELLIJ_TAB_PROCESS = $name
    session set-name $name
}

export def --env set-manual-name [name: string] {
    $env.ZELLIJ_TAB_NAME_MANUAL = $name
    session set-name $name
}

export def --env restore-auto [] {
    hide-env ZELLIJ_TAB_NAME_MANUAL --ignore-errors
    cwd
}

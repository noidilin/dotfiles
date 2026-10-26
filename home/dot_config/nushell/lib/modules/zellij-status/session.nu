use cache.nu

export def is-active [] {
    (($env.ZELLIJ? | default "") | is-not-empty) and ((which zellij | is-not-empty))
}

export def --env set-name [name: string] {
    if not (is-active) { return }
    if ($name | is-empty) { return }

    if (cache tab-name-is-current $name) { return }

    let result = (^zellij action rename-tab $name | complete)
    if $result.exit_code == 0 {
        cache remember-tab-name $name
    }
}

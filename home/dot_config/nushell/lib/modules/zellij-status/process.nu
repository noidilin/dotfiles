use format.nu shorten

export def process-name [command: string] {
    let first_line = ($command | str trim | lines | first | default "")
    if ($first_line | is-empty) { return "" }

    let first_segment = ($first_line | split row ";" | first | default "" | str trim)
    let executable = (
        $first_segment
        | str replace --regex '^\s*(sudo|doas|env|time|command|builtin|exec)\s+' ''
        | str replace --regex '^\^' ''
        | split row " "
        | where {|part| ($part | str trim | is-not-empty) }
        | first
        | default ""
        | path basename
    )

    if ($executable | is-empty) { "" } else { shorten $"($executable)" }
}

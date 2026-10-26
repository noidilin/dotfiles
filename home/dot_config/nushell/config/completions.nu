export def main [] {
  let carapace_completer = {|spans: list<string>|
    carapace $spans.0 nushell ...$spans
    | from json
    | if ($in | default [] | where value =~ '^-.*ERR$' | is-empty) { $in } else { null }
  }

  let fish_completer = {|spans|
    fish --command $'complete "--do-complete=($spans | str join " ")"'
    | $"value(char tab)description(char newline)" + $in
    | from tsv --flexible --no-infer
  }

  let zoxide_completer = {|spans|
    $spans | skip 1 | zoxide query -l ...$in | lines | where {|x| $x != $env.PWD}
  }

  let external_completer = {|place|
    let spans = $place.command
    let expanded_alias = (scope aliases | where name == $spans.0 | get --optional 0 | get --optional expansion)

    let spans = if $expanded_alias != null {
      $spans
      | skip 1
      | prepend ($expanded_alias | split row ' ')
    } else {
      $spans
    }

    match $spans.0 {
      z => $zoxide_completer
      zi => $zoxide_completer
      _ => $carapace_completer
    } | do $in $spans
  }
  return {
    case_sensitive: false
    quick: true
    partial: true
    algorithm: "prefix"
    sort: "smart"
    external: {
      enable: true
      max_results: 100
      completer: $external_completer
    }
    use_ls_colors: true
  }
}

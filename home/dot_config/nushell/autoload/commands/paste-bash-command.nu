def get-clipboard-text [] {
  match $nu.os-info.name {
    "macos" => {
      ^pbpaste
    }
    "windows" => {
      ^pwsh -NoLogo -NoProfile -Command "Get-Clipboard -Raw"
    }
    "linux" => {
      if ((which wl-paste | length) > 0) {
        ^wl-paste --no-newline
      } else if ((which xclip | length) > 0) {
        ^xclip -selection clipboard -o
      } else if ((which xsel | length) > 0) {
        ^xsel --clipboard --output
      } else {
        error make { msg: "No clipboard command found (tried wl-paste, xclip, xsel)" }
      }
    }
    _ => {
      error make { msg: $"Unsupported OS for clipboard paste: ($nu.os-info.name)" }
    }
  }
}

def normalize-bash-command-paste [] {
  str replace --all --regex '\r\n?' "\n"
  | str replace --all --regex '\\\n[ \t]*' ' '
  | str replace --all --regex '\n+' ' '
  | str trim
  | str replace --regex '^curl(?=\s)' '^curl'
}

def --env paste-bash-command [] {
  let text = (
    get-clipboard-text
    | normalize-bash-command-paste
  )

  if ($text | is-empty) {
    return
  }

  commandline edit --insert $text
  commandline set-cursor --end
}

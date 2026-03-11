yz() {
  local tmp cwd

  tmp="$(mktemp -t "yazi-cwd.XXXXXX" 2>/dev/null || mktemp)" || return 1
  yazi "$@" --cwd-file="$tmp"

  if [ -f "$tmp" ]; then
    cwd="$(<"$tmp")"
    if [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
      cd -- "$cwd" || return
    fi
    rm -f -- "$tmp"
  fi
}

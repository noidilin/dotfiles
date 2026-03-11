ez() {
  eza \
    --colour=always \
    --git \
    --group-directories-first \
    --icons=always \
    --ignore-glob=.DS_Store \
    --no-quotes \
    --sort=type \
    "$@"
}

alias lg='lazygit'

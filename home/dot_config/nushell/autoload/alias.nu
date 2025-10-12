const DEFAULT_EZA_ARGS = [
  "--colour=always",
  "--git",
  "--group-directories-first",
  "--icons=always",
  "--ignore-glob=.DS_Store",
  "--no-quotes",
  "--sort=type"
]

alias ez = eza ...$DEFAULT_EZA_ARGS
# alias l = eza -l ...$DEFAULT_EZA_ARGS
# alias ll = eza -lag ...$DEFAULT_EZA_ARGS
# alias ld = eza -lD ...$DEFAULT_EZA_ARGS
# alias lt = eza --tree --level=3 ...$DEFAULT_EZA_ARGS

alias lg = lazygit

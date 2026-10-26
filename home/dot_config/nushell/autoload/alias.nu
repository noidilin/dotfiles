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

alias lg = lazygit
alias ld = lazydocker
alias tf = terraform
alias tg = terragrunt
alias k = kubectl

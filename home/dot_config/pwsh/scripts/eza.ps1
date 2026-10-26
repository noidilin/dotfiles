if (!(Get-Command -Name "eza" -ErrorAction SilentlyContinue)) { return }

$DEFAULT_EZA_ARGS = @(
  "--colour=always"
  "--git"
  "--group-directories-first"
  "--icons=always"
  "--ignore-glob=.DS_Store"
  "--no-quotes"
  "--sort=type"
)

function _ls {
  eza @DEFAULT_EZA_ARGS @args
}

Set-Alias -Name ls -Value _ls -Force

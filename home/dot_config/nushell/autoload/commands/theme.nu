# Switch or inspect the achroma light/dark variant.
def --env theme [
  variant?: string # 'light' or 'dark'; omit to show the current state
] {
  let pointer = ($env.XDG_CONFIG_HOME | path join 'achroma' 'current')

  if $variant == null {
    return {
      variant: ($env.ACHROMA_VARIANT? | default 'unset')
      pointer: (if ($pointer | path exists) { $pointer | path expand | path basename } else { 'unset' })
      delta_features: ($env.DELTA_FEATURES? | default 'unset')
      wezterm_pin: ($env.WEZTERM_THEME? | default 'none (follows OS)')
    }
  }
  if $variant not-in ['light' 'dark'] {
    error make { msg: $"expected 'light' or 'dark', got '($variant)'" }
  }

  match $nu.os-info.name {
    'windows' => {
      pwsh -NoProfile -File ($env.XDG_CONFIG_HOME | path join 'pwsh' 'scripts' 'set-app-theme.ps1') -Variant $variant
    }
    'macos' => {
      let flag = ($variant == 'dark')
      ^osascript -e $'tell application "System Events" to tell appearance preferences to set dark mode to ($flag)'
    }
    _ => { error make { msg: $'no OS appearance toggle wired up for ($nu.os-info.name)' } }
  }

  $env.ACHROMA_VARIANT = $variant
  $env.DELTA_FEATURES = (if $variant == 'light' { 'achroma-light' } else { 'achroma' })
  let vivid_theme = (if $variant == 'light' { 'achroma-light.yml' } else { 'achroma.yml' })
  $env.LS_COLORS = (vivid generate ($env.XDG_CONFIG_HOME | path join 'vivid' 'themes' $vivid_theme) | str trim)
  $env.EZA_CONFIG_DIR = ($env.XDG_CONFIG_HOME | path join 'eza' (if $variant == 'light' { 'achroma-light' } else { 'achroma' }))
  let suffix = (if $variant == 'light' { '-light' } else { '' })
  $env.LG_CONFIG_FILE = ([
    ($env.XDG_CONFIG_HOME | path join 'lazygit' 'config.yml')
    ($env.XDG_CONFIG_HOME | path join 'lazygit' $'theme-achroma($suffix).yml')
  ] | str join ',')
  $env.GH_DASH_CONFIG = ($env.XDG_CONFIG_HOME | path join 'gh-dash' $'config-achroma($suffix).yml')

  match $nu.os-info.name {
    'windows' => {
      pwsh -NoProfile -File ($env.XDG_CONFIG_HOME | path join 'pwsh' 'scripts' 'set-achroma-current.ps1') -Variant $variant
    }
    # -n is required: without it, `current` being an existing symlink to a
    # directory makes ln write the new link *inside* the old target.
    _ => { ^ln -sfn $'variants/($variant)' $pointer }
  }

  if (which herdr | is-not-empty) {
    try { ^herdr server reload-config } catch { }
  }

  print $'app theme -> ($variant)'
  print 'follows automatically: wezterm, nvim, bat, delta, windows terminal, zed, yazi, opencode, zellij'
  print 'via achroma/current, live: starship (next prompt, every running shell)'
  print 'via achroma/current + reload: herdr'
  print 'via achroma/current (next launch): jjui, k9s, pi, posting, carapace, bottom, lazydocker, claude code, leaf, tuxedo'
  print 'refreshed in this session: delta, LS_COLORS (vivid), eza, lazygit, gh-dash'
  print 'per-session (restart shell/app): fzf colors, nushell color_config, other running shells'
}

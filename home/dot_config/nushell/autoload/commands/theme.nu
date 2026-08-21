# Switch or inspect the achroma light/dark variant.
#
# `theme light` / `theme dark` flips the OS app theme -- the single source of
# truth. Everything that watches the OS or the terminal background follows on
# its own: wezterm -> neovim (OSC 11), bat, delta's mode detection, ghostty,
# windows terminal, zed, yazi, opencode. This command also refreshes the env
# vars for the current session (other running shells re-resolve on start).
# zellij switches natively (theme_dark/theme_light in config.kdl). jjui and
# k9s have a single selection key: flipped in place below (chezmoi's source
# keeps the dark default, so `chezmoi apply` resets them to dark -- rerun
# this command after applying while in light mode).
#
# Still dark-only, to be wired up here as their light themes land:
# pi, posting, starship palette, vivid/LS_COLORS, eza, carapace,
# nushell's own color_config.
def --env theme [
  variant?: string # 'light' or 'dark'; omit to show the current state
] {
  if $variant == null {
    return {
      variant: ($env.ACHROMA_VARIANT? | default 'unset')
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

  # Refresh this session; new shells re-resolve from the OS in env/variant.nu.
  $env.ACHROMA_VARIANT = $variant
  $env.DELTA_FEATURES = (if $variant == 'light' { 'achroma-light' } else { 'achroma' })

  # Tools with one selection key in their applied config: flip it in place.
  let theme_name = (if $variant == 'light' { 'achroma-light' } else { 'achroma' })
  let flips = [
    [file key];
    [($env.XDG_CONFIG_HOME | path join 'jjui' 'config.toml') 'theme = "']
    [($env.XDG_CONFIG_HOME | path join 'k9s' 'config.yaml') 'skin: ']
  ]
  for f in $flips {
    if ($f.file | path exists) {
      open --raw $f.file
      | str replace --regex ($f.key + 'achroma(-light)?') ($f.key + $theme_name)
      | save --force --raw $f.file
    }
  }

  print $'app theme -> ($variant)'
  print 'follows automatically: wezterm, nvim, bat, delta, windows terminal, zed, yazi, opencode, zellij'
  print 'config flipped in place (restart if running): jjui, k9s'
  print 'per-session (restart shell/app): fzf colors, nushell color_config, other running shells'
}

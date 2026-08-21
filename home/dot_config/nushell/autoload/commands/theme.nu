# Switch or inspect the achroma light/dark variant.
#
# `theme light` / `theme dark` flips the OS app theme -- the single source of
# truth. Everything that watches the OS or the terminal background follows on
# its own: wezterm -> neovim (OSC 11), bat, delta's mode detection, ghostty,
# windows terminal, zed, yazi, opencode. This command also refreshes the env
# vars for the current session (other running shells re-resolve on start).
# zellij switches natively (theme_dark/theme_light in config.kdl). jjui, k9s,
# starship, pi and posting have a single selection key: flipped in place below
# (chezmoi's source keeps the dark default, so `chezmoi apply` resets them to
# dark -- rerun this command after applying while in light mode). vivid/eza
# resolve from ACHROMA_VARIANT at shell start and are refreshed here; nushell's
# color_config resolves at shell start only.
#
# carapace, bottom and lazydocker read exactly one config file, so the
# variant render is copied over it below (same chezmoi-apply-resets-to-dark
# caveat as the key flips). lazygit (LG_CONFIG_FILE) and gh-dash
# (GH_DASH_CONFIG) resolve from env at launch and are refreshed here.
#
# zebar follows the OS app theme on its own (bootstrap in its main.html).
# flow-launcher and antinote have light theme files but the app's theme is
# selected in-app, not flipped here. Still dark-only (deferred): blender,
# stylus userstyles, shareX, fcitx5.
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
  let vivid_theme = (if $variant == 'light' { 'achroma-light.yml' } else { 'achroma.yml' })
  $env.LS_COLORS = (vivid generate ($env.XDG_CONFIG_HOME | path join 'vivid' 'themes' $vivid_theme) | str trim)
  $env.EZA_CONFIG_DIR = ($env.XDG_CONFIG_HOME | path join 'eza' (if $variant == 'light' { 'achroma-light' } else { 'achroma' }))
  let suffix = (if $variant == 'light' { '-light' } else { '' })
  $env.LG_CONFIG_FILE = ([
    ($env.XDG_CONFIG_HOME | path join 'lazygit' 'config.yml')
    ($env.XDG_CONFIG_HOME | path join 'lazygit' $'theme-achroma($suffix).yml')
  ] | str join ',')
  $env.GH_DASH_CONFIG = ($env.XDG_CONFIG_HOME | path join 'gh-dash' $'config-achroma($suffix).yml')

  # Tools with one selection key in their applied config: flip it in place.
  let flips = [
    [file key name];
    [($env.XDG_CONFIG_HOME | path join 'jjui' 'config.toml') 'theme = "' 'achroma']
    [($env.XDG_CONFIG_HOME | path join 'k9s' 'config.yaml') 'skin: ' 'achroma']
    [($env.XDG_CONFIG_HOME | path join 'starship.toml') "palette = '" 'noidilin']
    [($env.XDG_CONFIG_HOME | path join 'pi' 'settings.json') '"theme": "' 'achroma']
    [($env.XDG_CONFIG_HOME | path join 'posting' 'config.yaml') 'theme: ' 'achroma']
  ]
  for f in $flips {
    if ($f.file | path exists) {
      let target = (if $variant == 'light' { $f.name + '-light' } else { $f.name })
      open --raw $f.file
      | str replace --regex ($f.key + $f.name + '(-light)?') ($f.key + $target)
      | save --force --raw $f.file
    }
  }

  # Tools that read exactly one config file: copy the variant render over it.
  let copies = [
    [src dst];
    [($env.XDG_CONFIG_HOME | path join 'carapace' $'styles-achroma($suffix).json') ($env.XDG_CONFIG_HOME | path join 'carapace' 'styles.json')]
    [($env.XDG_CONFIG_HOME | path join 'bottom' $'bottom-achroma($suffix).toml') ($env.XDG_CONFIG_HOME | path join 'bottom' 'bottom.toml')]
    [($env.XDG_CONFIG_HOME | path join 'lazydocker' $'config-achroma($suffix).yml') ($env.XDG_CONFIG_HOME | path join 'lazydocker' 'config.yml')]
  ]
  for c in $copies {
    if ($c.src | path exists) {
      open --raw $c.src | save --force --raw $c.dst
    }
  }

  print $'app theme -> ($variant)'
  print 'follows automatically: wezterm, nvim, bat, delta, windows terminal, zed, yazi, opencode, zellij'
  print 'config flipped in place (restart if running): jjui, k9s, starship, pi, posting, carapace, bottom, lazydocker'
  print 'refreshed in this session: delta, LS_COLORS (vivid), eza, lazygit, gh-dash'
  print 'per-session (restart shell/app): fzf colors, nushell color_config, other running shells'
}

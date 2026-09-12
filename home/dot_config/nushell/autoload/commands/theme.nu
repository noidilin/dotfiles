# Switch or inspect the achroma light/dark variant.
#
# `theme light` / `theme dark` flips the OS app theme -- the single source of
# truth. Everything that watches the OS or the terminal background follows on
# its own: wezterm -> neovim (OSC 11), bat, delta's mode detection, ghostty,
# windows terminal, zed, yazi, opencode. This command also refreshes the env
# vars for the current session (other running shells re-resolve on start).
# zellij switches natively (theme_dark/theme_light in config.kdl).
#
# Everything that cannot follow on its own goes through ONE pointer:
# ~/.config/achroma/current, a symlink to achroma/variants/{dark,light}.
# chezmoi renders both variant trees and owns every path that reaches into
# them; it ignores the pointer itself, so this command is the only writer and
# `chezmoi apply` can no longer reset the live variant (it used to -- the old
# mechanism rewrote applied configs in place, and the chezmoi source kept the
# dark default). Two shapes of indirection, no drift in either:
#
#   - tools with a themes directory read a fixed filename that never changes:
#     jjui `theme = "achroma-current"`, k9s `skin:`, pi `"theme":`,
#     posting `theme:`, claude code `"theme": "custom:achroma-current"` --
#     themes/achroma-current.* is a symlink into current/.
#   - tools that read exactly one config file have that whole file symlinked:
#     starship, carapace, bottom, lazydocker, herdr.
#
# starship is the one that updates live in *every* running shell: it re-reads
# and re-resolves ~/.config/starship.toml on each prompt. herdr needs
# `server reload-config` to pick the new target up without dropping the
# session, done below. The rest apply on next launch.
#
# vivid/eza resolve from ACHROMA_VARIANT at shell start and are refreshed here;
# nushell's color_config resolves at shell start only. lazygit (LG_CONFIG_FILE)
# and gh-dash (GH_DASH_CONFIG) resolve from env at launch and are refreshed
# here.
#
# zebar follows the OS app theme on its own (bootstrap in its main.html).
# flow-launcher and antinote have light theme files but the app's theme is
# selected in-app, not flipped here. Still dark-only (deferred): blender,
# stylus userstyles, shareX, fcitx5.
def --env theme [
  variant?: string # 'light' or 'dark'; omit to show the current state
] {
  let pointer = ($env.XDG_CONFIG_HOME | path join 'achroma' 'current')

  if $variant == null {
    return {
      variant: ($env.ACHROMA_VARIANT? | default 'unset')
      # Resolves the symlink, so this is the authoritative live variant --
      # and the cheapest way to confirm `chezmoi apply` left it alone.
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

  # The whole switch for the ten pointer-driven tools. Relative target, so it
  # resolves against the pointer's own directory.
  match $nu.os-info.name {
    'windows' => {
      pwsh -NoProfile -File ($env.XDG_CONFIG_HOME | path join 'pwsh' 'scripts' 'set-achroma-current.ps1') -Variant $variant
    }
    # -n is required: without it, `current` being an existing symlink to a
    # directory makes ln write the new link *inside* the old target.
    _ => { ^ln -sfn $'variants/($variant)' $pointer }
  }

  # herdr holds its config in the running server; reload so the new pointer
  # target applies without dropping the session. Silent when no server is up.
  if (which herdr | is-not-empty) {
    try { ^herdr server reload-config } catch { }
  }

  print $'app theme -> ($variant)'
  print 'follows automatically: wezterm, nvim, bat, delta, windows terminal, zed, yazi, opencode, zellij'
  print 'via achroma/current, live: starship (next prompt, every running shell)'
  print 'via achroma/current + reload: herdr'
  print 'via achroma/current (restart if running): jjui, k9s, pi, posting, carapace, bottom, lazydocker, claude code'
  print 'refreshed in this session: delta, LS_COLORS (vivid), eza, lazygit, gh-dash'
  print 'per-session (restart shell/app): fzf colors, nushell color_config, other running shells'
}

# achroma variant, resolved once per shell start from the OS appearance.
#
# The OS app theme is the single source of truth: wezterm, neovim (via OSC 11),
# bat, ghostty, windows terminal, zed and yazi all follow it on their own.
# This file covers the tools that only read their colors at shell startup
# (delta features, fzf colors). Flip everything at once with the `theme`
# command (autoload/commands/theme.nu).

$env.ACHROMA_VARIANT = (match $nu.os-info.name {
  'windows' => {
    let v = (try {
      registry query --hkcu 'Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'AppsUseLightTheme'
    } catch { 0 })
    if $v == 1 { 'light' } else { 'dark' }
  }
  'macos' => {
    let style = (try { ^defaults read -g AppleInterfaceStyle } catch { 'Light' })
    if $style =~ 'Dark' { 'dark' } else { 'light' }
  }
  _ => 'dark'
})

# delta cannot pick a feature from the terminal background itself; a bare
# (un-prefixed) DELTA_FEATURES value replaces the features from gitconfig.
$env.DELTA_FEATURES = (if $env.ACHROMA_VARIANT == 'light' { 'achroma-light' } else { 'achroma' })

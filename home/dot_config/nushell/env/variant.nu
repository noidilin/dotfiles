$env.ACHROMA_VARIANT = (match $nu.os-info.name {
  'windows' => {
    let v = (try {
      registry query --hkcu 'Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'AppsUseLightTheme' | get value
    } catch { 0 })
    if $v == 1 { 'light' } else { 'dark' }
  }
  'macos' => {
    # In Light mode this key is intentionally absent. `try` catches the
    # non-zero exit but still lets the external command's stderr through, so
    # capture the complete result and treat a failed read as Light.
    let result = (^defaults read -g AppleInterfaceStyle | complete)
    let style = (if $result.exit_code == 0 { $result.stdout } else { 'Light' })
    if $style =~ 'Dark' { 'dark' } else { 'light' }
  }
  _ => 'dark'
})

# delta cannot pick a feature from the terminal background itself; a bare
# (un-prefixed) DELTA_FEATURES value replaces the features from gitconfig.
$env.DELTA_FEATURES = (if $env.ACHROMA_VARIANT == 'light' { 'achroma-light' } else { 'achroma' })

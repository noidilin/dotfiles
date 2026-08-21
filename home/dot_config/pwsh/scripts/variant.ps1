# achroma variant, resolved once per shell start from the OS appearance
# (mirrors nushell env/variant.nu — the OS app theme is the single source of
# truth). Flip it with the nushell `theme` command or scripts/set-app-theme.ps1;
# running pwsh sessions re-resolve on next start.
$appsUseLightTheme = 0
try {
  $appsUseLightTheme = (Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'AppsUseLightTheme' -ErrorAction Stop).AppsUseLightTheme
} catch {}
$env:ACHROMA_VARIANT = if ($appsUseLightTheme -eq 1) { 'light' } else { 'dark' }
$achromaSuffix = if ($env:ACHROMA_VARIANT -eq 'light') { '-light' } else { '' }

# delta cannot pick a feature from the terminal background itself; a bare
# (un-prefixed) DELTA_FEATURES value replaces the features from gitconfig.
$env:DELTA_FEATURES = "achroma$achromaSuffix"

# eza reads exactly one $EZA_CONFIG_DIR/theme.yml, so the variant picks the dir
$env:EZA_CONFIG_DIR = "$HOME\.config\eza\achroma$achromaSuffix"

# lazygit layers the variant theme fragment over the shared config
$env:LG_CONFIG_FILE = "$HOME\.config\lazygit\config.yml,$HOME\.config\lazygit\theme-achroma$achromaSuffix.yml"

# gh-dash reads the variant render directly
$env:GH_DASH_CONFIG = "$HOME\.config\gh-dash\config-achroma$achromaSuffix.yml"

if (Get-Command "vivid" -ErrorAction SilentlyContinue) {
  $env:LS_COLORS = (vivid generate "$HOME\.config\vivid\themes\achroma$achromaSuffix.yml" | Out-String).Trim()
}

Remove-Variable appsUseLightTheme, achromaSuffix

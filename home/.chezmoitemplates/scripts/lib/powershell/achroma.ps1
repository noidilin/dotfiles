function Get-AchromaVariant {
    $appsUseLightTheme = 0
    try {
        $appsUseLightTheme = (Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'AppsUseLightTheme' -ErrorAction Stop).AppsUseLightTheme
    } catch {}
    if ($appsUseLightTheme -eq 1) { 'light' } else { 'dark' }
}

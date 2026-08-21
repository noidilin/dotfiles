# Flip the Windows app theme (the achroma single source of truth).
#
# Only AppsUseLightTheme is touched: terminals, editors and zebar follow the
# app theme; the system theme (taskbar / start menu) is left alone.
#
# A plain registry write does not notify running programs, so afterwards we
# broadcast WM_SETTINGCHANGE "ImmersiveColorSet" -- the same message Windows
# Settings sends -- which is what makes wezterm, Windows Terminal and zed
# switch without a restart.
param(
    [Parameter(Mandatory)]
    [ValidateSet('light', 'dark')]
    [string]$Variant
)

$value = if ($Variant -eq 'light') { 1 } else { 0 }
Set-ItemProperty `
    -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' `
    -Name 'AppsUseLightTheme' -Value $value -Type DWord

Add-Type -Namespace Win32 -Name NativeMethods -MemberDefinition @'
[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
public static extern IntPtr SendMessageTimeout(
    IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam,
    uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
'@

[UIntPtr]$result = [UIntPtr]::Zero
# 0xffff = HWND_BROADCAST, 0x1A = WM_SETTINGCHANGE, 2 = SMTO_ABORTIFHUNG
[Win32.NativeMethods]::SendMessageTimeout(
    [IntPtr]0xffff, 0x1A, [UIntPtr]::Zero, 'ImmersiveColorSet', 2, 5000, [ref]$result) | Out-Null

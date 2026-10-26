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

$HWND_BROADCAST = [IntPtr]0xffff
$WM_SETTINGCHANGE = 0x001A
$SMTO_ABORTIFHUNG = 0x0002

[UIntPtr]$result = [UIntPtr]::Zero
[Win32.NativeMethods]::SendMessageTimeout(
    $HWND_BROADCAST, $WM_SETTINGCHANGE, [UIntPtr]::Zero, 'ImmersiveColorSet', $SMTO_ABORTIFHUNG, 5000, [ref]$result) | Out-Null

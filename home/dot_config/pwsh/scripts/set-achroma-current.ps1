# Re-point the achroma variant pointer (~/.config/achroma/current).
#
# This is the only mutable piece of achroma theme state. The nine tools that
# cannot follow the OS app theme on their own reach their colors through this
# pointer, so flipping it is the whole switch (see docs/achroma.md). chezmoi
# ignores the pointer, which is what keeps `chezmoi apply` from resetting the
# live variant.
#
# Real symlinks need SeCreateSymbolicLinkPrivilege or Developer Mode, both set
# up by init/win.ps1. If that ever fails, fall back to a directory junction,
# which needs no elevation but requires an absolute target.
param(
    [Parameter(Mandatory)]
    [ValidateSet('light', 'dark')]
    [string]$Variant
)

$achroma = Join-Path $env:USERPROFILE '.config\achroma'
$link = Join-Path $achroma 'current'

if (-not (Test-Path -LiteralPath $achroma)) {
    New-Item -ItemType Directory -Path $achroma -Force | Out-Null
}

try {
    New-Item -ItemType SymbolicLink -Path $link -Target "variants\$Variant" -Force | Out-Null
} catch {
    Write-Host "Symlink failed ($_); falling back to a directory junction." -ForegroundColor Yellow
    $target = Join-Path $achroma "variants\$Variant"
    if (Test-Path -LiteralPath $link) { cmd /c rmdir "$link" }
    cmd /c mklink /J "$link" "$target" | Out-Null
}

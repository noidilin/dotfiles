function Reload-Profile {
  . $PROFILE
}

Set-Alias -Name rl -Value Reload-Profile

if (Get-Command lazygit) { Set-Alias -Name lg -Value lazygit }

function yz {
    <#
    .SYNOPSIS
        A function that allows yazi to cd into cwd.
    #>
    $tmp = [System.IO.Path]::GetTempFileName()
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath $cwd
    }
    Remove-Item -Path $tmp
}

function Delete-RecyleBin {
  $Path = 'C' + ':\$Recycle.Bin'
  Get-ChildItem $Path -Force -Recurse -ErrorAction SilentlyContinue |
    Remove-Item -Recurse -Exclude *.ini -ErrorAction SilentlyContinue
  Write-Host "All the necessary data removed from recycle bin successfully" -ForegroundColor Green
}
function Delete-TempData {
  Write-Host "Erasing temporary files from various locations" -ForegroundColor Yellow  
  $Path1 = 'C' + ':\Windows\Temp' 
  Get-ChildItem $Path1 -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue  
  $Path2 = 'C' + ':\Windows\Prefetch' 
  Get-ChildItem $Path2 -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue  
  $Path3 = 'C' + ':\Users\*\AppData\Local\Temp' 
  Get-ChildItem $Path3 -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
  Write-Host "removed all the temp files successfully" -ForegroundColor Green
}
function Run-DiskCleanUp {
  Write-Host "Using Disk cleanup Tool" -ForegroundColor Yellow  
  cleanmgr /sagerun:1 | out-Null  
  Write-Host "$([char]7)"  
  Write-Host "Disk Cleanup Successfully done" -ForegroundColor Green  
}
function Clean-All {
  Delete-RecyleBin
  Delete-TempData
  Run-DiskCleanUp
}

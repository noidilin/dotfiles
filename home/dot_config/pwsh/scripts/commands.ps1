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

# Source: https://www.geeksforgeeks.org/disk-cleanup-using-powershell-scripts/
# 1 Removing recycle bin files
function Delete-RecyleBin {
    <#
    .SYNOPSIS
        A function that allows yazi to cd into cwd.
    #>
  # Set the path to the recycle bin on the C drive
  $Path = 'C' + ':\$Recycle.Bin'
  # Get all items (files and directories) within the recycle bin path, including hidden ones
  Get-ChildItem $Path -Force -Recurse -ErrorAction SilentlyContinue |
    # Remove the items, excluding any files with the .ini extension
    Remove-Item -Recurse -Exclude *.ini -ErrorAction SilentlyContinue
  # Display a success message
  Write-Host "All the necessary data removed from recycle bin successfully" -ForegroundColor Green
}
# 2 Remove Temp files from various locations 
function Delete-TempData {
  Write-Host "Erasing temporary files from various locations" -ForegroundColor Yellow  
  # Specify the path where temporary files are stored in the Windows Temp folder
  $Path1 = 'C' + ':\Windows\Temp' 
  # Remove all items (files and directories) from the Windows Temp folder
  Get-ChildItem $Path1 -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue  
  # Specify the path where temporary files are stored in the Windows Prefetch folder
  $Path2 = 'C' + ':\Windows\Prefetch' 
  # Remove all items (files and directories) from the Windows Prefetch folder
  Get-ChildItem $Path2 -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue  
  # Specify the path where temporary files are stored in the user's AppData\Local\Temp folder
  $Path3 = 'C' + ':\Users\*\AppData\Local\Temp' 
  # Remove all items (files and directories) from the specified user's Temp folder
  Get-ChildItem $Path3 -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
  # Display a success message
  Write-Host "removed all the temp files successfully" -ForegroundColor Green
}
# 3 Using Disk cleanup Tool  
function Run-DiskCleanUp {
  # Display a message indicating the usage of the Disk Cleanup tool
  Write-Host "Using Disk cleanup Tool" -ForegroundColor Yellow  
  # Run the Disk Cleanup tool with the specified sagerun parameter
  cleanmgr /sagerun:1 | out-Null  
  # Emit a beep sound using ASCII code 7
  Write-Host "$([char]7)"  
  # Display a success message indicating that Disk Cleanup was successfully done
  Write-Host "Disk Cleanup Successfully done" -ForegroundColor Green  
}
# 4 function that combines all the clean functions
function Clean-All {
  Delete-RecyleBin
  Delete-TempData
  Run-DiskCleanUp
}

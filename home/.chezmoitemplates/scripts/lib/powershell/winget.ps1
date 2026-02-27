$script:WingetPackages = $null

function Get-WingetInstalledPackages {
    if ($null -ne $script:WingetPackages) {
        return $script:WingetPackages
    }

    $script:WingetPackages = @()

    $tempFile = [System.IO.Path]::GetTempFileName()
    try {
        winget export -o $tempFile --accept-source-agreements 2>$null | Out-Null
        if ($LASTEXITCODE -ne 0 -or !(Test-Path $tempFile)) {
            Write-ErrorLine "WARNING: Failed to query installed packages (skipping all)"
            return $script:WingetPackages
        }

        $jsonContent = Get-Content $tempFile -Raw | ConvertFrom-Json
        if ($jsonContent.Sources) {
            foreach ($source in $jsonContent.Sources) {
                if ($source.Packages) {
                    foreach ($pkg in $source.Packages) {
                        if ($pkg.PackageIdentifier) {
                            $script:WingetPackages += $pkg.PackageIdentifier
                        }
                    }
                }
            }
        }
    } catch {
        Write-ErrorLine "WARNING: Failed to parse installed packages: $_"
    } finally {
        if (Test-Path $tempFile) {
            Remove-Item $tempFile -Force
        }
    }

    return $script:WingetPackages
}

function Test-WinGetPackage {
    param([string]$PackageId)
    $installed = Get-WingetInstalledPackages
    return $installed -contains $PackageId
}

function Install-WinGetPackage {
    param([string]$PackageId)

    if (Test-WinGetPackage $PackageId) {
        Write-SkipLine "$PackageId is already installed (skipping)"
        Add-Skipped
        return
    }

    Write-InfoLine "Installing: $PackageId"
    try {
        winget install --id $PackageId --silent --accept-source-agreements --accept-package-agreements
        if ($LASTEXITCODE -ne 0) {
            Write-ErrorLine "Failed to install $PackageId (exit code: $LASTEXITCODE)"
            Add-Failure -Manager "winget" -Package $PackageId
        } else {
            Add-Installed
        }
    } catch {
        Write-ErrorLine "Failed to install $PackageId : $_"
        Add-Failure -Manager "winget" -Package $PackageId
    }
}

$script:ScoopPackages = $null

function Get-ScoopInstalledPackages {
    if ($null -ne $script:ScoopPackages) {
        return $script:ScoopPackages
    }

    $script:ScoopPackages = @()

    try {
        $installed = scoop list 2>$null
        if ($LASTEXITCODE -ne 0 -or -not $installed) {
            Write-ErrorLine "WARNING: Failed to query installed packages (skipping all)"
            return $script:ScoopPackages
        }

        $script:ScoopPackages = @($installed.Name)
    } catch {
        Write-ErrorLine "WARNING: Failed to query installed packages: $_"
    }

    return $script:ScoopPackages
}

function Test-ScoopPackageInstalled {
    param([string]$Package)
    $installed = Get-ScoopInstalledPackages
    return $installed -contains $Package
}

function Install-ScoopPackage {
    param([string]$Package)

    if (Test-ScoopPackageInstalled -Package $Package) {
        Write-SkipLine "$Package is already installed (skipping)"
        Add-Skipped
        return
    }

    Write-InfoLine "Installing: $Package"
    try {
        scoop install $Package
        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            Add-Installed
        } else {
            Write-ErrorLine "Failed to install $Package (exit code: $LASTEXITCODE)"
            Add-Failure -Manager "scoop" -Package $Package
        }
    } catch {
        Write-ErrorLine "Failed to install $Package : $_"
        Add-Failure -Manager "scoop" -Package $Package
    }
}

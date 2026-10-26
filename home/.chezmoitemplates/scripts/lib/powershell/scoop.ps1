$script:ScoopPackages = $null
$script:ScoopBuckets = $null

function Get-ScoopBuckets {
    if ($null -ne $script:ScoopBuckets) {
        return $script:ScoopBuckets
    }

    $script:ScoopBuckets = @()

    try {
        $buckets = scoop bucket list 2>$null
        if ($LASTEXITCODE -eq 0 -and $buckets) {
            $script:ScoopBuckets = @($buckets.Name)
        }
    } catch {
        Write-ErrorLine "WARNING: Failed to query scoop buckets: $_"
    }

    return $script:ScoopBuckets
}

function Add-ScoopBucket {
    param(
        [string]$Name,
        [string]$Url = ""
    )

    if ((Get-ScoopBuckets) -contains $Name) {
        Write-SkipLine "Bucket '$Name' is already added (skipping)"
        return
    }

    Write-InfoLine "Adding bucket: $Name"
    try {
        if ($Url) {
            scoop bucket add $Name $Url
        } else {
            scoop bucket add $Name
        }
        if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) {
            Write-ErrorLine "Failed to add bucket $Name (exit code: $LASTEXITCODE)"
            Add-Failure -Manager "scoop-bucket" -Package $Name
        }
    } catch {
        Write-ErrorLine "Failed to add bucket $Name : $_"
        Add-Failure -Manager "scoop-bucket" -Package $Name
    }
}

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

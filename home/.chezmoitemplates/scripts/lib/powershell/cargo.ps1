$script:CargoPackages = $null

function Get-CargoInstalledPackages {
    if ($null -ne $script:CargoPackages) {
        return $script:CargoPackages
    }

    $script:CargoPackages = @()
    $rawOutput = mise exec -- cargo install --list 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $rawOutput) {
        return $script:CargoPackages
    }

    $packages = $rawOutput | rg -N '^\S+\s+v\d' | rg -o '^\S+'
    foreach ($pkg in $packages) {
        if ($pkg) {
            $script:CargoPackages += $pkg
        }
    }

    return $script:CargoPackages
}

function Test-CargoPackageInstalled {
    param([string]$Package)
    $installed = Get-CargoInstalledPackages
    return $installed -contains $Package
}

function Install-CargoPackage {
    param([string]$Package)

    if (Test-CargoPackageInstalled -Package $Package) {
        Write-SkipLine "$Package is already installed via cargo (skipping)"
        Add-Skipped
        return
    }

    Write-InfoLine "Installing (cargo): $Package"
    try {
        mise exec -- cargo install $Package
        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            Add-Installed
        } else {
            Write-ErrorLine "Failed to install $Package (cargo, exit code: $LASTEXITCODE)"
            Add-Failure -Manager "cargo" -Package $Package
        }
    } catch {
        Write-ErrorLine "Failed to install $Package (cargo): $_"
        Add-Failure -Manager "cargo" -Package $Package
    }
}

$script:PnpmPackages = $null

function Get-PnpmInstalledPackages {
    if ($null -ne $script:PnpmPackages) {
        return $script:PnpmPackages
    }

    $script:PnpmPackages = @()
    $rawOutput = mise exec -- pnpm ls -g --depth=0 --json 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $rawOutput) {
        return $script:PnpmPackages
    }

    foreach ($project in ($rawOutput | Out-String | ConvertFrom-Json)) {
        if ($project.dependencies) {
            $script:PnpmPackages += $project.dependencies.PSObject.Properties.Name
        }
    }

    return $script:PnpmPackages
}

function Test-PnpmPackageInstalled {
    param([string]$Package)
    $installed = Get-PnpmInstalledPackages
    return $installed -contains $Package
}

function Install-PnpmPackage {
    param([string]$Package)

    if (Test-PnpmPackageInstalled -Package $Package) {
        Write-SkipLine "$Package is already installed via pnpm (skipping)"
        Add-Skipped
        return
    }

    Write-InfoLine "Installing (pnpm): $Package"
    try {
        mise exec -- pnpm add -g $Package
        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            Add-Installed
        } else {
            Write-ErrorLine "Failed to install $Package (pnpm, exit code: $LASTEXITCODE)"
            Add-Failure -Manager "pnpm" -Package $Package
        }
    } catch {
        Write-ErrorLine "Failed to install $Package (pnpm): $_"
        Add-Failure -Manager "pnpm" -Package $Package
    }
}

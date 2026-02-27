$script:UvTools = $null

function Get-UvInstalledTools {
    if ($null -ne $script:UvTools) {
        return $script:UvTools
    }

    $script:UvTools = @()
    $rawOutput = mise exec -- uv tool list 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $rawOutput) {
        return $script:UvTools
    }

    $packages = $rawOutput | rg -N '^\S+\s+v\d' | rg -o '^\S+' | rg -v '^Installed$'
    foreach ($pkg in $packages) {
        if ($pkg) {
            $script:UvTools += $pkg
        }
    }

    return $script:UvTools
}

function Test-UvToolInstalled {
    param([string]$Package)
    $installed = Get-UvInstalledTools
    return $installed -contains $Package
}

function Install-UvTool {
    param([string]$Package)

    if (Test-UvToolInstalled -Package $Package) {
        Write-SkipLine "$Package is already installed via uv (skipping)"
        Add-Skipped
        return
    }

    Write-InfoLine "Installing (uv): $Package"
    try {
        mise exec -- uv tool install $Package
        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            Add-Installed
        } else {
            Write-ErrorLine "Failed to install $Package (uv, exit code: $LASTEXITCODE)"
            Add-Failure -Manager "uv" -Package $Package
        }
    } catch {
        Write-ErrorLine "Failed to install $Package (uv): $_"
        Add-Failure -Manager "uv" -Package $Package
    }
}

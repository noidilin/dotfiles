function Write-InfoLine {
    param([string]$Message)
    Write-Host $Message -ForegroundColor White
}

function Write-SuccessLine {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Green
}

function Write-WarnLine {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Yellow
}

function Write-ErrorLine {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Red
}

function Write-SkipLine {
    param([string]$Message)
    Write-Host $Message -ForegroundColor DarkGray
}

function Assert-CommandOrExit {
    param(
        [string]$CommandName,
        [string]$ErrorMessage,
        [string]$HintMessage = ""
    )

    if (Get-Command $CommandName -ErrorAction SilentlyContinue) {
        return
    }

    Write-ErrorLine $ErrorMessage
    if ($HintMessage) {
        Write-InfoLine $HintMessage
    }
    exit 1
}

$script:MiseToolVersion = $null

function Assert-MiseToolOrSkip {
    param(
        [string]$Tool,
        [string]$MissingMiseMessage,
        [string]$MissingToolMessage
    )

    if (!(Get-Command mise -ErrorAction SilentlyContinue)) {
        Write-ErrorLine $MissingMiseMessage
        return $false
    }

    $versionOutput = mise exec -- $Tool --version 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $versionOutput) {
        Write-ErrorLine $MissingToolMessage
        return $false
    }

    $script:MiseToolVersion = $versionOutput
    return $true
}

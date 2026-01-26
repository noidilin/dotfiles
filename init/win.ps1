# Windows Bootstrap Script
# Execute via: irm https://raw.githubusercontent.com/noidilin/dotfiles/main/init/win.ps1 | iex

#Requires -Version 5.1

# Helper Functions
function Write-Step
{
  param([string]$Message)
  Write-Host "`n▶ $Message" -ForegroundColor White
}

function Write-Success
{
  param([string]$Message)
  Write-Host "  ✓ $Message" -ForegroundColor DarkGray
}

function Write-ErrorMsg
{
  param([string]$Message)
  Write-Host "  ✗ $Message" -ForegroundColor Red
}

function Stop-OnError
{
  param(
    [string]$Message,
    [string]$Hint = ""
  )
  Write-ErrorMsg $Message
  if ($Hint)
  {
    Write-Host "  Hint: $Hint" -ForegroundColor Yellow
  }
  exit 1
}

function Test-CommandExists
{
  param([string]$Command)
  $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

function Write-ManualStep
{
  param(
    [string]$Title,
    [string[]]$Instructions
  )
  Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Yellow
  Write-Host "  MANUAL STEP REQUIRED: $Title" -ForegroundColor Yellow
  Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow
  Write-Host ""
  foreach ($Instruction in $Instructions)
  {
    Write-Host $Instruction
  }
  Write-Host ""
  Read-Host "Press Enter when ready to continue"
}

function Get-UserConfirmation
{
  param([string]$Message)
  $response = Read-Host "$Message (y/n)"
  return $response -match '^[Yy]'
}

# Banner
Clear-Host
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor White
Write-Host "  Windows Bootstrap Script for Dotfiles" -ForegroundColor White
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor White
Write-Host ""
Write-Host "This script will automate the following:" -ForegroundColor DarkGray
Write-Host "  • Set execution policy" -ForegroundColor DarkGray
Write-Host "  • Install Scoop package manager" -ForegroundColor DarkGray
Write-Host "  • Add Scoop buckets (extras, nerd-fonts, wezterm-alt-icon)" -ForegroundColor DarkGray
Write-Host "  • Install bootstrap tools (chezmoi, age, gsudo)" -ForegroundColor DarkGray
Write-Host "  • Enable Developer Mode (via registry)" -ForegroundColor DarkGray
Write-Host "  • Install 1Password apps" -ForegroundColor DarkGray
Write-Host "  • Run chezmoi init with dotfiles repo" -ForegroundColor DarkGray
Write-Host "  • Download Rime language model (197MB, optional)" -ForegroundColor DarkGray
Write-Host ""

# Prerequisites Reminder
Write-ManualStep "Prerequisites Check" @(
  "Before continuing, please ensure you have:",
  "",
  "  ✓ Windows 10/11 with PowerShell 5.1+",
  "  ✓ Internet access and GitHub connectivity",
  "  ✓ Age passphrase ready (for decrypting chezmoi encrypted files)",
  "",
  "Note: Some steps will require manual configuration:",
  "  • 1Password sign-in and SSH agent setup",
  "  • Symlink privileges via secpol.msc"
)

# Step 1: Set Execution Policy
Write-Step "Setting execution policy to RemoteSigned..."
try
{
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction Stop
  Write-Success "Execution policy set to RemoteSigned"
} catch
{
  Stop-OnError "Failed to set execution policy" "You may need to run PowerShell as administrator"
}

# Step 2: Install Scoop
Write-Step "Installing Scoop package manager..."
if (Test-CommandExists "scoop")
{
  Write-Success "Scoop is already installed"
} else
{
  try
  {
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE)
    {
      Stop-OnError "Failed to install Scoop" "Check internet connection and try again"
    }
    Write-Success "Scoop installed successfully"
  } catch
  {
    Stop-OnError "Failed to install Scoop" "Error: $_"
  }
}

# Step 3: Install Git
Write-Step "Installing Git via Scoop..."
try
{
  scoop install git
  if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE)
  {
    Stop-OnError "Failed to install Git" "Scoop installation may be incomplete"
  }
  Write-Success "Git installed successfully"
} catch
{
  Stop-OnError "Failed to install Git" "Error: $_"
}

# Step 4: Add Scoop Buckets
Write-Step "Adding Scoop buckets..."

$buckets = @(
  @{Name = "extras"; Url = $null},
  @{Name = "nerd-fonts"; Url = $null},
  @{Name = "wezterm-alt-icon"; Url = "https://github.com/ocodo/wezterm-alt-windows-icon-builds.git"}
)

foreach ($bucket in $buckets)
{
  try
  {
    if ($bucket.Url)
    {
      scoop bucket add $bucket.Name $bucket.Url
    } else
    {
      scoop bucket add $bucket.Name
    }
    Write-Success "Bucket '$($bucket.Name)' added"
  } catch
  {
    # Scoop handles duplicate buckets gracefully, so we can continue
    Write-Success "Bucket '$($bucket.Name)' processed"
  }
}

# Step 5: Install Bootstrap Tools
Write-Step "Installing bootstrap tools..."
$tools = @("chezmoi", "age", "gsudo")

foreach ($tool in $tools)
{
  try
  {
    scoop install $tool
    if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE)
    {
      Stop-OnError "Failed to install $tool" "Check Scoop installation"
    }
    Write-Success "$tool installed successfully"
  } catch
  {
    Stop-OnError "Failed to install $tool" "Error: $_"
  }
}

# Step 6: Enable Developer Mode
Write-Step "Enabling Developer Mode via registry..."
try
{
  gsudo {
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowAllTrustedApps" /d "1" | Out-Null
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1" | Out-Null
  }
  if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE)
  {
    Stop-OnError "Failed to enable Developer Mode" "Registry modification failed"
  }
  Write-Success "Developer Mode enabled successfully"
} catch
{
  Stop-OnError "Failed to enable Developer Mode" "Error: $_"
}

# Step 7: Install 1Password
Write-Step "Installing 1Password apps..."

# Install/upgrade 1Password desktop app
try
{
  $desktopInstalled = winget list --id AgileBits.1Password --accept-source-agreements 2>$null | Select-String "AgileBits.1Password"
  if ($desktopInstalled)
  {
    Write-Success "1Password desktop app is already installed"
  } else
  {
    winget install --id AgileBits.1Password --silent --accept-source-agreements --accept-package-agreements
    if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq -1978335189)
    {
      Write-Success "1Password desktop app installed"
    } else
    {
      Stop-OnError "Failed to install 1Password desktop app" "WinGet exited with code $LASTEXITCODE"
    }
  }
} catch
{
  Stop-OnError "Failed to install 1Password desktop app" "Error: $_"
}

# Install/upgrade 1Password CLI
try
{
  $cliInstalled = winget list --id AgileBits.1Password.CLI --accept-source-agreements 2>$null | Select-String "AgileBits.1Password.CLI"
  if ($cliInstalled)
  {
    Write-Success "1Password CLI is already installed"
  } else
  {
    winget install --id AgileBits.1Password.CLI --silent --accept-source-agreements --accept-package-agreements
    if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq -1978335189)
    {
      Write-Success "1Password CLI installed"
    } else
    {
      Stop-OnError "Failed to install 1Password CLI" "WinGet exited with code $LASTEXITCODE"
    }
  }
} catch
{
  Stop-OnError "Failed to install 1Password CLI" "Error: $_"
}

# Step 8: Manual 1Password Configuration
Write-ManualStep "1Password Configuration" @(
  "1Password apps have been installed.",
  "Please complete these steps before continuing:",
  "",
  "  1. Launch 1Password desktop app",
  "  2. Sign in to your account",
  "  3. Go to Settings → Developer",
  "  4. Check 'Use the SSH agent'",
  "  5. Verify github-win key exists by running:",
  "     op item get `"github-win`" --fields `"public key`"",
  ""
)

# Step 9: Manual Symlink Privileges Configuration
Write-ManualStep "Symlink Privileges" @(
  "Developer Mode has been enabled via registry.",
  "Now you must grant symlink privileges:",
  "",
  "  1. Press Win+R and run: secpol.msc",
  "  2. Navigate to: Local Policies → User Rights Assignment → Create symbolic links",
  "  3. Click 'Add User or Group' → 'Object Types...'",
  "  4. Check 'Groups' option",
  "  5. Type 'Users', then press 'Check Names'",
  "  6. Click OK → Apply → OK",
  "  7. Sign out and sign back in (or reboot)",
  "",
  "After signing back in, verify with:",
  "  whoami /priv | Select-String CreateSymbolic",
  ""
)

# Step 10: Initialize Chezmoi Repository
Write-Step "Initializing chezmoi repository..."
Write-Host "  Using HTTPS URL for initial clone (SSH will work after dotfiles are applied)" -ForegroundColor DarkGray
Write-Host ""
try
{
  chezmoi init https://github.com/noidilin/dotfiles.git
  if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE)
  {
    Stop-OnError "Chezmoi init failed" "Check internet connection"
  }
  
  $chezmoiSrc = chezmoi source-path
  Write-Success "Repository cloned to $chezmoiSrc"
} catch
{
  Stop-OnError "Chezmoi init failed" "Error: $_"
}

# Step 11: Apply Dotfiles
Write-Step "Applying dotfiles..."
Write-Host "  Environment variables configured via chezmoi scriptEnv" -ForegroundColor DarkGray
Write-Host "  Mise-managed tools available via 'mise exec' in scripts" -ForegroundColor DarkGray
Write-Host ""

try
{
  chezmoi apply
  if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE)
  {
    Stop-OnError "Chezmoi apply failed" "Check your age passphrase and try again"
  }
  Write-Success "Dotfiles applied successfully"
} catch
{
  Stop-OnError "Chezmoi apply failed" "Error: $_"
}

# Step 12: Download Rime Language Model (Optional)
Write-Step "Setting up Rime language model..."
$RIME_DIR = Join-Path $env:USERPROFILE ".config\rime"
$GRAM_FILE = Join-Path $RIME_DIR "wanxiang-lts-zh-hans.gram"
$GRAM_URL = "https://github.com/amzxyz/RIME-LMDG/releases/download/LTS/wanxiang-lts-zh-hans.gram"

# Create directory if it doesn't exist
if (-not (Test-Path $RIME_DIR))
{
  New-Item -ItemType Directory -Path $RIME_DIR -Force | Out-Null
}

if (-not (Test-Path $GRAM_FILE))
{
  Write-Host "  The Wanxiang language model improves Chinese input accuracy (197MB download)" -ForegroundColor DarkGray
  if (Get-UserConfirmation "  Do you want to download the Rime language model now?")
  {
    Write-Host "  Downloading from GitHub..." -ForegroundColor DarkGray
    try
    {
      Invoke-WebRequest -Uri $GRAM_URL -OutFile $GRAM_FILE -UseBasicParsing
      Write-Success "Rime language model downloaded successfully"
    } catch
    {
      Write-ErrorMsg "Failed to download Rime language model: $_"
      Write-Host "  You can download it later manually from: $GRAM_URL" -ForegroundColor Yellow
    }
  } else
  {
    Write-Host "  Skipped. You can download it later from: $GRAM_URL" -ForegroundColor DarkGray
  }
} else
{
  Write-Success "Rime language model already exists"
}

# Final Summary
Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor White
Write-Host "  Bootstrap Complete!" -ForegroundColor White
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor White
Write-Host ""
Write-Host "Your dotfiles have been applied successfully." -ForegroundColor White
Write-Host ""
Write-Host "What happened:"
Write-Host "  ✓ Execution policy set to RemoteSigned" -ForegroundColor DarkGray
Write-Host "  ✓ Scoop package manager installed" -ForegroundColor DarkGray
Write-Host "  ✓ Scoop buckets added (extras, nerd-fonts, wezterm-alt-icon)" -ForegroundColor DarkGray
Write-Host "  ✓ Bootstrap tools installed (chezmoi, age, gsudo)" -ForegroundColor DarkGray
Write-Host "  ✓ Developer Mode enabled" -ForegroundColor DarkGray
Write-Host "  ✓ 1Password apps installed and configured" -ForegroundColor DarkGray
Write-Host "  ✓ Symlink privileges granted" -ForegroundColor DarkGray
Write-Host "  ✓ Rime language model setup completed" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Next steps:"
Write-Host "  • Restart PowerShell to load new configurations" -ForegroundColor DarkGray
Write-Host "  • Chezmoi will automatically run remaining setup scripts" -ForegroundColor DarkGray
Write-Host "  • Check ~/.config for your configurations" -ForegroundColor DarkGray
Write-Host ""

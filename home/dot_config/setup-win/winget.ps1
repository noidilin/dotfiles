Write-Host "starting winget.ps1 script..." -ForegroundColor White

$WINGET_GUI = @(
  # @{name = "Flow-Launcher.Flow-Launcher"}
  # @{name = "voidtools.Everything"}
  @{name = "Microsoft.PowerToys" }
  @{name = "glzr-io.glazewm" }
  @{name = "Rime.Weasel"}
  @{name = "dechamps.FlexASIO" }
  @{name = "CyberPowerSystemsInc.PowerPanelPersonal" }
  @{name = "SteelSeries.GG"}
  @{name = "Wacom.WacomTabletDriver"}
  # @{name = "Crucial.StorageExecutive"}
  # @{name = "lukehaas.RunJS" }
  @{name = "ogdesign.Eagle"}
  @{name = "WavesAudio.WavesCentral"}
  @{name = "Zen-Team.Zen-Browser.Optimized"}
)

Write-Host "installing winget apps..." -ForegroundColor Gray
Foreach ($app in $WINGET_GUI) {
  winget install --exact --silent --disable-interactivity --accept-source-agreements --accept-package-agreements --id $app.name
}

Write-Host "winget.ps1 script finished." -ForegroundColor Green

# BUG: this part didn't respond
<#
Foreach ($app in $WINGET_GUI) {
    $listApp = winget list --exact -q $app.name
    if (![String]::Join("", $listApp).Contains($app.name)) {
        Write-host "Installing: " $app.name
        winget install --exact --silent --disable-interactivity --accept-source-agreements --accept-package-agreements --id $app.name
    }
    else {
        Write-host "Skipping: " $app.name " (already installed)"
    }
}
#>

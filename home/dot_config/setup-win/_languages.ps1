Write-Host "starting languages.ps1 script..." -ForegroundColor White

$SCOOP_LANGUAGES = @(
  "main/mingw"
  "main/rustup-gnu"
  # "main/podman"
  # "main/docker"
  # "main/docker-compose"
)

Write-Host "installing programming languages with scoop..." -ForegroundColor Gray
scoop install $SCOOP_LANGUAGES

Write-Host "languages.ps1 script finished." -ForegroundColor Green

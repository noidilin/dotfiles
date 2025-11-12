Write-Host "starting scoop.ps1 script..." -ForegroundColor White

# NOTE: set up ssh private key before this
Write-Host "adding third-party scoop bucket..." -ForegroundColor Gray
# scoop bucket add custom git@github.com:noidilin/scoop.git
scoop bucket add wezterm-alt-icon git@github.com:noidilin/wezterm-alt-icon.git

$SCOOP_BASE = @(
  "main/7zip"
  "main/gzip"
  # "main/unar"
  "main/unrar"
  "main/unzip"
  "main/wget"
  "main/openssh"
)

$SCOOP_LANGUAGES = @(
  "main/mingw"
  "main/mise"
)

$SCOOP_FONT = @(
  "nerd-fonts/CommitMono-NF-Mono"
  "nerd-fonts/jf-open-huninn"
  "nerd-fonts/GlowSansTC-Compressed"
  "nerd-fonts/GlowSansTC-Condensed"
  "nerd-fonts/GlowSansTC-Extended"
  "nerd-fonts/GlowSansTC-Normal"
  "nerd-fonts/GlowSansTC-Wide"
  "nerd-fonts/Noto-CJK-Mega-OTC"
  "nerd-fonts/Noto-Serif-CJK-Super-OTC"
)

$SCOOP_EDITOR = @(
  "main/neovim"
  "wezterm-alt-icon/wezterm"
  "extras/vscode"
  "extras/zed"
)

$SCOOP_GUI = @(
  "extras/via"
  "extras/flow-launcher"
  "extras/blender-launcher"
  "extras/crystaldiskinfo"
  "extras/rufus"
  "extras/sharex"
  "extras/obs-studio"
  "extras/obsidian"
  "extras/potplayer"
  # "main/spicetify-cli" # tool for customizing the Spotify client.
  # "extras/spicetify-themes"
  # "extras/spotify"
)

$SCOOP_CLI = @(
  "extras/carapace-bin"
  # "extra/jqp" # TUI playground to experiment with jq
  "extras/lazygit"
  "extras/opencode"
  "extras/posh-git"
  "extras/psreadline"
  "extras/psfzf"
  "extras/sfsu"
  "extras/vcredist2022"
  # "main/podman"
  # "main/docker"
  # "main/docker-compose"
  "main/ast-grep"
  "main/bat"
  "main/bottom"
  "main/delta"
  "main/eza"
  "main/fastfetch"
  "main/fd"
  "main/ffmpeg"
  "main/fzf"
  "main/gh"
  # "main/glow" # terminal based markdown reader 
  "main/gpg"
  "main/grep"
  "main/gsudo"
  "main/imagemagick"
  # "main/jq" # command-line JSON processor
  "main/less"
  # "main/lazydocker"
  "main/pastel"
  "main/ripgrep"
  "main/sd" # sed alternative
  "main/sed" # sed (stream editor) is a non-interactive command-line text editor
  "main/starship"
  "main/tectonic" # modernized, complete, self-contained TeX/LaTeX engine, powered by XeTeX and TeXLive
  "main/vivid"
  # "main/xh" # friendly and fast tool for sending HTTP requests
  "main/yazi"
  # "main/yq" # a portable command-line YAML, JSON, XML, CSV, TOML and properties processor
  "main/zoxide"
  # "main/yt-dlp" # command-line audio/video downloader 
  # "main/rclone" # sync files and directories to and from multiple cloud / FTP / HTTP hosters.
)

<#
$SCOOP_OTHERS = @(
  # "main/uutils-coreutils" # rust implementation of GNU coreutils
  # "main/openssl" # TLS/SSL toolkit
  # "extras/putty" # implementation of SSH and Telnet, along with an xterm terminal emulator.
  # "extras/qbittorrent-enhanced" # reliable P2P Bittorent client.
  # "extras/v2rayn" # desktop proxy software for bypassing internet restrictions
  # "extras/winscp" # copy files between a local computer and remote servers using FTP, FTPS, SCP, SFTP, WebDAV or S3 file transfer protocols
  # "nonportable/winfsp-np" # set of software components that allows the creation of user mode file systems.
)
#>

Write-Host "installing basic apps with scoop..." -ForegroundColor Gray
scoop install $SCOOP_BASE
Write-Host "basic apps installation finished." -ForegroundColor White

Write-Host "installing programming languages with scoop..." -ForegroundColor Gray
scoop install $SCOOP_LANGUAGES
Write-Host "installing programming languages with mise..." -ForegroundColor Gray
mise install
Write-Host "programming languages installation finished." -ForegroundColor White

Write-Host "installing the rest of scoop apps..." -ForegroundColor Gray
scoop install $SCOOP_FONT
scoop install $SCOOP_EDITOR
scoop install $SCOOP_GUI
scoop install $SCOOP_CLI
# NOTE: can't add blank array to installation list
# scoop install $SCOOP_OTHERS

# NOTE: recently added, not tested yet
if (Get-Command -Name bat -ErrorAction SilentlyContinue) {
  Write-Host "building bat themes..." -ForegroundColor DarkGreen
  bat cache --build
} else {
  Write-Host "bat not installed, skip building Bat themes!" -ForegroundColor DarkGray
}

# allow long path: fix potential problem (suggestion from `scoop checkup`)
gsudo Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1

Write-Host "scoop.ps1 script finished." -ForegroundColor Green

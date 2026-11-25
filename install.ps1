# Install Neovim + LazyVim config from this repo on Windows.
# Run from the repo folder:  powershell -ExecutionPolicy Bypass -File .\install.ps1
# Safe to re-run. No admin needed (fonts install per user, config is a junction).
$ErrorActionPreference = "Stop"

$RepoDir    = $PSScriptRoot
$NvimSrc    = Join-Path $RepoDir "nvim"
$NvimTarget = Join-Path $env:LOCALAPPDATA "nvim"
$NvimData   = Join-Path $env:LOCALAPPDATA "nvim-data"
$Stamp      = Get-Date -Format "yyyyMMdd-HHmmss"

function Info($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Warn($msg) { Write-Host "warning: $msg" -ForegroundColor Yellow }

function Refresh-Path {
    $machine = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $user    = [Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machine;$user"
}

# 1. Packages
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "winget is required (App Installer from the Microsoft Store)."
}
$packages = @(
    "Neovim.Neovim",
    "Git.Git",
    "BurntSushi.ripgrep.MSVC",
    "sharkdp.fd",
    "OpenJS.NodeJS.LTS",
    "zig.zig",               # C compiler for treesitter parsers
    "JesseDuffield.lazygit"
)
foreach ($id in $packages) {
    Info "winget install $id"
    winget install --id $id -e --silent --accept-source-agreements --accept-package-agreements
    # winget returns non-zero when a package is already installed; not fatal
    if ($LASTEXITCODE -ne 0) { Warn "${id}: winget exit code $LASTEXITCODE (often means already installed)" }
}
Refresh-Path

# LazyVim needs Neovim >= 0.11.2
if (Get-Command nvim -ErrorAction SilentlyContinue) {
    $nvLine = & nvim --version | Select-Object -First 1
    if ($nvLine -match 'v(\d+\.\d+\.\d+)') {
        if ([version]$Matches[1] -lt [version]"0.11.2") {
            Warn "Neovim $($Matches[1]) is too old for LazyVim (needs 0.11.2+). Run: winget upgrade Neovim.Neovim"
        } else {
            Info "Neovim $($Matches[1])"
        }
    }
} else {
    Warn "nvim not found on PATH; open a new terminal after the script finishes"
}

# 2. tree-sitter CLI: not installed here, Mason installs it on first launch
#    (nvim/lua/plugins/treesitter.lua)

# 3. FiraCode Nerd Font (per-user install, no admin)
$UserFonts = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Fonts"
$RegPath   = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"
if (-not (Get-ChildItem $UserFonts -Filter "FiraCodeNerdFont*.ttf" -ErrorAction SilentlyContinue)) {
    Info "Installing FiraCode Nerd Font"
    $tmp = Join-Path $env:TEMP "FiraCode-NF-$Stamp"
    New-Item -ItemType Directory -Force -Path $tmp | Out-Null
    $zip = Join-Path $tmp "FiraCode.zip"
    Invoke-WebRequest -Uri "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip" -OutFile $zip
    Expand-Archive -Path $zip -DestinationPath $tmp -Force
    New-Item -ItemType Directory -Force -Path $UserFonts | Out-Null
    if (-not (Test-Path $RegPath)) { New-Item -Path $RegPath -Force | Out-Null }
    Get-ChildItem $tmp -Filter "*.ttf" | ForEach-Object {
        $dest = Join-Path $UserFonts $_.Name
        Copy-Item $_.FullName $dest -Force
        New-ItemProperty -Path $RegPath -Name "$($_.BaseName) (TrueType)" -Value $dest -PropertyType String -Force | Out-Null
    }
    Remove-Item $tmp -Recurse -Force
} else {
    Info "FiraCode Nerd Font already installed"
}

# 4. Link config
$item = Get-Item $NvimTarget -ErrorAction SilentlyContinue
if ($item -and $item.LinkType -eq "Junction" -and ($item.Target -contains $NvimSrc)) {
    Info "$NvimTarget already links to this repo"
} else {
    foreach ($p in @($NvimTarget, $NvimData)) {
        if (Test-Path $p) {
            Info "Backing up $p -> $p.bak-$Stamp"
            Rename-Item -Path $p -NewName "$(Split-Path $p -Leaf).bak-$Stamp"
        }
    }
    New-Item -ItemType Junction -Path $NvimTarget -Target $NvimSrc | Out-Null
    Info "Linked $NvimTarget -> $NvimSrc"
}

Write-Host ""
Info "Done. Next:"
Write-Host "  1. Windows Terminal: Settings > Profiles > Defaults > Appearance > Font face > FiraCode Nerd Font"
Write-Host "  2. Open a NEW terminal, run nvim, wait for plugins and :Mason, restart, then :checkhealth"
Write-Host "  3. Commit nvim\lazy-lock.json"

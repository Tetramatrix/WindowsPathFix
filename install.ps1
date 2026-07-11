# WindowsPathFix Installer
# Usage: Download and run, or copy files manually

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "  WindowsPathFix Installer" -ForegroundColor Cyan
Write-Host "  ─────────────────────────────────" -ForegroundColor DarkGray
Write-Host ""

# Find target directory from PSModulePath
$moduleRoots = $env:PSModulePath -split ';' | Where-Object { $_ -ne '' }
$targetDir = $null

foreach ($root in $moduleRoots) {
    if ($root -match 'Program Files|WINDOWS|system32') { continue }
    if (Test-Path $root) {
        $targetDir = Join-Path $root "WindowsPathFix"
        break
    }
}

if (-not $targetDir) {
    $targetDir = Join-Path ($moduleRoots | Select-Object -First 1) "WindowsPathFix"
}

# Create directory
if (!(Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

# Copy files from script location
$sourceDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$files = @("WindowsPathFix.psm1", "WindowsPathFix.psd1")
foreach ($file in $files) {
    $src = Join-Path $sourceDir $file
    $dst = Join-Path $targetDir $file
    if (Test-Path $src) {
        Copy-Item -Path $src -Destination $dst -Force
        Write-Host "  [OK] $file" -ForegroundColor Green
    } else {
        Write-Host "  [!] Not found: $file" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "  Installed to: $targetDir" -ForegroundColor Green
Write-Host ""
Write-Host "  Usage:" -ForegroundColor Cyan
Write-Host "    Import-Module WindowsPathFix" -ForegroundColor White
Write-Host ""

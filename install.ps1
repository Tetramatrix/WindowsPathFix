# One-line installer for WindowsPathFix
# Run in PowerShell: irm https://raw.githubusercontent.com/Tetramatrix/WindowsPathFix/main/Install.ps1 | iex

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "  WindowsPathFix - Installing..." -ForegroundColor Cyan
Write-Host ""

# Download module
$url = "https://raw.githubusercontent.com/Tetramatrix/WindowsPathFix/main/WindowsPathFix.psm1"
$manifestUrl = "https://raw.githubusercontent.com/Tetramatrix/WindowsPathFix/main/WindowsPathFix.psd1"

$installDir = "$env:USERPROFILE\Documents\PowerShell\Modules\WindowsPathFix"
if (!(Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
}

try {
    Invoke-WebRequest -Uri $url -OutFile "$installDir\WindowsPathFix.psm1" -UseBasicParsing
    Invoke-WebRequest -Uri $manifestUrl -OutFile "$installDir\WindowsPathFix.psd1" -UseBasicParsing
} catch {
    # Fallback: copy from local if available
    $localPath = Split-Path -Parent $MyInvocation.MyCommand.Path
    if (Test-Path "$localPath\WindowsPathFix.psm1") {
        Copy-Item "$localPath\WindowsPathFix.psm1" -Destination $installDir -Force
        Copy-Item "$localPath\WindowsPathFix.psd1" -Destination $installDir -Force
    } else {
        Write-Host "  Download failed. Install manually:" -ForegroundColor Red
        Write-Host "  Copy .psm1 and .psd1 to $installDir" -ForegroundColor Yellow
        exit 1
    }
}

# Import and enable
Import-Module WindowsPathFix -Force
Enable-LiteralPathDefault

# Add to profile
Install-AllFixes

Write-Host ""
Write-Host "  Done! Restart PowerShell to apply." -ForegroundColor Green
Write-Host ""
Write-Host "  Usage:" -ForegroundColor Cyan
Write-Host "    Import-Module WindowsPathFix" -ForegroundColor White
Write-Host "    Get-ShellInfo              # Check environment" -ForegroundColor White
Write-Host "    Disable-StorePython        # Fix Store issue (Admin)" -ForegroundColor White
Write-Host ""

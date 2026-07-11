#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Installs WindowsPathFix module system-wide.
.DESCRIPTION
    Copies the module to the PowerShell modules directory and enables LiteralPath by default.
.EXAMPLE
    .\install.ps1
#>

$moduleName = 'WindowsPathFix'
$moduleDir = "$env:ProgramFiles\WindowsPowerShell\Modules\$moduleName"

Write-Host "Installing $moduleName..." -ForegroundColor Cyan

# Create module directory
if (!(Test-Path $moduleDir)) {
    New-Item -ItemType Directory -Path $moduleDir -Force | Out-Null
}

# Copy module files
Copy-Item "$PSScriptRoot\*.psm1" -Destination $moduleDir -Force
Copy-Item "$PSScriptRoot\*.psd1" -Destination $moduleDir -Force

Write-Host "Module installed to: $moduleDir" -ForegroundColor Green

# Import and enable
Import-Module $moduleName -Force
Enable-LiteralPathDefault

Write-Host ""
Write-Host "Done! LiteralPath is now enabled for this session." -ForegroundColor Green
Write-Host "To make it permanent, run: Install-LiteralPathProfile" -ForegroundColor Cyan

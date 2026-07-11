#Requires -Version 5.1
<#
.SYNOPSIS
    Disables wildcard interpretation of brackets [ ] and other special characters in PowerShell paths.

.DESCRIPTION
    Sets $PSDefaultParameterValues to use -LiteralPath by default for all cmdlets that support it.
    This fixes issues where paths containing [ ], { }, ?, * break because PowerShell interprets
    them as wildcard characters.

    Common affected paths:
    - D:\...\__ [ Projects ] __\...
    - C:\Users\[username]\...
    - Any path with brackets, braces, or question marks

.EXAMPLE
    # Import the module
    Import-Module .\WindowsPathFix.psm1

    # Or install globally
    Install-Module -Name WindowsPathFix -Scope CurrentUser

.NOTES
    Author: Tetramatrix
    Version: 1.0.0
    Date: 2026-07-11
#>

function Enable-LiteralPathDefault {
    <#
    .SYNOPSIS
        Enables -LiteralPath as the default for all cmdlets.
    .DESCRIPTION
        Sets $PSDefaultParameterValues['*:LiteralPath'] = $true
        This makes all path parameters treat special characters as literals.
    #>
    [CmdletBinding()]
    param()

    $PSDefaultParameterValues['*:LiteralPath'] = $true
    Write-Host "LiteralPath default enabled." -ForegroundColor Green
    Write-Host "Paths with [ ], { }, ?, * will now be treated as literal characters." -ForegroundColor Cyan
}

function Disable-LiteralPathDefault {
    <#
    .SYNOPSIS
        Disables the -LiteralPath default (restores PowerShell wildcard behavior).
    #>
    [CmdletBinding()]
    param()

    $PSDefaultParameterValues.Remove('*:LiteralPath')
    Write-Host "LiteralPath default disabled." -ForegroundColor Yellow
    Write-Host "PowerShell wildcard behavior restored." -ForegroundColor Cyan
}

function Get-LiteralPathStatus {
    <#
    .SYNOPSIS
        Shows whether the LiteralPath default is currently enabled.
    #>
    [CmdletBinding()]
    param()

    if ($PSDefaultParameterValues['*:LiteralPath'] -eq $true) {
        Write-Host "Status: ENABLED" -ForegroundColor Green
        Write-Host "All cmdlets will use -LiteralPath by default." -ForegroundColor Cyan
    } else {
        Write-Host "Status: DISABLED" -ForegroundColor Yellow
        Write-Host "PowerShell wildcard behavior is active." -ForegroundColor Cyan
    }
}

function Install-LiteralPathProfile {
    <#
    .SYNOPSIS
        Adds the LiteralPath fix to your PowerShell profile permanently.
    .DESCRIPTION
        Appends the $PSDefaultParameterValues setting to your PowerShell profile
        so it loads automatically in every session.
    #>
    [CmdletBinding()]
    param()

    $profilePath = $PROFILE.CurrentUserAllHosts
    $marker = "# WindowsPathFix - Disable wildcards in paths"

    # Check if already installed
    if (Test-Path $profilePath) {
        $content = Get-Content $profilePath -Raw
        if ($content -match [regex]::Escape($marker)) {
            Write-Host "Already installed in profile: $profilePath" -ForegroundColor Yellow
            return
        }
    }

    # Create profile directory if needed
    $profileDir = Split-Path $profilePath -Parent
    if (!(Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }

    # Append to profile
    $entry = @"

# WindowsPathFix - Disable wildcards in paths
# See: https://github.com/Tetramatrix/WindowsPathFix
`$PSDefaultParameterValues['*:LiteralPath'] = `$true
"@

    Add-Content -Path $profilePath -Value $entry -Encoding UTF8
    Write-Host "Installed to profile: $profilePath" -ForegroundColor Green
    Write-Host "Restart PowerShell to apply." -ForegroundColor Cyan
}

function Uninstall-LiteralPathProfile {
    <#
    .SYNOPSIS
        Removes the LiteralPath fix from your PowerShell profile.
    #>
    [CmdletBinding()]
    param()

    $profilePath = $PROFILE.CurrentUserAllHosts

    if (!(Test-Path $profilePath)) {
        Write-Host "No profile found at: $profilePath" -ForegroundColor Yellow
        return
    }

    $content = Get-Content $profilePath -Raw
    $marker = "# WindowsPathFix - Disable wildcards in paths"

    if ($content -notmatch [regex]::Escape($marker)) {
        Write-Host "WindowsPathFix not found in profile." -ForegroundColor Yellow
        return
    }

    # Remove the marker and the line after it
    $lines = Get-Content $profilePath
    $newLines = @()
    $skipNext = $false

    foreach ($line in $lines) {
        if ($skipNext) {
            $skipNext = $false
            continue
        }
        if ($line -match [regex]::Escape($marker)) {
            $skipNext = $true
            continue
        }
        if ($line -match 'PSDefaultParameterValues.*LiteralPath') {
            continue
        }
        $newLines += $line
    }

    Set-Content -Path $profilePath -Value ($newLines -join "`n") -Encoding UTF8
    Write-Host "Removed from profile: $profilePath" -ForegroundColor Green
    Write-Host "Restart PowerShell to apply." -ForegroundColor Cyan
}

# Export functions
Export-ModuleMember -Function @(
    'Enable-LiteralPathDefault',
    'Disable-LiteralPathDefault',
    'Get-LiteralPathStatus',
    'Install-LiteralPathProfile',
    'Uninstall-LiteralPathProfile'
)

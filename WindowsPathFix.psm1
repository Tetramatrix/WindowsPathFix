#Requires -Version 5.1
<#
.SYNOPSIS
    Fixes common Windows issues for AI coding agents:
    - Disables wildcard interpretation of [ ] in paths
    - Removes Windows Store Python aliases that open Store instead of Python
    - Detects which shell is being used

.DESCRIPTION
    This module addresses two major pain points for AI agents on Windows:

    1. PATH FIX: PowerShell treats [ ] as wildcards, breaking paths like
       D:\...\__ [ Projects ] __\...
       Solution: $PSDefaultParameterValues['*:LiteralPath'] = $true

    2. PYTHON FIX: Windows Store aliases intercept 'python' command, opening Store
       Solution: Remove/disable the aliases in WindowsApps

.NOTES
    Author: Tetramatrix
    Version: 2.0.0
    Date: 2026-07-11
#>

# ============================================================================
# PATH FIX: LiteralPath Default
# ============================================================================

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
    Write-Host "[OK] LiteralPath default enabled." -ForegroundColor Green
    Write-Host "     Paths with [ ], { }, ?, * will now be treated as literal characters." -ForegroundColor Cyan
}

function Disable-LiteralPathDefault {
    <#
    .SYNOPSIS
        Disables the -LiteralPath default (restores PowerShell wildcard behavior).
    #>
    [CmdletBinding()]
    param()

    $PSDefaultParameterValues.Remove('*:LiteralPath')
    Write-Host "[OFF] LiteralPath default disabled." -ForegroundColor Yellow
    Write-Host "     PowerShell wildcard behavior restored." -ForegroundColor Cyan
}

function Get-LiteralPathStatus {
    <#
    .SYNOPSIS
        Shows whether the LiteralPath default is currently enabled.
    #>
    [CmdletBinding()]
    param()

    if ($PSDefaultParameterValues['*:LiteralPath'] -eq $true) {
        Write-Host "LiteralPath: ENABLED" -ForegroundColor Green
    } else {
        Write-Host "LiteralPath: DISABLED" -ForegroundColor Yellow
    }
}

# ============================================================================
# PYTHON FIX: Remove Windows Store Aliases
# ============================================================================

function Disable-StorePython {
    <#
    .SYNOPSIS
        Removes Windows Store Python aliases that open Store instead of Python.
    .DESCRIPTION
        Windows 10/11 installs "App Execution Aliases" for python.exe and python3.exe
        in WindowsApps. These intercept the 'python' command and open the Store.

        This function renames them to .bak to disable them.

        Requires Administrator privileges.
    .EXAMPLE
        Disable-StorePython
    #>
    [CmdletBinding()]
    param()

    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $isAdmin) {
        Write-Host "[WARN] Administrator privileges required. Run as Admin." -ForegroundColor Red
        return
    }

    $storePath = "$env:LOCALAPPDATA\Microsoft\WindowsApps"
    $aliases = @("python.exe", "python3.exe", "pip.exe", "pip3.exe")
    $fixed = 0

    foreach ($alias in $aliases) {
        $path = Join-Path $storePath $alias
        if (Test-Path $path) {
            $backup = "$path.bak"
            if (Test-Path $backup) {
                Write-Host "[SKIP] $alias (already disabled)" -ForegroundColor DarkGray
            } else {
                Rename-Item -Path $path -NewName "$alias.bak" -Force
                Write-Host "[FIXED] $alias -> $alias.bak" -ForegroundColor Green
                $fixed++
            }
        }
    }

    if ($fixed -eq 0) {
        Write-Host "[OK] No Store aliases found (already clean)" -ForegroundColor Green
    } else {
        Write-Host "[DONE] Disabled $fixed Store alias(es)" -ForegroundColor Green
        Write-Host "       Python will now use the real installation." -ForegroundColor Cyan
    }
}

function Enable-StorePython {
    <#
    .SYNOPSIS
        Restores Windows Store Python aliases.
    #>
    [CmdletBinding()]
    param()

    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $isAdmin) {
        Write-Host "[WARN] Administrator privileges required. Run as Admin." -ForegroundColor Red
        return
    }

    $storePath = "$env:LOCALAPPDATA\Microsoft\WindowsApps"
    $aliases = @("python.exe", "python3.exe", "pip.exe", "pip3.exe")

    foreach ($alias in $aliases) {
        $path = Join-Path $storePath $alias
        $backup = "$path.bak"
        if (Test-Path $backup) {
            Rename-Item -Path $backup -NewName $alias -Force
            Write-Host "[RESTORED] $alias.bak -> $alias" -ForegroundColor Green
        }
    }
}

function Get-StorePythonStatus {
    <#
    .SYNOPSIS
        Shows whether Windows Store Python aliases are active.
    #>
    [CmdletBinding()]
    param()

    $storePath = "$env:LOCALAPPDATA\Microsoft\WindowsApps"
    $aliases = @("python.exe", "python3.exe", "pip.exe", "pip3.exe")

    Write-Host "Windows Store Python Aliases:" -ForegroundColor Cyan
    foreach ($alias in $aliases) {
        $path = Join-Path $storePath $alias
        $backup = "$path.bak"
        if (Test-Path $path) {
            Write-Host "  $alias : ACTIVE (may open Store)" -ForegroundColor Red
        } elseif (Test-Path $backup) {
            Write-Host "  $alias : DISABLED (renamed to .bak)" -ForegroundColor Green
        } else {
            Write-Host "  $alias : NOT FOUND" -ForegroundColor DarkGray
        }
    }
}

# ============================================================================
# SHELL DETECTION
# ============================================================================

function Get-ShellInfo {
    <#
    .SYNOPSIS
        Detects which shell/terminal is currently being used.
    .DESCRIPTION
        Returns information about the current shell environment.
        Useful for agents that need to know which shell they're in.
    #>
    [CmdletBinding()]
    param()

    $info = [ordered]@{
        Shell = "Unknown"
        Version = $PSVersionTable.PSVersion.ToString()
        Edition = $PSVersionTable.PSEdition
        Platform = if ($PSVersionTable.Platform) { $PSVersionTable.Platform } else { "Windows" }
        IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        LiteralPathEnabled = $PSDefaultParameterValues['*:LiteralPath'] -eq $true
    }

    # Detect specific shell
    if ($env:WT_SESSION) {
        $info.Shell = "Windows Terminal"
    } elseif ($env:TERM_PROGRAM -eq "mintty" -or $env:MSYSTEM) {
        $info.Shell = "Git Bash"
    } elseif ($PSVersionTable.PSEdition -eq "Core") {
        $info.Shell = "PowerShell 7+"
    } elseif ($PSVersionTable.PSEdition -eq "Desktop") {
        $info.Shell = "PowerShell 5.1"
    }

    # Show info
    Write-Host "Shell Environment:" -ForegroundColor Cyan
    foreach ($key in $info.Keys) {
        $value = $info[$key]
        $color = switch ($key) {
            "LiteralPathEnabled" { if ($value) { "Green" } else { "Yellow" } }
            "IsAdmin" { if ($value) { "Green" } else { "Yellow" } }
            default { "White" }
        }
        Write-Host ("  {0,-22} {1}" -f "$key", $value) -ForegroundColor $color
    }
}

# ============================================================================
# PROFILE INTEGRATION
# ============================================================================

function Install-AllFixes {
    <#
    .SYNOPSIS
        Installs all fixes: LiteralPath + Store Python + profile integration.
    .DESCRIPTION
        Detects your existing profile and adds the necessary settings.
    #>
    [CmdletBinding()]
    param()

    # Enable LiteralPath for current session
    Enable-LiteralPathDefault

    # Add to profile
    $profilePath = Get-ProfilePath
    if ($profilePath) {
        $marker = "# WindowsPathFix"
        if (Test-Path $profilePath) {
            $content = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
            if ($content -and $content -match [regex]::Escape($marker)) {
                Write-Host "[SKIP] Already in profile: $profilePath" -ForegroundColor Yellow
            } else {
                Add-ToProfile -Path $profilePath
            }
        } else {
            Add-ToProfile -Path $profilePath
        }
    }

    # Check Store Python
    $storePath = "$env:LOCALAPPDATA\Microsoft\WindowsApps"
    $hasStore = Test-Path (Join-Path $storePath "python.exe")
    if ($hasStore) {
        Write-Host ""
        Write-Host "[!] Windows Store Python aliases detected." -ForegroundColor Yellow
        Write-Host "    Run 'Disable-StorePython' as Admin to fix." -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "Done! Restart PowerShell to apply all fixes." -ForegroundColor Green
}

function Get-ProfilePath {
    <#
    .SYNOPSIS
        Detects the actual PowerShell profile path being used.
    #>
    [CmdletBinding()]
    param()

    # Check standard locations
    $candidates = @(
        $PROFILE.CurrentUserAllHosts,
        $PROFILE.CurrentUserCurrentHost,
        "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1",
        "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1",
        "$env:USERPROFILE\PowerShell\profile.ps1"
    )

    foreach ($path in $candidates) {
        if ($path -and (Test-Path $path)) {
            return $path
        }
    }

    # Return default if none found
    return $PROFILE.CurrentUserAllHosts
}

function Add-ToProfile {
    <#
    .SYNOPSIS
        Adds WindowsPathFix settings to a profile file.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $entry = @"

# === WindowsPathFix (auto-added) ===
# Disables [ ] wildcards in paths - see: https://github.com/Tetramatrix/WindowsPathFix
`$PSDefaultParameterValues['*:LiteralPath'] = `$true
# === End WindowsPathFix ===
"@

    # Create directory if needed
    $dir = Split-Path $Path -Parent
    if ($dir -and !(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    Add-Content -Path $Path -Value $entry -Encoding UTF8
    Write-Host "[OK] Added to profile: $Path" -ForegroundColor Green
}

# ============================================================================
# QUICK ALIASES (like lcd, lls in the existing profile)
# ============================================================================

# These complement the existing lcd/lls/lgi/ltest functions
function lcat { param([Parameter(Mandatory = $true)][string]$Path); Get-Content -LiteralPath $Path }
function lni { param([Parameter(Mandatory = $true)][string]$Path); New-Item -LiteralPath $Path }
function lrm { param([Parameter(Mandatory = $true)][string]$Path); Remove-Item -LiteralPath $Path }
function lcp { param([Parameter(Mandatory = $true)][string]$Source, [Parameter(Mandatory = $true)][string]$Dest); Copy-Item -LiteralPath $Source -Destination $Dest }
function lmv { param([Parameter(Mandatory = $true)][string]$Source, [Parameter(Mandatory = $true)][string]$Dest); Move-Item -LiteralPath $Source -Destination $Dest }

# ============================================================================
# EXPORTS
# ============================================================================

Export-ModuleMember -Function @(
    # Path fix
    'Enable-LiteralPathDefault',
    'Disable-LiteralPathDefault',
    'Get-LiteralPathStatus',
    # Python Store fix
    'Disable-StorePython',
    'Enable-StorePython',
    'Get-StorePythonStatus',
    # Shell detection
    'Get-ShellInfo',
    # Profile integration
    'Install-AllFixes',
    'Get-ProfilePath',
    # Quick aliases
    'lcat', 'lni', 'lrm', 'lcp', 'lmv'
)

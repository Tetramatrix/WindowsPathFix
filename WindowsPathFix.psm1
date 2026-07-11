#Requires -Version 5.1
<#
.SYNOPSIS
    Fixes common Windows issues for AI coding agents — automatically.

.DESCRIPTION
    Import this module and ALL of these are fixed automatically:

    1. PATH FIX: [ ] brackets no longer break PowerShell paths
    2. PYTHON FIX: Store aliases removed (if Admin)
    3. ENCODING: Console set to UTF-8
    4. GIT: autocrlf and longpaths configured
    5. EXECUTION POLICY: Set to RemoteSigned for current user
    6. PATH CLEANUP: Remove duplicate entries

    Just import and everything works.

.NOTES
    Author: Tetramatrix
    Version: 3.1.0
    Date: 2026-07-11
#>

# ============================================================================
# AUTO-INSTALL: Detect correct modules path and install
# ============================================================================

function Install-WindowsPathFix {
    <#
    .SYNOPSIS
        Installs WindowsPathFix to the correct PowerShell modules directory.
    .DESCRIPTION
        Auto-detects where PowerShell looks for modules and copies files there.
        Works even if Documents folder is in a non-standard location.
    .EXAMPLE
        Install-WindowsPathFix
    #>
    [CmdletBinding()]
    param()

    # Find the correct modules path from PSModulePath
    $moduleRoots = $env:PSModulePath -split ';' | Where-Object { $_ -ne '' }
    $targetDir = $null

    # Look for a user-writable modules directory
    foreach ($root in $moduleRoots) {
        # Skip system directories (need Admin)
        if ($root -match 'Program Files|WINDOWS|system32') { continue }
        # Check if we can write here
        if (Test-Path $root) {
            $targetDir = Join-Path $root "WindowsPathFix"
            break
        }
    }

    # Fallback: use first entry
    if (-not $targetDir) {
        $targetDir = Join-Path ($moduleRoots | Select-Object -First 1) "WindowsPathFix"
    }

    Write-Host "Installing to: $targetDir" -ForegroundColor Cyan

    # Create directory
    if (!(Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }

    # Find source (where this .psm1 file is)
    $sourceDir = Split-Path -Parent $PSCommandPath
    if (-not $sourceDir) { $sourceDir = Split-Path -Parent (Get-Module WindowsPathFix).Path }

    # Copy files
    $files = @("WindowsPathFix.psm1", "WindowsPathFix.psd1")
    foreach ($file in $files) {
        $src = Join-Path $sourceDir $file
        $dst = Join-Path $targetDir $file
        if (Test-Path $src) {
            Copy-Item -Path $src -Destination $dst -Force
            Write-Host "[OK] $file" -ForegroundColor Green
        } else {
            Write-Host "[WARN] Source not found: $src" -ForegroundColor Yellow
        }
    }

    # Verify
    if (Test-Path (Join-Path $targetDir "WindowsPathFix.psm1")) {
        Write-Host ""
        Write-Host "[DONE] Installed to: $targetDir" -ForegroundColor Green
        Write-Host "       Run: Import-Module WindowsPathFix" -ForegroundColor Cyan
    } else {
        Write-Host "[ERROR] Installation failed" -ForegroundColor Red
    }
}

function Get-ModuleInstallPath {
    <#
    .SYNOPSIS
        Shows where WindowsPathFix should be installed.
    #>
    [CmdletBinding()]
    param()

    $moduleRoots = $env:PSModulePath -split ';' | Where-Object { $_ -ne '' }

    Write-Host "PowerShell Module Paths:" -ForegroundColor Cyan
    foreach ($root in $moduleRoots) {
        $isSystem = $root -match 'Program Files|WINDOWS|system32'
        $exists = Test-Path $root
        $marker = if ($isSystem) { "[system]" } else { "[user]" }
        $color = if ($isSystem) { "Yellow" } elseif ($exists) { "Green" } else { "Red" }
        Write-Host "  $marker $root" -ForegroundColor $color
    }

    $writable = $moduleRoots | Where-Object { $_ -notmatch 'Program Files|WINDOWS|system32' } | Select-Object -First 1
    Write-Host ""
    Write-Host "Recommended: $writable\WindowsPathFix" -ForegroundColor Green
}

# ============================================================================
# AUTO-FIX: Runs on module import
# ============================================================================

function Initialize-WindowsFixes {
    <#
    .SYNOPSIS
        Applies all Windows fixes automatically.
    .DESCRIPTION
        Called when module is imported. Fixes everything without user action.
    #>
    [CmdletBinding()]
    param(
        [switch]$Quiet
    )

    $fixed = 0

    # 1. LiteralPath (always works, no Admin needed)
    if ($PSDefaultParameterValues['*:LiteralPath'] -ne $true) {
        $PSDefaultParameterValues['*:LiteralPath'] = $true
        if (-not $Quiet) { Write-Host "[FIXED] LiteralPath default enabled" -ForegroundColor Green }
        $fixed++
    }

    # 2. UTF-8 Console Encoding
    try {
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
        [Console]::InputEncoding = [System.Text.Encoding]::UTF8
        $OutputEncoding = [System.Text.Encoding]::UTF8
        if (-not $Quiet) { Write-Host "[FIXED] Console encoding set to UTF-8" -ForegroundColor Green }
        $fixed++
    } catch {
        if (-not $Quiet) { Write-Host "[WARN] Could not set UTF-8 encoding" -ForegroundColor Yellow }
    }

    # 3. Git Config (if git is available)
    if (Get-Command git -ErrorAction SilentlyContinue) {
        # autocrlf
        $current = & git config --global core.autocrlf 2>$null
        if ($current -ne "true") {
            & git config --global core.autocrlf true 2>$null
            if (-not $Quiet) { Write-Host "[FIXED] git config core.autocrlf = true" -ForegroundColor Green }
            $fixed++
        }

        # longpaths
        $longpaths = & git config --global core.longpaths 2>$null
        if ($longpaths -ne "true") {
            & git config --global core.longpaths true 2>$null
            if (-not $Quiet) { Write-Host "[FIXED] git config core.longpaths = true" -ForegroundColor Green }
            $fixed++
        }
    }

    # 4. Execution Policy (current user only, no Admin needed)
    try {
        $policy = Get-ExecutionPolicy -Scope CurrentUser
        if ($policy -eq "Restricted" -or $policy -eq "AllSigned") {
            Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force -ErrorAction SilentlyContinue
            if (-not $Quiet) { Write-Host "[FIXED] ExecutionPolicy set to RemoteSigned (CurrentUser)" -ForegroundColor Green }
            $fixed++
        }
    } catch {
        # Silently skip if can't change
    }

    # 5. Store Python Aliases (needs Admin)
    $storePath = "$env:LOCALAPPDATA\Microsoft\WindowsApps"
    $pythonAlias = Join-Path $storePath "python.exe"
    if (Test-Path $pythonAlias) {
        $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if ($isAdmin) {
            $backup = "$pythonAlias.bak"
            if (-not (Test-Path $backup)) {
                Rename-Item -Path $pythonAlias -NewName "python.exe.bak" -Force -ErrorAction SilentlyContinue
                Rename-Item -Path (Join-Path $storePath "python3.exe") -NewName "python3.exe.bak" -Force -ErrorAction SilentlyContinue
                if (-not $Quiet) { Write-Host "[FIXED] Store Python aliases disabled" -ForegroundColor Green }
                $fixed++
            }
        } elseif (-not $Quiet) {
            Write-Host "[INFO] Store Python aliases found (run as Admin to fix)" -ForegroundColor Yellow
        }
    }

    # 6. PATH cleanup (remove duplicates)
    $paths = $env:PATH -split ';' | Where-Object { $_ -ne '' } | Select-Object -Unique
    $newPath = $paths -join ';'
    if ($newPath -ne $env:PATH) {
        $env:PATH = $newPath
        if (-not $Quiet) { Write-Host "[FIXED] PATH duplicates removed" -ForegroundColor Green }
        $fixed++
    }

    if (-not $Quiet -and $fixed -gt 0) {
        Write-Host ""
        Write-Host "[DONE] Applied $fixed fix(es)" -ForegroundColor Green
    }

    return $fixed
}

# ============================================================================
# PATH FIX: LiteralPath Default
# ============================================================================

function Enable-LiteralPathDefault {
    $PSDefaultParameterValues['*:LiteralPath'] = $true
    Write-Host "[OK] LiteralPath default enabled." -ForegroundColor Green
}

function Disable-LiteralPathDefault {
    $PSDefaultParameterValues.Remove('*:LiteralPath')
    Write-Host "[OFF] LiteralPath default disabled." -ForegroundColor Yellow
}

function Get-LiteralPathStatus {
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
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Host "[WARN] Administrator privileges required." -ForegroundColor Red
        return
    }

    $storePath = "$env:LOCALAPPDATA\Microsoft\WindowsApps"
    $aliases = @("python.exe", "python3.exe", "pip.exe", "pip3.exe")
    $fixed = 0

    foreach ($alias in $aliases) {
        $path = Join-Path $storePath $alias
        $backup = "$path.bak"
        if ((Test-Path $path) -and -not (Test-Path $backup)) {
            Rename-Item -Path $path -NewName "$alias.bak" -Force
            Write-Host "[FIXED] $alias -> $alias.bak" -ForegroundColor Green
            $fixed++
        }
    }

    if ($fixed -eq 0) {
        Write-Host "[OK] No Store aliases to fix" -ForegroundColor Green
    }
}

function Enable-StorePython {
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Host "[WARN] Administrator privileges required." -ForegroundColor Red
        return
    }

    $storePath = "$env:LOCALAPPDATA\Microsoft\WindowsApps"
    @("python.exe", "python3.exe", "pip.exe", "pip3.exe") | ForEach-Object {
        $backup = Join-Path $storePath "$_.bak"
        if (Test-Path $backup) {
            Rename-Item -Path $backup -NewName $_ -Force
            Write-Host "[RESTORED] $_" -ForegroundColor Green
        }
    }
}

function Get-StorePythonStatus {
    $storePath = "$env:LOCALAPPDATA\Microsoft\WindowsApps"
    @("python.exe", "python3.exe") | ForEach-Object {
        $path = Join-Path $storePath $_
        $backup = "$path.bak"
        if (Test-Path $path) {
            Write-Host "  $_ : ACTIVE (may open Store)" -ForegroundColor Red
        } elseif (Test-Path $backup) {
            Write-Host "  $_ : DISABLED" -ForegroundColor Green
        } else {
            Write-Host "  $_ : NOT FOUND" -ForegroundColor DarkGray
        }
    }
}

# ============================================================================
# SHELL DETECTION
# ============================================================================

function Get-ShellInfo {
    $info = [ordered]@{
        Shell = "Unknown"
        Version = $PSVersionTable.PSVersion.ToString()
        Edition = $PSVersionTable.PSEdition
        Platform = if ($PSVersionTable.Platform) { $PSVersionTable.Platform } else { "Windows" }
        IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        LiteralPathEnabled = $PSDefaultParameterValues['*:LiteralPath'] -eq $true
    }

    if ($env:WT_SESSION) { $info.Shell = "Windows Terminal" }
    elseif ($env:TERM_PROGRAM -eq "mintty" -or $env:MSYSTEM) { $info.Shell = "Git Bash" }
    elseif ($PSVersionTable.PSEdition -eq "Core") { $info.Shell = "PowerShell 7+" }
    elseif ($PSVersionTable.PSEdition -eq "Desktop") { $info.Shell = "PowerShell 5.1" }

    Write-Host "Shell Environment:" -ForegroundColor Cyan
    foreach ($key in $info.Keys) {
        $color = switch ($key) {
            "LiteralPathEnabled" { if ($info[$key]) { "Green" } else { "Yellow" } }
            "IsAdmin" { if ($info[$key]) { "Green" } else { "Yellow" } }
            default { "White" }
        }
        Write-Host ("  {0,-22} {1}" -f $key, $info[$key]) -ForegroundColor $color
    }
}

# ============================================================================
# PROFILE INTEGRATION
# ============================================================================

function Install-AllFixes {
    Initialize-WindowsFixes

    $profilePath = Get-ProfilePath
    $marker = "# WindowsPathFix"

    if (Test-Path $profilePath) {
        $content = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
        if ($content -and $content -match [regex]::Escape($marker)) {
            Write-Host "[SKIP] Already in profile" -ForegroundColor Yellow
        } else {
            Add-ToProfile -Path $profilePath
        }
    } else {
        Add-ToProfile -Path $profilePath
    }

    Write-Host ""
    Write-Host "Restart PowerShell to apply all fixes." -ForegroundColor Cyan
}

function Get-ProfilePath {
    $candidates = @(
        $PROFILE.CurrentUserAllHosts,
        $PROFILE.CurrentUserCurrentHost,
        "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1",
        "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1",
        "$env:USERPROFILE\PowerShell\profile.ps1"
    )

    foreach ($path in $candidates) {
        if ($path -and (Test-Path $path)) { return $path }
    }

    return $PROFILE.CurrentUserAllHosts
}

function Add-ToProfile {
    param([string]$Path)

    $entry = @"

# === WindowsPathFix (auto-added) ===
`$PSDefaultParameterValues['*:LiteralPath'] = `$true
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
# === End WindowsPathFix ===
"@

    $dir = Split-Path $Path -Parent
    if ($dir -and !(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    Add-Content -Path $Path -Value $entry -Encoding UTF8
    Write-Host "[OK] Added to profile: $Path" -ForegroundColor Green
}

# ============================================================================
# QUICK ALIASES
# ============================================================================

function lcat { param([Parameter(Mandatory)][string]$Path); Get-Content -LiteralPath $Path }
function lni { param([Parameter(Mandatory)][string]$Path); New-Item -LiteralPath $Path }
function lrm { param([Parameter(Mandatory)][string]$Path); Remove-Item -LiteralPath $Path }
function lcp { param([Parameter(Mandatory)][string]$Source, [Parameter(Mandatory)][string]$Dest); Copy-Item -LiteralPath $Source -Destination $Dest }
function lmv { param([Parameter(Mandatory)][string]$Source, [Parameter(Mandatory)][string]$Dest); Move-Item -LiteralPath $Source -Destination $Dest }

# ============================================================================
# EXPORTS
# ============================================================================

Export-ModuleMember -Function @(
    'Install-WindowsPathFix',
    'Get-ModuleInstallPath',
    'Initialize-WindowsFixes',
    'Enable-LiteralPathDefault',
    'Disable-LiteralPathDefault',
    'Get-LiteralPathStatus',
    'Disable-StorePython',
    'Enable-StorePython',
    'Get-StorePythonStatus',
    'Get-ShellInfo',
    'Install-AllFixes',
    'Get-ProfilePath',
    'lcat', 'lni', 'lrm', 'lcp', 'lmv'
)

# ============================================================================
# AUTO-RUN ON IMPORT
# ============================================================================

Initialize-WindowsFixes -Quiet

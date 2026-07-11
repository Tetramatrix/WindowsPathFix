@{
    RootModule        = 'WindowsPathFix.psm1'
    ModuleVersion     = '3.2.0'
    GUID              = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
    Author            = 'Tetramatrix'
    CompanyName       = 'Tetramatrix'
    Copyright         = '(c) 2026 Tetramatrix. MIT License.'
    Description       = 'Fixes common Windows issues for AI coding agents automatically on import: paths, Store Python, UTF-8, git config, execution policy, safe execution helpers.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
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
        'lcat', 'lni', 'lrm', 'lcp', 'lmv',
        # Safe execution helpers
        'Invoke-Safe',
        'Invoke-PythonSafe',
        'New-TempFile',
        'Get-SafePath',
        'Test-PathSafe'
    )
    CmdletsToExport   = @()
    VariablesToExport  = @()
    AliasesToExport    = @()
    PrivateData = @{
        PSData = @{
            Tags       = @('Path', 'LiteralPath', 'Wildcard', 'Windows', 'PowerShell', 'Python', 'UTF-8', 'Git', 'Fix', 'AI', 'Agent', 'Safe')
            LicenseUri = 'https://opensource.org/licenses/MIT'
            ProjectUri = 'https://github.com/Tetramatrix/WindowsPathFix'
        }
    }
}

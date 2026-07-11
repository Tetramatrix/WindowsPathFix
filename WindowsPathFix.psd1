@{
    RootModule        = 'WindowsPathFix.psm1'
    ModuleVersion     = '2.0.0'
    GUID              = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
    Author            = 'Tetramatrix'
    CompanyName       = 'Tetramatrix'
    Copyright         = '(c) 2026 Tetramatrix. MIT License.'
    Description       = 'Fixes common Windows issues for AI coding agents: disables [ ] wildcards in paths, removes Store Python aliases, detects shell environment.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
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
    CmdletsToExport   = @()
    VariablesToExport  = @()
    AliasesToExport    = @()
    PrivateData = @{
        PSData = @{
            Tags       = @('Path', 'LiteralPath', 'Wildcard', 'Windows', 'PowerShell', 'Python', 'Store', 'Fix', 'AI', 'Agent')
            LicenseUri = 'https://opensource.org/licenses/MIT'
            ProjectUri = 'https://github.com/Tetramatrix/WindowsPathFix'
        }
    }
}

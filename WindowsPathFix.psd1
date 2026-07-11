@{
    RootModule        = 'WindowsPathFix.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
    Author            = 'Tetramatrix'
    CompanyName       = 'Tetramatrix'
    Copyright         = '(c) 2026 Tetramatrix. MIT License.'
    Description       = 'Disables wildcard interpretation of brackets and special characters in PowerShell paths by enabling -LiteralPath as the default.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Enable-LiteralPathDefault',
        'Disable-LiteralPathDefault',
        'Get-LiteralPathStatus',
        'Install-LiteralPathProfile',
        'Uninstall-LiteralPathProfile'
    )
    CmdletsToExport   = @()
    VariablesToExport  = @()
    AliasesToExport    = @()
    PrivateData = @{
        PSData = @{
            Tags       = @('Path', 'LiteralPath', 'Wildcard', 'Windows', 'PowerShell', 'Fix')
            LicenseUri = 'https://opensource.org/licenses/MIT'
            ProjectUri = 'https://github.com/Tetramatrix/WindowsPathFix'
        }
    }
}

# WindowsPathFix

Disables wildcard interpretation of `[ ]`, `{ }`, `?`, `*` in PowerShell paths.

## The Problem

PowerShell treats `[ ]` as wildcard characters:

```powershell
# This BREAKS with bracketed paths:
Get-ChildItem "D:\...\__ [ Projects ] __\..."
# → Interprets [ P ] as wildcard matching P

# This WORKS:
Get-ChildItem -LiteralPath "D:\...\__ [ Projects ] __\..."
# → Treats [ ] as literal characters
```

This causes issues for AI coding agents, automation scripts, and anyone with brackets in their paths.

## The Fix

```powershell
$PSDefaultParameterValues['*:LiteralPath'] = $true
```

This makes `-LiteralPath` the default for ALL cmdlets that support it.

## Installation

### Option 1: Import for current session

```powershell
Import-Module .\WindowsPathFix.psm1
Enable-LiteralPathDefault
```

### Option 2: Install permanently to profile

```powershell
Import-Module .\WindowsPathFix.psm1
Install-LiteralPathProfile
# Restart PowerShell to apply
```

### Option 3: Install system-wide (requires admin)

```powershell
.\install.ps1
```

## Commands

| Command | Description |
|---------|-------------|
| `Enable-LiteralPathDefault` | Enable LiteralPath for current session |
| `Disable-LiteralPathDefault` | Disable (restore wildcard behavior) |
| `Get-LiteralPathStatus` | Check if enabled |
| `Install-LiteralPathProfile` | Add to PowerShell profile permanently |
| `Uninstall-LiteralPathProfile` | Remove from profile |

## What This Fixes

- Paths with `[ ]` brackets (e.g., `__ [ Projects ] __`)
- Paths with `{ }` braces
- Paths with `?` question marks
- Paths with `*` asterisks
- Any path that PowerShell misinterprets as a wildcard pattern

## Compatibility

- PowerShell 5.1+
- PowerShell 7+
- Windows, macOS, Linux

## License

MIT

# WindowsPathFix

Fixes common Windows issues for AI coding agents.

## Problems Solved

### 1. Path Brackets Break PowerShell

```powershell
# BREAKS:
Get-ChildItem "D:\...\__ [ Projects ] __\..."
# PowerShell interprets [ P ] as wildcard

# WORKS after fix:
Get-ChildItem "D:\...\__ [ Projects ] __\..."
# Treated as literal characters
```

### 2. Windows Store Opens Instead of Python

```cmd
# BREAKS:
C:\> python
# Opens Microsoft Store instead of running Python

# WORKS after fix:
C:\> python
# Runs actual Python installation
```

## Quick Start

```powershell
# Import the module
Import-Module .\WindowsPathFix.psm1

# Install all fixes (adds to profile permanently)
Install-AllFixes
```

## Commands

| Command | Description |
|---------|-------------|
| **Path Fix** | |
| `Enable-LiteralPathDefault` | Enable for current session |
| `Disable-LiteralPathDefault` | Disable (restore wildcards) |
| `Get-LiteralPathStatus` | Check if enabled |
| **Python Store Fix** | |
| `Disable-StorePython` | Remove Store aliases (requires Admin) |
| `Enable-StorePython` | Restore Store aliases |
| `Get-StorePythonStatus` | Check alias status |
| **Info** | |
| `Get-ShellInfo` | Detect current shell |
| `Install-AllFixes` | Install everything + add to profile |
| **Quick Aliases** | |
| `lcat` | `Get-Content -LiteralPath` |
| `lni` | `New-Item -LiteralPath` |
| `lrm` | `Remove-Item -LiteralPath` |
| `lcp` | `Copy-Item -LiteralPath` |
| `lmv` | `Move-Item -LiteralPath` |

## Integration with Existing Profiles

The module detects your existing profile and adds settings without overwriting:

```powershell
# Your existing profile (e.g., D:\...\PowerShell\profile.ps1)
# WindowsPathFix adds at the end:
# === WindowsPathFix (auto-added) ===
# $PSDefaultParameterValues['*:LiteralPath'] = $true
# === End WindowsPathFix ===
```

## For AI Agents (agents.md)

Add to your agents.md:

```markdown
# Windows Environment

When on Windows, import WindowsPathFix:
\`\`\`powershell
Import-Module WindowsPathFix
Enable-LiteralPathDefault
\`\`\`

This disables [ ] wildcards in PowerShell paths.
```

## Compatibility

- PowerShell 5.1+
- PowerShell 7+
- Windows 10/11

## License

MIT

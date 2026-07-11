# WindowsPathFix

**Fixes the two most annoying Windows issues for AI coding agents.**

![Version](https://img.shields.io/badge/version-2.0.0-blue)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Windows-lightgrey)

---

## What It Fixes

### Problem 1: `[ ]` in Paths Break PowerShell

```
D:\Benutzer\Dokumente\__ [ Projects ] __\myproject
                ^^                        ^^
            These are WILDCARDS in PowerShell
```

```powershell
# BEFORE: Breaks
Get-ChildItem "D:\...\__ [ Projects ] __\..."
# PowerShell interprets [ P ] as "match P"

# AFTER: Works
# (just import the module)
Get-ChildItem "D:\...\__ [ Projects ] __\..."
# Treated as literal text
```

### Problem 2: `python` Opens Windows Store

```
C:\> python
# Opens Microsoft Store instead of running Python
```

```powershell
# Fix with one command:
Disable-StorePython
```

---

## Install

### Option 1: One-liner (recommended)

```powershell
irm https://raw.githubusercontent.com/Tetramatrix/WindowsPathFix/main/Install.ps1 | iex
```

### Option 2: Manual

```powershell
# Clone or download, then:
Import-Module .\WindowsPathFix.psm1
Install-AllFixes
```

### Option 3: Copy to modules folder

```powershell
# Copy files to:
# C:\Users\<you>\Documents\PowerShell\Modules\WindowsPathFix\

Import-Module WindowsPathFix
```

---

## Quick Start

```powershell
# See what's wrong
Get-ShellInfo

# Fix paths
Enable-LiteralPathDefault

# Fix Python Store issue (needs Admin)
Disable-StorePython

# Or install everything at once
Install-AllFixes
```

---

## Commands

| Command | What it does |
|---------|--------------|
| `Enable-LiteralPathDefault` | Disable `[ ]` wildcards in paths |
| `Disable-LiteralPathDefault` | Restore default behavior |
| `Get-LiteralPathStatus` | Check if fix is active |
| `Disable-StorePython` | Remove Store Python aliases (Admin) |
| `Enable-StorePython` | Restore Store aliases |
| `Get-StorePythonStatus` | Check alias status |
| `Get-ShellInfo` | Show shell environment |
| `Install-AllFixes` | Install everything + add to profile |

---

## For AI Agents

Add to your `agents.md`:

```markdown
## Windows Path Rules

On Windows, import WindowsPathFix first:
\`\`\`powershell
Import-Module WindowsPathFix
Enable-LiteralPathDefault
\`\`\`

This prevents [ ] from breaking paths.
```

---

## Profile Integration

The module adds this to your PowerShell profile:

```powershell
# === WindowsPathFix (auto-added) ===
$PSDefaultParameterValues['*:LiteralPath'] = $true
# === End WindowsPathFix ===
```

This makes `-LiteralPath` the default for ALL cmdlets, permanently.

---

## Compatibility

- PowerShell 5.1 (Windows built-in)
- PowerShell 7+ (recommended)
- Windows 10 / 11

## License

MIT

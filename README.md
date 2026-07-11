# WindowsPathFix

**Fixes common Windows issues for AI coding agents — automatically.**

![Version](https://img.shields.io/badge/version-3.2.0-blue)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Windows-lightgrey)

---

## What It Fixes (automatically on import)

| Fix | What happens |
|-----|--------------|
| `[ ]` paths | Brackets no longer break PowerShell |
| UTF-8 | Console encoding set to UTF-8 |
| Git | autocrlf + longpaths configured |
| Store Python | Detected (Admin to fix) |
| PATH | Duplicates removed |
| Execution Policy | Set to RemoteSigned |

---

## Safe Execution Helpers

These functions help AI agents avoid common PowerShell issues:

### Invoke-Safe
Execute PowerShell commands safely:
```powershell
Invoke-Safe -Command "Get-Item -LiteralPath 'D:\...\[ Projects ]'"
```

### Invoke-PythonSafe
Run Python without PowerShell quoting issues:
```powershell
Invoke-PythonSafe -Script "print('hello')"
Invoke-PythonSafe -File "script.py"
```

### New-TempFile
Write to temp file, then move (avoids sandbox issues):
```powershell
New-TempFile -Content "data" -Target "D:\...\file.txt"
```

### Get-SafePath / Test-PathSafe
Path helpers that handle special characters:
```powershell
$path = Get-SafePath "D:\...\[ Projects ]\file.txt"
Test-PathSafe "D:\...\[ Projects ]\file.txt"
```

---

## Install (one-time)

### Option 1: One command

```powershell
irm https://raw.githubusercontent.com/Tetramatrix/WindowsPathFix/main/Install.ps1 | iex
```

### Option 2: Clone and install

```powershell
git clone https://github.com/Tetramatrix/WindowsPathFix.git
cd WindowsPathFix
Import-Module .\WindowsPathFix.psm1
Install-WindowsPathFix
```

---

## Use (every time)

```powershell
Import-Module WindowsPathFix
```

That's it. Everything auto-fixes and you see what was fixed:

```
  WindowsPathFix v3.2.0
  ─────────────────────────────────────
  [FIXED] LiteralPath default enabled
  [FIXED] Console encoding set to UTF-8
  [FIXED] git config core.autocrlf = true
  [FIXED] git config core.longpaths = true
  [FIXED] PATH duplicates removed
```

---

## What is a PowerShell Module?

A **module** is just a reusable script file (`.psm1`) that contains functions you can import.

Think of it like a **library**:
- You install it once
- You import it when you need it
- It provides functions you can use

After installing WindowsPathFix, `Import-Module WindowsPathFix` loads it from anywhere on your system.

---

## All Commands

| Command | What it does |
|---------|--------------|
| **Auto-fix (on import)** | |
| `Initialize-WindowsFixes` | Apply all fixes |
| **Path fix** | |
| `Enable-LiteralPathDefault` | Disable `[ ]` wildcards |
| `Disable-LiteralPathDefault` | Restore wildcard behavior |
| `Get-LiteralPathStatus` | Check if fix is active |
| **Python fix** | |
| `Disable-StorePython` | Fix Python opening Store (Admin) |
| `Enable-StorePython` | Restore Store aliases |
| `Get-StorePythonStatus` | Check Store alias status |
| **Info** | |
| `Get-ShellInfo` | Show shell environment |
| `Get-ModuleInstallPath` | Show module paths |
| **Safe execution** | |
| `Invoke-Safe` | Execute PowerShell safely |
| `Invoke-PythonSafe` | Run Python without quoting issues |
| `New-TempFile` | Write via temp file (sandbox-safe) |
| `Get-SafePath` | Get properly escaped path |
| `Test-PathSafe` | Test path with special chars |
| **Quick aliases** | |
| `lcat`, `lni`, `lrm`, `lcp`, `lmv` | LiteralPath versions of common commands |

---

## Compatibility

- PowerShell 5.1+ (Windows built-in)
- PowerShell 7+ (recommended)
- Windows 10 / 11

## License

MIT

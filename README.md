# WindowsPathFix

**Fixes common Windows issues for AI coding agents — automatically.**

![Version](https://img.shields.io/badge/version-3.1.1-blue)
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

### Option 3: Manual copy

Copy these 2 files to `D:\Benutzer\Dokumente\PowerShell\Modules\WindowsPathFix\`:
- `WindowsPathFix.psm1`
- `WindowsPathFix.psd1`

---

## Use (every time)

```powershell
Import-Module WindowsPathFix
```

That's it. Everything auto-fixes and you see what was fixed:

```
  WindowsPathFix v3.1.1
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

## Commands

| Command | What it does |
|---------|--------------|
| `Get-ShellInfo` | Show shell environment |
| `Disable-StorePython` | Fix Python opening Store (Admin) |
| `Get-StorePythonStatus` | Check Store alias status |
| `Get-LiteralPathStatus` | Check if path fix is active |

---

## Compatibility

- PowerShell 5.1+ (Windows built-in)
- PowerShell 7+ (recommended)
- Windows 10 / 11

## License

MIT

# WindowsPathFix Skill

**When to use:** On Windows systems, before any file operations or PowerShell commands.

---

## Quick Start

```powershell
Import-Module WindowsPathFix
```

This automatically fixes:
- `[ ]` brackets in paths (wildcards)
- UTF-8 encoding
- Git autocrlf + longpaths
- Execution policy
- PATH duplicates

---

## Rules

### 1. Paths with Special Characters
```powershell
# WRONG
Get-ChildItem "D:\...\[ Projects ]\..."

# CORRECT
Get-ChildItem -LiteralPath "D:\...\[ Projects ]\..."
```

### 2. Running Python
```powershell
# WRONG
python -c "print('hello')"

# CORRECT
Invoke-PythonSafe -Script "print('hello')"
```

### 3. Writing Files
```powershell
# WRONG
Set-Content -Path "D:\...\file.txt" -Value "data"

# CORRECT
New-TempFile -Content "data" -Target "D:\...\file.txt"
```

### 4. Testing Paths
```powershell
# WRONG
Test-Path "D:\...\[ Projects ]\file.txt"

# CORRECT
Test-PathSafe "D:\...\[ Projects ]\file.txt"
```

---

## Helper Functions

| Function | Use Case |
|----------|----------|
| `Invoke-PythonSafe` | Run Python without quoting issues |
| `Invoke-Safe` | Execute PowerShell safely |
| `New-TempFile` | Write via temp file (sandbox-safe) |
| `Get-SafePath` | Get properly escaped path |
| `Test-PathSafe` | Test path with special chars |
| `lcat`, `lni`, `lrm`, `lcp`, `lmv` | LiteralPath versions |

---

## Shell Detection

```powershell
Get-ShellInfo
```

Shows current shell, version, and whether LiteralPath is enabled.

# AI Agent Rules for WindowsPathFix

## When to Use WindowsPathFix

**ALWAYS** import WindowsPathFix at the start of any PowerShell session on Windows:

```powershell
Import-Module WindowsPathFix
```

This fixes:
- `[ ]` brackets in paths (wildcards)
- UTF-8 encoding
- Git autocrlf + longpaths
- Execution policy
- PATH duplicates

---

## Mandatory Rules

### Rule 1: Always Use -LiteralPath
When working with paths that contain `[ ]`, `{ }`, `?`, or `*`:

```powershell
# WRONG - breaks with special chars
Get-ChildItem "D:\...\[ Projects ]\..."

# CORRECT - use -LiteralPath
Get-ChildItem -LiteralPath "D:\...\[ Projects ]\..."
```

### Rule 2: Use Invoke-PythonSafe for Python
When running Python from PowerShell:

```powershell
# WRONG - quoting issues
python -c "print('hello')"

# CORRECT - use helper
Invoke-PythonSafe -Script "print('hello')"
```

### Rule 3: Use New-TempFile for File Writes
When writing to paths with special chars or in sandboxed environments:

```powershell
# WRONG - may fail
Set-Content -Path "D:\...\file.txt" -Value "data"

# CORRECT - use temp file
New-TempFile -Content "data" -Target "D:\...\file.txt"
```

### Rule 4: Use Test-PathSafe for Path Checks

```powershell
# WRONG - breaks with brackets
Test-Path "D:\...\[ Projects ]\file.txt"

# CORRECT
Test-PathSafe "D:\...\[ Projects ]\file.txt"
```

### Rule 5: Use Get-SafePath for Path Resolution

```powershell
$path = Get-SafePath "D:\...\[ Projects ]\file.txt"
```

---

## Quick Reference

| Task | Use This |
|------|----------|
| Run Python | `Invoke-PythonSafe -Script "..."` |
| Write file safely | `New-TempFile -Content "..." -Target "..."` |
| Check path exists | `Test-PathSafe "..."` |
| Get safe path | `Get-SafePath "..."` |
| Execute PowerShell | `Invoke-Safe -Command "..."` |
| List files | `lcat`, `lni`, `lrm`, `lcp`, `lmv` |

---

## Shell-Specific Notes

### PowerShell 7+ (Recommended)
- Full support for all helpers
- `-LiteralPath` works everywhere

### PowerShell 5.1
- `-LiteralPath` works but some cmdlets may not support it
- Use helpers for complex paths

### Git Bash
- Not affected by `[ ]` issue
- Standard Unix quoting works

### CMD
- Not affected by `[ ]` issue
- Just quote paths normally

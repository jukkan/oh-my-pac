# Setup

## Quick Install

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\windows\install-pac-omp.ps1
```

## Verify

1. Open a new PowerShell 7 tab.
2. Run `pac auth who`.
3. Confirm the prompt shows a purple PAC context segment.

## Manual Refresh

```powershell
Refresh-PacContext
```

## Reinstall After Theme Changes

If you change the repo copies of `pac-context.ps1` or `oh-my-posh-pac.omp.json`, rerun the installer to copy the updated files into `~\.config\oh-my-posh\`.

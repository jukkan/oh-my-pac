# oh-my-pac

Show the active Microsoft Power Platform CLI auth context in an `oh-my-posh` prompt.

This repo provides a small PowerShell helper, a ready-made `oh-my-posh` theme, and an installer that wires the setup into a user's PowerShell 7 profile.

## What It Shows

The prompt adds a dedicated Power Apps-style segment that displays the active PAC auth context, using:

1. `Organization Friendly Name`
2. `Organization Unique Name`
3. user name prefix as a fallback

Example:

```text
 Jukka PAYG
```

## Requirements

- Windows
- PowerShell 7 (`pwsh`)
- `oh-my-posh` installed and available in `PATH`
- Microsoft Power Platform CLI (`pac.exe`) installed and available in `PATH`

## Install

From this repo root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\windows\install-pac-omp.ps1
```

Then open a new PowerShell tab.

## What The Installer Does

- copies the helper and theme into `~\.config\oh-my-posh\`
- updates the current user's PowerShell 7 profile
- adds `Refresh-PacContext`
- wraps `pac` so auth-changing commands auto-refresh the prompt label
- initializes `oh-my-posh` with the PAC-aware theme

## Auto Refresh Behavior

The prompt label refreshes automatically after successful:

- `pac auth create`
- `pac auth select`
- `pac auth delete`
- `pac auth update`
- `pac auth name`
- `pac auth clear`

You can also refresh manually:

```powershell
Refresh-PacContext
```

## Files

- `scripts/windows/pac-context.ps1`
- `scripts/windows/oh-my-posh-pac.omp.json`
- `scripts/windows/install-pac-omp.ps1`

## Notes

- The helper resolves `pac.exe` dynamically from `PATH`.
- The installer is designed to be rerun safely.
- The current implementation targets PowerShell 7 profile setup, not Windows PowerShell 5.1.

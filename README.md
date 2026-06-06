# oh-my-pac

Show the active Microsoft Power Platform CLI auth context in an `oh-my-posh` prompt.

This repo adds a dedicated Power Apps-style prompt segment so you can see which PAC auth profile is active before you run commands against the wrong environment.

It provides:

- a small PowerShell helper
- a ready-made `oh-my-posh` theme
- an installer that wires the setup into a user's PowerShell 7 profile

## What Are These Tools?

[`oh-my-posh`](https://ohmyposh.dev/) is a prompt theming engine for shells such as PowerShell, bash, zsh, and others. It lets you build a rich terminal prompt with segments for things like Git status, current folder, shell, time, and custom context.

[`pac`](https://learn.microsoft.com/power-platform/developer/cli/introduction) is the Microsoft Power Platform CLI. It is commonly used for Dataverse, Power Apps, Power Pages, solution ALM, environment work, and authentication profile management such as `pac auth list`, `pac auth select`, and `pac auth who`.

`oh-my-pac` connects those two pieces:

- `pac` tells you which Power Platform auth context is active
- `oh-my-posh` renders that context directly in the prompt

That matters when you work across multiple tenants, environments, or customer profiles and want a visible reminder in every PowerShell tab.

<img width="1084" height="641" alt="image" src="https://github.com/user-attachments/assets/21f9fb57-f9e0-4792-bbb3-c139945294d2" />

## What It Shows

The prompt adds a dedicated Power Apps-style segment that displays the active PAC auth context, using:

1. `Organization Friendly Name`
2. `Organization Unique Name`
3. user name prefix as a fallback

Example:

```text
 Jukka PAYG
```

In practice, this means your terminal prompt can show the active Power Platform org or profile name all the time, without needing to run `pac auth who` manually.

## Requirements

- Windows
- PowerShell 7 (`pwsh`)
- [`oh-my-posh`](https://ohmyposh.dev/docs/installation/windows) installed and available in `PATH`
- [Microsoft Power Platform CLI](https://learn.microsoft.com/power-platform/developer/cli/introduction) (`pac.exe`) installed and available in `PATH`

## How It Works

1. The helper script runs `pac auth who`.
2. It extracts the most useful label for the active context:
   `Organization Friendly Name` first, then `Organization Unique Name`, then user name as a fallback.
3. The value is stored in the `PAC_CONTEXT` environment variable.
4. The `oh-my-posh` theme renders that value as a purple prompt segment.

The installer also wraps `pac` in the PowerShell profile so auth-changing commands can refresh the prompt label automatically.

## Install

From this repo root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\windows\install-pac-omp.ps1
```

Then open a new PowerShell tab.

If `oh-my-posh` is already configured in your PowerShell profile, the installer updates that setup to use the PAC-aware theme block.

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

So when you switch profiles with `pac auth select`, the label in the same terminal session updates automatically.

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
- This repo focuses on Windows + PowerShell because that is the most common PAC CLI workflow, but the core idea could be adapted to other shells.

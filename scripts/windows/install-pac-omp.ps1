param(
    [string]$ConfigDir = (Join-Path $HOME '.config\oh-my-posh')
)

$ErrorActionPreference = 'Stop'

$sourceDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$helperSource = Join-Path $sourceDir 'pac-context.ps1'
$themeSource = Join-Path $sourceDir 'oh-my-posh-pac.omp.json'

$helperTarget = Join-Path $ConfigDir 'pac-context.ps1'
$themeTarget = Join-Path $ConfigDir 'oh-my-posh-pac.omp.json'

New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null
Copy-Item $helperSource $helperTarget -Force
Copy-Item $themeSource $themeTarget -Force

$profilePath = $PROFILE.CurrentUserCurrentHost
$profileDir = Split-Path -Parent $profilePath
New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
if (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

$markerStart = '# >>> pac-omp >>>'
$markerEnd = '# <<< pac-omp <<<'

$block = @"
$markerStart
`$script:OmpPacHelper = Join-Path `$HOME '.config\oh-my-posh\pac-context.ps1'
`$script:OmpPacTheme = Join-Path `$HOME '.config\oh-my-posh\oh-my-posh-pac.omp.json'
`$script:PacExe = (Get-Command pac.exe -ErrorAction SilentlyContinue).Source

function Refresh-PacContext {
    try {
        if (-not (Test-Path `$script:OmpPacHelper)) {
            Remove-Item Env:PAC_CONTEXT -ErrorAction SilentlyContinue
            return
        }

        `$context = & `$script:OmpPacHelper
        if ([string]::IsNullOrWhiteSpace(`$context)) {
            Remove-Item Env:PAC_CONTEXT -ErrorAction SilentlyContinue
            return
        }

        `$env:PAC_CONTEXT = `$context.Trim()
    } catch {
        Remove-Item Env:PAC_CONTEXT -ErrorAction SilentlyContinue
    }
}

if (`$script:PacExe) {
    function global:pac {
        & `$script:PacExe @args
        `$exitCode = `$LASTEXITCODE

        if (`$exitCode -eq 0 -and `$args.Count -ge 2 -and `$args[0] -eq 'auth') {
            switch (`$args[1]) {
                'create' { Refresh-PacContext }
                'select' { Refresh-PacContext }
                'delete' { Refresh-PacContext }
                'update' { Refresh-PacContext }
                'name' { Refresh-PacContext }
                'clear' { Refresh-PacContext }
            }
        }

        `$global:LASTEXITCODE = `$exitCode
    }
}

Refresh-PacContext
oh-my-posh init pwsh --config `$script:OmpPacTheme | Invoke-Expression
$markerEnd
"@

$content = Get-Content $profilePath -Raw

$escapedStart = [regex]::Escape($markerStart)
$escapedEnd = [regex]::Escape($markerEnd)
$managedBlockPattern = "(?s)$escapedStart.*?$escapedEnd"

if ($content -match $managedBlockPattern) {
    $content = [regex]::Replace($content, $managedBlockPattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $block.TrimEnd() })
} elseif ($content -match '(?m)^oh-my-posh init pwsh.*$') {
    $content = [regex]::Replace($content, '(?m)^oh-my-posh init pwsh.*$', [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $block.TrimEnd() }, 1)
} else {
    if ($content -and -not $content.EndsWith("`n")) {
        $content += "`r`n"
    }

    $content += $block.TrimEnd() + "`r`n"
}

Set-Content -Path $profilePath -Value $content -Encoding UTF8

Write-Host "Installed PAC OMP config to: $ConfigDir"
Write-Host "Updated PowerShell profile: $profilePath"
Write-Host "Open a new PowerShell tab or run: . `"$profilePath`""

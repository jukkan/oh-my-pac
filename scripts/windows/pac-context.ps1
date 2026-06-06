try {
    $pacCommand = Get-Command pac.exe -ErrorAction SilentlyContinue
    if (-not $pacCommand) {
        $pacCommand = Get-Command pac -CommandType Application -ErrorAction SilentlyContinue
    }

    if (-not $pacCommand) {
        return
    }

    $who = & $pacCommand.Source auth who 2>$null
    if (-not $who) {
        return
    }

    $fields = @{}
    foreach ($line in $who) {
        if ($line -match '^\s*([^:]+):\s*(.+?)\s*$') {
            $fields[$matches[1].Trim()] = $matches[2].Trim()
        }
    }

    $friendlyName = $fields['Organization Friendly Name']
    $uniqueName = $fields['Organization Unique Name']
    $user = $fields['User']

    if ($friendlyName) {
        return $friendlyName
    }

    if ($uniqueName) {
        return $uniqueName
    }

    if ($user) {
        return $user.Split('@')[0]
    }
} catch {
    return
}

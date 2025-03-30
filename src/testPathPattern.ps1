function Test-PathPattern {
    param (
        [string]$Path,
        [string[]]$Patterns = @()
    )

    foreach ($pattern in $Patterns) {
        if ($Path -like $pattern) {
            return $true
        }
    }

    return $false
}

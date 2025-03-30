. "$PSScriptRoot\testPathPattern.ps1"

function Search-Directory {
    param (
        [string]$Directory,
        [string[]]$ExcludePatterns,
        [scriptblock]$Collector
    )

    Get-ChildItem -Path $Directory -Directory -Force | ForEach-Object {
        $item = $_

        if ($ExcludePatterns -and (Test-PathPattern -Path $item.Name -Patterns $ExcludePatterns)) {
            return
        }

        & $Collector $item

        Search-Directory -Directory $item.FullName `
            -ExcludePatterns $ExcludePatterns `
            -Collector $Collector
    }
}

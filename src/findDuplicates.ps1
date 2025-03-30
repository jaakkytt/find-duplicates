. "$PSScriptRoot\searchDirectory.ps1"
. "$PSScriptRoot\compareFolderContents.ps1"

function Find-Duplicates {
    param (
        [string[]]$Paths,
        [string[]]$ExcludePaths
    )

    foreach ($path in $Paths) {
        if (-not (Test-Path -Path $path -PathType Container)) {
            Write-Warning "The provided path '$path' is not a valid directory."
            exit 1
        }
    }

    $folderMap = @{}

    $Collector = {
        param ([System.IO.DirectoryInfo]$Item)

        if ($folderMap.ContainsKey($Item.Name)) {
            $folderMap[$Item.Name] += $Item.FullName
        } else {
            $folderMap[$Item.Name] = @($Item.FullName)
        }
    }

    $Paths | Where-Object { Test-Path $_ } | ForEach-Object {
        Search-Directory -Directory $_ `
            -ExcludePatterns $ExcludePaths `
            -Collector $Collector
    }

    $suspectedDuplicates = $folderMap.GetEnumerator() | Where-Object { $_.Value.Count -gt 1 }

    foreach ($entry in $suspectedDuplicates) {
        Write-Host "`nSuspected duplicate folders by name: $($entry.Key)" -ForegroundColor Blue
        foreach ($p in $entry.Value) {
            Write-Host "  $p" -ForegroundColor Green
        }
    }

    $actualDuplicates = @{}

    $total = $suspectedDuplicates.Count
    $current = 0

    foreach ($entry in $suspectedDuplicates) {
        $current++

        Write-Progress -Activity "Verifying suspected duplicates..." `
            -Status "Processing $current of $total suspected names: $($entry.Key)" `
            -PercentComplete (($current / $total) * 100)

        $folderName = $entry.Key
        $paths = $entry.Value

        if ($paths.Count -lt 2) { 
            continue
        }

        $verified = @()

        for ($i = 0; $i -lt $paths.Count; $i++) {
            for ($j = $i + 1; $j -lt $paths.Count; $j++) {
                $pathA = $paths[$i]
                $pathB = $paths[$j]

                if (Compare-FolderContents -Path1 $pathA -Path2 $pathB) {
                    if (-not $verified.Contains($pathA)) { 
                        $verified += $pathA
                    }
                    if (-not $verified.Contains($pathB)) {
                        $verified += $pathB 
                    }
                }
            }
        }

        if ($verified.Count -gt 1) {
            $actualDuplicates[$folderName] = $verified
        }
    }

    Write-Progress -Activity "Done" -Completed

    foreach ($entry in $actualDuplicates.GetEnumerator()) {
        Write-Host "`nFolders with duplicate content: '$($entry.Key)'"  -ForegroundColor Red
        foreach ($p in $entry.Value) {
            Write-Host "  $p" -ForegroundColor Yellow
        }
    }

}

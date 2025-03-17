function Test-PathPattern {
    param (
        [string]$Path,
        [string[]]$Patterns
    )
    if (-not $Patterns) {
        return $false
    }
    foreach ($pattern in $Patterns) {
        if ($Path -like $pattern) {
            return $true
        }
    }
    return $false
}

function Search-Directory {
    param (
        [string]$Directory,
        [string[]]$IncludeFilePatterns,
        [string[]]$ExcludePatterns,
        [hashtable]$Results
    )
    
    Get-ChildItem -Path $Directory -File -Force | ForEach-Object {
        $fullPath = $_.FullName
        $name = $_.Name

        if ($ExcludePatterns -and (Test-PathPattern -Path $name -Patterns $ExcludePatterns)) {
            Write-Debug "Excluding: $fullPath"
            return
        }

        if ($IncludeFilePatterns) {
            if (Test-PathPattern -Path $name -Patterns $IncludeFilePatterns) {
                $Results.Files += $fullPath
            }
        } else {
            $Results.Files += $fullPath
        }
    }

    Get-ChildItem -Path $Directory -Directory -Force | ForEach-Object {
        $fullPath = $_.FullName
        $name = $_.Name

        if ($ExcludePatterns -and (Test-PathPattern -Path $name -Patterns $ExcludePatterns)) {
            Write-Debug "Excluding: $fullPath"
            return
        }

        $Results.Folders += $fullPath

        Search-Directory -Directory $fullPath `
            -IncludeFilePatterns $IncludeFilePatterns `
            -ExcludePatterns $ExcludePatterns `
            -Results $Results
    }
}

function Search-Path {
    param (
        [System.IO.FileSystemInfo]$item,
        [string[]]$IncludeFilePatterns,
        [string[]]$ExcludePatterns,
        [hashtable]$Results
    )

    if ($item.PSIsContainer) {
        if ($ExcludePatterns -and (Test-PathPattern -Path $item.Name -Patterns $ExcludePatterns)) {
            Write-Debug "Excluding: $($item.FullName)"
            return
        }

        $results.Folders += $item.FullName

        return Search-Directory -Directory $item.FullName `
            -IncludeFilePatterns $IncludeFilePatterns `
            -ExcludePatterns $ExcludePatterns `
            -Results $results
    } 

    if ($ExcludePatterns -and (Test-PathPattern -Path $item.Name -Patterns $ExcludePatterns)) {
        Write-Debug "Excluding: $($item.FullName)"
        return
    }

    if ($IncludeFilePatterns) {
        if (Test-PathPattern -Path $item.Name -Patterns $IncludeFilePatterns) {
            $results.Files += $item.FullName
        }
    } else {
        $results.Files += $item.FullName
    }
}

function Search-Paths {
    param (
        [string[]]$Paths,
        [string[]]$IncludeFilePatterns,
        [string[]]$ExcludePatterns
    )
    
    $results = @{ Files = @(); Folders = @(); }

    $Paths |`
        Where-Object { Test-Path -Path $_ } |`
        ForEach-Object { Get-Item -Path $_ } |`
        ForEach-Object { 
            Search-Path -item $_ `
                -IncludeFilePatterns $IncludeFilePatterns `
                -ExcludePatterns $ExcludePatterns `
                -Results $results
        } 

    return $results
}

function Compare-FolderContents {
    param (
        [string]$Path1,
        [string]$Path2
    )

    if (-not (Test-Path $Path1) -or -not (Test-Path $Path2)) {
        return $false
    }

    $files1 = @(
        Get-ChildItem -Path $Path1 -Recurse -File |
        Select-Object @{Name="RelPath"; Expression={ $_.FullName.Substring($Path1.Length).TrimStart('\') }},
            @{Name="Size"; Expression={ $_.Length }},
            @{Name="FullPath"; Expression={ $_.FullName }}
    )
    
    $files2 = @(
        Get-ChildItem -Path $Path2 -Recurse -File |
        Select-Object @{Name="RelPath"; Expression={ $_.FullName.Substring($Path2.Length).TrimStart('\') }},
            @{Name="Size"; Expression={ $_.Length }},
            @{Name="FullPath"; Expression={ $_.FullName }}
    )

    if ($files1.Count -ne $files2.Count) {
        return $false
    }

    $map2 = @{}
    foreach ($f in $files2) { 
        $map2[$f.RelPath] = $f
    }

    foreach ($f1 in $files1) {
        if (-not $map2.ContainsKey($f1.RelPath)) {
            return $false
        }

        $f2 = $map2[$f1.RelPath]

        if ($f1.Size -ne $f2.Size) {
            return $false
        }

        $hash1 = Get-FileHash -Path $f1.FullPath -Algorithm SHA256
        $hash2 = Get-FileHash -Path $f2.FullPath -Algorithm SHA256

        if ($hash1.Hash -ne $hash2.Hash) {
            return $false
        }
    }

    return $true
}

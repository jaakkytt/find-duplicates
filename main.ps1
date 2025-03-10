# Define variables
$paths = @("D:\Archive\Dev", "D:\Archive\Games")
$includeFiles = @("*.zip", "*.txt", "*.html")
$exclude = @(".svn", "blog*")

# Function to check if a name matches any pattern
function Test-PathPattern {
    param (
        [string]$Path,
        [string[]]$Patterns
    )
    if (-not $Patterns) {
        return $false # No patterns means no match
    }
    foreach ($pattern in $Patterns) {
        if ($Path -like $pattern) {
            return $true # Found a match
        }
    }
    return $false
}

# Recursively process a given directory
function Process-Directory {
    param (
        [string]$Directory,
        [string[]]$IncludeFilePatterns,
        [string[]]$ExcludePatterns,
        [hashtable]$Results
    )
    
    # Process files in the current directory (include hidden files)
    Get-ChildItem -Path $Directory -File -Force | ForEach-Object {
        $fullPath = $_.FullName
        $name = $_.Name
        # Exclude check for files
        if ($ExcludePatterns -and (Test-PathPattern -Path $name -Patterns $ExcludePatterns)) {
            Write-Host "Excluding: $fullPath"
        }
        else {
            if ($IncludeFilePatterns) {
                if (Test-PathPattern -Path $name -Patterns $IncludeFilePatterns) {
                    $Results.Files += $fullPath
                }
            }
            else {
                $Results.Files += $fullPath
            }
        }
    }
    
    # Process subdirectories in the current directory (include hidden folders)
    Get-ChildItem -Path $Directory -Directory -Force | ForEach-Object {
        $fullPath = $_.FullName
        $name = $_.Name
        # Exclude check for folders
        if ($ExcludePatterns -and (Test-PathPattern -Path $name -Patterns $ExcludePatterns)) {
            Write-Host "Excluding: $fullPath"
        }
        else {
            $Results.Folders += $fullPath
            Process-Directory -Directory $fullPath -IncludeFilePatterns $IncludeFilePatterns -ExcludePatterns $ExcludePatterns -Results $Results
        }
    }
}

# Main function to process the initial paths
function Process-Paths {
    param (
        [string[]]$Paths,
        [string[]]$IncludeFilePatterns,
        [string[]]$ExcludePatterns
    )
    
    # Create a structured map to hold files and folders
    $results = @{
        Files   = @();
        Folders = @();
    }
    
    foreach ($path in $Paths) {
        if (Test-Path -Path $path) {
            $item = Get-Item -Path $path
            if ($item.PSIsContainer) {
                # If the base folder itself is excluded, skip it entirely
                if ($ExcludePatterns -and (Test-PathPattern -Path $item.Name -Patterns $ExcludePatterns)) {
                    Write-Host "Excluding: $($item.FullName)"
                }
                else {
                    $results.Folders += $item.FullName
                    Process-Directory -Directory $item.FullName -IncludeFilePatterns $IncludeFilePatterns -ExcludePatterns $ExcludePatterns -Results $results
                }
            }
            else {
                # If the path is a file, check exclusion and include conditions
                if (-not ($ExcludePatterns -and (Test-PathPattern -Path $item.Name -Patterns $ExcludePatterns))) {
                    if ($IncludeFilePatterns) {
                        if (Test-PathPattern -Path $item.Name -Patterns $IncludeFilePatterns) {
                            $results.Files += $item.FullName
                        }
                    }
                    else {
                        $results.Files += $item.FullName
                    }
                }
                else {
                    Write-Host "Excluding: $($item.FullName)"
                }
            }
        }
        else {
            Write-Warning "Path not found: $path"
        }
    }
    
    return $results
}

# Run the script and collect the results into a structured map
$collectedPaths = Process-Paths -Paths $paths -IncludeFilePatterns $includeFiles -ExcludePatterns $exclude

# Example: Output the structured results
Write-Host "Folders:"
$collectedPaths.Folders | ForEach-Object { Write-Host $_ }

Write-Host "`nFiles:"
$collectedPaths.Files | ForEach-Object { Write-Host $_ }

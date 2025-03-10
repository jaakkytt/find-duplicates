# Define the variables
$paths = @("D:\Archive\Dev", "D:\Archive\Games")
$includeFiles = @("*.zip", "*.txt", "*.html")
$excludeFilesAndFolders = @("temp*", "blog*", ".svn", "*.log")

# Function to process each file system item recursively
function Process-Item {
    param (
        [System.IO.FileSystemInfo]$item
    )

    if ($item.PSIsContainer) {
        # For directories, check if its name matches any exclusion pattern.
        $excludeFolder = $false
        foreach ($pattern in $excludeFilesAndFolders) {
            if ($item.Name -like $pattern) {
                $excludeFolder = $true
                break
            }
        }
        if ($excludeFolder) {
            # Skip this folder (and do not traverse it)
            return
        }

        # Print the directory's full path
        Write-Output $item.FullName

        # Get the children and process them recursively.
        try {
            $children = Get-ChildItem -LiteralPath $item.FullName -Force -ErrorAction SilentlyContinue
        }
        catch {
            Write-Error "Error accessing $($item.FullName): $($_)"
            return
        }
        foreach ($child in $children) {
            Process-Item -item $child
        }
    }
    else {
        # For files, first check if the file name should be excluded.
        $excludeFile = $false
        foreach ($pattern in $excludeFilesAndFolders) {
            if ($item.Name -like $pattern) {
                $excludeFile = $true
                break
            }
        }
        if ($excludeFile) {
            return
        }

        # If includeFiles is not empty, check if the file matches one of the include patterns.
        if ($includeFiles.Count -gt 0) {
            $include = $false
            foreach ($pattern in $includeFiles) {
                if ($item.Name -like $pattern) {
                    $include = $true
                    break
                }
            }
            if ($include) {
                Write-Output $item.FullName
            }
        }
        else {
            # If no include pattern is provided, print all files.
            Write-Output $item.FullName
        }
    }
}

# Loop through each provided path.
foreach ($path in $paths) {
    if (Test-Path $path) {
        # Get the items directly under the given path (without printing the root itself).
        try {
            $children = Get-ChildItem -LiteralPath $path -Force -ErrorAction SilentlyContinue
        }
        catch {
            Write-Error "Error accessing ${path}: $($_)"
            continue
        }
        foreach ($child in $children) {
            Process-Item -item $child
        }
    }
    else {
        Write-Error "Path ${path} does not exist."
    }
}

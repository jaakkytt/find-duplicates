# $paths = @("C:\Archive\Dev", "C:\Archive\Games")
$paths = @("C:\Projects\find-duplicates")
$includeFiles = @("*.zip", "*.txt", "*.html", "*.md")
$exclude = @(".svn", ".git", "blog*")

. "$PSScriptRoot\src\searchPaths.ps1"

$collectedPaths = Search-Paths -Paths $paths -IncludeFilePatterns $includeFiles -ExcludePatterns $exclude

Write-Host "`nFolders:"
$collectedPaths.Folders | ForEach-Object { Write-Host $_ }

Write-Host "`nFiles:"
$collectedPaths.Files | ForEach-Object { Write-Host $_ }

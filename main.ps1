Add-Type -AssemblyName Microsoft.VisualBasic

. "$PSScriptRoot\src\selectFolders.ps1"
. "$PSScriptRoot\src\findDuplicates.ps1"

$paths = Select-Folders

$excludeRaw = [Microsoft.VisualBasic.Interaction]::InputBox(
    "Enter folder names or patterns to exclude, separated by commas:",
    "Exclude Folders",
    ".git, .svn"
)

$excludePaths = $excludeRaw -split ',' | ForEach-Object { $_.Trim() }

Write-Host "`nSelected folders:" -ForegroundColor Cyan
foreach ($path in $paths) {
    Write-Host "  - $path" -ForegroundColor Green
}

Find-Duplicates -Paths $paths -ExcludePaths $excludePaths

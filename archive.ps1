param(
    [Parameter(
        Mandatory=$true,
         HelpMessage="Usage example: .\archive.ps1 'C:\path\to\folder'"
    )]
    [string]$dir
)

if (-not (Test-Path -Path $dir -PathType Container)) {
    Write-Warning "The provided path '$dir' is not a valid directory."
    exit 1
}

. "$PSScriptRoot\archiveFolder.ps1"

$fullPath = Convert-Path $dir
$fileThreshold = 100
$removePaths = @("build", "node_modules", ".venv", ".cache", ".gradle")

Get-ChildItem -Path $fullPath -Directory | ForEach-Object {
    ArchiveFolder -path $_.FullName -threshold $fileThreshold -removePaths $removePaths
}

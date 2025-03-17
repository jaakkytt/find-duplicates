param(
    [Parameter(
        Mandatory=$true,
        HelpMessage="Usage example: .\listLongFolders.ps1 'C:\path\to\folder'"
    )]
    [string]$dir
)

if (-not (Test-Path -Path $dir -PathType Container)) {
    Write-Warning "The provided path '$dir' is not a valid directory."
    exit 1
}

$fullPath = Convert-Path $dir

Get-ChildItem -Path $fullPath -Directory -Recurse | ForEach-Object {
    $Folder = $_.FullName
    $RelativePath = $Folder.Substring($fullPath.Length).TrimStart('\','/')
    $FileCount = (Get-ChildItem -Path $Folder | Measure-Object).Count
    [PSCustomObject]@{
        FileCount = $FileCount
        RelativePath = $RelativePath
    }
} | Sort-Object -Property FileCount

. "$PSScriptRoot\confirmDelete.ps1"

function ArchiveFolder($path, $threshold, $removePaths) {
    $folderName = Split-Path -Path $path -Leaf
    $parentPath = Split-Path -Path $path -Parent
    $zipFilePath = Join-Path -Path $parentPath -ChildPath "$folderName.zip"

    if (Test-Path -Path $zipFilePath -PathType Leaf) {
        Write-Host "Zip file '$zipFilePath' already exists. Skipping archive."
        return
    }

    $fileCount = (Get-ChildItem -Path $path -Recurse -File | Measure-Object).Count

    if ($fileCount -lt $threshold) {
        Compress-Archive -Path $path -DestinationPath $zipFilePath
        Write-Host "Folder '$path' has been archived to '$zipFilePath'."
        return
    }

    foreach ($remove in $removePaths) {
        $rmPath = Join-Path -Path $path -ChildPath "$remove"
        ConfirmDelete -path $rmPath
    }
  
    $fileCount = (Get-ChildItem -Path $path -Recurse -File | Measure-Object).Count

    Write-Host "Folder '$path' has more than $threshold ($fileCount) files." -ForegroundColor Magenta
    Write-Host -NoNewline "Do you want to archive it? (Y/N): " -ForegroundColor Magenta

    $choice = Read-Host
    if ($choice -notin @('Y', 'y')) {
        Write-Host "Skipping archiving '$path'."
        return
    }

    Compress-Archive -Path $path -DestinationPath $zipFilePath
    Write-Host "Folder '$path' has been archived to '$zipFilePath'."
}

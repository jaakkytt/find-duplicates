function ConfirmDelete($path) {
    if (!(Test-Path -Path $path)) {
        return
    }

    $item = Get-Item -Path $path
    if (!$item.PSIsContainer) {
        return
    }

    Write-Host -NoNewline "Do you want to delete '$path'? (Y/N): " -ForegroundColor Yellow
    $choice = Read-Host

    if ($choice -notin @('Y', 'y')) {
        Write-Host "Retaining '$path'." -ForegroundColor Green
        return
    }

    Write-Host "Removing '$item'." -ForegroundColor Red
    Remove-Item -Path "$path" -Recurse -Force
}

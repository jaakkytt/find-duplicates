Add-Type -AssemblyName System.Windows.Forms

function Select-Folders {
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = "Select a folder"
    $selected = @()

    do {
        $result = $dialog.ShowDialog()
        if ($result -eq "OK") {
            $selected += $dialog.SelectedPath
            $again = Read-Host "Add another folder? (y/n)"
        } else {
            break
        }
    } while ($again -eq 'y')

    return $selected
}

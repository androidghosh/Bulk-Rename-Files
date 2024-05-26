# Step 1: Count images and videos and ask for confirmation
$files = Get-ChildItem -Path $PSScriptRoot -Include *.jpg, *.jpeg, *.png, *.gif, *.bmp, *.mp4, *.avi, *.mov, *.mkv -Recurse
$totalFiles = $files.Count

$confirmation = Read-Host "Number of files found: $totalFiles`nDo you want to proceed with the renaming? (y/n)"
if ($confirmation -ne 'y') {
    Write-Host "Operation cancelled by the user."
    exit
}

# Step 2: Check "date" metadata
$filesWithoutDate = @()

foreach ($file in $files) {
    $date = $file.CreationTime
    if (!$date) {
        $filesWithoutDate += $file.Name
    }
}

if ($filesWithoutDate.Count -gt 0) {
    Write-Host "The following files do not have date metadata:"
    $filesWithoutDate | ForEach-Object { Write-Host $_ }
    Write-Host "Please add date metadata to these files and run the script again."
    exit
}

# Step 3: Rename files based on "date" and "time" metadata
$files = $files | Sort-Object LastWriteTime -Descending
$backupNames = @{}
$counter = 1
$suffixes = @{}

foreach ($file in $files) {
    $originalName = $file.Name
    $newName = "$counter$($file.Extension)"

    # Check for files with same "Date modified"
    if ($backupNames.ContainsKey($newName)) {
        if (-not $suffixes.ContainsKey($counter)) {
            $suffixes[$counter] = 0
        }
        $suffixes[$counter]++
        $newName = "$counter($([char]($suffixes[$counter] + 96)))$($file.Extension)"
    }

    Rename-Item -Path $file.FullName -NewName $newName
    $backupNames[$newName] = $originalName
    Write-Host "Renamed $originalName to $newName ($([math]::Round(($counter / $totalFiles) * 100))% done)"
    $counter++
}

# Step 4: Operation successful message and undo option
Write-Host "Operation successful."
$undo = Read-Host "Do you want to undo the changes? (y/n)"
if ($undo -eq 'y') {
    foreach ($key in $backupNames.Keys) {
        $file = Get-ChildItem -Path $PSScriptRoot -Filter "$key"
        if ($file) {
            Rename-Item -Path $file.FullName -NewName $backupNames[$key]
            Write-Host "Reverted $($file.Name) to $($backupNames[$key])"
        }
    }
    Write-Host "All changes have been undone."
} else {
    Write-Host "Exiting without undoing changes."
}

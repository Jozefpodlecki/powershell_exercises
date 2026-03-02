$FileName = "ghidra_12.0.3_PUBLIC_20260210.zip";
$ExtractPath = "."

$zip = [System.IO.Compression.ZipFile]::OpenRead($FileName)
$totalEntries = $zip.Entries.Count
$extractedEntries = 0

try {
    Write-Information "Extracting $totalEntries items..." -ForegroundColor Yellow

    $firstEntry = $zip.Entries[0].FullName -split '/' | Select-Object -First 1
    $RootFolder = $firstEntry + "/"

    Write-Information "Removing root folder: '$rootFolder'" -ForegroundColor Cyan

    foreach ($entry in $zip.Entries) {

        $FullPath = $entry.FullName

        if ($FullPath -match '/$') { continue }
        
        $RelativePath = $FullPath -replace "^$([regex]::Escape($RootFolder))", ""

        $targetDir = Split-Path $RelativePath -Parent
        $TargetPath = Join-Path $ExtractPath $RelativePath

        if ($targetDir -and !(Test-Path $targetDir) -and $targetDir) {
            Write-Information "Creating directory $targetDir"
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        }

        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $TargetPath, $true)

        $extractedEntries++
        $percentComplete = [math]::Round(($extractedEntries / $totalEntries) * 100, 1)
        
        Write-Progress -Activity "Extracting Ghidra" `
                        -Status "$percentComplete% Complete" `
                        -CurrentOperation "Extracting: $($entry.Name)" `
                        -PercentComplete $percentComplete
    }

    $zip.Dispose()
    Write-Progress -Activity "Extracting completed" -Completed
    Write-Information "Extraction complete!" -ForegroundColor Green
}
catch {
    Write-Error "Fatal error: $_" -ForegroundColor Red
    
    if ($zip) { $zip.Dispose() }
    Write-Progress -Activity "Extracting Ghidra" -Completed
    exit 1
}

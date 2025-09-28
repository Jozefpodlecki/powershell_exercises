Clear-Host

function Scan-Item {
    param (
        [string]$ItemPath,
        [int]$Current,
        [int]$Total,
        [int]$BatchSize,
        [string]$CsvPath
    )

    $Results = @()
    $Percent = [math]::Round(($Current / $Total) * 100, 1)

    if (Test-Path $ItemPath -PathType Container) {
        Get-ChildItem -Path $ItemPath -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
            Write-Progress -Activity "Scanning filesystem..." `
                -Status "$Current/$Total : Currently scanning $($_.FullName)" `
                -PercentComplete $Percent

            if (Test-Path -Path $_ -PathType Leaf) {
                $Results += [pscustomobject]@{
                    FullName      = $_.FullName
                    Length        = $_.Length
                    LastWriteTime = $_.LastWriteTime
                }
            }

            if ($Results.Count -ge $BatchSize) {
                $Results | Export-Csv -Path $CsvPath -NoTypeInformation -Append
                $Results.Clear()
            }

            Start-Sleep -Seconds 1
        }
    } else {
        $FileInfo = Get-Item -Path $ItemPath -Force -ErrorAction SilentlyContinue
        
        if ($FileInfo) {
            Write-Progress -Activity "Scanning filesystem..." `
                -Status "$Current/$Total : Currently scanning $($FileInfo.FullName)" `
                -PercentComplete $Percent

            $Results += [pscustomobject]@{
                FullName      = $FileInfo.FullName
                Length        = $FileInfo.Length
                LastWriteTime = $FileInfo.LastWriteTime
            }

            if ($Results.Count -ge $BatchSize) {
                $Results | Export-Csv -Path $CsvPath -NoTypeInformation -Append
                $Results.Clear()
            }
        }
    }

    if ($Results.Count -gt 0) {
        $Results | Export-Csv -Path $CsvPath -NoTypeInformation -Append
    }
}

$InputPath = Read-Host "Enter the drive or path to scan (default: C:\)"
$Path = if ([string]::IsNullOrWhiteSpace($InputPath)) { "C:\" } else { $InputPath }

$TopItems = @(Get-ChildItem -Path $Path -Force -ErrorAction SilentlyContinue)
$TopItems = @($Path) + $TopItems.FullName
$Total = $TopItems.Count
$Current = 0
$CsvPath = ".\filesystem-scan.csv"

try {
    foreach ($Item in $TopItems) {
        $Current++
        Scan-Item -ItemPath $Item -Current $Current -Total $Total -BatchSize $BatchSize -CsvPath $CsvPath
    }   
}
catch {
    Write-Warning "Failed to process $ItemPath : $_"
}

Write-Host "Scan complete! Results saved to filesystem-scan.csv" -ForegroundColor Green
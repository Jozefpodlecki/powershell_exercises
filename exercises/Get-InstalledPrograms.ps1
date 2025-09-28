$UninstallKeys = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

function Get-CachedCimInstance {
        param (
        [string]$CacheFile = ".\MSIProductsCache.json"
    )

    if (Test-Path $CacheFile) {
        $MSIProducts = Get-Content $CacheFile | ConvertFrom-Json
        Write-Host "Loaded MSI cache from $CacheFile"
    } else {
        Write-Host "Querying Win32_Product (this may take a while)..."
        $MSIProducts = Get-CimInstance -ClassName Win32_Product -ErrorAction SilentlyContinue |
            Select-Object IdentifyingNumber, Name, InstallLocation

        $MSIProducts | ConvertTo-Json -Depth 5 | Set-Content $CacheFile
        Write-Host "MSI cache saved to $CacheFile"
    }

    return $MSIProducts
}

$MSIProducts = Get-CachedCimInstance

# $MSIProducts | ForEach-Object {
#     Write-Host "$($_.Name) -> $($_.IdentifyingNumber) is of type $($_.IdentifyingNumber.GetType().Name)"
# }

$Programs = foreach ($Key in $UninstallKeys) {
    Get-ItemProperty $Key -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName } |
        Select-Object DisplayName, DisplayVersion, Publisher, InstallLocation, UninstallString
}

$Programs | ForEach-Object {
    if (-not $_.InstallLocation -and $_.UninstallString) {

        $folder = Split-Path $_.UninstallString -Parent

        if ($_.UninstallString -match '\{[0-9A-Fa-f\-]{36}\}') {
            $guid = $matches[0]

            $msi = $MSIProducts | Where-Object { $_.IdentifyingNumber -eq $guid }
            if ($msi -and $msi.InstallLocation) {
                $folder = $msi.InstallLocation
            }
        }

        $_ | Add-Member -NotePropertyName 'GuessedInstallPath' -NotePropertyValue $folder
    }
}

$Programs | Sort-Object DisplayName |
    Export-Csv -Path ".\installed-programs.csv" -NoTypeInformation

Write-Host "Installed programs exported to installed-programs.csv" -ForegroundColor Green
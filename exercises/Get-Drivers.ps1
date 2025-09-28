$Drivers = Get-CimInstance -ClassName Win32_PnPSignedDriver

$Drivers | Select-Object -First 1 | Format-List *

$Drivers | Select-Object DeviceName, Manufacturer, DriverVersion, DriverDate, DriverProviderName, InfName |
    Sort-Object DeviceName |
    Export-Csv -Path ".\drivers.csv" -NoTypeInformation

Write-Host "Drivers exported to drivers.csv" -ForegroundColor Green
param (
    [Parameter(Mandatory=$false)]
    [string]$GithubReleaseUrl = "https://api.github.com/repos/NationalSecurityAgency/ghidra/releases/latest"
)

$Assets = (Invoke-RestMethod -Uri $GithubReleaseUrl).assets;
$Asset = $Assets[0];
$FileName = $Asset.name;
$Digest = $Asset.digest;
$DownloadUrl = $Asset.browser_download_url;

if (Test-Path $FileName) {
    Write-Warning "File already exists: $FileName" -ForegroundColor Green;
    exit 0
}

Write-Information "Downloading: $FileName" -ForegroundColor Cyan
Write-Information "Size: $([math]::Round($Asset.size / 1MB, 2)) MB" -ForegroundColor Yellow

Invoke-WebRequest -Uri $DownloadUrl -OutFile $FileName -WarningAction SilentlyContinue | Out-Null

if (Test-Path $FileName) {
    $actualHash = (Get-FileHash -Path $FileName -Algorithm SHA256).Hash
    $expectedHash = $Digest -replace 'sha256:', ''
    
    if ($actualHash -eq $expectedHash) {
        Write-Information "Download verified! Hash matches." -ForegroundColor Green
        Write-Information "File saved as: $FileName" -ForegroundColor Green
    } else {
        Write-Information "Hash mismatch! File may be corrupted." -ForegroundColor Red
        Write-Information "Expected: $expectedHash" -ForegroundColor Red
        Write-Information "Actual:   $actualHash" -ForegroundColor Red
    }
} else {
    Write-Information "Download failed - file not found." -ForegroundColor Red
}
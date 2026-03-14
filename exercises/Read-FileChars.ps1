param (
    [Parameter(Mandatory=$true)]
    [string]$FilePath,
    [Parameter(Mandatory=$false)]
    [int]$Length = 1000
)

$reader = [System.IO.StreamReader]::new($FilePath);
$buffer = New-Object char[] $Length;
$read = $sr.Read($buffer, 0, $Length);
$reader.Close();

-join $buffer[0..($read-1)]
Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser

Invoke-ScriptAnalyzer -Path ".\exercises\Get-Drivers.ps1"
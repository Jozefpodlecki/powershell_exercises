Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser

Get-ChildItem -Path ".\exercises" `
    -Recurse `
    -Filter "*.ps1" | Invoke-ScriptAnalyzer  -Settings .\Rules.rule
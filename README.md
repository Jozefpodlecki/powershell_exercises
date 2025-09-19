
# Powershell Exercises

A collection of PowerShell exercises and scripts for learning and experimentation.

## Running Scripts as Administrator

Some scripts require administrative privileges. You can start a new elevated PowerShell session using the following command:


```ps1
Start-Process powershell.exe -ArgumentList ("-NoExit",("cd {0}" -f (Get-Location).path)) -Verb RunAs
```
:: Simple run script to bypass default powershell execution policy 

@ECHO OFF
PowerShell -ExecutionPolicy Bypass -File .\remux-delete.ps1
pause

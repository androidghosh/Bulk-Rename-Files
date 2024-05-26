@echo off
setlocal

:: Change directory to the folder containing the PowerShell script
cd /d "%~dp0"

:: Launch the PowerShell script in a new window
start powershell -ExecutionPolicy Bypass -File "rename_files.ps1"

:: End of script

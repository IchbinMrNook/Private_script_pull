@echo off
REM Setzt die PowerShell-Ausführungsrichtlinie auf Undefined
powershell -Command "Set-ExecutionPolicy Undefined -Scope CurrentUser -Force"
echo PowerShell-Ausführungsrichtlinie wurde auf Undefined gesetzt.

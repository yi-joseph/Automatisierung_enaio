# Hier ist ein Script für Enaio-Basisinstallation ohne GUI
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

# 1.3 Datenträger D:\ und E:\ initialisieren:
# Hier sehe ich die Nummer von den Laufwerken
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

# Jetzt möchte ich B für DVD, D für "ENAIO_D" und E für "ENAIO_E" hinzuweisen: 
Get-Volume
diskpart
# DVD-ROM wählen
select Volume 0 
# B für DVD hinzuweisen
assign letter=B
# "ENAIO_D" asuwählen
select Volume 4 
# D für "ENAIO_D" hinzuweisen
assign letter=D
# "ENAIO_E" auswählen
select Volume 5
# E für "ENAIO_E" hinzuweisen
assign letter=E
exit
# Jetzt überprüfe ich, ob alles nach Wunsch gesetzt wurde
Get-Volume

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
# "Suchen": Gruppenrichtlinie bearbeiten -> Windows-Einstellungen -> Sicherheitseinstellungen -> Kontorichtlinien -> Kennwortrichtlinien -> Kennwort muss Komplexitätsvoraussetzungen entsprechen: Deaktivieren
# Dann kann man die Passworde von den beiden Konten als "optimal" einsetzen.  
# Ich erstelle zuerst Verzeichnis:
New-Item -ItemType Directory -Path C:\temp

# Dann exportiere ich die aktuellen Sicherheitsrichtlinien:
secedit /export /cfg C:\temp\secpol.cfg
cd C:\temp
dir
# Hier sollte es secpol.cfg geben: 
notepad .\secpol.cfg
# Ich ändere "PasswordComplexity = 1" auf "0" und speichere.
# Jetzt muss ich die Änderung in System einsetzen: 
secedit /configure /db secedit.sdb /cfg secpol.cfg /areas SECURITYPOLICY
# Dann update ich die Richtlinien
gpupdate /force
# Jetzt überprüfe ich, ob der Wert wirklich geändert wurde: 
secedit /export /cfg C:\temp\secpol_1.cfg
dir
notepad secpol_1.cfg
# Jetzt sollte der Wert auch auf 0 gesetzt werden.
# jetzt sollte ich einfaches Passwort setzen und 
# mich mit einfachem Password anmelden

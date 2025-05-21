# Automatisierung für Enaio-Basisinsallation

Dieses Projekt dient der automatisierten Basisinstallation der Anwendung enaio 11.10 mit einer einfachen Benutzeroberfläche auf Kundensystem.
Ziel ist es, den Installationsroutinen zu vereinfachen, Zeit zu sparen und Fehler zu vermeiden. 

1. Benutzer freundlichen GUI werden erstellt und getest. 
2. Die Powershell-Scripten werden in eine exe-Datei umwandelt. 
3. Die exe-Datei wird nach erfolgreicher Installation von enaio automatisch entfernt. 

Funktionen: 
1. Systemprüfung vor der Enaio-Basisinstallation.
2. Automatisierte Enaio-Basisinstallation per Powershell.
3. Einfache grafische Oberfläche (GUI)
4. Erstellung einer ".exe"-Datei mit automatischem Selbstlösch-Mechanismus. 

#Projektstruktur: 
enaio-Installer: 
gui.ps1					# GUI-Skript für die Benutzeroberfläche
System-Check.ps1		# Überprüft, ob Systemanforderungen erfüllt sind
Enaio_Basis_Instal.ps1	# Enaio-Basisinsallation durchführen
config.ps1				# Optionale Konfiguration
logs\					# Log-Verzeichnis

#Autor Yi Miao Heidelberg
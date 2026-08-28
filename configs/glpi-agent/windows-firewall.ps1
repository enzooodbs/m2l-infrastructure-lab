# Exemple public - exécuter en PowerShell administrateur.
# Autorise uniquement le serveur GLPI du lab à joindre GLPI Agent sur TCP/62354.

$GlpiServer = "192.168.10.58"

New-NetFirewallRule `
  -DisplayName "GLPI Agent - GLPI Server TCP 62354" `
  -Direction Inbound `
  -Action Allow `
  -Protocol TCP `
  -LocalPort 62354 `
  -RemoteAddress $GlpiServer `
  -Profile Any

# Vérifier et désactiver l'ancienne règle entrante générique si elle autorise Any.
Get-NetFirewallRule |
  Where-Object DisplayName -eq "GLPI Agent" |
  Where-Object Direction -eq "Inbound" |
  Disable-NetFirewallRule

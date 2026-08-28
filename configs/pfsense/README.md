# pfSense - principes de filtrage du lab

Les exports `config.xml` ne sont volontairement pas publiés.

## Principes appliqués

- WAN simulé via VMnet5 / VMware NAT.
- Aucun NAT entre les sites.
- OpenVPN TUN Layer 3 en hub-and-spoke.
- Les règles inter-sites sont créées par usage, pas par `any -> any`.
- Le Web direct TCP/80-443 est bloqué depuis les LAN agences.
- Les clients utilisent Squid en TCP/3128.
- Centreon est limité à ICMP + UDP/161 vers les équipements supervisés.
- GLPI est autorisé vers les agents uniquement en TCP/62354.
- Graylog reçoit un port Syslog UDP dédié par pfSense.

## Exemple de matrice

| Source | Destination | Proto/port | Usage |
|---|---|---|---|
| LAN agence | DC1/DC2 | IPv4, limité aux DC | AD/DNS/DHCP |
| LAN agence | GLPI | TCP/80 | inventaire agent -> GLPI |
| GLPI | agents LAN/DMZ | TCP/62354 | demande d'inventaire distante |
| Centreon | équipements | ICMP + UDP/161 | supervision |
| pfSense Basket | Graylog | UDP/1515 | Syslog |
| pfSense Équitation | Graylog | UDP/1516 | Syslog |

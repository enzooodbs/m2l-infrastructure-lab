# LAB M2L - Récapitulatif final v3.0

**Date : 28/08/2026**  
**État : PROJET TERMINÉ - 7/7 sprints - 100 %**  
**Documentation complète : conservée hors dépôt public ; ce fichier constitue le récapitulatif assaini.**

## 1. Architecture finale

- VMnet1 / VLAN114 - LANUSERS siège - `192.168.10.32/28`
- VMnet2 / VLAN115 - SERVERS siège - `192.168.10.16/28`
- VMnet3 / VLAN116 - réservé / non utilisé - `192.168.10.0/28`
- VMnet4 / VLAN117 - MGMT - `192.168.10.48/28`
- VMnet5 - NAT VMware / WAN simulé - `172.16.0.0/16`
- VMnet6 - DMZ Basket - `172.17.72.0/24`
- VMnet7 - LAN Basket - `172.31.72.0/27`
- VMnet8 - DMZ Équitation - `172.18.1.0/24`
- VMnet9 - LAN Équitation - `172.31.72.32/27`
- OpenVPN - `10.255.0.0/24`

Aucun chevauchement IPv4 n'est présent entre les réseaux de référence. Aucun NAT inter-sites n'est utilisé.

## 2. Siège

| Hôte | IP | Rôle |
|---|---:|---|
| PfSense-Siege | WAN `172.16.100.1` / `.46` / `.30` / `.62` | Routeur/firewall, hub OpenVPN |
| DC1 | `192.168.10.17` | AD DS principal, DNS, DHCP |
| Srv-Fich | `192.168.10.18` | SMB + sauvegarde NAS |
| DC2 | `192.168.10.19` | AD DS / DNS secondaire |
| Graylog | `192.168.10.20` | Graylog 7.1 / MongoDB 8 / OpenSearch 2.19.5 |
| NAS | `192.168.10.21` | OpenMediaVault / sauvegarde |
| GLPI | `192.168.10.58` | GLPI 11.0.8 / LDAP / inventaire |
| Centreon | `192.168.10.60` | Centreon 25.10 / supervision |
| Admin-Siege | `192.168.10.33` | Administration |

## 3. Agence Basket

- PfSense-Basket : WAN `172.16.100.109/16`, DMZ `.254`, LAN `.30`, OpenVPN `10.255.0.2`.
- SQUID-Basket : `172.17.72.1:3128`.
- Admin-Basket : `172.31.72.28`, `isc-dhcp-relay` vers DC1.
- CLT-Basket : réservation DHCP `172.31.72.2/27`, domaine `m2l.local`.
- Web direct LAN TCP/80-443 bloqué ; HTTP/HTTPS via Squid validés.
- GLPI, Centreon et Graylog validés.

## 4. Agence Équitation

- PfSense-Equitation : WAN `172.16.100.110/16`, DMZ `.254`, LAN `.62`, OpenVPN `10.255.0.3`.
- SQUID-Equitation : `172.18.1.1:3128`.
- Admin-Equitation : `172.31.72.60`, `isc-dhcp-relay` vers DC1.
- CLT-Equitation : réservation DHCP `172.31.72.34/27`, domaine `m2l.local`, secure channel `NERR_Success`.
- Web direct LAN TCP/80-443 bloqué ; HTTP/HTTPS via Squid validés.
- GLPI, Centreon et Graylog validés.

## 5. OpenVPN hub-and-spoke

- Hub : PfSense-Siege.
- Tunnel : `10.255.0.0/24`, TUN Layer 3, UDP/1194.
- Basket : `10.255.0.2`.
- Équitation : `10.255.0.3`.
- Chiffrement observé : AES-256-GCM.
- Routage par certificat / Client Specific Override.
- Aucun NAT inter-sites.

## 6. DHCP centralisé

| Site | Scope | Pool | Gateway | Relais | Réservation client |
|---|---|---|---|---|---|
| Basket | `172.31.72.0/27` | `.2-.27` | `.30` | Admin-Basket `.28` | CLT `.2` |
| Équitation | `172.31.72.32/27` | `.34-.59` | `.62` | Admin-Equitation `.60` | CLT `.34` |

DNS : `192.168.10.17`, `192.168.10.19` ; suffixe : `m2l.local`.

## 7. GLPI

- Agents GLPI 1.19 sur les équipements validés.
- Push agent -> GLPI : `TCP/80` vers `http://192.168.10.58/front/inventory.php`.
- Demande distante GLPI -> agents : `TCP/62354`.
- `httpd-trust = 127.0.0.1/32,192.168.10.58/32`.
- Sur Windows, la règle entrante générique autorisant Any est désactivée ; seule la source GLPI `.58` est autorisée.

## 8. Centreon

- Poller Central : `192.168.10.60`.
- ICMP + SNMP v2c vers pfSense / Admin / SQUID des deux agences.
- SQUID-Equitation : Swap en WARNING ~10,41 %, non bloquant.

## 9. Graylog

- PfSense-Siege -> UDP/1514 -> stream `pfSense-Siege`.
- PfSense-Basket -> UDP/1515 -> stream `PfSense-Basket`.
- PfSense-Equitation -> UDP/1516 -> stream `PfSense-Equitation`.
- DC1 -> Beats TCP/5044 -> stream `Windows-DC`.

## 10. Flux durcis

- LAN agences -> DC1/DC2 : règle `IPv4 *` limitée aux contrôleurs de domaine.
- Agents -> GLPI : TCP/80.
- GLPI -> agents : TCP/62354.
- Centreon -> équipements : ICMP + UDP/161.
- PfSense Basket -> Graylog : UDP/1515 ; PfSense Équitation -> Graylog : UDP/1516.
- Web direct LAN TCP/80-443 : bloqué ; proxy Squid TCP/3128 : autorisé.

## 11. Incidents / enseignements majeurs

1. VMware NAT / DNS : redémarrer `VMnetNat` avant de modifier la configuration DNS lorsque l'ICMP fonctionne mais pas les requêtes DNS externes.
2. DHCP relay + OpenVPN TUN : le relais pfSense ne peut pas utiliser `ovpnc1`; utiliser `isc-dhcp-relay` sur l'Admin local.
3. Vérifier les alias et adresses sources des règles firewall : erreurs corrigées sur `BASKET_DMZ`, GLPI Équitation et Centreon.
4. Ne pas assigner temporairement `ovpnc1` comme interface sans nécessité : une reconnexion OpenVPN peut être requise pour restaurer les routes.
5. Vérifier qu'une VM/service cible est démarré avant de conclure à une panne réseau.

## 12. Clôture

- Smoke tests finaux : OK.
- Non-régression Basket : OK.
- GLPI distant : OK.
- Centreon : OK.
- Graylog : OK.
- OpenVPN : deux spokes connectés.
- Snapshots finaux : réalisés sur l'ensemble des VMs.

**Projet M2L techniquement terminé et figé.**

## 13. Schémas publics

Les schémas versionnés et lisibles directement sur GitHub sont disponibles dans [`docs/diagrams/README.md`](diagrams/README.md) au format Mermaid :

- architecture globale ;
- OpenVPN hub-and-spoke ;
- flux principaux durcis.

Les exports haute résolution PNG/SVG sont conservés avec la documentation complète du projet.

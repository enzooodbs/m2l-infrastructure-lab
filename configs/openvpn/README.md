# OpenVPN hub-and-spoke - paramètres publics

Aucune clé, aucun certificat privé et aucune TLS key ne sont publiés.

## Hub

- pfSense-Siege
- réseau tunnel : `10.255.0.0/24`
- transport : UDP/1194
- mode : TUN Layer 3
- chiffrement observé : AES-256-GCM

## Spokes

- Basket : `10.255.0.2`
- Équitation : `10.255.0.3`

Le routage des réseaux distants repose sur les certificats clients et les Client Specific Overrides (CSO/iroute).

# Diagrammes d'architecture

Les vues ci-dessous sont volontairement maintenues en **Mermaid** afin de rester lisibles directement dans GitHub et faciles à versionner.

## Architecture globale

```mermaid
flowchart TB
    Internet((Internet)) --> NAT[VMnet5 - NAT VMware<br/>172.16.0.0/16]

    subgraph SIEGE[Siège M2L]
        PFS[pfSense-Siege<br/>Hub OpenVPN]
        USERS[VMnet1 LANUSERS<br/>192.168.10.32/28]
        SERVERS[VMnet2 SERVERS<br/>192.168.10.16/28]
        MGMT[VMnet4 MGMT<br/>192.168.10.48/28]
        DC[DC1 / DC2<br/>AD DS - DNS - DHCP]
        FILES[Srv-Fich + NAS]
        GLPI[GLPI<br/>192.168.10.58]
        CENTREON[Centreon<br/>192.168.10.60]
        GRAYLOG[Graylog<br/>192.168.10.20]
        PFS --> USERS
        PFS --> SERVERS
        PFS --> MGMT
        SERVERS --> DC
        SERVERS --> FILES
        MGMT --> GLPI
        MGMT --> CENTREON
        SERVERS --> GRAYLOG
    end

    NAT --> PFS

    subgraph BASKET[Agence Basket]
        PFB[pfSense-Basket<br/>VPN 10.255.0.2]
        BLAN[LAN 172.31.72.0/27]
        BDMZ[DMZ 172.17.72.0/24]
        BADMIN[Admin-Basket<br/>172.31.72.28]
        BCLT[CLT-Basket<br/>172.31.72.2]
        BSQ[Squid-Basket<br/>172.17.72.1:3128]
        PFB --> BLAN
        PFB --> BDMZ
        BLAN --> BADMIN
        BLAN --> BCLT
        BDMZ --> BSQ
    end

    subgraph EQUI[Agence Équitation]
        PFE[pfSense-Equitation<br/>VPN 10.255.0.3]
        ELAN[LAN 172.31.72.32/27]
        EDMZ[DMZ 172.18.1.0/24]
        EADMIN[Admin-Equitation<br/>172.31.72.60]
        ECLT[CLT-Equitation<br/>172.31.72.34]
        ESQ[Squid-Equitation<br/>172.18.1.1:3128]
        PFE --> ELAN
        PFE --> EDMZ
        ELAN --> EADMIN
        ELAN --> ECLT
        EDMZ --> ESQ
    end

    NAT --> PFB
    NAT --> PFE
    PFS == OpenVPN 10.255.0.0/24 ==> PFB
    PFS == OpenVPN 10.255.0.0/24 ==> PFE
```

## OpenVPN hub-and-spoke

```mermaid
flowchart LR
    HUB[pfSense-Siege<br/>OpenVPN Hub<br/>10.255.0.1]
    B[pfSense-Basket<br/>10.255.0.2]
    E[pfSense-Equitation<br/>10.255.0.3]

    HUB == AES-256-GCM / UDP 1194 ==> B
    HUB == AES-256-GCM / UDP 1194 ==> E

    B --> BLAN[172.31.72.0/27]
    B --> BDMZ[172.17.72.0/24]
    E --> ELAN[172.31.72.32/27]
    E --> EDMZ[172.18.1.0/24]
```

## Flux principaux durcis

```mermaid
flowchart LR
    LAN[LAN agences] -->|AD / DNS / DHCP| DC[DC1 / DC2]
    LAN -->|TCP 80| GLPI[GLPI]
    GLPI -->|TCP 62354| AGENTS[Agents GLPI LAN / DMZ]
    CENTREON[Centreon] -->|ICMP + UDP 161| MONITORED[pfSense / Admin / Squid]
    PFB[pfSense-Basket] -->|UDP 1515| GRAYLOG[Graylog]
    PFE[pfSense-Equitation] -->|UDP 1516| GRAYLOG
    LAN -. Web direct 80/443 bloqué .-> INTERNET((Internet))
    LAN -->|TCP 3128| SQUID[Squid]
    SQUID --> INTERNET
```

Les exports PNG/SVG haute résolution de la documentation finale peuvent être ajoutés dans ce répertoire pour les présentations ou les impressions.

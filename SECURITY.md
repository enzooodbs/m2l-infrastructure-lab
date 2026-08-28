# Politique de publication et de sécurité

Ce dépôt contient une version publique et assainie du lab M2L.

Ne jamais publier dans ce dépôt :

- mots de passe ;
- clés privées OpenVPN ;
- TLS keys ;
- fichiers `.p12`, `.pfx`, `.key` ou certificats privés ;
- exports pfSense `config.xml` non nettoyés ;
- secrets SQL/LDAP ;
- tokens ou clés API ;
- communautés SNMP réellement utilisées ;
- sauvegardes contenant des identifiants.

Les adresses RFC1918 visibles dans les schémas appartiennent uniquement au lab.

Les exemples de configuration utilisent des placeholders tels que `CHANGE_ME` ou `COMMUNAUTE_SNMP`.

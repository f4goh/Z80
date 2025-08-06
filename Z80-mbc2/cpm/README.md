#  CP/M des cartes Z80/68000 (1978–1979) et CP/M de l'Amstrad CPC

##  Origines du CP/M

- **CP/M (Control Program for Microcomputers)** a été développé par **Digital Research** en 1974 pour les processeurs **Intel 8080**.
- Le **Zilog Z80**, compatible avec l’8080, est devenu le processeur dominant pour les systèmes CP/M.
- Des ports de CP/M ont existé pour d'autres architectures comme le **Motorola 68000**, mais ils étaient moins répandus.

---

##  CP/M sur cartes embarquées Z80/68000 (1978–1979)

- Utilisé dans des systèmes industriels ou des kits de développement.
- CP/M servait de **système d’exploitation standard** pour les micro-ordinateurs Z80.
- Versions souvent **personnalisées** selon le matériel, mais conformes aux standards de Digital Research.

---

## CP/M sur Amstrad CPC (1984+)

- L’Amstrad CPC utilisait un **Z80A**, donc compatible avec CP/M.
- **Locomotive Software** a adapté **CP/M 2.2** pour les CPC 464, 664 et 6128.
- Le **CPC 6128** incluait aussi **CP/M Plus (version 3.0)**.
- Le CP/M sur CPC utilisait principalement les **mnémoniques 8080**, pour assurer la compatibilité logicielle.

---

## Tableau comparatif

| Élément                  | Cartes Z80/68000 (1978–1979) | Amstrad CPC (1984+)            |
|--------------------------|------------------------------|--------------------------------|
| Processeur principal     | Z80 / parfois 68000          | Z80A                           |
| Version de CP/M          | CP/M 1.x / 2.2 / parfois 3.0 | CP/M 2.2 / CP/M Plus (3.0)     |
| Compatibilité logicielle | Forte avec 8080              | Compatible 8080, Z80 limité    |
| Origine du système       | Digital Research             | Digital Research + Locomotive  |

---

# Instructions CP/M 2.2 pour Z80

## Commandes internes (Console Command Processor - CCP)

Ces commandes sont intégrées dans le système et ne nécessitent pas de fichier sur disque :

| Commande | Description                          |
|----------|--------------------------------------|
| DIR      | Liste les fichiers du disque         |
| ERA      | Supprime un fichier                  |
| REN      | Renomme un fichier                   |
| TYPE     | Affiche le contenu d’un fichier      |
| SAVE     | Sauvegarde un segment mémoire en fichier |
| USER     | Change l’espace utilisateur (0–15)   |

---

## Programmes transitoires (chargés depuis le disque)

Ces programmes sont des fichiers `.COM` exécutables :

| Programme | Fonction principale                          |
|-----------|----------------------------------------------|
| ASM       | Assembleur 8080                              |
| LOAD      | Convertit un fichier `.HEX` en `.COM`        |
| PIP       | Copie de fichiers, redirection, etc.         |
| ED        | Éditeur de texte en ligne                    |
| SYSGEN    | Installe CP/M sur un disque                  |
| SUBMIT    | Exécute un script de commandes `.SUB`        |
| DUMP      | Affiche le contenu hexadécimal d’un fichier  |
| MOVCPM    | Reconfigure CP/M pour une taille mémoire donnée |

---

## Appels système BDOS (Basic Disk Operating System)

Les programmes en assembleur peuvent appeler BDOS via :

```asm
CALL 0005h



LD C, 9          ; Code de la fonction BDOS (Print String)
LD DE, MSG       ; Adresse de la chaîne à afficher
CALL 0005h       ; Appel BDOS

MSG: DB 'Bonjour CP/M!$'
```

## Fonctions BDOS – CP/M 2.2


[BDOS calls](https://www.seasip.info/Cpm/bdos.html)


[cpm-2.2 Source, Manuals and Utilities](https://github.com/Z80-Retro/cpm-2.2) 





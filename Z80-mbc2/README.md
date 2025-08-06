# Z80-MBC2

Le [Z80-MBC2](https://hackaday.io/project/159973-z80-mbc2-a-4-ics-homebrew-z80-computer) est un ordinateur monocarte (SBC) Z80 facile à assembler avec une carte SD utilisée comme émulateur de disque, et une mémoire RAM de 128 Ko en mode banque pour CP/M 3 (mais il peut aussi faire tourner CP/M 2.2, QP/M 2.71, UCSD Pascal, Collapse OS et Fuzix).
La carte dispose en option d’un expandeur GPIO 16x intégré, et utilise des modules additionnels courants et peu coûteux pour les options SD et RTC.
Elle possède également un Atmega32A, utilisé comme EEPROM et comme émulateur d’E/S « universel »
C’est un véritable [écosystème de développement complet](https://hackaday.io/project/159973-z80-mbc2-a-4-ics-homebrew-z80-computer/details), et grâce au mode de démarrage iLoad, il est possible de compiler, charger et exécuter sur la cible un programme en assembleur ou en C (avec le compilateur SDCC) en une seule commande — comme dans l’environnement Arduino IDE.

```console
Z80-MBC2 - A040618
IOS - I/O Subsystem - S220718-R290823

IOS: Found extended serial Rx buffer
IOS: Z80 clock set at 4MHz
IOS: Found GPE Option
IOS: CP/M Autoexec is OFF

IOS: Select boot mode or system parameters:

 0: No change (1)
 1: Basic
 2: Forth
 3: Load/set OS Disk Set 0 (CP/M 2.2)
 4: Autoboot
 5: iLoad
 6: Change Z80 clock speed (->8MHz)
 7: Toggle CP/M Autoexec (->ON)
 8: Set serial port speed (115200)

Enter your choice >
>
```

![board](images/board.jpg "Main board")


## Quelques Exemples d'utilisation

- Allumer une led en BASIC

![led](images/led_on_off.gif "onoff")

```console
Allume la led sur GPA5 (MCP23017)
10 out 1,5
20 out 0,0
30 out 1,3
40 out 0,32
```

- Clignoter une led en BASIC via CP/M

![user](images/USER_LED.gif "user")

- Charger un fichier HEX intel avec CoolTerm sous linux ou Tera Term sous windows

![iload](images/iload.gif "iload")

## Exemple de code ASM

```asm
LOOP:	
		LD A, 0          ; Opcode pour écrire dans USERLED (0x00)
        OUT (1), A       
		LD A, 1          ; Allume USERLED
        OUT (0), A       

        CALL LONG_DELAY       ; Pause 500ms

		LD A, 0          ; Opcode pour écrire dans USERLED (0x00)
        OUT (1), A       
	    LD A, 0          ; Éteint USERLED
        OUT (0), A       

        CALL LONG_DELAY       ; Pause 500ms

        JP LOOP          ; Boucle infinie

LONG_DELAY:
    LD D, 50       ; compteur externe
EXTERN_WAIT:
    CALL DELAY     ; appelle délai de 10 ms
    DEC D
    JP NZ, EXTERN_WAIT
    RET
	
; --- Sous-programme DELAY 10ms ---
DELAY:  LD BC, 1665      ; Charge le compteur de boucle dans BC
WAIT:   DEC BC           ; Décrémente le compteur
        LD A, B          ; Charge B dans A
        OR C             ; Combine avec C — si BC != 0, résultat ≠ 0
        JP NZ, WAIT      ; Si BC ≠ 0, on recommence
        RET              ; Sinon, on revient au programme principal
```

## Assemblage avec TASM

```console
TASM Z80 Assembler.       Version 3.2 September, 2001.
 Copyright (C) 2001 Squak Valley Software
tasm: pass 1 complete.
tasm: pass 2 complete.
tasm: Number of errors = 0
TASM Z80 Assembler.       Version 3.2 September, 2001.
 Copyright (C) 2001 Squak Valley Software
tasm: pass 1 complete.
tasm: pass 2 complete.
tasm: Number of errors = 0
? Fichiers generes avec succes :
   - blink.hex
   - blink.bin
Appuyez sur une touche pour continuer...
```

## Résultat produit (contenu du fichier HEX intel)

```console
:100000003E00D3013E01D300CD19003E00D3013E96
:1000100000D300CD1900C300001632CD230015C255
:0D0020001B00C90181060B78B1C22600C982
:00000001FF
```

## Charger le fichier HEX avec le menu iload

```console
Z80-MBC2 - A040618
IOS - I/O Subsystem - S220718-R290823

IOS: Found extended serial Rx buffer
IOS: Z80 clock set at 4MHz
IOS: Found GPE Option
IOS: CP/M Autoexec is OFF

IOS: Select boot mode or system parameters:

 0: No change (1)
 1: Basic
 2: Forth
 3: Load/set OS Disk Set 0 (CP/M 2.2)
 4: Autoboot
 5: iLoad
 6: Change Z80 clock speed (->8MHz)
 7: Toggle CP/M Autoexec (->ON)
 8: Set serial port speed (115200)

Enter your choice >5  Ok
IOS: Loading boot program... Done
IOS: Z80 is running from now

iLoad - Intel-Hex Loader - S200718
Waiting input stream...
:180000003E00D3013E01D300CD19003E00D3013E00D300CD1900C30012
:13001800001632CD22001520FAC90181060B78B120FBC906
:00000001FF
iLoad: Starting Address: 0000
```

## STORE Opcode – I/O Write Address (0x01)

Le bit AD0 = 1 indique une opération d’écriture sur l’adresse I/O 0x01.  
Cette opération permet de **stocker un code d’opération I/O (Opcode)** et de **réinitialiser le compteur de bytes échangés**.

### 📝 Notes importantes :
1. Un Opcode peut être de lecture ou d’écriture, selon l’opération I/O.
2. L’opération STORE doit toujours **précéder** une opération EXECUTE WRITE ou EXECUTE READ.
3. Pour les Opcodes de lecture multi-octets (comme `DATETIME`), il faut lire les octets **séquentiellement** sans envoyer une nouvelle opération STORE après le premier octet.

---

## 🔧 Opcodes définis pour les opérations I/O **Write**

| Opcode     | Nom              | Octets échangés |
|------------|------------------|------------------|
| `0x00`     | USER LED         | 1                |
| `0x01`     | SERIAL TX        | 1                |
| `0x03`     | GPIOA Write      | 1                |
| `0x04`     | GPIOB Write      | 1                |
| `0x05`     | IODIRA Write     | 1                |
| `0x06`     | IODIRB Write     | 1                |
| `0x07`     | GPPUA Write      | 1                |
| `0x08`     | GPPUB Write      | 1                |
| `0x09`     | SELDISK          | 1                |
| `0x0A`     | SELTRACK         | 2                |
| `0x0B`     | SELSECT          | 1                |
| `0x0C`     | WRITESECT        | 512              |
| `0x0D`     | SETBANK          | 1                |
| `0x0E`     | SETIRQ           | 1                |
| `0x0F`     | SETTICK          | 1                |
| `0x10`     | SETOPT           | 1                |
| `0x11`     | SETSPP           | 1                |
| `0x12`     | WRSPP            | 1                |
| `0xFF`     | No operation     | 1                |

---

## 🔍 Opcodes définis pour les opérations I/O **Read**

| Opcode     | Nom              | Octets échangés |
|------------|------------------|------------------|
| `0x80`     | USER KEY         | 1                |
| `0x81`     | GPIOA Read       | 1                |
| `0x82`     | GPIOB Read       | 1                |
| `0x83`     | SYSFLAGS         | 1                |
| `0x84`     | DATETIME         | 7                |
| `0x85`     | ERRDISK          | 1                |
| `0x86`     | READSECT         | 512              |
| `0x87`     | SDMOUNT          | 1                |
| `0x88`     | ATXBUFF          | 1                |
| `0x89`     | SYSIRQ           | 1                |
| `0x8A`     | GETSPP           | 1                |
| `0xFF`     | No operation     | 1                |

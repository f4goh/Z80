
#define equ .equ
#define end .end
#define db  .db

LCDCLEAR:    equ 20h
LCDSETXY:    equ 21h
LCDWRITE:    equ 22h
LCDPRINT:    equ 23h


        LD A, LCDCLEAR   ; OUT 1, &H20
        OUT (1), A

        LD A, 1          ; OUT 0, 1
        OUT (0), A

        LD A, LCDSETXY        ; OUT 1, &H21
        OUT (1), A

        LD A, 4          ; OUT 0, 4
        OUT (0), A

        LD A, 1          ; OUT 0, 1
        OUT (0), A

        LD A, LCDPRINT        ; OUT 1, &H23
        OUT (1), A

        LD HL, message   ; HL pointe vers la chaîne "HELLO"
loop:
        LD A, (HL)       ; Charger le caractère
        CP 0             ; Fin de chaîne ?
        JR Z, endloop
        OUT (0), A       ; Envoyer caractère
        INC HL           ; Suivant
        JP loop

endloop:
        LD A, 0          ; OUT 0, 0
        OUT (0), A

        LD A, LCDWRITE        ; OUT 1, &H22
        OUT (1), A

        LD A, '!'        ; OUT 0, ASC("!")
        OUT (0), A

        JP $

message:
        db	"HELLO", 0    ; Chaîne terminée par 0

	end
		

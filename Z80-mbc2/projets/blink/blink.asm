
#define equ .equ
#define end .end

USERLED:    equ 00h


LOOP:	
	LD A, USERLED          ; Opcode pour écrire dans USERLED (0x00)
    OUT (1), A       
	LD A, 1          	; Allume USERLED
    OUT (0), A       

    CALL LONG_DELAY       ; Pause 500ms

	LD A, USERLED          ; Opcode pour écrire dans USERLED (0x00)
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
    JR NZ, EXTERN_WAIT
    RET
	
; --- Sous-programme DELAY 10ms ---
DELAY:
	LD BC, 1665      ; Charge le compteur de boucle dans BC
WAIT:
    DEC BC           ; Décrémente le compteur
    LD A, B          ; Charge B dans A
    OR C             ; Combine avec C — si BC != 0, résultat ≠ 0
    JR NZ, WAIT      ; Si BC ≠ 0, on recommence
    RET              ; Sinon, on revient au programme principal

	end
		

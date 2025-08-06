;--------------------------------------------------------
; File Created by SDCC : free open source ISO C Compiler
; Version 4.5.0 #15242 (MINGW64)
;--------------------------------------------------------
	.module Blink_MBC2
	
	.optsdcc -mz80 sdcccall(1)
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _putchar
	.globl _getchar
	.globl _puts
	.globl _printf
	.globl _message
	.globl _i
	.globl _c
	.globl _userKey
	.globl _userLed
	.globl _delay
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
_EXEC_OPCODE	=	0x0000
_STORE_OPCODE	=	0x0001
_SER_RX	=	0x0001
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_c::
	.ds 1
_i::
	.ds 2
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
_message::
	.ds 12
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area _DABS (ABS)
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area _HOME
	.area _GSINIT
	.area _GSFINAL
	.area _GSINIT
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area _HOME
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
;Blink_MBC2.c:134: char userKey()
;	---------------------------------
; Function userKey
; ---------------------------------
_userKey::
;Blink_MBC2.c:136: STORE_OPCODE = USRKEY;
	ld	a, #0x80
	out	(_STORE_OPCODE), a
;Blink_MBC2.c:137: c = EXEC_OPCODE;
	in	a, (_EXEC_OPCODE)
	ld	(_c+0), a
;Blink_MBC2.c:138: return c;
	ld	a, (_c)
;Blink_MBC2.c:139: }
	ret
;Blink_MBC2.c:141: void userLed(char c)
;	---------------------------------
; Function userLed
; ---------------------------------
_userLed::
	ld	c, a
;Blink_MBC2.c:143: STORE_OPCODE = USRLED;
	xor	a, a
	out	(_STORE_OPCODE), a
;Blink_MBC2.c:144: EXEC_OPCODE = c;
	ld	a, c
	out	(_EXEC_OPCODE), a
;Blink_MBC2.c:145: }
	ret
;Blink_MBC2.c:147: void delay(unsigned short d)
;	---------------------------------
; Function delay
; ---------------------------------
_delay::
	ld	iy, #-16
	add	iy, sp
	ld	sp, iy
	ex	de, hl
;Blink_MBC2.c:150: j= (unsigned long long) d * 1000;
	ld	iy, #8
	add	iy, sp
	ld	0 (iy), e
	ld	1 (iy), d
	xor	a, a
	ld	2 (iy), a
	ld	3 (iy), a
	ld	4 (iy), a
	ld	5 (iy), a
	ld	6 (iy), a
	ld	7 (iy), a
	ld	l, 6 (iy)
	ld	h, 7 (iy)
	push	hl
	ld	l, 4 (iy)
	ld	h, 5 (iy)
	push	hl
	ld	l, 2 (iy)
	ld	h, 3 (iy)
	push	hl
	ld	l, 0 (iy)
	ld	h, 1 (iy)
	push	hl
	ld	hl, #0x0000
	push	hl
	push	hl
	push	hl
	ld	hl, #0x03e8
	push	hl
;Blink_MBC2.c:151: for (i=0; i < j; i++ );
	ld	hl, #0x0010
	add	hl, sp
	push	hl
	call	__mullonglong
	ld	hl, #18
	add	hl, sp
	ld	sp, hl
	xor	a, a
	ld	iy, #8
	add	iy, sp
	ld	0 (iy), a
	ld	1 (iy), a
	ld	2 (iy), a
	ld	3 (iy), a
	ld	4 (iy), a
	ld	5 (iy), a
	ld	6 (iy), a
	ld	7 (iy), a
00103$:
	ld	hl, #0
	add	hl, sp
	ld	iy, #8
	add	iy, sp
	ld	a, 0 (iy)
	sub	a, (hl)
	ld	a, 1 (iy)
	inc	hl
	sbc	a, (hl)
	ld	a, 2 (iy)
	inc	hl
	sbc	a, (hl)
	ld	a, 3 (iy)
	inc	hl
	sbc	a, (hl)
	ld	a, 4 (iy)
	inc	hl
	sbc	a, (hl)
	ld	a, 5 (iy)
	inc	hl
	sbc	a, (hl)
	ld	a, 6 (iy)
	inc	hl
	sbc	a, (hl)
	ld	a, 7 (iy)
	inc	hl
	sbc	a, (hl)
	jr	NC, 00105$
	inc	0 (iy)
	jr	NZ, 00103$
	inc	1 (iy)
	jr	NZ, 00103$
	inc	2 (iy)
	jr	NZ, 00103$
	inc	3 (iy)
	jr	NZ, 00103$
	inc	4 (iy)
	jr	NZ, 00103$
	inc	5 (iy)
	jr	NZ, 00103$
	inc	6 (iy)
	jr	NZ, 00103$
	inc	7 (iy)
	jr	00103$
00105$:
;Blink_MBC2.c:152: }
	ld	hl, #16
	add	hl, sp
	ld	sp, hl
	ret
;Blink_MBC2.c:154: void main(void) { 
;	---------------------------------
; Function main
; ---------------------------------
_main::
;Blink_MBC2.c:155: printf("\n");
	ld	hl, #___str_1
	call	_puts
;Blink_MBC2.c:156: printf(message);
	ld	hl, #_message
	push	hl
	call	_printf
	pop	af
;Blink_MBC2.c:158: printf("\nJust some counts...\n\n");
	ld	hl, #___str_16
	call	_puts
;Blink_MBC2.c:159: for (i=0; i<11; i++) printf("I=%d\n", i);
	ld	hl, #0x0000
	ld	(_i), hl
00112$:
	ld	hl, (_i)
	push	hl
	ld	hl, #___str_5
	push	hl
	call	_printf
	pop	af
	pop	af
	ld	hl, (_i)
	inc	hl
	ld	(_i), hl
	ld	a, (_i+0)
	sub	a, #0x0b
	ld	a, (_i+1)
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	C, 00112$
;Blink_MBC2.c:161: printf("\nPress USER key to continue...");
	ld	hl, #___str_6
	push	hl
	call	_printf
	pop	af
;Blink_MBC2.c:162: while (userKey() == 0);
00102$:
	call	_userKey
	or	a, a
	jr	Z, 00102$
;Blink_MBC2.c:164: printf("\nPress 'b' to start blinking >");
	ld	hl, #___str_7
	push	hl
	call	_printf
	pop	af
;Blink_MBC2.c:165: do
00106$:
;Blink_MBC2.c:166: c = getchar();
	call	_getchar
	ld	hl, #_c
	ld	(hl), e
;Blink_MBC2.c:167: while ((c != 'b') && (c != 'B'));
	ld	a,(_c+0)
	cp	a,#0x62
	jr	Z, 00108$
	sub	a, #0x42
	jr	NZ, 00106$
00108$:
;Blink_MBC2.c:168: putchar('b');
	ld	hl, #0x0062
	call	_putchar
;Blink_MBC2.c:170: printf("\n\nAt last start blinking...");
	ld	hl, #___str_8
	push	hl
	call	_printf
	pop	af
;Blink_MBC2.c:171: delay(10);
	ld	hl, #0x000a
	call	_delay
;Blink_MBC2.c:173: printf ("%c[2J",27);                            // Clear screen
	ld	hl, #0x001b
	push	hl
	ld	hl, #___str_9
	push	hl
	call	_printf
	pop	af
;Blink_MBC2.c:174: printf ("%c[?25l",27);                          // Cursor invisible
	ld	hl, #0x001b
	ex	(sp),hl
	ld	hl, #___str_10
	push	hl
	call	_printf
	pop	af
	pop	af
;Blink_MBC2.c:175: while (1)
00110$:
;Blink_MBC2.c:177: userLed(1);                                 // User led on
	ld	a, #0x01
	call	_userLed
;Blink_MBC2.c:178: printf("\r");
	ld	hl, #___str_11
	push	hl
	call	_printf
;Blink_MBC2.c:179: printf ("%c[15;30H",27);
	ld	hl, #0x001b
	ex	(sp),hl
	ld	hl, #___str_12
	push	hl
	call	_printf
	pop	af
;Blink_MBC2.c:180: printf ("%c[7m * * LED on  * * ",27);       // Print reverse
	ld	hl, #0x001b
	ex	(sp),hl
	ld	hl, #___str_13
	push	hl
	call	_printf
	pop	af
	pop	af
;Blink_MBC2.c:181: delay(12);
	ld	hl, #0x000c
	call	_delay
;Blink_MBC2.c:182: printf ("%c[m",27);                         // Reset all attributes
	ld	bc, #___str_14+0
	ld	hl, #0x001b
	push	hl
	push	bc
	call	_printf
	pop	af
;Blink_MBC2.c:183: printf ("%c[15;30H",27);
	ld	hl, #0x001b
	ex	(sp),hl
	ld	hl, #___str_12
	push	hl
	call	_printf
	pop	af
	pop	af
;Blink_MBC2.c:184: printf (" * * LED off * * ");
	ld	bc, #___str_15+0
	push	bc
	call	_printf
	pop	af
;Blink_MBC2.c:185: userLed(0);                                 // User led off
	xor	a, a
	call	_userLed
;Blink_MBC2.c:186: delay(12);
	ld	hl, #0x000c
	call	_delay
;Blink_MBC2.c:188: } 
	jr	00110$
___str_1:
	.db 0x00
___str_5:
	.ascii "I=%d"
	.db 0x0a
	.db 0x00
___str_6:
	.db 0x0a
	.ascii "Press USER key to continue..."
	.db 0x00
___str_7:
	.db 0x0a
	.ascii "Press 'b' to start blinking >"
	.db 0x00
___str_8:
	.db 0x0a
	.db 0x0a
	.ascii "At last start blinking..."
	.db 0x00
___str_9:
	.ascii "%c[2J"
	.db 0x00
___str_10:
	.ascii "%c[?25l"
	.db 0x00
___str_11:
	.db 0x0d
	.db 0x00
___str_12:
	.ascii "%c[15;30H"
	.db 0x00
___str_13:
	.ascii "%c[7m * * LED on  * * "
	.db 0x00
___str_14:
	.ascii "%c[m"
	.db 0x00
___str_15:
	.ascii " * * LED off * * "
	.db 0x00
___str_16:
	.db 0x0a
	.db 0x0a
	.ascii "Just some counts..."
	.db 0x0a
	.db 0x00
	.area _CODE
	.area _INITIALIZER
__xinit__message:
	.ascii "Hello Folk!"
	.db 0x00
	.area _CABS (ABS)

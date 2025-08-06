;--------------------------------------------------------
; File Created by SDCC : free open source ISO C Compiler
; Version 4.5.0 #15242 (MINGW64)
;--------------------------------------------------------
	.module S290923_Z80_MBC2
	
	.optsdcc -mz80 sdcccall(1)
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _IM1_IRQ_ISR
	.globl _putchar
	.globl _getchar
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
_Exec_port	=	0x0000
_StorOpc_port	=	0x0001
_SerRx_port	=	0x0001
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_getchar_sysflags_10000_21:
	.ds 1
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
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
;S290923_Z80-MBC2.c:236: // Nothing to do as IRQ are disabled.
;	---------------------------------
; Function IM1_IRQ_ISR
; ---------------------------------
_IM1_IRQ_ISR::
;S290923_Z80-MBC2.c:241: 
	ret
;S290923_Z80-MBC2.c:243: {
;	---------------------------------
; Function putchar
; ---------------------------------
_putchar::
	ex	de, hl
;S290923_Z80-MBC2.c:245: // Is a LF
	ld	a, e
	sub	a, #0x0a
	or	a, d
	jr	NZ, 00102$
;S290923_Z80-MBC2.c:248: Exec_port = 0x0d;           // Print a CR before;
	ld	a, #0x01
	out	(_StorOpc_port), a
;S290923_Z80-MBC2.c:249: }
	ld	a, #0x0d
	out	(_Exec_port), a
00102$:
;S290923_Z80-MBC2.c:251: Exec_port = (char) (c);
	ld	a, #0x01
	out	(_StorOpc_port), a
;S290923_Z80-MBC2.c:252: return c;
	ld	a, e
	out	(_Exec_port), a
;S290923_Z80-MBC2.c:253: }
;S290923_Z80-MBC2.c:254: 
	ret
;S290923_Z80-MBC2.c:256: {
;	---------------------------------
; Function getchar
; ---------------------------------
_getchar::
;S290923_Z80-MBC2.c:259: {
00101$:
;S290923_Z80-MBC2.c:261: sysflags = Exec_port;       // Read IOS SYSFLAGS;
	ld	a, #0x83
	out	(_StorOpc_port), a
;S290923_Z80-MBC2.c:262: }
	in	a, (_Exec_port)
	ld	(_getchar_sysflags_10000_21+0), a
;S290923_Z80-MBC2.c:264: return SerRx_port;
	ld	a, (_getchar_sysflags_10000_21)
	bit	2, a
	jr	Z, 00101$
;S290923_Z80-MBC2.c:265: }
	in	a, (_SerRx_port)
	ld	e, a
	ld	d, #0x00
;S290923_Z80-MBC2.c:266: 
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)

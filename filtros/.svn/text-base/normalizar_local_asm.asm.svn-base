; void normalizar_local_asm (
; 	unsigned char *src,
; 	unsigned char *dst,
; 	int m,
; 	int n,
; 	int row_size
; );

global normalizar_local_asm

section .data
mask: DQ 0x00000000FFFFFFFF
maskUlt: DD 0x0, 0x0, 0x0, 0xFF000000
maskNoUlt: DD 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFF
maskPrim: DD 0x000000FF, 0x0, 0x0, 0x0
maskNoPrim: DD 0xFFFFFF00, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF


section .text



normalizar_local_asm:
	; *src en rdi
	; *dst en rsi
	; m en rdx
	; n en rcx
	; row_size en r8 


	PUSH rbp				;				Alinea
	MOV rbp, rsp
	
	PUSH rbx				; salva rbx		Desalinea
	PUSH r14				; salva r14		Alinea
	PUSH r15				; salva r15   	Desalinea
	SUB rsp, 8				; 				Alinea
	
	MOV rax, [mask]			; pone en rax lo que se usa como máscara
	AND rdx, rax			; máscara a rdx para dejar la parte baja únicamente
	AND rcx, rax			; máscara a rcx para dejar la parte baja únicamente
	AND r8, rax 			; máscara a r8 para dejar la parte baja únicamente
	
	MOV rbx, rsi			; salva momentáneamente a *dst
	MOV rsi, rdi			; pone en rsi a *src
	MOV rdi, rbx			; pone en rdi a *dst
	
	MOV r14, rcx			; pone en r14 el amcho
	MOV r15, rdx			; pone en r15 la altura
	SHR r14, 1				; guarda en r14 la mitad del ancho
	SHR r15, 1				; guarda en r15 la mitad de la altura
	MOV rbx, r14			; pasa momentáneamente r14 a rbx
	SHL r14, 32				; pone la parte baja en la parte alta
	ADD r14, rbx			; pone en la parte baja de r14 lo mismo que hay en la alta
	MOV rbx, r15			; pasa momentáneamente r15 a rbx
	SHL r15, 32				; pone la parte baja en la parte alta
	ADD r15, rbx			; pone en la parte baja de r15 lo mismo que hay en la alta
	
	
	MOV qword r14, 0		; en r14 está el ancho
	MOV qword r15, 0		; en r15 está el alto
	
;///////// Primera línea que queda como estaba

cicloAnchoNormPrim:
	MOV rbx, r14			; pone en rbx el ancho
	ADD rbx, 16				; deja en rbx a ancho+16
	CMP rbx, rcx			; compara ancho+16 con w
	JG faltaAlgoNormPrim
	CMP r14, rcx			; compara el ancho con w
	JE saleAnchoNormPrim

	MOVDQU xmm0, [rsi]		; carga en xmm0 16 bytes de src	
	MOVDQU [rdi], xmm0		; pasa a dst el resultado
	
	ADD rdi, 16				; pasa a los siguientes 16 bytes en rdi
	ADD rsi, 16				; pasa a los siguientes bytes en rsi
	ADD r14, 16				; aumenta 'ancho' en 16
	JMP cicloAnchoNormPrim
		
faltaAlgoNormPrim:
	MOV rbx, r14			; pone en rbx a ancho
	ADD rbx, 16				; deja en rbx a ancho+16
	SUB rbx, rcx			; deja en rbx a ancho-(w-16) o sea la diferencia que debo restar
	SUB rsi, rbx			; deja en rsi una pos tal que faltan 16 para terminar la fila
	SUB rdi, rbx			; ídem para rdi

	MOVDQU xmm0, [rsi]		; carga en xmm0 16 bytes de src
	MOVDQU [rdi], xmm0		; pasa a dst el resultado

	ADD rdi, 16				; pasa a los siguientes 16 bytes en rdi
	ADD rsi, 16				; pasa a los siguientes bytes en rsi
	ADD r14, 16				; aumenta 'ancho' en 16	
saleAnchoNormPrim:
	ADD rsi, r8				; aumenta a rsi el row_size
	SUB rsi, rcx			; resta a rsi el w
	ADD rdi, r8				; aumenta a rdi el row_size
	SUB rdi, rcx			; resta a rdi el w
	MOV qword r14, 0		; pone nuevamente el ancho en 0
	INC r15					; aumenta en 1 el alto
	
	
	
;///// Resto de la imagen	
	
		
	
cicloAltoNorm:
	MOV rbx, r15			; pone en rbx el alto
	LEA rbx, [rbx+2]		; aumenta en 2 el alto
	CMP rbx, rdx			; compara alto+2 con h
	JG saleAltoNorm

			;// Primer tirada pone como primer byte al original

			; código
				MOVDQU xmm0, [rsi]		; carga en xmm0 a la línea central
				MOV rbx, rsi			; pone en rbx a rsi
				SUB rbx, r8				; resta el row_size
				MOVDQU xmm1, [rbx]		; carga en xmm1 a la línea superior
				LEA rbx, [rsi + r8]		; coloca en rbx la posición de una línea antes
				MOVDQU xmm2, [rbx]		; carga en xmm2 a la línea inferior
				
				PXOR xmm15, xmm15		; limpia xmm5 para usarlo para desempaquetar
				
				; Primeros 4
				MOVDQU xmm4, xmm0		; pone en xmm4 una copia de la central
				PUNPCKHBW xmm4, xmm15	; deja en xmm4 los primeros 8 de la línea central
				PUNPCKHWD xmm4, xmm15	; deja en xmm4 los primeros 4 ints de la línea central
				CVTDQ2PS xmm4, xmm4		; convierte los ints en floats
				MOVDQU xmm8, xmm4		; pone una copia de éstos en xmm8
				
				MOVDQU xmm13, xmm1		; pone en xmm13 una copia de la inferior
				PUNPCKHBW xmm13, xmm15	; deja en xmm13 los primeros 8 de la línea inferior
				PUNPCKHWD xmm13, xmm15	; deja en xmm13 los primeros 4 ints de la línea inferior
				CVTDQ2PS xmm13, xmm13	; convierte los ints en floats
				
				MOVDQU xmm14, xmm2		; pone en xmm14 una copia de la superior
				PUNPCKHBW xmm14, xmm15	; deja en xmm14 los primeros 8 de la línea superior
				PUNPCKHWD xmm14, xmm15	; deja en xmm14 los primeros 4 ints de la línea superior
				CVTDQ2PS xmm14, xmm14	; convierte los ints en floats 
				
				MAXPS xmm8, xmm13
				MAXPS xmm8, xmm14		; deja en xmm8 los máximos de columna de los floats 16,15,14,13
				
				MINPS xmm4, xmm13
				MINPS xmm4, xmm14		; deja en xmm4 los mínimos de columna de los floats 16,15,14,13
				
				; Segundos 4
				MOVDQU xmm5, xmm0		; pone en xmm5 una copia de la central
				PUNPCKHBW xmm5, xmm15	; deja en xmm5 los primeros 8 de la línea central
				PUNPCKLWD xmm5, xmm15	; deja en xmm5 los segundos 4 ints de la línea central
				CVTDQ2PS xmm5, xmm5		; convierte los ints en floats
				MOVDQU xmm9, xmm5		; pone una copia de éstos en xmm9
				
				MOVDQU xmm13, xmm1		; pone en xmm13 una copia de la inferior
				PUNPCKHBW xmm13, xmm15	; deja en xmm13 los primeros 8 de la línea inferior
				PUNPCKLWD xmm13, xmm15	; deja en xmm13 los segundos 4 de la línea inferior
				CVTDQ2PS xmm13, xmm13	; convierte los ints en floats
				
				MOVDQU xmm14, xmm2		; pone en xmm14 una copia de la superior
				PUNPCKHBW xmm14, xmm15	; deja en xmm14 los primeros 8 de la línea superior
				PUNPCKLWD xmm14, xmm15	; deja en xmm14 los segundos 4 de la línea superior
				CVTDQ2PS xmm14, xmm14	; convierte los ints en floats 
				
				MAXPS xmm9, xmm13
				MAXPS xmm9, xmm14		; deja en xmm9 los máximos de columna de los floats 12,11,10,9
				
				MINPS xmm5, xmm13
				MINPS xmm5, xmm14		; deja en xmm5 los mínimos de columna de los floats 12,11,10,9
				
				; Terceros 4
				MOVDQU xmm6, xmm0		; pone en xmm6 una copia de la central
				PUNPCKLBW xmm6, xmm15	; deja en xmm6 los segundos 8 de la línea central
				PUNPCKHWD xmm6, xmm15	; deja en xmm6 los primeros 4 ints de la línea central
				CVTDQ2PS xmm6, xmm6		; convierte los ints en floats
				MOVDQU xmm10, xmm6		; pone una copia de éstos en xmm10
				
				MOVDQU xmm13, xmm1		; pone en xmm13 una copia de la inferior
				PUNPCKLBW xmm13, xmm15	; deja en xmm13 los segundos 8 de la línea inferior
				PUNPCKHWD xmm13, xmm15	; deja en xmm13 los primeros 4 de la línea inferior
				CVTDQ2PS xmm13, xmm13	; convierte los ints en floats
				
				MOVDQU xmm14, xmm2		; pone en xmm14 una copia de la superior
				PUNPCKLBW xmm14, xmm15	; deja en xmm14 los segundos 8 de la línea superior
				PUNPCKHWD xmm14, xmm15	; deja en xmm14 los primeros 4 de la línea superior
				CVTDQ2PS xmm14, xmm14	; convierte los ints en floats 
				
				MAXPS xmm10, xmm13
				MAXPS xmm10, xmm14		; deja en xmm10 los máximos de columna de los floats 8,7,6,5
				
				MINPS xmm6, xmm13
				MINPS xmm6, xmm14		; deja en xmm6 los mínimos de columna de los floats 8,7,6,5
				
				
				; Cuartos 4
				MOVDQU xmm7, xmm0		; pone en xmm6 una copia de la central
				PUNPCKLBW xmm7, xmm15	; deja en xmm6 los segundos 8 de la línea central
				PUNPCKLWD xmm7, xmm15	; deja en xmm6 los segundos 4 ints de la línea central
				CVTDQ2PS xmm7, xmm7		; convierte los ints en floats
				MOVDQU xmm11, xmm7		; pone una copia de éstos en xmm11
				
				MOVDQU xmm13, xmm1		; pone en xmm13 una copia de la inferior
				PUNPCKLBW xmm13, xmm15	; deja en xmm13 los segundos 8 de la línea inferior
				PUNPCKLWD xmm13, xmm15	; deja en xmm13 los segundos 4 de la línea inferior
				CVTDQ2PS xmm13, xmm13	; convierte los ints en floats
				
				MOVDQU xmm14, xmm2		; pone en xmm14 una copia de la superior
				PUNPCKLBW xmm14, xmm15	; deja en xmm14 los segundos 8 de la línea superior
				PUNPCKLWD xmm14, xmm15	; deja en xmm14 los segundos 4 de la línea superior
				CVTDQ2PS xmm14, xmm14	; convierte los ints en floats 
				
				MAXPS xmm11, xmm13
				MAXPS xmm11, xmm14		; deja en xmm10 los máximos de columna de los floats 4,3,2,1
				
				MINPS xmm7, xmm13
				MINPS xmm7, xmm14		; deja en xmm7 los mínimos de columna de los floats 4,3,2,1


				; Deja en xmm12, xmm13, xmm14, xmm15 los valores centrales
				PXOR xmm1, xmm1			; limpia xmm1 para usarlo para desempaquetar
				MOVDQU xmm12, xmm0		; pone en xmm12 a xmm0 para desempaquetar
				MOVDQU xmm13, xmm0		; pone en xmm13 a xmm0 para desempaquetar
				MOVDQU xmm14, xmm0		; pone en xmm14 a xmm0 para desempaquetar
				MOVDQU xmm15, xmm0		; pone en xmm15 a xmm0 para desempaquetar
				PUNPCKHBW xmm12, xmm1	; pone en xmm12 los primeros 8 de la línea central
				PUNPCKHBW xmm13, xmm1	; pone en xmm13 los primeros 8 de la línea central
				PUNPCKLBW xmm14, xmm1	; pone en xmm14 los segundos 8 de la línea central
				PUNPCKLBW xmm15, xmm1	; pone en xmm15 los segundos 8 de la línea central
				PUNPCKHWD xmm12, xmm1	; pone en xmm12 los primeros 4 de la línea central
				PUNPCKLWD xmm13, xmm1	; pone en xmm13 los segundos 4 de la línea central
				PUNPCKHWD xmm14, xmm1	; pone en xmm14 los terceros 4 de la línea central
				PUNPCKLWD xmm15, xmm1	; pone en xmm15 los cuartos 4 de la línea central
				CVTDQ2PS xmm12, xmm12	; deja en xmm12 los ints converitos en floats
				CVTDQ2PS xmm13, xmm13	; deja en xmm13 los ints converitos en floats
				CVTDQ2PS xmm14, xmm14	; deja en xmm14 los ints converitos en floats
				CVTDQ2PS xmm15, xmm15	; deja en xmm15 los ints converitos en floats
				
				
				MOVDQU xmm3, xmm0		; deja en xmm3 la línea central para usarla después sin repetir el acceso a memoria
				
				
				; Divide los source por los máximos M15, M14, M13, M12, M11, M10, M9, M8, M7, M6, M5, M4, M3, M2, M1
				; Se tiene:
				; xmm8 = (máx16, máx15, máx14, máx13)
				; xmm9 = (máx12, máx11, máx10, máx9)
				; xmm10 = (máx8, máx7, máx6, máx5)
				; xmm11 = (máx4, máx3, máx2, máx1)
				
				
				; X M15 M14 M13
				MOVDQU xmm0, xmm9		; pone en xmm0 a (máx12, máx11, máx10, máx9)
				PSRLDQ xmm0, 12			; mueve a derecha 12 bytes (6 words) o sea 3 floats y queda (0, 0, 0, máx12)
				MOVDQU xmm1, xmm8		; pone en xmm1 a (máx16, máx15, máx14, máx13)
				PSLLDQ xmm1, 4			; mueve a izquierda 4 bytes (2 words) o sea 1 float y queda (máx15, máx14, máx13, 0)
				ADDPS xmm0, xmm1			; deja en xmm0 a (máx15, máx14, máx13, máx12)
				MOVDQU xmm1, xmm8		; pone en xmm1 a (máx16, máx15, máx14, máx13)
				MOVDQU xmm2, xmm8		; pone en xmm2 a (máx16, máx15, máx14, máx13)
				PSRLDQ xmm2, 4			; mueve a derecha 4 bytes (2 words) o sea 1 float y queda (0, máx16, máx15, máx14)
				; (máx15, máx14, máx13, máx12)
				; (máx16, máx15, máx14, máx13)
				; (0, máx16, máx15, máx14)
				MAXPS xmm0, xmm1
				MAXPS xmm0, xmm2		; deja en xmm0 a los máximos (X, M15, M14, M13)
				DIVPS xmm12, xmm0		; divide cada valor del source (16, 15, 14, 13) por (X, M15, M14, M13)
				
				
				; M12 M11 M10 M9
				MOVDQU xmm0, xmm10		; pone en xmm0 a (máx8, máx7, máx6, máx5)
				PSRLDQ xmm0, 12			; mueve a derecha 12 bytes (6 words) o sea 3 floats y queda (0, 0, 0, máx8)
				MOVDQU xmm1, xmm9		; pone en xmm1 a (máx12, máx11, máx10, máx9)
				PSLLDQ xmm1, 4			; mueve a izquierda 4 bytes (2 words) o sea 1 float y queda (máx11, máx10, máx9, 0)
				ADDPS xmm0, xmm1			; deja en xmm0 a (máx11, máx10, máx9, máx8)
				MOVDQU xmm2, xmm8		; pone en xmm2 a (máx16, máx15, máx14, máx13)
				PSLLDQ xmm2, 12			; mueve a izquierda 12 bytes (6 words) o sea 3 floats y queda (máx13, 0, 0, 0)
				MOVDQU xmm1, xmm9		; pone en xmm1 a (máx12, máx11, máx10, máx9)
				PSRLDQ xmm1, 4			; mueve a derecha 4 bytes (2 word) o sea 1 float y queda (0, máx12, máx11, máx10)
				ADDPS xmm2, xmm1			; deja en xmm2 a (máx13, máx12, máx11, máx10)
				MOVDQU xmm1, xmm9		; pone en xmm1 a (máx12, máx11, máx10, máx9)
				; (máx11, máx10, máx9, máx8)
				; (máx12, máx11, máx10, máx9)
				; (máx13, máx12, máx11, máx10)
				MAXPS xmm0, xmm1
				MAXPS xmm0, xmm2		; deja en xmm0 a los máximos (M12, M11, M10, M9)
				DIVPS xmm13, xmm0		; divide cada valor del source (12, 11, 10, 9) por (M12, M11, M10, M9)
				
				
				; M8 M7 M6 M5
				MOVDQU xmm0, xmm11		; pone en xmm0 a (máx4, máx3, máx2, máx1)
				PSRLDQ xmm0, 12			; mueve a derecha 12 bytes (6 words) o sea 3 floats y queda (0, 0, 0, máx4)
				MOVDQU xmm1, xmm10		; pone en xmm1 a (máx8, máx7, máx6, máx5)
				PSLLDQ xmm1, 4			; mueve a izquierda 4 bytes (2 words) o sea 1 float y queda (máx7, máx6, máx5, 0)
				ADDPS xmm0, xmm1			; deja en xmm0 a (máx7, máx6, máx5, máx4)
				MOVDQU xmm2, xmm9		; pone en xmm2 a (máx12, máx11, máx10, máx9)
				PSLLDQ xmm2, 12			; mueve a izquierda 12 bytes (6 words) o sea 3 floats y queda (máx9, 0, 0, 0)
				MOVDQU xmm1, xmm10		; pone en xmm1 a (máx8, máx7, máx6, máx5)
				PSRLDQ xmm1, 4			; mueve a derecha 4 bytes (2 word) o sea 1 float y queda (0, máx8, máx7, máx6)
				ADDPS xmm2, xmm1			; deja en xmm2 a (máx9, máx8, máx7, máx6)
				MOVDQU xmm1, xmm10		; pone en xmm1 a (máx8, máx7, máx6, máx5)
				; (máx7, máx6, máx5, máx4)
				; (máx8, máx7, máx6, máx5)
				; (máx9, máx8, máx7, máx6)
				MAXPS xmm0, xmm1
				MAXPS xmm0, xmm2		; deja en xmm0 a los máximos (M8, M7, M6, M5)
				DIVPS xmm14, xmm0		; divide cada valor del source (8, 7, 6, 5) por (M8, M7, M6, M5)

				
				; M4 M3 M2 M1
				MOVDQU xmm0, xmm11		; pone en xmm0 a (máx4, máx3, máx2, máx1)
				PSLLDQ xmm0, 4			; mueve a izquierda 4 bytes (2 words) o sea 1 float y queda (máx3, máx2, máx1, 0)
				MOVDQU xmm1, xmm10		; pone en xmm1 a (máx8, máx7, máx6, máx5)
				PSLLDQ xmm1, 12			; mueve a izquierda 12 bytes (6 words) o sea 3 floats y queda (máx5, 0, 0, 0)
				MOVDQU xmm2, xmm11		; pone en xmm2 a (máx4, máx3, máx2, máx1)
				PSRLDQ xmm2, 4			; mueve a derecha 4 bytes (2 word) o sea 1 float y queda (0, máx4, máx3, máx2)
				ADDPS xmm2, xmm1			; deja en xmm2 a (máx5, máx4, máx3, máx2)
				MOVDQU xmm1, xmm11		; pone en xmm1 a (máx4, máx3, máx2, máx1)
				; (máx3, máx2, máx1, 0)
				; (máx4, máx3, máx2, máx1)
				; (máx5, máx4, máx3, máx2)
				MAXPS xmm0, xmm1
				MAXPS xmm0, xmm2		; deja en xmm0 a los máximos (M4, M3, M2, M1)
				DIVPS xmm15, xmm0		; divide cada valor del source (4, 3, 2, 1) por (M4, M3, M2, X)
				
				
				
				
				; Suma a lo obtenido antes los mínimos m15, m14, m13, m12, m11, m10, m9, m8, m7, m6, m5, m4, m3, m2, m1
				; Se tiene:
				; xmm4 = (mín16, mín15, mín14, mín13)
				; xmm5 = (mín12, mín11, mín10, mín9)
				; xmm6 = (mín8, mín7, mín6, mín5)
				; xmm7 = (mín4, mín3, mín2, mín1)
				
				
				; X m15 m14 m13
				MOVDQU xmm0, xmm5		; pone en xmm0 a (mín12, mín11, mín10, mín9)
				PSRLDQ xmm0, 12			; mueve a derecha 12 bytes (6 words) o sea 3 floats y queda (0, 0, 0, mín12)
				MOVDQU xmm1, xmm4		; pone en xmm1 a (mín16, mín15, mín14, mín13)
				PSLLDQ xmm1, 4			; mueve a izquierda 4 bytes (2 words) o sea 1 float y queda (mín15, mín14, mín13, 0)
				ADDPS xmm0, xmm1			; deja en xmm0 a (mín15, mín14, mín13, mín12)
				MOVDQU xmm1, xmm4		; pone en xmm1 a (mín16, mín15, mín14, mín13)
				MOVDQU xmm2, xmm4		; pone en xmm2 a (mín16, mín15, mín14, mín13)
				PSRLDQ xmm2, 4			; mueve a derecha 4 bytes (2 words) o sea 1 float y queda (0, mín16, mín15, mín14)
				; (mín15, mín14, mín13, mín12)
				; (mín16, mín15, mín14, mín13)
				; (0, mín16, mín15, mín14)
				MINPS xmm0, xmm1
				MINPS xmm0, xmm2		; deja en xmm0 a los mínimos (X, m15, m14, m13)
				ADDPS xmm12, xmm0		; suma cada valor del source (16, 15, 14, 13) a (X, m15, m14, m13)
				
				
				; m12 m11 m10 m9
				MOVDQU xmm0, xmm6		; pone en xmm0 a (mín8, mín7, mín6, mín5)
				PSRLDQ xmm0, 12			; mueve a derecha 12 bytes (6 words) o sea 3 floats y queda (0, 0, 0, mín8)
				MOVDQU xmm1, xmm5		; pone en xmm1 a (mín12, mín11, mín10, mín9)
				PSLLDQ xmm1, 4			; mueve a izquierda 4 bytes (2 words) o sea 1 float y queda (mín11, mín10, mín9, 0)
				ADDPS xmm0, xmm1			; deja en xmm0 a (mín11, mín10, mín9, mín8)
				MOVDQU xmm2, xmm4		; pone en xmm2 a (mín16, mín15, mín14, mín13)
				PSLLDQ xmm2, 12			; mueve a izquierda 12 bytes (6 words) o sea 3 floats y queda (mín13, 0, 0, 0)
				MOVDQU xmm1, xmm5		; pone en xmm1 a (mín12, mín11, mín10, mín9)
				PSRLDQ xmm1, 4			; mueve a derecha 4 bytes (2 word) o sea 1 float y queda (0, mín12, mín11, mín10)
				ADDPS xmm2, xmm1			; deja en xmm2 a (mín13, mín12, mín11, mín10)
				MOVDQU xmm1, xmm5		; pone en xmm1 a (mín12, mín11, mín10, mín9)
				; (mín11, mín10, mín9, mín8)
				; (mín12, mín11, mín10, mín9)
				; (mín13, mín12, mín11, mín10)
				MINPS xmm0, xmm1
				MINPS xmm0, xmm2		; deja en xmm0 a los mínimo (m12, m11, m10, m9)
				ADDPS xmm13, xmm0		; suma cada valor del source (12, 11, 10, 9) a (m12, m11, m10, m9)
				
				
				; m8 m7 m6 m5
				MOVDQU xmm0, xmm7		; pone en xmm0 a (mín4, mín3, mín2, mín1)
				PSRLDQ xmm0, 12			; mueve a derecha 12 bytes (6 words) o sea 3 floats y queda (0, 0, 0, mín4)
				MOVDQU xmm1, xmm6		; pone en xmm1 a (mín8, mín7, mín6, mín5)
				PSLLDQ xmm1, 4			; mueve a izquierda 4 bytes (2 words) o sea 1 float y queda (mín7, mín6, mín5, 0)
				ADDPS xmm0, xmm1			; deja en xmm0 a (mín7, mín6, mín5, mín4)
				MOVDQU xmm2, xmm5		; pone en xmm2 a (mín12, mín11, mín10, mín9)
				PSLLDQ xmm2, 12			; mueve a izquierda 12 bytes (6 words) o sea 3 floats y queda (mín9, 0, 0, 0)
				MOVDQU xmm1, xmm6		; pone en xmm1 a (mín8, mín7, mín6, mín5)
				PSRLDQ xmm1, 4			; mueve a derecha 4 bytes (2 word) o sea 1 float y queda (0, mín8, mín7, mín6)
				ADDPS xmm2, xmm1			; deja en xmm2 a (mín9, mín8, mín7, mín6)
				MOVDQU xmm1, xmm6		; pone en xmm1 a (mín8, mín7, mín6, mín5)
				; (mín7, mín6, mín5, mín4)
				; (mín8, mín7, mín6, mín5)
				; (mín9, mín8, mín7, mín6)
				MINPS xmm0, xmm1
				MINPS xmm0, xmm2		; deja en xmm0 a los mínimos (m8, m7, m6, m5)
				ADDPS xmm14, xmm0		; suma cada valor del source (8, 7, 6, 5) a (m8, m7, m6, m5)

				
				; m4 m3 m2 m1
				MOVDQU xmm0, xmm7		; pone en xmm0 a (mín4, mín3, mín2, mín1)
				PSLLDQ xmm0, 4			; mueve a izquierda 4 bytes (2 words) o sea 1 float y queda (mín3, mín2, mín1, 0)
				MOVDQU xmm1, xmm6		; pone en xmm1 a (mín8, mín7, mín6, mín5)
				PSLLDQ xmm1, 12			; mueve a izquierda 12 bytes (6 words) o sea 3 floats y queda (mín5, 0, 0, 0)
				MOVDQU xmm2, xmm7		; pone en xmm2 a (mín4, mín3, mín2, mín1)
				PSRLDQ xmm2, 4			; mueve a derecha 4 bytes (2 word) o sea 1 float y queda (0, mín4, mín3, mín2)
				ADDPS xmm2, xmm1			; deja en xmm2 a (mín5, mín4, mín3, mín2)
				MOVDQU xmm1, xmm7		; pone en xmm1 a (mín4, mín3, mín2, mín1)
				; (mín3, mín2, mín1, 0)
				; (mín4, mín3, mín2, mín1)
				; (mín5, mín4, mín3, mín2)
				MINPS xmm0, xmm1
				MINPS xmm0, xmm2		; deja en xmm0 a los mínimos (m4, m3, m2, m1)
				ADDPS xmm15, xmm0		; suma cada valor del source (4, 3, 2, 1) a (m4, m3, m2, X)
			
	
				
				CVTPS2DQ xmm12, xmm12	; pasa el float a int
				CVTPS2DQ xmm13, xmm13	; pasa el float a int
				CVTPS2DQ xmm14, xmm14	; pasa el float a int
				CVTPS2DQ xmm15, xmm15	; pasa el float a int
				
				
				PACKUSDW xmm13, xmm12	; empaqueta los altos para ponerlos en rdi
				PACKUSDW xmm15, xmm14	; empaqueta los bajos para ponerlos en rdi
				
				PACKUSWB xmm15, xmm13	; empaqueta a bytes y se tiene la salida
				
				MOVDQU xmm0, xmm3		; pone la línea central en xmm0
				MOVDQU xmm1, [maskUlt]	; pone en xmm1 la máscara
				PAND xmm0, xmm1		 	; deja el último byte únicamente
				MOVDQU xmm1, [maskNoUlt]; pone en xmm1 la máscara
				PAND xmm15, xmm1 		; deja todos los bytes salvo el último
				
				PADDB xmm0, xmm15		; deja en xmm0 (basura, dato14, dato13, dato12, dato11, dato10, dato9, dato8, dato7, dato6, dato5, dato4, dato3, dato2, original) 
					
				MOVDQU [rdi], xmm0

	; Avanza rsi y dsi 16 lugares
	; Retrocede rsi 2 lugares para poder leer dos elementos antes y procesar el último que antes es basura
	; Retrocede rdi 1 lugar para pisar el byte basura que colocó antes
	ADD rsi, 14
	ADD rdi, 15

	ADD r14, 15				; aumenta 'ancho' en 15

cicloAnchoNorm:
	MOV rbx, r14			; pone en rbx el ancho
	ADD rbx, 16				; deja en rbx a ancho+16
	CMP rbx, rcx			; compara ancho+16 con w
	JG faltaAlgoNorm		; faltan 15 ó menos
	CMP r14, rcx			; compara el ancho con w
	JE saleAnchoNorm

				; código
					MOVDQU xmm0, [rsi]		; carga en xmm0 a la línea central
					MOV rbx, rsi			; pone en rbx a rsi
					SUB rbx, r8				; resta el row_size
					MOVDQU xmm1, [rbx]		; carga en xmm1 a la línea superior
					LEA rbx, [rsi + r8]		; coloca en rbx la posición de una línea antes
					MOVDQU xmm2, [rbx]		; carga en xmm2 a la línea inferior
					
					PXOR xmm15, xmm15		; limpia xmm5 para usarlo para desempaquetar
					
					; Primeros 4
					MOVDQU xmm4, xmm0		; pone en xmm4 una copia de la central
					PUNPCKHBW xmm4, xmm15	; deja en xmm4 los primeros 8 de la línea central
					PUNPCKHWD xmm4, xmm15	; deja en xmm4 los primeros 4 ints de la línea central
					CVTDQ2PS xmm4, xmm4		; convierte los ints en floats
					MOVDQU xmm8, xmm4		; pone una copia de éstos en xmm8
					
					MOVDQU xmm13, xmm1		; pone en xmm13 una copia de la inferior
					PUNPCKHBW xmm13, xmm15	; deja en xmm13 los primeros 8 de la línea inferior
					PUNPCKHWD xmm13, xmm15	; deja en xmm13 los primeros 4 ints de la línea inferior
					CVTDQ2PS xmm13, xmm13	; convierte los ints en floats
					
					MOVDQU xmm14, xmm2		; pone en xmm14 una copia de la superior
					PUNPCKHBW xmm14, xmm15	; deja en xmm14 los primeros 8 de la línea superior
					PUNPCKHWD xmm14, xmm15	; deja en xmm14 los primeros 4 ints de la línea superior
					CVTDQ2PS xmm14, xmm14	; convierte los ints en floats 
					
					MAXPS xmm8, xmm13
					MAXPS xmm8, xmm14		; deja en xmm8 los máximos de columna de los floats 16,15,14,13
					
					MINPS xmm4, xmm13
					MINPS xmm4, xmm14		; deja en xmm4 los mínimos de columna de los floats 16,15,14,13
					
					; Segundos 4
					MOVDQU xmm5, xmm0		; pone en xmm5 una copia de la central
					PUNPCKHBW xmm5, xmm15	; deja en xmm5 los primeros 8 de la línea central
					PUNPCKLWD xmm5, xmm15	; deja en xmm5 los segundos 4 ints de la línea central
					CVTDQ2PS xmm5, xmm5		; convierte los ints en floats
					MOVDQU xmm9, xmm5		; pone una copia de éstos en xmm9
					
					MOVDQU xmm13, xmm1		; pone en xmm13 una copia de la inferior
					PUNPCKHBW xmm13, xmm15	; deja en xmm13 los primeros 8 de la línea inferior
					PUNPCKLWD xmm13, xmm15	; deja en xmm13 los segundos 4 de la línea inferior
					CVTDQ2PS xmm13, xmm13	; convierte los ints en floats
					
					MOVDQU xmm14, xmm2		; pone en xmm14 una copia de la superior
					PUNPCKHBW xmm14, xmm15	; deja en xmm14 los primeros 8 de la línea superior
					PUNPCKLWD xmm14, xmm15	; deja en xmm14 los segundos 4 de la línea superior
					CVTDQ2PS xmm14, xmm14	; convierte los ints en floats 
					
					MAXPS xmm9, xmm13
					MAXPS xmm9, xmm14		; deja en xmm9 los máximos de columna de los floats 12,11,10,9
					
					MINPS xmm5, xmm13
					MINPS xmm5, xmm14		; deja en xmm5 los mínimos de columna de los floats 12,11,10,9
					
					; Terceros 4
					MOVDQU xmm6, xmm0		; pone en xmm6 una copia de la central
					PUNPCKLBW xmm6, xmm15	; deja en xmm6 los segundos 8 de la línea central
					PUNPCKHWD xmm6, xmm15	; deja en xmm6 los primeros 4 ints de la línea central
					CVTDQ2PS xmm6, xmm6		; convierte los ints en floats
					MOVDQU xmm10, xmm6		; pone una copia de éstos en xmm10
					
					MOVDQU xmm13, xmm1		; pone en xmm13 una copia de la inferior
					PUNPCKLBW xmm13, xmm15	; deja en xmm13 los segundos 8 de la línea inferior
					PUNPCKHWD xmm13, xmm15	; deja en xmm13 los primeros 4 de la línea inferior
					CVTDQ2PS xmm13, xmm13	; convierte los ints en floats
					
					MOVDQU xmm14, xmm2		; pone en xmm14 una copia de la superior
					PUNPCKLBW xmm14, xmm15	; deja en xmm14 los segundos 8 de la línea superior
					PUNPCKHWD xmm14, xmm15	; deja en xmm14 los primeros 4 de la línea superior
					CVTDQ2PS xmm14, xmm14	; convierte los ints en floats 
					
					MAXPS xmm10, xmm13
					MAXPS xmm10, xmm14		; deja en xmm10 los máximos de columna de los floats 8,7,6,5
					
					MINPS xmm6, xmm13
					MINPS xmm6, xmm14		; deja en xmm6 los mínimos de columna de los floats 8,7,6,5
					
					
					; Cuartos 4
					MOVDQU xmm7, xmm0		; pone en xmm6 una copia de la central
					PUNPCKLBW xmm7, xmm15	; deja en xmm6 los segundos 8 de la línea central
					PUNPCKLWD xmm7, xmm15	; deja en xmm6 los segundos 4 ints de la línea central
					CVTDQ2PS xmm7, xmm7		; convierte los ints en floats
					MOVDQU xmm11, xmm7		; pone una copia de éstos en xmm11
					
					MOVDQU xmm13, xmm1		; pone en xmm13 una copia de la inferior
					PUNPCKLBW xmm13, xmm15	; deja en xmm13 los segundos 8 de la línea inferior
					PUNPCKLWD xmm13, xmm15	; deja en xmm13 los segundos 4 de la línea inferior
					CVTDQ2PS xmm13, xmm13	; convierte los ints en floats
					
					MOVDQU xmm14, xmm2		; pone en xmm14 una copia de la superior
					PUNPCKLBW xmm14, xmm15	; deja en xmm14 los segundos 8 de la línea superior
					PUNPCKLWD xmm14, xmm15	; deja en xmm14 los segundos 4 de la línea superior
					CVTDQ2PS xmm14, xmm14	; convierte los ints en floats 
					
					MAXPS xmm11, xmm13
					MAXPS xmm11, xmm14		; deja en xmm10 los máximos de columna de los floats 4,3,2,1
					
					MINPS xmm7, xmm13
					MINPS xmm7, xmm14		; deja en xmm7 los mínimos de columna de los floats 4,3,2,1


					; Deja en xmm12, xmm13, xmm14, xmm15 los valores centrales
					PXOR xmm1, xmm1			; limpia xmm1 para usarlo para desempaquetar
					MOVDQU xmm12, xmm0		; pone en xmm12 a xmm0 para desempaquetar
					MOVDQU xmm13, xmm0		; pone en xmm13 a xmm0 para desempaquetar
					MOVDQU xmm14, xmm0		; pone en xmm14 a xmm0 para desempaquetar
					MOVDQU xmm15, xmm0		; pone en xmm15 a xmm0 para desempaquetar
					PUNPCKHBW xmm12, xmm1	; pone en xmm12 los primeros 8 de la línea central
					PUNPCKHBW xmm13, xmm1	; pone en xmm13 los primeros 8 de la línea central
					PUNPCKHBW xmm14, xmm1	; pone en xmm14 los segundos 8 de la línea central
					PUNPCKHBW xmm15, xmm1	; pone en xmm15 los segundos 8 de la línea central
					PUNPCKHWD xmm12, xmm1	; pone en xmm12 los primeros 4 de la línea central
					PUNPCKLWD xmm13, xmm1	; pone en xmm13 los segundos 4 de la línea central
					PUNPCKHWD xmm14, xmm1	; pone en xmm14 los terceros 4 de la línea central
					PUNPCKLWD xmm15, xmm1	; pone en xmm15 los cuartos 4 de la línea central
					CVTDQ2PS xmm12, xmm12	; deja en xmm12 los ints converitos en floats
					CVTDQ2PS xmm13, xmm13	; deja en xmm13 los ints converitos en floats
					CVTDQ2PS xmm14, xmm14	; deja en xmm14 los ints converitos en floats
					CVTDQ2PS xmm15, xmm15	; deja en xmm15 los ints converitos en floats
					
					
					MOVDQU xmm3, xmm0		; deja en xmm3 la línea central para usarla después sin repetir el acceso a memoria
					
					
					; Divide los source por los máximos M15, M14, M13, M12, M11, M10, M9, M8, M7, M6, M5, M4, M3, M2, M1
					; Se tiene:
					; xmm8 = (máx16, máx15, máx14, máx13)
					; xmm9 = (máx12, máx11, máx10, máx9)
					; xmm10 = (máx8, máx7, máx6, máx5)
					; xmm11 = (máx4, máx3, máx2, máx1)
					
					
					; X M15 M14 M13
					MOVDQU xmm0, xmm9		; pone en xmm0 a (máx12, máx11, máx10, máx9)
					PSRLDQ xmm0, 12			; mueve a derecha 12 bytes (6 words) o sea 3 floats y queda (0, 0, 0, máx12)
					MOVDQU xmm1, xmm8		; pone en xmm1 a (máx16, máx15, máx14, máx13)
					PSLLDQ xmm1, 4			; mueve a izquierda 4 bytes (2 words) o sea 1 float y queda (máx15, máx14, máx13, 0)
					ADDPS xmm0, xmm1			; deja en xmm0 a (máx15, máx14, máx13, máx12)
					MOVDQU xmm1, xmm8		; pone en xmm1 a (máx16, máx15, máx14, máx13)
					MOVDQU xmm2, xmm8		; pone en xmm2 a (máx16, máx15, máx14, máx13)
					PSRLDQ xmm2, 4			; mueve a derecha 4 bytes (2 words) o sea 1 float y queda (0, máx16, máx15, máx14)
					; (máx15, máx14, máx13, máx12)
					; (máx16, máx15, máx14, máx13)
					; (0, máx16, máx15, máx14)
					MAXPS xmm0, xmm1
					MAXPS xmm0, xmm2		; deja en xmm0 a los máximos (X, M15, M14, M13)
					DIVPS xmm12, xmm0		; divide cada valor del source (16, 15, 14, 13) por (X, M15, M14, M13)
					
					
					; M12 M11 M10 M9
					MOVDQU xmm0, xmm10		; pone en xmm0 a (máx8, máx7, máx6, máx5)
					PSRLDQ xmm0, 12			; mueve a derecha 12 bytes (6 words) o sea 3 floats y queda (0, 0, 0, máx8)
					MOVDQU xmm1, xmm9		; pone en xmm1 a (máx12, máx11, máx10, máx9)
					PSLLDQ xmm1, 4			; mueve a izquierda 4 bytes (2 words) o sea 1 float y queda (máx11, máx10, máx9, 0)
					ADDPS xmm0, xmm1			; deja en xmm0 a (máx11, máx10, máx9, máx8)
					MOVDQU xmm2, xmm8		; pone en xmm2 a (máx16, máx15, máx14, máx13)
					PSLLDQ xmm2, 12			; mueve a izquierda 12 bytes (6 words) o sea 3 floats y queda (máx13, 0, 0, 0)
					MOVDQU xmm1, xmm9		; pone en xmm1 a (máx12, máx11, máx10, máx9)
					PSRLDQ xmm1, 4			; mueve a derecha 4 bytes (2 word) o sea 1 float y queda (0, máx12, máx11, máx10)
					ADDPS xmm2, xmm1			; deja en xmm2 a (máx13, máx12, máx11, máx10)
					MOVDQU xmm1, xmm9		; pone en xmm1 a (máx12, máx11, máx10, máx9)
					; (máx11, máx10, máx9, máx8)
					; (máx12, máx11, máx10, máx9)
					; (máx13, máx12, máx11, máx10)
					MAXPS xmm0, xmm1
					MAXPS xmm0, xmm2		; deja en xmm0 a los máximos (M12, M11, M10, M9)
					DIVPS xmm13, xmm0		; divide cada valor del source (12, 11, 10, 9) por (M12, M11, M10, M9)
					
					
					; M8 M7 M6 M5
					MOVDQU xmm0, xmm11		; pone en xmm0 a (máx4, máx3, máx2, máx1)
					PSRLDQ xmm0, 12			; mueve a derecha 12 bytes (6 words) o sea 3 floats y queda (0, 0, 0, máx4)
					MOVDQU xmm1, xmm10		; pone en xmm1 a (máx8, máx7, máx6, máx5)
					PSLLDQ xmm1, 4			; mueve a izquierda 4 bytes (2 words) o sea 1 float y queda (máx7, máx6, máx5, 0)
					ADDPS xmm0, xmm1			; deja en xmm0 a (máx7, máx6, máx5, máx4)
					MOVDQU xmm2, xmm9		; pone en xmm2 a (máx12, máx11, máx10, máx9)
					PSLLDQ xmm2, 12			; mueve a izquierda 12 bytes (6 words) o sea 3 floats y queda (máx9, 0, 0, 0)
					MOVDQU xmm1, xmm10		; pone en xmm1 a (máx8, máx7, máx6, máx5)
					PSRLDQ xmm1, 4			; mueve a derecha 4 bytes (2 word) o sea 1 float y queda (0, máx8, máx7, máx6)
					ADDPS xmm2, xmm1			; deja en xmm2 a (máx9, máx8, máx7, máx6)
					MOVDQU xmm1, xmm10		; pone en xmm1 a (máx8, máx7, máx6, máx5)
					; (máx7, máx6, máx5, máx4)
					; (máx8, máx7, máx6, máx5)
					; (máx9, máx8, máx7, máx6)
					MAXPS xmm0, xmm1
					MAXPS xmm0, xmm2		; deja en xmm0 a los máximos (M8, M7, M6, M5)
					DIVPS xmm14, xmm0		; divide cada valor del source (8, 7, 6, 5) por (M8, M7, M6, M5)

					
					; M4 M3 M2 M1
					MOVDQU xmm0, xmm11		; pone en xmm0 a (máx4, máx3, máx2, máx1)
					PSLLDQ xmm0, 4			; mueve a izquierda 4 bytes (2 words) o sea 1 float y queda (máx3, máx2, máx1, 0)
					MOVDQU xmm1, xmm10		; pone en xmm1 a (máx8, máx7, máx6, máx5)
					PSLLDQ xmm1, 12			; mueve a izquierda 12 bytes (6 words) o sea 3 floats y queda (máx5, 0, 0, 0)
					MOVDQU xmm2, xmm11		; pone en xmm2 a (máx4, máx3, máx2, máx1)
					PSRLDQ xmm2, 4			; mueve a derecha 4 bytes (2 word) o sea 1 float y queda (0, máx4, máx3, máx2)
					ADDPS xmm2, xmm1			; deja en xmm2 a (máx5, máx4, máx3, máx2)
					MOVDQU xmm1, xmm11		; pone en xmm1 a (máx4, máx3, máx2, máx1)
					; (máx3, máx2, máx1, 0)
					; (máx4, máx3, máx2, máx1)
					; (máx5, máx4, máx3, máx2)
					MAXPS xmm0, xmm1
					MAXPS xmm0, xmm2		; deja en xmm0 a los máximos (M4, M3, M2, M1)
					DIVPS xmm15, xmm0		; divide cada valor del source (4, 3, 2, 1) por (M4, M3, M2, X)
					
					
					
					
					; Suma a lo obtenido antes los mínimos m15, m14, m13, m12, m11, m10, m9, m8, m7, m6, m5, m4, m3, m2, m1
					; Se tiene:
					; xmm4 = (mín16, mín15, mín14, mín13)
					; xmm5 = (mín12, mín11, mín10, mín9)
					; xmm6 = (mín8, mín7, mín6, mín5)
					; xmm7 = (mín4, mín3, mín2, mín1)
					
					
					; X m15 m14 m13
					MOVDQU xmm0, xmm5		; pone en xmm0 a (mín12, mín11, mín10, mín9)
					PSRLDQ xmm0, 12			; mueve a derecha 12 bytes (6 words) o sea 3 floats y queda (0, 0, 0, mín12)
					MOVDQU xmm1, xmm4		; pone en xmm1 a (mín16, mín15, mín14, mín13)
					PSLLDQ xmm1, 4			; mueve a izquierda 4 bytes (2 words) o sea 1 float y queda (mín15, mín14, mín13, 0)
					ADDPS xmm0, xmm1			; deja en xmm0 a (mín15, mín14, mín13, mín12)
					MOVDQU xmm1, xmm4		; pone en xmm1 a (mín16, mín15, mín14, mín13)
					MOVDQU xmm2, xmm4		; pone en xmm2 a (mín16, mín15, mín14, mín13)
					PSRLDQ xmm2, 4			; mueve a derecha 4 bytes (2 words) o sea 1 float y queda (0, mín16, mín15, mín14)
					; (mín15, mín14, mín13, mín12)
					; (mín16, mín15, mín14, mín13)
					; (0, mín16, mín15, mín14)
					MINPS xmm0, xmm1
					MINPS xmm0, xmm2		; deja en xmm0 a los mínimos (X, m15, m14, m13)
					ADDPS xmm12, xmm0		; suma cada valor del source (16, 15, 14, 13) por (X, m15, m14, m13)
					
					
					; m12 m11 m10 m9
					MOVDQU xmm0, xmm6		; pone en xmm0 a (mín8, mín7, mín6, mín5)
					PSRLDQ xmm0, 12			; mueve a derecha 12 bytes (6 words) o sea 3 floats y queda (0, 0, 0, mín8)
					MOVDQU xmm1, xmm5		; pone en xmm1 a (mín12, mín11, mín10, mín9)
					PSLLDQ xmm1, 4			; mueve a izquierda 4 bytes (2 words) o sea 1 float y queda (mín11, mín10, mín9, 0)
					ADDPS xmm0, xmm1			; deja en xmm0 a (mín11, mín10, mín9, mín8)
					MOVDQU xmm2, xmm4		; pone en xmm2 a (mín16, mín15, mín14, mín13)
					PSLLDQ xmm2, 12			; mueve a izquierda 12 bytes (6 words) o sea 3 floats y queda (mín13, 0, 0, 0)
					MOVDQU xmm1, xmm5		; pone en xmm1 a (mín12, mín11, mín10, mín9)
					PSRLDQ xmm1, 4			; mueve a derecha 4 bytes (2 word) o sea 1 float y queda (0, mín12, mín11, mín10)
					ADDPS xmm2, xmm1			; deja en xmm2 a (mín13, mín12, mín11, mín10)
					MOVDQU xmm1, xmm5		; pone en xmm1 a (mín12, mín11, mín10, mín9)
					; (mín11, mín10, mín9, mín8)
					; (mín12, mín11, mín10, mín9)
					; (mín13, mín12, mín11, mín10)
					MINPS xmm0, xmm1
					MINPS xmm0, xmm2		; deja en xmm0 a los mínimo (m12, m11, m10, m9)
					ADDPS xmm13, xmm0		; divide cada valor del source (12, 11, 10, 9) por (m12, m11, m10, m9)
					
					
					; M8 M7 M6 M5
					MOVDQU xmm0, xmm7		; pone en xmm0 a (mín4, mín3, mín2, mín1)
					PSRLDQ xmm0, 12			; mueve a derecha 12 bytes (6 words) o sea 3 floats y queda (0, 0, 0, mín4)
					MOVDQU xmm1, xmm6		; pone en xmm1 a (mín8, mín7, mín6, mín5)
					PSLLDQ xmm1, 4			; mueve a izquierda 4 bytes (2 words) o sea 1 float y queda (mín7, mín6, mín5, 0)
					ADDPS xmm0, xmm1			; deja en xmm0 a (mín7, mín6, mín5, mín4)
					MOVDQU xmm2, xmm5		; pone en xmm2 a (mín12, mín11, mín10, mín9)
					PSLLDQ xmm2, 12			; mueve a izquierda 12 bytes (6 words) o sea 3 floats y queda (mín9, 0, 0, 0)
					MOVDQU xmm1, xmm6		; pone en xmm1 a (mín8, mín7, mín6, mín5)
					PSRLDQ xmm1, 4			; mueve a derecha 4 bytes (2 word) o sea 1 float y queda (0, mín8, mín7, mín6)
					ADDPS xmm2, xmm1			; deja en xmm2 a (mín9, mín8, mín7, mín6)
					MOVDQU xmm1, xmm6		; pone en xmm1 a (mín8, mín7, mín6, mín5)
					; (mín7, mín6, mín5, mín4)
					; (mín8, mín7, mín6, mín5)
					; (mín9, mín8, mín7, mín6)
					MINPS xmm0, xmm1
					MINPS xmm0, xmm2		; deja en xmm0 a los mínimos (m8, m7, m6, m5)
					ADDPS xmm14, xmm0		; divide cada valor del source (8, 7, 6, 5) por (m8, m7, m6, m5)

					
					; m4 m3 m2 m1
					MOVDQU xmm0, xmm7		; pone en xmm0 a (mín4, mín3, mín2, mín1)
					PSLLDQ xmm0, 4			; mueve a izquierda 4 bytes (2 words) o sea 1 float y queda (mín3, mín2, mín1, 0)
					MOVDQU xmm1, xmm6		; pone en xmm1 a (mín8, mín7, mín6, mín5)
					PSLLDQ xmm1, 12			; mueve a izquierda 12 bytes (6 words) o sea 3 floats y queda (mín5, 0, 0, 0)
					MOVDQU xmm2, xmm7		; pone en xmm2 a (mín4, mín3, mín2, mín1)
					PSRLDQ xmm2, 4			; mueve a derecha 4 bytes (2 word) o sea 1 float y queda (0, mín4, mín3, mín2)
					ADDPS xmm2, xmm1			; deja en xmm2 a (mín5, mín4, mín3, mín2)
					MOVDQU xmm1, xmm7		; pone en xmm1 a (mín4, mín3, mín2, mín1)
					; (mín3, mín2, mín1, 0)
					; (mín4, mín3, mín2, mín1)
					; (mín5, mín4, mín3, mín2)
					MINPS xmm0, xmm1
					MINPS xmm0, xmm2		; deja en xmm0 a los mínimos (m4, m3, m2, m1)
					ADDPS xmm15, xmm0		; divide cada valor del source (4, 3, 2, 1) por (m4, m3, m2, X)
					
					CVTPS2DQ xmm12, xmm12	; pasa el float a int
					CVTPS2DQ xmm13, xmm13	; pasa el float a int
					CVTPS2DQ xmm14, xmm14	; pasa el float a int
					CVTPS2DQ xmm15, xmm15	; pasa el float a int
				
					
					PACKUSDW xmm13, xmm12	; empaqueta los altos para ponerlos en rdi
					PACKUSDW xmm15, xmm14	; empaqueta los bajos para ponerlos en rdi
					
					PACKUSWB xmm15, xmm13	; empaqueta a bytes y se tiene la salida
					
					;~ MOVDQU xmm0, xmm3		; pone la línea central en xmm0
					;~ MOVDQU xmm1, [maskUlt]	; pone en xmm1 la máscara
					;~ PAND xmm0, xmm1		 	; deja el último byte únicamente
					;~ PAND xmm15, [maskNoPrimYUlt] ; deja todos los bytes salvo el primero y el último
					;~ 
					;~ PADDB xmm0, xmm15		; deja en xmm0 (original, dato15, dato14, dato13, dato12, dato11, dato10, dato9, dato8, dato7, dato6, dato5, dato4, dato3, dato2, original) 
					
					MOVDQU xmm0, xmm15		; pone en xmm0 a (basura, dato14, dato13, dato12, dato11, dato10, dato9, dato8, dato7, dato6, dato5, dato4, dato3, dato2, basura) 
					PSRLDQ xmm0, 1			; shiftea 1 byte a derecha y queda (0, basura, dato14, dato13, dato12, dato11, dato10, dato9, dato8, dato7, dato6, dato5, dato4, dato3, dato2) 
						
					MOVDQU [rdi], xmm0		; coloca en imagen destino
	
	; Avanza rsi y dsi 16 lugares
	; Retrocede rsi 2 lugares para operar al último byte
	; Retrocede rdi 2 lugares para pisar los dos bytes que se colocaron al final y que tienen basura
	ADD rsi, 14
	ADD rdi, 14
	
	
	
	ADD r14, 14				; aumenta 'ancho' en 14
	JMP cicloAnchoNorm
		
faltaAlgoNorm:
	MOV rbx, r14			; pone en rbx a ancho
	ADD rbx, 15				; deja en rbx a ancho+15
	SUB rbx, rcx			; deja en rbx a ancho-(w-15) o sea la diferencia que debo restar
	SUB rsi, rbx			; deja en rsi una pos tal que faltan 15 para terminar la fila
	SUB rdi, rbx			; ídem para rdi
	
;SUB rdi, 1		; resta 1 más porque está adelantado uno respecto del rsi (LUEGO MODIFICAR)
	
		; código
					MOVDQU xmm0, [rsi]		; carga en xmm0 a la línea central
					MOV rbx, rsi			; pone en rbx a rsi
					SUB rbx, r8				; resta el row_size
					MOVDQU xmm1, [rbx]		; carga en xmm1 a la línea superior
					LEA rbx, [rsi + r8]		; coloca en rbx la posición de una línea antes
					MOVDQU xmm2, [rbx]		; carga en xmm2 a la línea inferior
					
					PXOR xmm15, xmm15		; limpia xmm5 para usarlo para desempaquetar
					
					; Primeros 4
					MOVDQU xmm4, xmm0		; pone en xmm4 una copia de la central
					PUNPCKHBW xmm4, xmm15	; deja en xmm4 los primeros 8 de la línea central
					PUNPCKHWD xmm4, xmm15	; deja en xmm4 los primeros 4 ints de la línea central
					CVTDQ2PS xmm4, xmm4		; convierte los ints en floats
					MOVDQU xmm8, xmm4		; pone una copia de éstos en xmm8
					
					MOVDQU xmm13, xmm1		; pone en xmm13 una copia de la inferior
					PUNPCKHBW xmm13, xmm15	; deja en xmm13 los primeros 8 de la línea inferior
					PUNPCKHWD xmm13, xmm15	; deja en xmm13 los primeros 4 ints de la línea inferior
					CVTDQ2PS xmm13, xmm13	; convierte los ints en floats
					
					MOVDQU xmm14, xmm2		; pone en xmm14 una copia de la superior
					PUNPCKHBW xmm14, xmm15	; deja en xmm14 los primeros 8 de la línea superior
					PUNPCKHWD xmm14, xmm15	; deja en xmm14 los primeros 4 ints de la línea superior
					CVTDQ2PS xmm14, xmm14	; convierte los ints en floats 
					
					MAXPS xmm8, xmm13
					MAXPS xmm8, xmm14		; deja en xmm8 los máximos de columna de los floats 16,15,14,13
					
					MINPS xmm4, xmm13
					MINPS xmm4, xmm14		; deja en xmm4 los mínimos de columna de los floats 16,15,14,13
					
					; Segundos 4
					MOVDQU xmm5, xmm0		; pone en xmm5 una copia de la central
					PUNPCKHBW xmm5, xmm15	; deja en xmm5 los primeros 8 de la línea central
					PUNPCKLWD xmm5, xmm15	; deja en xmm5 los segundos 4 ints de la línea central
					CVTDQ2PS xmm5, xmm5		; convierte los ints en floats
					MOVDQU xmm9, xmm5		; pone una copia de éstos en xmm9
					
					MOVDQU xmm13, xmm1		; pone en xmm13 una copia de la inferior
					PUNPCKHBW xmm13, xmm15	; deja en xmm13 los primeros 8 de la línea inferior
					PUNPCKLWD xmm13, xmm15	; deja en xmm13 los segundos 4 de la línea inferior
					CVTDQ2PS xmm13, xmm13	; convierte los ints en floats
					
					MOVDQU xmm14, xmm2		; pone en xmm14 una copia de la superior
					PUNPCKHBW xmm14, xmm15	; deja en xmm14 los primeros 8 de la línea superior
					PUNPCKLWD xmm14, xmm15	; deja en xmm14 los segundos 4 de la línea superior
					CVTDQ2PS xmm14, xmm14	; convierte los ints en floats 
					
					MAXPS xmm9, xmm13
					MAXPS xmm9, xmm14		; deja en xmm9 los máximos de columna de los floats 12,11,10,9
					
					MINPS xmm5, xmm13
					MINPS xmm5, xmm14		; deja en xmm5 los mínimos de columna de los floats 12,11,10,9
					
					; Terceros 4
					MOVDQU xmm6, xmm0		; pone en xmm6 una copia de la central
					PUNPCKLBW xmm6, xmm15	; deja en xmm6 los segundos 8 de la línea central
					PUNPCKHWD xmm6, xmm15	; deja en xmm6 los primeros 4 ints de la línea central
					CVTDQ2PS xmm6, xmm6		; convierte los ints en floats
					MOVDQU xmm10, xmm6		; pone una copia de éstos en xmm10
					
					MOVDQU xmm13, xmm1		; pone en xmm13 una copia de la inferior
					PUNPCKLBW xmm13, xmm15	; deja en xmm13 los segundos 8 de la línea inferior
					PUNPCKHWD xmm13, xmm15	; deja en xmm13 los primeros 4 de la línea inferior
					CVTDQ2PS xmm13, xmm13	; convierte los ints en floats
					
					MOVDQU xmm14, xmm2		; pone en xmm14 una copia de la superior
					PUNPCKLBW xmm14, xmm15	; deja en xmm14 los segundos 8 de la línea superior
					PUNPCKHWD xmm14, xmm15	; deja en xmm14 los primeros 4 de la línea superior
					CVTDQ2PS xmm14, xmm14	; convierte los ints en floats 
					
					MAXPS xmm10, xmm13
					MAXPS xmm10, xmm14		; deja en xmm10 los máximos de columna de los floats 8,7,6,5
					
					MINPS xmm6, xmm13
					MINPS xmm6, xmm14		; deja en xmm6 los mínimos de columna de los floats 8,7,6,5
					
					
					; Cuartos 4
					MOVDQU xmm7, xmm0		; pone en xmm6 una copia de la central
					PUNPCKLBW xmm7, xmm15	; deja en xmm6 los segundos 8 de la línea central
					PUNPCKLWD xmm7, xmm15	; deja en xmm6 los segundos 4 ints de la línea central
					CVTDQ2PS xmm7, xmm7		; convierte los ints en floats
					MOVDQU xmm11, xmm7		; pone una copia de éstos en xmm11
					
					MOVDQU xmm13, xmm1		; pone en xmm13 una copia de la inferior
					PUNPCKLBW xmm13, xmm15	; deja en xmm13 los segundos 8 de la línea inferior
					PUNPCKLWD xmm13, xmm15	; deja en xmm13 los segundos 4 de la línea inferior
					CVTDQ2PS xmm13, xmm13	; convierte los ints en floats
					
					MOVDQU xmm14, xmm2		; pone en xmm14 una copia de la superior
					PUNPCKLBW xmm14, xmm15	; deja en xmm14 los segundos 8 de la línea superior
					PUNPCKLWD xmm14, xmm15	; deja en xmm14 los segundos 4 de la línea superior
					CVTDQ2PS xmm14, xmm14	; convierte los ints en floats 
					
					MAXPS xmm11, xmm13
					MAXPS xmm11, xmm14		; deja en xmm10 los máximos de columna de los floats 4,3,2,1
					
					MINPS xmm7, xmm13
					MINPS xmm7, xmm14		; deja en xmm7 los mínimos de columna de los floats 4,3,2,1


					; Deja en xmm12, xmm13, xmm14, xmm15 los valores centrales
					PXOR xmm1, xmm1			; limpia xmm1 para usarlo para desempaquetar
					MOVDQU xmm12, xmm0		; pone en xmm12 a xmm0 para desempaquetar
					MOVDQU xmm13, xmm0		; pone en xmm13 a xmm0 para desempaquetar
					MOVDQU xmm14, xmm0		; pone en xmm14 a xmm0 para desempaquetar
					MOVDQU xmm15, xmm0		; pone en xmm15 a xmm0 para desempaquetar
					PUNPCKHBW xmm12, xmm1	; pone en xmm12 los primeros 8 de la línea central
					PUNPCKHBW xmm13, xmm1	; pone en xmm13 los primeros 8 de la línea central
					PUNPCKHBW xmm14, xmm1	; pone en xmm14 los segundos 8 de la línea central
					PUNPCKHBW xmm15, xmm1	; pone en xmm15 los segundos 8 de la línea central
					PUNPCKHWD xmm12, xmm1	; pone en xmm12 los primeros 4 de la línea central
					PUNPCKLWD xmm13, xmm1	; pone en xmm13 los segundos 4 de la línea central
					PUNPCKHWD xmm14, xmm1	; pone en xmm14 los terceros 4 de la línea central
					PUNPCKLWD xmm15, xmm1	; pone en xmm15 los cuartos 4 de la línea central
					CVTDQ2PS xmm12, xmm12	; deja en xmm12 los ints converitos en floats
					CVTDQ2PS xmm13, xmm13	; deja en xmm13 los ints converitos en floats
					CVTDQ2PS xmm14, xmm14	; deja en xmm14 los ints converitos en floats
					CVTDQ2PS xmm15, xmm15	; deja en xmm15 los ints converitos en floats
					
					
					MOVDQU xmm3, xmm0		; deja en xmm3 la línea central para usarla después sin repetir el acceso a memoria
					
					
					; Divide los source por los máximos M15, M14, M13, M12, M11, M10, M9, M8, M7, M6, M5, M4, M3, M2, M1
					; Se tiene:
					; xmm8 = (máx16, máx15, máx14, máx13)
					; xmm9 = (máx12, máx11, máx10, máx9)
					; xmm10 = (máx8, máx7, máx6, máx5)
					; xmm11 = (máx4, máx3, máx2, máx1)
					
					
					; X M15 M14 M13
					MOVDQU xmm0, xmm9		; pone en xmm0 a (máx12, máx11, máx10, máx9)
					PSRLDQ xmm0, 12			; mueve a derecha 12 bytes (6 words) o sea 3 floats y queda (0, 0, 0, máx12)
					MOVDQU xmm1, xmm8		; pone en xmm1 a (máx16, máx15, máx14, máx13)
					PSLLDQ xmm1, 4			; mueve a izquierda 4 bytes (2 words) o sea 1 float y queda (máx15, máx14, máx13, 0)
					ADDPS xmm0, xmm1			; deja en xmm0 a (máx15, máx14, máx13, máx12)
					MOVDQU xmm1, xmm8		; pone en xmm1 a (máx16, máx15, máx14, máx13)
					MOVDQU xmm2, xmm8		; pone en xmm2 a (máx16, máx15, máx14, máx13)
					PSRLDQ xmm2, 4			; mueve a derecha 4 bytes (2 words) o sea 1 float y queda (0, máx16, máx15, máx14)
					; (máx15, máx14, máx13, máx12)
					; (máx16, máx15, máx14, máx13)
					; (0, máx16, máx15, máx14)
					MAXPS xmm0, xmm1
					MAXPS xmm0, xmm2		; deja en xmm0 a los máximos (X, M15, M14, M13)
					DIVPS xmm12, xmm0		; divide cada valor del source (16, 15, 14, 13) por (X, M15, M14, M13)
					
					
					; M12 M11 M10 M9
					MOVDQU xmm0, xmm10		; pone en xmm0 a (máx8, máx7, máx6, máx5)
					PSRLDQ xmm0, 12			; mueve a derecha 12 bytes (6 words) o sea 3 floats y queda (0, 0, 0, máx8)
					MOVDQU xmm1, xmm9		; pone en xmm1 a (máx12, máx11, máx10, máx9)
					PSLLDQ xmm1, 4			; mueve a izquierda 4 bytes (2 words) o sea 1 float y queda (máx11, máx10, máx9, 0)
					ADDPS xmm0, xmm1			; deja en xmm0 a (máx11, máx10, máx9, máx8)
					MOVDQU xmm2, xmm8		; pone en xmm2 a (máx16, máx15, máx14, máx13)
					PSLLDQ xmm2, 12			; mueve a izquierda 12 bytes (6 words) o sea 3 floats y queda (máx13, 0, 0, 0)
					MOVDQU xmm1, xmm9		; pone en xmm1 a (máx12, máx11, máx10, máx9)
					PSRLDQ xmm1, 4			; mueve a derecha 4 bytes (2 word) o sea 1 float y queda (0, máx12, máx11, máx10)
					ADDPS xmm2, xmm1			; deja en xmm2 a (máx13, máx12, máx11, máx10)
					MOVDQU xmm1, xmm9		; pone en xmm1 a (máx12, máx11, máx10, máx9)
					; (máx11, máx10, máx9, máx8)
					; (máx12, máx11, máx10, máx9)
					; (máx13, máx12, máx11, máx10)
					MAXPS xmm0, xmm1
					MAXPS xmm0, xmm2		; deja en xmm0 a los máximos (M12, M11, M10, M9)
					DIVPS xmm13, xmm0		; divide cada valor del source (12, 11, 10, 9) por (M12, M11, M10, M9)
					
					
					; M8 M7 M6 M5
					MOVDQU xmm0, xmm11		; pone en xmm0 a (máx4, máx3, máx2, máx1)
					PSRLDQ xmm0, 12			; mueve a derecha 12 bytes (6 words) o sea 3 floats y queda (0, 0, 0, máx4)
					MOVDQU xmm1, xmm10		; pone en xmm1 a (máx8, máx7, máx6, máx5)
					PSLLDQ xmm1, 4			; mueve a izquierda 4 bytes (2 words) o sea 1 float y queda (máx7, máx6, máx5, 0)
					ADDPS xmm0, xmm1			; deja en xmm0 a (máx7, máx6, máx5, máx4)
					MOVDQU xmm2, xmm9		; pone en xmm2 a (máx12, máx11, máx10, máx9)
					PSLLDQ xmm2, 12			; mueve a izquierda 12 bytes (6 words) o sea 3 floats y queda (máx9, 0, 0, 0)
					MOVDQU xmm1, xmm10		; pone en xmm1 a (máx8, máx7, máx6, máx5)
					PSRLDQ xmm1, 4			; mueve a derecha 4 bytes (2 word) o sea 1 float y queda (0, máx8, máx7, máx6)
					ADDPS xmm2, xmm1			; deja en xmm2 a (máx9, máx8, máx7, máx6)
					MOVDQU xmm1, xmm10		; pone en xmm1 a (máx8, máx7, máx6, máx5)
					; (máx7, máx6, máx5, máx4)
					; (máx8, máx7, máx6, máx5)
					; (máx9, máx8, máx7, máx6)
					MAXPS xmm0, xmm1
					MAXPS xmm0, xmm2		; deja en xmm0 a los máximos (M8, M7, M6, M5)
					DIVPS xmm14, xmm0		; divide cada valor del source (8, 7, 6, 5) por (M8, M7, M6, M5)

					
					; M4 M3 M2 M1
					MOVDQU xmm0, xmm11		; pone en xmm0 a (máx4, máx3, máx2, máx1)
					PSLLDQ xmm0, 4			; mueve a izquierda 4 bytes (2 words) o sea 1 float y queda (máx3, máx2, máx1, 0)
					MOVDQU xmm1, xmm10		; pone en xmm1 a (máx8, máx7, máx6, máx5)
					PSLLDQ xmm1, 12			; mueve a izquierda 12 bytes (6 words) o sea 3 floats y queda (máx5, 0, 0, 0)
					MOVDQU xmm2, xmm11		; pone en xmm2 a (máx4, máx3, máx2, máx1)
					PSRLDQ xmm2, 4			; mueve a derecha 4 bytes (2 word) o sea 1 float y queda (0, máx4, máx3, máx2)
					ADDPS xmm2, xmm1			; deja en xmm2 a (máx5, máx4, máx3, máx2)
					MOVDQU xmm1, xmm11		; pone en xmm1 a (máx4, máx3, máx2, máx1)
					; (máx3, máx2, máx1, 0)
					; (máx4, máx3, máx2, máx1)
					; (máx5, máx4, máx3, máx2)
					MAXPS xmm0, xmm1
					MAXPS xmm0, xmm2		; deja en xmm0 a los máximos (M4, M3, M2, M1)
					DIVPS xmm15, xmm0		; divide cada valor del source (4, 3, 2, 1) por (M4, M3, M2, X)
					
					
					
					
					; Suma a lo obtenido antes los mínimos m15, m14, m13, m12, m11, m10, m9, m8, m7, m6, m5, m4, m3, m2, m1
					; Se tiene:
					; xmm4 = (mín16, mín15, mín14, mín13)
					; xmm5 = (mín12, mín11, mín10, mín9)
					; xmm6 = (mín8, mín7, mín6, mín5)
					; xmm7 = (mín4, mín3, mín2, mín1)
					
					
					; X m15 m14 m13
					MOVDQU xmm0, xmm5		; pone en xmm0 a (mín12, mín11, mín10, mín9)
					PSRLDQ xmm0, 12			; mueve a derecha 12 bytes (6 words) o sea 3 floats y queda (0, 0, 0, mín12)
					MOVDQU xmm1, xmm4		; pone en xmm1 a (mín16, mín15, mín14, mín13)
					PSLLDQ xmm1, 4			; mueve a izquierda 4 bytes (2 words) o sea 1 float y queda (mín15, mín14, mín13, 0)
					ADDPS xmm0, xmm1			; deja en xmm0 a (mín15, mín14, mín13, mín12)
					MOVDQU xmm1, xmm4		; pone en xmm1 a (mín16, mín15, mín14, mín13)
					MOVDQU xmm2, xmm4		; pone en xmm2 a (mín16, mín15, mín14, mín13)
					PSRLDQ xmm2, 4			; mueve a derecha 4 bytes (2 words) o sea 1 float y queda (0, mín16, mín15, mín14)
					; (mín15, mín14, mín13, mín12)
					; (mín16, mín15, mín14, mín13)
					; (0, mín16, mín15, mín14)
					MINPS xmm0, xmm1
					MINPS xmm0, xmm2		; deja en xmm0 a los mínimos (X, m15, m14, m13)
					ADDPS xmm12, xmm0		; divide cada valor del source (16, 15, 14, 13) por (X, m15, m14, m13)
					
					
					; m12 m11 m10 m9
					MOVDQU xmm0, xmm6		; pone en xmm0 a (mín8, mín7, mín6, mín5)
					PSRLDQ xmm0, 12			; mueve a derecha 12 bytes (6 words) o sea 3 floats y queda (0, 0, 0, mín8)
					MOVDQU xmm1, xmm5		; pone en xmm1 a (mín12, mín11, mín10, mín9)
					PSLLDQ xmm1, 4			; mueve a izquierda 4 bytes (2 words) o sea 1 float y queda (mín11, mín10, mín9, 0)
					ADDPS xmm0, xmm1			; deja en xmm0 a (mín11, mín10, mín9, mín8)
					MOVDQU xmm2, xmm4		; pone en xmm2 a (mín16, mín15, mín14, mín13)
					PSLLDQ xmm2, 12			; mueve a izquierda 12 bytes (6 words) o sea 3 floats y queda (mín13, 0, 0, 0)
					MOVDQU xmm1, xmm5		; pone en xmm1 a (mín12, mín11, mín10, mín9)
					PSRLDQ xmm1, 4			; mueve a derecha 4 bytes (2 word) o sea 1 float y queda (0, mín12, mín11, mín10)
					ADDPS xmm2, xmm1			; deja en xmm2 a (mín13, mín12, mín11, mín10)
					MOVDQU xmm1, xmm5		; pone en xmm1 a (mín12, mín11, mín10, mín9)
					; (mín11, mín10, mín9, mín8)
					; (mín12, mín11, mín10, mín9)
					; (mín13, mín12, mín11, mín10)
					MINPS xmm0, xmm1
					MINPS xmm0, xmm2		; deja en xmm0 a los mínimo (m12, m11, m10, m9)
					ADDPS xmm13, xmm0		; divide cada valor del source (12, 11, 10, 9) por (m12, m11, m10, m9)
					
					
					; M8 M7 M6 M5
					MOVDQU xmm0, xmm7		; pone en xmm0 a (mín4, mín3, mín2, mín1)
					PSRLDQ xmm0, 12			; mueve a derecha 12 bytes (6 words) o sea 3 floats y queda (0, 0, 0, mín4)
					MOVDQU xmm1, xmm6		; pone en xmm1 a (mín8, mín7, mín6, mín5)
					PSLLDQ xmm1, 4			; mueve a izquierda 4 bytes (2 words) o sea 1 float y queda (mín7, mín6, mín5, 0)
					ADDPS xmm0, xmm1			; deja en xmm0 a (mín7, mín6, mín5, mín4)
					MOVDQU xmm2, xmm5		; pone en xmm2 a (mín12, mín11, mín10, mín9)
					PSLLDQ xmm2, 12			; mueve a izquierda 12 bytes (6 words) o sea 3 floats y queda (mín9, 0, 0, 0)
					MOVDQU xmm1, xmm6		; pone en xmm1 a (mín8, mín7, mín6, mín5)
					PSRLDQ xmm1, 4			; mueve a derecha 4 bytes (2 word) o sea 1 float y queda (0, mín8, mín7, mín6)
					ADDPS xmm2, xmm1			; deja en xmm2 a (mín9, mín8, mín7, mín6)
					MOVDQU xmm1, xmm6		; pone en xmm1 a (mín8, mín7, mín6, mín5)
					; (mín7, mín6, mín5, mín4)
					; (mín8, mín7, mín6, mín5)
					; (mín9, mín8, mín7, mín6)
					MINPS xmm0, xmm1
					MINPS xmm0, xmm2		; deja en xmm0 a los mínimos (m8, m7, m6, m5)
					ADDPS xmm14, xmm0		; divide cada valor del source (8, 7, 6, 5) por (m8, m7, m6, m5)

					
					; m4 m3 m2 m1
					MOVDQU xmm0, xmm7		; pone en xmm0 a (mín4, mín3, mín2, mín1)
					PSLLDQ xmm0, 4			; mueve a izquierda 4 bytes (2 words) o sea 1 float y queda (mín3, mín2, mín1, 0)
					MOVDQU xmm1, xmm6		; pone en xmm1 a (mín8, mín7, mín6, mín5)
					PSLLDQ xmm1, 12			; mueve a izquierda 12 bytes (6 words) o sea 3 floats y queda (mín5, 0, 0, 0)
					MOVDQU xmm2, xmm7		; pone en xmm2 a (mín4, mín3, mín2, mín1)
					PSRLDQ xmm2, 4			; mueve a derecha 4 bytes (2 word) o sea 1 float y queda (0, mín4, mín3, mín2)
					ADDPS xmm2, xmm1			; deja en xmm2 a (mín5, mín4, mín3, mín2)
					MOVDQU xmm1, xmm7		; pone en xmm1 a (mín4, mín3, mín2, mín1)
					; (mín3, mín2, mín1, 0)
					; (mín4, mín3, mín2, mín1)
					; (mín5, mín4, mín3, mín2)
					MINPS xmm0, xmm1
					MINPS xmm0, xmm2		; deja en xmm0 a los mínimos (m4, m3, m2, m1)
					ADDPS xmm15, xmm0		; divide cada valor del source (4, 3, 2, 1) por (m4, m3, m2, X)
					
					CVTPS2DQ xmm12, xmm12	; pasa el float a int
					CVTPS2DQ xmm13, xmm13	; pasa el float a int
					CVTPS2DQ xmm14, xmm14	; pasa el float a int
					CVTPS2DQ xmm15, xmm15	; pasa el float a int
				
					
					PACKSSDW xmm13, xmm12	; empaqueta los altos para ponerlos en rdi
					PACKSSDW xmm15, xmm14	; empaqueta los bajos para ponerlos en rdi
					
					PACKUSWB xmm15, xmm13	; empaqueta a bytes y se tiene la salida
					
					;~ MOVDQU xmm0, xmm3		; pone la línea central en xmm0
					;~ MOVDQU xmm1, [maskUlt]	; pone en xmm1 la máscara
					;~ PAND xmm0, xmm1		 	; deja el último byte únicamente
					;~ MOVDQU xmm1, [maskNoUlt]; pone en xmm1 la máscara
					;~ PAND xmm15, xmm1 		; deja todos los bytes salvo el primero y el último
					;~
					
	MOVDQU xmm0, xmm3			; pone la línea central en xmm0
	MOVDQU xmm1, [maskPrim]		; pone en xmm1 la máscara
	PAND xmm0, xmm1				; deja el primer byte únicamente (último leído)
	MOVDQU xmm1, [maskNoPrim]	; pone en xmm1 la máscara
	PAND xmm15, xmm1			; deja todos los bytes salvo el primero
				
					 
					PADDB xmm0, xmm15		; deja en xmm0 (original, dato15, dato14, dato13, dato12, dato11, dato10, dato9, dato8, dato7, dato6, dato5, dato4, dato3, dato2, original) 
					
					PSRLDQ xmm0, 1			; deja en xmm0 (0, original, dato15, dato14, dato13, dato12, dato11, dato10, dato9, dato8, dato7, dato6, dato5, dato4, dato3, dato2) 
			; Se colocan de a partes para sólo imprimir los últimos 15 bytes
			; o sea original, dato15, dato14, dato13, dato12, dato11, dato10, dato9, dato8, dato7, dato6, dato5, dato4, dato3, dato2
					MOVQ [rdi], xmm0		; coloca los primeros 8 bytes en memoria
					PSRLDQ xmm0, 8			; corre 8 bytes a derecha y queda 0, 0, 0, 0, 0, 0, 0, 0, 0, original, dato15, dato14, dato13, dato12, dato11, dato10
					MOVD [rdi+8], xmm0		; coloca los siguientes 4 bytes en memoria
					PSRLDQ xmm0, 4			; corre 4 bytes a derecha y queda 0, 0, 0, 0, 0, 0, 0, 0, original, dato15, dato14
					MOVD eax, xmm0			; pone en eax (4bytes) los últimos 4 bytes de xmm0 o sea 0, original, dato15, dato14
					MOV WORD [rdi+12], ax	; coloca los siguientes 2 bytes en memoria
					SHR eax, 8				; mueve 8 bits a derecha en eax y deja eax = 0, 0, 0, original
					MOV BYTE [rdi+14], al	; coloca en memoria el último byte
					


	ADD rdi, 15				; pasa a los siguientes 16 bytes en rdi
	ADD rsi, 16				; pasa a los siguientes bytes en rsi
	ADD r14, 16				; aumenta 'ancho' en 16	
saleAnchoNorm:
	ADD rsi, r8				; aumenta a rsi el row_size
	SUB rsi, rcx			; resta a rsi el w
	ADD rdi, r8				; aumenta a rdi el row_size
	SUB rdi, rcx			; resta a rdi el w
	MOV qword r14, 0		; pone nuevamente el ancho en 0
	INC r15					; aumenta en 1 el alto
	
	
	JMP cicloAltoNorm	
	
saleAltoNorm:

;/////// La última línea queda como estaba

cicloAnchoNormUlt:
	MOV rbx, r14			; pone en rbx el ancho
	ADD rbx, 16				; deja en rbx a ancho+16
	CMP rbx, rcx			; compara ancho+16 con w
	JG faltaAlgoNormUlt
	CMP r14, rcx			; compara el ancho con w
	JE saleAnchoNormUlt

	MOVDQU xmm0, [rsi]		; carga en xmm0 16 bytes de src	
	MOVDQU [rdi], xmm0		; pasa a dst el resultado
	
	ADD rdi, 16				; pasa a los siguientes 16 bytes en rdi
	ADD rsi, 16				; pasa a los siguientes bytes en rsi
	ADD r14, 16				; aumenta 'ancho' en 16
	JMP cicloAnchoNormUlt
		
faltaAlgoNormUlt:
	MOV rbx, r14			; pone en rbx a ancho
	ADD rbx, 16				; deja en rbx a ancho+16
	SUB rbx, rcx			; deja en rbx a ancho-(w-16) o sea la diferencia que debo restar
	SUB rsi, rbx			; deja en rsi una pos tal que faltan 16 para terminar la fila
	SUB rdi, rbx			; ídem para rdi

	MOVDQU xmm0, [rsi]		; carga en xmm0 16 bytes de src
	MOVDQU [rdi], xmm0		; pasa a dst el resultado

	ADD rdi, 16				; pasa a los siguientes 16 bytes en rdi
	ADD rsi, 16				; pasa a los siguientes bytes en rsi
	ADD r14, 16				; aumenta 'ancho' en 16	
saleAnchoNormUlt:
	ADD rsi, r8				; aumenta a rsi el row_size
	SUB rsi, rcx			; resta a rsi el w
	ADD rdi, r8				; aumenta a rdi el row_size
	SUB rdi, rcx			; resta a rdi el w
	MOV qword r14, 0		; pone nuevamente el ancho en 0
	INC r15					; aumenta en 1 el alto
	
; Termina



	ADD rsp, 8
	POP r15
	POP r14
	POP rbx
		
	POP rbp	
	



	ret


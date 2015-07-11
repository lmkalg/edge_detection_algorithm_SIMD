; void pixelar_asm (
; 	unsigned char *src,
; 	unsigned char *dst,
; 	int m,
; 	int n,
; 	int src_row_size,
; 	int dst_row_size
; );

section .data
mask: DQ 0x00000000FFFFFFFF
maskDejarPrimeroYCuarto: DW 0xFFFF, 0x0000, 0x0000, 0x0000, 0xFFFF, 0x0000, 0x0000, 0x0000
maskMultiplode4: DQ 0xFFFFFFFFFFFFFFFC
section .text

global pixelar_asm

pixelar_asm:
	; *src en rdi
	; *dst en rsi
	; m en rdx
	; n en rcx
	; src_row_size en r8 
	; dst_row_size en r9
	
	PUSH rbp				;				Alinea
	MOV rbp, rsp
	PUSH rbx				; salva rbx		Desalinea
	PUSH r13				; salva r13		Alinea
	PUSH r14				; salva r14		Desalinea
	PUSH r15				; salva r15   	Alinea
	
	MOV rax, [mask]			; pone en rax lo que se usa como máscara
	AND rdx, rax			; máscara a rdx para dejar la parte baja únicamente
	AND rcx, rax			; máscara a rcx para dejar la parte baja únicamente
	AND r8, rax 			; máscara a r8 para dejar la parte baja únicamente
	AND r9, rax 			; máscara a r9 para dejar la parte baja únicamente
	
	
	AND rcx, [maskMultiplode4]	; corta el resto módulo 4 del ancho
	AND rdx, [maskMultiplode4]	; corta el resto módulo 4 del alto
	
	
	XOR r11,r11				; limpia r11


cicloPorFila:
			CMP edx, 0				; para ver si termine de ciclar todas las filas
			JE salir

			MOV r11d, ecx			; muevo al cantidad de columnas a r11
			MOV r14, rdi			; hago el iterador de columnas de src
			MOV r13, rsi			; hago el iterador de columnas de dst

			cicloPorColumna:
				CMP r11d, 0			; comparo para ver si ya miré todas las columnas
				JE cambiarDeFila
				CMP r11d, 16		; comparo para ver si estoy cerca del w
				JL redimensionar
				

				; Desarma los 16 bytes en 16 words repartidas en 4 registros
				MOVDQU xmm0, [r14]		; carga en xmm0 16 bytes de src
				LEA rbx, [r14+r8]		; carga en rbx src+src_row_size
				MOVDQU xmm2, [rbx]		; carga en xmm1 16 bytes de src+src_row_size
				LEA rbx, [rbx+r8]		; carga en rbx src+src_row_size
				MOVDQU xmm4, [rbx]		; carga en xmm2 16 bytes de src+2*src_row_size
				LEA rbx, [rbx+r8]		; carga en rbx src+src_row_size
				MOVDQU xmm6, [rbx]		; carga en xmm3 16 bytes de src+3*src_row_size
				
				MOVDQU xmm1, xmm0		; pasa xmm0 también a xmm1 para desempaquetar en los dos
				MOVDQU xmm3, xmm2		; pasa xmm2 también a xmm3 para desempaquetar en los dos
				MOVDQU xmm5, xmm4		; pasa xmm4 también a xmm5 para desempaquetar en los dos
				MOVDQU xmm7, xmm6		; pasa xmm6 también a xmm7 para desempaquetar en los dos
				
				PXOR xmm15, xmm15		; limpia xmm15
				PUNPCKHBW xmm0, xmm15	; desempaqueta en xmm0 la parte alta de la primer línea
				PUNPCKLBW xmm1, xmm15	; desempaqueta en xmm1 la parte baja de la primer línea
				PUNPCKHBW xmm2, xmm15	; desempaqueta en xmm2 la parte alta de la segunda línea
				PUNPCKLBW xmm3, xmm15	; desempaqueta en xmm3 la parte baja de la segunda línea
				PUNPCKHBW xmm4, xmm15	; desempaqueta en xmm4 la parte alta de la tercera línea
				PUNPCKLBW xmm5, xmm15	; desempaqueta en xmm5 la parte baja de la tercera línea
				PUNPCKHBW xmm6, xmm15	; desempaqueta en xmm6 la parte alta de la cuarta línea
				PUNPCKLBW xmm7, xmm15	; desempaqueta en xmm7 la parte baja de la cuarta línea
				
				; Suma de las partes altas
				PADDW xmm0, xmm2		; coloca en xmm0 a 1A + 2A
				PADDW xmm0, xmm4		; coloca en xmm0 a 1A + 2A + 3A
				PADDW xmm0, xmm6		; coloca en xmm0 a 1A + 2A + 3A + 4A
				; Suma de las partes bajas
				PADDW xmm1, xmm3		; coloca en xmm0 a 1B + 2B
				PADDW xmm1, xmm5		; coloca en xmm0 a 1B + 2B + 3B
				PADDW xmm1, xmm7		; coloca en xmm0 a 1B + 2B + 3B + 4B
				
				; Resta sumar las sumas parciales de xmm0 y para eso hago shifts
				MOVDQU xmm10, xmm0
				MOVDQU xmm11, xmm0
				MOVDQU xmm12, xmm0

				PSRLDQ xmm10, 2			; shiftea 2 bytes (1 word) a derecha
				PSRLDQ xmm11, 4			; shiftea 4 bytes (2 word) a derecha
				PSRLDQ xmm12, 6			; shiftea 6 bytes (3 word) a derecha

				; Sea xmm0 = (4, 3, 2, ,1) y sea 0 una word de ceros
				PADDW xmm0, xmm10		; deja en xmm0 a (4+0 , 3+4, 3+2, 2+1)
				PADDW xmm0, xmm11		; deja en xmm0 a (4+0+0, 3+4+0, 4+3+2, 3+2+1)
				PADDW xmm0, xmm12		; deja en xmm0 a (4+0+0+0, 3+4+0+0, 2+3+4+0, 1+2+3+4) y lo mismo con el otro

				; Hay que poner 1+2+3+4 en las cuatro posiciones, eso lo hago con máscaras y shifts
				MOVDQU xmm15, [maskDejarPrimeroYCuarto]; pone en xmm15 la máscara para filtrar el primer word
				PAND xmm0, xmm15		; deja en xmm0 a (1+2+3+4, 0, 0, 0)
				MOVDQU xmm10, xmm0		; pone en xmm10 una copia de xmm0
				PSLLDQ xmm10, 2			; shiftea 1 word a derecha y queda xmm10 = (0, 1+2+3+4, 0, 0)
				PADDW xmm0, xmm10		; suma xmm0 y xmm10 y queda xmm0 = (1+2+3+4, 1+2+3+4, 0, 0)
				PSLLDQ xmm10, 2			; shiftea 1 word a derecha y queda xmm1 = (0, 0, 1+2+3+4, 0)
				PADDW xmm0, xmm10		; suma xmm0 y xmm10 y queda xmm0 = (1+2+3+4, 1+2+3+4, 1+2+3+4, 0)
				PSLLDQ xmm10, 2			; shiftea 1 word a derecha y queda xmm1 = (0, 0, 0, 1+2+3+4)
				PADDW xmm0, xmm10		; suma xmm0 y xmm10 y queda xmm0 = (1+2+3+4, 1+2+3+4, 1+2+3+4, 1+2+3+4) con los otro a derecha
				; Hay que dividir cada parte por 16
				PSRAW xmm0, 4			; mueve dos bits a derecha (divide por 16)
				
				; Resta sumar las sumas parciales de xmm1 y para eso hago shifts
				MOVDQU xmm10, xmm1
				MOVDQU xmm11, xmm1
				MOVDQU xmm12, xmm1

				PSRLDQ xmm10, 2			; shiftea 2 bytes (1 word) a izquierda
				PSRLDQ xmm11, 4			; shiftea 4 bytes (2 word) a izquierda
				PSRLDQ xmm12, 6			; shiftea 6 bytes (3 word) a izquierda

				; Sea xmm1 = (1, 2, 3, 4) y sea 0 una word de ceros
				PADDW xmm1, xmm10		; deja en xmm0 a (1+2, 2+3, 3+4, 4+0)
				PADDW xmm1, xmm11		; deja en xmm0 a (1+2+3, 2+3+4, 3+4+0, 4+0+0)
				PADDW xmm1, xmm12		; deja en xmm0 a (1+2+3+4, 2+3+4+0, 3+4+0+0, 4+0+0+0)

				; Hay que poner 1+2+3+4 en las cuatro posiciones, eso lo hago con máscaras y shifts
				MOVDQU xmm15, [maskDejarPrimeroYCuarto]; pone en xmm15 la máscara para filtrar el primer word (el cuarto también pero pienso en uno porque el otro es igual)
				PAND xmm1, xmm15		; deja en xmm1 a (0, 0, 0, 1+2+3+4)
				MOVDQU xmm10, xmm1		; pone en xmm1 una copia de xmm10
				PSLLDQ xmm10, 2			; shiftea 1 word a izquierda y queda xmm10 = (0, 0, 1+2+3+4, 0)
				PADDW xmm1, xmm10		; suma xmm1 y xmm10 y queda xmm1 = (0, 0, 1+2+3+4, 1+2+3+4)
				PSLLDQ xmm10, 2			; shiftea 1 word a izquierda y queda xmm10 = (0, 1+2+3+4, 0, 0)
				PADDW xmm1, xmm10		; suma xmm0 y xmm1 y queda xmm1 = (0, 1+2+3+4, 1+2+3+4, 1+2+3+4)
				PSLLDQ xmm10, 2			; shiftea 1 word a izquierda y queda xmm10 = (1+2+3+4, 0, 0, 0)
				PADDW xmm1, xmm10		; suma xmm1 y xmm10 y queda xmm1 = (1+2+3+4, 1+2+3+4, 1+2+3+4, 1+2+3+4)
				; Hay que dividir cada parte por 16
				PSRAW xmm1, 4			; mueve dos bits a derecha (divide por 16)
				
				
				PACKUSWB xmm1, xmm0		; empaqueta
				
					
				MOVDQU [r13], xmm1		; pasa a dst el resultado
				LEA rbx, [r13+r9]		; carga en rbx dst + dst_row_size
				MOVDQU [rbx], xmm1		; pasa a dst+dst_row_size el resultado
				LEA rbx, [rbx+r9]		; carga en rbx dst + 2*dst_row_size
				MOVDQU [rbx], xmm1		; pasa a dst+dst_row_size el resultado
				LEA rbx, [rbx+r9]		; carga en rbx dst + 3*dst_row_size
				MOVDQU [rbx], xmm1		; pasa a dst+dst_row_size el resultado
				

				ADD r14, 16				; avanzo iterador
				ADD r13, 16				; avanzo iterador
				SUB r11d, 16			; resto 16 columnas
				JMP cicloPorColumna

			redimensionar:
					MOV eax, 16				; rax finalmente va a tener el desplazamiento total
					SUB eax, r11d			; calculo el desplazamiento total (16 - (totalCol - procesCol))
					SUB r13, rax			; atraso los iteradores
					SUB r14, rax			;
					MOV r11d, 16			;
					JMP cicloPorColumna

			cambiarDeFila:
					ADD rdi, r8				; aumenta a rdi el src_row_size
					ADD rdi, r8				; aumenta a rdi el src_row_size
					ADD rdi, r8				; aumenta a rdi el src_row_size
					ADD rdi, r8				; aumenta a rdi el src_row_size (queda rdi = rdi + 4*src_row_size)
					ADD rsi, r9				; aumenta a rsi el dst_row_size
					ADD rsi, r9				; aumenta a rsi el dst_row_size
					ADD rsi, r9				; aumenta a rsi el dst_row_size
					ADD rsi, r9				; aumenta a rsi el dst_row_size (queda rsi = rsi + 4*dst_row_size)
					DEC edx
					DEC edx
					DEC edx
					DEC edx
					JMP cicloPorFila

 
	salir:
		POP r15
		POP r14
		POP r13
		POP rbx
		POP rbp

		RET

; void combinar_asm (
; 	unsigned char *src_a,
; 	unsigned char *src_b,
; 	unsigned char *dst,
; 	int m,
; 	int n,
; 	int row_size,
; 	float alpha
; );

global combinar_asm

section .data
mascaraAlpha: DD 0xFFFFFFFF, 0x00000000, 0x0000000, 0x000000000 
mascara255: DD 0x000000FF, 0x000000FF, 0x000000FF, 0x000000FF

section .text
combinar_asm:
	; rdi --> puntero a src a
	; rsi --> puntero a src b
	; rdx --> puntero a dst
	; rcx --> m (cantidad de filas)
	; r8 --> n (cantidad de columnas)
	; r9 --> row_size

	;xmm0 --> alpha

	PUSH rbp;A
	MOV rbp,rsp;
	PUSH r15;D
	PUSH r14;A
	PUSH r13;D
	SUB rsp, 8;A

	XOR r11, r11 				; limpio r11
	XOR rax, rax				; limpio rax


	;LIMPIO LAS PARTES ALTAS DE LOS REGISTROS 

	MOV r11d, ecx				; muevo m a r11d
	XOR rcx, rcx				; limpio rcx
	MOV ecx, r11d				; vuelvo a poner m en ecx

	MOV r11d, r8d				; muevo n a r11d
	XOR r8, r8					; limpio r8
	MOV r8d, r11d				; vuelvo a poner n en r8d

	MOV r11d, r9d				; muevo row_size a r11d
	XOR r9, r9					; limpio r9
	MOV r9d, r11d				; vuelvo a poner row_size en r9d

	


	PXOR xmm1,xmm1				; limpio xmm1
	PAND xmm0, [mascaraAlpha] 	; xmm0 = [ 0 | 0 | 0 | alpha ]
	MOVUPS xmm1,xmm0			; xmm0 = xmm1
	PSLLDQ xmm0, 4				; xmm0 = [ 0 | 0 | alpha | 0  ]
	ADDPS xmm0,xmm1				; xmm0 = [ 0 | 0 | alpha | alpha ]
	MOVUPS xmm1,xmm0			; xmm0 = xmm1
	PSLLDQ xmm1, 8				; xmm0 = [ alpha | alpha | 0 | 0  ]
	ADDPS xmm0,xmm1				; xmm0 = [ alpha | alpha | alpha | alpha ]


	MOVUPS xmm15, [mascara255]	; cargo en xmm15 la mascara con 255
	CVTDQ2PS xmm15, xmm15		; paso el 255 a float 


	cicloPorFilaCO:
			CMP ecx, 0				; para ver si termine de ciclar todas las filas
			JE salirCO

			MOV r11d, r8d			; muevo la cantidad de columnas a r11
			MOV r14, rdi			; hago el iterador de columnas de srca
			MOV r15, rsi			; hago el iterador de columnas de srcb
			MOV r13, rdx			; hago el iterador de columnas de dst

			cicloPorColumnaCO:
			 	CMP r11d, 0				; comparo para ver si ya miré todas las columnas
				JE cambiarDeFilaCO
			 	CMP r11d, 16			; comparo para ver si estoy cerca del w
				JL redimensionarCO

				MOVDQU xmm1, [r14]		; muevo a xmm1 los 16 primeros pixels del srca
				MOVDQU xmm2, [r15]		; muevo a xmm2 los 16 primeros pixels del srcb 
			    ;PARES = SRC B    /////// IMPARES = SRC A
				MOVDQU xmm3, xmm1		; Creo copias para las partes bajas
				MOVDQU xmm4, xmm2		; 


				PXOR xmm11, xmm11		; limpio xmm11	

				PUNPCKHBW xmm1, xmm11	; xmm1 = 0 | Pixel15A | 0 | Pixel14A | 0 | Pixel13A | .... |  0 | Pixel09A | 0 | Pixel08A  (entre || hay 1 byte)
				PUNPCKHBW xmm2, xmm11	; xmm2 = 0 | Pixel15B | 0 | Pixel14B | 0 | Pixel13B | .... |  0 | Pixel09B | 0 | Pixel08B  (entre || hay 1 byte)
				PUNPCKLBW xmm3, xmm11	; xmm3 = 0 | Pixel07A | 0 | Pixel06A | 0 | Pixel05A | .... |  0 | Pixel01A | 0 | Pixel00A  (entre || hay 1 byte)
				PUNPCKLBW xmm4, xmm11	; xmm4 = 0 | Pixel07B | 0 | Pixel06B | 0 | Pixel05B | .... |  0 | Pixel01B | 0 | Pixel00B  (entre || hay 1 byte)
				
				PSUBW xmm1,xmm2			; Calculo "Pixel i de a" - "Pixel i de b" (altos)
				PSUBW xmm3,xmm4			; Calculo "Pixel i de a" - "Pixel i de b" (bajos)				
 

				MOVDQU xmm5, xmm1		; Pongo en xmm5 a (a - b) parte alta
				MOVDQU xmm7, xmm3		; Pongo en xmm7 a (a - b) parte baja
				MOVDQU xmm6, xmm2		; Pongo en xmm6 a parte alta de b
				MOVDQU xmm8,xmm4		; Pongo en xmm8 a parte baja de b

			
				PMOVSXWD xmm1, xmm5		; xmm1 = Pixel15A - Pixel15B | Pixel14A - Pixel14B | Pixel13A - Pixel13B | Pixel12A - Pixel12B (cada de uno de tamaño DWord)
				PSRLDQ xmm5, 8			; xmm5 = Pixel11A - Pixel11B | Pixel10A - Pixel10B | Pixel09A - Pixel09B | Pixel08A - Pixel08B | 0 | 0 | 0 | 0 (cada de uno de tamaño Word)
				PMOVSXWD xmm5, xmm5		; xmm5 = Pixel11A - Pixel11B | Pixel10A - Pixel10B | Pixel09A - Pixel09B | Pixel08A - Pixel08B (cada de uno de tamaño DWord)
				
				PMOVSXWD xmm3, xmm7		; xmm3 = Pixel07A - Pixel07B | Pixel06A - Pixel06B | Pixel05A - Pixel05B | Pixel04A - Pixel04B (cada de uno de tamaño DWord)
				PSRLDQ xmm7, 8			; xmm7 = Pixel03A - Pixel03B | Pixel02A - Pixel02B | Pixel01A - Pixel01B | Pixel00A - Pixel00B | 0 | 0 | 0 | 0 (cada de uno de tamaño Word)
				PMOVSXWD xmm7, xmm7		; xmm7 = Pixel03A - Pixel03B | Pixel02A - Pixel02B | Pixel01A - Pixel01B | Pixel00A - Pixel00B (cada de uno de tamaño DWord)
							
				PMOVSXWD xmm2, xmm6		; xmm2 = Pixel15B | Pixel14B | Pixel13B | Pixel12B (cada de uno de tamaño DWord)
				PSRLDQ xmm6, 8			; xmm6 = Pixel11B | Pixel10B | Pixel09B | Pixel08B | 0 | 0 | 0 | 0 (cada de uno de tamaño Word)
				PMOVSXWD xmm6, xmm6		; xmm6 = Pixel11B | Pixel10B | Pixel09B | Pixel08B (cada de uno de tamaño DWord)
				
				PMOVSXWD xmm4, xmm8		; xmm4 = Pixel07B | Pixel06B | Pixel05B | Pixel04B (cada de uno de tamaño DWord)
				PSRLDQ xmm8, 8			; xmm8 = Pixel03B | Pixel02B | Pixel01B | Pixel00B | 0 | 0 | 0 | 0 (cada de uno de tamaño Word)
				PMOVSXWD xmm8, xmm8		; xmm8 = Pixel03B | Pixel02B | Pixel01B | Pixel00B (cada de uno de tamaño DWord)
				 
		
				CVTDQ2PS xmm1,xmm1		; Paso los enteros de 4 bytes a float de 4 bytes
				CVTDQ2PS xmm3,xmm3		;
				CVTDQ2PS xmm5,xmm5		;
				CVTDQ2PS xmm7,xmm7		;

				MULPS xmm1,xmm0			; alpha(xmm0) * ("Pixel i de a" - "Pixel i de b")     (los altos)
				MULPS xmm3,xmm0			; alpha(xmm0) * ("Pixel i de a" - "Pixel i de b")     (los bajos)
				MULPS xmm5,xmm0			;
				MULPS xmm7,xmm0			;
								
				DIVPS xmm1,xmm15		; alpha(xmm0) * ("Pixel i de a" - "Pixel i de b") / 255    (los altos)
				DIVPS xmm3,xmm15		; alpha(xmm0) * ("Pixel i de a" - "Pixel i de b") / 255    (los bajos)
				DIVPS xmm5,xmm15		;
				DIVPS xmm7,xmm15		;

				CVTPS2DQ xmm1,xmm1		; Paso los floats de 4 bytes a enteros de 4 bytes
				CVTPS2DQ xmm3,xmm3		;	
				CVTPS2DQ xmm5,xmm5		;
				CVTPS2DQ xmm7,xmm7		;
				
				PADDD xmm1,xmm2			; xmm1 = [Pixel15A - Pixel15B | Pixel14A - Pixel14B | Pixel13A - Pixel13B | Pixel12A - Pixel12B] * alpha / 255 + [Pixel15B | Pixel14B | Pixel13B | Pixel12B]
				PADDD xmm3,xmm4			; xmm3 = [Pixel07A - Pixel07B | Pixel06A - Pixel06B | Pixel05A - Pixel05B | Pixel04A - Pixel04B] * aplha / 255 + [Pixel07B | Pixel06B | Pixel05B | Pixel04B]
				PADDD xmm5,xmm6			; xmm5 = [Pixel11A - Pixel11B | Pixel10A - Pixel10B | Pixel09A - Pixel09B | Pixel08A - Pixel08B] * alpha / 255 + [Pixel11B | Pixel10B | Pixel09B | Pixel08B]
				PADDD xmm7,xmm8			; xmm7 = [Pixel03A - Pixel03B | Pixel02A - Pixel02B | Pixel01A - Pixel01B | Pixel00A - Pixel00B] * alpha / 255 + [Pixel03B | Pixel02B | Pixel01B | Pixel00B]

				PACKSSDW xmm1, xmm5		; Empaqueto a words
				PACKSSDW xmm3, xmm7		;
	
				PACKUSWB xmm3, xmm1		; junto los 2 resultados


				;Escribo en dst
				MOVDQU [r13] ,xmm3 		; escribo en dst


				ADD r14, 16				; avanzo iterador
				ADD r15, 16				; avanzo iterador
				ADD r13, 16				; avanzo iterador
				SUB r11d, 16			; resto 16 columna (pixels)
				JMP cicloPorColumnaCO

			redimensionarCO:
					MOV eax, 16				; rax finalmente va a tener el desplazamiento total
					SUB eax, r11d			; calculo el desplazamiento total (16 - (totalCol - procesCol))
					;ajusto los iteradores
					SUB r13, rax			; atraso los iteradores
					SUB r14, rax			;
					SUB r15, rax			;
					MOV r11d, 16			;
					JMP cicloPorColumnaCO


			cambiarDeFilaCO:
					LEA rdi, [rdi + r9]		; sumo el row_size
					LEA rsi, [rsi + r9]		; sumo el row_size
					LEA rdx, [rdx + r9]		; sumo el row_size
					DEC ecx					; resto 1 fila
					JMP cicloPorFilaCO

 
	salirCO:
		ADD rsp, 8
		POP r13
		POP r14
		POP r15
		POP rbp

		RET


global roberts_cross_asm

section .data
gxInf: DQ 0x00FF00FF00FF00FF, 0x00FF00FF00FF00FF ; las posiciones son iguales a las de gyInf
gxSup: DQ 0xFF00FF00FF00FF00, 0xFF00FF00FF00FF00 ; las posiciones son iguales a las de gySup
mask: DQ 0xFFFF0000FFFF0000, 0xFFFF0000FFFF0000
maskMultiplode4: DQ 0xFFFFFFFFFFFFFFFC

section .text
roberts_cross_asm:
	; rdi --> puntero a src
	; rsi --> puntero a dst
	; rdx --> m (cantidad de filas)
	; rcx --> n (cantidad de columnas)
	; r8  --> src_row_size
	; r9  --> dst_row_size
	
	

	PUSH rbp
	MOV rbp,rsp		; arma StackFrame
	PUSH r15
	PUSH r14
	PUSH r13
	PUSH r12

	XOR r11, r11; 

	MOV r14, rdi; muevo a r14 el puntero a src
	MOV r13, rsi; muevo a r13 el puntero a dst



	;LIMPIO LAS PARTES ALTAS DE LOS REGISTROS  (porque son de 64 bits y acá uso sólo 32)

	;En rdx tengo la cantidad de filas
	MOV r12d, edx;
	XOR rdx, rdx;
	MOV edx, r12d;

	; En rcx la cantidad de columnas
	MOV r12d, ecx;
	XOR rcx, rcx;
	MOV ecx, r12d;

	; En r8 el src_row size
	MOV r12d, r8d;
	XOR r8, r8;
	MOV r8d, r12d;

	; En r9 el dst_row size
	MOV r12d, r9d;
	XOR r9, r9;
	MOV r9d, r12d;

	AND rcx, [maskMultiplode4]	; corta el resto módulo 4 del ancho
	AND rdx, [maskMultiplode4]	; corta el resto módulo 4 del alto

	;rdx --> filas
	;rcx --> columnas
	;r8  --> src_row_size
	;r9  --> dst_row_size
	
	MOVDQU xmm0, [mask]				; levanta la máscara y la deja siempre en xmm0


	.cicloPorFila:
			MOV r11, rcx					; mueve la cantidad de columnas a r11
			MOV r14, rdi					; mueve a r14 el puntero al primero de la fila
			MOV r13, rsi					; mueve a r13 el puntero al dst



			CMP edx, 1						; para ver si terminó de ciclar todas las filas (compara con 1 pues la última no hay que procesarla)
			JE .cicloPorColumnaUltima



			.cicloPorColumna:
				CMP r11, 1					; compara para ver si ya miró todas las columnas (deja 1 pues ese no se procesa)
				JE .cambiarDeFila
				CMP r11, 16					; compara para ver si queda un tamaño menor al de procesado (16 en este caso)
				JL .actualizarFinal

				; Procesamiento de Extremos
				MOVDQU xmm1, [r14]			; lee de src: sup15 | sup14 | sup13 | sup12 | sup11 | sup10 | sup9 | sup8 | sup7 | sup6 | sup5 | sup4 | sup3 | sup2 | sup1 | sup0
				MOVDQU xmm2, [r14 + r8]		; lee de src: inf15 | inf14 | inf13 | inf12 | inf11 | inf10 | inf9 | inf8 | inf7 | inf6 | inf5 | inf4 | inf3 | inf2 | inf1 | inf0
				MOVDQU xmm3, xmm1			; copia sup
				MOVDQU xmm4, xmm2			; copia inf
							
				PXOR xmm12, xmm12			; limpia xmm12 para poder extender apropiadamente
				PUNPCKLBW xmm1, xmm12		; extiende a word la parte alta de sup: sup15 | sup14 | sup13 | sup12 | sup11 | sup10 | sup9 | sup8 
				PUNPCKHBW xmm3, xmm12		; extiende a word la parte baja de sup: sup7 | sup6 | sup5 | sup4 | sup3 | sup2 | sup1 | sup0 
				PUNPCKLBW xmm2, xmm12		; extiende a word la parte alta de inf: inf15 | inf14 | inf13 | inf12 | inf11 | inf10 | inf9 | inf8
				PUNPCKHBW xmm4, xmm12		; extiende a word la parte baja de inf: inf7 | inf6 | inf5 | inf4 | inf3 | inf2 | inf1 | inf0 
							
				MOVDQU xmm12, xmm0			; copia la máscara a xmm12
				
				MOVDQU xmm5, xmm12			; copia extensión: 0000 FFFF 0000 FFFF 0000 FFFF 0000 FFFF
				MOVDQU xmm7, xmm12			; copia extensión: 0000 FFFF 0000 FFFF 0000 FFFF 0000 FFFF
				MOVDQU xmm9, xmm12			; copia extensión: 0000 FFFF 0000 FFFF 0000 FFFF 0000 FFFF
				MOVDQU xmm11, xmm12			; copia extensión: 0000 FFFF 0000 FFFF 0000 FFFF 0000 FFFF
				PSRLDQ xmm12, 2				; xmm12: FFFF 0000 FFFF 0000 FFFF 0000 FFFF 0000
				MOVDQU xmm6, xmm12			; copia extensión: FFFF 0000 FFFF 0000 FFFF 0000 FFFF 0000
				MOVDQU xmm8, xmm12			; copia extensión: FFFF 0000 FFFF 0000 FFFF 0000 FFFF 0000
				MOVDQU xmm10, xmm12			; copia extensión: FFFF 0000 FFFF 0000 FFFF 0000 FFFF 0000
				
				; Datos para Mx
				PAND xmm5, xmm1				; deja en xmm5: 0 | sup14 | 0 | sup12 | 0 | sup10 | 0 | sup8
				PAND xmm7, xmm3				; deja en xmm7: 0 | sup6 | 0 | sup4 | 0 | sup2 | 0 | sup0
				PAND xmm6, xmm2				; deja en xmm6: inf15 | 0 | inf13 | 0 | inf11 | 0 | inf9 | 0
				PAND xmm8, xmm4				; deja en xmm8: inf7 | 0 | inf5 | 0 | inf3 | 0 | inf1 | 0
                
				; Datos para My
				PAND xmm9, xmm2				; deja en xmm9: 0 | inf14 | 0 | inf12 | 0 | inf10 | 0 | inf8
				PAND xmm11, xmm4			; deja en xmm11: 0 | inf6 | 0 | inf4 | 0 | inf2 | 0 | inf0
				PAND xmm10, xmm1			; deja en xmm10: sup15 | 0 | sup13 | 0 | sup11 | 0 | sup9 | 0
				PAND xmm12, xmm3			; deja en xmm12: sup7 | 0 | sup5 | 0 | sup3 | 0 | sup1 | 0
				
				; Shifts para sumar todo en la misma posición
				PSLLDQ xmm6, 2				; deja en xmm6: 0 | inf15 | 0 | inf13 | 0 | inf11 | 0 | inf9
				PSLLDQ xmm8, 2				; deja en xmm8: 0 | inf7 | 0 | inf5 | 0 | inf3 | 0 | inf1
				PSLLDQ xmm10, 2				; deja en xmm10: 0 | sup15 | 0 | sup13 | 0 | sup11 | 0 | sup9
				PSLLDQ xmm12, 2				; deja en xmm12: 0 | sup7 | 0 | sup5 | 0 | sup3 | 0 | sup1
				
				; Calcula Mx
				PSUBW xmm5, xmm6			; deja en xmm5: 0 | sup14-inf15 | 0 | sup12-inf13 | 0 | sup10-inf11 | 0 | sup8-inf9
				PSUBW xmm7, xmm8			; deja en xmm7: 0 | sup6-inf7 | 0 | sup4-inf5 | 0 | sup2-inf3 | 0 | sup0-inf1
				; Mx es xmm5 : xmm7 o sea 	0 | Hx | 0 | Gx | 0 | Fx | 0 | Ex : 0 | Dx | 0 | Cx | 0 | Bx | 0 | Ax
                
				; Calcula My
				PSUBW xmm10, xmm9			; deja en xmm10: 0 | sup15-inf14 | 0 | sup13-inf12 | 0 | sup11-inf10 | 0 | sup9-inf8
				PSUBW xmm12, xmm11			; deja en xmm12: 0 | sup7-inf6 | 0 | sup5-inf4 | 0 | sup3-inf2 | 0 | sup1-inf0
				; By es xmm10 : xmm12 o sea 0 | Hy | 0 | Gy | 0 | Fy | 0 | Ey : 0 | Dy | 0 | Cy | 0 | By | 0 | Ay
				
				; Calcula Mx²
				MOVDQU xmm6, xmm5			; xmm6: 0 | Hx | 0 | Gx | 0 | Fx | 0 | Ex
				PMULHW xmm5, xmm5			; xmm5: 0 | HighHx² | 0 | HighGx² | 0 | HighFx² | 0 | HighEx²
				PMULLW xmm6, xmm6			; xmm6: 0 | LowHx² | 0 | LowGx² | 0 | LowFx² | 0 | LowEx²
				PSRLDQ xmm6, 2				; xmm6: LowHx² | 0 | LowGx² | 0 | LowFx² | 0 | LowEx² | 0
				POR xmm5, xmm6				; xmm5: LowHx² | HighHx² | LowGx² | HighGx² | LowFx² | HighFx² | LowEx² | HighEx²
				; o sea xmm5: Hx² | Gx² | Fx² | Ex²
				MOVDQU xmm8, xmm7			; xmm8: 0 | Dx | 0 | Cx | 0 | Bx | 0 | Ax
				PMULHW xmm7, xmm7			; xmm7: 0 | HighDx² | 0 | HighCx² | 0 | HighBx² | 0 | HighAx²
				PMULLW xmm8, xmm8			; xmm8: 0 | LowDx² | 0 | LowCx² | 0 | LowBx² | 0 | LowAx²
				PSRLDQ xmm8, 2				; xmm8: LowDx² | 0 | LowCx² | 0 | LowBx² | 0 | LowAx² | 0
				POR xmm7, xmm8				; xmm7: LowDx² | HighDx² | LowCx² | HighCx² | LowBx² | HighBx² | LowAx² | HighAx²
				; o sea xmm7: Dx² | Cx² | Bx² | Ax² pues al organizarse en little endian Low : High da el resultado bien
				
				; Calcula My²
				MOVDQU xmm11, xmm12			; xmm11: 0 | Dy | 0 | Cy | 0 | By | 0 | Ay
				PMULHW xmm12, xmm12			; xmm12: 0 | HighDy² | 0 | HighCy² | 0 | HighBy² | 0 | HighAy²
				PMULLW xmm11, xmm11			; xmm11: 0 | LowDy² | 0 | LowCy² | 0 | LowBy² | 0 | LowAy²
				PSRLDQ xmm11, 2				; xmm11: LowDy² | 0 | LowCy² | 0 | LowBy² | 0 | LowAy² | 0
				POR xmm12, xmm11			; xmm12: LowDy² | HighDy² | LowCy² | HighCy² | LowBy² | HighBy² | LowAy² | HighAy²
				; o sea xmm12: Dy² | Cy² | By² | Ay²
				MOVDQU xmm9, xmm10			; xmm9: 0 | Hy | 0 | Gy | 0 | Fy | 0 | Ey
				PMULHW xmm10, xmm10			; xmm10: 0 | HighHy² | 0 | HighGy² | 0 | HighFy² | 0 | HighEy²
				PMULLW xmm9, xmm9			; xmm9: 0 | LowHy² | 0 | LowGy² | 0 | LowFy² | 0 | LowEy²
				PSRLDQ xmm9, 2				; xmm9: LowHy² | 0 | LowGy² | 0 | LowFy² | 0 | LowEy² | 0
				POR xmm10, xmm9				; xmm10: LowHy² | HighHy² | LowGy² | HighGy² | LowFy² | HighFy² | LowEy² | HighEy²
				; o sea xmm10: Hy² | Gy² | Fy² | Ey² pues al organizarse en little endian Low : High da el resultado bien
				
				; Calcula √(Mx² + My²)
				PADDD xmm5, xmm10			; xmm5: Hx²+Hy² | Gx²+Gy² | Fx²+Fy² | Ex²+Ey²
				PADDD xmm7, xmm12			; xmm7: Dx²+Dy² | Cx²+Cy² | Bx²+By² | Ax²+Ay²
				CVTDQ2PS xmm5, xmm5			; convierte a float
				CVTDQ2PS xmm7, xmm7			; convierte a float
				SQRTPS xmm5, xmm5			; xmm5: √(Hx²+Hy²) | √(Gx²+Gy²) | √(Fx²+Fy²) | √(Ex²+Ey²)
				SQRTPS xmm7, xmm7			; xmm7: √(Dx²+Dy²) | √(Cx²+Cy²) | √(Bx²+By²) | √(Ax²+Ay²)
				CVTPS2DQ xmm5, xmm5			; convierte a entero
				CVTPS2DQ xmm7, xmm7			; convierte a entero
				MOVDQU xmm6, xmm7
				; o sea xmm5: √(Hx²+Hy²) | √(Gx²+Gy²) | √(Fx²+Fy²) | √(Ex²+Ey²)
				;		xmm6: √(Dx²+Dy²) | √(Cx²+Cy²) | √(Bx²+By²) | √(Ax²+Ay²)
				
				; Reubica para que queden intercalados con ceros
				MOVDQU xmm7, xmm5			; xmm7: √(Hx²+Hy²) | √(Gx²+Gy²) | √(Fx²+Fy²) | √(Ex²+Ey²)
				MOVDQU xmm8, xmm5			; xmm8: √(Hx²+Hy²) | √(Gx²+Gy²) | √(Fx²+Fy²) | √(Ex²+Ey²)
				MOVDQU xmm9, xmm5			; xmm9: √(Hx²+Hy²) | √(Gx²+Gy²) | √(Fx²+Fy²) | √(Ex²+Ey²)
				MOVDQU xmm10, xmm5			; xmm10: √(Hx²+Hy²) | √(Gx²+Gy²) | √(Fx²+Fy²) | √(Ex²+Ey²)
				PSRLDQ xmm7, 12				; xmm7: √(Ex²+Ey²) | 0 | 0 | 0
				PSLLDQ xmm7, 12				; xmm7: 0 | 0 | 0 | √(Ex²+Ey²)
				PSLLDQ xmm8, 4				; xmm8: 0 | √(Hx²+Hy²) | √(Gx²+Gy²) | √(Fx²+Fy²)
				PSRLDQ xmm8, 12				; xmm8: √(Fx²+Fy²) | 0 | 0 | 0
				PSLLDQ xmm8, 4				; xmm8: 0 | √(Fx²+Fy²) | 0 | 0
				PSRLDQ xmm9, 4				; xmm9: √(Gx²+Gy²) | √(Fx²+Fy²) | √(Ex²+Ey²) | 0
				PSLLDQ xmm9, 12				; xmm9: 0 | 0 | 0 | √(Gx²+Gy²)
				PSLLDQ xmm10, 12 			; xmm10: 0 | 0 | 0 | √(Hx²+Hy²)
				PSRLDQ xmm10, 8				; xmm10: 0 | √(Hx²+Hy²) | 0 | 0
				POR xmm7, xmm8				; xmm7: 0 | √(Fx²+Fy²) | 0 | √(Ex²+Ey²)
				POR xmm9, xmm10				; xmm9: 0 | √(Hx²+Hy²) | 0 | √(Gx²+Gy²)
				PACKUSDW xmm9, xmm7			; xmm7: 0 | √(Hx²+Hy²) | 0 | √(Gx²+Gy²) | 0 | √(Fx²+Fy²) | 0 | √(Ex²+Ey²)
				MOVDQU xmm5, xmm9			; xmm5: 0 | √(Hx²+Hy²) | 0 | √(Gx²+Gy²) | 0 | √(Fx²+Fy²) | 0 | √(Ex²+Ey²)
				
				MOVDQU xmm7, xmm6			; xmm7: √(Dx²+Dy²) | √(Cx²+Cy²) | √(Bx²+By²) | √(Ax²+Ay²)
				MOVDQU xmm8, xmm6			; xmm8: √(Dx²+Dy²) | √(Cx²+Cy²) | √(Bx²+By²) | √(Ax²+Ay²)
				MOVDQU xmm9, xmm6			; xmm9: √(Dx²+Dy²) | √(Cx²+Cy²) | √(Bx²+By²) | √(Ax²+Ay²)
				MOVDQU xmm10, xmm6			; xmm10: √(Dx²+Dy²) | √(Cx²+Cy²) | √(Bx²+By²) | √(Ax²+Ay²)
				PSRLDQ xmm7, 12				; xmm7: √(Ax²+Ay²) | 0 | 0 | 0
				PSLLDQ xmm7, 12				; xmm7: 0 | 0 | 0 | √(Ax²+Ay²)
				PSLLDQ xmm8, 4				; xmm8: 0 | √(Dx²+Dy²) | √(Cx²+Cy²) | √(Bx²+By²)
				PSRLDQ xmm8, 12				; xmm8: √(Bx²+By²) | 0 | 0 | 0
				PSLLDQ xmm8, 4				; xmm8: 0 | √(Bx²+By²) | 0 | 0
				PSRLDQ xmm9, 4				; xmm9: √(Cx²+Cy²) | √(Bx²+By²) | √(Ax²+Ay²) | 0
				PSLLDQ xmm9, 12				; xmm9: 0 | 0 | 0 | √(Cx²+Cy²)
				PSLLDQ xmm10, 12 			; xmm10: 0 | 0 | 0 | √(Dx²+Dy²)
				PSRLDQ xmm10, 8				; xmm10: 0 | √(Dx²+Dy²) | 0 | 0
				POR xmm7, xmm8				; xmm7: 0 | √(Bx²+By²) | 0 | √(Ax²+Ay²)
				POR xmm9, xmm10				; xmm9: 0 | √(Dx²+Dy²) | 0 | √(Cx²+Cy²)
				PACKUSDW xmm9, xmm7			; xmm9: 0 | √(Dx²+Dy²) | 0 | √(Cx²+Cy²) | 0 | √(Bx²+By²) | 0 | √(Ax²+Ay²)
				; o sea que en xmm9 se tienen los resultados para 8 píxeles intercalados desde el principio
				
				PACKUSWB xmm5, xmm9			; xmm5: 0 | √(Hx²+Hy²) | 0 | √(Gx²+Gy²) | 0 | √(Fx²+Fy²) | 0 | √(Ex²+Ey²) | 0 | √(Dx²+Dy²) | 0 | √(Cx²+Cy²) | 0 | √(Bx²+By²) | 0 | √(Ax²+Ay²)
				MOVDQU xmm15, xmm5			; guarda lo calculado para usarlo después
				
			
			; INTERMEDIOS
				
				; Guarda tanto sup8 como inf8 para usarlos después
				MOVDQU xmm13, xmm1			; xmm13: sup15 | sup14 | sup13 | sup12 | sup11 | sup10 | sup9 | sup8
				MOVDQU xmm14, xmm2			; xmm14: inf15 | inf14 | inf13 | inf12 | inf11 | inf10 | inf9 | inf8
				
				; Acomoda lo levantado de memoria para operar similarmente con los intermedios
				PSLLDQ xmm1, 2				; de src: ## | sup15 | sup14 | sup13 | sup12 | sup11 | sup10 | sup9
				PSLLDQ xmm2, 2				; de src: ## | inf15 | inf14 | inf13 | inf12 | inf11 | inf10 | inf9
				PSLLDQ xmm3, 2				; de src: ## | sup7  | sup6  | sup5  | sup4  | sup3  | sup2  | sup1
				PSLLDQ xmm4, 2				; de src: ## | inf7  | inf6  | inf5  | inf4  | inf3  | inf2  | inf1
		
				MOVDQU xmm12, xmm0			; copia la máscara a xmm12
				
				MOVDQU xmm5, xmm12			; copia extensión: 0000 FFFF 0000 FFFF 0000 FFFF 0000 FFFF
				MOVDQU xmm7, xmm12			; copia extensión: 0000 FFFF 0000 FFFF 0000 FFFF 0000 FFFF
				MOVDQU xmm9, xmm12			; copia extensión: 0000 FFFF 0000 FFFF 0000 FFFF 0000 FFFF
				MOVDQU xmm11, xmm12			; copia extensión: 0000 FFFF 0000 FFFF 0000 FFFF 0000 FFFF
				PSRLDQ xmm12, 2				; xmm12: FFFF 0000 FFFF 0000 FFFF 0000 FFFF 0000
				MOVDQU xmm6, xmm12			; copia extensión: FFFF 0000 FFFF 0000 FFFF 0000 FFFF 0000
				MOVDQU xmm8, xmm12			; copia extensión: FFFF 0000 FFFF 0000 FFFF 0000 FFFF 0000
				MOVDQU xmm10, xmm12			; copia extensión: FFFF 0000 FFFF 0000 FFFF 0000 FFFF 0000
				
				; Datos para Mx
				PAND xmm5, xmm1				; deja en xmm5:  0 	  | sup15 | 0	  | sup13 | 0	  | sup11 | 0	  | sup9
				PAND xmm7, xmm3				; deja en xmm7:  0 	  | sup7  | 0	  | sup5  | 0	  | sup3  | 0	  | sup1
				PAND xmm6, xmm2				; deja en xmm6:  ##	  | 0 	  | inf14 | 0	  | inf12 | 0	  | inf10 | 0
				PAND xmm8, xmm4				; deja en xmm8:  ##	  | 0 	  | inf6  | 0	  | inf4  | 0	  | inf2  | 0 
				PSRLDQ xmm8, 2				; deja en xmm8:  0 	  | inf6  | 0	  | inf4  | 0	  | inf2  | 0 	  | 0
				PSLLDQ xmm8, 2				; deja en xmm8:  0 	  | 0 	  | inf6  | 0	  | inf4  | 0	  | inf2  | 0
				PSRLDQ xmm14, 14			; deja en xmm14: inf8 | 0 	  | 0 	  | 0 	  | 0 	  | 0 	  | 0 	  | 0
				POR xmm8, xmm14				; deja en xmm8:  inf8 | 0 	  | inf6  | 0	  | inf4  | 0	  | inf2  | 0
                
				; Datos para My
				PAND xmm9, xmm2				; deja en xmm9:	 0	  | inf15 | 0	  | inf13 | 0	  | inf11 | 0	  | inf9
				PAND xmm11, xmm4			; deja en xmm11: 0	  | inf7  | 0	  | inf5  | 0	  | inf3  | 0	  | inf1
				PAND xmm10, xmm1			; deja en xmm10: ##   | 0	  | sup14 | 0	  | sup12 | 0	  | sup10 | 0
				PAND xmm12, xmm3			; deja en xmm12: ##   | 0	  | sup6  | 0	  | sup4  | 0	  | sup2  | 0
				PSRLDQ xmm12, 2				; deja en xmm12: 0	  | sup6  | 0	  | sup4  | 0	  | sup2  | 0	  | 0
				PSLLDQ xmm12, 2				; deja en xmm12: 0	  | 0	  | sup6  | 0	  | sup4  | 0	  | sup2  | 0
				PSRLDQ xmm13, 14			; deja en xmm13: sup8 | 0 	  | 0 	  | 0 	  | 0 	  | 0 	  | 0 	  | 0
				POR xmm12, xmm13			; deja en xmm12: sup8 | 0	  | sup6  | 0	  | sup4  | 0	  | sup2  | 0
				
				; Shifts para sumar todo en la misma posición
				PSLLDQ xmm6, 2				; deja en xmm6:	 0 | ##   | 0 | inf14 | 0 | inf12 | 0 | inf10
				PSLLDQ xmm8, 2				; deja en xmm8:	 0 | inf8 | 0 | inf6  | 0 | inf4  | 0 | inf2 
				PSLLDQ xmm10, 2				; deja en xmm10: 0 | ##   | 0 | sup14 | 0 | sup12 | 0 | sup10
				PSLLDQ xmm12, 2				; deja en xmm12: 0 | sup8 | 0 | sup6  | 0 | sup4  | 0 | sup2
				
				; Calcula Mx
				PSUBW xmm5, xmm6			; deja en xmm5: 0 | ## 		  | 0 | sup13-inf14 | 0 | sup11-inf12 | 0 | sup9-inf10
				PSUBW xmm7, xmm8			; deja en xmm7: 0 | sup7-inf8 | 0 | sup5-inf6	| 0 | sup3-inf4   | 0 | sup1-inf2
				; Mx es xmm5 : xmm7 o sea 	0 | ## | 0 | Gx | 0 | Fx | 0 | Ex : 0 | Dx | 0 | Cx | 0 | Bx | 0 | Ax
                
				; Calcula My
				PSUBW xmm10, xmm9			; deja en xmm10: 0 | ## 	   | 0 | sup14-inf13 | 0 | sup12-inf11 | 0 | sup10-inf9
				PSUBW xmm12, xmm11			; deja en xmm12: 0 | sup8-inf7 | 0 | sup6-inf5	 | 0 | sup4-inf3   | 0 | sup2-inf1
				; By es xmm10 : xmm12 o sea 0 | ## | 0 | Gy | 0 | Fy | 0 | Ey : 0 | Dy | 0 | Cy | 0 | By | 0 | Ay
				
				; Calcula Mx²
				MOVDQU xmm6, xmm5			; xmm6: 0  | ## | 0		 | Gx	   | 0		| Fx	  | 0	   | Ex
				PMULHW xmm5, xmm5			; xmm5: 0  | ## | 0		 | HighGx² | 0		| HighFx² | 0	   | HighEx²
				PMULLW xmm6, xmm6			; xmm6: 0  | ## | 0		 | LowGx²  | 0		| LowFx²  | 0	   | LowEx²
				PSRLDQ xmm6, 2				; xmm6: ## | 0  | LowGx² | 0	   | LowFx² | 0		  | LowEx² | 0
				POR xmm5, xmm6				; xmm5: ## | ## | LowGx² | HighGx² | LowFx² | HighFx² | LowEx² | HighEx²
				; o sea xmm5: ## | Gx² | Fx² | Ex²
				MOVDQU xmm8, xmm7			; xmm8: 0 	   | Dx		 | 0	  | Cx		| 0		 | Bx	   | 0		| Ax
				PMULHW xmm7, xmm7			; xmm7: 0 	   | HighDx² | 0	  | HighCx² | 0		 | HighBx² | 0		| HighAx²
				PMULLW xmm8, xmm8			; xmm8: 0 	   | LowDx²  | 0	  | LowCx²	| 0		 | LowBx²  | 0		| LowAx²
				PSRLDQ xmm8, 2				; xmm8: LowDx² | 0		 | LowCx² | 0		| LowBx² | 0	   | LowAx² | 0
				POR xmm7, xmm8				; xmm7: LowDx² | HighDx² | LowCx² | HighCx² | LowBx² | HighBx² | LowAx² | HighAx²
				; o sea xmm7: Dx² | Cx² | Bx² | Ax² pues al organizarse en little endian Low : High da el resultado bien
				
				; Calcula My²
				MOVDQU xmm11, xmm12			; xmm11: 0		| Dy	  | 0	   | Cy		 | 0	  | By		| 0		 | Ay
				PMULHW xmm12, xmm12			; xmm12: 0		| HighDy² | 0	   | HighCy² | 0	  | HighBy² | 0		 | HighAy²
				PMULLW xmm11, xmm11			; xmm11: 0		| LowDy²  | 0	   | LowCy²	 | 0	  | LowBy²	| 0		 | LowAy²
				PSRLDQ xmm11, 2				; xmm11: LowDy² | 0		  | LowCy² | 0		 | LowBy² | 0		| LowAy² | 0
				POR xmm12, xmm11			; xmm12: LowDy² | HighDy² | LowCy² | HighCy² | LowBy² | HighBy² | LowAy² | HighAy²
				; o sea xmm12: Dy² | Cy² | By² | Ay²
				MOVDQU xmm9, xmm10			; xmm9:  0	| ## | 0	  | Gy		| 0		 | Fy	   | 0		| Ey
				PMULHW xmm10, xmm10			; xmm10: 0	| ## | 0	  | HighGy² | 0		 | HighFy² | 0		| HighEy²
				PMULLW xmm9, xmm9			; xmm9:  0	| ## | 0	  | LowGy²	| 0		 | LowFy²  | 0		| LowEy²
				PSRLDQ xmm9, 2				; xmm9:  ##	| 0	 | LowGy² | 0		| LowFy² | 0	   | LowEy² | 0
				POR xmm10, xmm9				; xmm10: ##	| ## | LowGy² | HighGy² | LowFy² | HighFy² | LowEy² | HighEy²
				; o sea xmm10: ## | Gy² | Fy² | Ey² pues al organizarse en little endian Low : High da el resultado bien
				
				; Calcula √(Mx² + My²)
				PADDD xmm5, xmm10			; xmm5: ##		| Gx²+Gy² | Fx²+Fy² | Ex²+Ey²
				PADDD xmm7, xmm12			; xmm7: Dx²+Dy² | Cx²+Cy² | Bx²+By² | Ax²+Ay²
				CVTDQ2PS xmm5, xmm5			; convierte a float
				CVTDQ2PS xmm7, xmm7			; convierte a float
				SQRTPS xmm5, xmm5			; xmm5: ##		   | √(Gx²+Gy²) | √(Fx²+Fy²) | √(Ex²+Ey²)
				SQRTPS xmm7, xmm7			; xmm7: √(Dx²+Dy²) | √(Cx²+Cy²) | √(Bx²+By²) | Ax²+Ay²
				CVTPS2DQ xmm5, xmm5			; convierte a entero
				CVTPS2DQ xmm7, xmm7			; convierte a entero
				MOVDQU xmm6, xmm7
				; o sea xmm5: ##		 | √(Gx²+Gy²) | √(Fx²+Fy²) | √(Ex²+Ey²)
				;		xmm6: √(Dx²+Dy²) | √(Cx²+Cy²) | √(Bx²+By²) | √(Ax²+Ay²)
				
				; Reubica para que queden intercalados con ceros
				MOVDQU xmm7, xmm5			; xmm7:  ##			| √(Gx²+Gy²) | √(Fx²+Fy²) | √(Ex²+Ey²)
				MOVDQU xmm8, xmm5			; xmm8:  ##			| √(Gx²+Gy²) | √(Fx²+Fy²) | √(Ex²+Ey²)
				MOVDQU xmm9, xmm5			; xmm9:  ##			| √(Gx²+Gy²) | √(Fx²+Fy²) | √(Ex²+Ey²)
				MOVDQU xmm10, xmm5			; xmm10: ##			| √(Gx²+Gy²) | √(Fx²+Fy²) | √(Ex²+Ey²)
				PSRLDQ xmm7, 12				; xmm7:  √(Ex²+Ey²) | 0			 | 0		  | 0
				PSLLDQ xmm7, 12				; xmm7:  0			| 0			 | 0		  | √(Ex²+Ey²)
				PSLLDQ xmm8, 4				; xmm8:  0			| √(Hx²+Hy²) | √(Gx²+Gy²) | √(Fx²+Fy²)
				PSRLDQ xmm8, 12				; xmm8:  √(Fx²+Fy²) | 0			 | 0		  | 0
				PSLLDQ xmm8, 4				; xmm8:  0			| √(Fx²+Fy²) | 0		  | 0
				PSRLDQ xmm9, 4				; xmm9:  √(Gx²+Gy²) | √(Fx²+Fy²) | √(Ex²+Ey²) | 0
				PSLLDQ xmm9, 12				; xmm9:  0			| 0			 | 0		  | √(Gx²+Gy²)
				PSLLDQ xmm10, 12 			; xmm10: 0			| 0			 | 0		  | √(Hx²+Hy²)
				PSRLDQ xmm10, 8				; xmm10: 0			| √(Hx²+Hy²) | 0		  | 0
				POR xmm7, xmm8				; xmm7:  0			| √(Fx²+Fy²) | 0		  | √(Ex²+Ey²)
				POR xmm9, xmm10				; xmm9:  0			| √(Hx²+Hy²) | 0		  | √(Gx²+Gy²)
				PACKUSDW xmm9, xmm7			; xmm7:  0 | ## | 0 | √(Gx²+Gy²) | 0 | √(Fx²+Fy²) | 0 | √(Ex²+Ey²)
				MOVDQU xmm5, xmm9			; xmm5:  0 | ## | 0 | √(Gx²+Gy²) | 0 | √(Fx²+Fy²) | 0 | √(Ex²+Ey²)
				
				MOVDQU xmm7, xmm6			; xmm7:  √(Dx²+Dy²) | √(Cx²+Cy²) | √(Bx²+By²) | √(Ax²+Ay²)
				MOVDQU xmm8, xmm6			; xmm8:  √(Dx²+Dy²) | √(Cx²+Cy²) | √(Bx²+By²) | √(Ax²+Ay²)
				MOVDQU xmm9, xmm6			; xmm9:  √(Dx²+Dy²) | √(Cx²+Cy²) | √(Bx²+By²) | √(Ax²+Ay²)
				MOVDQU xmm10, xmm6			; xmm10: √(Dx²+Dy²) | √(Cx²+Cy²) | √(Bx²+By²) | √(Ax²+Ay²)
				PSRLDQ xmm7, 12				; xmm7:  √(Ax²+Ay²)	| 0			 | 0		  | 0
				PSLLDQ xmm7, 12				; xmm7:  0			| 0			 | 0		  | √(Ax²+Ay²)
				PSLLDQ xmm8, 4				; xmm8:  0			| √(Dx²+Dy²) | √(Cx²+Cy²) | √(Bx²+By²)
				PSRLDQ xmm8, 12				; xmm8:  √(Bx²+By²) | 0			 | 0		  | 0
				PSLLDQ xmm8, 4				; xmm8:  0			| √(Bx²+By²) | 0		  | 0
				PSRLDQ xmm9, 4				; xmm9:  √(Cx²+Cy²) | √(Bx²+By²) | √(Ax²+Ay²) | 0
				PSLLDQ xmm9, 12				; xmm9:  0			| 0			 | 0		  | √(Cx²+Cy²)
				PSLLDQ xmm10, 12 			; xmm10: 0			| 0			 | 0		  | √(Dx²+Dy²)
				PSRLDQ xmm10, 8				; xmm10: 0			| √(Dx²+Dy²) | 0		  | 0
				POR xmm7, xmm8				; xmm7:  0			| √(Bx²+By²) | 0		  | √(Ax²+Ay²)
				POR xmm9, xmm10				; xmm9:  0			| √(Dx²+Dy²) | 0		  | √(Cx²+Cy²)
				PACKUSDW xmm9, xmm7			; xmm9:  0 | √(Dx²+Dy²) | 0 | √(Cx²+Cy²) | 0 | √(Bx²+By²) | 0 | √(Ax²+Ay²)
				; o sea que en xmm9 se tienen los resultados para 8 píxeles intercalados desde el principio
				
				PACKUSWB xmm5, xmm9			; xmm5: 0 | ##		   | 0			| √(Gx²+Gy²) | 0		  | √(Fx²+Fy²) | 0			| √(Ex²+Ey²) | 0		  | √(Dx²+Dy²) | 0			| √(Cx²+Cy²) | 0		  | √(Bx²+By²) | 0			| √(Ax²+Ay²)
				PSRLDQ xmm5, 2				; xmm5: 0 | √(Gx²+Gy²) | 0			| √(Fx²+Fy²) | 0		  | √(Ex²+Ey²) | 0			| √(Dx²+Dy²) | 0		  | √(Cx²+Cy²) | 0			| √(Bx²+By²) | 0		  | √(Ax²+Ay²) | 0			| 0
				PSLLDQ xmm5, 1				; xmm5: 0 | 0		   | √(Gx²+Gy²) | 0			 | √(Fx²+Fy²) | 0		   | √(Ex²+Ey²) | 0			 | √(Dx²+Dy²) | 0		   | √(Cx²+Cy²) | 0			 | √(Bx²+By²) | 0		   | √(Ax²+Ay²) | 0
				
				POR xmm15, xmm5				; junta lo de antes con los calculados para el intercalado (15 píxeles procesados)
				PSRLDQ xmm15, 1				; lo ubica al comienzo del registro
				
				MOVDQU [r13], xmm15
				
				
				ADD r14, 15						; avanza el iterador 15 bytes (cantidad procesada en este caso)
				ADD r13, 15						; avanza el iterador 15 bytes (cantidad procesada en este caso)
				SUB r11, 15						; resta 15 columnas (cantidad procesadas en este caso)
				JMP .cicloPorColumna

			.actualizarFinal:
				MOV r12, 16
				SUB r12, r11					; r12 tiene lo que hay que retroceder para procesar justo para que queden 16 (pues en este caso de procesa de a 15 pero el último se deja sin efecto)
				ADD r11, r12					; actualiza la cantidad de columnas
				SUB r14, r12					; actualiza el src
				SUB r13, r12					; actualiza el dst
				JMP .cicloPorColumna
	
			.cambiarDeFila:
				ADD rdi, r8						; suma al src su row_size para ubicarlo en la siguiente fila
				ADD rsi, r9						; suma al dst su row_size para ubicarlo en la siguiente fila
				DEC edx							; resta 1 fila
				JMP .cicloPorFila


	
		.cicloPorColumnaUltima:
			PXOR xmm15, xmm15
			CMP r11, 0						; compara para ver si no quedan más píxeles
			JE .salir
			CMP r11, 16						; compara para ver si queda un tamaño menor al de procesado (16 en este caso)
			JL .actualizarFinalUltima

			MOVDQU [r13], xmm15				; imprime todo negro

			ADD r14, 16						; avanza el iterador 16 bytes (cantidad procesada en este caso)
			ADD r13, 16						; avanza el iterador 16 bytes (cantidad procesada en este caso)
			SUB r11, 16						; resta 16 columnas (cantidad procesadas en este caso)
			JMP .cicloPorColumnaUltima
				
			.actualizarFinalUltima:
				MOV r12, 16
				SUB r12, r11					; r12 tiene lo que hay que retroceder para procesar justo para que queden 16 (pues en este caso de procesa de a 15 pero el último se deja sin efecto)
				ADD r11, r12					; actualiza la cantidad de columnas
				SUB r14, r12					; actualiza el src
				SUB r13, r12					; actualiza el dst
				JMP .cicloPorColumnaUltima

	.salir:
	POP r12
	POP r13
	POP r14
	POP r15
	POP rbp

	RET

	
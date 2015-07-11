global nonMaxSup_asm




section .data
mask50: DW 0x32, 0x32, 0x32, 0x32, 0x32, 0x32, 0x32, 0x32



section .text
nonMaxSup_asm:
	; rdi  --> puntero a grd
	; rsi  --> puntero a ang
	; rdx  --> puntero a dst
	; rcx  --> m (cantidad de filas)
	; r8   --> n (cantidad de columnas)
	; r9   --> grd_row_size
	; pila --> ang_row_size
	; pila --> dst_row_size
	; pila --> Threshold High
	; pila --> Threshold Low



	PUSH rbp		; A
	MOV rbp,rsp		; arma StackFrame		
	PUSH r15		; D					
	PUSH r14		; A
	PUSH r13		; D
	PUSH r12		; A
	PUSH rbx		; D
	SUB rsp, 8		; A
	

	MOV r10, [rsp+64]		; carga en r10 a ang_row_size
	MOV rbx, [rsp+72]		; carga en rbx a dst_row_size
	MOV rax, [rsp+80]		; carga en rax a Threshold High (es el byte más bajo)
	MOV bh, al 				; mueve Threshold High a bh (el segundo byte de rbx)
	MOV rax, [rsp+88]		; carga en rax a Threshold Low (es el byte más bajo)
	MOV bl, al 				; mueve Threshold Low a bl (el byte más bajo de rbx)
	




	;LIMPIO LAS PARTES ALTAS DE LOS REGISTROS  (porque son de 64 bits y acá uso sólo 32)

	;En rcx tengo la cantidad de filas
	MOV r12d, ecx;
	XOR rcx, rcx;
	MOV ecx, r12d;

	; En r8 la cantidad de columnas
	MOV r12d, r8d;
	XOR r8, r8;
	MOV r8d, r12d;

	; En r9 el grd_row size
	MOV r12d, r9d;
	XOR r9, r9;
	MOV r9d, r12d;
	
	; En r10 el ang_row_size
	MOV r12d, r10d
	XOR r10, r10
	MOV r10d, r12d
	
	; En r15 el dst_row_size
	MOV r12d, r15d
	XOR r15, r15
	MOV r15d, r12d

	;rcx --> filas
	;r8 --> columnas
	;r9  --> grd_row_size
	;r10  --> ang_row_size
	;r15  --> dst_row_size
	



	MOV r11, 2 					;Para iterar 2 filas			
	PXOR xmm0,xmm0 				;Para escribir 0 en el borde
	primerasFilas:
		CMP r11, 0 ;
		JE  seguirConMedio
		MOV r14, rdx 				;Guardo el puntero al destinoGrad en r15 (para usarlo de iterador).
		MOV r12, r8				;Guardo en r12, la cantidad de columnas para poder comparar contra 0 cuando termine de iterar toda la fila.
	


	cicloPrimeras3Filas:
		CMP r12,0 					;Armo un loop para la primer fila
		JE cambiarPrimerasFilas
		CMP r12,16 					;Para redimensionar
		JL redimensionPrimeras3filas
		MOVDQU [r14], xmm0 		    ;Escribo 16 bytes de  0 en la posición de memoria apuntada por el iterador
		ADD r14, 16 				;Aumento el iterador
		SUB r12, 16					;Disminuyo la cantidad de columnas que me faltan recorrer
		JMP cicloPrimeras3Filas


	cambiarPrimerasFilas: 
		LEA rdx, [rdx + r9]			; Muevo los punteros de las imágenes al primero de la segunda fila sumandole el row_size correspondiente a cada uno.
		LEA rsi, [rsi + r9]	
		LEA rdi, [rdi + r9]		
		DEC ecx					; Decremento una fila
		DEC r11					; Decremento el contador de estas tres filas 
		JMP primerasFilas
 	

 	redimensionPrimeras3filas:
 		MOV r13, 16		 		; Hago esto para retroceder (16-r12d) para atrás que es lo que necesito que retrocedan los iteradores para poder hacer la última escritura.
		SUB r13, r12 		
		SUB r14, r13
		MOV r12, 16   
		JMP cicloPrimeras3Filas












	seguirConMedio: 


	LEA rdx, [rdx + r9] 				; agrega una fila al destino para escribir en la fila central
	LEA rsi, [rsi + r9] 				; agrega una fila al ángulos así se ubica en la central




	XOR r12, r12						; limpia r12
	XOR rax, rax						; limpia rax
	MOV al, bh							; levanta el valor alto como byte y lo pone en r12
	OR r12, rax							; pone lo levantado en r12
	MOV r11, r12						; copia el byte a r11
	SHL r11, 8							; corre el byte a la izquierda
	OR r12, r11							; r12: 0 | 0 | 0 | 0 | 0 | 0 | TH | TH
	MOV r11, r12
	SHL r11, 16							; r11: 0 | 0 | 0 | 0 | TH | TH | 0 | 0
	OR r12, r11							; r12: 0 | 0 | 0 | 0 | TH | TH | TH | TH
	MOV r11, r12
	SHL r11, 32							; r11: TH | TH | TH | TH | 0 | 0 | 0 | 0
	OR r12, r11							; r12: TH | TH | TH | TH | TH | TH | TH | TH
	MOVQ xmm15, r12						; xmm15: 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | TH | TH | TH | TH | TH | TH | TH | TH
	;PSLLDQ xmm15, 8						; xmm15: TH | TH | TH | TH | TH | TH | TH | TH | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0
	;PXOR xmm13, xmm13 					; limpia xmm13
	;MOVQ xmm13, r12						; xmm13: 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | TH | TH | TH | TH | TH | TH | TH | TH
	;POR xmm15, xmm13 					; xmm15: TH | TH | TH | TH | TH | TH | TH | TH | TH | TH | TH | TH | TH | TH | TH | TH
	PXOR xmm0, xmm0 					; limpia para extender
	PUNPCKLBW xmm15, xmm0 				; xmm15: TH | TH | TH | TH | TH | TH | TH | TH
	
	XOR r12, r12						; limpia r12
	XOR rax, rax						; limpia rax
	MOV al, bl							; levanta el valor bajo como byte y lo pone en r12
	OR r12, rax							; pone lo levantado en r12	
	MOV r11, r12						; copia el byte a r11
	SHL r11, 8							; corre el byte a la izquierda
	OR r12, r11							; r12: 0 | 0 | 0 | 0 | 0 | 0 | TL | TL
	MOV r11, r12
	SHL r11, 16							; r11: 0 | 0 | 0 | 0 | TL | TL | 0 | 0
	OR r12, r11							; r12: 0 | 0 | 0 | 0 | TL | TL | TL | TL
	MOV r11, r12
	SHL r11, 32							; r11: TL | TL | TL | TL | 0 | 0 | 0 | 0
	OR r12, r11							; r12: TL | TL | TL | TL | TL | TL | TL | TL
	MOVQ xmm14, r12						; xmm15: 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | TL | TL | TL | TL | TL | TL | TL | TL
	PXOR xmm0, xmm0 					; limpia para extender
	PUNPCKLBW xmm14, xmm0 				; xmm14: TL | TL | TL | TL | TL | TL | TL | TL
	
	MOVDQU xmm13, [mask50]				; carga la máscara que tiene 8 50's

	INC rdx	



	
	.cicloPorFila:
			MOV r11, r8						; mueve la cantidad de columnas a r11
			MOV r15, rdi					; muevo a r15 el puntero a grd
			MOV r14, rsi					; muevo a r14 el puntero a ang
			MOV r13, rdx					; muevo a r13 el puntero a dst
			
			CMP ecx, 3						; para ver si terminó de ciclar todas las filas (deja 1 pues ese no se procesa)
			JE .salir

			.cicloPorColumna:
				CMP r11, 1					; compara para ver si ya miró todas las columnas (deja 1 pues ese no se procesa)
				JE .cambiarDeFila
				CMP r11, 15					; compara para ver si queda un tamaño menor al de procesado (15 en este caso)
				JL .actualizarFinal

				; Código
				;~ MOVDQU xmm1, [r14]
				;~ MOVDQU [r13], xmm1
				
				
				
				MOVDQU xmm0, [r14] 				; levanta los ángulos
				MOVDQU xmm1, xmm0
				MOVDQU xmm2, [r15]				; levanta la línea superior
				MOVDQU xmm3, xmm2
				ADD r15, r9						; pasa a la fila de abajo
				MOVDQU xmm4, [r15]				; levanta la línea central
				MOVDQU xmm5, xmm4
				ADD r15, r9						; pasa a la fila de abajo
				MOVDQU xmm6, [r15]				; levanta la línea inferior
				MOVDQU xmm7, xmm6
				SUB r15, r9						; vuelve una fila
				SUB r15, r9						; vuelve una fila
				
				PXOR xmm8, xmm8 				; limpia xmm8 para extender
				PUNPCKLBW xmm0, xmm8 			; extiende la parte baja en xmm0
				PUNPCKHBW xmm1, xmm8 			; extiende la parte alta en xmm1
				PUNPCKLBW xmm2, xmm8 			; extiende la parte baja en xmm2
				PUNPCKHBW xmm3, xmm8 			; extiende la parte alta en xmm3
				PUNPCKLBW xmm4, xmm8 			; extiende la parte baja en xmm4
				PUNPCKHBW xmm5, xmm8 			; extiende la parte alta en xmm5
				PUNPCKLBW xmm6, xmm8 			; extiende la parte baja en xmm6
				PUNPCKHBW xmm7, xmm8 			; extiende la parte alta en xmm7



				; RESUMEN
				; xmm0 tiene los ángulos bajos
				; xmm1 tiene los ángulos altos
				; xmm2 tiene la fila superior bajos
				; xmm3 tiene la fila superior altos
				; xmm4 tiene la fila central bajos
				; xmm5 tiene la fila central altos
				; xmm6 tiene la fila inferior bajos
				; xmm7 tiene la fila inferior altos
				; xmm13 tiene los 50's
				; xmm14 tiene los TL's
				; xmm15 tiene los TH's

				; xmm11 va a acumular los resultados para la parte alta
				; xmm12 va a acumular los resultados para la parte baja

				PXOR xmm11, xmm11				; limpia
				PXOR xmm12, xmm12 				; limpia

				; COMPARACIONES CON 50
				MOVDQU xmm8, xmm1 				; copia angulos alta
				MOVDQU xmm9, xmm13 				; carga la máscara de 50's
				PCMPEQW xmm8, xmm9 				; deja en xmm8 1's donde había 50
				MOVDQU xmm9, xmm5 				; copia la fila central alta
				PAND xmm8, xmm9 				; deja en xmm8 los altos que tienen ángulo 50

				MOVDQU xmm10, xmm5				; xmm10: 	CH7 CH6 CH5 CH4 CH3 CH2 CH1 CH0
				PSLLDQ xmm10, 2 				; xmm10: 	CH6 CH5 CH4 CH3 CH2 CH1 CH0 000
				MOVDQU xmm9, xmm4 				; xmm9: 	CL7 CL6 CL5 CL4 CL3 CL2 CL1 CL0
				PSRLDQ xmm9, 14 				; xmm9: 	000 000 000 000 000 000 000 CL7
				POR xmm10, xmm9 				; xmm10: 	CH6 CH5 CH4 CH3 CH2 CH1 CH0 CL7
				MOVDQU xmm9, xmm8 				; xmm9: 	CH7 CH6 CH5 CH4 CH3 CH2 CH1 CH0 (son los CH pero de ángulo 50)
				PCMPGTW xmm9, xmm10 			; deja en xmm9 1's donde es mayor
				PAND xmm8, xmm9 				; deja pasar a los mayores solamente
				MOVDQU xmm9, xmm5 				; xmm9: 	CH7 CH6 CH5 CH4 CH3 CH2 CH1 CH0
				PSRLDQ xmm9, 2 					; corre para el otro lado para tener la otra comparación
				MOVDQU xmm10, xmm8
				PCMPGTW xmm10, xmm9 			; compara y deja 1's donde es mayor
				PAND xmm8, xmm10 				; finalmente deja pasar en xmm8 a los que son mayores a ambos vecinos
				POR xmm12, xmm8 				; almacena esos de la parte alta

				MOVDQU xmm8, xmm0 				; copia angulos baja
				MOVDQU xmm9, xmm13 				; carga la máscara de 50's
				PCMPEQW xmm8, xmm9 				; deja en xmm8 1's donde había 50
				MOVDQU xmm9, xmm4 				; copia la fila central baja
				PAND xmm8, xmm9 				; deja en xmm8 los bajos que tienen ángulo 50

				MOVDQU xmm10, xmm4 				; xmm10: 	CL7 CL6 CL5 CL4 CL3 CL2 CL1 CL0
				PSRLDQ xmm10, 2 				; xmm10: 	CL6 CL5 CL4 CL3 CL2 CL1 CL0 000
				MOVDQU xmm9, xmm5 				; xmm9: 	CH7 CH6 CH5 CH4 CH3 CH2 CH1 CH0
				PSLLDQ xmm9, 14 				; xmm9: 	000 000 000 000 000 000 000 CH7
				POR xmm10, xmm9 				; xmm10: 	CL6 CL5 CL4 CL3 CL2 CL1 CL0 CH7
				MOVDQU xmm9, xmm8 				; xmm9: 	CL7 CL6 CL5 CL4 CL3 CL2 CL1 CL0 (son los CH pero de ángulo 50)
				PCMPGTW xmm9, xmm10 			; deja en xmm9 1's donde es mayor
				PAND xmm8, xmm9 				; deja pasar a los mayores solamente
				MOVDQU xmm9, xmm4 				; xmm9: 	CL7 CL6 CL5 CL4 CL3 CL2 CL1 CL0
				PSLLDQ xmm9, 2 					; corre para el otro lado para tener la otra comparación
				MOVDQU xmm10, xmm8
				PCMPGTW xmm10, xmm9 			; compara y deja 1's donde es mayor
				PAND xmm8, xmm10 				; finalmente deja pasar en xmm8 a los que son mayores a ambos vecinos
				POR xmm11, xmm8 				; almacena esos de la parte baja









				; Los comentarios acá no están del todo bien
				; COMPARACIONES CON 100
				MOVDQU xmm8, xmm1 				; copia angulos baja
				MOVDQU xmm9, xmm13 				; pone los 50's en xmm9 
				PADDW xmm9, xmm13 				; en xmm9 quedan 100's
				PCMPEQW xmm8, xmm9 				; deja en xmm8 1's donde había 100
				MOVDQU xmm9, xmm5 				; copia la fila central baja
				PAND xmm8, xmm9 				; deja en xmm8 los bajos que tienen angulo 100

				MOVDQU xmm10, xmm7				; xmm10: 	UL7 UL6 UL5 UL4 UL3 UL2 UL1 UL0
				PSLLDQ xmm10, 2 				; xmm10: 	000 UL7 UL6 UL5 UL4 UL3 UL2 UL1
				MOVDQU xmm9, xmm6 				; xmm9: 	UH7 UH6 UH5 UH4 UH3 UH2 UH1 UH0
				PSRLDQ xmm9, 14 				; xmm9: 	UH0 000 000 000 000 000 000 000
				POR xmm10, xmm9 				; xmm10: 	UH0 UL7 UL6 UL5 UL4 UL3 UL2 UL1
				MOVDQU xmm9, xmm8 				; xmm9: 	CL7 CL6 CL5 CL4 CL3 CL2 CL1 CL0 (son los CL pero de ángulo 100)
				PCMPGTW xmm9, xmm10 			; deja en xmm9 1's donde es mayor
				PAND xmm8, xmm9 				; deja pasar a los mayores solamente
				MOVDQU xmm9, xmm3 				; xmm9: 	DL7 DL6 DL5 DL4 DL3 DL2 DL1 DL0
				PSRLDQ xmm9, 2 					; corre para el otro lado para tener la otra comparación
				MOVDQU xmm10, xmm8
				PCMPGTW xmm10, xmm9 			; compara y deja 1's donde es mayor
				PAND xmm8, xmm10 				; finalmente deja pasar en xmm8 a los que son mayores a ambos vecinos
				POR xmm12, xmm8 				; almacena esos de la parte baja

				MOVDQU xmm8, xmm0 				; copia angulos alta
				MOVDQU xmm9, xmm13 				; pone los 50's en xmm9 
				PADDW xmm9, xmm13 				; en xmm9 quedan 100's
				PCMPEQW xmm8, xmm9 				; deja en xmm8 1's donde había 100
				MOVDQU xmm9, xmm4 				; copia la fila central alta
				PAND xmm8, xmm9 				; deja en xmm8 los altos que tienen angulo 100

				MOVDQU xmm10, xmm2 				; xmm10: 	UH7 UH6 UH5 UH4 UH3 UH2 UH1 UH0
				PSRLDQ xmm10, 2 				; xmm10: 	UH6 UH5 UH4 UH3 UH2 UH1 UH0 000
				MOVDQU xmm9, xmm3 				; xmm9: 	UL7 UL6 UL5 UL4 UL3 UL2 UL1 UL0
				PSLLDQ xmm9, 14 				; xmm9: 	000 000 000 000 000 000 000 UL7
				POR xmm10, xmm9 				; xmm10: 	UH6 UH5 UH4 UH3 UH2 UH1 UH0 UL7
				MOVDQU xmm9, xmm8 				; xmm9: 	CH7 CH6 CH5 CH4 CH3 CH2 CH1 CH0 (son los CH pero de ángulo 100)
				PCMPGTW xmm9, xmm10 			; deja en xmm9 1's donde es mayor
				PAND xmm8, xmm9 				; deja pasar a los mayores solamente
				MOVDQU xmm9, xmm6				; xmm9: 	DH7 DH6 DH5 DH4 DH3 DH2 DH1 DH0
				PSLLDQ xmm9, 2 					; corre para el otro lado para tener la otra comparación
				MOVDQU xmm10, xmm8
				PCMPGTW xmm10, xmm9 			; compara y deja 1's donde es mayor
				PAND xmm8, xmm10 				; finalmente deja pasar en xmm8 a los que son mayores a ambos vecinos
				POR xmm11, xmm8 				; almacena esos de la parte alta









				; Los comentarios acá no están del todo bien
				; COMPARACIONES CON 150
				MOVDQU xmm8, xmm1 				; copia angulos baja
				MOVDQU xmm9, xmm13 				; carga la máscara de 50's
				PADDW xmm9, xmm13 				; en xmm9 quedan 100's
				PADDW xmm9, xmm13 				; en xmm9 quedan 150's
				PCMPEQW xmm8, xmm9 				; deja en xmm8 1's donde había 150
				MOVDQU xmm9, xmm5 				; copia la fila central baja
				PAND xmm8, xmm9 				; deja en xmm8 los bajos que tienen angulo 150

				MOVDQU xmm9, xmm3 				; xmm9: 	UL7 UL6 UL5 UL4 UL3 UL2 UL1 UL0
				MOVDQU xmm10, xmm8				; copia los bajos de ángulo 150
				PCMPGTW xmm10, xmm9 			; deja en xmm9 1's donde es mayor
				PAND xmm8, xmm10 				; deja pasar a los mayores solamente
				MOVDQU xmm9, xmm7 				; xmm9: 	DL7 DL6 DL5 DL4 DL3 DL2 DL1 DL0
				MOVDQU xmm10, xmm8 				; copia los bajos que pasaron
				PCMPGTW xmm10, xmm9 			; compara y deja 1's donde es mayor
				PAND xmm8, xmm10 				; finalmente deja pasar en xmm8 a los que son mayores a ambos vecinos
				POR xmm12, xmm8 				; almacena esos de la parte baja

				MOVDQU xmm8, xmm0 				; copia angulos alta
				MOVDQU xmm9, xmm13 				; carga la máscara de 50's
				PADDW xmm9, xmm13 				; en xmm9 quedan 100's
				PADDW xmm9, xmm13 				; en xmm9 quedan 150's
				PCMPEQW xmm8, xmm9 				; deja en xmm8 1's donde había 150
				MOVDQU xmm9, xmm4 				; copia la fila central alta
				PAND xmm8, xmm9 				; deja en xmm8 los altos que tienen angulo 150

				MOVDQU xmm9, xmm2 				; xmm9: 	UH7 UH6 UH5 UH4 UH3 UH2 UH1 UH0
				MOVDQU xmm10, xmm8 				; copia los altos de ángulo 150
				PCMPGTW xmm10, xmm9 			; deja en xmm9 1's donde es mayor
				PAND xmm8, xmm10 				; deja pasar a los mayores solamente
				MOVDQU xmm9, xmm6 				; xmm9: 	DH7 DH6 DH5 DH4 DH3 DH2 DH1 DH0
				MOVDQU xmm10, xmm8 				; copia los altos que pasaron
				PCMPGTW xmm10, xmm9 			; compara y deja 1's donde es mayor
				PAND xmm8, xmm10 				; finalmente deja pasar en xmm8 a los que son mayores a ambos vecinos
				POR xmm11, xmm8 				; almacena esos de la parte alta









				; Los comentarios acá no están del todo bien
				; COMPARACIONES CON 200
				MOVDQU xmm8, xmm1 				; copia angulos baja
				MOVDQU xmm9, xmm13 				; pone los 50's en xmm9 
				PADDW xmm9, xmm13 				; en xmm9 quedan 100's
				PADDW xmm9, xmm13 				; en xmm9 quedan 150's
				PADDW xmm9, xmm13 				; en xmm9 quedan 200's
				PCMPEQW xmm8, xmm9 				; deja en xmm8 1's donde había 200
				MOVDQU xmm9, xmm5 				; copia la fila central baja
				PAND xmm8, xmm9 				; deja en xmm8 los bajos que tienen angulo 200

				MOVDQU xmm10, xmm3				; xmm10: 	DL7 DL6 DL5 DL4 DL3 DL2 DL1 DL0
				PSLLDQ xmm10, 2 				; xmm10: 	000 DL7 DL6 DL5 DL4 DL3 DL2 DL1
				MOVDQU xmm9, xmm2				; xmm9: 	DH7 DH6 DH5 DH4 DH3 DH2 DH1 DH0
				PSRLDQ xmm9, 14 				; xmm9: 	UH0 000 000 000 000 000 000 000
				POR xmm10, xmm9 				; xmm10: 	UH0 UL7 UL6 UL5 UL4 UL3 UL2 UL1
				MOVDQU xmm9, xmm8 				; xmm9: 	CL7 CL6 CL5 CL4 CL3 CL2 CL1 CL0 (son los CL pero de ángulo 200)
				PCMPGTW xmm9, xmm10 			; deja en xmm9 1's donde es mayor
				PAND xmm8, xmm9 				; deja pasar a los mayores solamente
				MOVDQU xmm9, xmm7 				; xmm9: 	UL7 UL6 UL5 UL4 UL3 UL2 UL1 UL0
				PSRLDQ xmm9, 2 					; corre para el otro lado para tener la otra comparación
				MOVDQU xmm10, xmm8
				PCMPGTW xmm10, xmm9 			; compara y deja 1's donde es mayor
				PAND xmm8, xmm10 				; finalmente deja pasar en xmm8 a los que son mayores a ambos vecinos
				POR xmm12, xmm8 				; almacena esos de la parte baja
				
				MOVDQU xmm8, xmm0 				; copia angulos alta
				MOVDQU xmm9, xmm13 				; pone los 50's en xmm9 
				PADDW xmm9, xmm13 				; en xmm9 quedan 100's
				PADDW xmm9, xmm13 				; en xmm9 quedan 150's
				PADDW xmm9, xmm13 				; en xmm9 quedan 200's
				PCMPEQW xmm8, xmm9 				; deja en xmm8 1's donde había 200
				MOVDQU xmm9, xmm4 				; copia la fila central alta
				PAND xmm8, xmm9 				; deja en xmm8 los altos que tienen angulo 200

				MOVDQU xmm10, xmm6 				; xmm10: 	DH7 DH6 DH5 DH4 DH3 DH2 DH1 DH0
				PSRLDQ xmm10, 2 				; xmm10: 	DH6 DH5 DH4 DH3 DH2 DH1 DH0 000
				MOVDQU xmm9, xmm7 				; xmm9: 	DL7 DL6 DL5 DL4 DL3 DL2 DL1 DL0
				PSLLDQ xmm9, 14 				; xmm9: 	000 000 000 000 000 000 000 UL7
				POR xmm10, xmm9 				; xmm10: 	DH6 DH5 DH4 DH3 DH2 DH1 DH0 DL7
				MOVDQU xmm9, xmm8 				; xmm9: 	CH7 CH6 CH5 CH4 CH3 CH2 CH1 CH0 (son los CH pero de ángulo 200)
				PCMPGTW xmm9, xmm10 			; deja en xmm9 1's donde es mayor
				PAND xmm8, xmm9 				; deja pasar a los mayores solamente
				MOVDQU xmm9, xmm2				; xmm9: 	UH7 UH6 UH5 UH4 UH3 UH2 UH1 UH0
				PSLLDQ xmm9, 2 					; corre para el otro lado para tener la otra comparación
				MOVDQU xmm10, xmm8
				PCMPGTW xmm10, xmm9 			; compara y deja 1's donde es mayor
				PAND xmm8, xmm10 				; finalmente deja pasar en xmm8 a los que son mayores a ambos vecinos
				POR xmm11, xmm8 				; almacena esos de la parte alta







				; Resta comparar contra THRESHOLD_HIGH y THRESHOLD_LOW	

				; En xmm11 se tienen los almacenados de la parte alta
				; En xmm12 se tienen los almacenados de la parte baja
				; xmm13 tiene los 50's
				; xmm14 tiene los TL's
				; xmm15 tiene los TH's


				; Genera 100 y 200
				MOVDQU xmm0, xmm13 				; pone 50's en xmm0
				PADDW xmm0, xmm0 				; deja 100's en xmm0
				MOVDQU xmm1, xmm0 				; pone 100's en xmm1
				PADDW xmm1, xmm1				; deja 200's en xmm1


				; Comparación con TH y TL para los altos
				MOVDQU xmm8, xmm11 				; copia los valores
				PCMPGTW xmm8, xmm15 			; si lo que hay es mayor al THRESHOLD_HIGH entonces pone unos ahí
				MOVDQU xmm7, xmm1 				; carga 200's en xmm7
				PAND xmm7, xmm8 				; deja 200's donde había 1's por la comparación

				; Invierte xmm8
				PCMPEQW xmm2, xmm2 				; compara consigo mismo con lo cual da todos 1's
				PXOR xmm8, xmm2 				; al hacer XOR donde había 1's ahora hay 0's y en el resto hay 1's

				MOVDQU xmm6, xmm11 				; copia los valores
				PAND xmm6, xmm8 				; deja en xmm6 a los que son menores que 200
				PCMPGTW xmm6, xmm14 			; si lo que hay es mayor al THRESHOLD_LOW entonces pone unos ahí
				MOVDQU xmm5, xmm0				; carga 100's en xmm5
				PAND xmm5, xmm6 				; deja 100's donde había 1's por la compatación

				; En xmm7 se tienen 200's para los superiores a HIGH y en xmm5 se tienen 100's para los que están entre TH y TL
				MOVDQU xmm10, xmm5 				; copia a xmm1 los de 100
				POR xmm10, xmm7 					; agrega los de 200




				; Comparación con TH y TL para los bajos
				MOVDQU xmm8, xmm12 				; copia los valores
				PCMPGTW xmm8, xmm15 			; si lo que hay es mayor al THRESHOLD_HIGH entonces pone unos ahí
				MOVDQU xmm7, xmm1				; carga 200's en xmm7
				PAND xmm7, xmm8 				; deja 200's donde había 1's por la comparación

				; Invierte xmm8
				PCMPEQW xmm2, xmm2 				; compara consigo mismo con lo cual da todos 1's
				PXOR xmm8, xmm2 				; al hacer XOR donde había 1's ahora hay 0's y en el resto hay 1's

				MOVDQU xmm6, xmm12 				; copia los valores
				PAND xmm6, xmm8 				; deja en xmm6 a los que son menores que 200
				PCMPGTW xmm6, xmm14 			; si lo que hay es mayor al THRESHOLD_LOW entonces pone unos ahí
				MOVDQU xmm5, xmm0 				; carga 100's en xmm5
				PAND xmm5, xmm6 				; deja 100's donde había 1's por la compatación

				; En xmm7 se tienen 200's para los superiores a HIGH y en xmm5 se tienen 100's para los que están entre TH y TL
				MOVDQU xmm11, xmm5 				; copia a xmm1 los de 100
				POR xmm11, xmm7 					; agrega los de 200


				PACKUSWB xmm10, xmm11 			; empaqueta

				PSRLDQ xmm10, 1 	 			;
				PSLLDQ xmm10, 2
				PSRLDQ xmm10, 2

				MOVDQU [r13], xmm10				; imprime







				
				
;				MOVDQU xmm0, [r14]				; levanta los ángulos
;				MOVDQU xmm1, [r15]				; levanta la línea superior
;				ADD r15, r9						; pasa a la fila de abajo
;				MOVDQU xmm2, [r15]				; levanta la línea central
;				ADD r15, r9						; pasa a la fila de abajo
;				MOVDQU xmm3, [r15]				; levanta la línea inferior
;				SUB r15, r9						; vuelve una fila
;				SUB r15, r9						; vuelve una fila
;				
;				; Máscara para ángulo 50
;				MOVDQU xmm4, xmm2				; pone una copia de la fila central en xmm4
;				MOVDQU xmm6, xmm10				; carga la máscara de 50's en xmm6
;				PCMPEQB xmm6, xmm0				; compara bytes y deja 1's donde hay 50's
;				PAND xmm4, xmm6					; deja únicamente aquellos bytes que valen 50 en la fila central
;				
;				MOVDQU xmm5, xmm4				; copia a xmm5 para comparar
;				MOVDQU xmm6, xmm4				; copia a xmm6 para comparar
;				PSLLDQ xmm6, 1					; mueve todo lo del registro a derecha 1 píxel
;				PCMPGTB xmm5, xmm6				; compara byte a byte, si el original es mayor al de su izquierda entonces deja 1's en xmm5
;				PAND xmm4, xmm5					; filtra y deja sólo a aquellos mayores que el de su izquierda
;				MOVDQU xmm5, xmm4				; copia a xmm5 para comparar
;				MOVDQU xmm6, xmm4				; copia a xmm6 para comparar
;				PSRLDQ xmm6, 1					; mueve todo lo del registro a izquierda 1 píxel
;				PCMPGTB xmm5, xmm6				; compara byte a byte, si el original es mayor al de su derecha entonces deja 1's en xmm5
;				PAND xmm4, xmm5					; filtra y deja sólo a aquellos mayores que el de su derecha
;				MOVDQU xmm9, xmm4				; se reserva el valor en xmm9
;				
;				
;				
;				; Máscara para ángulo 100
;				MOVDQU xmm4, xmm2				; pone una copia de la fila central en xmm4
;				MOVDQU xmm6, xmm11				; carga la máscara de 100's en xmm6
;				PCMPEQB xmm6, xmm0				; compara bytes y deja 1's donde hay 100's
;				PAND xmm4, xmm6					; deja únicamente aquellos bytes que valen 100 en la fila central
;				
;				MOVDQU xmm5, xmm4				; copia a xmm5 para comparar
;				MOVDQU xmm6, xmm1				; copia a xmm6 la superior
;				PSRLDQ xmm6, 1					; mueve todo lo del registro superior a izquierda 1 píxel
;				PCMPGTB xmm5, xmm6				; compara byte a byte, si el original es mayor al de su superior derecha entonces deja 1's en xmm5
;				PAND xmm4, xmm5					; filtra y deja sólo a aquellos mayores que el de su superior derecha
;				MOVDQU xmm5, xmm4				; copia a xmm5 para comparar
;				MOVDQU xmm6, xmm3				; copia a xmm6 la inferior
;				PSLLDQ xmm6, 1					; mueve todo lo del registro a derecha 1 píxel
;				PCMPGTB xmm5, xmm6				; compara byte a byte, si el original es mayor al de su inferior izquierda entonces deja 1's en xmm5
;				PAND xmm4, xmm5					; filtra y deja sólo a aquellos mayores que el de su inferior izquierda
;				POR xmm9, xmm4					; acumula los resultados parciales en xmm9
;				
;				
;				
;				; Máscara para ángulo 150
;				MOVDQU xmm4, xmm2				; pone una copia de la fila central en xmm4
;				MOVDQU xmm6, xmm12				; carga la máscara de 150's en xmm6
;				PCMPEQB xmm6, xmm0				; compara bytes y deja 1's donde hay 150's
;				PAND xmm4, xmm6					; deja únicamente aquellos bytes que valen 150 en la fila central
;				
;				MOVDQU xmm5, xmm4				; copia a xmm5 para comparar
;				MOVDQU xmm6, xmm1				; copia a xmm6 la superior
;				PCMPGTB xmm5, xmm6				; compara byte a byte, si el original es mayor al de su superior entonces deja 1's en xmm5
;				PAND xmm4, xmm5					; filtra y deja sólo a aquellos mayores que el de su superior
;				MOVDQU xmm5, xmm4				; copia a xmm5 para comparar
;				MOVDQU xmm6, xmm3				; copia a xmm6 la inferior
;				PCMPGTB xmm5, xmm6				; compara byte a byte, si el original es mayor al de su inferior entonces deja 1's en xmm5
;				PAND xmm4, xmm5					; filtra y deja sólo a aquellos mayores que el de su inferior
;				POR xmm9, xmm4					; acumula los resultados parciales en xmm9
;				
;				
;				
;				; Máscara para ángulo 200
;				MOVDQU xmm4, xmm2				; pone una copia de la fila central en xmm4
;				MOVDQU xmm6, xmm13				; carga la máscara de 200's en xmm6
;				PCMPEQB xmm6, xmm0				; compara bytes y deja 1's donde hay 200's
;				PAND xmm4, xmm6					; deja únicamente aquellos bytes que valen 200 en la fila central
;				
;				MOVDQU xmm5, xmm4				; copia a xmm5 para comparar
;				MOVDQU xmm6, xmm1				; copia a xmm6 la superior
;				PSLLDQ xmm6, 1					; mueve todo lo del registro superior a derecha 1 píxel
;				PCMPGTB xmm5, xmm6				; compara byte a byte, si el original es mayor al de su superior izquierda entonces deja 1's en xmm5
;				PAND xmm4, xmm5					; filtra y deja sólo a aquellos mayores que el de su superior izquierda
;				MOVDQU xmm5, xmm4				; copia a xmm5 para comparar
;				MOVDQU xmm6, xmm3				; copia a xmm6 la inferior
;				PSRLDQ xmm6, 1					; mueve todo lo del registro a izquierda 1 píxel
;				PCMPGTB xmm5, xmm6				; compara byte a byte, si el original es mayor al de su inferior derecha entonces deja 1's en xmm5
;				PAND xmm4, xmm5					; filtra y deja sólo a aquellos mayores que el de su inferior derecha
;				POR xmm9, xmm4					; acumula los resultados parciales en xmm9		
;				
;				
;				; En xmm9 se tiene todo lo que haya sobrevivido a las comparaciones
;				; Resta comparar contra THRESHOLD_HIGH y THRESHOLD_LOW		
;				
;				MOVDQU xmm8, xmm9				; pone una copia en xmm8
;				PCMPGTB xmm8, xmm15				; si lo que hay es mayor al THRESHOLD_HIGH entonces pone unos ahí
;				MOVDQU xmm7, xmm13				; carga 200's en xmm7
;				PAND xmm7, xmm8					; deja 200's donde había 1's por la comparación
;				
;				; Invierte xmm8
;				PXOR xmm2, xmm2					; limpia xmm2
;				PCMPEQB xmm2, xmm2				; compara consigo mismo con lo cual da todos 1's
;				PXOR xmm8, xmm2					; al hacer XOR donde había 1's ahora hay 0's y en el resto hay 1's
;				
;				MOVDQU xmm6, xmm9				; pone una copia en xmm6
;				PAND xmm6, xmm8					; deja en xmm6 a los que son menores que 200
;				PCMPGTB xmm6, xmm14				; si lo que hay es mayor al THRESHOLD_LOW entonces pone unos ahí
;				MOVDQU xmm5, xmm11				; carga 100's en xmm5
;				PAND xmm5, xmm6					; deja 100's donde había 1's por la comparación
;				
;				; En xmm7 se tienen 200's para los superiores a HIGH y en xmm5 se tienen 100's para los que están entre 100 y 200
;				MOVDQU xmm1, xmm5				; copia a xmm1 los de 100
;				POR xmm1, xmm7					; agrega los de 200
;				
;				MOVDQU [r13], xmm1				; imprime
				
				
				
				
				ADD r15, 14						; avanza el iterador 14 bytes (cantidad procesada en este caso)
				ADD r14, 14						; avanza el iterador 14 bytes (cantidad procesada en este caso)
				ADD r13, 14						; avanza el iterador 14 bytes (cantidad procesada en este caso)
				SUB r11, 14						; resta 14 columnas (cantidad procesadas en este caso)
				JMP .cicloPorColumna

			.actualizarFinal:
				MOV r12, 15
				SUB r12, r11					; r12 tiene lo que hay que retroceder para procesar justo para que queden 15 (pues en este caso de procesa de a 14 pero el último se deja sin efecto)
				ADD r11, r12					; actualiza la cantidad de columnas
				SUB r15, r12					; actualiza el grd
				SUB r14, r12					; actualiza el ang
				SUB r13, r12					; actualiza el dst
				JMP .cicloPorColumna
	
			.cambiarDeFila:
				ADD rdi, r9						; suma al grd su row_size para ubicarlo en la siguiente fila
				ADD rsi, r9						; suma al ang su row_size para ubicarlo en la siguiente fila
				ADD rdx, r9						; suma al dst su row_size para ubicarlo en la siguiente fila
				DEC ecx							; resta 1 fila
				JMP .cicloPorFila


	.salir:
	ADD rsp, 8
	POP rbx
	POP r12
	POP r13
	POP r14
	POP r15
	POP rbp

	RET

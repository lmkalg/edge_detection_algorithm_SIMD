; void sobel_asm (
; 	unsigned char *src,
; 	unsigned char *dst,
; 	int h,
; 	int w, 
; 	int src_row_size, 
; 	int dst_row_size
; );

section .data
ultimas2WordsNO:  DW 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0x0000, 0x0000   ; EL ORDEN DE LAS COMAS ES COMO ESTÁ PERO LOS NUMEROS EN SI VAN CON LITTLE ENDIAN
ultimas2WordsSI:  DW 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0xFFFF, 0xFFFF
ultimaWordSi:     DW 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0xFFFF 
anteUltimaWordSi: DW 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0xFFFF, 0x0000

section .text

global sobel_asm

sobel_asm:

	; rdi --> *src/ puntero a src 
	; rsi --> *dst/ dst
	; edx --> h/ cantidad de filas
	; ecx --> w/ columnas
	; r8d --> src_row size
	; r9d --> dst_row_size


	;Salvar registros, armar el stack frame y alinear pila.
	PUSH rbp;A
	MOV rbp,rsp;
	PUSH r15;D
	PUSH r14;A
	PUSH r12;D
	SUB rbp, 8; A
	
	
	
	;Limpio parte alta de los registros 
	XOR r12,r12
	
	MOV r12d, r8d   
	XOR r8,r8		
	MOV r8, r12		
	
	MOV r12d, r9d   
	XOR r9,r9		
	MOV r9, r12		
	
	MOV r12d, ecx   
	XOR rcx,rcx		
	MOV rcx, r12		
	
	MOVDQU xmm12, [anteUltimaWordSi] 				;guardamos  las máscaras
	MOVDQU xmm13, [ultimaWordSi]
	MOVDQU xmm14, [ultimas2WordsNO]  
	MOVDQU xmm15, [ultimas2WordsSI]
	
	



	;Poner 0's en la primer fila del dst

		MOV r15, rsi 			;Guardo el puntero al destino en r11 (para usarlo de iterador
								; de la primer fila)

		MOV r12, rcx			;Guardo en r12, la cantidad de columnas para poder
								;comparar contra 0 cuando termine de iterar toda la fila

								;Resumen:
								; r12 ----> Cantidad de colunas a procesar 
								; r11 ----> puntero a la dirección de memoria próxima a escribir
	PXOR xmm2,xmm2
	primerFila:
		CMP r12,0 				;Armo un loop para la primer fila
		JE seguirConMedio
		
		CMP r12, 16;
		JL redimensionarPrimFila


		MOVDQU [r15], xmm2		;Escribo un 0 en la posición de memoria apuntada por el iterador
		ADD r15,16				;Aumento el iterador
		SUB r12,16					;Disminuyo la cantidad de columnas que me faltan recorrer
		JMP primerFila

	redimensionarPrimFila: 
		MOV r11, 16;
		SUB r11, r12
		SUB r15 , r11
		MOV r12, 16;
		JMP primerFila




	seguirConMedio:

	DEC edx 					;Decremento la cantidad de filas puesto que la primera ya fué escrita

	LEA rdi, [rdi + r8]			; Muevo los punteros de las imágenes al primero de la segunda fila 
	LEA rsi, [rsi + r9]			; sumandole el row_size correspondiente a cada uno.


	;De la forma que se va a implementar podemos procesar de a 14 pixeles a la vez,porque lo de las puntas
	;no se pueden procesar ya que necesitan los píxeles de los costados.

		cicloPorFilas:

				CMP edx,1 			; Comparo a ver si la cantidad de filas que me restan por procesar es 1 (solo resta la ùltima).
				JE parteFinal

				MOV r14, rdi   		; Creo el iterador de la fila actual de la imagen src 
				MOV r15, rsi 		; Creo el iterador de la fila actual de la imagen dst
				MOV r12, rcx    	; Pongo en r12d la cantidad de columnas que voy a procesar

				MOV BYTE [r15],0    ; Escribo que en el borde izquierdo halla un 0.
				INC r15; 


				cicloPorColumnas:
							CMP r12, 16  ; Si es menor a la 16 hay que redimensionar
							JL redimensionar

									
							MOV r10, r14 
							SUB r10, r8 
							MOVDQU xmm0, [r10]   		;Levanto los 16 bytes de arriba (U15,U14,U13..U0)
							MOVDQU xmm1, [r14]  		;Levanto los 16 bytes del medio (M15,M14,M13..M0)
							MOVDQU xmm2, [r14 + r8] 	;Levanto los 16 bytes de abajo  (D15,D14,D13..D0)
							MOVDQU xmm3, xmm0			;
							MOVDQU xmm4, xmm1			;
							MOVDQU xmm5, xmm2			;		;

							PXOR xmm8,xmm8				; Lo limpio para poder extender con 0's

							PUNPCKLBW xmm0, xmm8		; xmm0 = [U15|U14|U13|U12|U11|U10|U9|U8]	
							PUNPCKHBW xmm3, xmm8		; xmm3 = [U7|U6|U5|U4|U3|U2|U1|U0]
							PUNPCKLBW xmm1, xmm8		; xmm1 = [M15|M14|M13|M12|M11|M10|M9|M8]
							PUNPCKHBW xmm4, xmm8		; xmm4 = [M7|M6|M5|M4|M3|M2|M1|M0]
							PUNPCKLBW xmm2, xmm8		; xmm2 = [D15|D14|D13|D12|D11|D10|D9|D8]
							PUNPCKHBW xmm5, xmm8		; xmm5 = [D7|D6|D5|D4|D3|D2|D1|D0]



;************************************************************************************************************************************************************************************************************************
;************************************************************************************************************************************************************************************************************************
;******************************************************************************************* Calcular GX ****************************************************************************************************************	
;************************************************************************************************************************************************************************************************************************
;************************************************************************************************************************************************************************************************************************



							; Matriz de convolución:

							;  -1   0   1    ---> U
							;  -2   0   2 	 ---> M
							;  -1   0   1    ---> D

							
							



							; En xmm0 están los píxeles de arriba     ---> [U15|U14|U13|U12|U11|U10|U9|U8|U7|U6|U5|U4|U3|U2|U1|U0] 
							; En xmm1 están los píxeles de del medio  ---> [M15|M14|M13|M12|M11|M10|M9|M8|M7|M6|M5|M4|M3|M2|M1|M0]
							; En xmm2 están los píxeles de abajo      ---> [D15|D14|D13|D12|D11|D10|D9|D8|D7|U6|D5|U4|U3|U2|D1|D0]

							; Si hacemos que : -(xmm0+2*xmm1+xmm2) + 2<<(xmm0+2*xmm1+xmm2) 
							; Entonces, se cumple que en la parte alta del registro queda :
							; [GX(M14)|GX(M13)|GX(M12)|GX(M11)|GX(M10)|GX(M9)|Basura|Basura]
							; donde GX(M{n}) = -(U{n+}1 + 2*M{n+}1 + D{n+1}) + U{n-1} + 2*M{n-1} + D{n-1}  (n es la posición dentro del registro del pixel a procesar)
							






							PADDW xmm1,xmm1 		;Multiplico por dos

							; Busco que xmm7 = (xmm0+xmm1+xmm2)

							MOVDQU xmm7, xmm0	; xmm7 = [U15|U14|U13|U12|U11|U10|U9|U8]
							PADDW xmm7,xmm1		; xmm7 = [U15 + 2*M15 | .. | U8 + 2*M8]
							PADDW xmm7,xmm2		; xmm7 = [U15 + 2*M15 + D15 | ..| U8 + 2*M8 + D8]

							MOVDQU xmm9, xmm7 	; Para calcular GX(8) y GX(7)

							PSUBW xmm8,xmm7		; xmm8 = -xmm7 =  -(xmm0+xmm1+xmm2)
											    ; xmm8 = [-(U15 + 2*M15 + D15) | ..| -(U8 + 2*M8 + D8)]

							PSRLDQ xmm7,4		; xmm7 = [U13 + 2*M13 + D13 | ..| Basura|Basura]
							PADDW xmm8,xmm7		; xmm8 = [-(U15 + 2*M15 + D15) + U13 + 2*M13 + D13 | ..| Basura|Basura]

							; xmm8 = [GX(M14)|GX(M13)|GX(M12)|GX(M11)|GX(M10)|GX(M9)|Basura|Basura]





							; Si hacemos que :  -(xmm3+2*xmm4+xmm5) + 2<<(xmm3+2*xmm4+xmm5 )
							; Entonces, se cumple que en la parte alta del registro queda :
							; [GX(M6)|GX(M5)|GX(M4)|GX(M3)|GX(M2)|GX(M1)|Basura|Basura]
							; donde GX(M{n}) = -(U{n+}1 + 2*M{n+}1 + D{n+1}) + U{n-1} + 2*M{n-1} + D{n-1}  (n es la posición dentro del registro del pixel a procesar)
							

							PADDW xmm4,xmm4 		;MULTIPLICO POR 2

							; quiero que xmm10 = (xmm3+xmm4+xmm5)

							MOVDQU xmm10, xmm3		; xmm10 = [U7|U6|U5|U4|U3|U2|U1|U0]
							PADDW xmm10,xmm4		; xmm10 = [U7 + 2*M7 |...|U0 + 2*M0]
							PADDW xmm10,xmm5		; xmm10 = [U7 + 2*M7 + D7|...|U0 + 2*M0 + D0]

							MOVDQU xmm7, xmm10 		; Para calcular GX(8) y GX(7)
	
							PXOR xmm11,xmm11		;
							PSUBW xmm11,xmm10		; xmm11 = -xmm10 =  -(xmm3+xmm4+xmm5)
											        ; xmm11 = [-(U7 + 2*M7 + D7)|...|-(U0 + 2*M0 + D0)]
	
							PSRLDQ xmm10,4			; xmm10 = [U5 + 2*M5 + D5|..|Basura|Basura]
							PADDW xmm11,xmm10		; xmm11 = [-(U7 + 2*M7 + D7) + U5 + 2*M5 + D5|..|Basura|Basura]

							; xmm11 = [GX(M6)|GX(M5)|GX(M4)|GX(M3)|GX(M2)|GX(M1)|Basura|Basura]




							; Ya sabiamos que M15, y M0 no los ibamos a poder procesar ya que se necesitan sus vecinos y no los tenemos. Por ende solo procesamos los  14 píxeles del medio. Como tuvimos que hacer unpack,
							; nos quedaron en el medio M7 y M8 que sí se pueden hacer. Para eso hay que hacer unos corrimientos, porque al separar un solo registro que tenía 2 extremos (M15 y M0) en dos, 
							; ahora se nos suman dos nuevos extremos.
							 

							;xmm9 = [U15 + 2*M15 + D15 | ..| U8 + 2*M8 + D8]
							;xmm7 = [U7 + 2*M7 + D7|...|U0 + 2*M0 + D0]

							; Necesitamos obtener en la parte baja de algun registro :
							; [Basura|Basura|...|GX(M8)|GX(M7)] osea:
							; [M|M|...|U7 + 2*M7 + D7 - (U9 + 2*M9 + D9)|U6 + 2*M6 + D6 - (U8 + 2*M8 + D8)]



							PSLLDQ xmm7, 12		;xmm7 = [Basura|...|U7 + 2*M7 + D7|U6 + 2*M6 + D6]
							PSUBW xmm7,xmm9  	;xmm7 = [Basura|Basura|..|F(M8)|F(M7)]



							;Resumen:
							; xmm8 = [GX(M14)|GX(M13)|GX(M12)|GX(M11)|GX(M10)|GX(M9)|Basura|Basura]
							; xmm11 = [GX(M6)|GX(M5)|GX(M4)|GX(M3)|GX(M2)|GX(M1)|Basura|Basura]
							; xmm7 = [Basura|Basura|..|GX(M8)|GX(M7)]

							;Ahora unimos todo:

							PAND xmm8,xmm14		; xmm8 = [GX(M14)|GX(M13)|GX(M12)|GX(M11)|GX(M10)|GX(M9)|0|0]
							PAND xmm7,xmm15 	; xmm7 =[0|0|..|GX(M8)|GX(M7)]
							PADDW xmm8,xmm7  	; xmm8 = [GX(M14)|GX(M13)|GX(M12)|GX(M11)|GX(M10)|GX(M9)|GX(M8)|GX(M7)]




;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

; Ya calculamos GX :
; xmm8 = [GX(M14)|GX(M13)|GX(M12)|GX(M11)|GX(M10)|GX(M9)|GX(M8)|GX(M7)]
; xmm11 = [GX(M6)|GX(M5)|GX(M4)|GX(M3)|GX(M2)|GX(M1)|Basura|Basura]

;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


;************************************************************************************************************************************************************************************************************************
;************************************************************************************************************************************************************************************************************************
;******************************************************************************************* Calcular GX ****************************************************************************************************************	
;************************************************************************************************************************************************************************************************************************
;************************************************************************************************************************************************************************************************************************
							

							; Matriz de convolución:
							; 1    2    1    ---> U
							; 0    0    0    ---> M
							; -1  -2   -1    ---> D





							MOVDQU xmm1, xmm3; 
							MOVDQU xmm4, xmm2;
							

			               ;Resumen:
			               ; xmm0 = [U15|U14|U13|U12|U11|U10|U9|U8]
			               ; xmm1 = [U7|U6|U5|U4|U3|U2|U1|U0]
			               ; xmm2 = [M15|M14|M13|M12|M11|M10|M9|M8] /n uso
			               ; xmm3 = [M7|M6|M5|M4|M3|M2|M1|M0 /nl uso]
			               ; xmm4 = [D15|D14|D13|D12|D11|D10|D9|D8]
			               ; xmm5 = [D7|D6|D5|D4|D3|D2|D1|D0]
			               ; xmm8 = [GX(M14)|GX(M13)|GX(M12)|GX(M11)|GX(M10)|GX(M9)|GX(M8)|GX(M7)]
			               ; xmm11 = [GX(M6)|GX(M5)|GX(M4)|GX(M3)|GX(M2)|GX(M1)|Basura|Basura]
			              


				           ; GY(Mn) = Un+1 + 2*Un + Un-1 - (Dn+1 + 2*Dn + Dn-1)
  	                       ; xmm2 y xmm3 no me interesan porque no trabajo con M. Ya que está en la matriz de convolución aparece toda en 0 esa fila



		 ;Cálculo de la parte LOW de los registros sometidos al pack.

				              ;Acomodamos los píxeles de arriba (U)
								MOVDQU xmm2, xmm0 				; xmm2 = [U15|U14|U13|U12|U11|U10|U9|U8]
								MOVDQU xmm6, xmm0 				; para calcular GY(8) y GY(7)
								PADDW xmm2,xmm2 				; xmm2 =[2*U15|2*U14|2*U13|2*U12|2*U11|2*U10|2*U9|2*U8]
								PSRLDQ xmm2, 2 					; xmm2 = [2*U14|2*U13|2*U12|2*U11|2*U10|2*U9|2*U8|0]
				        
								MOVDQU xmm3, xmm0 				; xmm3 = [U15|U14|U13|U12|U11|U10|U9|U8]
								PSRLDQ xmm3, 4 					; xmm3 = [U13|U12|U11|U10|U9|U8|0|0]
							
								PADDW xmm0, xmm2 				; xmm0 = [U15 + 2*U14 | ..| U10 + 2*U9 | U9 + 2*U8 | 0]
								MOVDQU xmm10, xmm0 				; para calcular GY(8) y GY(7)
								PADDW xmm0, xmm3 				; xmm0 = [U15 + 2*U14 + U13 | .. | U10 + 2*U9 + U8| Basura  | Basura]
				        
				             



								;Acomodamos los píxeles de abajo (D)
								MOVDQU xmm2, xmm4 				; xmm2 = [D15|D14|D13|D12|D11|D10|D9|D8]
								MOVDQU xmm7, xmm2 				; para calcular GY(8) y GY(7)
								PADDW xmm2,xmm2 				; xmm2 =[2*D15|2*D14|2*D13|2*D12|2*D11|2*D10|2*D9|2*D8]
								PSRLDQ xmm2, 2 					; xmm2 = [2*D14|2*D13|2*D12|2*D11|2*D10|2*D9|2*D8|0]
							
								MOVDQU xmm3, xmm4 				; xmm3 = [D15|D14|D13|D12|D11|D10|D9|D8]
								PSRLDQ xmm3, 4 					; xmm3 = [D13|D12|D11|D10|D9|D8|0|0]
							
								PADDW xmm4, xmm2 				; xmm4 = [D15 + 2*D14 | ..| D10 + 2*D9 | D9 + 2*D8 | D8]
								PSUBW xmm10,xmm4 				; xmm10 = [U15 + 2*U14 - (D15 + 2*D14) | ..| U9 + 2*U8 - (D9 + 2*D8) | D8]
								PADDW xmm4, xmm3 				; xmm4 = [D15 + 2*D14 + D13 | .. | D10 + 2*D9 + 2*D8| Basura  | D8]
							



								; Unimos la parte low completa:
								PSUBW xmm0,xmm4 					; xmm0 = [U15 + 2*U14 + U13 - (D15 + 2*D14 + D13) | .. | U10 + 2*U9 + 2*U8 - (D10 + 2*D9 + 2*D8)| 0  | 0]
								


								; xmm0 = [GY(M14)|GY(M13)|GY(M12)|GY(M11)|GY(M10)|GY(M9)|Basura|Basura]
								




 
			;Cálculo de la parte LOW de los registros sometidos al pack.
								
								;Acomodamos los píxeles de arriba (U)
									MOVDQU xmm2, xmm1 			; xmm2 = [U7|U6|U5|U4|U3|U2|U1|U0]
									MOVDQU xmm9, xmm2 			; para calcular GY(8) y GY(7)
									PADDW xmm2,xmm2 			; xmm2 = [2*U7|2*U6|2*U5|2*U4|2*U3|2*U2|2*U1|2*U0]
									PSRLDQ xmm2, 2 				; xmm2 = [2*U6|2*U5|2*U4|2*U3|2*U2|2*U1|2*U0|0]
								
									MOVDQU xmm3, xmm1 			; xmm3 = [U7|U6|U5|U4|U3|U2|U1|U0]
									PSRLDQ xmm3, 4 				;  xmm3 = [U5|U4|U3|U2|U1|U0|0|0]
								
									PADDW xmm1, xmm2 			; xmm1 = [Un7+2*U6|..|U2+2*U1|Basura|Basura]
									PADDW xmm1, xmm3 			; xmm1 = [U7+ 2*U6 + U5|..|U2 + 2*U1 + U0|Basura|Basura]
								
								
								
								;Acomodamos los píxeles de abajo (D)
									MOVDQU xmm2, xmm5 			; xmm2 = [D7|D6|D5|D4|D3|D2|D1|D0]
									MOVDQU xmm4, xmm2 			; para calcular GY(8) y GY(7)
									PADDW xmm2,xmm2 			; xmm2 = [2*D7|2*D6|2*D5|2*D4|2*D3|2*D2|2*D1|2*D0]
									PSRLDQ xmm2, 2 				; xmm2 = [2*D6|2*D5|2*D4|2*D3|2*D2|2*D1|2*D0|0]
								
									MOVDQU xmm3, xmm5 			; xmm3 = [D7|D6|D5|D4|D3|D2|D1|D0]
									PSRLDQ xmm3, 4 				; xmm3 = [D5|D4|D3|D2|D1|D0|Basura|Basura]
								
									PADDW xmm5, xmm2 			; xmm5 = [D7 + 2*D6 |..|D2 + 2*D1|Basura|Basura]
									PADDW xmm5, xmm3 			; xmm5 = [D7 + 2*D6 + D5 |..|D2 + 2*D1 + D0|Basura|Basura]
									
									;Unimos la parte high completa:
									PSUBW xmm1,xmm5 			; xmm1 = [D7 + 2*D6 + D5 - (U7+ 2*U6 + U5) |..|D2 + 2*D1 + D0 - (U2 + 2*U1 + U0)|Basura|Basura]
													

									; xmm1 = [GY(M6)|GY(M5)|GY(M4)|GY(M3)|GY(M2)|GY(M1)||Basura|Basura]
								
								;----------------------------------------------------------------------------------------------------------------								
								;//				;RESUMEN 										
								;//				;xmm0 = [GY(M14)|GY(M13)|GY(M12)|GY(M11)|GY(M10)|GY(M9)|Basura|Basura]
								;//				;xmm1 = [GY(M6)|GY(M5)|GY(M4)|GY(M3)|GY(M2)|GY(M1)|Basura|Basura]
								;//				;
								;//				;xmm4 = [D7|D6|D5|D4|D3|D2|D1|D0]
								;//				;xmm6 = [U15|U14|U13|U12|U11|U10|U9|U8]
								;//				;xmm7 = [D15|D14|D13|D12|D11|D10|D9|D8]
								;//				;xmm9 = [U7|U6|U5|U4|U3|U2|U1|U0]
								;//				;xmm10 = [U15 + 2*U14 - (D15 + 2*D14) | ..| U9 + 2*U8 - (D9 + 2*D8) | D8]
								;----------------------------------------------------------------------------------------------------------------






								;Faltan obtener GY(8) y GY(7) igual que como pasó en GX(8) Y GX(7)
								;GY(8) = U9 + 2*U8 + U7 - (D9 + 2*D8 + D7)
								;GY(7) = U8 + 2*U7 + U6 - (D8 + 2*D7 + D6)
							
							
				;Cálculo para obtener GY(8)  
								PSLLDQ xmm9, 12 			; xmm9 = [0|..|0|U7|U6]
								PSLLDQ xmm4, 12 			; xmm4 = [0|..|0|D7|D6]
								PADDW xmm10, xmm9			; xmm10 = [Basura| ..|U9 + 2*U8 + U7 - (D9 + 2*D8)| D8+D6]
								PSUBW xmm10, xmm4			; xmm10 = [Basura| ..|U9 + 2*U8 + U7 - (D9 + 2*D8 + D7)| Basura]
											

						;xmm10 = [Basura|..|GY(8)|Basura]
							
							
							
				;Cálculo para obtener GY(8) 
								;Acomodamos los píxeles de arriba (U)
								MOVDQU xmm5,xmm9			; xmm5 = [0|..|0|U7|U6]
								PADDW xmm9,xmm9				; xmm9 = [Basura|..|2*U7|2*U6]
								PSLLDQ xmm9,2 				; xmm9 = [Basura|..|2*U7]
								PADDW xmm9,xmm5 			; xmm9 = [Basura|..|2*U7 + U6 ]
								PADDW xmm9,xmm6 			; xmm9 = [Basura|..|2*U7 + U6 + U8]
							
								;Acomodamos los píxeles de abajo (D)
								MOVDQU xmm5, xmm4 			; xmm5 = [0|..|0|D7|D6]
								PADDW xmm4,xmm4 			; xmm4 = [Basura|..|2*D7|2*D6]
								PSLLDQ xmm4,2 				; xmm4 = [Basura|..|2*D7]
								PADDW xmm4,xmm5 			; xmm4 = [Basura|..|2*D7 + D6 ]
								PADDW xmm4,xmm7 			; xmm4 = [Basura|..|2*D7 + D6 + D8]
							
								PSUBW xmm9,xmm4 			; xmm9 = [Basura|..|2*U7 + U6 + U8 - (2*D7 + D6 + D8)]
							
						;xmm9 = [Basura|..|GY(7)]
												
												
												
								;----------------------------------------------------------------------------------------------------------------	
								;//						;Resumen: 
								;//						; xmm0 = [GY(M14)|GY(M13)|GY(M12)|GY(M11)|GY(M10)|GY(M9)|Basura|Basura]
								;//						; xmm1 = [GY(M6)|GY(M5)|GY(M4)|GY(M3)|GY(M2)|GY(M1)|Basura|Basura]
								;//						; xmm10 = [Basura|..|GY(8)|Basura]
								;//						; xmm9 = [Basura|..|GY(7)]
								;----------------------------------------------------------------------------------------------------------------	
									
								


				;Unimos los GY 	
								
								PAND xmm10, xmm12 ; Deja pasar sólo la anteúltima word
								PAND xmm9, xmm13 ;  Deja pasar sólo la última word
								PAND xmm0, xmm14 ; Deja pasar todo menos las últimas 2 words
								
								PADDW xmm0, xmm10; xmm0 = [GY(M14)|GY(M13)|GY(M12)|GY(M11)|GY(M10)|GY(M9)|GY(8)|Basura]
								PADDW xmm0, xmm9;  xmm0 = [GY(M14)|GY(M13)|GY(M12)|GY(M11)|GY(M10)|GY(M9)|GY(8)|GY(7)]
									
									
									
									
								
				
				
				
				
					
					
					

;************************************************************************************************************************************************************************************************************************
;************************************************************************************************************************************************************************************************************************
;******************************************************************************************* Parte Final ****************************************************************************************************************	
;************************************************************************************************************************************************************************************************************************
;************************************************************************************************************************************************************************************************************************
							
				;----------------------------------------------------------------------------------------------------------------	
				;// 					;Resumen  
				;// 					; xmm0 = [GY(M14)|GY(M13)|GY(M12)|GY(M11)|GY(M10)|GY(M9)|GY(8)|GY(7)]
				;// 					; xmm1 = [GY(M6)|GY(M5)|GY(M4)|GY(M3)|GY(M2)|GY(M1)|Basura|Basura]
				;// 					; xmm8 = [GX(M14)|GX(M13)|GX(M12)|GX(M11)|GX(M10)|GX(M9)|GX(M8)|GX(M7)]
				;// 					; xmm11 = [GX(M6)|GX(M5)|GX(M4)|GX(M3)|GX(M2)|GX(M1)|Basura|Basura]
				;----------------------------------------------------------------------------------------------------------------
					
					
				
			;Debemos hacer: √(GY(Mi)² + GX(Mi)²), para  cada i = 1 .. 14 (14 píxeles centrales)
					
					;Tomamos módulo 
					PABSW xmm1,xmm1
					PABSW xmm0,xmm0
					PABSW xmm8,xmm8
					PABSW xmm11,xmm11

					MOVDQU xmm2, xmm0
					MOVDQU xmm3,xmm1
					MOVDQU xmm7,xmm8
					MOVDQU xmm10,xmm11
					

					PXOR xmm5,xmm5
					
					;Extendemos a double words
					PUNPCKHWD xmm0, xmm5 			; xmm0 = [GY(M10)|GY(M9)|GY(8)|GY(7)]
					PUNPCKHWD xmm1, xmm5 			; xmm1 = [GY(M2)|GY(M1)|Basura|Basura]
					PUNPCKHWD xmm8, xmm5 			; xmm8 = [GX(M10)|GX(M9)|GX(M8)|GX(M7)]
					PUNPCKHWD xmm11, xmm5 			; xmm11 =  [GX(M2)|GX(M1)|Basura|Basura]
					
					PUNPCKLWD xmm2, xmm5 			; xmm2 = [GY(M14)|GY(M13)|GY(M12)|GY(M11)]
					PUNPCKLWD xmm3, xmm5 			; xmm3 = [GY(M6)|GY(M5)|GY(M4)|GY(M3)]
					PUNPCKLWD xmm7, xmm5 			; xmm7 = [GX(M14)|GX(M13)|GX(M12)|GX(M11)]
					PUNPCKLWD xmm10, xmm5 			; xmm10 = [GX(M6)|GX(M5)|GX(M4)|GX(M3)]	


					;Convertimos a punto flotante de precisión simple				
					CVTDQ2PS xmm0,xmm0 				; xmm0 = [GY(M10)|GY(M9)|GY(8)|GY(7)]
					CVTDQ2PS xmm1,xmm1 				; xmm1 = [GY(M2)|GY(M1)|Basura|Basura]
					CVTDQ2PS xmm2,xmm2 				; xmm2 = [GY(M14)|GY(M13)|GY(M12)|GY(M11)]
					CVTDQ2PS xmm3,xmm3 				; xmm3 = [GY(M6)|GY(M5)|GY(M4)|GY(M3)]
					CVTDQ2PS xmm7,xmm7 				; xmm7 = [GX(M14)|GX(M13)|GX(M12)|GX(M11)]
					CVTDQ2PS xmm8,xmm8 				; xmm8 = [GX(M10)|GX(M9)|GX(M8)|GX(M7)]
					CVTDQ2PS xmm10,xmm10 			; xmm10 = [GX(M6)|GX(M5)|GX(M4)|GX(M3)]
					CVTDQ2PS xmm11,xmm11 			; xmm11 =  [GX(M2)|GX(M1)|Basura|Basura]
					
					;Elevamos cada término al cuadrdado     (GY(Mi)² / GX(Mi)²)           
					MULPS xmm0,xmm0 				; xmm0 = [GY(M10)²|GY(M9)²|GY(M8)²|GY(M7)²]
					MULPS xmm1,xmm1 				; xmm1 = [GY(M2)²|GY(M1)²|Basura|Basura]
					MULPS xmm2,xmm2 				; xmm2 = [GY(M14)²|GY(M13)²|GY(M12)²|GY(M11)²]
					MULPS xmm3,xmm3 				; xmm3 = [GY(M6)²|GY(M5)²|GY(M4)²|GY(M3)²]
					MULPS xmm7,xmm7 				; xmm7 = [GX(M14)²|GX(M13)²|GX(M12)²|GX(M11)²]
					MULPS xmm8,xmm8 				; xmm8 = [GX(M10)²|GX(M9)²|GX(M8)²|GX(M7)²]
					MULPS xmm10,xmm10 				; xmm10 = [GX(M6)²|GX(M5)²|GX(M4)²|GX(M3)²]
					MULPS xmm11,xmm11 				; xmm11 =  [GX(M2)²|GX(M1)²|Basura|Basura]
					
					;Hacemos la suma de GX + GY con respecto al i (GY(Mi)² + GX(Mi)²)
					ADDPS xmm2, xmm7 				; xmm2 = [GY(M14)² + GX(M14)²|...|GY(M11)² + GX(M11)²]
					ADDPS xmm0, xmm8 				; xmm0 = [GY(M10)² + GX(M10)²|...|GY(M7)² + GX(M7)² ]  
					ADDPS xmm3, xmm10 				; xmm3 = [GY(M6)² + GX(M6)²|...|GY(M3)² + GX(M3)²]
					ADDPS xmm1, xmm11 				; xmm1 = [GY(M2)² + GX(M2)²|GY(M1)² + GX(M1)²|Basura|Basura]
					
					;Aplico Raíz
					SQRTPS xmm2,xmm2 				; xmm2 = [√(GY(M14)² + GX(M14)²)|...|√(GY(M11)² + GX(M11)²)]
					SQRTPS xmm0,xmm0 				; xmm0 = [√(GY(M10)² + GX(M10)²)|...|√(GY(M7)² + GX(M7)²) ] 
					SQRTPS xmm3,xmm3 				; xmm3 = [√(GY(M6)² + GX(M6)²)|...|√(GY(M3)² + GX(M3)²)]
					SQRTPS xmm1,xmm1 				; xmm1 = [√(GY(M2)² + GX(M2)²)|√(GY(M1)² + GX(M1)²)|Basura|Basura]
					
					;Volvemos a enteros (Double words)					
					 CVTPS2DQ xmm2,xmm2				; xmm2 = [√(GY(M14)² + GX(M14)²)|...|√(GY(M11)² + GX(M11)²)]
					 CVTPS2DQ xmm0,xmm0				; xmm0 = [√(GY(M10)² + GX(M10)²)|...|√(GY(M7)² + GX(M7)²) ] 
					 CVTPS2DQ xmm3,xmm3				; xmm3 = [√(GY(M6)² + GX(M6)²)|...|√(GY(M3)² + GX(M3)²)]
				     CVTPS2DQ xmm1,xmm1				; xmm1 = [√(GY(M2)² + GX(M2)²)|√(GY(M1)² + GX(M1)²)|Basura|Basura]
					 
					
					
					;Volvemos a words					
					PACKUSDW  xmm2,xmm0 			; xmm2 = [SOBEL(M14)|...|SOBEL(M11)|SOBEL(M10)|...|SOBEL(M7) ]
					PACKUSDW  xmm3, xmm1 			; xmm3 = [SOBEL(M6)|...|SOBEL(M3)|SOBEL(M2)|SOBEL(M1)|Basura|Basura]

			
					;Volvemos a bytes							
					PACKUSWB xmm2,xmm3 				; xmm2 = [SOBEL(M14)| .. |SOBEL(M1)|Basura|Basura]





		;Escritura en memoria
				CMP r12,16    			; Me fijo si es la última escritura de la fila o no.
				JE ultimaEscritura



				MOVDQU [r15], xmm2 		; Si no es la última escritura, entonces escribo los 16 bytes.
				ADD r14, 14				; Aumento 14 ya que es la cantidad de píxeles que procesamos a la vez.
				ADD r15, 14				
				SUB r12,14      		; Resto las 14 columnas ya procesadas. 
				JMP cicloPorColumnas
				
				
				ultimaEscritura:
					MOVQ [r15], xmm2		; Escribe los primeros 8 bytes en memoria.
					PSRLDQ xmm2, 8			
					MOVD [r15+8], xmm2 		; Escribe los siguientes 4 bytes en memoria.
					PSRLDQ xmm2, 4			
					MOVD eax, xmm2			; Pone en eax (4bytes) los últimos 4 bytes de xmm2 .
					MOV WORD [r15+12], ax	; Escribe los siguientes 2 bytes en memoria.
					SHR eax, 8				
					MOV BYTE [r15+14], 0	; Escribe en memoria el último byte.
					JMP cambiarDeFila


				redimensionar: 
						MOV r11, 16		 	; Hago esto para retroceder (16-r12d) para atrás que es lo que necesito que retrocedan los iteradores para poder hacer la última escritura.
						SUB r11, r12 		
						SUB r14, r11    	
						SUB r15, r11   
						MOV r12, 16    
						JMP cicloPorColumnas


				cambiarDeFila:
						LEA rdi, [rdi + r8]			; Muevo los punteros de las imágenes al primero de la segunda fila sumandole el row_size correspondiente a cada uno.
						LEA rsi, [rsi + r9]			
						DEC edx						; Decremento una fila
						JMP cicloPorFilas





	;Opero con la última fila
	parteFinal:
	MOV r15, rsi 				;Guardo el puntero al destino en r11 (para usarlo de iterador de la última fila).					
	MOV r12, rcx				;Guardo en r12, la cantidad de columnas para poder comparar contra 0 cuando termine de iterar toda la fila.
	XOR r11,r11
	PXOR xmm2,xmm2

	
	ultimaFila:
		
		CMP r12,0
		JE salir

		CMP r12,16 				;Armo un loop para la última fila.
		JL redimensionUltFila
		

		MOVDQU [r15], xmm2 		;Escribo un 0 en la posición de memoria apuntada por el iterador.
		ADD r15,16
		SUB r12,16					;Disminuyo la cantidad de columnas que me faltan recorrer.
		JMP ultimaFila

	redimensionUltFila:
		MOV r11,16;
		SUB r11, r12;
		SUB r15, r11;
		MOV r12, 16
		JMP ultimaFila



	salir:
	ADD rbp,8;
	POP r12
	POP r14
	POP r15
	POP rbp

	RET















	


%define off_primero -8 
%define off_segundo -12


section .data
dos25mil: DD  0x36EE8,0x36EE8,0x36EE8,0x36EE8  ; 0x36EE8  = 225000
pisobre2: DD  0X3D5B,0X3D5B,0X3D5B,0X3D5B  ; 0X3D5B  = 15707
diezmil: DD 0x2710,0x2710,0x2710,0x2710 ; 0x2710 = 10000
cincuenta: DD 0x32, 0x32, 0x32, 0x32 ; 0x32 = 50

section .text

global anguloSobel_asm

anguloSobel_asm:

; void ang_sobel_asm (
; 	unsigned char *src,
; 	unsigned char *dstGrad,
; 	unsigned char *dstAng,
; 	int h,
; 	int w, 
; 	int src_row_size, 
; 	int dst_row_size
; );

	; rdi --> *src/ puntero a src 
	; rsi --> *dstGrad/ dst
	; rdx --> *dstAng/dst
	; rcx --> h/ cantidad de filas
	; r8 --> w/ columnas
	; r9 --> src_row size
	; pila(rsp) --> dst_row_size


	;Busco el parámetro de la pila
	

	;Salvar registros, armar el stack frame y alinear pila.
	PUSH rbp;A
	MOV rbp,rsp;
	SUB rsp,16;A
	PUSH r15;D
	PUSH r14;A
	PUSH r13;D
	PUSH r12;A

	MOV rax, [rsp+64]

	MOV r13, rax;
	MOV rax, rdx;  En rax tengo el puntero al dstAng
	MOV rdx, rcx;  En rdx tengo la cantidad de filas
	MOV rcx, r8 ;  En rcx tengo la cantidad de columnas
	MOV r8, r9  ;  En r8 tengo el src row size
	MOV r9, r13 ;  En r9 tengo el dst row size
	
	; En rdi tengo el puntero al src
	; En rsi tengo el puntero al dstGrad
	


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



	;configuramos  las máscaras	

	 MOVDQU xmm15, [pisobre2]		;  xmm15 = [15707|15707|15707|15707]

	 MOVDQU xmm12, [dos25mil]   ;  xmm12 = [225000|225000|225000|225000]
	 MOVDQU xmm11, [diezmil] 	;  xmm11 = [10000|10000|10000|10000]
	 CVTDQ2PS xmm15, xmm15		; 
	 CVTDQ2PS xmm12, xmm12		;
	 CVTDQ2PS xmm11, xmm11	    ; 
	 DIVPS xmm15, xmm11 		; xmm15 = [1.5707|1.5707|1.5707|1.5707]
	 DIVPS xmm12, xmm11			; xmm12 = [22.5|22.5|22.5|22.5]

     MOVDQU xmm14, [cincuenta]
     CVTDQ2PS xmm14, xmm14;			
	


    ;Poner 0's en la primeras 3 filas del dst
		MOV r11, 3 					;Para iterar 3 filas			
		PXOR xmm0,xmm0 				;Para escribir 0 en el borde
		primerasFilas:
			CMP r11, 0 ;
			JE  seguirConMedio
			MOV r15, rsi 				;Guardo el puntero al destinoGrad en r15 (para usarlo de iterador).
			MOV r13, rax 				;Guardo el puntero al destinoANG en r13 (para usarlo de iterador).
			MOV r12, rcx				;Guardo en r12, la cantidad de columnas para poder comparar contra 0 cuando termine de iterar toda la fila.
		


		cicloPrimeras3Filas:
			CMP r12,0 					;Armo un loop para la primer fila
			JE cambiarPrimerasFilas
			CMP r12,16 					;Para redimensionar
			JL redimensionPrimeras3filas
			MOVDQU [r15], xmm0 		    ;Escribo 16 bytes de  0 en la posición de memoria apuntada por el iterador
			MOVDQU [r13], xmm0 		    ;Escribo 16 bytes de  0 en la posición de memoria apuntada por el iterador
			ADD r15, 16 				;Aumento el iterador
			ADD r13, 16 				;Aumento el iterador
			SUB r12, 16					;Disminuyo la cantidad de columnas que me faltan recorrer
			JMP cicloPrimeras3Filas


		cambiarPrimerasFilas: 
			LEA rdi, [rdi + r8]			; Muevo los punteros de las imágenes al primero de la segunda fila sumandole el row_size correspondiente a cada uno.
			LEA rsi, [rsi + r9]	
			LEA rax, [rax + r9]		
			DEC edx						; Decremento una fila
			DEC r11					; Decremento el contador de estas tres filas 
			JMP primerasFilas
	 	

	 	redimensionPrimeras3filas:
	 		MOV r14, 16		 		; Hago esto para retroceder (16-r12d) para atrás que es lo que necesito que retrocedan los iteradores para poder hacer la última escritura.
			SUB r14, r12 		
			SUB r15, r14   
			SUB r13, r14    	 	
			MOV r12, 16   
			JMP cicloPrimeras3Filas



	seguirConMedio:
	;De la forma que se va a implementar podemos procesar de a 14 pixeles a la vez,porque lo de las puntas
	;no se pueden procesar ya que necesitan los píxeles de los costados.
	
	
		cicloPorFilas:

			CMP edx,3 			; Comparo a ver si la cantidad de filas que me restan por procesar es 3 (2 de smoothign + 1  que es la ultima solo resta la ùltima).
			JE parteFinal

			MOV r14, rdi   		; Creo el iterador de la fila actual de la imagen src 
			MOV r15, rsi 		; Creo el iterador de la fila actual de la imagen dstGradiente
			MOV r13, rax		; Creo el iterador de la fila actual de la imagen dstAngulos
			MOV r12, rcx    	; Pongo en r12d la cantidad de columnas que voy a procesar

			
			MOV WORD [r15],0    ; Pinto de negro los 3 bordes
			ADD r15,2;
			MOV BYTE [r15],0    
			INC r15; 

			MOV WORD [r13],0    ; Pinto de negro los 3 bordes
			ADD r13,2;
			MOV BYTE [r13],0    
			INC r13; 

			ADD r14,2 			;Salteas los dos primeros bordes de smoothing


			cicloPorColumnas:
						CMP r12, 18  ; Si es menor a la 16 hay que redimensionar
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

						PSLLDQ xmm8, 4       ; xmm8 = [Basura|Basura|GX(M14)|GX(M13)|GX(M12)|GX(M11)|GX(M10)|GX(M9)]
						PSRLDQ xmm8, 4      	; xmm8 = [GX(M14)|GX(M13)|GX(M12)|GX(M11)|GX(M10)|GX(M9)|0|0]

						PSRLDQ xmm7, 12 	; xmm7 =[GX(M8)|GX(M7)|0..|0]
						PSLLDQ xmm7, 12     ; xmm7 = [0|...|GX(M8)|GX(M7)]



						PADDW xmm8,xmm7  	; xmm8 = [GX(M14)|GX(M13)|GX(M12)|GX(M11)|GX(M10)|GX(M9)|GX(M8)|GX(M7)]




;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

; Ya calculamos GX :
; xmm8 = [GX(M14)|GX(M13)|GX(M12)|GX(M11)|GX(M10)|GX(M9)|GX(M8)|GX(M7)]
; xmm11 = [GX(M6)|GX(M5)|GX(M4)|GX(M3)|GX(M2)|GX(M1)|Basura|Basura]

;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


;************************************************************************************************************************************************************************************************************************
;************************************************************************************************************************************************************************************************************************
;******************************************************************************************* Calcular GY ****************************************************************************************************************	
;************************************************************************************************************************************************************************************************************************
;************************************************************************************************************************************************************************************************************************
							

							; Matriz de convolución:
							; 1    2    1    ---> U
							; 0    0    0    ---> M
							; -1  -2   -1    ---> D





						MOVDQU xmm1, xmm3
						MOVDQU xmm4, xmm2

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
								
								PSRLDQ xmm10, 12 ; xmm10 =  [GY(8)|0|..|0|Basura]
								PSLLDQ xmm10, 14 ; xmm10 =  [0|..|0|GY(8)]
								PSRLDQ xmm10, 2  ; xmm10 = [0|..|0|GY(8)|0]


								PSRLDQ xmm9, 14 ; xmm9 = [GY(7)|0|..|0] 
								PSLLDQ xmm9, 14 ; xmm9 = [0|...|0|GY(7)]


								PSLLDQ xmm0, 4 ; xmm0 = [0|0|GY(M14)|GY(M13)|GY(M12)|GY(M11)|GY(M10)|GY(M9)]
								PSRLDQ xmm0, 4 ; xmm0 = [GY(M14)|GY(M13)|GY(M12)|GY(M11)|GY(M10)|GY(M9)|0|0]

								PADDW xmm0, xmm10; xmm0 = [GY(M14)|GY(M13)|GY(M12)|GY(M11)|GY(M10)|GY(M9)|GY(8)|Basura]
								PADDW xmm0, xmm9;  xmm0 = [GY(M14)|GY(M13)|GY(M12)|GY(M11)|GY(M10)|GY(M9)|GY(8)|GY(7)]
									
									
									
			
					

;************************************************************************************************************************************************************************************************************************
;*************************************************************************************************************************************************************************************************************************
;******************************************************************************************* Parte Sobel ****************************************************************************************************************	
;************************************************************************************************************************************************************************************************************************
;************************************************************************************************************************************************************************************************************************
							

				;----------------------------------------------------------------------------------------------------------------	
				; 					Resumen  
				;					xmm0 = [GY(M14)|GY(M13)|GY(M12)|GY(M11)|GY(M10)|GY(M9)|GY(8)|GY(7)]
 				;					xmm1 = [GY(M6)|GY(M5)|GY(M4)|GY(M3)|GY(M2)|GY(M1)|Basura|Basura]
 				;					xmm2 = LIBRE
 				;					xmm3 = LIBRE
 				;					xmm4 = LIBRE
 				;					xmm5 = LIBRE
 				;					xmm6 = LIBRE
 				;					xmm7 = LIBRE
 				;					xmm8 = [GX(M14)|GX(M13)|GX(M12)|GX(M11)|GX(M10)|GX(M9)|GX(M8)|GX(M7)]
 				;					xmm9 = LIBRE
 				;					xmm10 = LIBRE
 				;					xmm11 = [GX(M6)|GX(M5)|GX(M4)|GX(M3)|GX(M2)|GX(M1)|Basura|Basura]
 				;					xmm12 = [22.5|22.5|22.5|22.5]
 				;					xmm13 = LIBRE
 				;					xmm14 = [50|50|50|50]
 				;					xmm15 = [pi/2|pi/2|pi/2|pi/2]
				;----------------------------------------------------------------------------------------------------------------
				;Guardamos los valores de gx y gy para utilizarlos en el Cálculo del ángulo
				MOVDQU xmm13,xmm0;
				MOVDQU xmm4 , xmm1;
				MOVDQU xmm6 , xmm8;
				MOVDQU xmm9 , xmm11;
				




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
					CMP r12,18    			; Me fijo si es la última escritura de la fila o no.
					JE ultimaEscrituraGradiente



					MOVDQU [r15], xmm2 		; Si no es la última escritura, entonces escribo los 16 bytes.
					JMP angulos
				
				
				ultimaEscrituraGradiente:
					MOVQ [r15], xmm2		; Escribe los primeros 8 bytes en memoria.
					PSRLDQ xmm2, 8			
					MOVD [r15+8], xmm2 		; Escribe los siguientes 4 bytes en memoria.
					MOV WORD [r15+12], 0	; Escribe los siguientes 2 bytes en memoria.
					MOV BYTE [r15+14], 0	; Escribe en memoria 0 para completar los 3 bores de ceros. 
					MOV WORD [r15+15], 0	; Escribe en memoria 0 para completar los 3 bores de ceros. 

			






;************************************************************************************************************************************************************************************************************************
;************************************************************************************************************************************************************************************************************************
;************************************************************************************************************************************************************************************************************************
;************************************************************************************************************************************************************************************************************************
;************************************************************************************************************************************************************************************************************************
;*************************************************************************************************************************************************************************************************************************
;******************************************************************************************* Parte Angulos ****************************************************************************************************************	
;************************************************************************************************************************************************************************************************************************
;************************************************************************************************************************************************************************************************************************
;************************************************************************************************************************************************************************************************************************
;************************************************************************************************************************************************************************************************************************
;************************************************************************************************************************************************************************************************************************
;************************************************************************************************************************************************************************************************************************

		
			;Recupero el back up realizado.
				angulos:
					
					MOVDQU xmm0, xmm13;
					MOVDQU xmm1, xmm4;
					MOVDQU xmm8, xmm6;
					MOVDQU xmm11, xmm9;


				;----------------------------------------------------------------------------------------------------------------	
				;// 					;Resumen  
				;// 					; xmm0 = [GY(M14)|GY(M13)|GY(M12)|GY(M11)|GY(M10)|GY(M9)|GY(8)|GY(7)]
				;// 					; xmm1 = [GY(M6)|GY(M5)|GY(M4)|GY(M3)|GY(M2)|GY(M1)|Basura|Basura]
				;// 					; xmm8 = [GX(M14)|GX(M13)|GX(M12)|GX(M11)|GX(M10)|GX(M9)|GX(M8)|GX(M7)]
				;// 					; xmm11 = [GX(M6)|GX(M5)|GX(M4)|GX(M3)|GX(M2)|GX(M1)|Basura|Basura]
				;----------------------------------------------------------------------------------------------------------------
				
					; Comenzamos a operar 
					MOVDQU xmm2, xmm0
					MOVDQU xmm3,xmm1
					MOVDQU xmm7,xmm8
					MOVDQU xmm10,xmm11
					
					;Hacemos un sign extention(Extendemos a double words)
					PXOR xmm5,xmm5
					PCMPGTW xmm5,xmm0;
					PUNPCKHWD xmm0, xmm5 			; xmm0 = [GY(M10)|GY(M9)|GY(8)|GY(7)]
					PUNPCKLWD xmm2,xmm5 			; xmm2 = [GY(M14)|GY(M13)|GY(M12)|GY(M11)]

					PXOR xmm5,xmm5
					PCMPGTW xmm5,xmm1;
					PUNPCKHWD xmm1, xmm5 			; xmm1 = [GY(M10)|GY(M9)|GY(8)|GY(7)]
					PUNPCKLWD xmm3, xmm5 			; xmm3 = [GY(M6)|GY(M5)|GY(M4)|GY(M3)]


					PXOR xmm5,xmm5
					PCMPGTW xmm5,xmm8;
					PUNPCKHWD xmm8, xmm5 			; xmm8 = [GX(M10)|GX(M9)|GX(M8)|GX(M7)]
					PUNPCKLWD xmm7, xmm5 			; xmm7 = [GX(M14)|GX(M13)|GX(M12)|GX(M11)]


					PXOR xmm5,xmm5
					PCMPGTW xmm5,xmm11;
					PUNPCKHWD xmm11, xmm5 			; xmm11 = [GY(M2)|GY(M1)|Basura|Basura]
					PUNPCKLWD xmm10, xmm5 			; xmm10 = [GX(M6)|GX(M5)|GX(M4)|GX(M3)]			


				;Convertimos a punto flotante de precisión simple				
					CVTDQ2PS xmm0,xmm0 				; xmm0 = [GY(M10)|GY(M9)|GY(8)|GY(7)]
					CVTDQ2PS xmm1,xmm1 				; xmm1 = [GY(M2)|GY(M1)|Basura|Basura]
					CVTDQ2PS xmm2,xmm2 				; xmm2 = [GY(M14)|GY(M13)|GY(M12)|GY(M11)]
					CVTDQ2PS xmm3,xmm3 				; xmm3 = [GY(M6)|GY(M5)|GY(M4)|GY(M3)]
					CVTDQ2PS xmm7,xmm7 				; xmm7 = [GX(M14)|GX(M13)|GX(M12)|GX(M11)]
					CVTDQ2PS xmm8,xmm8 				; xmm8 = [GX(M10)|GX(M9)|GX(M8)|GX(M7)]
					CVTDQ2PS xmm10,xmm10 			; xmm10 = [GX(M6)|GX(M5)|GX(M4)|GX(M3)]
					CVTDQ2PS xmm11,xmm11 			; xmm11 = [GX(M2)|GX(M1)|Basura|Basura]
					
				



;************************************************************************************************************************************************************************************************************************
;************************************************************************************************************************************************************************************************************************
;******************************************************************************************* Cálculo Ángulos ****************************************************************************************************************	
;************************************************************************************************************************************************************************************************************************
;************************************************************************************************************************************************************************************************************************
				
				;----------------------------------------------------------------------------------------------------------------	
				; 				Resumen  
				;				 xmm0 = [GY(M10)|GY(M9)|GY(8)|GY(7)]
				;				 xmm1 = [GY(M2)|GY(M1)|Basura|Basura]
				;				 xmm2 = [GY(M14)|GY(M13)|GY(M12)|GY(M11)]
				;				 xmm3 = [GY(M6)|GY(M5)|GY(M4)|GY(M3)]
				;			 	 xmm4 = LIBRE
				;			 	 xmm5 = LIBRE
				;			 	 xmm6 = LIBRE
				;				 xmm7 = [GX(M14)|GX(M13)|GX(M12)|GX(M11)]
				;				 xmm8 = [GX(M10)|GX(M9)|GX(M8)|GX(M7)]
				;				 xmm9 = LIBRE
				;				 xmm10 = [GX(M6)|GX(M5)|GX(M4)|GX(M3)]
				;				 xmm11 = [GX(M2)|GX(M1)|Basura|Basura]
				;				 xmm12 = [22.5|22.5|22.5|22.5]
				;				 xmm13 = LIBRE
				;				 xmm14 = [50|50|50|50]
				;				 xmm15 = [pi/2|pi/2|pi/2|pi/2]
				;
				;----------------------------------------------------------------------------------------------------------------
				

				; ---------------------------------------- Pìxeles 14-11 ----------------------------------------
				angsPixel14a11:

					MOVDQU xmm5, xmm7; xmm5 = [GX(M4)|GX(M13)|GX(M12)|GX(M11)]	   
					MOVDQU xmm4, xmm2; xmm4 = [GY(M14)|GY(M13)|GY(M12)|GY(M11)]


					angPixel14:
						PSRLDQ xmm4, 12;  xmm4 = [0|0|0|GY(M14)]
						PSRLDQ xmm5, 12;  xmm5 = [0|0|0|GX(M14)]
						MOVD r11d,xmm4 ; r11d = GY(M14)
						MOVD ebx,xmm5 ; ebx = GX(M14)
						
						CMP ebx, 0 ; Comparo contra 0 (GX == 0)
						JE gx14Es0

						JMP gx14arctg

						gx14Es0:
							CMP r11d,0 ;(GY == 0)
							JE angulo14Es0
							MOVDQU xmm13,xmm15 ; xmm13 = [pi/2|pi/2|pi/2|pi/2] = 90 en radianes
							JMP angPixel13

						angulo14Es0:
							MOV ebx,0 ; ANGULO = 0
							MOVD xmm13,ebx
							JMP angPixel13

						gx14arctg:
							MOVD [rbp + off_primero] ,xmm4 		; GY(M14)
							MOVD [rbp + off_segundo], xmm5		; GX(M14)
							FINIT 
							FLD dword [rbp + off_primero]		; Pusheo --> ST[1] --> GY(M14)
							FLD dword [rbp + off_segundo]	    ; Pusheo --> ST[0] --> GX(M14)
							FPATAN 								; Cálculo de arctng(ST[1] / ST[0])
							FST dword [rbp + off_primero]       ; Popeo ---> [rbp + off_primero] = ST[0] = arctang(gy/gx)
							MOVD xmm13, [rbp + off_primero]     ; xmm13 = [Basura|Basura|Basura|ang(M14)]
							


					angPixel13: 

						;-------------ACOMODAMOSS -------------
						; xmm13 = [Basura|Basura|Basura|ang(M14)]
						PSLLDQ xmm13, 12;
						PSRLDQ xmm13, 12;
						; xmm13 = [0|0|0|ang(M14)]
						MOVDQU xmm9, xmm13		; xmm9 =  [Basura|Basura|Basura|ang(M14)]
						PSLLDQ xmm9, 4     		; xmm9 = [Basura|Basura|ang(M14)|0] 
						;-------------ACOMODAMOSS -------------

						MOVDQU xmm5, xmm7			; xmm5 = [GX(M14)|GX(M13)|GX(M12)|GX(M11)]
						MOVDQU xmm4, xmm2 			; xmm4 = [GY(M14)|GY(M13)|GY(M12)|GY(M11)]
						PSRLDQ xmm4, 8				; xmm4 = [0|0|GY(M14)|GY(M13)]
						PSRLDQ xmm5, 8				; xmm5  =[0|0|GX(M14)|GX(M13)]
						MOVD r11d,xmm4 ; r11d = GY(M13)
						MOVD ebx,xmm5 ; ebx = GX(M13)


						CMP ebx, 0 ; COmparo contra 0 (gx == 0)
						JE gx13Es0

						JMP gx13arctg

						gx13Es0:
							CMP r11d,0
							JE angulo13Es0
							MOVDQU xmm13,xmm15 ; xmm13 = [pi/2|pi/2|pi/2|pi/2] = 90 en radianes
							JMP angPixel12

						angulo13Es0:
							MOV ebx,0 ; ANGULO = 0
							MOVD xmm13,ebx
							JMP angPixel12

						gx13arctg:
							MOVD [rbp + off_primero] ,xmm4 		; GY(M13)
							MOVD [rbp + off_segundo], xmm5		; GX(M13)
							FINIT 
							FLD dword [rbp + off_primero]		; Pusheo --> ST[1] --> GY(M13)
							FLD dword [rbp + off_segundo]	    ; Pusheo --> ST[0] --> GX(M13)
							FPATAN 								; Cálculo de arctng(ST[1] / ST[0])
							FST dword [rbp + off_primero]       ; Popeo ---> [rbp + off_primero] = ST[0] = arctang(gy/gx)
							MOVD xmm13, [rbp + off_primero]     ; xmm13 = [Basura|Basura|Basura|ang(M13)]




					angPixel12:
						;-------------ACOMODAMOSS -------------
						; xmm13 = [Basura|Basura|Basura|ang(M13)]
						PSLLDQ xmm13, 12;
						PSRLDQ xmm13, 12;
						; xmm13 = [0|0|0|ang(M13)
						; xmm9 = [Basura|Basura|ang(M14)|0] 
						ADDPS xmm9,xmm13 ; 		; xmm9 = [Basura|Basura|ang(M14)|ang(M13)] 
						PSLLDQ xmm9, 4     		; xmm9 = [Basura|ang(M14)|ang(M13)|0]
						;-------------ACOMODAMOSS -------------

						MOVDQU xmm5, xmm7			; xmm5 = [GX(M14)|GX(M13)|GX(M12)|GX(M11)]
						MOVDQU xmm4, xmm2 			; xmm4 = [GY(M14)|GY(M13)|GY(M12)|GY(M11)]
						PSRLDQ xmm4, 4				; xmm4 = [0|GY(M14)|GY(M13)|GY(M12)]
						PSRLDQ xmm5, 4				; xmm5  =[0|GX(M14)|GX(M13)|GX(M12)]
						MOVD r11d,xmm4 ; r11d = GY(M12)
						MOVD ebx,xmm5 ; ebx = GX(M12)

						CMP ebx, 0 ; COmparo contra 0 (gx == 0)
						JE gx12Es0

						JMP gx12arctg

						gx12Es0:
							CMP r11d,0
							JE angulo12Es0
							MOVDQU xmm13,xmm15 ; xmm13 = [pi/2|pi/2|pi/2|pi/2] = 90 en radianes
							JMP angPixel11

						angulo12Es0:
							MOV ebx,0 ; ANGULO = 0
							MOVD xmm13,ebx
							JMP angPixel11

						gx12arctg:
							MOVD [rbp + off_primero] ,xmm4 		; GY(M12)
							MOVD [rbp + off_segundo], xmm5		; GX(M12)
							FINIT 
							FLD dword [rbp + off_primero]		; Pusheo --> ST[1] --> GY(M12)
							FLD dword [rbp + off_segundo]	    ; Pusheo --> ST[0] --> GX(M12)
							FPATAN 								; Cálculo de arctng(ST[1] / ST[0])
							FST dword [rbp + off_primero]       ; Popeo ---> [rbp + off_primero] = ST[0] = arctang(gy/gx)
							MOVD xmm13, [rbp + off_primero]     ; xmm13 = [Basura|Basura|Basura|ang(M12)]




					angPixel11:
						;-------------ACOMODAMOSS -------------
						; xmm13 = [Basura|Basura|Basura|ang(M12)]
						PSLLDQ xmm13, 12;
						PSRLDQ xmm13, 12;
						; xmm13 = [0|0|0|ang(M12)
						; xmm9 = [Basura|ang(M14)|ang(M13)|0]
						ADDPS xmm9,xmm13 			; xmm9 = [Basura|ang(M14)|ang(M13)|ang(M12)]
						PSLLDQ xmm9, 4     			; xmm9 = [ang(M14)|ang(M13)|ang(M12)|0]
						;-------------ACOMODAMOSS -------------


						MOVDQU xmm5, xmm7			; xmm5 = [GX(M14)|GX(M13)|GX(M12)|GX(M11)]
						MOVDQU xmm4, xmm2 			; xmm4 = [GY(M14)|GY(M13)|GY(M12)|GY(M11)]
						MOVD r11d,xmm4 ; r11d = GY(M11)
						MOVD ebx,xmm5 ; ebx = GX(M11)


						CMP ebx, 0 ; COmparo contra 0 (gx == 0)
						JE gx11Es0

						JMP gx11arctg

						gx11Es0:
							CMP r11d,0
							JE angulo11Es0
							MOVDQU xmm13,xmm15 ; xmm13 = [pi/2|pi/2|pi/2|pi/2] = 90 en radianes
							JMP angs10a7

						angulo11Es0:
							MOV ebx,0 ; ANGULO = 0
							MOVD xmm13,ebx
							JMP angs10a7

						gx11arctg:
							MOVD [rbp + off_primero] ,xmm4 		; GY(M11)
							MOVD [rbp + off_segundo], xmm5		; GX(M11)
							FINIT 
							FLD dword [rbp + off_primero]		; Pusheo --> ST[1] --> GY(M11)
							FLD dword [rbp + off_segundo]	    ; Pusheo --> ST[0] --> GX(M11)
							FPATAN 								; Cálculo de arctng(ST[1] / ST[0])
							FST dword [rbp + off_primero]       ; Popeo ---> [rbp + off_primero] = ST[0] = arctang(gy/gx)
							MOVD xmm13, [rbp + off_primero]     ; xmm13 = [Basura|Basura|Basura|ang(M11)]



				angs10a7:
					;-------------ACOMODAMOSS -------------
					; xmm13 = [Basura|Basura|Basura|ang(M11)]
					PSLLDQ xmm13, 12;
					PSRLDQ xmm13, 12;
					; xmm13 = [0|0|0|ang(M11)
					; xmm9 = [ang(M14)|ang(M13)|ang(M12)|0]
					ADDPS xmm9,xmm13 			; xmm9 = [ang(M14)|ang(M13)|ang(M12)|ang(M11)]
					MOVDQU xmm2,xmm9 			; Guardo los resultados obtenidos 
					;-------------ACOMODAMOSS -------------


					angPixel10:

						MOVDQU xmm5, xmm8; xmm5 = [GX(M10)|GX(M9)|GX(M8)|GX(M7)]
						MOVDQU xmm4, xmm0; xmm4 = [GY(M10)|GY(M9)|GY(M8)|GY(M7)]
						PSRLDQ xmm4, 12;  xmm4 = [0|0|0|GY(M10)]
						PSRLDQ xmm5, 12;  xmm5 = [0|0|0|GX(M10)]
						MOVD r11d,xmm4 ; r11d = GY(M10)
						MOVD ebx,xmm5 ; ebx = GX(M10)

						CMP ebx, 0 ; COmparo contra 0 (gx == 0)
						JE gx10Es0

						JMP gx10arctg


						gx10Es0:
							CMP r11d,0
							JE angulo10Es0
							MOVDQU xmm13,xmm15 ; xmm13 = [pi/2|pi/2|pi/2|pi/2] = 90 en radianes
							JMP angPixel9

						angulo10Es0:
							MOV ebx,0 ; ANGULO = 0
							MOVD xmm13,ebx
							JMP angPixel9

						gx10arctg:
							MOVD [rbp + off_primero] ,xmm4 		; GY(M10)
							MOVD [rbp + off_segundo], xmm5		; GX(M10)
							FINIT 
							FLD dword [rbp + off_primero]		; Pusheo --> ST[1] --> GY(M10)
							FLD dword [rbp + off_segundo]	    ; Pusheo --> ST[0] --> GX(M10)
							FPATAN 								; Cálculo de arctng(ST[1] / ST[0])
							FST dword [rbp + off_primero]       ; Popeo ---> [rbp + off_primero] = ST[0] = arctang(gy/gx)
							MOVD xmm13, [rbp + off_primero]     ; xmm13 = [Basura|Basura|Basura|ang(M10)]


					angPixel9:
						;-------------ACOMODAMOSS -------------
						; xmm13 = [Basura|Basura|Basura|arct(M10)]
						PSLLDQ xmm13, 12;
						PSRLDQ xmm13, 12;
						; xmm13 = [0|0|0|arct(M10)
						MOVDQU xmm9, xmm13		; xmm9 =  [Basura|Basura|Basura|arct(M10)]
						PSLLDQ xmm9, 4     		; xmm9 = [Basura|Basura|arct(M10)|0] 
						;-------------ACOMODAMOSS -------------


						MOVDQU xmm5, xmm8			; xmm5 = [GX(M10)|GX(M9)|GX(M8)|GX(M7)]
						MOVDQU xmm4, xmm0 			; xmm4 = [GY(M10)|GY(M9)|GY(M8)|GY(M7)]
						PSRLDQ xmm4, 8				; xmm4 = [0|0|GY(M10)|GY(M9)]
						PSRLDQ xmm5, 8				; xmm5  =[0|0|GX(M10)|GX(M9)]
						MOVD r11d,xmm4 ; r11d = GY(M9)
						MOVD ebx,xmm5 ; ebx = GX(M9)


						CMP ebx, 0 ; COmparo contra 0 (gx == 0)
						JE gx9Es0

						JMP gx9arctg

						gx9Es0:
							CMP r11d,0
							JE angulo9Es0
							MOVDQU xmm13,xmm15 ; xmm13 = [pi/2|pi/2|pi/2|pi/2] = 90 en radianes
							JMP angPixel8

						angulo9Es0:
							MOV ebx,0 ; ANGULO = 0
							MOVD xmm13,ebx
							JMP angPixel8

						gx9arctg:
							MOVD [rbp + off_primero] ,xmm4 		; GY(M9)
							MOVD [rbp + off_segundo], xmm5		; GX(M9)
							FINIT 
							FLD dword [rbp + off_primero]		; Pusheo --> ST[1] --> GY(M9)
							FLD dword [rbp + off_segundo]	    ; Pusheo --> ST[0] --> GX(M9)
							FPATAN 								; Cálculo de arctng(ST[1] / ST[0])
							FST dword [rbp + off_primero]       ; Popeo ---> [rbp + off_primero] = ST[0] = arctang(gy/gx)
							MOVD xmm13, [rbp + off_primero]     ; xmm13 = [Basura|Basura|Basura|ang(M9)]



					angPixel8:
						;-------------ACOMODAMOSS -------------
						; xmm13 = [Basura|Basura|Basura|arct(M9)]
						PSLLDQ xmm13, 12;
						PSRLDQ xmm13, 12;
						; xmm13 = [0|0|0|arct(M19)
						; xmm9 = [Basura|Basura|arct(M10)|0] 
						ADDPS xmm9,xmm13 ; 		; xmm9 = [Basura|Basura|arct(M10)|arct(M9)] 
						PSLLDQ xmm9, 4     		; xmm9 = [Basura|arct(M10)|arct(M9)|0]
						;-------------ACOMODAMOSS -------------

						MOVDQU xmm5, xmm8			; xmm5 = [GX(M10)|GX(M9)|GX(M8)|GX(M7)]
						MOVDQU xmm4, xmm0 			; xmm4 = [GY(M10)|GY(M9)|GY(M8)|GY(M7)]
						PSRLDQ xmm4, 4				; xmm4 = [0|GY(M10)|GY(M9)|GY(M8)]
						PSRLDQ xmm5, 4				; xmm5  =[0|GX(M10)|GX(M9)|GX(M8)]
						MOVD r11d,xmm4 ; r11d = GY(M8)
						MOVD ebx,xmm5 ; ebx = GX(M8)


						CMP ebx, 0 ; COmparo contra 0 (gx == 0)
						JE gx8Es0

						JMP gx8arctg

						gx8Es0:
							CMP r11d,0
							JE angulo8Es0
							MOVDQU xmm13,xmm15 ; xmm13 = [pi/2|pi/2|pi/2|pi/2] = 90 en radianes
							JMP angPixel7

						angulo8Es0:
							MOV ebx,0 ; ANGULO = 0
							MOVD xmm13,ebx
							JMP angPixel7

						gx8arctg:
							MOVD [rbp + off_primero] ,xmm4 		; GY(M8)
							MOVD [rbp + off_segundo], xmm5		; GX(M8)
							FINIT 
							FLD dword [rbp + off_primero]		; Pusheo --> ST[1] --> GY(M8)
							FLD dword [rbp + off_segundo]	    ; Pusheo --> ST[0] --> GX(M8)
							FPATAN 								; Cálculo de arctng(ST[1] / ST[0])
							FST dword [rbp + off_primero]       ; Popeo ---> [rbp + off_primero] = ST[0] = arctang(gy/gx)
							MOVD xmm13, [rbp + off_primero]     ; xmm13 = [Basura|Basura|Basura|ang(M8)]



					angPixel7:
						;-------------ACOMODAMOSS -------------
						; xmm13 = [Basura|Basura|Basura|arct(M8)]
						PSLLDQ xmm13, 12;
						PSRLDQ xmm13, 12;
						; xmm13 = [0|0|0|arct(M8)
						; xmm9 = [Basura|arct(M10)|arct(M9)|0]
						ADDPS xmm9,xmm13 			; xmm9 = [Basura|arct(M10)|arct(M9)|arct(M8)]
						PSLLDQ xmm9, 4     			; xmm9 = [arct(M10)|arct(M9)|arct(M8)|0]
						;-------------ACOMODAMOSS -------------

						MOVDQU xmm5, xmm8			; xmm5 = [GX(M10)|GX(M9)|GX(M8)|GX(M7)]
						MOVDQU xmm4, xmm0 			; xmm4 = [GY(M10)|GY(M9)|GY(M8)|GY(M7)]
						MOVD r11d,xmm4 ; r11d = GY(M7)
						MOVD ebx,xmm5 ; ebx = GX(M7)


						CMP ebx, 0 ; COmparo contra 0 (gx == 0)
						JE gx7Es0

						JMP gx7arctg

						gx7Es0:
							CMP r11d,0
							JE angulo7Es0
							MOVDQU xmm13,xmm15 ; xmm13 = [pi/2|pi/2|pi/2|pi/2] = 90 en radianes
							JMP angsPixeles6a3

						angulo7Es0:
							MOV ebx,0 ; ANGULO = 0
							MOVD xmm13,ebx
							JMP angsPixeles6a3

						gx7arctg:
							MOVD [rbp + off_primero] ,xmm4 		; GY(M7)
							MOVD [rbp + off_segundo], xmm5		; GX(M7)
							FINIT 
							FLD dword [rbp + off_primero]		; Pusheo --> ST[1] --> GY(M7)
							FLD dword [rbp + off_segundo]	    ; Pusheo --> ST[0] --> GX(M7)
							FPATAN 								; Cálculo de arctng(ST[1] / ST[0])
							FST dword [rbp + off_primero]       ; Popeo ---> [rbp + off_primero] = ST[0] = arctang(gy/gx)
							MOVD xmm13, [rbp + off_primero]     ; xmm13 = [Basura|Basura|Basura|ang(M7)]




				angsPixeles6a3:
					;-------------ACOMODAMOSS -------------
					; xmm13 = [Basura|Basura|Basura|arct(M7)]
					PSLLDQ xmm13, 12;
					PSRLDQ xmm13, 12;
					; xmm13 = [0|0|0|arct(M7)
					; xmm9 = [arct(M10)|arct(M9)|arct(M8)|0]
					ADDPS xmm9,xmm13 			; xmm9 = [arct(M10)|arct(M9)|arct(M8)|arct(M7)]
					MOVDQU xmm0,xmm9 			; Guardo los resultados obtenidos 
					;-------------ACOMODAMOSS -------------

					angPixel6:

						MOVDQU xmm5, xmm10; xmm5 = [GX(M6)|GX(M5)|GX(M4)|GX(M3)]
						MOVDQU xmm4, xmm3; xmm4 = [GY(M6)|GY(M5)|GY(M4)|GY(M3)]
						PSRLDQ xmm4, 12;  xmm4 = [0|0|0|GY(M6)]
						PSRLDQ xmm5, 12;  xmm5 = [0|0|0|GX(M6)]
						MOVD r11d,xmm4 ; r11d = GY(M6)
						MOVD ebx,xmm5 ; ebx = GX(M6)


						CMP ebx, 0 ; COmparo contra 0 (gx == 0)
						JE gx6Es0

						JMP gx6arctg

						gx6Es0:
							CMP r11d,0
							JE angulo6Es0
							MOVDQU xmm13,xmm15 ; xmm13 = [pi/2|pi/2|pi/2|pi/2] = 90 en radianes
							JMP angPixel5

						angulo6Es0:
							MOV ebx,0 ; ANGULO = 0
							MOVD xmm13,ebx
							JMP angPixel5

						gx6arctg:
							MOVD [rbp + off_primero] ,xmm4 		; GY(M6)
							MOVD [rbp + off_segundo], xmm5		; GX(M6)
							FINIT 
							FLD dword [rbp + off_primero]		; Pusheo --> ST[1] --> GY(M6)
							FLD dword [rbp + off_segundo]	    ; Pusheo --> ST[0] --> GX(M6)
							FPATAN 								; Cálculo de arctng(ST[1] / ST[0])
							FST dword [rbp + off_primero]       ; Popeo ---> [rbp + off_primero] = ST[0] = arctang(gy/gx)
							MOVD xmm13, [rbp + off_primero]     ; xmm13 = [Basura|Basura|Basura|ang(M6)]



					angPixel5: 
						;-------------ACOMODAMOSS -------------
						; xmm13 = [Basura|Basura|Basura|arct(M6)]
						PSLLDQ xmm13, 12;
						PSRLDQ xmm13, 12;
						; xmm13 = [0|0|0|arct(M6)
						MOVDQU xmm9, xmm13		; xmm9 =  [Basura|Basura|Basura|arct(M6)]
						PSLLDQ xmm9, 4     		; xmm9 = [Basura|Basura|arct(M6)|0] 
						;-------------ACOMODAMOSS -------------

						MOVDQU xmm5, xmm10			; xmm5 = [GX(M6)|GX(M5)|GX(M4)|GX(M3)]
						MOVDQU xmm4, xmm3 			; xmm4 = [GY(M6)|GY(M5)|GY(M4)|GY(M3)]
						PSRLDQ xmm4, 8				; xmm4 = [0|0|GY(M6)|GY(M5)]
						PSRLDQ xmm5, 8				; xmm5  =[0|0|GX(M6)|GX(M5)]
						MOVD r11d,xmm4 ; r11d = GY(M5)
						MOVD ebx,xmm5 ; ebx = GX(M5)

						CMP ebx, 0 ; COmparo contra 0 (gx == 0)
						JE gx5Es0

						JMP gx5arctg


						gx5Es0:
							CMP r11d,0
							JE angulo5Es0
							MOVDQU xmm13,xmm15 ; xmm13 = [pi/2|pi/2|pi/2|pi/2] = 90 en radianes
							JMP angPixel4

						angulo5Es0:
							MOV ebx,0 ; ANGULO = 0
							MOVD xmm13,ebx
							JMP angPixel4

						gx5arctg:
							MOVD [rbp + off_primero] ,xmm4 		; GY(M5)
							MOVD [rbp + off_segundo], xmm5		; GX(M5)
							FINIT 
							FLD dword [rbp + off_primero]		; Pusheo --> ST[1] --> GY(M5)
							FLD dword [rbp + off_segundo]	    ; Pusheo --> ST[0] --> GX(M5)
							FPATAN 								; Cálculo de arctng(ST[1] / ST[0])
							FST dword [rbp + off_primero]       ; Popeo ---> [rbp + off_primero] = ST[0] = arctang(gy/gx)
							MOVD xmm13, [rbp + off_primero]     ; xmm13 = [Basura|Basura|Basura|ang(M5)]



					angPixel4:
						;-------------ACOMODAMOSS -------------
						; xmm13 = [Basura|Basura|Basura|arct(M5)]
						PSLLDQ xmm13, 12;
						PSRLDQ xmm13, 12;
						; xmm13 = [0|0|0|arct(M5)
						; xmm9 = [Basura|Basura|arct(M6)|0] 
						ADDPS xmm9,xmm13 ; 		; xmm9 = [Basura|Basura|arct(M6)|arct(M5)] 
						PSLLDQ xmm9, 4     		; xmm9 = [Basura|arct(M6)|arct(M5)|0]
						;-------------ACOMODAMOSS -------------

						MOVDQU xmm5, xmm10			; xmm5 = [GX(M6)|GX(M5)|GX(M4)|GX(M3)]
						MOVDQU xmm4, xmm3			; xmm4 = [GY(M6)|GY(M5)|GY(M4)|GY(M3)]
						PSRLDQ xmm4, 4				; xmm4 = [0|GY(M6)|GY(M5)|GY(M4)]
						PSRLDQ xmm5, 4				; xmm5  =[0|GX(M6)|GX(M5)|GX(M4)]
						MOVD r11d,xmm4 ; r11d = GY(M4)
						MOVD ebx,xmm5 ; ebx = GX(M4)


						CMP ebx, 0 ; COmparo contra 0 (gx == 0)
						JE gx4Es0

						JMP gx4arctg


						gx4Es0:
							CMP r11d,0
							JE angulo4Es0
							MOVDQU xmm13,xmm15 ; xmm13 = [pi/2|pi/2|pi/2|pi/2] = 90 en radianes
							JMP angPixel3

						angulo4Es0:
							MOV ebx,0 ; ANGULO = 0
							MOVD xmm13,ebx
							JMP angPixel3

						gx4arctg:
							MOVD [rbp + off_primero] ,xmm4 		; GY(M4)
							MOVD [rbp + off_segundo], xmm5		; GX(M4)
							FINIT 
							FLD dword [rbp + off_primero]		; Pusheo --> ST[1] --> GY(M4)
							FLD dword [rbp + off_segundo]	    ; Pusheo --> ST[0] --> GX(M4)
							FPATAN 								; Cálculo de arctng(ST[1] / ST[0])
							FST dword [rbp + off_primero]       ; Popeo ---> [rbp + off_primero] = ST[0] = arctang(gy/gx)
							MOVD xmm13, [rbp + off_primero]     ; xmm13 = [Basura|Basura|Basura|ang(M4)]



					angPixel3:
						;-------------ACOMODAMOSS -------------
						; xmm13 = [Basura|Basura|Basura|arct(M4)]
						PSLLDQ xmm13, 12;
						PSRLDQ xmm13, 12;
						; xmm13 = [0|0|0|arct(M4)]
						; xmm9 = [Basura|arct(M6)|arct(M5)|0]
						ADDPS xmm9,xmm13 			; xmm9 = [Basura|arct(M6)|arct(M5)|arct(M4)]
						PSLLDQ xmm9, 4     			; xmm9 = [arct(M6)|arct(M5)|arct(M4)|0]
						;-------------ACOMODAMOSS -------------

						MOVDQU xmm5, xmm10			; xmm5 = [GX(M6)|GX(M5)|GX(M4)|GX(M3)]
						MOVDQU xmm4, xmm3			; xmm4 = [GY(M6)|GY(M5)|GY(M4)|GY(M3)]
						MOVD r11d,xmm4 ; r11d = GY(M3)
						MOVD ebx,xmm5 ; ebx = GX(M3)

						CMP ebx, 0 ; COmparo contra 0 (gx == 0)
						JE gx3Es0

						JMP gx3arctg


						gx3Es0:
							CMP r11d,0
							JE angulo3Es0
							MOVDQU xmm13,xmm15 ; xmm13 = [pi/2|pi/2|pi/2|pi/2] = 90 en radianes
							JMP angsPixeles2y1

						angulo3Es0:
							MOV ebx,0 ; ANGULO = 0
							MOVD xmm13,ebx
							JMP angsPixeles2y1

						gx3arctg:
							MOVD [rbp + off_primero] ,xmm4 		; GY(M3)
							MOVD [rbp + off_segundo], xmm5		; GX(M3)
							FINIT 
							FLD dword [rbp + off_primero]		; Pusheo --> ST[1] --> GY(M3)
							FLD dword [rbp + off_segundo]	    ; Pusheo --> ST[0] --> GX(M3)
							FPATAN 								; Cálculo de arctng(ST[1] / ST[0])
							FST dword [rbp + off_primero]       ; Popeo ---> [rbp + off_primero] = ST[0] = arctang(gy/gx)
							MOVD xmm13, [rbp + off_primero]     ; xmm13 = [Basura|Basura|Basura|ang(M3)]



				angsPixeles2y1:
					;-------------ACOMODAMOSS -------------
					; xmm13 = [Basura|Basura|Basura|arct(M3]
					PSLLDQ xmm13, 12;
					PSRLDQ xmm13, 12;
					; xmm13 = [0|0|0|arct(M2)]
					; xmm9 = [arct(M6)|arct(M5)|arct(M4)|0]
					ADDPS xmm9,xmm13 			; xmm9 = [arct(M6)|arct(M5)|arct(M4)|arct(M3)]
					MOVDQU xmm3,xmm9 			; Guardo los resultados obtenidos 
					;-------------ACOMODAMOSS -------------

					angPixel2:

						MOVDQU xmm5, xmm11; xmm5 = [GX(M2)|GX(M1)|Basura|Basura]
						MOVDQU xmm4, xmm1; xmm4 = [GY(M2)|GY(M1)|Basura|Basura]
						PSRLDQ xmm4, 4;  xmm4 = [0|0|0|GY(M2)]
						PSRLDQ xmm5, 4;  xmm5 = [0|0|0|GX(M2)]
						MOVD r11d,xmm4 ; r11d = GY(M2)
						MOVD ebx,xmm5 ; ebx = GX(M2)
						

						CMP ebx, 0 ; COmparo contra 0 (gx == 0)
						JE gx2Es0

						JMP gx2arctg


						gx2Es0:
							CMP r11d,0
							JE angulo2Es0
							MOVDQU xmm13,xmm15 ; xmm13 = [pi/2|pi/2|pi/2|pi/2] = 90 en radianes
							JMP angPixel1

						angulo2Es0:
							MOV ebx,0 ; ANGULO = 0
							MOVD xmm13,ebx
							JMP angPixel1

						gx2arctg:
							MOVD [rbp + off_primero] ,xmm4 		; GY(M2)
							MOVD [rbp + off_segundo], xmm5		; GX(M2)
							FINIT 
							FLD dword [rbp + off_primero]		; Pusheo --> ST[1] --> GY(M2)
							FLD dword [rbp + off_segundo]	    ; Pusheo --> ST[0] --> GX(M2)
							FPATAN 								; Cálculo de arctng(ST[1] / ST[0])
							FST dword [rbp + off_primero]       ; Popeo ---> [rbp + off_primero] = ST[0] = arctang(gy/gx)
							MOVD xmm13, [rbp + off_primero]     ; xmm13 = [Basura|Basura|Basura|ang(M2)]



					angPixel1: 
						;-------------ACOMODAMOSS -------------
						; xmm13 = [Basura|Basura|Basura|arct(M2)]
						PSLLDQ xmm13, 12;
						PSRLDQ xmm13, 12;
						; xmm13 = [0|0|0|arct(M2)]
						MOVDQU xmm9, xmm13		; xmm9 =  [0|0|0|arct(M2)]
						PSLLDQ xmm9, 4     		; xmm9 = [0|0|arct(M2)|0] 
						;-------------ACOMODAMOSS -------------

						MOVDQU xmm5, xmm11			; xmm5 = [GX(M2)|GX(M1)|Basura|Basura]
						MOVDQU xmm4, xmm1			; xmm4 = [GY(M2)|GY(M1)|Basura|Basura]
						MOVD r11d,xmm4 ; r11d = GY(M1)
						MOVD ebx,xmm5 ; ebx = GX(M1)
						

						CMP ebx, 0 ; COmparo contra 0 (gx == 0)
						JE gx1Es0

						JMP gx1arctg

						gx1Es0:
							CMP r11d,0
							JE angulo1Es0
							MOVDQU xmm13,xmm15 ; xmm13 = [pi/2|pi/2|pi/2|pi/2] = 90 en radianes
							JMP seguirConValores

						angulo1Es0:
							MOV ebx,0 ; ANGULO = 0
							MOVD xmm13,ebx
							JMP seguirConValores

						gx1arctg:
							MOVD [rbp + off_primero] ,xmm4 		; GY(M1)
							MOVD [rbp + off_segundo], xmm5		; GX(M1)
							FINIT 
							FLD dword [rbp + off_primero]		; Pusheo --> ST[1] --> GY(M1)
							FLD dword [rbp + off_segundo]	    ; Pusheo --> ST[0] --> GX(M1)
							FPATAN 								; Cálculo de arctng(ST[1] / ST[0])
							FST dword [rbp + off_primero]       ; Popeo ---> [rbp + off_primero] = ST[0] = arctang(gy/gx)
							MOVD xmm13, [rbp + off_primero]     ; xmm13 = [Basura|Basura|Basura|ang(M1)]



					seguirConValores:
						;-------------ACOMODAMOSS -------------
						; xmm13 = [Basura|Basura|Basura|arct(M1)]
						; xmm9 = [Basura|Basura|arct(M2)|0]
						PSLLDQ xmm13, 12;
						PSRLDQ xmm13, 12;
						 ;xmm13 = [0|0|0|arct(M1)]
						ADDPS xmm9,xmm13 			; xmm9 = [Basura|Basura|arct(M2)|arct(M1)]
						MOVDQU xmm1,xmm9 			; Guardo los resultados obtenidos 
						;-------------ACOMODAMOSS -------------

						;----------------------------------------------------------------------------------------------------------------	
						; 				Resumen  
						;				 xmm0 = [arct(M10)|arct(M9)|arct(M8)|arct(M7)]
						;				 xmm1 = [Basura|Basura|arct(M2)|arct(M1)]
						;				 xmm2 = [ang(M14)|ang(M13)|ang(M12)|ang(M11)]
						;				 xmm3 = [arct(M6)|arct(M5)|arct(M4)|arct(M3)]
						;			 	 xmm4 = LIBRE
						;			 	 xmm5 = LIBRE
						;			 	 xmm6 = LIBRE
						;				 xmm7 = LIBRE
						;				 xmm8 = LIBRE
						;				 xmm9 = LIBRE
						;				 xmm10 = LIBRE
						;				 xmm11 = LIBRE
						;				 xmm12 = [22.5|22.5|22.5|22.5]
						;				 xmm13 = LIBRE
						;				 xmm14 = [50|50|50|50]
						;				 xmm15 = [pi/2|pi/2|pi/2|pi/2]
						;
						;----------------------------------------------------------------------------------------------------------------
				



			     ;Pasamos los valores de radianes a grados 
			    	 MOVDQU xmm4,xmm12 			 ; xmm4 = [22.5|22.5|22.5|22.5]
			    	 ADDPS xmm4,xmm4 			 ; xmm4 = [45|45|45|45]
			    	 ADDPS xmm4,xmm4 			 ; xmm4 = [90|90|90|90]
			    	 ADDPS xmm4,xmm4 			 ; xmm4 = [180|180|180|180]
 
 
			     	;Multiplicamos por 180 
			     	MULPS xmm0,xmm4		  	 ; xmm0 = [arctg(M10)*180|...|arctg(M7) *180] --> En radianes
			     	MULPS xmm1,xmm4		  	 ; xmm1 = [arctg(M2)*180|arctg(M1) *180|0|0] --> En radianes
			     	MULPS xmm2,xmm4		  	 ; xmm2 = [arctg(M14)*180|...|arctg(M11) *180] --> En radianes
					MULPS xmm3,xmm4		  	 ; xmm3 = [arctg(M6)*180|...|arctg(M3) *180] --> En radianes
 
					 ;Dividimos por Pi 
					 MOVDQU xmm5, xmm15 			 ; xmm5 = [pi/2|pi/2|pi/2|pi/2]
					 ADDPS xmm5,xmm5              ; xmm5 = [pi|pi|pi|pi]
 
					 DIVPS xmm0,xmm5 			 ; xmm0 = [arctg(M10)|...|arctg(M7)] --> En grados 
					 DIVPS xmm1,xmm5 			 ; xmm1 = [arctg(M2)|arctg(M1)|0|0] --> En grados
					 DIVPS xmm2,xmm5 			 ; xmm2 = [arctg(M14)|...|arctg(M11)] --> En grados
					 DIVPS xmm3,xmm5 			 ; xmm3 = [arctg(M6)|...|arctg(M3)] --> En grados


 
 
				;Pasamos los negativos a positivos
					;xmm4 = [180|180|180|180]
					ADDPS xmm4,xmm4    ; xmm4 = [360|360|360|360]
					PCMPEQQ xmm5,xmm5  ; xmm5 = [1|1|..|1]

					; ------Para xmm0 -----------
					PXOR xmm6,xmm6     ; xmm6 = [0|0|0|0]

					CMPPS xmm6, xmm0, 2 ; CMPLEPS xmm6,xmm1  -->  xmm6 <= xmm1  --> 0 <= arctg(ANGi) --> Tengo con 1's los mayores o iguales a 0
					
					PXOR xmm6,xmm5 		; Me quedan en 1 solo los lugares donde hay angulos negativos
					PAND xmm6,xmm4  	; En los lugares donde los ang son positivos dejo 0 en los otros dejo 360
					ADDPS xmm0,xmm6 	; Le sumo a los negativos 360
					; ------Para xmm0 -----------


					; ------Para xmm1 -----------
					PXOR xmm6,xmm6     ; xmm6 = [0|0|0|0]

					CMPPS xmm6, xmm1, 2 ; CMPLEPS xmm6,xmm1  -->  xmm6 <= xmm1  --> 0 <= arctg(ANGi) --> Tengo con 1's los mayores o iguales a 0
					PXOR xmm6,xmm5 	    ; Me quedan en 1 solo los lugares donde hay angulos negativos
					PAND xmm6,xmm4  	; En los lugares donde los ang son positivos dejo 0 en los otros dejo 360
					ADDPS xmm1,xmm6		; Le sumo a los negativos 360
					; ------Para xmm1 -----------

					; ------Para xmm1 -----------
					PXOR xmm6,xmm6     ; xmm6 = [0|0|0|0]

					CMPPS xmm6, xmm2, 2 ; CMPLEPS xmm6,xmm2  -->  xmm6 <= xmm2  --> 0 <= arctg(ANGi) --> Tengo con 1's los mayores o iguales a 0
					PXOR xmm6,xmm5 	; Me quedan en 1 solo los lugares donde hay angulos negativos
					PAND xmm6,xmm4  	; En los lugares donde los ang son positivos dejo 0 en los otros dejo 360
					ADDPS xmm2,xmm6		; Le sumo a los negativos 360
					; ------Para xmm1 -----------

					; ------Para xmm3 -----------
					PXOR xmm6,xmm6     ; xmm6 = [0|0|0|0]

					CMPPS xmm6, xmm3, 2 ; CMPLEPS xmm6,xmm3  -->  xmm6 <= xmm3  --> 0 <= arctg(ANGi) --> Tengo con 1's los mayores o iguales a 0
					PXOR xmm6,xmm5 	; Me quedan en 1 solo los lugares donde hay angulos negativos
					PAND xmm6,xmm4  	; En los lugares donde los ang son positivos dejo 0 en los otros dejo 360
					ADDPS xmm3,xmm6		; Le sumo a los negativos 360
					; ------Para xmm3 -----------




					;----------------------------------------------------------------------------------------------------------------	
					; 				Resumen  
					;				 xmm0 = [arct(M10)|arct(M9)|arct(M8)|arct(M7)] 		(En grados y positivos)
					;				 xmm1 = [Basura|Basura|arct(M2)|arct(M1)]			(En grados y positivos)
					;				 xmm2 = [ang(M14)|ang(M13)|ang(M12)|ang(M11)]		(En grados y positivos)
					;				 xmm3 = [arct(M6)|arct(M5)|arct(M4)|arct(M3)]		(En grados y positivos)
					;			 	 xmm4 = LIBRE
					;			 	 xmm5 = LIBRE   
					;			 	 xmm6 = LIBRE   --> será utilizado para límite inferior
					;				 xmm7 = LIBRE   --> será utilizado para límite superior
					;				 xmm8 = LIBRE   --> será utilizado para la máscara de 50
					;				 xmm9 = LIBRE   --> será utilizado para la máscara de 100
					;				 xmm10 = LIBRE  --> será utilizado para la máscara de 150
					;				 xmm11 = LIBRE  --> será utilizado para la máscara de 200
					;				 xmm12 = [22.5|22.5|22.5|22.5]
					;				 xmm13 = LIBRE  --> será utilizado para sumar 45
					;				 xmm14 = [50|50|50|50]
					;				 xmm15 = [pi/2|pi/2|pi/2|pi/2]
					;
					;----------------------------------------------------------------------------------------------------------------
				

				
				;Calculamos los valores finales 


					;---------------------PARA XMM0 ----------------------------------
						;Limpio los registros "acumuladores"
						PXOR xmm8,xmm8
						PXOR xmm9,xmm9
						PXOR xmm10,xmm10
						PXOR xmm11,xmm11

						MOVDQU xmm7, xmm12 			; xmm7 = [22.5|22.5|22.5|22.5]
						PXOR xmm6,xmm6				; xmm6 = [0|0|0|0]
						MOVDQU xmm13,xmm7			; xmm13 = [22.5|22.5|22.5|22.5]
						ADDPS xmm13,xmm12           ; xmm13 = [45|45|45|45]
						

						;Menor a 22.5
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]

							MOVDQU xmm4,xmm7			; xmm4 = [22.5|22.5|22.5|22.5]

							CMPPS xmm4,xmm0,2 			; CMPLEPS xmm4,xmm0   -->  xmm4 <= xmm0 (Los que son mayores o iguales a 22.5 están con 1's)
							PXOR xmm4,xmm5 				; Los que son menores a 22.5 están con 1's. (HAGO UN NOT CASERO)

							MOVDQU xmm5,xmm6

							CMPPS xmm5, xmm0, 2         ; Los que son mayores o iguales a 0 estan con 1's

							PAND xmm4,xmm5 
							POR xmm8,xmm4 				; Guardo el resultado en xmm8 (valor 50)

						;Menor a 67.5 , Mayor  a 22.5
							MOVDQU xmm6,xmm7 			; xmm6 = [22.5|22.5|22.5|22.5]
							ADDPS xmm7,xmm13 			; xmm7 = [67.5|67.5|67.5|67.5]
							MOVDQU xmm4,xmm7  			; xmm4 = [67.5|67.5|67.5|67.5]
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]

							CMPPS xmm4,xmm0,2 			; CMPLEPS xmm4,xmm0   -->  xmm4 <= xmm0 (Los que son mayores o iguales a 67.5 están con 1's)
							PXOR xmm4,xmm5 				; Los que son menores a 67.5 están con 1's. (HAGO UN NOT CASERO)

							MOVDQU xmm5,xmm6			; xmm5 = [22.5|22.5|22.5|22.5]

							CMPPS xmm5,xmm0,2 			; CMPLEPS xmm5,xmm0   --> xmm5 <= xmm0 (Los que son mayores o iguales a 22.5 están con 1's)

							PAND xmm4,xmm5    			;Escribo solo aquellos que cumplan ambas condiciones
							POR xmm9,xmm4 				; Guardo el resultado en xmm9 (valor 100)

						;Menor a 112.5, Mayor a 67.5
							MOVDQU xmm6,xmm7 			; xmm6 = [67.5|67.5|67.5|67.5]
							ADDPS xmm7,xmm13 			; xmm7 = [112.5|112.5|112.5|112.5]
							MOVDQU xmm4,xmm7  			; xmm4 = [112.5|112.5|112.5|112.5]
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]


							CMPPS xmm4,xmm0,2 			; CMPLEPS xmm4,xmm0   -->  xmm4 <= xmm0 (Los que son mayores o iguales a 112.5 están con 1's)
							PXOR xmm4,xmm5	 			; Los que son menores a 112.5 están con 1's. (HAGO UN NOT CASERO)
							MOVDQU xmm5,xmm6			; xmm5 = [67.5|67.5|67.5|67.5]

							CMPPS xmm5,xmm0,2 			; CMPLEPS xmm5,xmm0   --> xmm5 <= xmm0 (Los que son mayores o iguales a 67.5 están con 1's)

							PAND xmm4,xmm5    			;Escribo solo aquellos que cumplan ambas condiciones
							POR xmm10,xmm4 				; Guardo el resultado en xmm10 (valor 150)

						;Menor a 157.5, Mayor a 112.5
							MOVDQU xmm6,xmm7 			; xmm6 = [112.5|112.5|112.5|112.5]
							ADDPS xmm7,xmm13 			; xmm7 = [157.5|157.5|157.5|157.5]
							MOVDQU xmm4,xmm7  			; xmm4 = [157.5|157.5|157.5|157.5]
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]
						
							CMPPS xmm4,xmm0,2 			; CMPLEPS xmm4,xmm0   -->  xmm4 <= xmm0 (Los que son mayores o iguales a 157.5 están con 1's)
							PXOR xmm4,xmm5  			; Los que son menores a 157.5 están con 1's. (HAGO UN NOT CASERO)

							MOVDQU xmm5,xmm6			; xmm5 = [112.5|112.5|112.5|112.5]
							CMPPS xmm5,xmm0,2 			; CMPLEPS xmm5,xmm0   --> xmm5 <= xmm0 (Los que son mayores o iguales a 112.5 están con 1's)

							PAND xmm4,xmm5    			;Escribo solo aquellos que cumplan ambas condiciones
							POR xmm11,xmm4 				; Guardo el resultado en xmm11 (valor 200)
						

						;Menor a 202.5, Mayor a 157.5
							MOVDQU xmm6,xmm7 			; xmm6 = [157.5|157.5|157.5|157.5]
							ADDPS xmm7,xmm13 			; xmm7 = [202.5|202.5|202.5|202.5]
							MOVDQU xmm4,xmm7  			; xmm4 = [202.5|202.5|202.5|202.5]
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]
						
							CMPPS xmm4,xmm0,2 			; CMPLEPS xmm4,xmm0   -->  xmm4 <= xmm0 (Los que son mayores o iguales a 202.5 están con 1's)
							PXOR xmm4,xmm5 				; Los que son menores a 202.5 están con 1's. (HAGO UN NOT CASERO)

							MOVDQU xmm5,xmm6			; xmm5 = [157.5|157.5|157.5|157.5]
							CMPPS xmm5,xmm0,2 			; CMPLEPS xmm5,xmm0   --> xmm5 <= xmm0 (Los que son mayores o iguales a 157.5 están con 1's)

							PAND xmm4,xmm5    			;Escribo solo aquellos que cumplan ambas condiciones
							POR xmm8,xmm4 				; Guardo el resultado en xmm8 (valor 50)


						;Menor a 247.5, Mayor a 202.5
							MOVDQU xmm6,xmm7 			; xmm6 = [202.5|202.5|202.5|202.5]
							ADDPS xmm7,xmm13 			; xmm7 = [247.5|247.5|247.5|247.5]
							MOVDQU xmm4,xmm7  			; xmm4 = [247.5|247.5|247.5|247.5]
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]
						
							CMPPS xmm4,xmm0,2 			; CMPLEPS xmm4,xmm0   -->  xmm4 <= xmm0 (Los que son mayores o iguales a 247.5 están con 1's)
							PXOR xmm4,xmm5 			    ; Los que son menores a 247.5 están con 1's. (HAGO UN NOT CASERO)

							MOVDQU xmm5,xmm6			; xmm5 = [202.5|202.5|202.5|202.5]
							CMPPS xmm5,xmm0,2 			; CMPLEPS xmm5,xmm0   --> xmm5 <= xmm0 (Los que son mayores o iguales a 202.5 están con 1's)

							PAND xmm4,xmm5    			;Escribo solo aquellos que cumplan ambas condiciones
							POR xmm9,xmm4 				; Guardo el resultado en xmm9 (valor 100)

						;Menor a 292.5, Mayor a 247.5
							MOVDQU xmm6,xmm7 			; xmm6 = [247.5|247.5|247.5|247.5]
							ADDPS xmm7,xmm13 			; xmm7 = [292.5|292.5|292.5|292.5]
							MOVDQU xmm4,xmm7  			; xmm4 = [292.5|292.5|292.5|292.5]
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]
						
							CMPPS xmm4,xmm0,2 			; CMPLEPS xmm4,xmm0   -->  xmm4 <= xmm0 (Los que son mayores o iguales a 292.5 están con 1's)
							PXOR xmm4,xmm5 				; Los que son menores a 292.5 están con 1's. (HAGO UN NOT CASERO)
							
							MOVDQU xmm5,xmm6			; xmm5 = [247.5|247.5|247.5|247.5]
							CMPPS xmm5,xmm0,2 			; CMPLEPS xmm5,xmm0   --> xmm5 <= xmm0 (Los que son mayores o iguales a 247.5 están con 1's)

							PAND xmm4,xmm5    			;Escribo solo aquellos que cumplan ambas condiciones
							POR xmm10,xmm4 				; Guardo el resultado en xmm10 (valor 150)

						;Menor a 337.5, Mayor a 292.5
							MOVDQU xmm6,xmm7 			; xmm6 = [292.5|292.5|292.5|292.5]
							ADDPS xmm7,xmm13 			; xmm7 = [337.5|337.5|337.5|337.5]
							MOVDQU xmm4,xmm7  			; xmm4 = [337.5|337.5|337.5|337.5]
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]					

							CMPPS xmm4,xmm0,2 			; CMPLEPS xmm4,xmm0   -->  xmm4 <= xmm0 (Los que son mayores o iguales a 337.5 están con 1's)
							PXOR xmm4,xmm5 				; Los que son menores a 337.5 están con 1's. (HAGO UN NOT CASERO)
							
							MOVDQU xmm5,xmm6			; xmm5 = [292.5|292.5|292.5|292.5]
							CMPPS xmm5,xmm0,2 			; CMPLEPS xmm5,xmm0   --> xmm5 <= xmm0 (Los que son mayores o iguales a 292.5 están con 1's)

							PAND xmm4,xmm5    			;Escribo solo aquellos que cumplan ambas condiciones
							POR xmm11,xmm4 				; Guardo el resultado en xmm11 (valor 200)


						;Menor a 360, Mayor a 337.5
							MOVDQU xmm6,xmm7 			; xmm6 = [337.5|337.5|337.5|337.5]
							ADDPS xmm7,xmm12 			; xmm7 = [360|360|360|360]
							MOVDQU xmm4,xmm7  			; xmm4 = [360|360|360|360]
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]
						

							CMPPS xmm4,xmm0,2 			; CMPLEPS xmm4,xmm0   -->  xmm4 <= xmm0 (Los que son mayores o iguales a 360 están con 1's)
							PXOR xmm4,xmm5 				; Los que son menores a 360 están con 1's. (HAGO UN NOT CASERO)
							MOVDQU xmm5,xmm6			; xmm5 = [337.5|337.5|337.5|337.5]


							CMPPS xmm5,xmm0,2 			; CMPLEPS xmm5,xmm0   --> xmm5 <= xmm0 (Los que son mayores o iguales a 337.5 están con 1's)

							PAND xmm4,xmm5    			;Escribo solo aquellos que cumplan ambas condiciones
							POR xmm11,xmm4 				; Guardo el resultado en xmm11 (valor 200)


						;Terminamos y escribimos el resultado en xmm0
						MOVDQU xmm4, xmm14 ; xmm4 = [50|50|50|50]
						PAND xmm8,xmm4     ; xmm8 tiene solo 50 en los que xmm8 habia unos

						ADDPS xmm4,xmm14   ; xmm4 = [100|100|100|100]
						PAND xmm9,xmm4 	   ; xmm9 tiene solo 100 en los que xmm8 habia unos

						ADDPS xmm4,xmm14   ; xmm4 = [150|150|150|150]
						PAND xmm10,xmm4    ; xmm10 tiene solo 150 en los que xmm8 habia unos

						ADDPS xmm4,xmm14   ; xmm4 = [200|200|200|200]
						PAND xmm11,xmm4    ; xmm10 tiene solo 200 en los que xmm8 habia unos


						POR xmm8,xmm9
						POR xmm10,xmm11
						POR xmm8,xmm10
						MOVDQU xmm0,xmm8 
					;---------------------PARA XMM0 ----------------------------------








					;---------------------PARA XMM1 ----------------------------------
						;Limpio los registros "acumuladores"
						PXOR xmm8,xmm8
						PXOR xmm9,xmm9
						PXOR xmm10,xmm10
						PXOR xmm11,xmm11

						MOVDQU xmm7, xmm12 			; xmm7 = [22.5|22.5|22.5|22.5]
						PXOR xmm6,xmm6				; xmm6 = [0|0|0|0]
						MOVDQU xmm13,xmm7			; xmm13 = [22.5|22.5|22.5|22.5]
						ADDPS xmm13,xmm12           ; xmm13 = [45|45|45|45]
						

						;Menor a 22.5
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]

							MOVDQU xmm4,xmm7			; xmm4 = [22.5|22.5|22.5|22.5]

							CMPPS xmm4,xmm1,2 			; CMPLEPS xmm4,xmm1   -->  xmm4 <= xmm1 (Los que son mayores o iguales a 22.5 están con 1's)
							PXOR xmm4,xmm5 				; Los que son menores a 22.5 están con 1's. (HAGO UN NOT CASERO)

							MOVDQU xmm5,xmm6

							CMPPS xmm5, xmm0, 2         ; Los que son mayores o iguales a 0 estan con 1's

							PAND xmm4,xmm5 
							POR xmm8,xmm4 				; Guardo el resultado en xmm8 (valor 50)

						;Menor a 67.5 , Mayor  a 22.5
							MOVDQU xmm6,xmm7 			; xmm6 = [22.5|22.5|22.5|22.5]
							ADDPS xmm7,xmm13 			; xmm7 = [67.5|67.5|67.5|67.5]
							MOVDQU xmm4,xmm7  			; xmm4 = [67.5|67.5|67.5|67.5]
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]

							CMPPS xmm4,xmm1,2 			; CMPLEPS xmm4,xmm1   -->  xmm4 <= xmm1 (Los que son mayores o iguales a 67.5 están con 1's)
							PXOR xmm4,xmm5 				; Los que son menores a 67.5 están con 1's. (HAGO UN NOT CASERO)

							MOVDQU xmm5,xmm6			; xmm5 = [22.5|22.5|22.5|22.5]

							CMPPS xmm5,xmm1,2 			; CMPLEPS xmm5,xmm1   --> xmm5 <= xmm1 (Los que son mayores o iguales a 22.5 están con 1's)

							PAND xmm4,xmm5    			;Escribo solo aquellos que cumplan ambas condiciones
							POR xmm9,xmm4 				; Guardo el resultado en xmm9 (valor 100)

						;Menor a 112.5, Mayor a 67.5
							MOVDQU xmm6,xmm7 			; xmm6 = [67.5|67.5|67.5|67.5]
							ADDPS xmm7,xmm13 			; xmm7 = [112.5|112.5|112.5|112.5]
							MOVDQU xmm4,xmm7  			; xmm4 = [112.5|112.5|112.5|112.5]
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]


							CMPPS xmm4,xmm1,2 			; CMPLEPS xmm4,xmm1   -->  xmm4 <= xmm1 (Los que son mayores o iguales a 112.5 están con 1's)
							PXOR xmm4,xmm5	 			; Los que son menores a 112.5 están con 1's. (HAGO UN NOT CASERO)
							MOVDQU xmm5,xmm6			; xmm5 = [67.5|67.5|67.5|67.5]

							CMPPS xmm5,xmm1,2 			; CMPLEPS xmm5,xmm1   --> xmm5 <= xmm1 (Los que son mayores o iguales a 67.5 están con 1's)

							PAND xmm4,xmm5    			;Escribo solo aquellos que cumplan ambas condiciones
							POR xmm10,xmm4 				; Guardo el resultado en xmm10 (valor 150)

						;Menor a 157.5, Mayor a 112.5
							MOVDQU xmm6,xmm7 			; xmm6 = [112.5|112.5|112.5|112.5]
							ADDPS xmm7,xmm13 			; xmm7 = [157.5|157.5|157.5|157.5]
							MOVDQU xmm4,xmm7  			; xmm4 = [157.5|157.5|157.5|157.5]
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]
						
							CMPPS xmm4,xmm1,2 			; CMPLEPS xmm4,xmm1   -->  xmm4 <= xmm1 (Los que son mayores o iguales a 157.5 están con 1's)
							PXOR xmm4,xmm5  			; Los que son menores a 157.5 están con 1's. (HAGO UN NOT CASERO)

							MOVDQU xmm5,xmm6			; xmm5 = [112.5|112.5|112.5|112.5]
							CMPPS xmm5,xmm1,2 			; CMPLEPS xmm5,xmm1   --> xmm5 <= xmm1 (Los que son mayores o iguales a 112.5 están con 1's)

							PAND xmm4,xmm5    			;Escribo solo aquellos que cumplan ambas condiciones
							POR xmm11,xmm4 				; Guardo el resultado en xmm11 (valor 200)
						

						;Menor a 202.5, Mayor a 157.5
							MOVDQU xmm6,xmm7 			; xmm6 = [157.5|157.5|157.5|157.5]
							ADDPS xmm7,xmm13 			; xmm7 = [202.5|202.5|202.5|202.5]
							MOVDQU xmm4,xmm7  			; xmm4 = [202.5|202.5|202.5|202.5]
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]
						
							CMPPS xmm4,xmm1,2 			; CMPLEPS xmm4,xmm1   -->  xmm4 <= xmm1 (Los que son mayores o iguales a 202.5 están con 1's)
							PXOR xmm4,xmm5 				; Los que son menores a 202.5 están con 1's. (HAGO UN NOT CASERO)

							MOVDQU xmm5,xmm6			; xmm5 = [157.5|157.5|157.5|157.5]
							CMPPS xmm5,xmm1,2 			; CMPLEPS xmm5,xmm1   --> xmm5 <= xmm1 (Los que son mayores o iguales a 157.5 están con 1's)

							PAND xmm4,xmm5    			;Escribo solo aquellos que cumplan ambas condiciones
							POR xmm8,xmm4 				; Guardo el resultado en xmm8 (valor 50)


						;Menor a 247.5, Mayor a 202.5
							MOVDQU xmm6,xmm7 			; xmm6 = [202.5|202.5|202.5|202.5]
							ADDPS xmm7,xmm13 			; xmm7 = [247.5|247.5|247.5|247.5]
							MOVDQU xmm4,xmm7  			; xmm4 = [247.5|247.5|247.5|247.5]
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]
						
							CMPPS xmm4,xmm1,2 			; CMPLEPS xmm4,xmm1   -->  xmm4 <= xmm1 (Los que son mayores o iguales a 247.5 están con 1's)
							PXOR xmm4,xmm5 			    ; Los que son menores a 247.5 están con 1's. (HAGO UN NOT CASERO)

							MOVDQU xmm5,xmm6			; xmm5 = [202.5|202.5|202.5|202.5]
							CMPPS xmm5,xmm1,2 			; CMPLEPS xmm5,xmm1   --> xmm5 <= xmm1 (Los que son mayores o iguales a 202.5 están con 1's)

							PAND xmm4,xmm5    			;Escribo solo aquellos que cumplan ambas condiciones
							POR xmm9,xmm4 				; Guardo el resultado en xmm9 (valor 100)

						;Menor a 292.5, Mayor a 247.5
							MOVDQU xmm6,xmm7 			; xmm6 = [247.5|247.5|247.5|247.5]
							ADDPS xmm7,xmm13 			; xmm7 = [292.5|292.5|292.5|292.5]
							MOVDQU xmm4,xmm7  			; xmm4 = [292.5|292.5|292.5|292.5]
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]
						
							CMPPS xmm4,xmm1,2 			; CMPLEPS xmm4,xmm1   -->  xmm4 <= xmm1 (Los que son mayores o iguales a 292.5 están con 1's)
							PXOR xmm4,xmm5 				; Los que son menores a 292.5 están con 1's. (HAGO UN NOT CASERO)
							
							MOVDQU xmm5,xmm6			; xmm5 = [247.5|247.5|247.5|247.5]
							CMPPS xmm5,xmm1,2 			; CMPLEPS xmm5,xmm1   --> xmm5 <= xmm1 (Los que son mayores o iguales a 247.5 están con 1's)

							PAND xmm4,xmm5    			;Escribo solo aquellos que cumplan ambas condiciones
							POR xmm10,xmm4 				; Guardo el resultado en xmm10 (valor 150)

						;Menor a 337.5, Mayor a 292.5
							MOVDQU xmm6,xmm7 			; xmm6 = [292.5|292.5|292.5|292.5]
							ADDPS xmm7,xmm13 			; xmm7 = [337.5|337.5|337.5|337.5]
							MOVDQU xmm4,xmm7  			; xmm4 = [337.5|337.5|337.5|337.5]
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]					

							CMPPS xmm4,xmm1,2 			; CMPLEPS xmm4,xmm1   -->  xmm4 <= xmm1 (Los que son mayores o iguales a 337.5 están con 1's)
							PXOR xmm4,xmm5 				; Los que son menores a 337.5 están con 1's. (HAGO UN NOT CASERO)
							
							MOVDQU xmm5,xmm6			; xmm5 = [292.5|292.5|292.5|292.5]
							CMPPS xmm5,xmm1,2 			; CMPLEPS xmm5,xmm1   --> xmm5 <= xmm1 (Los que son mayores o iguales a 292.5 están con 1's)

							PAND xmm4,xmm5    			;Escribo solo aquellos que cumplan ambas condiciones
							POR xmm11,xmm4 				; Guardo el resultado en xmm11 (valor 200)


						;Menor a 360, Mayor a 337.5
							MOVDQU xmm6,xmm7 			; xmm6 = [337.5|337.5|337.5|337.5]
							ADDPS xmm7,xmm12 			; xmm7 = [360|360|360|360]
							MOVDQU xmm4,xmm7  			; xmm4 = [360|360|360|360]
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]
						

							CMPPS xmm4,xmm1,2 			; CMPLEPS xmm4,xmm1   -->  xmm4 <= xmm1 (Los que son mayores o iguales a 360 están con 1's)
							PXOR xmm4,xmm5 				; Los que son menores a 360 están con 1's. (HAGO UN NOT CASERO)
							MOVDQU xmm5,xmm6			; xmm5 = [337.5|337.5|337.5|337.5]


							CMPPS xmm5,xmm1,2 			; CMPLEPS xmm5,xmm1   --> xmm5 <= xmm1 (Los que son mayores o iguales a 337.5 están con 1's)

							PAND xmm4,xmm5    			;Escribo solo aquellos que cumplan ambas condiciones
							POR xmm11,xmm4 				; Guardo el resultado en xmm11 (valor 200)


						;Terminamos y escribimos el resultado en xmm1
						MOVDQU xmm4, xmm14 ; xmm4 = [50|50|50|50]
						PAND xmm8,xmm4     ; xmm8 tiene solo 50 en los que xmm8 habia unos

						ADDPS xmm4,xmm14   ; xmm4 = [100|100|100|100]
						PAND xmm9,xmm4 	   ; xmm9 tiene solo 100 en los que xmm8 habia unos

						ADDPS xmm4,xmm14   ; xmm4 = [150|150|150|150]
						PAND xmm10,xmm4    ; xmm10 tiene solo 150 en los que xmm8 habia unos

						ADDPS xmm4,xmm14   ; xmm4 = [200|200|200|200]
						PAND xmm11,xmm4    ; xmm10 tiene solo 200 en los que xmm8 habia unos


						POR xmm8,xmm9
						POR xmm10,xmm11
						POR xmm8,xmm10
						MOVDQU xmm1,xmm8 
					;---------------------PARA XMM1 ----------------------------------








					;---------------------PARA XMM2 ----------------------------------
						;Limpio los registros "acumuladores"
						PXOR xmm8,xmm8
						PXOR xmm9,xmm9
						PXOR xmm10,xmm10
						PXOR xmm11,xmm11

						MOVDQU xmm7, xmm12 			; xmm7 = [22.5|22.5|22.5|22.5]
						PXOR xmm6,xmm6				; xmm6 = [0|0|0|0]
						MOVDQU xmm13,xmm7			; xmm13 = [22.5|22.5|22.5|22.5]
						ADDPS xmm13,xmm12           ; xmm13 = [45|45|45|45]
						

						;Menor a 22.5
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]

							MOVDQU xmm4,xmm7			; xmm4 = [22.5|22.5|22.5|22.5]

							CMPPS xmm4,xmm2,2 			; CMPLEPS xmm4,xmm2   -->  xmm4 <= xmm2 (Los que son mayores o iguales a 22.5 están con 1's)
							PXOR xmm4,xmm5 				; Los que son menores a 22.5 están con 1's. (HAGO UN NOT CASERO)

							MOVDQU xmm5,xmm6

							CMPPS xmm5, xmm0, 2         ; Los que son mayores o iguales a 0 estan con 1's

							PAND xmm4,xmm5 
							POR xmm8,xmm4 				; Guardo el resultado en xmm8 (valor 50)

						;Menor a 67.5 , Mayor  a 22.5
							MOVDQU xmm6,xmm7 			; xmm6 = [22.5|22.5|22.5|22.5]
							ADDPS xmm7,xmm13 			; xmm7 = [67.5|67.5|67.5|67.5]
							MOVDQU xmm4,xmm7  			; xmm4 = [67.5|67.5|67.5|67.5]
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]

							CMPPS xmm4,xmm2,2 			; CMPLEPS xmm4,xmm2   -->  xmm4 <= xmm2 (Los que son mayores o iguales a 67.5 están con 1's)
							PXOR xmm4,xmm5 				; Los que son menores a 67.5 están con 1's. (HAGO UN NOT CASERO)

							MOVDQU xmm5,xmm6			; xmm5 = [22.5|22.5|22.5|22.5]

							CMPPS xmm5,xmm2,2 			; CMPLEPS xmm5,xmm2   --> xmm5 <= xmm2 (Los que son mayores o iguales a 22.5 están con 1's)

							PAND xmm4,xmm5    			;Escribo solo aquellos que cumplan ambas condiciones
							POR xmm9,xmm4 				; Guardo el resultado en xmm9 (valor 100)

						;Menor a 112.5, Mayor a 67.5
							MOVDQU xmm6,xmm7 			; xmm6 = [67.5|67.5|67.5|67.5]
							ADDPS xmm7,xmm13 			; xmm7 = [112.5|112.5|112.5|112.5]
							MOVDQU xmm4,xmm7  			; xmm4 = [112.5|112.5|112.5|112.5]
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]


							CMPPS xmm4,xmm2,2 			; CMPLEPS xmm4,xmm2   -->  xmm4 <= xmm2 (Los que son mayores o iguales a 112.5 están con 1's)
							PXOR xmm4,xmm5	 			; Los que son menores a 112.5 están con 1's. (HAGO UN NOT CASERO)
							MOVDQU xmm5,xmm6			; xmm5 = [67.5|67.5|67.5|67.5]

							CMPPS xmm5,xmm2,2 			; CMPLEPS xmm5,xmm2   --> xmm5 <= xmm2 (Los que son mayores o iguales a 67.5 están con 1's)

							PAND xmm4,xmm5    			;Escribo solo aquellos que cumplan ambas condiciones
							POR xmm10,xmm4 				; Guardo el resultado en xmm10 (valor 150)

						;Menor a 157.5, Mayor a 112.5
							MOVDQU xmm6,xmm7 			; xmm6 = [112.5|112.5|112.5|112.5]
							ADDPS xmm7,xmm13 			; xmm7 = [157.5|157.5|157.5|157.5]
							MOVDQU xmm4,xmm7  			; xmm4 = [157.5|157.5|157.5|157.5]
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]
						
							CMPPS xmm4,xmm2,2 			; CMPLEPS xmm4,xmm2   -->  xmm4 <= xmm2 (Los que son mayores o iguales a 157.5 están con 1's)
							PXOR xmm4,xmm5  			; Los que son menores a 157.5 están con 1's. (HAGO UN NOT CASERO)

							MOVDQU xmm5,xmm6			; xmm5 = [112.5|112.5|112.5|112.5]
							CMPPS xmm5,xmm2,2 			; CMPLEPS xmm5,xmm2   --> xmm5 <= xmm2 (Los que son mayores o iguales a 112.5 están con 1's)

							PAND xmm4,xmm5    			;Escribo solo aquellos que cumplan ambas condiciones
							POR xmm11,xmm4 				; Guardo el resultado en xmm11 (valor 200)
						

						;Menor a 202.5, Mayor a 157.5
							MOVDQU xmm6,xmm7 			; xmm6 = [157.5|157.5|157.5|157.5]
							ADDPS xmm7,xmm13 			; xmm7 = [202.5|202.5|202.5|202.5]
							MOVDQU xmm4,xmm7  			; xmm4 = [202.5|202.5|202.5|202.5]
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]
						
							CMPPS xmm4,xmm2,2 			; CMPLEPS xmm4,xmm2   -->  xmm4 <= xmm2 (Los que son mayores o iguales a 202.5 están con 1's)
							PXOR xmm4,xmm5 				; Los que son menores a 202.5 están con 1's. (HAGO UN NOT CASERO)

							MOVDQU xmm5,xmm6			; xmm5 = [157.5|157.5|157.5|157.5]
							CMPPS xmm5,xmm2,2 			; CMPLEPS xmm5,xmm2   --> xmm5 <= xmm2 (Los que son mayores o iguales a 157.5 están con 1's)

							PAND xmm4,xmm5    			;Escribo solo aquellos que cumplan ambas condiciones
							POR xmm8,xmm4 				; Guardo el resultado en xmm8 (valor 50)


						;Menor a 247.5, Mayor a 202.5
							MOVDQU xmm6,xmm7 			; xmm6 = [202.5|202.5|202.5|202.5]
							ADDPS xmm7,xmm13 			; xmm7 = [247.5|247.5|247.5|247.5]
							MOVDQU xmm4,xmm7  			; xmm4 = [247.5|247.5|247.5|247.5]
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]
						
							CMPPS xmm4,xmm2,2 			; CMPLEPS xmm4,xmm2   -->  xmm4 <= xmm2 (Los que son mayores o iguales a 247.5 están con 1's)
							PXOR xmm4,xmm5 			    ; Los que son menores a 247.5 están con 1's. (HAGO UN NOT CASERO)

							MOVDQU xmm5,xmm6			; xmm5 = [202.5|202.5|202.5|202.5]
							CMPPS xmm5,xmm2,2 			; CMPLEPS xmm5,xmm2   --> xmm5 <= xmm2 (Los que son mayores o iguales a 202.5 están con 1's)

							PAND xmm4,xmm5    			;Escribo solo aquellos que cumplan ambas condiciones
							POR xmm9,xmm4 				; Guardo el resultado en xmm9 (valor 100)

						;Menor a 292.5, Mayor a 247.5
							MOVDQU xmm6,xmm7 			; xmm6 = [247.5|247.5|247.5|247.5]
							ADDPS xmm7,xmm13 			; xmm7 = [292.5|292.5|292.5|292.5]
							MOVDQU xmm4,xmm7  			; xmm4 = [292.5|292.5|292.5|292.5]
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]
						
							CMPPS xmm4,xmm2,2 			; CMPLEPS xmm4,xmm2   -->  xmm4 <= xmm2 (Los que son mayores o iguales a 292.5 están con 1's)
							PXOR xmm4,xmm5 				; Los que son menores a 292.5 están con 1's. (HAGO UN NOT CASERO)
							
							MOVDQU xmm5,xmm6			; xmm5 = [247.5|247.5|247.5|247.5]
							CMPPS xmm5,xmm2,2 			; CMPLEPS xmm5,xmm2   --> xmm5 <= xmm2 (Los que son mayores o iguales a 247.5 están con 1's)

							PAND xmm4,xmm5    			;Escribo solo aquellos que cumplan ambas condiciones
							POR xmm10,xmm4 				; Guardo el resultado en xmm10 (valor 150)

						;Menor a 337.5, Mayor a 292.5
							MOVDQU xmm6,xmm7 			; xmm6 = [292.5|292.5|292.5|292.5]
							ADDPS xmm7,xmm13 			; xmm7 = [337.5|337.5|337.5|337.5]
							MOVDQU xmm4,xmm7  			; xmm4 = [337.5|337.5|337.5|337.5]
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]					

							CMPPS xmm4,xmm2,2 			; CMPLEPS xmm4,xmm2   -->  xmm4 <= xmm2 (Los que son mayores o iguales a 337.5 están con 1's)
							PXOR xmm4,xmm5 				; Los que son menores a 337.5 están con 1's. (HAGO UN NOT CASERO)
							
							MOVDQU xmm5,xmm6			; xmm5 = [292.5|292.5|292.5|292.5]
							CMPPS xmm5,xmm2,2 			; CMPLEPS xmm5,xmm2   --> xmm5 <= xmm2 (Los que son mayores o iguales a 292.5 están con 1's)

							PAND xmm4,xmm5    			;Escribo solo aquellos que cumplan ambas condiciones
							POR xmm11,xmm4 				; Guardo el resultado en xmm11 (valor 200)


						;Menor a 360, Mayor a 337.5
							MOVDQU xmm6,xmm7 			; xmm6 = [337.5|337.5|337.5|337.5]
							ADDPS xmm7,xmm12			; xmm7 = [360|360|360|360]
							MOVDQU xmm4,xmm7  			; xmm4 = [360|360|360|360]
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]
						

							CMPPS xmm4,xmm2,2 			; CMPLEPS xmm4,xmm2   -->  xmm4 <= xmm2 (Los que son mayores o iguales a 360 están con 1's)
							PXOR xmm4,xmm5 				; Los que son menores a 360 están con 1's. (HAGO UN NOT CASERO)
							MOVDQU xmm5,xmm6			; xmm5 = [337.5|337.5|337.5|337.5]


							CMPPS xmm5,xmm2,2 			; CMPLEPS xmm5,xmm2   --> xmm5 <= xmm2 (Los que son mayores o iguales a 337.5 están con 1's)

							PAND xmm4,xmm5    			;Escribo solo aquellos que cumplan ambas condiciones
							POR xmm11,xmm4 				; Guardo el resultado en xmm11 (valor 200)


						;Terminamos y escribimos el resultado en xmm2
						MOVDQU xmm4, xmm14 ; xmm4 = [50|50|50|50]
						PAND xmm8,xmm4     ; xmm8 tiene solo 50 en los que xmm8 habia unos

						ADDPS xmm4,xmm14   ; xmm4 = [100|100|100|100]
						PAND xmm9,xmm4 	   ; xmm9 tiene solo 100 en los que xmm8 habia unos

						ADDPS xmm4,xmm14   ; xmm4 = [150|150|150|150]
						PAND xmm10,xmm4    ; xmm10 tiene solo 150 en los que xmm8 habia unos

						ADDPS xmm4,xmm14   ; xmm4 = [200|200|200|200]
						PAND xmm11,xmm4    ; xmm10 tiene solo 200 en los que xmm8 habia unos


						POR xmm8,xmm9
						POR xmm10,xmm11
						POR xmm8,xmm10
						MOVDQU xmm2,xmm8 
					;---------------------PARA XMM2 ----------------------------------








					;---------------------PARA XMM3 ----------------------------------
						;Limpio los registros "acumuladores"
						PXOR xmm8,xmm8
						PXOR xmm9,xmm9
						PXOR xmm10,xmm10
						PXOR xmm11,xmm11

						MOVDQU xmm7, xmm12 			; xmm7 = [22.5|22.5|22.5|22.5]
						PXOR xmm6,xmm6				; xmm6 = [0|0|0|0]
						MOVDQU xmm13,xmm7			; xmm13 = [22.5|22.5|22.5|22.5]
						ADDPS xmm13,xmm12           ; xmm13 = [45|45|45|45]
						

						;Menor a 22.5
							PXOR xmm5,xmm5      		; xmm5 = [0|0|..|0]
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]

							MOVDQU xmm4,xmm7			; xmm4 = [22.5|22.5|22.5|22.5]

							CMPPS xmm4,xmm3,2 			; CMPLEPS xmm4,xmm3   -->  xmm4 <= xmm3 (Los que son mayores o iguales a 22.5 están con 1's)
							PXOR xmm4,xmm5 				; Los que son menores a 22.5 están con 1's. (HAGO UN NOT CASERO)

							MOVDQU xmm5,xmm6

							CMPPS xmm5, xmm0, 2         ; Los que son mayores o iguales a 0 estan con 1's

							PAND xmm4,xmm5 
							POR xmm8,xmm4 				; Guardo el resultado en xmm8 (valor 50)

						;Menor a 67.5 , Mayor  a 22.5
							MOVDQU xmm6,xmm7 			; xmm6 = [22.5|22.5|22.5|22.5]
							ADDPS xmm7,xmm13 			; xmm7 = [67.5|67.5|67.5|67.5]
							MOVDQU xmm4,xmm7  			; xmm4 = [67.5|67.5|67.5|67.5]
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]

							CMPPS xmm4,xmm3,2 			; CMPLEPS xmm4,xmm3   -->  xmm4 <= xmm3 (Los que son mayores o iguales a 67.5 están con 1's)
							PXOR xmm4,xmm5 				; Los que son menores a 67.5 están con 1's. (HAGO UN NOT CASERO)

							MOVDQU xmm5,xmm6			; xmm5 = [22.5|22.5|22.5|22.5]

							CMPPS xmm5,xmm3,2 			; CMPLEPS xmm5,xmm3   --> xmm5 <= xmm3 (Los que son mayores o iguales a 22.5 están con 1's)

							PAND xmm4,xmm5    			;Escribo solo aquellos que cumplan ambas condiciones
							POR xmm9,xmm4 				; Guardo el resultado en xmm9 (valor 100)

						;Menor a 112.5, Mayor a 67.5
							MOVDQU xmm6,xmm7 			; xmm6 = [67.5|67.5|67.5|67.5]
							ADDPS xmm7,xmm13 			; xmm7 = [112.5|112.5|112.5|112.5]
							MOVDQU xmm4,xmm7  			; xmm4 = [112.5|112.5|112.5|112.5]
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]


							CMPPS xmm4,xmm3,2 			; CMPLEPS xmm4,xmm3   -->  xmm4 <= xmm3 (Los que son mayores o iguales a 112.5 están con 1's)
							PXOR xmm4,xmm5	 			; Los que son menores a 112.5 están con 1's. (HAGO UN NOT CASERO)
							MOVDQU xmm5,xmm6			; xmm5 = [67.5|67.5|67.5|67.5]

							CMPPS xmm5,xmm3,2 			; CMPLEPS xmm5,xmm3   --> xmm5 <= xmm3 (Los que son mayores o iguales a 67.5 están con 1's)

							PAND xmm4,xmm5    			;Escribo solo aquellos que cumplan ambas condiciones
							POR xmm10,xmm4 				; Guardo el resultado en xmm10 (valor 150)

						;Menor a 157.5, Mayor a 112.5
							MOVDQU xmm6,xmm7 			; xmm6 = [112.5|112.5|112.5|112.5]
							ADDPS xmm7,xmm13 			; xmm7 = [157.5|157.5|157.5|157.5]
							MOVDQU xmm4,xmm7  			; xmm4 = [157.5|157.5|157.5|157.5]
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]
						
							CMPPS xmm4,xmm3,2 			; CMPLEPS xmm4,xmm3   -->  xmm4 <= xmm3 (Los que son mayores o iguales a 157.5 están con 1's)
							PXOR xmm4,xmm5  			; Los que son menores a 157.5 están con 1's. (HAGO UN NOT CASERO)

							MOVDQU xmm5,xmm6			; xmm5 = [112.5|112.5|112.5|112.5]
							CMPPS xmm5,xmm3,2 			; CMPLEPS xmm5,xmm3   --> xmm5 <= xmm3 (Los que son mayores o iguales a 112.5 están con 1's)

							PAND xmm4,xmm5    			;Escribo solo aquellos que cumplan ambas condiciones
							POR xmm11,xmm4 				; Guardo el resultado en xmm11 (valor 200)
						

						;Menor a 202.5, Mayor a 157.5
							MOVDQU xmm6,xmm7 			; xmm6 = [157.5|157.5|157.5|157.5]
							ADDPS xmm7,xmm13 			; xmm7 = [202.5|202.5|202.5|202.5]
							MOVDQU xmm4,xmm7  			; xmm4 = [202.5|202.5|202.5|202.5]
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]
						
							CMPPS xmm4,xmm3,2 			; CMPLEPS xmm4,xmm3   -->  xmm4 <= xmm3 (Los que son mayores o iguales a 202.5 están con 1's)
							PXOR xmm4,xmm5 				; Los que son menores a 202.5 están con 1's. (HAGO UN NOT CASERO)

							MOVDQU xmm5,xmm6			; xmm5 = [157.5|157.5|157.5|157.5]
							CMPPS xmm5,xmm3,2 			; CMPLEPS xmm5,xmm3   --> xmm5 <= xmm3 (Los que son mayores o iguales a 157.5 están con 1's)

							PAND xmm4,xmm5    			;Escribo solo aquellos que cumplan ambas condiciones
							POR xmm8,xmm4 				; Guardo el resultado en xmm8 (valor 50)


						;Menor a 247.5, Mayor a 202.5
							MOVDQU xmm6,xmm7 			; xmm6 = [202.5|202.5|202.5|202.5]
							ADDPS xmm7,xmm13 			; xmm7 = [247.5|247.5|247.5|247.5]
							MOVDQU xmm4,xmm7  			; xmm4 = [247.5|247.5|247.5|247.5]
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]
						
							CMPPS xmm4,xmm3,2 			; CMPLEPS xmm4,xmm3   -->  xmm4 <= xmm3 (Los que son mayores o iguales a 247.5 están con 1's)
							PXOR xmm4,xmm5 			    ; Los que son menores a 247.5 están con 1's. (HAGO UN NOT CASERO)

							MOVDQU xmm5,xmm6			; xmm5 = [202.5|202.5|202.5|202.5]
							CMPPS xmm5,xmm3,2 			; CMPLEPS xmm5,xmm3   --> xmm5 <= xmm3 (Los que son mayores o iguales a 202.5 están con 1's)

							PAND xmm4,xmm5    			;Escribo solo aquellos que cumplan ambas condiciones
							POR xmm9,xmm4 				; Guardo el resultado en xmm9 (valor 100)

						;Menor a 292.5, Mayor a 247.5
							MOVDQU xmm6,xmm7 			; xmm6 = [247.5|247.5|247.5|247.5]
							ADDPS xmm7,xmm13 			; xmm7 = [292.5|292.5|292.5|292.5]
							MOVDQU xmm4,xmm7  			; xmm4 = [292.5|292.5|292.5|292.5]
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]
						
							CMPPS xmm4,xmm3,2 			; CMPLEPS xmm4,xmm3   -->  xmm4 <= xmm3 (Los que son mayores o iguales a 292.5 están con 1's)
							PXOR xmm4,xmm5 				; Los que son menores a 292.5 están con 1's. (HAGO UN NOT CASERO)
							
							MOVDQU xmm5,xmm6			; xmm5 = [247.5|247.5|247.5|247.5]
							CMPPS xmm5,xmm3,2 			; CMPLEPS xmm5,xmm3   --> xmm5 <= xmm3 (Los que son mayores o iguales a 247.5 están con 1's)

							PAND xmm4,xmm5    			;Escribo solo aquellos que cumplan ambas condiciones
							POR xmm10,xmm4 				; Guardo el resultado en xmm10 (valor 150)

						;Menor a 337.5, Mayor a 292.5
							MOVDQU xmm6,xmm7 			; xmm6 = [292.5|292.5|292.5|292.5]
							ADDPS xmm7,xmm13 			; xmm7 = [337.5|337.5|337.5|337.5]
							MOVDQU xmm4,xmm7  			; xmm4 = [337.5|337.5|337.5|337.5]
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]					

							CMPPS xmm4,xmm3,2 			; CMPLEPS xmm4,xmm3   -->  xmm4 <= xmm3 (Los que son mayores o iguales a 337.5 están con 1's)
							PXOR xmm4,xmm5 				; Los que son menores a 337.5 están con 1's. (HAGO UN NOT CASERO)
							
							MOVDQU xmm5,xmm6			; xmm5 = [292.5|292.5|292.5|292.5]
							CMPPS xmm5,xmm3,2 			; CMPLEPS xmm5,xmm3   --> xmm5 <= xmm3 (Los que son mayores o iguales a 292.5 están con 1's)

							PAND xmm4,xmm5    			;Escribo solo aquellos que cumplan ambas condiciones
							POR xmm11,xmm4 				; Guardo el resultado en xmm11 (valor 200)


						;Menor a 360, Mayor a 337.5
							MOVDQU xmm6,xmm7 			; xmm6 = [337.5|337.5|337.5|337.5]
							ADDPS xmm7,xmm12 			; xmm7 = [360|360|360|360]
							MOVDQU xmm4,xmm7  			; xmm4 = [360|360|360|360]
							PCMPEQQ xmm5,xmm5 			; xmm5 = [1|1|..|1]
						

							CMPPS xmm4,xmm3,2 			; CMPLEPS xmm4,xmm3   -->  xmm4 <= xmm3 (Los que son mayores o iguales a 360 están con 1's)
							PXOR xmm4,xmm5 				; Los que son menores a 360 están con 1's. (HAGO UN NOT CASERO)
							MOVDQU xmm5,xmm6			; xmm5 = [337.5|337.5|337.5|337.5]


							CMPPS xmm5,xmm3,2 			; CMPLEPS xmm5,xmm3   --> xmm5 <= xmm3 (Los que son mayores o iguales a 337.5 están con 1's)

							PAND xmm4,xmm5    			;Escribo solo aquellos que cumplan ambas condiciones
							POR xmm11,xmm4 				; Guardo el resultado en xmm11 (valor 200)


						;Terminamos y escribimos el resultado en xmm3
						MOVDQU xmm4, xmm14 ; xmm4 = [50|50|50|50]
						PAND xmm8,xmm4     ; xmm8 tiene solo 50 en los que xmm8 habia unos

						ADDPS xmm4,xmm14   ; xmm4 = [100|100|100|100]
						PAND xmm9,xmm4 	   ; xmm9 tiene solo 100 en los que xmm8 habia unos

						ADDPS xmm4,xmm14   ; xmm4 = [150|150|150|150]
						PAND xmm10,xmm4    ; xmm10 tiene solo 150 en los que xmm8 habia unos

						ADDPS xmm4,xmm14   ; xmm4 = [200|200|200|200]
						PAND xmm11,xmm4    ; xmm10 tiene solo 200 en los que xmm8 habia unos


						POR xmm8,xmm9
						POR xmm10,xmm11
						POR xmm8,xmm10
						MOVDQU xmm3,xmm8 
					;---------------------PARA XMM3 ----------------------------------





	

					;----------------------------------------------------------------------------------------------------------------	
					; 				Resumen  
					;				 xmm0 = [ang_sobel(M10)|ang_sobel(M9)|ang_sobel(M8)|ang_sobel(M7)] 		
					;				 xmm1 = [Basura|Basura|ang_sobel(M2)|ang_sobel(M1)]						
					;				 xmm2 = [ang_sobel(M14)|ang_sobel(M13)|ang_sobel(M12)|ang_sobel(M11)]	
					;				 xmm3 = [ang_sobel(M6)|ang_sobel(M5)|ang_sobel(M4)|ang_sobel(M3)]		
					;			 	 xmm4 = LIBRE
					;			 	 xmm5 = LIBRE   
					;			 	 xmm6 = LIBRE   
					;				 xmm7 = LIBRE   
					;				 xmm8 = LIBRE   
					;				 xmm9 = LIBRE   
					;				 xmm10 = LIBRE  
					;				 xmm11 = LIBRE  
					;				 xmm12 = [22.5|22.5|22.5|22.5]
					;				 xmm13 = LIBRE  
					;				 xmm14 = [50|50|50|50]
					;				 xmm15 = [pi/2|pi/2|pi/2|pi/2]
					;
					;----------------------------------------------------------------------------------------------------------------
				




				;Volvemos a enteros (Double words)					
				 CVTPS2DQ xmm2,xmm2				; xmm2 = xmm2 = [ang_sobel(M14)|...|ang_sobel(M11)]
				 CVTPS2DQ xmm0,xmm0				; xmm0 = xmm0 = [ang_sobel(M10)|...|ang_sobel(M7)]  
				 CVTPS2DQ xmm3,xmm3				; xmm3 = xmm3 = [ang_sobel(M6)|...|ang_sobel(M3)] 
			     CVTPS2DQ xmm1,xmm1				; xmm1 = xmm1 = [ang_sobel(M2)|ang_sobel(M1)|0|0]
				 
				
				
				;Volvemos a words					
				PACKSSDW  xmm2,xmm0 			; xmm2 = [ang_sobel(M14)|...|ang_sobel(M11)|ang_sobel(M10)|...|ang_sobel(M7) ]
				PACKSSDW  xmm3, xmm1 			; xmm3 = [ang_sobel(M6)|...|ang_sobel(M3)|ang_sobel(M2)|ang_sobel(M1)|Basura|Basura]

		
				;Volvemos a bytes							
				PACKUSWB xmm2,xmm3 				; xmm2 = [ang_sobel(M14)| .. |ang_sobel(M1)|Basura|Basura]







		;Escritura en memoria
				CMP r12,18    			; Me fijo si es la última escritura de la fila o no.
				JE ultimaEscritura



				MOVDQU [r13], xmm2 		; Si no es la última escritura, entonces escribo los 16 bytes.
				ADD r14, 14				; Aumento 14 ya que es la cantidad de píxeles que procesamos a la vez.
				ADD r15, 14	
				ADD r13, 14			
				SUB r12, 14      		; Resto las 14 columnas ya procesadas. 
				JMP cicloPorColumnas
				
				
				ultimaEscritura:
					MOVQ [r13], xmm2		; Escribe los primeros 8 bytes en memoria.
					PSRLDQ xmm2, 8			
					MOVD [r13+8], xmm2 		; Escribe los siguientes 4 bytes en memoria.
					MOV WORD [r13+12], 0	; Escribe los siguientes 2 bytes en memoria.
					MOV BYTE [r13+14], 0	; Escribe en memoria 0 para completar los 3 bores de ceros. 
					MOV WORD [r13+15], 0	; Escribe en memoria 0 para completar los 3 bores de ceros. 
					JMP cambiarDeFila


				redimensionar: 
						MOV r11, 18		 	; Hago esto para retroceder (18-r12d) para atrás que es lo que necesito que retrocedan los iteradores para poder hacer la última escritura.
						SUB r11, r12 		
						SUB r14, r11    	
						SUB r15, r11
						SUB r13, r11   
						MOV r12, 18   
						JMP cicloPorColumnas


				cambiarDeFila:
						LEA rdi, [rdi + r8]			; Muevo los punteros de las imágenes al primero de la segunda fila sumandole el row_size correspondiente a cada uno.
						LEA rsi, [rsi + r9]		
						LEA rax, [rax + r9]	
						DEC edx						; Decremento una fila
						JMP cicloPorFilas





	;Opero con la última fila
	parteFinal:


	PXOR xmm0,xmm0     			;Para escribir 0's en los bordes			
	
	ultimas3Filas:
		CMP edx, 3 ; 
		JE salir

		MOV r15, rsi
		MOV r13, rax 				;Guardo el puntero al destino en r11 (para usarlo de iterador de la última fila).		
		MOV r12, rcx				;Guardo en r12, la cantidad de columnas para poder comparar contra 0 cuando termine de iterar toda la fila.
	
		cicloUltimasFilas: 
			CMP r12,0 					
			JE cambiarUltimasFilas
			CMP r12,16 					;Para redimensionar
			JL redimensionUltimas3Filas
			MOVDQU [r15], xmm0 			;Escribo 16 bytes de  0 en la posición de memoria apuntada por el iterador
			MOVDQU [r13], xmm0 		    ;Escribo 16 bytes de  0 en la posición de memoria apuntada por el iterador
			ADD r15, 16 				;Aumento el iterador
			ADD r13, 16 				;Aumento el iterador
			SUB r12, 16					;Disminuyo la cantidad de columnas que me faltan recorrer
			JMP cicloUltimasFilas

		cambiarUltimasFilas: 
			LEA rdi, [rdi + r8]			; Muevo los punteros de las imágenes al primero de la segunda fila sumandole el row_size correspondiente a cada uno.
			LEA rsi, [rsi + r9]			
			LEA rax, [rax + r9]
			DEC edx						; Decremento una fila
			JMP ultimas3Filas



 	redimensionUltimas3Filas:
 		MOV r14, 16		 		; Hago esto para retroceder (16-r12d) para atrás que es lo que necesito que retrocedan los iteradores para poder hacer la última escritura.
		SUB r14, r12 		
		SUB r15, r14    	
		SUB r13, r14
		SUB r12, r14   
		JMP cicloUltimasFilas



	salir:
	POP r12
	POP r13
	POP r14
	POP r15
	ADD rsp,16;
	POP rbp

	RET















	


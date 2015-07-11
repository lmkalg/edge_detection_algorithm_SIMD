
global smoothing_asm

section .data
smooth1: DB 0x2, 0x4, 0x5, 0x4, 0x2, 0x2, 0x4, 0x5, 0x4, 0x2, 0x2, 0x4, 0x5, 0x4, 0x2, 0x0
smooth2: DB 0x4, 0x9, 0xC, 0x9, 0x4, 0x4, 0x9, 0xC, 0x9, 0x4, 0x4, 0x9, 0xC, 0x9, 0x4, 0x0
smooth3: DB 0x5, 0xC, 0xF, 0xC, 0x5, 0x5, 0xC, 0xF, 0xC, 0x5, 0x5, 0xC, 0xF, 0xC, 0x5, 0x0
mask159s: DD 0x9F, 0x9F, 0x9F, 0x9F

mask50: DB 0x32, 0x32, 0x32, 0x32, 0x32, 0x32, 0x32, 0x32, 0x32, 0x32, 0x32, 0x32, 0x32, 0x32, 0x32, 0x32
mask100: DB 0x64, 0x64, 0x64, 0x64, 0x64, 0x64, 0x64, 0x64, 0x64, 0x64, 0x64, 0x64, 0x64, 0x64, 0x64, 0x64
mask150: DB 0x96, 0x96, 0x96, 0x96, 0x96, 0x96, 0x96, 0x96, 0x96, 0x96, 0x96, 0x96, 0x96, 0x96, 0x96, 0x96
mask200: DB 0xC8, 0xC8, 0xC8, 0xC8, 0xC8, 0xC8, 0xC8, 0xC8, 0xC8, 0xC8, 0xC8, 0xC8, 0xC8, 0xC8, 0xC8, 0xC8


section .text
smoothing_asm:
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

	;rdx --> filas
	;rcx --> columnas
	;r8  --> src_row_size
	;r9  --> dst_row_size
	
	; Inicialmente pinta las dos primeras filas de negro
	MOV r11, rcx					; mueve la cantidad de columnas a r11
	MOV r14, rdi					; mueve a r14 el puntero al primero de la fila
	MOV r13, rsi					; mueve a r13 el puntero al dst
	
	
	PXOR xmm0, xmm0				; limpia xmm0
	.primeraFila:
		CMP r11, 0					; compara para ver si ya miró todas las columnas
		JE .pasaASegunda
		CMP r11, 16					; compara para ver si queda un tamaño menor al de procesado (16 en este caso)
		JL .actualizarFinalNegroPrimera
		MOVDQU [r13], xmm0			; imprime en memoria todo 0's
		ADD r13, 16					; adelanta el puntero a destino 16 bytes
		SUB r11, 16					; disminuye la cantidad de columnas por procesar
		JMP .primeraFila

	.pasaASegunda:
		MOV r11, rcx					; mueve la cantidad de columnas a r11
		ADD rsi, r9					; pasa destino a la siguiente fila
		MOV r13, rsi				; pone en r13 al destino
	.segundaFila:
		CMP r11, 0					; compara para ver si ya miró todas las columnas
		JE .parteCentral
		CMP r11, 16					; compara para ver si queda un tamaño menor al de procesado (16 en este caso)
		JL .actualizarFinalNegroSegunda
		MOVDQU [r13], xmm0			; imprime en memoria todo 0's
		ADD r13, 16					; adelanta el puntero a destino 16 bytes
		SUB r11, 16					; disminuye la cantidad de columnas por procesar
		JMP .segundaFila	


	.parteCentral:
		ADD rsi, r9						; pasa destino a la siguiente fila
		ADD rdi, r8						; pasa source a la siguiente fila
		ADD rdi, r8						; pasa source a la siguiente fila

		; escribe los primeros dos píxeles de esa fila con negro
		MOV byte [rsi], 0
		INC rsi
		MOV byte [rsi], 0
		INC rsi							; rsi queda posicionado donde corresponde

	.cicloPorFila:
		MOV r11, rcx					; mueve la cantidad de columnas a r11
		MOV r14, rdi					; mueve a r14 el puntero al primero de la fila
		MOV r13, rsi					; mueve a r13 el puntero al dst



		CMP edx, 4						; para ver si terminó de ciclar todas las filas (compara con 2 pues las últimas dos no hay que procesarlas)
		JE .final



		.cicloPorColumna:
			CMP r11, 4					; compara para ver si ya miró todas las columnas
			JE .cambiarDeFila
			CMP r11, 16					; compara para ver si queda un tamaño menor al de procesado (16 en este caso)
			JL .actualizarFinal
		

			MOV r15, r14					; coloca en r15 el puntero a source
			MOVDQU xmm3, [r15]				; carga en xmm3 la fila central
			SUB r15, r8						; le resta al puntero una fila
			MOVDQU xmm2, [r15]				; carga en xmm2 la segunda fila
			SUB r15, r8						; le resta al puntero una fila
			MOVDQU xmm1, [r15]				; carga en xmm1 la primera fila
			MOV r15, r14					; coloca en r15 el puntero a source
			ADD r15, r8						; le suma al puntero una fila
			MOVDQU xmm4, [r15]				; carga en xmm4 la cuarta fila
			ADD r15, r8						; le suma al puntero una fila
			MOVDQU xmm5, [r15]				; carga en xmm5 la quinta fila
			
			; se tiene
			; xmm1: primera fila	f1_15 | f1_14 | f1_13 | f1_12 | f1_11 | f1_10 | f1_9 | f1_8 | f1_7 | f1_6 | f1_5 | f1_4 | f1_3 | f1_2 | f1_1 | f1_0
			; xmm2: segunda fila	f2_15 | f2_14 | f2_13 | f2_12 | f2_11 | f2_10 | f2_9 | f2_8 | f2_7 | f2_6 | f2_5 | f2_4 | f2_3 | f2_2 | f2_1 | f2_0
			; xmm3: tercera fila	f3_15 | f3_14 | f3_13 | f3_12 | f3_11 | f3_10 | f3_9 | f3_8 | f3_7 | f3_6 | f3_5 | f3_4 | f3_3 | f3_2 | f3_1 | f3_0
			; xmm4: cuarta fila		f4_15 | f4_14 | f4_13 | f4_12 | f4_11 | f4_10 | f4_9 | f4_8 | f4_7 | f4_6 | f4_5 | f4_4 | f4_3 | f4_2 | f4_1 | f4_0
			; xmm5: quinta fila		f5_15 | f5_14 | f5_13 | f5_12 | f5_11 | f5_10 | f5_9 | f5_8 | f5_7 | f5_6 | f5_5 | f5_4 | f5_3 | f5_2 | f5_1 | f5_0
			
			PXOR xmm15, xmm15			; se lo va a usar para poner el resultado parcial mientras tanto
			
			; Posiciones de procesado:
			; X    X    P12    P11    P10    P9    P8    P7    P6    P5    P4   P3   P2   P1    X    X
			
			; Se procesan la 1, la 6 y la 11
			
				; PRIMEROS CUATRO
				
				MOVDQU xmm6, xmm1				; pone en xmm6 la primer fila
				PUNPCKLBW xmm6, xmm0			; deja en xmm6 la parte baja de la primer fila
				MOVDQU xmm7, xmm2				; pone en xmm7 la segunda fila
				PUNPCKLBW xmm7, xmm0			; deja en xmm7 la parte baja de la segunda fila
				MOVDQU xmm8, xmm3				; pone en xmm8 la tercera fila
				PUNPCKLBW xmm8, xmm0			; deja en xmm8 la parte baja de la tercera fila
				MOVDQU xmm9, xmm4				; pone en xmm9 la cuarta fila
				PUNPCKLBW xmm9, xmm0			; deja en xmm9 la parte baja de la cuarta fila
				MOVDQU xmm10, xmm5				; pone en xmm10 la quinta fila
				PUNPCKLBW xmm10, xmm0			; deja en xmm10 la parte baja de la quinta fila
				
				; se tiene
				; xmm6:  f1_7 | f1_6 | f1_5 | f1_4 | f1_3 | f1_2 | f1_1 | f1_0
				; xmm7:  f2_7 | f2_6 | f2_5 | f2_4 | f2_3 | f2_2 | f2_1 | f2_0
				; xmm8:  f3_7 | f3_6 | f3_5 | f3_4 | f3_3 | f3_2 | f3_1 | f3_0
				; xmm9:  f4_7 | f4_6 | f4_5 | f4_4 | f4_3 | f4_2 | f4_1 | f4_0
				; xmm10: f5_7 | f5_6 | f5_5 | f5_4 | f5_3 | f5_2 | f5_1 | f5_0
				
				PUNPCKLWD xmm6, xmm0			; deja en xmm6 la parte baja de la baja de la primer fila
				PUNPCKLWD xmm7, xmm0			; deja en xmm7 la parte baja de la baja de la segunda fila
				PUNPCKLWD xmm8, xmm0			; deja en xmm8 la parte baja de la baja de la tercera fila
				PUNPCKLWD xmm9, xmm0			; deja en xmm9 la parte baja de la baja de la cuarta fila
				PUNPCKLWD xmm10, xmm0			; deja en xmm10 la parte baja de la baja de la quinta fila
				
				; se tiene
				; xmm6:  f1_3 | f1_2 | f1_1 | f1_0
				; xmm7:  f2_3 | f2_2 | f2_1 | f2_0
				; xmm8:  f3_3 | f3_2 | f3_1 | f3_0
				; xmm9:  f4_3 | f4_2 | f4_1 | f4_0
				; xmm10: f5_3 | f5_2 | f5_1 | f5_0
				
				CVTDQ2PS xmm6, xmm6				; pasa los valores a float
				CVTDQ2PS xmm7, xmm7				; pasa los valores a float
				CVTDQ2PS xmm8, xmm8				; pasa los valores a float
				CVTDQ2PS xmm9, xmm9				; pasa los valores a float
				CVTDQ2PS xmm10, xmm10			; pasa los valores a float
				
				; obtiene las partes de las máscaras que se usan
				MOVDQU xmm11, [smooth1]		; pone en xmm11: 0,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2
				PUNPCKLBW xmm11, xmm0		; desempaqueta entonces xmm11: 5,  4,  2,  2,  4,  5,  4,  2
				PUNPCKLWD xmm11, xmm0		; desempaqueta entonces xmm11: 4,  5,  4,  2
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm6 como a xmm10
				MULPS xmm6, xmm11
				MULPS xmm10, xmm11
				
				MOVDQU xmm11, [smooth2]		; pone en xmm11: 0,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4
				PUNPCKLBW xmm11, xmm0		; desempaqueta entonces xmm11: 12,  9,  4,  4,  9, 12,  9,  4
				PUNPCKLWD xmm11, xmm0		; desempaqueta entonces xmm11: 9, 12,  9,  4
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm7 como a xmm9
				MULPS xmm7, xmm11
				MULPS xmm9, xmm11
				
				MOVDQU xmm11, [smooth3]		; pone en xmm11: 0,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5
				PUNPCKLBW xmm11, xmm0		; desempaqueta entonces xmm11: 15, 12,  5,  5, 12, 15, 12,  5
				PUNPCKLWD xmm11, xmm0		; desempaqueta entonces xmm11: 12, 15, 12,  5
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara sólo se aplica a xmm8
				MULPS xmm8, xmm11
				
				; suma todo lo calculado
				ADDPS xmm6, xmm7
				ADDPS xmm6, xmm8
				ADDPS xmm6, xmm9
				ADDPS xmm6, xmm10
				; se tiene xmm6: f1_3*4 + f2_3*9 + f3_3*12 + f4_3*9 + f5_3*4 | f1_2*5 + f2_2*12 + f3_2*15 + f4_2*12 + f5_2*5 | f1_1*4 + f2_1*9 + f3_1*12 + f4_1*9 + f5_1*4 | f1_0*2 + f2_0*4 + f3_0*5 + f4_0*4 + f5_0*2
				MOVDQU xmm14, xmm6			; guarda el resultado en xmm14
			
			
			
			
				; SEGUNDOS CUATRO
				
				MOVDQU xmm6, xmm1				; pone en xmm6 la primer fila
				PUNPCKLBW xmm6, xmm0			; deja en xmm6 la parte baja de la primer fila
				MOVDQU xmm7, xmm2				; pone en xmm7 la segunda fila
				PUNPCKLBW xmm7, xmm0			; deja en xmm7 la parte baja de la segunda fila
				MOVDQU xmm8, xmm3				; pone en xmm8 la tercera fila
				PUNPCKLBW xmm8, xmm0			; deja en xmm8 la parte baja de la tercera fila
				MOVDQU xmm9, xmm4				; pone en xmm9 la cuarta fila
				PUNPCKLBW xmm9, xmm0			; deja en xmm9 la parte baja de la cuarta fila
				MOVDQU xmm10, xmm5				; pone en xmm10 la quinta fila
				PUNPCKLBW xmm10, xmm0			; deja en xmm10 la parte baja de la quinta fila
				
				; se tiene
				; xmm6:  f1_7 | f1_6 | f1_5 | f1_4 | f1_3 | f1_2 | f1_1 | f1_0
				; xmm7:  f2_7 | f2_6 | f2_5 | f2_4 | f2_3 | f2_2 | f2_1 | f2_0
				; xmm8:  f3_7 | f3_6 | f3_5 | f3_4 | f3_3 | f3_2 | f3_1 | f3_0
				; xmm9:  f4_7 | f4_6 | f4_5 | f4_4 | f4_3 | f4_2 | f4_1 | f4_0
				; xmm10: f5_7 | f5_6 | f5_5 | f5_4 | f5_3 | f5_2 | f5_1 | f5_0
				
				PUNPCKHWD xmm6, xmm0			; deja en xmm6 la parte alta de la baja de la primer fila
				PUNPCKHWD xmm7, xmm0			; deja en xmm7 la parte alta de la baja de la segunda fila
				PUNPCKHWD xmm8, xmm0			; deja en xmm8 la parte alta de la baja de la tercera fila
				PUNPCKHWD xmm9, xmm0			; deja en xmm9 la parte alta de la baja de la cuarta fila
				PUNPCKHWD xmm10, xmm0			; deja en xmm10 la parte alta de la baja de la quinta fila
				
				; se tiene
				; xmm6:  f1_7 | f1_6 | f1_5 | f1_4
				; xmm7:  f2_7 | f2_6 | f2_5 | f2_4
				; xmm8:  f3_7 | f3_6 | f3_5 | f3_4
				; xmm9:  f4_7 | f4_6 | f4_5 | f4_4
				; xmm10: f5_7 | f5_6 | f5_5 | f5_4
				
				CVTDQ2PS xmm6, xmm6				; pasa los valores a float
				CVTDQ2PS xmm7, xmm7				; pasa los valores a float
				CVTDQ2PS xmm8, xmm8				; pasa los valores a float
				CVTDQ2PS xmm9, xmm9				; pasa los valores a float
				CVTDQ2PS xmm10, xmm10			; pasa los valores a float
				
				; obtiene las partes de las máscaras que se usan
				MOVDQU xmm11, [smooth1]		; pone en xmm11: 0,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2
				PUNPCKLBW xmm11, xmm0		; desempaqueta entonces xmm11: 5,  4,  2,  2,  4,  5,  4,  2
				PUNPCKHWD xmm11, xmm0		; desempaqueta entonces xmm11: 5,  4,  2,  2
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm6 como a xmm10
				MULPS xmm6, xmm11
				MULPS xmm10, xmm11
				
				MOVDQU xmm11, [smooth2]		; pone en xmm11: 0,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4
				PUNPCKLBW xmm11, xmm0		; desempaqueta entonces xmm11: 12,  9,  4,  4,  9, 12,  9,  4
				PUNPCKHWD xmm11, xmm0		; desempaqueta entonces xmm11: 12,  9,  4,  4
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm7 como a xmm9
				MULPS xmm7, xmm11
				MULPS xmm9, xmm11
				
				MOVDQU xmm11, [smooth3]		; pone en xmm11: 0,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5
				PUNPCKLBW xmm11, xmm0		; desempaqueta entonces xmm11: 15, 12,  5,  5, 12, 15, 12,  5
				PUNPCKHWD xmm11, xmm0		; desempaqueta entonces xmm11: 15, 12,  5,  5
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara sólo se aplica a xmm8
				MULPS xmm8, xmm11
				
				; suma todo lo calculado
				ADDPS xmm6, xmm7
				ADDPS xmm6, xmm8
				ADDPS xmm6, xmm9
				ADDPS xmm6, xmm10
				; se tiene xmm6: f1_7*5 + f2_7*12 + f3_7*15 + f4_7*12 + f5_7*5 | f1_6*4 + f2_6*9 + f3_6*12 + f4_6*9 + f5_6*4 | f1_5*2 + f2_5*4 + f3_5*5 + f4_5*4 + f5_5*2 | f1_4*2 + f2_4*4 + f3_4*5 + f4_4*4 + f5_4*2
				MOVDQU xmm13, xmm6			; guarda el resultado en xmm13




				; TERCEROS CUATRO
				
				MOVDQU xmm6, xmm1				; pone en xmm6 la primer fila
				PUNPCKHBW xmm6, xmm0			; deja en xmm6 la parte alta de la primer fila
				MOVDQU xmm7, xmm2				; pone en xmm7 la segunda fila
				PUNPCKHBW xmm7, xmm0			; deja en xmm7 la parte alta de la segunda fila
				MOVDQU xmm8, xmm3				; pone en xmm8 la tercera fila
				PUNPCKHBW xmm8, xmm0			; deja en xmm8 la parte alta de la tercera fila
				MOVDQU xmm9, xmm4				; pone en xmm9 la cuarta fila
				PUNPCKHBW xmm9, xmm0			; deja en xmm9 la parte alta de la cuarta fila
				MOVDQU xmm10, xmm5				; pone en xmm10 la quinta fila
				PUNPCKHBW xmm10, xmm0			; deja en xmm10 la parte alta de la quinta fila
				
				; se tiene
				; xmm6:  f1_15 | f1_14 | f1_13 | f1_12 | f1_11 | f1_10 | f1_9 | f1_8
				; xmm7:  f2_15 | f2_14 | f2_13 | f2_12 | f2_11 | f2_10 | f2_9 | f2_8
				; xmm8:  f3_15 | f3_14 | f3_13 | f3_12 | f3_11 | f3_10 | f3_9 | f3_8
				; xmm9:  f4_15 | f4_14 | f4_13 | f4_12 | f4_11 | f4_10 | f4_9 | f4_8
				; xmm10: f5_15 | f5_14 | f5_13 | f5_12 | f5_11 | f5_10 | f5_9 | f5_8
				
				PUNPCKLWD xmm6, xmm0			; deja en xmm6 la parte baja de la alta de la primer fila
				PUNPCKLWD xmm7, xmm0			; deja en xmm7 la parte baja de la alta de la segunda fila
				PUNPCKLWD xmm8, xmm0			; deja en xmm8 la parte baja de la alta de la tercera fila
				PUNPCKLWD xmm9, xmm0			; deja en xmm9 la parte baja de la alta de la cuarta fila
				PUNPCKLWD xmm10, xmm0			; deja en xmm10 la parte baja de la alta de la quinta fila
				
				; se tiene
				; xmm6:  f1_11 | f1_10 | f1_9 | f1_8
				; xmm7:  f2_11 | f2_10 | f2_9 | f2_8
				; xmm8:  f3_11 | f3_10 | f3_9 | f3_8
				; xmm9:  f4_11 | f4_10 | f4_9 | f4_8
				; xmm10: f5_11 | f5_10 | f5_9 | f5_8
				
				CVTDQ2PS xmm6, xmm6				; pasa los valores a float
				CVTDQ2PS xmm7, xmm7				; pasa los valores a float
				CVTDQ2PS xmm8, xmm8				; pasa los valores a float
				CVTDQ2PS xmm9, xmm9				; pasa los valores a float
				CVTDQ2PS xmm10, xmm10			; pasa los valores a float
				
				; obtiene las partes de las máscaras que se usan
				MOVDQU xmm11, [smooth1]		; pone en xmm11: 0,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2
				PUNPCKHBW xmm11, xmm0		; desempaqueta entonces xmm11: 0,	2,	4,	5,	4,	2,	2,	4
				PUNPCKLWD xmm11, xmm0		; desempaqueta entonces xmm11: 4,	2,	2,	4
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm6 como a xmm10
				MULPS xmm6, xmm11
				MULPS xmm10, xmm11
				
				MOVDQU xmm11, [smooth2]		; pone en xmm11: 0,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4
				PUNPCKHBW xmm11, xmm0		; desempaqueta entonces xmm11: 0,  4,  9, 12,  9,  4,  4,  9
				PUNPCKLWD xmm11, xmm0		; desempaqueta entonces xmm11: 9,  4,  4,  9
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm7 como a xmm9
				MULPS xmm7, xmm11
				MULPS xmm9, xmm11
				
				MOVDQU xmm11, [smooth3]		; pone en xmm11: 0,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5
				PUNPCKHBW xmm11, xmm0		; desempaqueta entonces xmm11: 0,  5, 12, 15, 12,  5,  5, 12
				PUNPCKLWD xmm11, xmm0		; desempaqueta entonces xmm11: 12,  5,  5, 12
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara sólo se aplica a xmm8
				MULPS xmm8, xmm11
				
				; suma todo lo calculado
				ADDPS xmm6, xmm7
				ADDPS xmm6, xmm8
				ADDPS xmm6, xmm9
				ADDPS xmm6, xmm10
				; se tiene xmm6: f1_11*4 + f2_11*9 + f3_11*12 + f4_11*9 + f5_11*4 | f1_10*2 + f2_10*4 + f3_10*5 + f4_10*4 + f5_10*2 | f1_9*2 + f2_9*4 + f3_9*5 + f4_9*4 + f5_9*2 | f1_8*4 + f2_8*9 + f3_8*12 + f4_8*9 + f5_8*4
				MOVDQU xmm12, xmm6			; guarda el resultado en xmm12




				; CUARTOS CUATRO
				
				MOVDQU xmm6, xmm1				; pone en xmm6 la primer fila
				PUNPCKHBW xmm6, xmm0			; deja en xmm6 la parte alta de la primer fila
				MOVDQU xmm7, xmm2				; pone en xmm7 la segunda fila
				PUNPCKHBW xmm7, xmm0			; deja en xmm7 la parte alta de la segunda fila
				MOVDQU xmm8, xmm3				; pone en xmm8 la tercera fila
				PUNPCKHBW xmm8, xmm0			; deja en xmm8 la parte alta de la tercera fila
				MOVDQU xmm9, xmm4				; pone en xmm9 la cuarta fila
				PUNPCKHBW xmm9, xmm0			; deja en xmm9 la parte alta de la cuarta fila
				MOVDQU xmm10, xmm5				; pone en xmm10 la quinta fila
				PUNPCKHBW xmm10, xmm0			; deja en xmm10 la parte alta de la quinta fila
				
				; se tiene
				; xmm6:  f1_15 | f1_14 | f1_13 | f1_12 | f1_11 | f1_10 | f1_9 | f1_8
				; xmm7:  f2_15 | f2_14 | f2_13 | f2_12 | f2_11 | f2_10 | f2_9 | f2_8
				; xmm8:  f3_15 | f3_14 | f3_13 | f3_12 | f3_11 | f3_10 | f3_9 | f3_8
				; xmm9:  f4_15 | f4_14 | f4_13 | f4_12 | f4_11 | f4_10 | f4_9 | f4_8
				; xmm10: f5_15 | f5_14 | f5_13 | f5_12 | f5_11 | f5_10 | f5_9 | f5_8
				
				PUNPCKHWD xmm6, xmm0			; deja en xmm6 la parte alta de la alta de la primer fila
				PUNPCKHWD xmm7, xmm0			; deja en xmm7 la parte alta de la alta de la segunda fila
				PUNPCKHWD xmm8, xmm0			; deja en xmm8 la parte alta de la alta de la tercera fila
				PUNPCKHWD xmm9, xmm0			; deja en xmm9 la parte alta de la alta de la cuarta fila
				PUNPCKHWD xmm10, xmm0			; deja en xmm10 la parte alta de la alta de la quinta fila
				
				; se tiene
				; xmm6:  f1_15 | f1_14 | f1_13 | f1_12
				; xmm7:  f2_15 | f2_14 | f2_13 | f2_12
				; xmm8:  f3_15 | f3_14 | f3_13 | f3_12
				; xmm9:  f4_15 | f4_14 | f4_13 | f4_12
				; xmm10: f5_15 | f5_14 | f5_13 | f5_12
				
				CVTDQ2PS xmm6, xmm6				; pasa los valores a float
				CVTDQ2PS xmm7, xmm7				; pasa los valores a float
				CVTDQ2PS xmm8, xmm8				; pasa los valores a float
				CVTDQ2PS xmm9, xmm9				; pasa los valores a float
				CVTDQ2PS xmm10, xmm10			; pasa los valores a float
				
				; obtiene las partes de las máscaras que se usan
				MOVDQU xmm11, [smooth1]		; pone en xmm11: 0,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2
				PUNPCKHBW xmm11, xmm0		; desempaqueta entonces xmm11: 0,	2,	4,	5,	4,	2,	2,	4
				PUNPCKHWD xmm11, xmm0		; desempaqueta entonces xmm11: 0,	2,	4,	5
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm6 como a xmm10
				MULPS xmm6, xmm11
				MULPS xmm10, xmm11
				
				MOVDQU xmm11, [smooth2]		; pone en xmm11: 0,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4
				PUNPCKHBW xmm11, xmm0		; desempaqueta entonces xmm11: 0,  4,  9, 12,  9,  4,  4,  9
				PUNPCKHWD xmm11, xmm0		; desempaqueta entonces xmm11: 0,  4,  9, 12
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm7 como a xmm9
				MULPS xmm7, xmm11
				MULPS xmm9, xmm11
				
				MOVDQU xmm11, [smooth3]		; pone en xmm11: 0,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5
				PUNPCKHBW xmm11, xmm0		; desempaqueta entonces xmm11: 0,  5, 12, 15, 12,  5,  5, 12
				PUNPCKHWD xmm11, xmm0		; desempaqueta entonces xmm11: 0,  5, 12, 15
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara sólo se aplica a xmm8
				MULPS xmm8, xmm11
				
				; suma todo lo calculado
				ADDPS xmm6, xmm7
				ADDPS xmm6, xmm8
				ADDPS xmm6, xmm9
				ADDPS xmm6, xmm10
				; se tiene xmm6: f1_15*0 + f2_15*0 + f3_15*0 + f4_15*0 + f5_15*0 | f1_14*2 + f2_14*4 + f3_14*5 + f4_14*4 + f5_14*2 | f1_13*4 + f2_13*9 + f3_13*12 + f4_13*9 + f5_13*4 | f1_12*5 + f2_12*12 + f3_12*15 + f4_12*12 + f5_12*5
				
				
				MOVDQU xmm11, xmm6			; el último resultado se lo pone en xmm11
				
				
				
				
				
				; se tiene: (col hace referencia a que se sumó todo lo de esa columna multipicado por la correspondiente máscara)
				; xmm14:	col3, 	col2, 	col1,	col0
				; xmm13:	col7, 	col6, 	col5,	col4
				; xmm12:	col11,	col10,	col9,	col8
				; xmm11:	XXXXX,	col14,	col13,	col12
			
				; Hay que armar los resultados para la posición 1, la 6 y la 11
				
				MOVDQU xmm6, xmm14			; pone en xmm6:	col3, col2, col1, col0
				MOVDQU xmm7, xmm14			; pone en xmm7:	col3, col2, col1, col0
				MOVDQU xmm8, xmm13			; pone en xmm8: col7, 	col6, 	col5,	col4
				PSRLDQ xmm7, 4				; xmm7: 0, col3, col2, col1
				ADDPS xmm6, xmm7			; suma float a float
				PSRLDQ xmm7, 4				; xmm7: 0, 0, col3, col2
				ADDPS xmm6, xmm7			; suma float a float
				PSRLDQ xmm7, 4				; xmm7: 0, 0, 0, col3
				ADDPS xmm6, xmm7			; suma float a float
				ADDPS xmm6, xmm8			; suma float a float
				MOVDQU xmm10, xmm6
				; xmm10: XXX | XXX | XXX | col4 + col3 + col2 + col1 + col0
				
				MOVDQU xmm6, xmm12			; pone en xmm6: col11, col10, col9, col8
				MOVDQU xmm7, xmm12			; pone en xmm7: col11, col10, col9, col8
				MOVDQU xmm8, xmm13			; pone en xmm8: col7, col6, col5, col4
				PSRLDQ xmm7, 4				; xmm7: 0, col11, col10, col9
				ADDPS xmm6, xmm7			; suma float a float
				PSRLDQ xmm8, 4				; xmm8: 0, col7, col6, col5
				ADDPS xmm6, xmm8			; suma float a float
				PSRLDQ xmm8, 4				; xmm8: 0, 0, col7, col6
				ADDPS xmm6, xmm8			; suma float a float
				PSRLDQ xmm8, 4				; xmm8: 0, 0, 0, col7
				ADDPS xmm6, xmm8			; suma float a float
				MOVDQU xmm9, xmm6
				; xmm9: XXX | XXX | XXX | col9 + col8 + col7 + col6 + col5
				
				MOVDQU xmm6, xmm11			; pone en xmm6: XXXXX, col14, col13, col12
				MOVDQU xmm7, xmm11			; pone en xmm7: XXXXX, col14, col13, col12
				MOVDQU xmm8, xmm12			; pone en xmm8: col11, col10, col9, col8
				PSRLDQ xmm7, 4				; xmm7: 0, XXXXX, col14, col13
				ADDPS xmm6, xmm7			; suma float a float
				PSRLDQ xmm7, 4				; xmm7: 0, 0, XXXXX, col14
				ADDPS xmm6, xmm7			; suma float a float
				PSRLDQ xmm8, 4				; xmm8: 0, col11, col10, col9
				PSRLDQ xmm8, 4				; xmm8: 0, 0, col11, col10
				ADDPS xmm6, xmm8			; suma float a float
				PSRLDQ xmm8, 4				; xmm8: 0, 0, 0, col11
				ADDPS xmm6, xmm8			; suma float a float
				MOVDQU xmm8, xmm6
				; xmm8: XXX | XXX | XXX | col14 + col13 + col12 + col11 + col10
				
				PSLLDQ xmm10, 12			; xmm10: col4 + col3 + col2 + col1 + col0 | 0 | 0 | 0
				PSLLDQ xmm9, 12				; xmm10: col9 + col8 + col7 + col6 + col5 | 0 | 0 | 0
				PSLLDQ xmm8, 12				; xmm10: col14 + col13 + col12 + col11 + col10 | 0 | 0 | 0
				PSRLDQ xmm10, 12			; xmm10: 0 | 0 | 0 | col4 + col3 + col2 + col1 + col0
				PSRLDQ xmm9, 8				; xmm10: 0 | 0 | col9 + col8 + col7 + col6 + col5 | 0
				PSRLDQ xmm8, 4				; xmm10: 0 | col14 + col13 + col12 + col11 + col10 | 0 | 0
				ADDPS xmm10, xmm9
				ADDPS xmm10, xmm8			; xmm10: 0 | col14 + col13 + col12 + col11 + col10 | col9 + col8 + col7 + col6 + col5 | col4 + col3 + col2 + col1 + col0
				MOVDQU xmm9, [mask159s]		; xmm9: 159 | 159 | 159 | 159
				CVTDQ2PS xmm9, xmm9			; los convierte a float
				DIVPS xmm10, xmm9			; divide a cada lugar por 159
				
				CVTPS2DQ xmm10, xmm10		; vuelve a entero
				PACKUSDW xmm10, xmm0		; xmm10: 0 | 0 | 0 | 0 | 0 | P11 | P6 | P1
				PACKUSWB xmm10, xmm0		; xmm10: 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | P11 | P6 | P1
				MOVDQU xmm11, xmm10			; copia a xmm11
				MOVDQU xmm12, xmm10			; copia a xmm12
				MOVDQU xmm13, xmm10			; copia a xmm13
				PSRLDQ xmm11, 2				; xmm11: 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | P11
				PSLLDQ xmm11, 10			; xmm11: 0 | 0 | 0 | 0 | 0 | P11 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0
				PSRLDQ xmm12, 1				; xmm12: 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | P11 | P6
				PSLLDQ xmm12, 15			; xmm12: P6 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0
				PSRLDQ xmm12, 10			; xmm12: 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | P6 | 0 | 0 | 0 | 0 | 0
				PSLLDQ xmm13, 15			; xmm13: P1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0
				PSRLDQ xmm13, 15			; xmm13: 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | P1
				PADDB xmm15, xmm11
				PADDB xmm15, xmm12
				PADDB xmm15, xmm13			; xmm15: 0 | 0 | 0 | 0 | 0 | P11 | 0 | 0 | 0 | 0 | P6 | 0 | 0 | 0 | 0 | P1
				
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			; Posiciones de procesado:
			; X    X    P12    P11    P10    P9    P8    P7    P6    P5    P4   P3   P2   P1    X    X
			
			; Se procesan la 2, la 7 y la 12
			
				; PRIMEROS CUATRO
				
				MOVDQU xmm6, xmm1				; pone en xmm6 la primer fila
				PUNPCKLBW xmm6, xmm0			; deja en xmm6 la parte baja de la primer fila
				MOVDQU xmm7, xmm2				; pone en xmm7 la segunda fila
				PUNPCKLBW xmm7, xmm0			; deja en xmm7 la parte baja de la segunda fila
				MOVDQU xmm8, xmm3				; pone en xmm8 la tercera fila
				PUNPCKLBW xmm8, xmm0			; deja en xmm8 la parte baja de la tercera fila
				MOVDQU xmm9, xmm4				; pone en xmm9 la cuarta fila
				PUNPCKLBW xmm9, xmm0			; deja en xmm9 la parte baja de la cuarta fila
				MOVDQU xmm10, xmm5				; pone en xmm10 la quinta fila
				PUNPCKLBW xmm10, xmm0			; deja en xmm10 la parte baja de la quinta fila
				
				; se tiene
				; xmm6:  f1_7 | f1_6 | f1_5 | f1_4 | f1_3 | f1_2 | f1_1 | f1_0
				; xmm7:  f2_7 | f2_6 | f2_5 | f2_4 | f2_3 | f2_2 | f2_1 | f2_0
				; xmm8:  f3_7 | f3_6 | f3_5 | f3_4 | f3_3 | f3_2 | f3_1 | f3_0
				; xmm9:  f4_7 | f4_6 | f4_5 | f4_4 | f4_3 | f4_2 | f4_1 | f4_0
				; xmm10: f5_7 | f5_6 | f5_5 | f5_4 | f5_3 | f5_2 | f5_1 | f5_0
				
				PUNPCKLWD xmm6, xmm0			; deja en xmm6 la parte baja de la baja de la primer fila
				PUNPCKLWD xmm7, xmm0			; deja en xmm7 la parte baja de la baja de la segunda fila
				PUNPCKLWD xmm8, xmm0			; deja en xmm8 la parte baja de la baja de la tercera fila
				PUNPCKLWD xmm9, xmm0			; deja en xmm9 la parte baja de la baja de la cuarta fila
				PUNPCKLWD xmm10, xmm0			; deja en xmm10 la parte baja de la baja de la quinta fila
				
				; se tiene
				; xmm6:  f1_3 | f1_2 | f1_1 | f1_0
				; xmm7:  f2_3 | f2_2 | f2_1 | f2_0
				; xmm8:  f3_3 | f3_2 | f3_1 | f3_0
				; xmm9:  f4_3 | f4_2 | f4_1 | f4_0
				; xmm10: f5_3 | f5_2 | f5_1 | f5_0
				
				CVTDQ2PS xmm6, xmm6				; pasa los valores a float
				CVTDQ2PS xmm7, xmm7				; pasa los valores a float
				CVTDQ2PS xmm8, xmm8				; pasa los valores a float
				CVTDQ2PS xmm9, xmm9				; pasa los valores a float
				CVTDQ2PS xmm10, xmm10			; pasa los valores a float
				
				; obtiene las partes de las máscaras que se usan
				MOVDQU xmm11, [smooth1]		; pone en xmm11: 0,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2
				PSLLDQ xmm11, 1				; xmm11: 2,	4,	5,	4,	2,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2, 0
				PUNPCKLBW xmm11, xmm0		; desempaqueta entonces xmm11: 4,	2,	2,	4,	5,	4,	2, 0
				PUNPCKLWD xmm11, xmm0		; desempaqueta entonces xmm11: 5,	4,	2, 0
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm6 como a xmm10
				MULPS xmm6, xmm11
				MULPS xmm10, xmm11
				
				MOVDQU xmm11, [smooth2]		; pone en xmm11: 0,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4
				PSLLDQ xmm11, 1				; xmm11: 4,  9, 12,  9,  4,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4, 0
				PUNPCKLBW xmm11, xmm0		; desempaqueta entonces xmm11: 9,  4,  4,  9, 12,  9,  4, 0
				PUNPCKLWD xmm11, xmm0		; desempaqueta entonces xmm11: 12,  9,  4, 0
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm7 como a xmm9
				MULPS xmm7, xmm11
				MULPS xmm9, xmm11
				
				MOVDQU xmm11, [smooth3]		; pone en xmm11: 0,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5
				PSLLDQ xmm11, 1				; xmm11: 5, 12, 15, 12,  5,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5, 0
				PUNPCKLBW xmm11, xmm0		; desempaqueta entonces xmm11: 12,  5,  5, 12, 15, 12,  5, 0
				PUNPCKLWD xmm11, xmm0		; desempaqueta entonces xmm11: 15, 12,  5, 0
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara sólo se aplica a xmm8
				MULPS xmm8, xmm11
				
				; suma todo lo calculado
				ADDPS xmm6, xmm7
				ADDPS xmm6, xmm8
				ADDPS xmm6, xmm9
				ADDPS xmm6, xmm10
				; se tiene xmm6: f1_3*5 + f2_3*12 + f3_3*15 + f4_3*12 + f5_3*5 | f1_2*4 + f2_2*9 + f3_2*12 + f4_2*9 + f5_2*4 | f1_1*2 + f2_1*4 + f3_1*5 + f4_1*4 + f5_1*2 | f1_0*0 + f2_0*0 + f3_0*0 + f4_0*0 + f5_0*0
				MOVDQU xmm14, xmm6			; guarda el resultado en xmm14
			
			
			
			
				; SEGUNDOS CUATRO
				
				MOVDQU xmm6, xmm1				; pone en xmm6 la primer fila
				PUNPCKLBW xmm6, xmm0			; deja en xmm6 la parte baja de la primer fila
				MOVDQU xmm7, xmm2				; pone en xmm7 la segunda fila
				PUNPCKLBW xmm7, xmm0			; deja en xmm7 la parte baja de la segunda fila
				MOVDQU xmm8, xmm3				; pone en xmm8 la tercera fila
				PUNPCKLBW xmm8, xmm0			; deja en xmm8 la parte baja de la tercera fila
				MOVDQU xmm9, xmm4				; pone en xmm9 la cuarta fila
				PUNPCKLBW xmm9, xmm0			; deja en xmm9 la parte baja de la cuarta fila
				MOVDQU xmm10, xmm5				; pone en xmm10 la quinta fila
				PUNPCKLBW xmm10, xmm0			; deja en xmm10 la parte baja de la quinta fila
				
				; se tiene
				; xmm6:  f1_7 | f1_6 | f1_5 | f1_4 | f1_3 | f1_2 | f1_1 | f1_0
				; xmm7:  f2_7 | f2_6 | f2_5 | f2_4 | f2_3 | f2_2 | f2_1 | f2_0
				; xmm8:  f3_7 | f3_6 | f3_5 | f3_4 | f3_3 | f3_2 | f3_1 | f3_0
				; xmm9:  f4_7 | f4_6 | f4_5 | f4_4 | f4_3 | f4_2 | f4_1 | f4_0
				; xmm10: f5_7 | f5_6 | f5_5 | f5_4 | f5_3 | f5_2 | f5_1 | f5_0
				
				PUNPCKHWD xmm6, xmm0			; deja en xmm6 la parte alta de la baja de la primer fila
				PUNPCKHWD xmm7, xmm0			; deja en xmm7 la parte alta de la baja de la segunda fila
				PUNPCKHWD xmm8, xmm0			; deja en xmm8 la parte alta de la baja de la tercera fila
				PUNPCKHWD xmm9, xmm0			; deja en xmm9 la parte alta de la baja de la cuarta fila
				PUNPCKHWD xmm10, xmm0			; deja en xmm10 la parte alta de la baja de la quinta fila
				
				; se tiene
				; xmm6:  f1_7 | f1_6 | f1_5 | f1_4
				; xmm7:  f2_7 | f2_6 | f2_5 | f2_4
				; xmm8:  f3_7 | f3_6 | f3_5 | f3_4
				; xmm9:  f4_7 | f4_6 | f4_5 | f4_4
				; xmm10: f5_7 | f5_6 | f5_5 | f5_4
				
				CVTDQ2PS xmm6, xmm6				; pasa los valores a float
				CVTDQ2PS xmm7, xmm7				; pasa los valores a float
				CVTDQ2PS xmm8, xmm8				; pasa los valores a float
				CVTDQ2PS xmm9, xmm9				; pasa los valores a float
				CVTDQ2PS xmm10, xmm10			; pasa los valores a float
				
				; obtiene las partes de las máscaras que se usan
				MOVDQU xmm11, [smooth1]		; pone en xmm11: 0,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2
				PSLLDQ xmm11, 1				; xmm11: 2,	4,	5,	4,	2,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2, 0
				PUNPCKLBW xmm11, xmm0		; desempaqueta entonces xmm11: 4,	2,	2,	4,	5,	4,	2, 0
				PUNPCKHWD xmm11, xmm0		; desempaqueta entonces xmm11: 4,	2,	2,	4
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm6 como a xmm10
				MULPS xmm6, xmm11
				MULPS xmm10, xmm11
				
				MOVDQU xmm11, [smooth2]		; pone en xmm11: 0,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4
				PSLLDQ xmm11, 1				; xmm11: 4,  9, 12,  9,  4,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4, 0
				PUNPCKLBW xmm11, xmm0		; desempaqueta entonces xmm11: 9,  4,  4,  9, 12,  9,  4, 0
				PUNPCKHWD xmm11, xmm0		; desempaqueta entonces xmm11: 9,  4,  4,  9
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm7 como a xmm9
				MULPS xmm7, xmm11
				MULPS xmm9, xmm11
				
				MOVDQU xmm11, [smooth3]		; pone en xmm11: 0,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5
				PSLLDQ xmm11, 1				; xmm11: 5, 12, 15, 12,  5,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5, 0
				PUNPCKLBW xmm11, xmm0		; desempaqueta entonces xmm11: 12,  5,  5, 12, 15, 12,  5, 0
				PUNPCKHWD xmm11, xmm0		; desempaqueta entonces xmm11: 12,  5,  5, 12
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara sólo se aplica a xmm8
				MULPS xmm8, xmm11
				
				; suma todo lo calculado
				ADDPS xmm6, xmm7
				ADDPS xmm6, xmm8
				ADDPS xmm6, xmm9
				ADDPS xmm6, xmm10
				; se tiene xmm6: f1_7*4 + f2_7*9 + f3_7*12 + f4_7*9 + f5_7*4 | f1_6*2 + f2_6*4 + f3_6*5 + f4_6*4 + f5_6*2 | f1_5*4 + f2_5*4 + f3_5*5 + f4_5*4 + f5_5*2 | f1_4*4 + f2_4*9 + f3_4*12 + f4_4*9 + f5_4*4
				MOVDQU xmm13, xmm6			; guarda el resultado en xmm13




				; TERCEROS CUATRO
				
				MOVDQU xmm6, xmm1				; pone en xmm6 la primer fila
				PUNPCKHBW xmm6, xmm0			; deja en xmm6 la parte alta de la primer fila
				MOVDQU xmm7, xmm2				; pone en xmm7 la segunda fila
				PUNPCKHBW xmm7, xmm0			; deja en xmm7 la parte alta de la segunda fila
				MOVDQU xmm8, xmm3				; pone en xmm8 la tercera fila
				PUNPCKHBW xmm8, xmm0			; deja en xmm8 la parte alta de la tercera fila
				MOVDQU xmm9, xmm4				; pone en xmm9 la cuarta fila
				PUNPCKHBW xmm9, xmm0			; deja en xmm9 la parte alta de la cuarta fila
				MOVDQU xmm10, xmm5				; pone en xmm10 la quinta fila
				PUNPCKHBW xmm10, xmm0			; deja en xmm10 la parte alta de la quinta fila
				
				; se tiene
				; xmm6:  f1_15 | f1_14 | f1_13 | f1_12 | f1_11 | f1_10 | f1_9 | f1_8
				; xmm7:  f2_15 | f2_14 | f2_13 | f2_12 | f2_11 | f2_10 | f2_9 | f2_8
				; xmm8:  f3_15 | f3_14 | f3_13 | f3_12 | f3_11 | f3_10 | f3_9 | f3_8
				; xmm9:  f4_15 | f4_14 | f4_13 | f4_12 | f4_11 | f4_10 | f4_9 | f4_8
				; xmm10: f5_15 | f5_14 | f5_13 | f5_12 | f5_11 | f5_10 | f5_9 | f5_8
				
				PUNPCKLWD xmm6, xmm0			; deja en xmm6 la parte baja de la alta de la primer fila
				PUNPCKLWD xmm7, xmm0			; deja en xmm7 la parte baja de la alta de la segunda fila
				PUNPCKLWD xmm8, xmm0			; deja en xmm8 la parte baja de la alta de la tercera fila
				PUNPCKLWD xmm9, xmm0			; deja en xmm9 la parte baja de la alta de la cuarta fila
				PUNPCKLWD xmm10, xmm0			; deja en xmm10 la parte baja de la alta de la quinta fila
				
				; se tiene
				; xmm6:  f1_11 | f1_10 | f1_9 | f1_8
				; xmm7:  f2_11 | f2_10 | f2_9 | f2_8
				; xmm8:  f3_11 | f3_10 | f3_9 | f3_8
				; xmm9:  f4_11 | f4_10 | f4_9 | f4_8
				; xmm10: f5_11 | f5_10 | f5_9 | f5_8
				
				CVTDQ2PS xmm6, xmm6				; pasa los valores a float
				CVTDQ2PS xmm7, xmm7				; pasa los valores a float
				CVTDQ2PS xmm8, xmm8				; pasa los valores a float
				CVTDQ2PS xmm9, xmm9				; pasa los valores a float
				CVTDQ2PS xmm10, xmm10			; pasa los valores a float
				
				; obtiene las partes de las máscaras que se usan
				MOVDQU xmm11, [smooth1]		; pone en xmm11: 0,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2
				PSLLDQ xmm11, 1				; xmm11: 2,	4,	5,	4,	2,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2, 0
				PUNPCKHBW xmm11, xmm0		; desempaqueta entonces xmm11: 2,	4,	5,	4,	2,	2,	4,	5
				PUNPCKLWD xmm11, xmm0		; desempaqueta entonces xmm11: 2,	2,	4,	5
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm6 como a xmm10
				MULPS xmm6, xmm11
				MULPS xmm10, xmm11
				
				MOVDQU xmm11, [smooth2]		; pone en xmm11: 0,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4
				PSLLDQ xmm11, 1				; xmm11: 4,  9, 12,  9,  4,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4, 0
				PUNPCKHBW xmm11, xmm0		; desempaqueta entonces xmm11: 4,  9, 12,  9,  4,  4,  9, 12
				PUNPCKLWD xmm11, xmm0		; desempaqueta entonces xmm11: 4,  4,  9, 12
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm7 como a xmm9
				MULPS xmm7, xmm11
				MULPS xmm9, xmm11
				
				MOVDQU xmm11, [smooth3]		; pone en xmm11: 0,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5
				PSLLDQ xmm11, 1				; xmm11: 5, 12, 15, 12,  5,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5, 0
				PUNPCKHBW xmm11, xmm0		; desempaqueta entonces xmm11: 5, 12, 15, 12,  5,  5, 12, 15
				PUNPCKLWD xmm11, xmm0		; desempaqueta entonces xmm11: 5,  5, 12, 15
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara sólo se aplica a xmm8
				MULPS xmm8, xmm11
				
				; suma todo lo calculado
				ADDPS xmm6, xmm7
				ADDPS xmm6, xmm8
				ADDPS xmm6, xmm9
				ADDPS xmm6, xmm10
				; se tiene xmm6: f1_11*2 + f2_11*4 + f3_11*5 + f4_11*4 + f5_11*2 | f1_10*2 + f2_10*4 + f3_10*5 + f4_10*4 + f5_10*2 | f1_9*4 + f2_9*9 + f3_9*12 + f4_9*9 + f5_9*4 | f1_8*5 + f2_8*12 + f3_8*15 + f4_8*12 + f5_8*5
				MOVDQU xmm12, xmm6			; guarda el resultado en xmm12




				; CUARTOS CUATRO
				
				MOVDQU xmm6, xmm1				; pone en xmm6 la primer fila
				PUNPCKHBW xmm6, xmm0			; deja en xmm6 la parte alta de la primer fila
				MOVDQU xmm7, xmm2				; pone en xmm7 la segunda fila
				PUNPCKHBW xmm7, xmm0			; deja en xmm7 la parte alta de la segunda fila
				MOVDQU xmm8, xmm3				; pone en xmm8 la tercera fila
				PUNPCKHBW xmm8, xmm0			; deja en xmm8 la parte alta de la tercera fila
				MOVDQU xmm9, xmm4				; pone en xmm9 la cuarta fila
				PUNPCKHBW xmm9, xmm0			; deja en xmm9 la parte alta de la cuarta fila
				MOVDQU xmm10, xmm5				; pone en xmm10 la quinta fila
				PUNPCKHBW xmm10, xmm0			; deja en xmm10 la parte alta de la quinta fila
				
				; se tiene
				; xmm6:  f1_15 | f1_14 | f1_13 | f1_12 | f1_11 | f1_10 | f1_9 | f1_8
				; xmm7:  f2_15 | f2_14 | f2_13 | f2_12 | f2_11 | f2_10 | f2_9 | f2_8
				; xmm8:  f3_15 | f3_14 | f3_13 | f3_12 | f3_11 | f3_10 | f3_9 | f3_8
				; xmm9:  f4_15 | f4_14 | f4_13 | f4_12 | f4_11 | f4_10 | f4_9 | f4_8
				; xmm10: f5_15 | f5_14 | f5_13 | f5_12 | f5_11 | f5_10 | f5_9 | f5_8
				
				PUNPCKHWD xmm6, xmm0			; deja en xmm6 la parte alta de la alta de la primer fila
				PUNPCKHWD xmm7, xmm0			; deja en xmm7 la parte alta de la alta de la segunda fila
				PUNPCKHWD xmm8, xmm0			; deja en xmm8 la parte alta de la alta de la tercera fila
				PUNPCKHWD xmm9, xmm0			; deja en xmm9 la parte alta de la alta de la cuarta fila
				PUNPCKHWD xmm10, xmm0			; deja en xmm10 la parte alta de la alta de la quinta fila
				
				; se tiene
				; xmm6:  f1_15 | f1_14 | f1_13 | f1_12
				; xmm7:  f2_15 | f2_14 | f2_13 | f2_12
				; xmm8:  f3_15 | f3_14 | f3_13 | f3_12
				; xmm9:  f4_15 | f4_14 | f4_13 | f4_12
				; xmm10: f5_15 | f5_14 | f5_13 | f5_12
				
				CVTDQ2PS xmm6, xmm6				; pasa los valores a float
				CVTDQ2PS xmm7, xmm7				; pasa los valores a float
				CVTDQ2PS xmm8, xmm8				; pasa los valores a float
				CVTDQ2PS xmm9, xmm9				; pasa los valores a float
				CVTDQ2PS xmm10, xmm10			; pasa los valores a float
				
				; obtiene las partes de las máscaras que se usan
				MOVDQU xmm11, [smooth1]		; pone en xmm11: 0,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2
				PSLLDQ xmm11, 1				; xmm11: 2,	4,	5,	4,	2,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2, 0
				PUNPCKHBW xmm11, xmm0		; desempaqueta entonces xmm11: 2,	4,	5,	4,	2,	2,	4,	5
				PUNPCKHWD xmm11, xmm0		; desempaqueta entonces xmm11: 2,	4,	5,	4
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm6 como a xmm10
				MULPS xmm6, xmm11
				MULPS xmm10, xmm11
				
				MOVDQU xmm11, [smooth2]		; pone en xmm11: 0,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4
				PSLLDQ xmm11, 1				; xmm11: 4,  9, 12,  9,  4,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4, 0
				PUNPCKHBW xmm11, xmm0		; desempaqueta entonces xmm11: 4,  9, 12,  9,  4,  4,  9, 12
				PUNPCKHWD xmm11, xmm0		; desempaqueta entonces xmm11: 4,  9, 12,  9
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm7 como a xmm9
				MULPS xmm7, xmm11
				MULPS xmm9, xmm11
				
				MOVDQU xmm11, [smooth3]		; pone en xmm11: 0,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5
				PSLLDQ xmm11, 1				; xmm11: 5, 12, 15, 12,  5,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5, 0
				PUNPCKHBW xmm11, xmm0		; desempaqueta entonces xmm11: 5, 12, 15, 12,  5,  5, 12, 15
				PUNPCKHWD xmm11, xmm0		; desempaqueta entonces xmm11: 5, 12, 15, 12
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara sólo se aplica a xmm8
				MULPS xmm8, xmm11
				
				; suma todo lo calculado
				ADDPS xmm6, xmm7
				ADDPS xmm6, xmm8
				ADDPS xmm6, xmm9
				ADDPS xmm6, xmm10
				; se tiene xmm6: f1_15*2 + f2_15*4 + f3_15*5 + f4_15*4 + f5_15*2 | f1_14*4 + f2_14*9 + f3_14*12 + f4_14*9 + f5_14*4 | f1_13*5 + f2_13*12 + f3_13*15 + f4_13*12 + f5_13*5 | f1_12*4 + f2_12*9 + f3_12*12 + f4_12*9 + f5_12*4
				
				
				MOVDQU xmm11, xmm6			; el último resultado se lo pone en xmm11
				; se tiene: (col hace referencia a que se sumó todo lo de esa columna multipicado por la correspondiente máscara)
				; xmm14:	col3, 	col2, 	col1,	XXXXX
				; xmm13:	col7, 	col6, 	col5,	col4
				; xmm12:	col11,	col10,	col9,	col8
				; xmm11:	col15,	col14,	col13,	col12
			
				; Hay que armar los resultados para la posición 2, la 7 y la 12
				
				MOVDQU xmm6, xmm14			; pone en xmm6:	col3, col2, col1, XXXXX
				PSRLDQ xmm6, 4				; xmm6: 0, col3, col2, col1
				MOVDQU xmm7, xmm6			; pone en xmm7:	0, col3, col2, col1
				MOVDQU xmm8, xmm13			; pone en xmm8: col7, 	col6, 	col5,	col4
				PSRLDQ xmm7, 4				; xmm7: 0, 0, col3, col2
				ADDPS xmm6, xmm7			; suma float a float
				PSRLDQ xmm7, 4				; xmm7: 0, 0, 0, col3
				ADDPS xmm6, xmm7			; suma float a float
				PSRLDQ xmm7, 4				; xmm7: 0, 0, 0, col3
				ADDPS xmm6, xmm7			; suma float a float
				ADDPS xmm6, xmm8			; suma float a float
				PSRLDQ xmm8, 4				; xmm8: 0, col7, 	col6, 	col5
				ADDPS xmm6, xmm8			; suma float a float
				MOVDQU xmm10, xmm6
				; xmm10: XXX | XXX | XXX | col5 + col4 + col3 + col2 + col1
				
				MOVDQU xmm6, xmm12			; pone en xmm6: col11, col10, col9, col8
				MOVDQU xmm7, xmm12			; pone en xmm7: col11, col10, col9, col8
				MOVDQU xmm8, xmm13			; pone en xmm8: col7, col6, col5, col4
				PSRLDQ xmm7, 4				; xmm7: 0, col11, col10, col9
				ADDPS xmm6, xmm7			; suma float a float
				PSRLDQ xmm7, 4				; xmm7: 0, 0, col11, col10
				ADDPS xmm6, xmm7			; suma float a float
				PSRLDQ xmm8, 8				; xmm8: 0, 0, col7, col6
				ADDPS xmm6, xmm8			; suma float a float
				PSRLDQ xmm8, 4				; xmm8: 0, 0, 0, col7
				ADDPS xmm6, xmm8			; suma float a float
				MOVDQU xmm9, xmm6
				; xmm9: XXX | XXX | XXX | col10 + col9 + col8 + col7 + col6
				
				MOVDQU xmm6, xmm11			; pone en xmm6: col15, col14, col13, col12
				MOVDQU xmm7, xmm11			; pone en xmm7: col15, col14, col13, col12
				MOVDQU xmm8, xmm12			; pone en xmm8: col11, col10, col9, col8
				PSRLDQ xmm7, 4				; xmm7: 0, col15, col14, col13
				ADDPS xmm6, xmm7			; suma float a float
				PSRLDQ xmm7, 4				; xmm7: 0, 0, col15, col14
				ADDPS xmm6, xmm7			; suma float a float
				PSRLDQ xmm7, 4				; xmm7: 0, 0, 0, col15
				ADDPS xmm6, xmm7			; suma float a float
				PSRLDQ xmm8, 12				; xmm8: 0, 0, 0, col11
				ADDPS xmm6, xmm8			; suma float a float
				MOVDQU xmm8, xmm6
				; xmm8: XXX | XXX | XXX | col15 + col14 + col13 + col12 + col11
				
				PSLLDQ xmm10, 12				; xmm10: col5 + col4 + col3 + col2 + col1 | 0 | 0 | 0
				PSLLDQ xmm9, 12				; xmm10: col10 + col9 + col8 + col7 + col6 | 0 | 0 | 0
				PSLLDQ xmm8, 12				; xmm10: col15 + col14 + col13 + col12 + col11 | 0 | 0 | 0
				PSRLDQ xmm10, 12				; xmm10: 0 | 0 | 0 | col5 + col4 + col3 + col2 + col1
				PSRLDQ xmm9, 8				; xmm10: 0 | 0 | col10 + col9 + col8 + col7 + col6 | 0
				PSRLDQ xmm8, 4				; xmm10: 0 | col15 + col14 + col13 + col12 + col11 | 0 | 0
				ADDPS xmm10, xmm9
				ADDPS xmm10, xmm8			; xmm10: 0 | col15 + col14 + col13 + col12 + col11 | col10 + col9 + col8 + col7 + col6 | col5 + col4 + col3 + col2 + col1
				MOVDQU xmm9, [mask159s]		; xmm9: 159 | 159 | 159 | 159
				CVTDQ2PS xmm9, xmm9			; los convierte a float
				DIVPS xmm10, xmm9			; divide a cada lugar por 159
				
				CVTPS2DQ xmm10, xmm10		; vuelve a entero
				PACKUSDW xmm10, xmm0			; xmm10: 0 | 0 | 0 | 0 | 0 | P12 | P7 | P2
				PACKUSWB xmm10, xmm0			; xmm10: 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | P12 | P7 | P2
				MOVDQU xmm11, xmm10			; copia a xmm11
				MOVDQU xmm12, xmm10			; copia a xmm12
				MOVDQU xmm13, xmm10			; copia a xmm13
				PSRLDQ xmm11, 2				; xmm11: 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | P12
				PSLLDQ xmm11, 11				; xmm11: 0 | 0 | 0 | 0 | P12 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0
				PSRLDQ xmm12, 1				; xmm12: 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | P12 | P7
				PSLLDQ xmm12, 15				; xmm12: P7 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0
				PSRLDQ xmm12, 9				; xmm12: 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | P7 | 0 | 0 | 0 | 0 | 0 | 0
				PSLLDQ xmm13, 15				; xmm13: P2 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0
				PSRLDQ xmm13, 14				; xmm13: 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | P2 | 0
				PADDB xmm15, xmm11
				PADDB xmm15, xmm12
				PADDB xmm15, xmm13			; xmm15: 0 | 0 | 0 | 0 | P12 | P11 | 0 | 0 | 0 | P7 | P6 | 0 | 0 | 0 | P2 | P1
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			; Posiciones de procesado:
			; X    X    P12    P11    P10    P9    P8    P7    P6    P5    P4   P3   P2   P1    X    X
			
			; Se procesan la 3 y la 8
			
				; PRIMEROS CUATRO
				
				MOVDQU xmm6, xmm1				; pone en xmm6 la primer fila
				PUNPCKLBW xmm6, xmm0			; deja en xmm6 la parte baja de la primer fila
				MOVDQU xmm7, xmm2				; pone en xmm7 la segunda fila
				PUNPCKLBW xmm7, xmm0			; deja en xmm7 la parte baja de la segunda fila
				MOVDQU xmm8, xmm3				; pone en xmm8 la tercera fila
				PUNPCKLBW xmm8, xmm0			; deja en xmm8 la parte baja de la tercera fila
				MOVDQU xmm9, xmm4				; pone en xmm9 la cuarta fila
				PUNPCKLBW xmm9, xmm0			; deja en xmm9 la parte baja de la cuarta fila
				MOVDQU xmm10, xmm5				; pone en xmm10 la quinta fila
				PUNPCKLBW xmm10, xmm0			; deja en xmm10 la parte baja de la quinta fila
				
				; se tiene
				; xmm6:  f1_7 | f1_6 | f1_5 | f1_4 | f1_3 | f1_2 | f1_1 | f1_0
				; xmm7:  f2_7 | f2_6 | f2_5 | f2_4 | f2_3 | f2_2 | f2_1 | f2_0
				; xmm8:  f3_7 | f3_6 | f3_5 | f3_4 | f3_3 | f3_2 | f3_1 | f3_0
				; xmm9:  f4_7 | f4_6 | f4_5 | f4_4 | f4_3 | f4_2 | f4_1 | f4_0
				; xmm10: f5_7 | f5_6 | f5_5 | f5_4 | f5_3 | f5_2 | f5_1 | f5_0
				
				PUNPCKLWD xmm6, xmm0			; deja en xmm6 la parte baja de la baja de la primer fila
				PUNPCKLWD xmm7, xmm0			; deja en xmm7 la parte baja de la baja de la segunda fila
				PUNPCKLWD xmm8, xmm0			; deja en xmm8 la parte baja de la baja de la tercera fila
				PUNPCKLWD xmm9, xmm0			; deja en xmm9 la parte baja de la baja de la cuarta fila
				PUNPCKLWD xmm10, xmm0			; deja en xmm10 la parte baja de la baja de la quinta fila
				
				; se tiene
				; xmm6:  f1_3 | f1_2 | f1_1 | f1_0
				; xmm7:  f2_3 | f2_2 | f2_1 | f2_0
				; xmm8:  f3_3 | f3_2 | f3_1 | f3_0
				; xmm9:  f4_3 | f4_2 | f4_1 | f4_0
				; xmm10: f5_3 | f5_2 | f5_1 | f5_0
				
				CVTDQ2PS xmm6, xmm6				; pasa los valores a float
				CVTDQ2PS xmm7, xmm7				; pasa los valores a float
				CVTDQ2PS xmm8, xmm8				; pasa los valores a float
				CVTDQ2PS xmm9, xmm9				; pasa los valores a float
				CVTDQ2PS xmm10, xmm10			; pasa los valores a float
				
				; obtiene las partes de las máscaras que se usan
				MOVDQU xmm11, [smooth1]		; pone en xmm11: 0,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2
				PSLLDQ xmm11, 2				; xmm11: 4,	5,	4,	2,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2, 0, 0
				PUNPCKLBW xmm11, xmm0		; desempaqueta entonces xmm11: 2,	2,	4,	5,	4,	2, 0, 0
				PUNPCKLWD xmm11, xmm0		; desempaqueta entonces xmm11: 4,	2, 0, 0
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm6 como a xmm10
				MULPS xmm6, xmm11
				MULPS xmm10, xmm11
				
				MOVDQU xmm11, [smooth2]		; pone en xmm11: 0,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4
				PSLLDQ xmm11, 2				; xmm11: 9, 12,  9,  4,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4, 0, 0
				PUNPCKLBW xmm11, xmm0		; desempaqueta entonces xmm11: 4,  4,  9, 12,  9,  4, 0, 0
				PUNPCKLWD xmm11, xmm0		; desempaqueta entonces xmm11: 9,  4, 0, 0
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm7 como a xmm9
				MULPS xmm7, xmm11
				MULPS xmm9, xmm11
				
				MOVDQU xmm11, [smooth3]		; pone en xmm11: 0,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5
				PSLLDQ xmm11, 2				; xmm11: 12, 15, 12,  5,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5, 0, 0
				PUNPCKLBW xmm11, xmm0		; desempaqueta entonces xmm11: 5,  5, 12, 15, 12,  5, 0, 0
				PUNPCKLWD xmm11, xmm0		; desempaqueta entonces xmm11: 12,  5, 0, 0
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara sólo se aplica a xmm8
				MULPS xmm8, xmm11
				
				; suma todo lo calculado
				ADDPS xmm6, xmm7
				ADDPS xmm6, xmm8
				ADDPS xmm6, xmm9
				ADDPS xmm6, xmm10
				; se tiene xmm6: f1_3*4 + f2_3*9 + f3_3*12 + f4_3*9 + f5_3*4 | f1_2*2 + f2_2*4 + f3_2*5 + f4_2*4 + f5_2*2 | f1_1*0 + f2_1*0 + f3_1*0 + f4_1*0 + f5_1*0 | f1_0*0 + f2_0*0 + f3_0*0 + f4_0*0 + f5_0*0
				MOVDQU xmm14, xmm6			; guarda el resultado en xmm14
			
			
			
			
				; SEGUNDOS CUATRO
				
				MOVDQU xmm6, xmm1				; pone en xmm6 la primer fila
				PUNPCKLBW xmm6, xmm0			; deja en xmm6 la parte baja de la primer fila
				MOVDQU xmm7, xmm2				; pone en xmm7 la segunda fila
				PUNPCKLBW xmm7, xmm0			; deja en xmm7 la parte baja de la segunda fila
				MOVDQU xmm8, xmm3				; pone en xmm8 la tercera fila
				PUNPCKLBW xmm8, xmm0			; deja en xmm8 la parte baja de la tercera fila
				MOVDQU xmm9, xmm4				; pone en xmm9 la cuarta fila
				PUNPCKLBW xmm9, xmm0			; deja en xmm9 la parte baja de la cuarta fila
				MOVDQU xmm10, xmm5				; pone en xmm10 la quinta fila
				PUNPCKLBW xmm10, xmm0			; deja en xmm10 la parte baja de la quinta fila
				
				; se tiene
				; xmm6:  f1_7 | f1_6 | f1_5 | f1_4 | f1_3 | f1_2 | f1_1 | f1_0
				; xmm7:  f2_7 | f2_6 | f2_5 | f2_4 | f2_3 | f2_2 | f2_1 | f2_0
				; xmm8:  f3_7 | f3_6 | f3_5 | f3_4 | f3_3 | f3_2 | f3_1 | f3_0
				; xmm9:  f4_7 | f4_6 | f4_5 | f4_4 | f4_3 | f4_2 | f4_1 | f4_0
				; xmm10: f5_7 | f5_6 | f5_5 | f5_4 | f5_3 | f5_2 | f5_1 | f5_0
				
				PUNPCKHWD xmm6, xmm0			; deja en xmm6 la parte alta de la baja de la primer fila
				PUNPCKHWD xmm7, xmm0			; deja en xmm7 la parte alta de la baja de la segunda fila
				PUNPCKHWD xmm8, xmm0			; deja en xmm8 la parte alta de la baja de la tercera fila
				PUNPCKHWD xmm9, xmm0			; deja en xmm9 la parte alta de la baja de la cuarta fila
				PUNPCKHWD xmm10, xmm0			; deja en xmm10 la parte alta de la baja de la quinta fila
				
				; se tiene
				; xmm6:  f1_7 | f1_6 | f1_5 | f1_4
				; xmm7:  f2_7 | f2_6 | f2_5 | f2_4
				; xmm8:  f3_7 | f3_6 | f3_5 | f3_4
				; xmm9:  f4_7 | f4_6 | f4_5 | f4_4
				; xmm10: f5_7 | f5_6 | f5_5 | f5_4
				
				CVTDQ2PS xmm6, xmm6				; pasa los valores a float
				CVTDQ2PS xmm7, xmm7				; pasa los valores a float
				CVTDQ2PS xmm8, xmm8				; pasa los valores a float
				CVTDQ2PS xmm9, xmm9				; pasa los valores a float
				CVTDQ2PS xmm10, xmm10			; pasa los valores a float
				
				; obtiene las partes de las máscaras que se usan
				MOVDQU xmm11, [smooth1]		; pone en xmm11: 0,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2
				PSLLDQ xmm11, 2				; xmm11: 4,	5,	4,	2,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2, 0, 0
				PUNPCKLBW xmm11, xmm0		; desempaqueta entonces xmm11: 5,	4,	2,	2,	4,	5,	4,	2
				PUNPCKHWD xmm11, xmm0		; desempaqueta entonces xmm11: 5,	4,	2,	2
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm6 como a xmm10
				MULPS xmm6, xmm11
				MULPS xmm10, xmm11
				
				MOVDQU xmm11, [smooth2]		; pone en xmm11: 0,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4
				PSLLDQ xmm11, 2				; xmm11: 9, 12,  9,  4,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4, 0, 0
				PUNPCKLBW xmm11, xmm0		; desempaqueta entonces xmm11: 4,  4,  9, 12,  9,  4, 0, 0
				PUNPCKHWD xmm11, xmm0		; desempaqueta entonces xmm11: 4,  4,  9, 12
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm7 como a xmm9
				MULPS xmm7, xmm11
				MULPS xmm9, xmm11
				
				MOVDQU xmm11, [smooth3]		; pone en xmm11: 0,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5
				PSLLDQ xmm11, 2				; xmm11: 12, 15, 12,  5,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5, 0, 0
				PUNPCKLBW xmm11, xmm0		; desempaqueta entonces xmm11: 5,  5, 12, 15, 12,  5, 0, 0
				PUNPCKHWD xmm11, xmm0		; desempaqueta entonces xmm11: 5,  5, 12, 15
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara sólo se aplica a xmm8
				MULPS xmm8, xmm11
				
				; suma todo lo calculado
				ADDPS xmm6, xmm7
				ADDPS xmm6, xmm8
				ADDPS xmm6, xmm9
				ADDPS xmm6, xmm10
				; se tiene xmm6: f1_7*5 + f2_7*12 + f3_7*15 + f4_7*12 + f5_7*5 | f1_6*4 + f2_6*9 + f3_6*12 + f4_6*9 + f5_6*4 | f1_5*2 + f2_5*4 + f3_5*5 + f4_5*4 + f5_5*2 | f1_4*2 + f2_4*4 + f3_4*5 + f4_4*4 + f5_4*2
				MOVDQU xmm13, xmm6			; guarda el resultado en xmm13




				; TERCEROS CUATRO
				
				MOVDQU xmm6, xmm1				; pone en xmm6 la primer fila
				PUNPCKHBW xmm6, xmm0			; deja en xmm6 la parte alta de la primer fila
				MOVDQU xmm7, xmm2				; pone en xmm7 la segunda fila
				PUNPCKHBW xmm7, xmm0			; deja en xmm7 la parte alta de la segunda fila
				MOVDQU xmm8, xmm3				; pone en xmm8 la tercera fila
				PUNPCKHBW xmm8, xmm0			; deja en xmm8 la parte alta de la tercera fila
				MOVDQU xmm9, xmm4				; pone en xmm9 la cuarta fila
				PUNPCKHBW xmm9, xmm0			; deja en xmm9 la parte alta de la cuarta fila
				MOVDQU xmm10, xmm5				; pone en xmm10 la quinta fila
				PUNPCKHBW xmm10, xmm0			; deja en xmm10 la parte alta de la quinta fila
				
				; se tiene
				; xmm6:  f1_15 | f1_14 | f1_13 | f1_12 | f1_11 | f1_10 | f1_9 | f1_8
				; xmm7:  f2_15 | f2_14 | f2_13 | f2_12 | f2_11 | f2_10 | f2_9 | f2_8
				; xmm8:  f3_15 | f3_14 | f3_13 | f3_12 | f3_11 | f3_10 | f3_9 | f3_8
				; xmm9:  f4_15 | f4_14 | f4_13 | f4_12 | f4_11 | f4_10 | f4_9 | f4_8
				; xmm10: f5_15 | f5_14 | f5_13 | f5_12 | f5_11 | f5_10 | f5_9 | f5_8
				
				PUNPCKLWD xmm6, xmm0			; deja en xmm6 la parte baja de la alta de la primer fila
				PUNPCKLWD xmm7, xmm0			; deja en xmm7 la parte baja de la alta de la segunda fila
				PUNPCKLWD xmm8, xmm0			; deja en xmm8 la parte baja de la alta de la tercera fila
				PUNPCKLWD xmm9, xmm0			; deja en xmm9 la parte baja de la alta de la cuarta fila
				PUNPCKLWD xmm10, xmm0			; deja en xmm10 la parte baja de la alta de la quinta fila
				
				; se tiene
				; xmm6:  f1_11 | f1_10 | f1_9 | f1_8
				; xmm7:  f2_11 | f2_10 | f2_9 | f2_8
				; xmm8:  f3_11 | f3_10 | f3_9 | f3_8
				; xmm9:  f4_11 | f4_10 | f4_9 | f4_8
				; xmm10: f5_11 | f5_10 | f5_9 | f5_8
				
				CVTDQ2PS xmm6, xmm6				; pasa los valores a float
				CVTDQ2PS xmm7, xmm7				; pasa los valores a float
				CVTDQ2PS xmm8, xmm8				; pasa los valores a float
				CVTDQ2PS xmm9, xmm9				; pasa los valores a float
				CVTDQ2PS xmm10, xmm10			; pasa los valores a float
				
				; obtiene las partes de las máscaras que se usan
				MOVDQU xmm11, [smooth1]		; pone en xmm11: 0,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2
				PSLLDQ xmm11, 2				; xmm11: 4,	5,	4,	2,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2, 0, 0
				PUNPCKHBW xmm11, xmm0		; desempaqueta entonces xmm11: 4,	5,	4,	2,	2,	4,	5,	4
				PUNPCKLWD xmm11, xmm0		; desempaqueta entonces xmm11: 2,	4,	5,	4
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm6 como a xmm10
				MULPS xmm6, xmm11
				MULPS xmm10, xmm11
				
				MOVDQU xmm11, [smooth2]		; pone en xmm11: 0,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4
				PSLLDQ xmm11, 2				; xmm11: 9, 12,  9,  4,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4, 0, 0
				PUNPCKHBW xmm11, xmm0		; desempaqueta entonces xmm11: 9, 12,  9,  4,  4,  9, 12,  9
				PUNPCKLWD xmm11, xmm0		; desempaqueta entonces xmm11: 4,  9, 12,  9
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm7 como a xmm9
				MULPS xmm7, xmm11
				MULPS xmm9, xmm11
				
				MOVDQU xmm11, [smooth3]		; pone en xmm11: 0,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5
				PSLLDQ xmm11, 2				; xmm11: 12, 15, 12,  5,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5, 0, 0
				PUNPCKHBW xmm11, xmm0		; desempaqueta entonces xmm11: 12, 15, 12,  5,  5, 12, 15, 12
				PUNPCKLWD xmm11, xmm0		; desempaqueta entonces xmm11: 5, 12, 15, 12
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara sólo se aplica a xmm8
				MULPS xmm8, xmm11
				
				; suma todo lo calculado
				ADDPS xmm6, xmm7
				ADDPS xmm6, xmm8
				ADDPS xmm6, xmm9
				ADDPS xmm6, xmm10
				; se tiene xmm6: f1_11*2 + f2_11*4 + f3_11*5 + f4_11*4 + f5_11*2 | f1_10*4 + f2_10*9 + f3_10*12 + f4_10*9 + f5_10*4 | f1_9*5 + f2_9*12 + f3_9*15 + f4_9*12 + f5_9*5 | f1_8*4 + f2_8*9 + f3_8*12 + f4_8*9 + f5_8*4
				MOVDQU xmm12, xmm6			; guarda el resultado en xmm12




				; CUARTOS CUATRO
				
				MOVDQU xmm6, xmm1				; pone en xmm6 la primer fila
				PUNPCKHBW xmm6, xmm0			; deja en xmm6 la parte alta de la primer fila
				MOVDQU xmm7, xmm2				; pone en xmm7 la segunda fila
				PUNPCKHBW xmm7, xmm0			; deja en xmm7 la parte alta de la segunda fila
				MOVDQU xmm8, xmm3				; pone en xmm8 la tercera fila
				PUNPCKHBW xmm8, xmm0			; deja en xmm8 la parte alta de la tercera fila
				MOVDQU xmm9, xmm4				; pone en xmm9 la cuarta fila
				PUNPCKHBW xmm9, xmm0			; deja en xmm9 la parte alta de la cuarta fila
				MOVDQU xmm10, xmm5				; pone en xmm10 la quinta fila
				PUNPCKHBW xmm10, xmm0			; deja en xmm10 la parte alta de la quinta fila
				
				; se tiene
				; xmm6:  f1_15 | f1_14 | f1_13 | f1_12 | f1_11 | f1_10 | f1_9 | f1_8
				; xmm7:  f2_15 | f2_14 | f2_13 | f2_12 | f2_11 | f2_10 | f2_9 | f2_8
				; xmm8:  f3_15 | f3_14 | f3_13 | f3_12 | f3_11 | f3_10 | f3_9 | f3_8
				; xmm9:  f4_15 | f4_14 | f4_13 | f4_12 | f4_11 | f4_10 | f4_9 | f4_8
				; xmm10: f5_15 | f5_14 | f5_13 | f5_12 | f5_11 | f5_10 | f5_9 | f5_8
				
				PUNPCKHWD xmm6, xmm0			; deja en xmm6 la parte alta de la alta de la primer fila
				PUNPCKHWD xmm7, xmm0			; deja en xmm7 la parte alta de la alta de la segunda fila
				PUNPCKHWD xmm8, xmm0			; deja en xmm8 la parte alta de la alta de la tercera fila
				PUNPCKHWD xmm9, xmm0			; deja en xmm9 la parte alta de la alta de la cuarta fila
				PUNPCKHWD xmm10, xmm0			; deja en xmm10 la parte alta de la alta de la quinta fila
				
				; se tiene
				; xmm6:  f1_15 | f1_14 | f1_13 | f1_12
				; xmm7:  f2_15 | f2_14 | f2_13 | f2_12
				; xmm8:  f3_15 | f3_14 | f3_13 | f3_12
				; xmm9:  f4_15 | f4_14 | f4_13 | f4_12
				; xmm10: f5_15 | f5_14 | f5_13 | f5_12
				
				CVTDQ2PS xmm6, xmm6				; pasa los valores a float
				CVTDQ2PS xmm7, xmm7				; pasa los valores a float
				CVTDQ2PS xmm8, xmm8				; pasa los valores a float
				CVTDQ2PS xmm9, xmm9				; pasa los valores a float
				CVTDQ2PS xmm10, xmm10			; pasa los valores a float
				
				; obtiene las partes de las máscaras que se usan
				MOVDQU xmm11, [smooth1]		; pone en xmm11: 0,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2
				PSLLDQ xmm11, 2				; xmm11: 4,	5,	4,	2,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2, 0, 0
				PUNPCKHBW xmm11, xmm0		; desempaqueta entonces xmm11: 4,	5,	4,	2,	2,	4,	5,	4
				PUNPCKHWD xmm11, xmm0		; desempaqueta entonces xmm11: 4,	5,	4,	2
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm6 como a xmm10
				MULPS xmm6, xmm11
				MULPS xmm10, xmm11
				
				MOVDQU xmm11, [smooth2]		; pone en xmm11: 0,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4
				PSLLDQ xmm11, 2				; xmm11: 9, 12,  9,  4,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4, 0, 0
				PUNPCKHBW xmm11, xmm0		; desempaqueta entonces xmm11: 9, 12,  9,  4,  4,  9, 12,  9
				PUNPCKHWD xmm11, xmm0		; desempaqueta entonces xmm11: 9, 12,  9,  4
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm7 como a xmm9
				MULPS xmm7, xmm11
				MULPS xmm9, xmm11
				
				MOVDQU xmm11, [smooth3]		; pone en xmm11: 0,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5
				PSLLDQ xmm11, 2				; xmm11: 12, 15, 12,  5,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5, 0, 0
				PUNPCKHBW xmm11, xmm0		; desempaqueta entonces xmm11: 12, 15, 12,  5,  5, 12, 15, 12
				PUNPCKHWD xmm11, xmm0		; desempaqueta entonces xmm11: 12, 15, 12,  5
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara sólo se aplica a xmm8
				MULPS xmm8, xmm11
				
				; suma todo lo calculado
				ADDPS xmm6, xmm7
				ADDPS xmm6, xmm8
				ADDPS xmm6, xmm9
				ADDPS xmm6, xmm10
				; se tiene xmm6: f1_15*4 + f2_15*9 + f3_15*12 + f4_15*9 + f5_15*4 | f1_14*5 + f2_14*12 + f3_14*15 + f4_14*12 + f5_14*5 | f1_13*4 + f2_13*9 + f3_13*12 + f4_13*9 + f5_13*4 | f1_12*2 + f2_12*4 + f3_12*5 + f4_12*4 + f5_12*2
				
				
				MOVDQU xmm11, xmm6			; el último resultado se lo pone en xmm11
				; se tiene: (col hace referencia a que se sumó todo lo de esa columna multipicado por la correspondiente máscara)
				; xmm14:	col3, 	col2, 	XXXXX,	XXXXX
				; xmm13:	col7, 	col6, 	col5,	col4
				; xmm12:	col11,	col10,	col9,	col8
				; xmm11:	col15,	col14,	col13,	col12
			
				; Hay que armar los resultados para la posición 3 y la 8
				
				MOVDQU xmm6, xmm14			; pone en xmm6:	col3, col2, XXXXX, XXXXX
				PSRLDQ xmm6, 8				; xmm6: 0, 0, col3, col2
				MOVDQU xmm7, xmm6			; pone en xmm7:	0, 0, col3, col2
				MOVDQU xmm8, xmm13			; pone en xmm8: col7, 	col6, 	col5,	col4
				PSRLDQ xmm7, 4				; xmm7: 0, 0, 0, col3
				ADDPS xmm6, xmm7			; suma float a float
				ADDPS xmm6, xmm8			; suma float a float
				PSRLDQ xmm8, 4				; xmm8: 0, col7, 	col6, 	col5
				ADDPS xmm6, xmm8			; suma float a float
				PSRLDQ xmm8, 4				; xmm8: 0, 0, col7, col6
				ADDPS xmm6, xmm8			; suma float a float
				MOVDQU xmm10, xmm6
				; xmm10: XXX | XXX | XXX | col6 + col5 + col4 + col3 + col2
				
				MOVDQU xmm6, xmm12			; pone en xmm6: col11, col10, col9, col8
				MOVDQU xmm7, xmm12			; pone en xmm7: col11, col10, col9, col8
				MOVDQU xmm8, xmm13			; pone en xmm8: col7, col6, col5, col4
				PSRLDQ xmm7, 4				; xmm7: 0, col11, col10, col9
				ADDPS xmm6, xmm7			; suma float a float
				PSRLDQ xmm7, 4				; xmm7: 0, 0, col11, col10
				ADDPS xmm6, xmm7			; suma float a float
				PSRLDQ xmm7, 4				; xmm7: 0, 0, 0, col11
				ADDPS xmm6, xmm7			; suma float a float
				PSRLDQ xmm8, 12				; xmm8: 0, 0, 0, col7
				ADDPS xmm6, xmm8			; suma float a float
				MOVDQU xmm9, xmm6
				; xmm9: XXX | XXX | XXX | col11 + col10 + col9 + col8 + col7
				
				PSLLDQ xmm10, 12				; xmm10: col6 + col5 + col4 + col3 + col2 | 0 | 0 | 0
				PSLLDQ xmm9, 12				; xmm10: col11 + col10 + col9 + col8 + col7 | 0 | 0 | 0
				PSRLDQ xmm10, 12				; xmm10: 0 | 0 | 0 | col6 + col5 + col4 + col3 + col2
				PSRLDQ xmm9, 8				; xmm10: 0 | 0 | col11 + col10 + col9 + col8 + col7 | 0
				ADDPS xmm10, xmm9
				MOVDQU xmm9, [mask159s]		; xmm9: 159 | 159 | 159 | 159
				CVTDQ2PS xmm9, xmm9			; los convierte a float
				DIVPS xmm10, xmm9			; divide a cada lugar por 159
				
				CVTPS2DQ xmm10, xmm10		; vuelve a entero
				PACKUSDW xmm10, xmm0			; xmm10: 0 | 0 | 0 | 0 | 0 | 0 | P8 | P3
				PACKUSWB xmm10, xmm0			; xmm10: 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | P8 | P3
				MOVDQU xmm12, xmm10			; copia a xmm12
				MOVDQU xmm13, xmm10			; copia a xmm13
				PSRLDQ xmm12, 1				; xmm12: 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | P8
				PSLLDQ xmm12, 15				; xmm12: P8 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0
				PSRLDQ xmm12, 8				; xmm12: 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | P8 | 0 | 0 | 0 | 0 | 0 | 0 | 0
				PSLLDQ xmm13, 15				; xmm13: P3 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0
				PSRLDQ xmm13, 13				; xmm13: 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | P3 | 0 | 0
				PADDB xmm15, xmm12
				PADDB xmm15, xmm13			; xmm15: 0 | 0 | 0 | 0 | P12 | P11 | 0 | 0 | P8 | P7 | P6 | 0 | 0 | P3 | P2 | P1
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			; Posiciones de procesado:
			; X    X    P12    P11    P10    P9    P8    P7    P6    P5    P4   P3   P2   P1    X    X
			
			; Se procesan la 4 y la 9
			
				; PRIMEROS CUATRO
				
				MOVDQU xmm6, xmm1				; pone en xmm6 la primer fila
				PUNPCKLBW xmm6, xmm0			; deja en xmm6 la parte baja de la primer fila
				MOVDQU xmm7, xmm2				; pone en xmm7 la segunda fila
				PUNPCKLBW xmm7, xmm0			; deja en xmm7 la parte baja de la segunda fila
				MOVDQU xmm8, xmm3				; pone en xmm8 la tercera fila
				PUNPCKLBW xmm8, xmm0			; deja en xmm8 la parte baja de la tercera fila
				MOVDQU xmm9, xmm4				; pone en xmm9 la cuarta fila
				PUNPCKLBW xmm9, xmm0			; deja en xmm9 la parte baja de la cuarta fila
				MOVDQU xmm10, xmm5				; pone en xmm10 la quinta fila
				PUNPCKLBW xmm10, xmm0			; deja en xmm10 la parte baja de la quinta fila
				
				; se tiene
				; xmm6:  f1_7 | f1_6 | f1_5 | f1_4 | f1_3 | f1_2 | f1_1 | f1_0
				; xmm7:  f2_7 | f2_6 | f2_5 | f2_4 | f2_3 | f2_2 | f2_1 | f2_0
				; xmm8:  f3_7 | f3_6 | f3_5 | f3_4 | f3_3 | f3_2 | f3_1 | f3_0
				; xmm9:  f4_7 | f4_6 | f4_5 | f4_4 | f4_3 | f4_2 | f4_1 | f4_0
				; xmm10: f5_7 | f5_6 | f5_5 | f5_4 | f5_3 | f5_2 | f5_1 | f5_0
				
				PUNPCKLWD xmm6, xmm0			; deja en xmm6 la parte baja de la baja de la primer fila
				PUNPCKLWD xmm7, xmm0			; deja en xmm7 la parte baja de la baja de la segunda fila
				PUNPCKLWD xmm8, xmm0			; deja en xmm8 la parte baja de la baja de la tercera fila
				PUNPCKLWD xmm9, xmm0			; deja en xmm9 la parte baja de la baja de la cuarta fila
				PUNPCKLWD xmm10, xmm0			; deja en xmm10 la parte baja de la baja de la quinta fila
				
				; se tiene
				; xmm6:  f1_3 | f1_2 | f1_1 | f1_0
				; xmm7:  f2_3 | f2_2 | f2_1 | f2_0
				; xmm8:  f3_3 | f3_2 | f3_1 | f3_0
				; xmm9:  f4_3 | f4_2 | f4_1 | f4_0
				; xmm10: f5_3 | f5_2 | f5_1 | f5_0
				
				CVTDQ2PS xmm6, xmm6				; pasa los valores a float
				CVTDQ2PS xmm7, xmm7				; pasa los valores a float
				CVTDQ2PS xmm8, xmm8				; pasa los valores a float
				CVTDQ2PS xmm9, xmm9				; pasa los valores a float
				CVTDQ2PS xmm10, xmm10			; pasa los valores a float
				
				; obtiene las partes de las máscaras que se usan
				MOVDQU xmm11, [smooth1]		; pone en xmm11: 0,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2
				PSLLDQ xmm11, 3				; xmm11: 5,	4,	2,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2, 0, 0, 0
				PUNPCKLBW xmm11, xmm0		; desempaqueta entonces xmm11: 2,	4,	5,	4,	2, 0, 0, 0
				PUNPCKLWD xmm11, xmm0		; desempaqueta entonces xmm11: 2, 0, 0, 0
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm6 como a xmm10
				MULPS xmm6, xmm11
				MULPS xmm10, xmm11
				
				MOVDQU xmm11, [smooth2]		; pone en xmm11: 0,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4
				PSLLDQ xmm11, 3				; xmm11: 12,  9,  4,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4, 0, 0, 0
				PUNPCKLBW xmm11, xmm0		; desempaqueta entonces xmm11: 4,  9, 12,  9,  4, 0, 0, 0
				PUNPCKLWD xmm11, xmm0		; desempaqueta entonces xmm11: 4, 0, 0, 0
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm7 como a xmm9
				MULPS xmm7, xmm11
				MULPS xmm9, xmm11
				
				MOVDQU xmm11, [smooth3]		; pone en xmm11: 0,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5
				PSLLDQ xmm11, 3				; xmm11: 15, 12,  5,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5, 0, 0, 0
				PUNPCKLBW xmm11, xmm0		; desempaqueta entonces xmm11: 5, 12, 15, 12,  5, 0, 0, 0
				PUNPCKLWD xmm11, xmm0		; desempaqueta entonces xmm11: 5, 0, 0, 0
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara sólo se aplica a xmm8
				MULPS xmm8, xmm11
				
				; suma todo lo calculado
				ADDPS xmm6, xmm7
				ADDPS xmm6, xmm8
				ADDPS xmm6, xmm9
				ADDPS xmm6, xmm10
				; se tiene xmm6: f1_3*2 + f2_3*4 + f3_3*5 + f4_3*4 + f5_3*2 | f1_2*0 + f2_2*0 + f3_2*0 + f4_2*0 + f5_2*0 | f1_1*0 + f2_1*0 + f3_1*0 + f4_1*0 + f5_1*0 | f1_0*0 + f2_0*0 + f3_0*0 + f4_0*0 + f5_0*0
				MOVDQU xmm14, xmm6			; guarda el resultado en xmm14
			
			
			
			
				; SEGUNDOS CUATRO
				
				MOVDQU xmm6, xmm1				; pone en xmm6 la primer fila
				PUNPCKLBW xmm6, xmm0			; deja en xmm6 la parte baja de la primer fila
				MOVDQU xmm7, xmm2				; pone en xmm7 la segunda fila
				PUNPCKLBW xmm7, xmm0			; deja en xmm7 la parte baja de la segunda fila
				MOVDQU xmm8, xmm3				; pone en xmm8 la tercera fila
				PUNPCKLBW xmm8, xmm0			; deja en xmm8 la parte baja de la tercera fila
				MOVDQU xmm9, xmm4				; pone en xmm9 la cuarta fila
				PUNPCKLBW xmm9, xmm0			; deja en xmm9 la parte baja de la cuarta fila
				MOVDQU xmm10, xmm5				; pone en xmm10 la quinta fila
				PUNPCKLBW xmm10, xmm0			; deja en xmm10 la parte baja de la quinta fila
				
				; se tiene
				; xmm6:  f1_7 | f1_6 | f1_5 | f1_4 | f1_3 | f1_2 | f1_1 | f1_0
				; xmm7:  f2_7 | f2_6 | f2_5 | f2_4 | f2_3 | f2_2 | f2_1 | f2_0
				; xmm8:  f3_7 | f3_6 | f3_5 | f3_4 | f3_3 | f3_2 | f3_1 | f3_0
				; xmm9:  f4_7 | f4_6 | f4_5 | f4_4 | f4_3 | f4_2 | f4_1 | f4_0
				; xmm10: f5_7 | f5_6 | f5_5 | f5_4 | f5_3 | f5_2 | f5_1 | f5_0
				
				PUNPCKHWD xmm6, xmm0			; deja en xmm6 la parte alta de la baja de la primer fila
				PUNPCKHWD xmm7, xmm0			; deja en xmm7 la parte alta de la baja de la segunda fila
				PUNPCKHWD xmm8, xmm0			; deja en xmm8 la parte alta de la baja de la tercera fila
				PUNPCKHWD xmm9, xmm0			; deja en xmm9 la parte alta de la baja de la cuarta fila
				PUNPCKHWD xmm10, xmm0			; deja en xmm10 la parte alta de la baja de la quinta fila
				
				; se tiene
				; xmm6:  f1_7 | f1_6 | f1_5 | f1_4
				; xmm7:  f2_7 | f2_6 | f2_5 | f2_4
				; xmm8:  f3_7 | f3_6 | f3_5 | f3_4
				; xmm9:  f4_7 | f4_6 | f4_5 | f4_4
				; xmm10: f5_7 | f5_6 | f5_5 | f5_4
				
				CVTDQ2PS xmm6, xmm6				; pasa los valores a float
				CVTDQ2PS xmm7, xmm7				; pasa los valores a float
				CVTDQ2PS xmm8, xmm8				; pasa los valores a float
				CVTDQ2PS xmm9, xmm9				; pasa los valores a float
				CVTDQ2PS xmm10, xmm10			; pasa los valores a float
				
				; obtiene las partes de las máscaras que se usan
				MOVDQU xmm11, [smooth1]		; pone en xmm11: 0,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2
				PSLLDQ xmm11, 3				; xmm11: 5,	4,	2,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2, 0, 0, 0
				PUNPCKLBW xmm11, xmm0		; desempaqueta entonces xmm11: 2,	4,	5,	4,	2, 0, 0, 0
				PUNPCKHWD xmm11, xmm0		; desempaqueta entonces xmm11: 2,	4,	5,	4
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm6 como a xmm10
				MULPS xmm6, xmm11
				MULPS xmm10, xmm11
				
				MOVDQU xmm11, [smooth2]		; pone en xmm11: 0,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4
				PSLLDQ xmm11, 3				; xmm11: 12,  9,  4,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4, 0, 0, 0
				PUNPCKLBW xmm11, xmm0		; desempaqueta entonces xmm11: 4,  9, 12,  9,  4, 0, 0, 0
				PUNPCKHWD xmm11, xmm0		; desempaqueta entonces xmm11: 4,  9, 12,  9
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm7 como a xmm9
				MULPS xmm7, xmm11
				MULPS xmm9, xmm11
				
				MOVDQU xmm11, [smooth3]		; pone en xmm11: 0,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5
				PSLLDQ xmm11, 3				; xmm11: 15, 12,  5,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5, 0, 0, 0
				PUNPCKLBW xmm11, xmm0		; desempaqueta entonces xmm11: 5, 12, 15, 12,  5, 0, 0, 0
				PUNPCKHWD xmm11, xmm0		; desempaqueta entonces xmm11: 5, 12, 15, 12
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara sólo se aplica a xmm8
				MULPS xmm8, xmm11
				
				; suma todo lo calculado
				ADDPS xmm6, xmm7
				ADDPS xmm6, xmm8
				ADDPS xmm6, xmm9
				ADDPS xmm6, xmm10
				; se tiene xmm6: f1_7*2 + f2_7*4 + f3_7*5 + f4_7*4 + f5_7*2 | f1_6*4 + f2_6*9 + f3_6*12 + f4_6*9 + f5_6*4 | f1_5*5 + f2_5*12 + f3_5*15 + f4_5*12 + f5_5*5 | f1_4*4 + f2_4*9 + f3_4*12 + f4_4*9 + f5_4*4
				MOVDQU xmm13, xmm6			; guarda el resultado en xmm13




				; TERCEROS CUATRO
				
				MOVDQU xmm6, xmm1				; pone en xmm6 la primer fila
				PUNPCKHBW xmm6, xmm0			; deja en xmm6 la parte alta de la primer fila
				MOVDQU xmm7, xmm2				; pone en xmm7 la segunda fila
				PUNPCKHBW xmm7, xmm0			; deja en xmm7 la parte alta de la segunda fila
				MOVDQU xmm8, xmm3				; pone en xmm8 la tercera fila
				PUNPCKHBW xmm8, xmm0			; deja en xmm8 la parte alta de la tercera fila
				MOVDQU xmm9, xmm4				; pone en xmm9 la cuarta fila
				PUNPCKHBW xmm9, xmm0			; deja en xmm9 la parte alta de la cuarta fila
				MOVDQU xmm10, xmm5				; pone en xmm10 la quinta fila
				PUNPCKHBW xmm10, xmm0			; deja en xmm10 la parte alta de la quinta fila
				
				; se tiene
				; xmm6:  f1_15 | f1_14 | f1_13 | f1_12 | f1_11 | f1_10 | f1_9 | f1_8
				; xmm7:  f2_15 | f2_14 | f2_13 | f2_12 | f2_11 | f2_10 | f2_9 | f2_8
				; xmm8:  f3_15 | f3_14 | f3_13 | f3_12 | f3_11 | f3_10 | f3_9 | f3_8
				; xmm9:  f4_15 | f4_14 | f4_13 | f4_12 | f4_11 | f4_10 | f4_9 | f4_8
				; xmm10: f5_15 | f5_14 | f5_13 | f5_12 | f5_11 | f5_10 | f5_9 | f5_8
				
				PUNPCKLWD xmm6, xmm0			; deja en xmm6 la parte baja de la alta de la primer fila
				PUNPCKLWD xmm7, xmm0			; deja en xmm7 la parte baja de la alta de la segunda fila
				PUNPCKLWD xmm8, xmm0			; deja en xmm8 la parte baja de la alta de la tercera fila
				PUNPCKLWD xmm9, xmm0			; deja en xmm9 la parte baja de la alta de la cuarta fila
				PUNPCKLWD xmm10, xmm0			; deja en xmm10 la parte baja de la alta de la quinta fila
				
				; se tiene
				; xmm6:  f1_11 | f1_10 | f1_9 | f1_8
				; xmm7:  f2_11 | f2_10 | f2_9 | f2_8
				; xmm8:  f3_11 | f3_10 | f3_9 | f3_8
				; xmm9:  f4_11 | f4_10 | f4_9 | f4_8
				; xmm10: f5_11 | f5_10 | f5_9 | f5_8
				
				CVTDQ2PS xmm6, xmm6				; pasa los valores a float
				CVTDQ2PS xmm7, xmm7				; pasa los valores a float
				CVTDQ2PS xmm8, xmm8				; pasa los valores a float
				CVTDQ2PS xmm9, xmm9				; pasa los valores a float
				CVTDQ2PS xmm10, xmm10			; pasa los valores a float
				
				; obtiene las partes de las máscaras que se usan
				MOVDQU xmm11, [smooth1]		; pone en xmm11: 0,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2
				PSLLDQ xmm11, 3				; xmm11: 5,	4,	2,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2, 0, 0, 0
				PUNPCKHBW xmm11, xmm0		; desempaqueta entonces xmm11: 5,	4,	2,	2,	4,	5,	4,	2
				PUNPCKLWD xmm11, xmm0		; desempaqueta entonces xmm11: 4,	5,	4,	2
				CVTDQ2PS xmm11, xmm11		; convierte a float
				; esa máscara se aplica tanto a xmm6 como a xmm10
				MULPS xmm6, xmm11
				MULPS xmm10, xmm11
				
				MOVDQU xmm11, [smooth2]		; pone en xmm11: 0,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4
				PSLLDQ xmm11, 3				; xmm11: 12,  9,  4,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4, 0, 0, 0
				PUNPCKHBW xmm11, xmm0		; desempaqueta entonces xmm11: 12,  9,  4,  4,  9, 12,  9,  4
				PUNPCKLWD xmm11, xmm0		; desempaqueta entonces xmm11: 9, 12,  9,  4
				CVTDQ2PS xmm11, xmm11		; convierte a float
				; esa máscara se aplica tanto a xmm7 como a xmm9
				MULPS xmm7, xmm11
				MULPS xmm9, xmm11
				
				MOVDQU xmm11, [smooth3]		; pone en xmm11: 0,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5
				PSLLDQ xmm11, 3				; xmm11: 15, 12,  5,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5, 0, 0, 0
				PUNPCKHBW xmm11, xmm0		; desempaqueta entonces xmm11: 15, 12,  5,  5, 12, 15, 12,  5
				PUNPCKLWD xmm11, xmm0		; desempaqueta entonces xmm11: 12, 15, 12,  5
				CVTDQ2PS xmm11, xmm11		; convierte a float
				; esa máscara sólo se aplica a xmm8
				MULPS xmm8, xmm11
				
				; suma todo lo calculado
				ADDPS xmm6, xmm7
				ADDPS xmm6, xmm8
				ADDPS xmm6, xmm9
				ADDPS xmm6, xmm10
				; se tiene xmm6: f1_11*4 + f2_11*9 + f3_11*12 + f4_11*9 + f5_11*4 | f1_10*5 + f2_10*12 + f3_10*15 + f4_10*12 + f5_10*5 | f1_9*4 + f2_9*9 + f3_9*12 + f4_9*9 + f5_9*4 | f1_8*2 + f2_8*4 + f3_8*5 + f4_8*4 + f5_8*2
				MOVDQU xmm12, xmm6			; guarda el resultado en xmm12




				; CUARTOS CUATRO
				
				MOVDQU xmm6, xmm1				; pone en xmm6 la primer fila
				PUNPCKHBW xmm6, xmm0			; deja en xmm6 la parte alta de la primer fila
				MOVDQU xmm7, xmm2				; pone en xmm7 la segunda fila
				PUNPCKHBW xmm7, xmm0			; deja en xmm7 la parte alta de la segunda fila
				MOVDQU xmm8, xmm3				; pone en xmm8 la tercera fila
				PUNPCKHBW xmm8, xmm0			; deja en xmm8 la parte alta de la tercera fila
				MOVDQU xmm9, xmm4				; pone en xmm9 la cuarta fila
				PUNPCKHBW xmm9, xmm0			; deja en xmm9 la parte alta de la cuarta fila
				MOVDQU xmm10, xmm5				; pone en xmm10 la quinta fila
				PUNPCKHBW xmm10, xmm0			; deja en xmm10 la parte alta de la quinta fila
				
				; se tiene
				; xmm6:  f1_15 | f1_14 | f1_13 | f1_12 | f1_11 | f1_10 | f1_9 | f1_8
				; xmm7:  f2_15 | f2_14 | f2_13 | f2_12 | f2_11 | f2_10 | f2_9 | f2_8
				; xmm8:  f3_15 | f3_14 | f3_13 | f3_12 | f3_11 | f3_10 | f3_9 | f3_8
				; xmm9:  f4_15 | f4_14 | f4_13 | f4_12 | f4_11 | f4_10 | f4_9 | f4_8
				; xmm10: f5_15 | f5_14 | f5_13 | f5_12 | f5_11 | f5_10 | f5_9 | f5_8
				
				PUNPCKHWD xmm6, xmm0			; deja en xmm6 la parte alta de la alta de la primer fila
				PUNPCKHWD xmm7, xmm0			; deja en xmm7 la parte alta de la alta de la segunda fila
				PUNPCKHWD xmm8, xmm0			; deja en xmm8 la parte alta de la alta de la tercera fila
				PUNPCKHWD xmm9, xmm0			; deja en xmm9 la parte alta de la alta de la cuarta fila
				PUNPCKHWD xmm10, xmm0			; deja en xmm10 la parte alta de la alta de la quinta fila
				
				; se tiene
				; xmm6:  f1_15 | f1_14 | f1_13 | f1_12
				; xmm7:  f2_15 | f2_14 | f2_13 | f2_12
				; xmm8:  f3_15 | f3_14 | f3_13 | f3_12
				; xmm9:  f4_15 | f4_14 | f4_13 | f4_12
				; xmm10: f5_15 | f5_14 | f5_13 | f5_12
				
				CVTDQ2PS xmm6, xmm6				; pasa los valores a float
				CVTDQ2PS xmm7, xmm7				; pasa los valores a float
				CVTDQ2PS xmm8, xmm8				; pasa los valores a float
				CVTDQ2PS xmm9, xmm9				; pasa los valores a float
				CVTDQ2PS xmm10, xmm10			; pasa los valores a float
				
				; obtiene las partes de las máscaras que se usan
				MOVDQU xmm11, [smooth1]		; pone en xmm11: 0,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2
				PSLLDQ xmm11, 3				; xmm11: 5,	4,	2,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2, 0, 0, 0
				PUNPCKHBW xmm11, xmm0		; desempaqueta entonces xmm11: 5,	4,	2,	2,	4,	5,	4,	2
				PUNPCKHWD xmm11, xmm0		; desempaqueta entonces xmm11: 5,	4,	2,	2
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm6 como a xmm10
				MULPS xmm6, xmm11
				MULPS xmm10, xmm11
				
				MOVDQU xmm11, [smooth2]		; pone en xmm11: 0,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4
				PSLLDQ xmm11, 3				; xmm11: 12,  9,  4,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4, 0, 0, 0
				PUNPCKHBW xmm11, xmm0		; desempaqueta entonces xmm11: 12,  9,  4,  4,  9, 12,  9,  4
				PUNPCKHWD xmm11, xmm0		; desempaqueta entonces xmm11: 12,  9,  4,  4
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm7 como a xmm9
				MULPS xmm7, xmm11
				MULPS xmm9, xmm11
				
				MOVDQU xmm11, [smooth3]		; pone en xmm11: 0,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5
				PSLLDQ xmm11, 3				; xmm11: 15, 12,  5,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5, 0, 0, 0
				PUNPCKHBW xmm11, xmm0		; desempaqueta entonces xmm11: 15, 12,  5,  5, 12, 15, 12,  5
				PUNPCKHWD xmm11, xmm0		; desempaqueta entonces xmm11: 15, 12,  5,  5
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara sólo se aplica a xmm8
				MULPS xmm8, xmm11
				
				; suma todo lo calculado
				ADDPS xmm6, xmm7
				ADDPS xmm6, xmm8
				ADDPS xmm6, xmm9
				ADDPS xmm6, xmm10
				; se tiene xmm6: f1_15*5 + f2_15*12 + f3_15*15 + f4_15*12 + f5_15*5 | f1_14*4 + f2_14*9 + f3_14*12 + f4_14*9 + f5_14*4 | f1_13*2 + f2_13*5 + f3_13*5 + f4_13*4 + f5_13*2 | f1_12*2 + f2_12*4 + f3_12*5 + f4_12*4 + f5_12*2
				
				
				MOVDQU xmm11, xmm6			; el último resultado se lo pone en xmm11
				; se tiene: (col hace referencia a que se sumó todo lo de esa columna multipicado por la correspondiente máscara)
				; xmm14:	col3, 	XXXXX, 	XXXXX,	XXXXX
				; xmm13:	col7, 	col6, 	col5,	col4
				; xmm12:	col11,	col10,	col9,	col8
				; xmm11:	col15,	col14,	col13,	col12
			
				; Hay que armar los resultados para la posición 4 y la 9
				
				MOVDQU xmm6, xmm14			; pone en xmm6:	col3, XXXXX, XXXXX, XXXXX
				PSRLDQ xmm6, 12				; xmm6: 0, 0, 0, col3
				MOVDQU xmm8, xmm13			; pone en xmm8: col7, 	col6, 	col5,	col4
				ADDPS xmm6, xmm8			; suma float a float
				PSRLDQ xmm8, 4				; xmm8: 0, col7, 	col6, 	col5
				ADDPS xmm6, xmm8			; suma float a float
				PSRLDQ xmm8, 4				; xmm8: 0, 0, col7, col6
				ADDPS xmm6, xmm8			; suma float a float
				PSRLDQ xmm8, 4				; xmm8: 0, 0, 0, col7
				ADDPS xmm6, xmm8			; suma float a float
				MOVDQU xmm10, xmm6
				; xmm10: XXX | XXX | XXX | col7 + col6 + col5 + col4 + col3
				
				MOVDQU xmm6, xmm11			; pone en xmm6: col15, col14, col13, col12
				MOVDQU xmm7, xmm12			; pone en xmm7: col11, col10, col9, col8
				ADDPS xmm6, xmm7			; suma float a float
				PSRLDQ xmm7, 4				; xmm7: 0, col11, col10, col9
				ADDPS xmm6, xmm7			; suma float a float
				PSRLDQ xmm7, 4				; xmm7: 0, 0, col11, col10
				ADDPS xmm6, xmm7			; suma float a float
				PSRLDQ xmm7, 4				; xmm7: 0, 0, 0, col11
				ADDPS xmm6, xmm7			; suma float a float
				MOVDQU xmm9, xmm6
				; xmm9: XXX | XXX | XXX | col12 + col11 + col10 + col9 + col8
				
				PSLLDQ xmm10, 12				; xmm10: col7 + col6 + col5 + col4 + col3 | 0 | 0 | 0
				PSLLDQ xmm9, 12				; xmm10: col12 + col11 + col10 + col9 + col8 | 0 | 0 | 0
				PSRLDQ xmm10, 12				; xmm10: 0 | 0 | 0 | col7 + col6 + col5 + col4 + col3
				PSRLDQ xmm9, 8				; xmm10: 0 | 0 | col12 + col11 + col10 + col9 + col8 | 0
				ADDPS xmm10, xmm9
				MOVDQU xmm9, [mask159s]		; xmm11: 159 | 159 | 159 | 159
				CVTDQ2PS xmm9, xmm9			; los convierte a float
				DIVPS xmm10, xmm9			; divide a cada lugar por 159
				
				CVTPS2DQ xmm10, xmm10		; vuelve a entero
				PACKUSDW xmm10, xmm0			; xmm10: 0 | 0 | 0 | 0 | 0 | 0 | P9 | P4
				PACKUSWB xmm10, xmm0			; xmm10: 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | P9 | P4
				MOVDQU xmm12, xmm10			; copia a xmm12
				MOVDQU xmm13, xmm10			; copia a xmm13
				PSRLDQ xmm12, 1				; xmm12: 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | P9
				PSLLDQ xmm12, 15				; xmm12: P9 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0
				PSRLDQ xmm12, 7				; xmm12: 0 | 0 | 0 | 0 | 0 | 0 | 0 | P9 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0
				PSLLDQ xmm13, 15				; xmm13: P4 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0
				PSRLDQ xmm13, 12				; xmm13: 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | P4 | 0 | 0 | 0
				PADDB xmm15, xmm12
				PADDB xmm15, xmm13			; xmm15: 0 | 0 | 0 | 0 | P12 | P11 | 0 | P9 | P8 | P7 | P6 | 0 | P4 | P3 | P2 | P1
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			; Posiciones de procesado:
			; X    X    P12    P11    P10    P9    P8    P7    P6    P5    P4   P3   P2   P1    X    X
			
			; Se procesan la 5 y la 10
			
				; PRIMEROS CUATRO
				
				; NO HACEN FALTA PORQUE SON TODAS POSICIONES CON 0's QUE NO APORTAN NADA
			
			
			
				; SEGUNDOS CUATRO
				
				MOVDQU xmm6, xmm1				; pone en xmm6 la primer fila
				PUNPCKLBW xmm6, xmm0			; deja en xmm6 la parte baja de la primer fila
				MOVDQU xmm7, xmm2				; pone en xmm7 la segunda fila
				PUNPCKLBW xmm7, xmm0			; deja en xmm7 la parte baja de la segunda fila
				MOVDQU xmm8, xmm3				; pone en xmm8 la tercera fila
				PUNPCKLBW xmm8, xmm0			; deja en xmm8 la parte baja de la tercera fila
				MOVDQU xmm9, xmm4				; pone en xmm9 la cuarta fila
				PUNPCKLBW xmm9, xmm0			; deja en xmm9 la parte baja de la cuarta fila
				MOVDQU xmm10, xmm5				; pone en xmm10 la quinta fila
				PUNPCKLBW xmm10, xmm0			; deja en xmm10 la parte baja de la quinta fila
				
				; se tiene
				; xmm6:  f1_7 | f1_6 | f1_5 | f1_4 | f1_3 | f1_2 | f1_1 | f1_0
				; xmm7:  f2_7 | f2_6 | f2_5 | f2_4 | f2_3 | f2_2 | f2_1 | f2_0
				; xmm8:  f3_7 | f3_6 | f3_5 | f3_4 | f3_3 | f3_2 | f3_1 | f3_0
				; xmm9:  f4_7 | f4_6 | f4_5 | f4_4 | f4_3 | f4_2 | f4_1 | f4_0
				; xmm10: f5_7 | f5_6 | f5_5 | f5_4 | f5_3 | f5_2 | f5_1 | f5_0
				
				PUNPCKHWD xmm6, xmm0			; deja en xmm6 la parte alta de la baja de la primer fila
				PUNPCKHWD xmm7, xmm0			; deja en xmm7 la parte alta de la baja de la segunda fila
				PUNPCKHWD xmm8, xmm0			; deja en xmm8 la parte alta de la baja de la tercera fila
				PUNPCKHWD xmm9, xmm0			; deja en xmm9 la parte alta de la baja de la cuarta fila
				PUNPCKHWD xmm10, xmm0			; deja en xmm10 la parte alta de la baja de la quinta fila
				
				; se tiene
				; xmm6:  f1_7 | f1_6 | f1_5 | f1_4
				; xmm7:  f2_7 | f2_6 | f2_5 | f2_4
				; xmm8:  f3_7 | f3_6 | f3_5 | f3_4
				; xmm9:  f4_7 | f4_6 | f4_5 | f4_4
				; xmm10: f5_7 | f5_6 | f5_5 | f5_4
				
				CVTDQ2PS xmm6, xmm6				; pasa los valores a float
				CVTDQ2PS xmm7, xmm7				; pasa los valores a float
				CVTDQ2PS xmm8, xmm8				; pasa los valores a float
				CVTDQ2PS xmm9, xmm9				; pasa los valores a float
				CVTDQ2PS xmm10, xmm10			; pasa los valores a float
				
				; obtiene las partes de las máscaras que se usan
				MOVDQU xmm11, [smooth1]		; pone en xmm11: 0,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2
				PSLLDQ xmm11, 4				; xmm11: 4,	2,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2, 0, 0, 0, 0
				PUNPCKLBW xmm11, xmm0		; desempaqueta entonces xmm11: 4,	5,	4,	2, 0, 0, 0, 0
				PUNPCKHWD xmm11, xmm0		; desempaqueta entonces xmm11: 4,	5,	4,	2
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm6 como a xmm10
				MULPS xmm6, xmm11
				MULPS xmm10, xmm11
				
				MOVDQU xmm11, [smooth2]		; pone en xmm11: 0,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4
				PSLLDQ xmm11, 4				; xmm11: 9,  4,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4, 0, 0, 0, 0
				PUNPCKLBW xmm11, xmm0		; desempaqueta entonces xmm11: 9, 12,  9,  4, 0, 0, 0, 0
				PUNPCKHWD xmm11, xmm0		; desempaqueta entonces xmm11: 9, 12,  9,  4
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm7 como a xmm9
				MULPS xmm7, xmm11
				MULPS xmm9, xmm11
				
				MOVDQU xmm11, [smooth3]		; pone en xmm11: 0,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5
				PSLLDQ xmm11, 4				; xmm11: 12,  5,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5, 0, 0, 0, 0
				PUNPCKLBW xmm11, xmm0		; desempaqueta entonces xmm11: 12, 15, 12,  5, 0, 0, 0, 0
				PUNPCKHWD xmm11, xmm0		; desempaqueta entonces xmm11: 12, 15, 12,  5
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara sólo se aplica a xmm8
				MULPS xmm8, xmm11
				
				; suma todo lo calculado
				ADDPS xmm6, xmm7
				ADDPS xmm6, xmm8
				ADDPS xmm6, xmm9
				ADDPS xmm6, xmm10
				; se tiene xmm6: f1_7*4 + f2_7*9 + f3_7*12 + f4_7*9 + f5_7*4 | f1_6*5 + f2_6*12 + f3_6*15 + f4_6*12 + f5_6*5 | f1_5*4 + f2_5*9 + f3_5*12 + f4_5*9 + f5_5*4 | f1_4*2 + f2_4*4 + f3_4*5 + f4_4*4 + f5_4*2
				MOVDQU xmm13, xmm6			; guarda el resultado en xmm13




				; TERCEROS CUATRO
				
				MOVDQU xmm6, xmm1				; pone en xmm6 la primer fila
				PUNPCKHBW xmm6, xmm0			; deja en xmm6 la parte alta de la primer fila
				MOVDQU xmm7, xmm2				; pone en xmm7 la segunda fila
				PUNPCKHBW xmm7, xmm0			; deja en xmm7 la parte alta de la segunda fila
				MOVDQU xmm8, xmm3				; pone en xmm8 la tercera fila
				PUNPCKHBW xmm8, xmm0			; deja en xmm8 la parte alta de la tercera fila
				MOVDQU xmm9, xmm4				; pone en xmm9 la cuarta fila
				PUNPCKHBW xmm9, xmm0			; deja en xmm9 la parte alta de la cuarta fila
				MOVDQU xmm10, xmm5				; pone en xmm10 la quinta fila
				PUNPCKHBW xmm10, xmm0			; deja en xmm10 la parte alta de la quinta fila
				
				; se tiene
				; xmm6:  f1_15 | f1_14 | f1_13 | f1_12 | f1_11 | f1_10 | f1_9 | f1_8
				; xmm7:  f2_15 | f2_14 | f2_13 | f2_12 | f2_11 | f2_10 | f2_9 | f2_8
				; xmm8:  f3_15 | f3_14 | f3_13 | f3_12 | f3_11 | f3_10 | f3_9 | f3_8
				; xmm9:  f4_15 | f4_14 | f4_13 | f4_12 | f4_11 | f4_10 | f4_9 | f4_8
				; xmm10: f5_15 | f5_14 | f5_13 | f5_12 | f5_11 | f5_10 | f5_9 | f5_8
				
				PUNPCKLWD xmm6, xmm0			; deja en xmm6 la parte baja de la alta de la primer fila
				PUNPCKLWD xmm7, xmm0			; deja en xmm7 la parte baja de la alta de la segunda fila
				PUNPCKLWD xmm8, xmm0			; deja en xmm8 la parte baja de la alta de la tercera fila
				PUNPCKLWD xmm9, xmm0			; deja en xmm9 la parte baja de la alta de la cuarta fila
				PUNPCKLWD xmm10, xmm0			; deja en xmm10 la parte baja de la alta de la quinta fila
				
				; se tiene
				; xmm6:  f1_11 | f1_10 | f1_9 | f1_8
				; xmm7:  f2_11 | f2_10 | f2_9 | f2_8
				; xmm8:  f3_11 | f3_10 | f3_9 | f3_8
				; xmm9:  f4_11 | f4_10 | f4_9 | f4_8
				; xmm10: f5_11 | f5_10 | f5_9 | f5_8
				
				CVTDQ2PS xmm6, xmm6				; pasa los valores a float
				CVTDQ2PS xmm7, xmm7				; pasa los valores a float
				CVTDQ2PS xmm8, xmm8				; pasa los valores a float
				CVTDQ2PS xmm9, xmm9				; pasa los valores a float
				CVTDQ2PS xmm10, xmm10			; pasa los valores a float
				
				; obtiene las partes de las máscaras que se usan
				MOVDQU xmm11, [smooth1]		; pone en xmm11: 0,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2
				PSLLDQ xmm11, 4				; xmm11: 4,	2,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2, 0, 0, 0, 0
				PUNPCKHBW xmm11, xmm0		; desempaqueta entonces xmm11: 4,	2,	2,	4,	5,	4,	2,	2
				PUNPCKLWD xmm11, xmm0		; desempaqueta entonces xmm11: 5,	4,	2,	2
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm6 como a xmm10
				MULPS xmm6, xmm11
				MULPS xmm10, xmm11
				
				MOVDQU xmm11, [smooth2]		; pone en xmm11: 0,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4
				PSLLDQ xmm11, 4				; xmm11: 9,  4,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4, 0, 0, 0, 0
				PUNPCKHBW xmm11, xmm0		; desempaqueta entonces xmm11: 9,  4,  4,  9, 12,  9,  4,  4
				PUNPCKLWD xmm11, xmm0		; desempaqueta entonces xmm11: 12,  9,  4,  4
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm7 como a xmm9
				MULPS xmm7, xmm11
				MULPS xmm9, xmm11
				
				MOVDQU xmm11, [smooth3]		; pone en xmm11: 0,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5
				PSLLDQ xmm11, 4				; xmm11: 12,  5,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5, 0, 0, 0, 0
				PUNPCKHBW xmm11, xmm0		; desempaqueta entonces xmm11: 12,  5,  5, 12, 15, 12,  5,  5
				PUNPCKLWD xmm11, xmm0		; desempaqueta entonces xmm11: 15, 12,  5,  5
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara sólo se aplica a xmm8
				MULPS xmm8, xmm11
				
				; suma todo lo calculado
				ADDPS xmm6, xmm7
				ADDPS xmm6, xmm8
				ADDPS xmm6, xmm9
				ADDPS xmm6, xmm10
				; se tiene xmm6: f1_11*5 + f2_11*12 + f3_11*15 + f4_11*12 + f5_11*5 | f1_10*4 + f2_10*9 + f3_10*12 + f4_10*9 + f5_10*4 | f1_9*2 + f2_9*4 + f3_9*5 + f4_9*4 + f5_9*2 | f1_8*2 + f2_8*4 + f3_8*5 + f4_8*4 + f5_8*2
				MOVDQU xmm12, xmm6			; guarda el resultado en xmm12




				; CUARTOS CUATRO
				
				MOVDQU xmm6, xmm1				; pone en xmm6 la primer fila
				PUNPCKHBW xmm6, xmm0			; deja en xmm6 la parte alta de la primer fila
				MOVDQU xmm7, xmm2				; pone en xmm7 la segunda fila
				PUNPCKHBW xmm7, xmm0			; deja en xmm7 la parte alta de la segunda fila
				MOVDQU xmm8, xmm3				; pone en xmm8 la tercera fila
				PUNPCKHBW xmm8, xmm0			; deja en xmm8 la parte alta de la tercera fila
				MOVDQU xmm9, xmm4				; pone en xmm9 la cuarta fila
				PUNPCKHBW xmm9, xmm0			; deja en xmm9 la parte alta de la cuarta fila
				MOVDQU xmm10, xmm5				; pone en xmm10 la quinta fila
				PUNPCKHBW xmm10, xmm0			; deja en xmm10 la parte alta de la quinta fila
				
				; se tiene
				; xmm6:  f1_15 | f1_14 | f1_13 | f1_12 | f1_11 | f1_10 | f1_9 | f1_8
				; xmm7:  f2_15 | f2_14 | f2_13 | f2_12 | f2_11 | f2_10 | f2_9 | f2_8
				; xmm8:  f3_15 | f3_14 | f3_13 | f3_12 | f3_11 | f3_10 | f3_9 | f3_8
				; xmm9:  f4_15 | f4_14 | f4_13 | f4_12 | f4_11 | f4_10 | f4_9 | f4_8
				; xmm10: f5_15 | f5_14 | f5_13 | f5_12 | f5_11 | f5_10 | f5_9 | f5_8
				
				PUNPCKHWD xmm6, xmm0			; deja en xmm6 la parte alta de la alta de la primer fila
				PUNPCKHWD xmm7, xmm0			; deja en xmm7 la parte alta de la alta de la segunda fila
				PUNPCKHWD xmm8, xmm0			; deja en xmm8 la parte alta de la alta de la tercera fila
				PUNPCKHWD xmm9, xmm0			; deja en xmm9 la parte alta de la alta de la cuarta fila
				PUNPCKHWD xmm10, xmm0			; deja en xmm10 la parte alta de la alta de la quinta fila
				
				; se tiene
				; xmm6:  f1_15 | f1_14 | f1_13 | f1_12
				; xmm7:  f2_15 | f2_14 | f2_13 | f2_12
				; xmm8:  f3_15 | f3_14 | f3_13 | f3_12
				; xmm9:  f4_15 | f4_14 | f4_13 | f4_12
				; xmm10: f5_15 | f5_14 | f5_13 | f5_12
				
				CVTDQ2PS xmm6, xmm6				; pasa los valores a float
				CVTDQ2PS xmm7, xmm7				; pasa los valores a float
				CVTDQ2PS xmm8, xmm8				; pasa los valores a float
				CVTDQ2PS xmm9, xmm9				; pasa los valores a float
				CVTDQ2PS xmm10, xmm10			; pasa los valores a float
				
				; obtiene las partes de las máscaras que se usan
				MOVDQU xmm11, [smooth1]		; pone en xmm11: 0,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2
				PSLLDQ xmm11, 4				; xmm11: 4,	2,	2,	4,	5,	4,	2,	2,	4,	5,	4,	2, 0, 0, 0, 0
				PUNPCKHBW xmm11, xmm0		; desempaqueta entonces xmm11: 4,	2,	2,	4,	5,	4,	2,	2
				PUNPCKHWD xmm11, xmm0		; desempaqueta entonces xmm11: 4,	2,	2,	4
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm6 como a xmm10
				MULPS xmm6, xmm11
				MULPS xmm10, xmm11
				
				MOVDQU xmm11, [smooth2]		; pone en xmm11: 0,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4
				PSLLDQ xmm11, 4				; xmm11: 9,  4,  4,  9, 12,  9,  4,  4,  9, 12,  9,  4, 0, 0, 0, 0
				PUNPCKHBW xmm11, xmm0		; desempaqueta entonces xmm11: 9,  4,  4,  9, 12,  9,  4,  4
				PUNPCKHWD xmm11, xmm0		; desempaqueta entonces xmm11: 9,  4,  4,  9
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara se aplica tanto a xmm7 como a xmm9
				MULPS xmm7, xmm11
				MULPS xmm9, xmm11
				
				MOVDQU xmm11, [smooth3]		; pone en xmm11: 0,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5
				PSLLDQ xmm11, 4				; xmm11: 12,  5,  5, 12, 15, 12,  5,  5, 12, 15, 12,  5, 0, 0, 0, 0
				PUNPCKHBW xmm11, xmm0		; desempaqueta entonces xmm11: 12,  5,  5, 12, 15, 12,  5,  5
				PUNPCKHWD xmm11, xmm0		; desempaqueta entonces xmm11: 12,  5,  5, 12
				CVTDQ2PS xmm11, xmm11		; convierte a float para operar
				; esa máscara sólo se aplica a xmm8
				MULPS xmm8, xmm11
				
				; suma todo lo calculado
				ADDPS xmm6, xmm7
				ADDPS xmm6, xmm8
				ADDPS xmm6, xmm9
				ADDPS xmm6, xmm10
				; se tiene xmm6: f1_15*4 + f2_15*9 + f3_15*12 + f4_15*9 + f5_15*4 | f1_14*2 + f2_14*4 + f3_14*5 + f4_14*4 + f5_14*2 | f1_13*2 + f2_13*5 + f3_13*5 + f4_13*4 + f5_13*2 | f1_12*4 + f2_12*9 + f3_12*12 + f4_12*9 + f5_12*4
				
				
				MOVDQU xmm11, xmm6			; el último resultado se lo pone en xmm11
				; se tiene: (col hace referencia a que se sumó todo lo de esa columna multipicado por la correspondiente máscara)
				; xmm13:	col7, 	col6, 	col5,	col4
				; xmm12:	col11,	col10,	col9,	col8
				; xmm11:	col15,	col14,	col13,	col12
			
				; Hay que armar los resultados para la posición 5 y la 10
				
				MOVDQU xmm6, xmm12			; pone en xmm6:	col11, col10, col9, col8
				MOVDQU xmm8, xmm13			; pone en xmm8: col7, 	col6, 	col5,	col4
				ADDPS xmm6, xmm8			; suma float a float
				PSRLDQ xmm8, 4				; xmm8: 0, col7, 	col6, 	col5
				ADDPS xmm6, xmm8			; suma float a float
				PSRLDQ xmm8, 4				; xmm8: 0, 0, col7, col6
				ADDPS xmm6, xmm8			; suma float a float
				PSRLDQ xmm8, 4				; xmm8: 0, 0, 0, col7
				ADDPS xmm6, xmm8			; suma float a float
				MOVDQU xmm10, xmm6
				; xmm10: XXX | XXX | XXX | col8 + col7 + col6 + col5 + col4
				
				MOVDQU xmm6, xmm11			; pone en xmm6: col15, col14, col13, col12
				MOVDQU xmm7, xmm12			; pone en xmm7: col11, col10, col9, col8
				MOVDQU xmm8, xmm11			; pone en xmm8: col15, col14, col13, col12
				PSRLDQ xmm8, 4				; xmm8: 0, col15, col14, col13
				ADDPS xmm6, xmm8			; suma float a float
				PSRLDQ xmm7, 4				; xmm7: 0, col11, col10, col9
				ADDPS xmm6, xmm7			; suma float a float
				PSRLDQ xmm7, 4				; xmm7: 0, 0, col11, col10
				ADDPS xmm6, xmm7			; suma float a float
				PSRLDQ xmm7, 4				; xmm7: 0, 0, 0, col11
				ADDPS xmm6, xmm7			; suma float a float
				MOVDQU xmm9, xmm6
				; xmm9: XXX | XXX | XXX | col13 + col12 + col11 + col10 + col9
				
				PSLLDQ xmm10, 12				; xmm10: col8 + col7 + col6 + col5 + col4 | 0 | 0 | 0
				PSLLDQ xmm9, 12				; xmm9: col13 + col12 + col11 + col10 + col9 | 0 | 0 | 0
				PSRLDQ xmm10, 12				; xmm10: 0 | 0 | 0 | col8 + col7 + col6 + col5 + col4
				PSRLDQ xmm9, 8				; xmm9: 0 | 0 | col13 + col12 + col11 + col10 + col9 | 0
				ADDPS xmm10, xmm9
				MOVDQU xmm9, [mask159s]		; xmm9: 159 | 159 | 159 | 159
				CVTDQ2PS xmm9, xmm9			; los convierte a float
				DIVPS xmm10, xmm9			; divide a cada lugar por 159
				
				CVTPS2DQ xmm10, xmm10		; vuelve a entero
				PACKUSDW xmm10, xmm0			; xmm10: 0 | 0 | 0 | 0 | 0 | 0 | P10 | P5
				PACKUSWB xmm10, xmm0			; xmm10: 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | P10 | P5
				MOVDQU xmm12, xmm10			; copia a xmm12
				MOVDQU xmm13, xmm10			; copia a xmm13
				PSRLDQ xmm12, 1				; xmm12: 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | P10
				PSLLDQ xmm12, 15				; xmm12: P10 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0
				PSRLDQ xmm12, 6				; xmm12: 0 | 0 | 0 | 0 | 0 | 0 | P10 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0
				PSLLDQ xmm13, 15				; xmm13: P5 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0
				PSRLDQ xmm13, 11				; xmm13: 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | P5 | 0 | 0 | 0 | 0
				PADDB xmm15, xmm12
				PADDB xmm15, xmm13			; xmm15: 0 | 0 | 0 | 0 | P12 | P11 | P10 | P9 | P8 | P7 | P6 | P5 | P4 | P3 | P2 | P1

				MOVDQU [r13], xmm15			; imprime
		
			ADD r14, 12						; avanza el iterador 12 bytes (cantidad procesada en este caso)
			ADD r13, 12						; avanza el iterador 12 bytes (cantidad procesada en este caso)
			SUB r11, 12						; resta 12 columnas (cantidad procesadas en este caso)
			JMP .cicloPorColumna

		.actualizarFinal:
			MOV r12, 16
			SUB r12, r11					; r12 tiene lo que hay que retroceder para procesar justo para que queden 16
			ADD r11, r12					; actualiza la cantidad de columnas
			SUB r14, r12					; actualiza el src
			SUB r13, r12					; actualiza el dst
			JMP .cicloPorColumna
			
		.actualizarFinalNegroPrimera:
			MOV r12, 16
			SUB r12, r11					; r12 tiene lo que hay que retroceder para procesar justo para que queden 16
			ADD r11, r12					; actualiza la cantidad de columnas
			SUB r14, r12					; actualiza el src
			SUB r13, r12					; actualiza el dst
			JMP .primeraFila	

		.actualizarFinalNegroSegunda:
			MOV r12, 16
			SUB r12, r11					; r12 tiene lo que hay que retroceder para procesar justo para que queden 16
			ADD r11, r12					; actualiza la cantidad de columnas
			SUB r14, r12					; actualiza el src
			SUB r13, r12					; actualiza el dst
			JMP .segundaFila
			
		.actualizarFinalNegroAnte:
			MOV r12, 16
			SUB r12, r11					; r12 tiene lo que hay que retroceder para procesar justo para que queden 16
			ADD r11, r12					; actualiza la cantidad de columnas
			SUB r14, r12					; actualiza el src
			SUB r13, r12					; actualiza el dst
			JMP .anteUltimaFila
			
		.actualizarFinalNegroUltima:
			MOV r12, 16
			SUB r12, r11					; r12 tiene lo que hay que retroceder para procesar justo para que queden 16
			ADD r11, r12					; actualiza la cantidad de columnas
			SUB r14, r12					; actualiza el src
			SUB r13, r12					; actualiza el dst
			JMP .ultimaFila
			
	
		.cambiarDeFila:
			ADD rdi, r8						; suma al src su row_size para ubicarlo en la siguiente fila
			ADD rsi, r9						; suma al dst su row_size para ubicarlo en la siguiente fila
			DEC edx							; resta 1 fila
			JMP .cicloPorFila


		.final:
		PXOR xmm0, xmm0				; limpia xmm0
		.anteUltimaFila:
			CMP r11, 0					; compara para ver si ya miró todas las columnas
			JE .pasaAUltima
			CMP r11, 16					; compara para ver si queda un tamaño menor al de procesado (16 en este caso)
			JL .actualizarFinalNegroAnte
			MOVDQU [r13], xmm0			; imprime en memoria todo 0's
			ADD r13, 16					; adelanta el puntero a destino 16 bytes
			SUB r11, 16					; disminuye la cantidad de columnas por procesar
			JMP .anteUltimaFila

		.pasaAUltima:
			ADD rsi, r9					; pasa destino a la siguiente fila
			MOV r13, rsi				; pone en r13 al destino
			MOV r11, rcx				; mueve la cantidad de columnas a r11
		.ultimaFila:
			CMP r11, 0					; compara para ver si ya miró todas las columnas
			JE .salir
			CMP r11, 16					; compara para ver si queda un tamaño menor al de procesado (16 en este caso)
			JL .actualizarFinalNegroUltima
			MOVDQU [r13], xmm0			; imprime en memoria todo 0's
			ADD r13, 16					; adelanta el puntero a destino 16 bytes
			SUB r11, 16					; disminuye la cantidad de columnas por procesar
			JMP .ultimaFila	
				

	.salir:
	POP r12
	POP r13
	POP r14
	POP r15
	POP rbp

	RET
	
	
	
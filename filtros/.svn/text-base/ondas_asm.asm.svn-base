; void ondas_asm (
; 	unsigned char *src,
; 	unsigned char *dst,
; 	int m,
; 	int n,
; 	int row_size
; );

global ondas_asm

section .data
mask: DQ 0x00000000FFFFFFFF
mask0123: DD 0x0,0x1,0x2,0x3
mask1111: DD 0x1,0x1,0x1,0x1
maskRadius: DD 0x23,0x23,0x23,0x23
maskWavelenght: DD 0x40,0x40,0x40,0x40
mask34: DD 0x22,0x22,0x22,0x22
mask10: DD 0xA,0xA,0xA,0xA
mask2: DD 0x2,0x2,0x2,0x2
mask31415: DD 0x7AB7,0x7AB7,0x7AB7,0x7AB7
mask10000: DD 0x2710,0x2710,0x2710,0x2710
mask6: DD 0x6,0x6,0x6,0x6
mask120: DD 0x78,0x78,0x78,0x78
mask5040: DD 0x13b0,0x13b0,0x13b0,0x13b0
mask64: DD 0x40, 0x40, 0x40, 0x40




section .text

ondas_asm:
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
	PUSH r13	

	MOV rax, [mask]			; pone en rax lo que se usa como máscara
	AND rdx, rax			; máscara a rdx para dejar la parte baja únicamente
	AND rcx, rax			; máscara a rcx para dejar la parte baja únicamente
	AND r8, rax 			; máscara a r8 para dejar la parte baja únicamente

	
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
	
	PXOR xmm10, xmm10		; limpia xmm10
	PXOR xmm11, xmm11		; limpia xmm11
	MOV rbx, r14			; pone en rbx a r14 (ancho/2, ancho/2)
	MOVQ xmm10, rbx			; pone en xmm10 a rbx
	MOVLHPS xmm10,xmm10		; deja en xmm10 a (ancho/2, ancho/2, ancho/2, ancho/2)
	MOV rbx, r15			; pone en rbx a r15 (altura/2, altura/2)
	MOVQ xmm11, rbx			; pone en xmm11 
	MOVLHPS xmm11,xmm11		; deja en xmm11 a (altura/2, altura/2, altura/2, altura/2)
	
	CVTDQ2PS xmm10, xmm10	; convierte los 4 integers en 4 simple floats
	CVTDQ2PS xmm11, xmm11	; convierte los 4 integers en 4 simple floats
	
	MOVUPS xmm12, [mask0123]
	CVTDQ2PS xmm12, xmm12	; convierte los ints en floats

	PXOR xmm13, xmm13		; limpia xmm13 y deja (0, 0, 0, 0)
	CVTDQ2PS xmm13, xmm13	; convierte los int 0, 0, 0, 0 en float (alto, alto, alto, alto)
	

	
cicloPorFilaO:
	CMP rdx, 0		; compara alto con h
	JE salirO
	MOV r14, rdi;
	MOV r13, rsi;
	MOV r11, rcx;
	
cicloPorColumnaO:
	CMP r11, 0; comparo para ver si ya miré todas las columnas
	JE cambiarDeFilaO
	CMP r11, 16; comparo para ver si estoy cerca del w
	JL redimensionarO	
				


	MOVDQU xmm0, [r14]		; carga en xmm0 16 bytes de src


	MOVDQU xmm1, xmm0			; limpia xmm1
	MOVDQU xmm2, xmm0			; limpia xmm2
	PXOR xmm0, xmm0
	PUNPCKHBW xmm1, xmm0
	PUNPCKLBW xmm2, xmm0
	
	MOVDQU xmm3, xmm1			; limpia xmm3
	MOVDQU xmm4, xmm1			; limpia xmm4
	PXOR xmm0, xmm0
	PUNPCKHWD xmm3, xmm0
	PUNPCKLWD xmm4, xmm0
	
	MOVDQU xmm5, xmm2			; limpia xmm5
	MOVDQU xmm6, xmm2			; limpia xmm6
	PXOR xmm0, xmm0
	PUNPCKHWD xmm5, xmm0
	PUNPCKLWD xmm6, xmm0
	
	CVTDQ2PS xmm3, xmm3		; convierte cada doubleword de entero en single float
	CVTDQ2PS xmm4, xmm4		; convierte cada doubleword de entero en single float
	CVTDQ2PS xmm5, xmm5		; convierte cada doubleword de entero en single float
	CVTDQ2PS xmm6, xmm6		; convierte cada doubleword de entero en single float

	MOV r10,1		;Muevo un 1 al contador de tandas


	HacerTandas:
			; Calcula d_xy
			MOVDQU xmm7, xmm12		; carga en xmm7 los anchos
			MOVDQU xmm8, xmm13		; carga en xmm8 los altos
			SUBPS xmm7, xmm10		; deja en xmm7 a x - x_0 para cada posición
			SUBPS xmm8, xmm11		; deja en xmm8 a y - y_0 para cada posición
			MULPS xmm7, xmm7		; eleva al duadrado a d_x
			MULPS xmm8, xmm8		; eleva al duadrado a d_y
			ADDPS xmm7, xmm8		; suma d_x con d_y
			SQRTPS xmm7, xmm7		; deja en xmm7 la raiz cuadrada de (d_x + d_y)
			
			; Calcula r
			MOVUPS xmm8, [maskRadius]	; carga 35, 35, 35, 35 como ints
			CVTDQ2PS xmm8, xmm8		; convierte los ints en floats
			SUBPS xmm7, xmm8		; deja en xmm7 a d_xy - radius
			MOVUPS xmm8, [maskWavelenght] ; carga wavlenghts 4 veces como ints
			CVTDQ2PS xmm8, xmm8		; convierte los ints a floats
			DIVPS xmm7, xmm8		; deja en xmm7 a r = (d_xy - radius)/wavelenght
			
			; Calcula a
			MOVDQU xmm8, xmm7		; carga a r en xmm8
			MOVUPS xmm9, [mask34]	; carga 34, 34, 34, 34 como ints
			CVTDQ2PS xmm9, xmm9		; convierte los ints en floats
			MOVUPS xmm15, [mask10]	; carga 10, 10, 10, 10 como ints
			CVTDQ2PS xmm15, xmm15	; convierte los ints en floats

			DIVPS xmm9, xmm15		; deja en xmm9 a 3.4, 3.4, 3.4, 3.4
			DIVPS xmm8, xmm9		; pone en xmm8 a r/trainwidth
			MULPS xmm8, xmm8		; pone en xmm8 a (r/trainwidth)^2
			
			MOVUPS xmm9, [mask1111]	; carga 1, 1, 1, 1 como ints
			CVTDQ2PS xmm9, xmm9		; convierte los ints en floats
			
			ADDPS xmm8, xmm9		; pone en xmm8 a 1 + (r/trainwidth)^2z
			RCPPS xmm8, xmm8		; pone en xmm8 a a = 1 / (1 + (r/trainwidth)^2)
			
			; Calcula r - floor(r)
			MOVDQU xmm9, xmm7		; pone en xmm7 a r
			ROUNDPS xmm9, xmm9, 01B	; pone en xmm9 a cada valor de xmm7 redondeado hacia -inf (floor)
			SUBPS xmm7, xmm9		; pone en xmm7 a r - floor(r)
			;Multiplica por 2
			MOVUPS xmm9, [mask2]	; carga 2, 2, 2, 2 como ints
			CVTDQ2PS xmm9, xmm9		; convierte los ints en floats
			MULPS xmm7, xmm9		; multiplica por 2 a cada parte
			;Calcula pi
			MOVUPS xmm9, [mask31415]; carga 31415, 31415, 31415, 31415 como ints
			CVTDQ2PS xmm9, xmm9		; convierte los ints en floats
			
			MOVUPS xmm15, [mask10000]; carga 10000, 10000, 10000, 10000 como ints
			CVTDQ2PS xmm15, xmm15	; convierte los ints en floats
			
			DIVPS xmm9, xmm15		; deja en xmm9 a 3.1415, 3.1415, 3.1415, 3.1415
			
			; Calcula t = (r - floor(r))*2*pi - pi
			MULPS xmm7, xmm9		; pone en xmm7 a (r - floor(r))*2*pi
			SUBPS xmm7, xmm9		; deja en xmm7 a (r - floor(r))*2*pi - pi

			; Calcula t^3 t^5 t^7
			MOVDQU xmm14, xmm7		; pone en xmm14 a t
			MULPS xmm7, xmm14		; pone en xmm7 a t^2
			MULPS xmm7, xmm14		; pone en xmm7 a t^3
			MOVDQU xmm9, xmm7		; guarda en xmm9 a t^3
			MULPS xmm7, xmm14		; pone en xmm7 a t^4
			MULPS xmm7, xmm14		; pone en xmm7 a t^5
			MOVDQU xmm15, xmm7		; guarda en xmm15 a t^5
			MULPS xmm7, xmm14		; pone en xmm7 a t^6
			MULPS xmm7, xmm14		; pone en xmm7 a t^7
			
			MOVUPS xmm1, [mask6]	; carga 6, 6, 6, 6 como ints
			CVTDQ2PS xmm1, xmm1		; convierte los ints en floats
			DIVPS xmm9, xmm1		; deja en xmm9 a (t^3) / 6
			MOVUPS xmm1, [mask120]	; carga 120, 120, 120, 120 como ints
			CVTDQ2PS xmm1, xmm1	; convierte los ints en floats
			DIVPS xmm15, xmm1		; deja en xmm15 a (t^5) / 120
			MOVUPS xmm1, [mask5040]	; carga 5040, 5040, 5040, 5040 como ints
			CVTDQ2PS xmm1, xmm1		; convierte los ints en floats
			DIVPS xmm7, xmm1		; deja en xmm7 a (t^7) / 5040	
			
			; Calcula prof
			ADDPS xmm15, xmm14		; carga en xmm15 a (t^5) / 120 + t
			SUBPS xmm15, xmm9		; carga en xmm15 a (t^5) / 120 + t - t^3 / 6
			SUBPS xmm15, xmm7		; carga en xmm15 a t - t^3 / 6 + t^5 / 120 - t^7 / 5040
			MULPS xmm8, xmm15		; guarda en xmm8 a prof = a*(x - t^3 / 6 + t^5 / 120 - t^7 / 5040)
			
			; Calcula prof*64
			MOVUPS xmm7, [mask64]	; carga 64, 64, 64, 64 como ints
			CVTDQ2PS xmm7, xmm7		; convierte los ints en floats
			
			MULPS xmm8, xmm7		; deja en xmm8 a prof*64
			; Suma prof*64 a la primera tanda


			CMP r10,1
			JE primerTanda
			CMP r10,2
			JE segundaTanda
			CMP r10,3
			JE tercerTanda
			JMP cuartaTanda

			primerTanda:
				ADDPS xmm6, xmm8		; carga en xmm8 a pixel = prof*64 + xmm3 que son los primeros 4 elementos
				INC r10; aumento el contador de tandas
				JMP siguienteTanda	

			segundaTanda:
				ADDPS xmm5, xmm8		; carga en xmm8 a pixel = prof*64 + xmm3 que son los primeros 4 elementos
				INC r10; aumento el contador de tandas
				JMP siguienteTanda	

			tercerTanda:
				ADDPS xmm4, xmm8		; carga en xmm8 a pixel = prof*64 + xmm3 que son los primeros 4 elementos
				INC r10; aumento el contador de tandas
				JMP siguienteTanda

			cuartaTanda:
				ADDPS xmm3, xmm8		; carga en xmm8 a pixel = prof*64 + xmm3 que son los primeros 4 elementos
				INC r10;


			siguienteTanda:
				MOVUPS xmm1, [mask1111]
				CVTDQ2PS xmm1, xmm1		; convierte los ints en floats
				ADDPS xmm12, xmm1
				ADDPS xmm12, xmm1
				ADDPS xmm12, xmm1
				ADDPS xmm12, xmm1
				CMP r10,5
				JL HacerTandas


	; Pasa los datos de float a int en byte nuevamente
	seguir:
	CVTPS2DQ xmm3, xmm3		; transforma cada float en integer
	CVTPS2DQ xmm4, xmm4		; transforma cada float en integer
	CVTPS2DQ xmm5, xmm5		; transforma cada float en integer
	CVTPS2DQ xmm6, xmm6		; transforma cada float en integer
	

	PACKSSDW xmm4, xmm3
	MOVDQU xmm1, xmm4
	PACKSSDW xmm6, xmm5
	MOVDQU xmm2, xmm6
	

	PACKUSWB xmm2, xmm1
	MOVDQU xmm0, xmm2
	
	MOVDQU [r13], xmm0		; pasa a dst el resultado
	
	ADD r13, 16				; pasa a los siguientes 16 bytes en rdi
	ADD r14, 16				; pasa a los siguientes bytes en rsi
	SUB r11, 16				; aumenta 'ancho' en 16
	JMP cicloPorColumnaO
		
redimensionarO:
			MOV r15, 16; rax finalmente va a tener el desplazamiento total
			SUB r15, r11; calculo el desplazamiento total (16 - (totalCol - procesCol))
			SUB r13, r15; atraso los iteradores
			SUB r14, r15;
			MOV r11, 16;

			MOV rax, r15            ; pasa momentáneamente rbx a rax
			SHL r15, 32                ; pone la parte baja en la parte alta
			ADD r15, rax            ; pone en la parte baja de rbx lo mismo que hay en la alta

            ; pone en la parte baja de rbx lo mismo que hay en la alta

			PXOR xmm0, xmm0        ; limpia xmm0
			MOVQ xmm0, r15        ; pone en xmm0 a rbx (la cantidad que hay que retroceder)
			MOVLHPS    xmm0, xmm0    ; deja en xmm0 a (cant_Retr, cant_Retr, cant_Retr, cant_Retr)
			MOVQ mm0, r15
			CVTDQ2PS xmm0, xmm0    ; convierte los valores a float
			SUBPS xmm12, xmm0    ; le resta a los x's de las posiciones la cantidad que se retrocede para que queden igual a la posición donde se está después de retroceder

			JMP cicloPorColumnaO

cambiarDeFilaO:
	LEA rdi, [rdi + r8]; sumo el row_size
	LEA rsi, [rsi + r8]; sumo el row_size
	DEC rdx; resto 1 fila
	

	MOVUPS xmm1, [mask1111]	; carga 1, 1, 1, 1 como ints
	CVTDQ2PS xmm1, xmm1		; convierte los ints en floats
	ADDPS xmm13, xmm1		; aumenta en 1 los altos

	MOVUPS xmm12, [mask0123]
	CVTDQ2PS xmm12, xmm12	; convierte los ints en floats
	
	JMP cicloPorFilaO		
	
salirO:
	POP r13
	POP r15
	POP r14
	POP rbx
	POP rbp	
	
	RET

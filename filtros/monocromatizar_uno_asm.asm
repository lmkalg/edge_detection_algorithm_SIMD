; void monocromatizar_uno_asm (
; 	unsigned char *src,
; 	unsigned char *dst,
; 	int h,
; 	int w, en pixels
; 	int src_row_size, en bytes
; 	int dst_row_size
; );



section .data
mask: DQ 0x00000000FFFFFFFF
maskPrimeroCuarto: DW 0xFFFF, 0x0000, 0x0000, 0xFFFF, 0x0000, 0x0000, 0x0000, 0x0000
maskPrimerosDos: DW 0xFFFF, 0xFFFF, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000

section .text

global monocromatizar_uno_asm

monocromatizar_uno_asm:
	; rdi --> *src/ puntero a src 
	; rsi --> *dst/ dst
	; rdx --> h/ cantidad de filas
	; rcx --> w/ columnas
	; r8 --> src_row size
	; r9 --> dst_row_size
	

	PUSH rbp				;				Alinea
	MOV rbp, rsp
	PUSH r13				; salva r13		Alinea
	PUSH r14				; salva r14		Desalinea
	
	MOV rax, [mask]			; pone en rax lo que se usa como máscara
	AND rdx, rax			; máscara a rdx para dejar la parte baja únicamente
	AND rcx, rax			; máscara a rcx para dejar la parte baja únicamente
	AND r8, rax 			; máscara a r8 para dejar la parte baja únicamente
	AND r9, rax 			; máscara a r9 para dejar la parte baja únicamente
	XOR r11,r11;
	XOR rax,rax;
	

	cicloPorFilaMU:
			CMP rdx, 0; para ver si termine de ciclar todas las filas
			JE salirMU

			MOV r11, rcx; muevo al cantidad de columnas a r11
			MOV r14, rdi; hago el iterador de columnas de srca
			MOV r13, rsi; hago el iterador de columnas de dst


			cicloPorColumnaMU:
			 	CMP r11, 0; comparo para ver si ya miré todas las columnas
				JE cambiarDeFilaMU
			 	CMP r11, 16; comparo para ver si estoy cerca del w
				JL redimensionarMU




;Primera tanda
	MOVDQU xmm0, [r14]		; pone en xmm0 la primera tirada de 16 bytes (|BGR, BGR, BGR, BGR|, BGR, B)
	PXOR xmm15, xmm15		; limpia xmm15
	MOVDQU xmm1, xmm0		; copia al xmm1 lo de memoria
	MOVDQU xmm2, xmm0		; copia al xmm2 lo de memoria
	PUNPCKLBW xmm1, xmm15	; pasa al xmm1 en tamaño word los primeros (|BGR, BGR|, BG)
	PSLLDQ xmm2, 2			; mueve dos bytes a derecha para que queden como parte baja los dos pixeles segundos o sea (00, BGR, BGR, |BGR, BGR|, BG)
	PUNPCKHBW xmm2, xmm15	; pasa al xmm1 en tamaño word los segundos (|BGR, BGR|, BG)
	
	; cálculo HIGH
	MOVDQU xmm3, xmm1		; pasa al xmm3 el xmm1 para operar
	PSRLDQ xmm3, 2			; mueve 2 bytes a izquierda (1 word, o sea una componente) queda (GR, BGR, BG0)
	PADDW xmm1, xmm3		; deja en el xmm1 la suma o sea (|B1+G1, G1+R1|, R1+B2, |B2+G2, G2+R2|, R2+B3, B3+G3, G3+0)
	MOVDQU xmm3, xmm1		; copia a xmm1 lo calculado antes
	PSRLDQ xmm3, 2			; mueve 2 bytes a izquierda (1 word, o sea una componente) queda (G1+R1, R1+B2, B2+G2, G2+R2, R2+B3, B3+G3, G3+0, 0)
	PADDW xmm1, xmm3		; deja en el xmm1 la suma o sea (|B1+G1+G1+R1|, G1+R1+R1+B2, R1+B2+B2+G2, |B2+G2+G2+R2|, G2+R2+R2+B3, R2+B3+B3+G3, B3+G3+G3+0, G3+0+0)
	PSRAW xmm1, 2			; mueve 2 bits en cada uno a derecha (o sea divide por 4 cada uno de los words)
	
	; cálculo LOW
	MOVDQU xmm3, xmm2		; pasa al xmm3 el xmm1 para operar
	PSRLDQ xmm3, 2			; mueve 2 bytes a izquierda (1 word, o sea una componente) queda (GR, BGR, BG0)
	PADDW xmm2, xmm3		; deja en el xmm1 la suma o sea (|B1+G1, G1+R1|, R1+B2, |B2+G2, G2+R2|, R2+B3, B3+G3, G3+0)
	MOVDQU xmm3, xmm2		; copia a xmm1 lo calculado antes
	PSRLDQ xmm3, 2			; mueve 2 bytes a izquierda (1 word, o sea una componente) queda (G1+R1, R1+B2, B2+G2, G2+R2, R2+B3, B3+G3, G3+0, 0)
	PADDW xmm2, xmm3		; deja en el xmm1 la suma o sea (|B1+G1+G1+R1|, G1+R1+R1+B2, R1+B2+B2+G2, |B2+G2+G2+R2|, G2+R2+R2+B3, R2+B3+B3+G3, B3+G3+G3+0, G3+0+0)
	PSRAW xmm2, 2			; mueve 2 bits en cada uno a derecha (o sea divide por 4 cada uno de los words)
	
		
	;máscaras
	MOVDQU xmm15, [maskPrimeroCuarto] ; pone en xmm15 la máscara para filtrar primero y cuarto
	PAND xmm1, xmm15		; aplica la máscara
	PAND xmm2, xmm15		; aplica la máscara
	
	MOVDQU xmm14, xmm1		; pone en xmm14 a xmm1
	PSRLDQ xmm14, 4			; mueve a izquierda 4 bytes (o sea 2 words)
	PADDW xmm1, xmm14		; deja en xmm1 (primero, segundo, basura, basura, basura, basura, basura, basura)
	MOVDQU xmm15, [maskPrimerosDos] ; pone en xmm15 la máscara para dejar sólo los primeros dos
	PAND xmm1, xmm15		; deja los primeros dos
	
	MOVDQU xmm14, xmm2		; pone en xmm14 a xmm2
	PSRLDQ xmm14, 4			; mueve a izquierda 4 bytes (o sea 2 words)
	PADDW xmm2, xmm14		; deja en xmm1 (primero, segundo, basura, basura, basura, basura, basura, basura)
	MOVDQU xmm15, [maskPrimerosDos] ; pone en xmm15 la máscara para dejar sólo los primeros dos
	PAND xmm2, xmm15		; deja los primeros dos
	
	PSLLDQ xmm2, 4			; deja los dos segundo en las posiciones 3 y 4
	PADDW xmm1, xmm2			; deja en xmm1 los datos (1, 2, 3, 4, 0, 0, 0, 0)
	MOVDQU xmm10, xmm1		; deja en xmm10 este registro para usarlo después
	
	
	; pasa a los siguientes 4 píxeles
	LEA r14, [r14+12]		; aumenta 12 bytes para pasar a los siguientes
	

;Segunda tanda
	MOVDQU xmm0, [r14]		; pone en xmm0 la primera tirada de 16 bytes (|BGR, BGR, BGR, BGR|, BGR, B)
	PXOR xmm15, xmm15		; limpia xmm15
	MOVDQU xmm1, xmm0		; copia al xmm1 lo de memoria
	MOVDQU xmm2, xmm0		; copia al xmm2 lo de memoria
	PUNPCKLBW xmm1, xmm15	; pasa al xmm1 en tamaño word los primeros (|BGR, BGR|, BG)
	PSLLDQ xmm2, 2			; mueve dos bytes a derecha para que queden como parte baja los dos pixeles segundos o sea (00, BGR, BGR, |BGR, BGR|, BG)
	PUNPCKHBW xmm2, xmm15	; pasa al xmm1 en tamaño word los segundos (|BGR, BGR|, BG)

	; cálculo HIGH
	MOVDQU xmm3, xmm1		; pasa al xmm3 el xmm1 para operar
	PSRLDQ xmm3, 2			; mueve 2 bytes a izquierda (1 word, o sea una componente) queda (GR, BGR, BG0)
	PADDW xmm1, xmm3		; deja en el xmm1 la suma o sea (|B1+G1, G1+R1|, R1+B2, |B2+G2, G2+R2|, R2+B3, B3+G3, G3+0)
	MOVDQU xmm3, xmm1		; copia a xmm1 lo calculado antes
	PSRLDQ xmm3, 2			; mueve 2 bytes a izquierda (1 word, o sea una componente) queda (G1+R1, R1+B2, B2+G2, G2+R2, R2+B3, B3+G3, G3+0, 0)
	PADDW xmm1, xmm3		; deja en el xmm1 la suma o sea (|B1+G1+G1+R1|, G1+R1+R1+B2, R1+B2+B2+G2, |B2+G2+G2+R2|, G2+R2+R2+B3, R2+B3+B3+G3, B3+G3+G3+0, G3+0+0)
	PSRAW xmm1, 2			; mueve 2 bits en cada uno a derecha (o sea divide por 4 cada uno de los words)
	
	; cálculo <LOW
	MOVDQU xmm3, xmm2		; pasa al xmm3 el xmm1 para operar
	PSRLDQ xmm3, 2			; mueve 2 bytes a izquierda (1 word, o sea una componente) queda (GR, BGR, BG0)
	PADDW xmm2, xmm3		; deja en el xmm1 la suma o sea (|B1+G1, G1+R1|, R1+B2, |B2+G2, G2+R2|, R2+B3, B3+G3, G3+0)
	MOVDQU xmm3, xmm2		; copia a xmm1 lo calculado antes
	PSRLDQ xmm3, 2			; mueve 2 bytes a izquierda (1 word, o sea una componente) queda (G1+R1, R1+B2, B2+G2, G2+R2, R2+B3, B3+G3, G3+0, 0)
	PADDW xmm2, xmm3		; deja en el xmm1 la suma o sea (|B1+G1+G1+R1|, G1+R1+R1+B2, R1+B2+B2+G2, |B2+G2+G2+R2|, G2+R2+R2+B3, R2+B3+B3+G3, B3+G3+G3+0, G3+0+0)
	PSRAW xmm2, 2			; mueve 2 bits en cada uno a derecha (o sea divide por 4 cada uno de los words)
	
	
			
	;máscaras
	MOVDQU xmm15, [maskPrimeroCuarto] ; pone en xmm15 la máscara para filtrar primero y cuarto
	PAND xmm1, xmm15		; aplica la máscara
	PAND xmm2, xmm15		; aplica la máscara
	
	MOVDQU xmm14, xmm1		; pone en xmm14 a xmm1
	PSRLDQ xmm14, 4			; mueve a izquierda 4 bytes (o sea 2 words)
	PADDW xmm1, xmm14		; deja en xmm1 (primero, segundo, basura, basura, basura, basura, basura, basura)
	MOVDQU xmm15, [maskPrimerosDos] ; pone en xmm15 la máscara para dejar sólo los primeros dos
	PAND xmm1, xmm15		; deja los primeros dos
	
	MOVDQU xmm14, xmm2		; pone en xmm14 a xmm2
	PSRLDQ xmm14, 4			; mueve a izquierda 4 bytes (o sea 2 words)
	PADDW xmm2, xmm14		; deja en xmm1 (primero, segundo, basura, basura, basura, basura, basura, basura)
	MOVDQU xmm15, [maskPrimerosDos] ; pone en xmm15 la máscara para dejar sólo los primeros dos
	PAND xmm2, xmm15		; deja los primeros dos
	
	PSLLDQ xmm2, 4			; deja los dos segundo en las posiciones 3 y 4
	PADDW xmm1, xmm2			; deja en xmm1 los datos (5, 6, 7, 8, 0, 0, 0, 0)
	PSLLDQ xmm1, 8			; pasa a derecha 8 bytes (words) para tener (0, 0, 0, 0, 5, 6, 7, 8)	
	PADDW xmm10, xmm1		; deja en xmm10 (1, 2, 3, 4, 5, 6, 7, 8)
	
	
		

	; pasa a los siguientes 4 píxeles
	LEA r14, [r14+12]		; aumenta 12 bytes para pasar a los siguientes
	
	
	
;Tercera tanda
	MOVDQU xmm0, [r14]		; pone en xmm0 la primera tirada de 16 bytes (|BGR, BGR, BGR, BGR|, BGR, B)
	PXOR xmm15, xmm15		; limpia xmm15
	MOVDQU xmm1, xmm0		; copia al xmm1 lo de memoria
	MOVDQU xmm2, xmm0		; copia al xmm2 lo de memoria
	PUNPCKLBW xmm1, xmm15	; pasa al xmm1 en tamaño word los primeros (|BGR, BGR|, BG)
	PSLLDQ xmm2, 2			; mueve dos bytes a derecha para que queden como parte baja los dos pixeles segundos o sea (00, BGR, BGR, |BGR, BGR|, BG)
	PUNPCKHBW xmm2, xmm15	; pasa al xmm1 en tamaño word los segundos (|BGR, BGR|, BG)
	
	
	; cálculo HIGH
	MOVDQU xmm3, xmm1		; pasa al xmm3 el xmm1 para operar
	PSRLDQ xmm3, 2			; mueve 2 bytes a izquierda (1 word, o sea una componente) queda (GR, BGR, BG0)
	PADDW xmm1, xmm3		; deja en el xmm1 la suma o sea (|B1+G1, G1+R1|, R1+B2, |B2+G2, G2+R2|, R2+B3, B3+G3, G3+0)
	MOVDQU xmm3, xmm1		; copia a xmm1 lo calculado antes
	PSRLDQ xmm3, 2			; mueve 2 bytes a izquierda (1 word, o sea una componente) queda (G1+R1, R1+B2, B2+G2, G2+R2, R2+B3, B3+G3, G3+0, 0)
	PADDW xmm1, xmm3		; deja en el xmm1 la suma o sea (|B1+G1+G1+R1|, G1+R1+R1+B2, R1+B2+B2+G2, |B2+G2+G2+R2|, G2+R2+R2+B3, R2+B3+B3+G3, B3+G3+G3+0, G3+0+0)
	PSRAW xmm1, 2			; mueve 2 bits en cada uno a derecha (o sea divide por 4 cada uno de los words)
	
	; cálculo LOW
	MOVDQU xmm3, xmm2		; pasa al xmm3 el xmm1 para operar
	PSRLDQ xmm3, 2			; mueve 2 bytes a izquierda (1 word, o sea una componente) queda (GR, BGR, BG0)
	PADDW xmm2, xmm3		; deja en el xmm1 la suma o sea (|B1+G1, G1+R1|, R1+B2, |B2+G2, G2+R2|, R2+B3, B3+G3, G3+0)
	MOVDQU xmm3, xmm2		; copia a xmm1 lo calculado antes
	PSRLDQ xmm3, 2			; mueve 2 bytes a izquierda (1 word, o sea una componente) queda (G1+R1, R1+B2, B2+G2, G2+R2, R2+B3, B3+G3, G3+0, 0)
	PADDW xmm2, xmm3		; deja en el xmm1 la suma o sea (|B1+G1+G1+R1|, G1+R1+R1+B2, R1+B2+B2+G2, |B2+G2+G2+R2|, G2+R2+R2+B3, R2+B3+B3+G3, B3+G3+G3+0, G3+0+0)
	PSRAW xmm2, 2			; mueve 2 bits en cada uno a derecha (o sea divide por 4 cada uno de los words)
	
	
			
	;máscaras
	MOVDQU xmm15, [maskPrimeroCuarto] ; pone en xmm15 la máscara para filtrar primero y cuarto
	PAND xmm1, xmm15		; aplica la máscara
	PAND xmm2, xmm15		; aplica la máscara
	
	MOVDQU xmm14, xmm1		; pone en xmm14 a xmm1
	PSRLDQ xmm14, 4			; mueve a izquierda 4 bytes (o sea 2 words)
	PADDW xmm1, xmm14		; deja en xmm1 (primero, segundo, basura, basura, basura, basura, basura, basura)
	MOVDQU xmm15, [maskPrimerosDos] ; pone en xmm15 la máscara para dejar sólo los primeros dos
	PAND xmm1, xmm15		; deja los primeros dos
	
	MOVDQU xmm14, xmm2		; pone en xmm14 a xmm2
	PSRLDQ xmm14, 4			; mueve a izquierda 4 bytes (o sea 2 words)
	PADDW xmm2, xmm14		; deja en xmm1 (primero, segundo, basura, basura, basura, basura, basura, basura)
	MOVDQU xmm15, [maskPrimerosDos] ; pone en xmm15 la máscara para dejar sólo los primeros dos
	PAND xmm2, xmm15		; deja los primeros dos
	
	PSLLDQ xmm2, 4			; deja los dos segundo en las posiciones 3 y 4
	PADDW xmm1, xmm2			; deja en xmm1 los datos (9, 10, 11, 12, 0, 0, 0, 0)
	MOVDQU xmm11, xmm1		; deja en xmm10 este registro para usarlo después



	
	
	; pasa a los siguientes 4 píxeles
	LEA r14, [r14+12]		; aumenta 12 bytes para pasar a los siguientes
	

;Cuarta tanda
	MOVDQU xmm0, [r14]		; pone en xmm0 la primera tirada de 16 bytes (|BGR, BGR, BGR, BGR|, BGR, B)
	PXOR xmm15, xmm15		; limpia xmm15
	MOVDQU xmm1, xmm0		; copia al xmm1 lo de memoria
	MOVDQU xmm2, xmm0		; copia al xmm2 lo de memoria
	PUNPCKLBW xmm1, xmm15	; pasa al xmm1 en tamaño word los primeros (|BGR, BGR|, BG)
	PSLLDQ xmm2, 2			; mueve dos bytes a derecha para que queden como parte baja los dos pixeles segundos o sea (00, BGR, BGR, |BGR, BGR|, BG)
	PUNPCKHBW xmm2, xmm15	; pasa al xmm1 en tamaño word los segundos (|BGR, BGR|, BG)
	
	
	; cálculo HIGH
	MOVDQU xmm3, xmm1		; pasa al xmm3 el xmm1 para operar
	PSRLDQ xmm3, 2			; mueve 2 bytes a izquierda (1 word, o sea una componente) queda (GR, BGR, BG0)
	PADDW xmm1, xmm3		; deja en el xmm1 la suma o sea (|B1+G1, G1+R1|, R1+B2, |B2+G2, G2+R2|, R2+B3, B3+G3, G3+0)
	MOVDQU xmm3, xmm1		; copia a xmm1 lo calculado antes
	PSRLDQ xmm3, 2			; mueve 2 bytes a izquierda (1 word, o sea una componente) queda (G1+R1, R1+B2, B2+G2, G2+R2, R2+B3, B3+G3, G3+0, 0)
	PADDW xmm1, xmm3		; deja en el xmm1 la suma o sea (|B1+G1+G1+R1|, G1+R1+R1+B2, R1+B2+B2+G2, |B2+G2+G2+R2|, G2+R2+R2+B3, R2+B3+B3+G3, B3+G3+G3+0, G3+0+0)
	PSRAW xmm1, 2			; mueve 2 bits en cada uno a derecha (o sea divide por 4 cada uno de los words)
	
	; cálculo LOW
	MOVDQU xmm3, xmm2		; pasa al xmm3 el xmm1 para operar
	PSRLDQ xmm3, 2			; mueve 2 bytes a izquierda (1 word, o sea una componente) queda (GR, BGR, BG0)
	PADDW xmm2, xmm3		; deja en el xmm1 la suma o sea (|B1+G1, G1+R1|, R1+B2, |B2+G2, G2+R2|, R2+B3, B3+G3, G3+0)
	MOVDQU xmm3, xmm2		; copia a xmm1 lo calculado antes
	PSRLDQ xmm3, 2			; mueve 2 bytes a izquierda (1 word, o sea una componente) queda (G1+R1, R1+B2, B2+G2, G2+R2, R2+B3, B3+G3, G3+0, 0)
	PADDW xmm2, xmm3		; deja en el xmm1 la suma o sea (|B1+G1+G1+R1|, G1+R1+R1+B2, R1+B2+B2+G2, |B2+G2+G2+R2|, G2+R2+R2+B3, R2+B3+B3+G3, B3+G3+G3+0, G3+0+0)
	PSRAW xmm2, 2			; mueve 2 bits en cada uno a derecha (o sea divide por 4 cada uno de los words)
	
	
			
	;máscaras
	MOVDQU xmm15, [maskPrimeroCuarto] ; pone en xmm15 la máscara para filtrar primero y cuarto
	PAND xmm1, xmm15		; aplica la máscara
	PAND xmm2, xmm15		; aplica la máscara
	
	MOVDQU xmm14, xmm1		; pone en xmm14 a xmm1
	PSRLDQ xmm14, 4			; mueve a izquierda 4 bytes (o sea 2 words)
	PADDW xmm1, xmm14		; deja en xmm1 (primero, segundo, basura, basura, basura, basura, basura, basura)
	MOVDQU xmm15, [maskPrimerosDos] ; pone en xmm15 la máscara para dejar sólo los primeros dos
	PAND xmm1, xmm15		; deja los primeros dos
	
	MOVDQU xmm14, xmm2		; pone en xmm14 a xmm2
	PSRLDQ xmm14, 4			; mueve a izquierda 4 bytes (o sea 2 words)
	PADDW xmm2, xmm14		; deja en xmm1 (primero, segundo, basura, basura, basura, basura, basura, basura)
	MOVDQU xmm15, [maskPrimerosDos] ; pone en xmm15 la máscara para dejar sólo los primeros dos
	PAND xmm2, xmm15		; deja los primeros dos
	
	PSLLDQ xmm2, 4			; deja los dos segundo en las posiciones 3 y 4
	PADDW xmm1, xmm2			; deja en xmm1 los datos (13, 14, 15, 16, 0, 0, 0, 0)
	PSLLDQ xmm1, 8			; pasa a derecha 8 bytes (words) para tener (0, 0, 0, 0, 13, 14, 15, 16)
	PADDW xmm11, xmm1		; deja en xmm10 (9, 10, 11, 12, 13, 14, 15, 16)
	
	; pasa a los siguientes 4 píxeles
	LEA r14, [r14+12]		; aumenta 12 bytes para pasar a los siguientes
	
		PACKUSWB xmm10, xmm11	; pone en xmm11 los words de xmm10 y xmm11 en ese orden pero ahora como bytes
		
	MOVDQU xmm0, xmm10		; pasa a xmm0 los datos a imprimir
	MOVDQU [r13], xmm0		; imprime en dst los datos
	
	LEA r13, [r13+16]		; pasa a los siguientes 16 del dst
	
	SUB r11, 16; resto 16 columna
	JMP cicloPorColumnaMU



	redimensionarMU:
					MOV rax, 16; Que es la cantidad de pixels que escribo en momoria
					SUB rax, r11; Resto la cant de columnas que me faltan procesar
					SUB r13, rax; Retrocedo en el dst la diferencia entre la cantidad de columnas que procese y 16
					SUB r14 ,rax;Retrocedo en el src diferencia*3 (porque 1 px = 3b)
					SUB r14 ,rax;
					SUB r14 ,rax;
					MOV r11,16; Para que termine justo
					JMP cicloPorColumnaMU


			cambiarDeFilaMU:
					LEA rdi, [rdi + r8]; sumo el row_size
					LEA rsi, [rsi + r9]; sumo el row_size
					DEC rdx; resto 1 fila
					JMP cicloPorFilaMU

 
	salirMU:
		POP r14
		POP r13
		POP rbp

		RET

;void recortar_asm (
;	unsigned char *src,
;	unsigned char *dst,
;	int m,
;	int n,
;	int src_row_size,
;	int dst_row_size,
;	int x,
;	int y,
;	int tam
;);

section .data
mask: DQ 0x00000000FFFFFFFF

section .text

global recortar_asm

recortar_asm:
	; *src en rdi
	; *dst en rsi
	; m en rdx
	; n en rcx
	; src_row_size en r8 
	; dst_row_size en r9
	; x el tope de pila
	; y el segundo en pila
	; tam el tercero en pila
	
	PUSH rbp;A
	MOV rbp,rsp;
	PUSH r15;D
	PUSH r14;A
	PUSH r13;D
	PUSH r12;A
	PUSH rbx;D
	SUB rsp, 8; A			; 				Alinea
	
	MOV r10, [rbp+16]		; pone en r10 a x
	MOV r11, [rbp+24]		; pone en r11 a y
	MOV r12, [rbp+32]		; pone en r12 a tam
	
	
	MOV rax, [mask]			; pone en rax lo que se usa como máscara
	AND r8, rax 			; máscara a r8 para dejar la parte baja únicamente
	AND r9, rax 			; máscara a r9 para dejar la parte baja únicamente
	AND r10, rax 			; máscara a r10 para dejar la parte baja únicamente
	AND r11, rax 			; máscara a r11 para dejar la parte baja únicamente
	AND r12, rax			; máscara a r12 para dejar la parte baja únicamente 
	XOR rax,rax				; limpia rax
	
	
	MOV rbx, r11			; pone en rbx el y
	IMUL rbx, r8			; deja en rbx a y*src_row_size
	ADD rbx, r10			; deja en rbx a y*src_row_size + x
	ADD rdi, rbx			; deja en rdi a src + y*src_row_size + x
	

	XOR r11, r11; 
	
	MOV ecx, r12d;

	cicloPorFila:
			CMP ecx, 0				; para ver si termine de ciclar todas las filas
			JE salir

			MOV r11d, r12d			; muevo al cantidad de columnas a r11
			MOV r14, rdi			; hago el iterador de columnas de src
			MOV r13, rsi			; hago el iterador de columnas de dst

			cicloPorColumna:
				CMP r11d, 0			; comparo para ver si ya miré todas las columnas
				JE cambiarDeFila
				CMP r11d, 16		; comparo para ver si estoy cerca del w
				JL redimensionar
				
			
				MOVDQU xmm1,[r14]	; paso a xmm1 los proximos
				MOVDQU [r13],xmm1	; escribo en dst

				ADD r14, 16			; avanzo iterador
				ADD r13, 16			; avanzo iterador
				SUB r11d, 16		; resto 16 columnas
				JMP cicloPorColumna


			redimensionar:
					MOV eax, 16		; eax finalmente va a tener el desplazamiento total
					SUB eax, r11d	; calculo el desplazamiento total (16 - (totalCol - procesCol))
					SUB r13, rax	; atraso los iteradores
					SUB r14, rax	;
					MOV r11d, 16	;
					JMP cicloPorColumna

			cambiarDeFila:
					LEA rdi, [rdi + r8]; sumo el src_row_size
					LEA rsi, [rsi + r9]; sumo el dst_row_size
					DEC ecx			; resto 1 fila
					JMP cicloPorFila

 
	salir:
	ADD rsp, 8
		POP rbx
		POP r12
		POP r13
		POP r14
		POP r15
		POP rbp

		RET

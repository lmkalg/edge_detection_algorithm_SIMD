; void monocromatizar_inf_asm (
; 	unsigned char *src,
; 	unsigned char *dst,
; 	int h,
; 	int w,
; 	int src_row_size,
; 	int dst_row_size
; );

global monocromatizar_inf_asm

section .data
mask: DQ 0x00000000FFFFFFFF
maskMaximos: DB 0xFF,0x00,0x00,0xFF,0x00,0x00,0xFF,0x00,0x00,0xFF,0x00,0x00,0x00,0x00,0x00,0x00
maskMaximosDeAPares: DB 0xFF,0xFF,0x00,0x00,0x00,0x00,0xFF,0xFF,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
maskMaximosUltimos: DB 0xFF,0xFF,0xFF,0xFF,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00	

section .text

monocromatizar_inf_asm:
	; rdi --> *src/ puntero a src 
	; rsi --> *dst/ dst
	; rdx --> h/ cantidad de filas
	; rcx --> w/ columnas
	; r8 --> src_row size
	; r9 --> dst_row_size
	

	PUSH rbp				;				Alinea
	MOV rbp, rsp
	PUSH r13				; salva r13		Desalinea
	PUSH r14				; salva r14		Alinea
	
	MOV rax, [mask]			; pone en rax lo que se usa como máscara
	AND rdx, rax			; máscara a rdx para dejar la parte baja únicamente
	AND rcx, rax			; máscara a rcx para dejar la parte baja únicamente
	AND r8, rax 			; máscara a r8 para dejar la parte baja únicamente
	AND r9, rax 			; máscara a r9 para dejar la parte baja únicamente
	XOR r11,r11;
	XOR rax,rax;


	MOVDQU xmm10, [maskMaximos] ; guardo la mascara para dejar pasar maximos 
	MOVDQU xmm11, [maskMaximosDeAPares];
	MOVDQU xmm12, [maskMaximosUltimos]
	


	cicloPorFilaMI:
		CMP rdx, 0; para ver si termine de ciclar todas las filas
		JE salirMI

		MOV r11, rcx; muevo al cantidad de columnas a r11
		MOV r14, rdi; hago el iterador de columnas de srca
		MOV r13, rsi; hago el iterador de columnas de dst


			cicloPorColumnaMI:
			 	CMP r11, 0; comparo para ver si ya miré todas las columnas
				JE cambiarDeFilaMI
			 	CMP r11, 16; comparo para ver si estoy cerca del w
				JL redimensionarMI

				MOV eax,1; contador de llenados

				cicloLlenadosMI:
						MOVDQU xmm1, [r14]; xmm1 = [r1|g1|b1|r2|g2|b2|r3|g3|b3|r4|g4|b4|r5|g5|b5|r6|]
						MOVDQU xmm2,xmm1; 
						PSRLDQ xmm2, 1;  xmm2 =    [g1|b1|r2|g2|b2|r3|g3|b3|r4|g4|b4|r5|g5|b5|r6|0]
						MOVDQU xmm3,xmm1;
						PSRLDQ xmm3, 2;  xmm3 =    [b1|r2|g2|b2|r3|g3|b3|r4|g4|b4|r5|g5|b5|r6|0|0]

						PMAXUB xmm1,xmm2; xmm1 = [max(r1,g1),..,max(r2,g2).,.,max(r3,g3)..]
						PMAXUB xmm1,xmm3; xmm3 = [max(r1,g1,b1),..,max (r2,g2,b2)..]

						PAND xmm1,xmm10; (dejo pasar solo los maximos) xmm1 =  [m1,0,0,m2,0,0,m3,0,0,m4,0,0,0,0,0,0]
						MOVDQU xmm2,xmm1;		
						PSRLDQ xmm2, 2; xmm2 = [0,m2,0,0,m3,0,0,m4,0,0,0,0,0,0,0,0]
						PADDB xmm1,xmm2; xmm1 = [m1,m2,0,m2,m3,0,m3,m4,0,0,0,0,0,0,0,0]
						PAND xmm1,xmm11; xmm1 = [m1,m2,0,0,0,0,m3,m4,0,0,0,0,0,0,0,0]
						MOVDQU xmm2,xmm1;
						PSRLDQ xmm2, 4; xmm2 =  [0,0,m3,m4,0,0,0,0,0,0,0,0,0,0,0,0]
						PADDB xmm1,xmm2; xmm1 = [m1,m2,m3,m4,0,0,m3,m4,0,0,0,0,0,0,0,0,]
						PAND xmm1, xmm12; xmm1 =[m1,m2,m3,m4,0,...,0,0]	

						CMP eax,1
						JE primerLlenadoMI
						CMP eax,2
						JE segundoLlenadoMI
						CMP eax,3;
						JE tercerLlenadoMI
						JMP cuartoLlenadoMI

						primerLlenadoMI:
							MOVDQU xmm0, xmm1;
							LEA r14, [r14+12]	; aumento iterador de src
							INC eax				; aumento cant de llenados
							JMP cicloLlenadosMI

						segundoLlenadoMI:
							PSLLDQ xmm1, 4;
							PADDB xmm0, xmm1;
							LEA r14, [r14+12]	; aumento iterador de src
							INC eax				; aumento cant de llenados
							JMP cicloLlenadosMI

						tercerLlenadoMI:
							PSLLDQ xmm1, 8;
							PADDB xmm0, xmm1;
							LEA r14, [r14+12]	; aumento iterador de src
							INC eax;			; aumento cant de llenados
							JMP cicloLlenadosMI

						cuartoLlenadoMI:
							PSLLDQ xmm1, 12;
							PADDB xmm0, xmm1;   
							LEA r14, [r14+12]; aumento iterador de src
						

							MOVDQU [r13], xmm0; Escribo en memoria

							LEA r13, [r13+16]; aumento en 16 al iterador
							SUB r11, 16; disminuyo 16 columnas al iterador
							JMP cicloPorColumnaMI



	redimensionarMI:
					MOV rax, 16; Que es la cantidad de pixels que escribo en momoria
					SUB rax, r11; Resto la cant de columnas que me faltan procesar
					SUB r13, rax; Retrocedo en el dst la diferencia entre la cantidad de columnas que procese y 16
					SUB r14 ,rax;	Retrocedo en el src diferencia*3 (porque 1 px = 3b)
					SUB r14 ,rax;
					SUB r14 ,rax;
					MOV r11,16; Para que termine justo
					JMP cicloPorColumnaMI


			cambiarDeFilaMI:
					LEA rdi, [rdi + r8]; sumo el row_size
					LEA rsi, [rsi + r9]; sumo el row_size
					DEC rdx; 
					JMP cicloPorFilaMI

 
	salirMI:
		POP r14
		POP r13
		POP rbp

		RET




	

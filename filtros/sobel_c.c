#include <math.h>


void sobel_c (
	unsigned char *src,
	unsigned char *dst,
	int cantFilas,
	int cantColumnas,
	int src_row_size,
	int dst_row_size
) {
	
	int itColumnas = 0;
	int itFilas = 0;
	int resFinal;
	int gx;
	int gy;
	unsigned char * itSrc = src;
	unsigned char * itDst = dst;

	//Relleno la primer fila de dst con 0
	itColumnas = 0;

	while(itColumnas < cantColumnas) {
		*itDst = 0;
		itColumnas++;
		itDst++;
		
	}
	
	
	dst += dst_row_size ; //Paso a la segunda fila
	src += src_row_size;
	
	//Empieza la parte del medio
	itFilas = 1;
	while(itFilas < cantFilas-1){ 
			itColumnas = 0;
			itSrc = src; // los iteradores siempre se ubican al comienzo de la fila y van cambiando
			itDst = dst; // al final del ciclo se aumenta una fila tanto a src como a dst
			while(itColumnas < cantColumnas){
			
				//Pongo 0 en los bordes de los costados
				if ( (itColumnas == 0) || (itColumnas == (cantColumnas -1) ) ) {gx = 0; gy = 0;}// prueba_caca++;}
				else {			
			
				gx = - *(itSrc - src_row_size - 1) +   *(itSrc - src_row_size + 1)
					 - 2* (*(itSrc - 1)) 		   +   2* (*(itSrc + 1))
					 - *(itSrc + src_row_size - 1) +   *(itSrc + src_row_size + 1);


				gy = *(itSrc -src_row_size - 1 ) + 2 * (*(itSrc - src_row_size)) + *(itSrc - src_row_size + 1)
					-*(itSrc +src_row_size - 1 ) - 2 * (*(itSrc + src_row_size)) - *(itSrc + src_row_size + 1);
				
				}
				
				resFinal = sqrt(gy*gy + gx*gx);
				
				if (resFinal > 255)  resFinal = 255;
				*itDst = resFinal;
				itSrc++;
				itDst++;
				
				itColumnas++;
			}

		src = src + src_row_size;
		dst = dst + dst_row_size;
		itFilas++;
	}
	
	//Relleno la ULTIMA fila de dst con 0|
	itColumnas = 0;
	
	while(itColumnas < cantColumnas) {
		*itDst = 0;
		itColumnas++;
		itDst++;
	}
}

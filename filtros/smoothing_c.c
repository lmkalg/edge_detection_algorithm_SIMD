void smoothing_c ( 
	unsigned char *src,
	unsigned char *dst,
	int cantFilas,
	int cantColumnas,
	int src_row_size,
	int dst_row_size
) {
		
	int itColumnas = 0;
	int itFilas = 0;
	float mascara;
	

	unsigned char * itSrc;
	unsigned char * itDst = dst;

	//Relleno la primer fila de dst con 0
	itColumnas = 0;
	while(itColumnas < cantColumnas) {
		*itDst = 0;
		itColumnas++;
		itDst++;
	}
		
	dst = dst + dst_row_size; //Paso a la segunda fila
	src = src + src_row_size; //Paso a la segunda fila
	itDst = dst;	// Actualiza el iterador al comienzo de la fila

	//Relleno la segunda fila de dst con 0
	itColumnas = 0;
	while(itColumnas < cantColumnas) {
		*itDst = 0;
		itColumnas++;
		itDst++;
	}
	
	dst = dst + dst_row_size; //Paso a la tercera fila
	src = src + src_row_size; //Paso a la tercera fila
	itDst = dst;	// Actualiza el iterador al comienzo de la fila

	//Empieza la parte del medio
	itFilas = 2;
	while(itFilas < cantFilas-2){
		itColumnas = 0;
		itSrc = src; // los iteradores siempre se ubican al comienzo de la fila y van cambiando
		itDst = dst; // al final del ciclo se aumenta una fila tanto a src como a dst
		
		while(itColumnas < cantColumnas){
			
			mascara = 0;
			
			//Pongo 0 en los bordes de los costados (dos píxeles a cada lado)
			if ( !(itColumnas == 0 || itColumnas == 1 || itColumnas == cantColumnas - 2 || itColumnas == cantColumnas -1) ){
				
				mascara += *(itSrc - 2*src_row_size - 2)*2 	+ *(itSrc - 2*src_row_size - 1)*4 	+ *(itSrc - 2*src_row_size)*5 	+ *(itSrc - 2*src_row_size + 1)*4 	+ *(itSrc - 2*src_row_size + 2)*2;
				mascara += *(itSrc - src_row_size - 2)*4 	+ *(itSrc - src_row_size - 1)*9 	+ *(itSrc - src_row_size)*12 	+ *(itSrc - src_row_size + 1)*9 	+ *(itSrc - src_row_size + 2)*4;
				mascara += *(itSrc - 2)*5 					+ *(itSrc - 1)*12 					+ *itSrc*15 					+ *(itSrc + 1)*12 					+ *(itSrc + 2)*5;
				mascara += *(itSrc + src_row_size - 2)*4 	+ *(itSrc + src_row_size - 1)*9 	+ *(itSrc + src_row_size)*12 	+ *(itSrc + src_row_size + 1)*9 	+ *(itSrc + src_row_size + 2)*4;
				mascara += *(itSrc + 2*src_row_size - 2)*2 	+ *(itSrc + 2*src_row_size - 1)*4 	+ *(itSrc + 2*src_row_size)*5 	+ *(itSrc + 2*src_row_size + 1)*4 	+ *(itSrc + 2*src_row_size + 2)*2;
				
			}
			else 
				mascara = 0;

			*itDst = (unsigned char)(mascara / 159);
			itSrc++;
			itDst++;
			
			itColumnas++;
		}
		
		src = src + src_row_size;
		dst = dst + dst_row_size;
		itFilas++;
	}
	
	//Relleno la ANTEULTIMA fila de dst con 0
	itColumnas = 0;
	while(itColumnas < cantColumnas) {
		*itDst = 0;
		itColumnas++;
		itDst++;
	}
	
	dst = dst + dst_row_size; //Paso a la segunda fila
	itDst = dst;
	
	//Relleno la ULTIMA fila de dst con 0
	itColumnas = 0;
	while(itColumnas < cantColumnas) {
		*itDst = 0;
		itColumnas++;
		itDst++;
	}
}
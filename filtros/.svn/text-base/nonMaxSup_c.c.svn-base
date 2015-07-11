
void nonMaxSup_c ( 
	unsigned char *grd,
	unsigned char *ang,
	unsigned char *dst,
	int cantFilas,
	int cantColumnas,
	int grd_row_size,
	int ang_row_size,
	int dst_row_size,
	unsigned char tHigh,
	unsigned char tLow
) {
	
	int itColumnas = 0;
	int itFilas = 0;
	unsigned int valor;
	unsigned int pixel;

	unsigned char * itGrd;
	unsigned char * itAng;
	unsigned char * itDst = dst;


	int i;

	//Relleno la primeras tres filas de dst con 0
	for(i = 0; i < 3; ++i){
		
		itDst = dst;

		itColumnas = 0;
		while(itColumnas < cantColumnas) {
			*itDst = 0;
			itColumnas++;
			itDst++;
		}

			
		dst = dst + dst_row_size; //Paso de fila
		grd = grd + grd_row_size; //Paso de fila
		ang = ang + ang_row_size; //Paso de fila
	}




 

	//Empieza la parte del medio
	itFilas = 3;
	while(itFilas < cantFilas-3){	
							  
		itGrd = grd; // los iteradores siempre se ubican al comienzo de la fila y van cambiando ( me corro por los bordes)
		itAng = ang;
		itDst = dst; // al final del ciclo se aumenta una fila tanto a src como a dst

		*itDst = 0; itDst++; // Relleno el borde con 0
		*itDst = 0; itDst++; // Relleno el borde con 0
		*itDst = 0; itDst++; // Relleno el borde con 0

		itColumnas = 3;


			
			while(itColumnas < cantColumnas-3){
				
				valor = 0;
	
				//Pongo 0 en los bordes de los costados (dos píxeles a cada lado)
				pixel = *itGrd;
				if (!(itColumnas > cantColumnas - 3)){
					if ( *itAng == 50 ) {
						if( *(itGrd - 1) < pixel && pixel >  *(itGrd + 1) ) {
							if( pixel > tHigh ) valor = 200;
							else if ( pixel > tLow ) valor = 100;
						}
					}
					else if ( *itAng == 100 ) {
						if( *(itGrd - grd_row_size + 1) < pixel && pixel > *(itGrd + grd_row_size - 1) ){
							if( pixel > tHigh ) valor = 200;
							else if ( pixel > tLow ) valor = 100;
						}
					}
					else if ( *itAng == 150 ) {
						if( *(itGrd - grd_row_size) < pixel && pixel > *(itGrd + grd_row_size) ){
							if( pixel > tHigh ) valor = 200;
							else if ( pixel > tLow ) valor = 100;
						}
					}
					else if ( *itAng == 200 ) {
						if( *(itGrd - grd_row_size - 1) < pixel && pixel > *(itGrd + grd_row_size + 1) ) {
							if( pixel > tHigh ) valor = 200;
							else if ( pixel > tLow ) valor = 100;
						}
					}
				}

				*itDst = valor;
				itGrd++;
				itAng++;	
				itDst++;
				
				itColumnas++;
			}

		*itDst = 0; itDst++; // Relleno el borde con 0
		*itDst = 0; itDst++;	// Relleno el borde con 0
		*itDst = 0; itDst++;	// Relleno el borde con 0
				
		grd = grd + grd_row_size;
		ang = ang + ang_row_size;
		dst = dst + dst_row_size;
		itFilas++;
	}
	

	//Relleno la ultimas tres filas de dst con 0
	for(i = 0; i < 3; ++i){
		
		itDst = dst;

		itColumnas = 0;
		while(itColumnas < cantColumnas) {
			*itDst = 0;
			itColumnas++;
			itDst++;
		}

			
		dst = dst + dst_row_size; //Paso de fila
		grd = grd + grd_row_size; //Paso de fila
		ang = ang + ang_row_size; //Paso de fila
	}
}
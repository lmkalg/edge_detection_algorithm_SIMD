#include <math.h>

#define PI 3.1415


void anguloSobel_c ( 
	unsigned char *src,
	unsigned char *grd,
	unsigned char *ang,
	int cantFilas,
	int cantColumnas,
	int src_row_size,
	int grd_row_size
) {
	
	int ang_row_size = grd_row_size;

	int itColumnas = 0;
	int itFilas = 0;
	int resFinal;
	int gx;
	int gy;
	float angulo;
	unsigned char valor;

	
	unsigned char * itSrc = src;
	unsigned char * itGrd;
	unsigned char * itAng;

	int i;
	for( i = 0; i < 3; ++i){
		itGrd = grd;
		itAng = ang;

		//Relleno la fila de dst con 0 (convención para el borde)
		itColumnas = 0;
		while(itColumnas < cantColumnas) {
			*itGrd = 0;
			*itAng = 0;
			itColumnas++;
			itGrd++;
			itAng++;
		}
		
		src = src + src_row_size; //Paso a la siguiente fila
		grd = grd + grd_row_size; //Paso a la siguiente fila
		ang = ang + ang_row_size; //Paso a la siguiente fila
	}

	
	//Empieza la parte del medio
	itFilas = 3;
	while(itFilas < cantFilas-3){ 
							  
			itColumnas = 0;
			itSrc = src; // los iteradores siempre se ubican al comienzo de la fila y van cambiando
			itGrd = grd; // al final del ciclo se aumenta una fila tanto a src como a grd
			itAng = ang; // al final del ciclo se aumenta una fila tanto a src como a ang
			
			while(itColumnas < cantColumnas){
			
				// Pongo 0 en los bordes de los costados
				if (itColumnas == 0 || itColumnas == 1 || itColumnas == 2 || itColumnas == cantColumnas -3 || itColumnas == cantColumnas -2 || itColumnas == cantColumnas -1) {gx = 255; gy = 255;} // Convención para el caso de los bordes
				else {			
			
					gx = 	- *(itSrc - src_row_size - 1)	+   *(itSrc - src_row_size + 1)
							- 2* (*(itSrc - 1))				+   2* (*(itSrc + 1))
							- *(itSrc + src_row_size - 1)	+   *(itSrc + src_row_size + 1);

					gy = 	*(itSrc -src_row_size - 1 ) 	+ 2 * (*(itSrc - src_row_size)) 	+ *(itSrc - src_row_size + 1)
							-*(itSrc +src_row_size - 1 ) 	- 2 * (*(itSrc + src_row_size)) 	- *(itSrc + src_row_size + 1);
				}

				if ( gx == 255 && gy == 255 ) angulo = 255; 	// Convención por el borde
				else if ( gx == 0 && gy == 0 ) angulo = 0;		// Si gx es cero se resuelve
				else if ( gx == 0 && gy != 0 ) angulo = 90; 	// así según el valor de gy.
				else angulo = atan2( gy , gx ) * 180 / PI; 		// Dado que el resultado está en radianes lo transformo a grados
				

				if (angulo < 0) angulo = 360 + angulo;			// Si es negativo lo hace positivo (módulo 360º)
			

				// Se ubica el ángulo en 5 valores bien definidos según si es borde o alguna de las 4 direcciones (cruces 90º y 45º)
				if ( angulo == 255 ) valor = 0; 				// Convención
				else if ( (0 <= angulo && angulo < 22.5) || (157.5 <= angulo && angulo < 202.5) || (337.5 <= angulo && angulo < 360) ) valor = 50;
				else if ( (22.5 <= angulo && angulo < 67.5) || (202.5 <= angulo && angulo < 247.5) ) valor = 100;
				else if ( (67.5 <= angulo && angulo < 112.5) || (247.5 <= angulo && angulo < 292.5) ) valor = 150;
				else if ( (112.5 <= angulo && angulo < 157.5) || (292.5 <= angulo && angulo < 337.5) ) valor = 200;

				
				*itAng =  valor; 
				if( gx == 255 && gy == 255 ) *itGrd = 0;
				else{
					resFinal = sqrt(gx*gx + gy*gy); 
					if(resFinal > 255) resFinal = 255;
					*itGrd = resFinal;
				}
				itSrc++;
				itGrd++;
				itAng++;
				
				itColumnas++;
			}
		
		src = src + src_row_size;
		grd = grd + grd_row_size;
		ang = ang + ang_row_size;
		itFilas++;
	}

	for(i = 0; i < 3; ++i){
		itGrd = grd;
		itAng = ang;

		//Relleno la fila de dst con 0 (convención para el borde)
		itColumnas = 0;
		while(itColumnas < cantColumnas) {
			*itGrd = 0;
			*itAng = 0;
			itColumnas++;
			itGrd++;
			itAng++;
		}
		
		src = src + src_row_size; //Paso a la siguiente fila
		grd = grd + grd_row_size; //Paso a la siguiente fila
		ang = ang + ang_row_size; //Paso a la siguiente fila
	}
}

#include "Pila.h"
#include <vector>
#include <iostream>

using namespace std;

void doubleThresholding_c (
	unsigned char *src,
	int cantFilas,
	int cantColumnas,
	int src_row_size
) {
	int i;
	int j;
	Pila laPila;
	int abc;
	int ord;
	unsigned char *pos;
	

	vector<bool> aux(cantColumnas, true);
	vector< vector<bool> > porRevisar(cantFilas, aux);
	
	for(j = 0; j < cantColumnas; ++j){
		porRevisar[0][j] = false; // Primer fila
		porRevisar[cantFilas-1][j] = false; // Última fila
	}
	for(i = 1; i < cantFilas-1; ++i){
		porRevisar[i][0] = false; // Primer columna
		porRevisar[i][cantColumnas-1] = false; // Última columna
	}

	/// Operación con los píxeles
	for(i = 1 ; i < cantFilas-1 ; i++){
		for(j = 1 ; j < cantColumnas-1 ; j++){
			pos = src + i*src_row_size + j;									/// pos guarda la posición en la que uno está iterando
			if ( porRevisar[i][j] && *pos == 0 ) porRevisar[i][j] = false; /// Si no fue revisado y es nulo lo marca como revisado
			else if( porRevisar[i][j] && *pos == 200 ){ 	/// Si aún no fue revisado y es píxel fuerte
				/// Chequea todos los píxeles vecinos, si son débiles los pone en la pila para procesarlos luego
				/*	1 2 3 */
				/*	4 X 6 */
				/*	7 8 9 */
				
				if( *(pos - src_row_size - 1) 	== 100 ) laPila.Apilar(i-1, j-1);	/// Apila el pixel de la pos 1
				if( *(pos - src_row_size) 		== 100 ) laPila.Apilar(i-1, j);		/// Apila el pixel de la pos 2
				if( *(pos - src_row_size + 1) 	== 100 ) laPila.Apilar(i-1, j+1);	/// Apila el pixel de la pos 3
				if( *(pos - 1)					== 100 ) laPila.Apilar(i, j-1);		/// Apila el pixel de la pos 4
				if( *(pos + 1)					== 100 ) laPila.Apilar(i, j+1);		/// Apila el pixel de la pos 6
				if( *(pos + src_row_size - 1)	== 100 ) laPila.Apilar(i+1, j-1);	/// Apila el pixel de la pos 7
				if( *(pos + src_row_size)		== 100 ) laPila.Apilar(i+1, j);		/// Apila el pixel de la pos 8
				if( *(pos + src_row_size + 1)	== 100 ) laPila.Apilar(i+1, j+1);	/// Apila el pixel de la pos 9
				
				porRevisar[i][j] = false;										/// Al fuerte lo marca como revisado
				
				while( !laPila.EsVacia() ){		/// Mientras la pila no sea vacía opera todos los puntos
					abc = laPila.AbcisaTope();
					ord = laPila.OrdenadaTope();
					pos = src + abc*src_row_size + ord;
					laPila.SacarTope();											/// Saca al par ordenado ya operado

					if(porRevisar[abc][ord]){
						
						*pos = 200;					/// Pinta fuerte al píxel	
			
						/// Revisa los vecinos y todos los débiles los agrega a la pila
						if( *(pos - src_row_size - 1) 	== 100 ) laPila.Apilar(abc-1, ord-1);
						if( *(pos - src_row_size) 		== 100 ) laPila.Apilar(abc-1, ord);
						if( *(pos - src_row_size + 1) 	== 100 ) laPila.Apilar(abc-1, ord+1);
						if( *(pos - 1)					== 100 ) laPila.Apilar(abc, ord-1);
						if( *(pos + 1)					== 100 ) laPila.Apilar(abc, ord+1);
						if( *(pos + src_row_size - 1)	== 100 ) laPila.Apilar(abc+1, ord-1);
						if( *(pos + src_row_size)		== 100 ) laPila.Apilar(abc+1, ord);
						if( *(pos + src_row_size + 1)	== 100 ) laPila.Apilar(abc+1, ord+1);
						
						porRevisar[abc][ord] = false;							/// Lo marca como revisado
					}
				}
			}
		}
	}
	
	
	/// Por último, anula todos los débiles que sobrevivieron
	for(i = 1 ; i < cantFilas-1 ; i++){
		for(j = 1 ; j < cantColumnas-1 ; j++){
			if( *(src + i*src_row_size + j) == 100 ) *(src + i*src_row_size + j) = 0;
		}
	}
}

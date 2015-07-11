#include <stdbool.h>

void recortar_c (
	unsigned char *src,
	unsigned char *dst,
	int m,
	int n,
	int src_row_size,
	int dst_row_size,
	int x,
	int y,
	int tam
) {
	
	src = src + y*(src_row_size) + x;
	
	int ancho = 0;
	int alto =  0;
	
	while((alto < tam)){
		
		while((ancho < tam)){
			*dst = *src;
			src+=1;
			dst+=1;
			ancho++;
		}
		
		src = src + src_row_size - (ancho+x) + x;
		dst = dst + dst_row_size - ancho;
	
		
		ancho = 0;
		alto++;
	}
	
}

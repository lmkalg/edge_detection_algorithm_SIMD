#include <math.h>

void roberts_cross_c (
	unsigned char *src,
	unsigned char *dst,
	int m,
	int n,
	int src_row_size,
	int dst_row_size
) {
	
	int ancho = 0;
	int alto = 0;
	
	int gx;
	int gy;

	m -= m % 4;
	n -= n % 4;
	
	
	while(alto < m - 1){
		
		while(ancho < n-1){
			gx = *src - *(src + 1 + src_row_size);
			gy = *(src + 1) - *(src + src_row_size);
			*dst = (unsigned char)sqrt(gx*gx + gy*gy);
			src++;
			dst++;
			ancho++;
		}
		
		*dst = 0;
		*(dst+1) = 0;
		
		src = src + src_row_size - (n-1);
		dst = dst + dst_row_size - (n-1);
		ancho = 0;
		alto++;
	}
	
	dst = dst + dst_row_size - (n-1);
	
	// Última fila de negro
	ancho = 0;
	while(ancho < n){
		*dst = 0;
		dst++;
		ancho++;
	}
	
}

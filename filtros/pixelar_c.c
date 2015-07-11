short sumatoria(short a[]){
	return (a[0] + a[1] + a[2] + a[3]);			
}

void pixelar_c (
	unsigned char *src,
	unsigned char *dst,
	int m,
	int n,
	int src_row_size,
	int dst_row_size
) {
	
	int ancho = 0;
	int alto = 0;
	
	 m -= m % 4;
	 n -= n % 4;
	short arriba[4];
	short medioArriba[4];
	short medioAbajo[4];
	short abajo[4];
	
	char promedio;
	
		
	while(alto < m){
		
		while(ancho < n){
			
			
			arriba[0] = (short)(*src);
			arriba[1] = (short)(* (src + 1));
			arriba[2] = (short)(* (src + 2));
			arriba[3] = (short)(* (src + 3));
			
			medioArriba[0] = (short)(*(src + src_row_size));
			medioArriba[1] = (short)(*(src + src_row_size + 1));
			medioArriba[2] = (short)(*(src + src_row_size + 2));
			medioArriba[3] = (short)(*(src + src_row_size + 3));
		
			medioAbajo[0] = (short)(*(src + src_row_size + src_row_size));
			medioAbajo[1] = (short)(*(src + src_row_size + src_row_size + 1));
			medioAbajo[2] = (short)(*(src + src_row_size + src_row_size + 2));
			medioAbajo[3] = (short)(*(src + src_row_size + src_row_size + 3));
			
			abajo[0] = (short)(*(src + src_row_size + src_row_size + src_row_size));
			abajo[1] = (short)(*(src + src_row_size + src_row_size + src_row_size + 1));
			abajo[2] = (short)(*(src + src_row_size + src_row_size + src_row_size + 2));
			abajo[3] = (short)(*(src + src_row_size + src_row_size + src_row_size + 3));
			
			
			promedio = (char)((sumatoria(arriba) + sumatoria(medioArriba) + sumatoria(medioAbajo) + sumatoria(abajo))/16);

			
			*dst = promedio;
			*(dst + 1) = promedio;
			*(dst + 2) = promedio;
			*(dst + 3) = promedio;
			*(dst + dst_row_size) = promedio;
			*(dst + dst_row_size + 1) = promedio;
			*(dst + dst_row_size + 2) = promedio;
			*(dst + dst_row_size + 3) = promedio;
			*(dst + dst_row_size + dst_row_size) = promedio;
			*(dst + dst_row_size + dst_row_size + 1) = promedio;
			*(dst + dst_row_size + dst_row_size + 2) = promedio;
			*(dst + dst_row_size + dst_row_size + 3) = promedio;
			*(dst + dst_row_size + dst_row_size + dst_row_size) = promedio;
			*(dst + dst_row_size + dst_row_size + dst_row_size + 1) = promedio;
			*(dst + dst_row_size + dst_row_size + dst_row_size + 2) = promedio;
			*(dst + dst_row_size + dst_row_size + dst_row_size + 3) = promedio;
			
			
			
			src = src + 4;
			dst = dst + 4;
			
			ancho = ancho + 4;
		}
		
		src = src + (4*src_row_size) - ancho;
		dst = dst + (4*dst_row_size) - ancho;
		
		ancho = 0;
		alto = alto + 4;
	}
	
}

void monocromatizar_uno_c (
	unsigned char *src,
	unsigned char *dst,
	int h,
	int w,
	int src_row_size,
	int dst_row_size
) {
	int contadorF = 1;
	int contadorC;
	while (contadorF <= h){

		contadorC = 1;
		while ( contadorC <= w) {

	short blue = (short)*src;
	src += 1;
	short green = (short)*src;
	src += 1;
	short red = (short)*src;
	src += 1;	
	*dst = (unsigned char)((red+2*green+blue)/4);	
	dst+=1;
						
			contadorC++;
		
		}
		
		src = src + src_row_size - w*3 ;
		dst = dst + dst_row_size - w ;
		contadorF++;
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}

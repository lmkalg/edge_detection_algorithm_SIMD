float funcionCombinar(float alpha, unsigned char ** srcA,  unsigned char ** srcB){

	float divisor = 255.0;
	float pixelDeA = (float)**srcA;
	float pixelDeB = (float)**srcB;
	*srcA +=1;
	*srcB +=1;

	float resta = pixelDeA - pixelDeB;
	return (((alpha*resta)/divisor) + pixelDeB);

}


void combinar_c (
	unsigned char *src_a,
	unsigned char *src_b,
	unsigned char *dst,
	int m,
	int n,
	int row_size,
	float alpha
) {
		int itColumnas;
		int itFilas = 1;

		while (itFilas <= m){
			int itColumnas = 1;
		
			while (itColumnas <= n){
				*dst = funcionCombinar(alpha,&src_a,&src_b);
				dst += 1; 
				itColumnas++;
			}

			dst += (row_size - n);
			src_a += (row_size - n);
			src_b += (row_size - n);
			itFilas++;
		}
	}

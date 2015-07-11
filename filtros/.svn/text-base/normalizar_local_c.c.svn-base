void normalizar(unsigned char **dst, unsigned char **src, int row_size){
	short vecinos[9];
	short res;
	
	vecinos[0] = *(*src-row_size-1);
	vecinos[1] = *(*src-row_size);
	vecinos[2] = *(*src-row_size+1);
	vecinos[3] = *(*src-1);
	vecinos[4] = *(*src);
	vecinos[5] = *(*src+1);
	vecinos[6] = *(*src+row_size-1);
	vecinos[7] = *(*src+row_size);
	vecinos[8] = *(*src+row_size+1);
	
	//Tomo el maximo
	short maximo = vecinos[0];
	int i = 1;
	while (i < 9){
		if (vecinos[i] > maximo) maximo = vecinos[i];
		i++;		
	}

	short minimo = vecinos[0];
	i = 1;
	while (i < 9){
		if (vecinos[i] < minimo) minimo = vecinos[i];
		i++;		
	}
	
	double valor = (double) **src;
	double max = (double) maximo;
	double min = (double) minimo;
	
	res = (unsigned char) ((valor/maximo) + minimo);
	
	//res = (((**src)/maximo)+minimo);
	
	**dst = res;
}





void normalizar_local_c (
	unsigned char *src,
	unsigned char *dst,
	int m,
	int n,
	int row_size
) {
	int itColumnas = 1;
	int itFilas = 1;
			
	//PARA LA PRIMER FILA
	while (itColumnas <= n){
		*dst = *src;
		src+=1;
		dst+=1;
		itColumnas++;
	}
	
	itFilas++;
	dst += (row_size - n);
	src += (row_size - n);
	
	while (itFilas < m){
		*dst = *src; //Por la primera columna
		dst +=1;
		src +=1;
		itColumnas = 2;
		
		while (itColumnas < n){
			normalizar(&dst, &src,row_size);	
			itColumnas++;
			dst += 1;
			src += 1;
		}
		
		*dst = *src; //Por la ultima columna
		dst += (row_size - n + 1);
		src += (row_size - n + 1);
		itFilas++;
	}
	//ultima fila
	itColumnas = 1;
	
	while (itColumnas <= n){
		*dst = *src;
		src+=1;
		dst+=1;
		itColumnas++;
	}
	
	
		
}
	

#include <math.h>

#define PI 			3.1415
#define RADIUS 		35
#define WAVELENGTH 	64
#define TRAINWIDTH 	3.4

float sin_taylor (float x) {
	float x_3 = x*x*x;
	float x_5 = x*x*x*x*x;
	float x_7 = x*x*x*x*x*x*x;

	return x-(x_3/6.0)+(x_5/120.0)-(x_7/5040.0);
}

float profundidad (int x, int y, int x0, int y0) {
	float dx = x - x0;
	float dy = y - y0;

	float dxy = sqrt(dx*dx+dy*dy);

	float r = (dxy-RADIUS)/WAVELENGTH ;
	float k = r-floor(r);
	float a = 1.0/(1.0+(r/TRAINWIDTH)*(r/TRAINWIDTH));

	float t = k*2*PI-PI;

	float s_taylor = sin_taylor(t);

	return a * s_taylor;
}

void ondas_c (
	unsigned char *src,
	unsigned char *dst,
	int m,
	int n,
	int row_size,
	int x0,
	int y0
) {
	unsigned char (*src_matrix)[row_size] = (unsigned char (*)[row_size]) src;
	unsigned char (*dst_matrix)[row_size] = (unsigned char (*)[row_size]) dst;

	float new_pixel;

	float prof;

	int i, j;

	for (i = 0; i<m; i+=1) {
		for (j = 0; j<n; j+=1) {
			prof = profundidad(i, j, x0, y0);

			new_pixel = (prof * 64.0) + (float) src_matrix[i][j];

			new_pixel = new_pixel <   0.0 ?   0.0 : new_pixel;
			new_pixel = new_pixel > 255.0 ? 255.0 : new_pixel;

			dst_matrix[i][j] = (unsigned char) new_pixel;
		}
	}
}
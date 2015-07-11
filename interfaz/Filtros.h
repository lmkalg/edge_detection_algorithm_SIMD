#ifndef FILTROS_H
#define FILTROS_H

extern "C"
{

/* Funciones en C */
    void recortar_c (unsigned char *src, unsigned char *dst, int m, int n, int src_row_size, int dst_row_size, int x, int y, int tam);
    void pixelar_c (unsigned char *src, unsigned char *dst, int m, int n, int src_row_size, int dst_row_size);
    void combinar_c (unsigned char *src_a, unsigned char *src_b, unsigned char *dst, int m, int n, int row_size, float alpha);
    void monocromatizar_inf_c(unsigned char *src, unsigned char *dst, int h, int w, int src_row_size, int dst_row_size);
    void monocromatizar_uno_c(unsigned char *src, unsigned char *dst, int h, int w, int src_row_size, int dst_row_size);
    void normalizar_local_c (unsigned char *src, unsigned char *dst, int m, int n, int row_size);
    void ondas_c (unsigned char *src, unsigned char *dst, int m, int n, int row_size, int x0, int y0);

    void recortarMult_c (unsigned char *src, unsigned char *dst, int m, int n, int src_row_size, int dst_row_size, int tam);
    void colorizar_c (unsigned char *src, unsigned char *dst, int m, int n, int src_row_size, int dst_row_size, float alpha);
    void halftone_c (unsigned char *src, unsigned char *dst, int m, int n, int src_row_size, int dst_row_size);
    void rotar_c (unsigned char *src, unsigned char *dst, int m, int n, int src_row_size, int dst_row_size);
    void umbralizar_c (unsigned char *src, unsigned char *dst, int m, int n, int row_size, unsigned char min, unsigned char max, unsigned char q);
    void waves_c (unsigned char *src, unsigned char *dst, int m, int n, int row_size, float x_scale, float y_scale, float g_scale);

    void roberts_cross_c (unsigned char *src, unsigned char *dst, int cantFilas, int cantColumnas, int src_row_size, int dst_row_size);
    void sobel_c (unsigned char *src, unsigned char *dst, int cantFilas, int cantColumnas, int src_row_size, int dst_row_size);
    void prewitt_c (unsigned char *src, unsigned char *dst, int cantFilas, int cantColumnas, int src_row_size, int dst_row_size);
    void smoothing_c (unsigned char *src, unsigned char *dst, int cantFilas, int cantColumnas, int src_row_size, int dst_row_size);
    void anguloSobel_c (unsigned char *smo, unsigned char *grd, unsigned char *ang, int cantFilas, int cantColumnas, int smo_row_size, int grd_row_size, int ang_row_size);
    void nonMaxSup_c (unsigned char *grd, unsigned char *ang, unsigned char *dst, int cantFilas, int cantColumnas, int grd_row_size, int ang_row_size, int dst_row_size, unsigned char tHigh, unsigned char tLow);
/* FIN funciones en C */

/* Funciones en assembly */
    void recortar_asm (unsigned char *src, unsigned char *dst, int m, int n, int src_row_size, int dst_row_size, int x, int y, int tam);
    void pixelar_asm (unsigned char *src, unsigned char *dst, int m, int n, int src_row_size, int dst_row_size);
    void combinar_asm (unsigned char *src_a, unsigned char *src_b, unsigned char *dst, int m, int n, int row_size, float alpha);
    void monocromatizar_inf_asm (unsigned char *src, unsigned char *dst, int h, int w, int src_row_size, int dst_row_size);
    void monocromatizar_uno_asm (unsigned char *src, unsigned char *dst, int h, int w, int src_row_size, int dst_row_size);
    void normalizar_local_asm (unsigned char *src, unsigned char *dst, int m, int n, int row_size);
    void ondas_asm (unsigned char *src, unsigned char *dst, int m, int n, int row_size, int x0, int y0);

    void recortarMult_asm (unsigned char *src, unsigned char *dst, int m, int n, int src_row_size, int dst_row_size, int tam);
    void colorizar_asm (unsigned char *src, unsigned char *dst, int m, int n, int src_row_size, int dst_row_size, float alpha);
    void halftone_asm (unsigned char *src, unsigned char *dst, int m, int n, int src_row_size, int dst_row_size);
    void rotar_asm (unsigned char *src, unsigned char *dst, int m, int n, int src_row_size, int dst_row_size);
    void umbralizar_asm (unsigned char *src, unsigned char *dst, int m, int n, int row_size, unsigned char min, unsigned char max, unsigned char q);
    void waves_asm (unsigned char *src, unsigned char *dst, int m, int n, int row_size, float x_scale, float y_scale, float g_scale);

    void roberts_cross_asm (unsigned char *src, unsigned char *dst, int m, int n, int src_row_size, int dst_row_size);
    void prewitt_asm (unsigned char *src, unsigned char *dst, int m, int n, int src_row_size, int dst_row_size);
    void sobel_asm (unsigned char *src, unsigned char *dst, int m, int n, int src_row_size, int dst_row_size);
    void smoothing_asm (unsigned char *src, unsigned char *dst, int cantFilas, int cantColumnas, int src_row_size, int dst_row_size);
    void anguloSobel_asm (unsigned char *src, unsigned char *grd, unsigned char *ang, int cantFilas, int cantColumnas, int src_row_size, int grd_row_size, int ang_row_size);
    void nonMaxSup_asm (unsigned char *grd, unsigned char *ang, unsigned char *dst, int cantFilas, int cantColumnas, int grd_row_size, int ang_row_size, int dst_row_size, unsigned char tHigh, unsigned char tLow);
/* FIN funciones en assembly */

}


    void doubleThresholding_c (unsigned char *src, int cantFilas, int cantColumnas, int src_row_size);

#endif // FILTROS_H

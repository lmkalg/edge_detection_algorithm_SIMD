#include "ventanaprincipal.h"
#include "ui_ventanaprincipal.h"
#include "Filtros.h"


const char* rutaImagenBase = "lineas.jpg";
const int tamMenu = -2;
const int posXManito = -2;
const int posYManito = -5;
const unsigned char TH_DEFAULT = 100;
const unsigned char TL_DEFAULT = 60;
const int tiempoIntervaloInicial = 100;



#include <stdio.h>


VentanaPrincipal::VentanaPrincipal(QWidget *parent) : QMainWindow(parent), ui(new Ui::VentanaPrincipal)
{
    ui->setupUi(this);
    
    filtro = 0;
    filtrosNinguno();
    fuente = 0;
    fuentesNinguno();
    aplicarEnC();

    play = false;
    habilitarGuardar();

    reiniciarParamsEscala();

    taparObjetosUmbral();
    taparObjetosColorizar();
    taparObjetosUmbralizar();
    taparObjetosWaves();

    taparObjetosVideo();

    /// Pintado de la medición
    pintaPrimerClick = false;
    pintaSegundoClick = false;
}

VentanaPrincipal::~VentanaPrincipal()
{

    delete ui;
}

void VentanaPrincipal::Iniciar()
{
    imagen = cvLoadImage(rutaImagenBase);
    video = NULL;
    play = false;
    habilitarGuardar();
    taparObjetosVideo();
    camara = NULL;


    // Variables para los filtros
    x = 0;
    y = 0;
    x0 = 0;
    y0 = 0;
    tam = 200;
    alpha = 128;
    alphaColorizar = 0.5;
    min = 64;
    max = 128;
    q = 16;
    x_scale = 2.0;
    y_scale = 4.0;
    g_scale = 16.0;



    if(imagen){
        thresholdHigh = TH_DEFAULT;
        thresholdLow = TL_DEFAULT;

        imagelabelDestiny = ui->labelDestiny;
        imagelabelSource = ui->labelSource;

        ponerImagen(imagen, imagelabelSource);
        ponerImagen(imagen, imagelabelDestiny);

        //timer = startTimer(tiempoIntervaloInicial);
    }
    else{
        QMessageBox error;
        error.critical(0,"Error","Se ha producido un error al iniciar el programa. Verifique que todos los archivos se encuentran en  el directorio.");
        error.setFixedSize(500,200);
        close();
    }

    ultimoPathGuardar = QDir::homePath();
    ultimoPathAbrir = QDir::homePath();
    medicion = -1;
}



/// Funciones sobre la imagen ///
void VentanaPrincipal::voltear_horizontal(unsigned char *src, unsigned char *dst, int m, int n, int row_size)
{
    unsigned char (*src_matrix)[row_size] = (unsigned char (*)[row_size]) src;
    unsigned char (*dst_matrix)[row_size] = (unsigned char (*)[row_size]) dst;

    for (int i = 0; i<m; i+=1) {
        for (int j = 0; j<n; j+=1) {
            dst_matrix[i][n-j-1] = src_matrix[i][j];
        }
    }
}

void VentanaPrincipal::ponerImagen(const cv::Mat& frame, QLabel * donde)
{
    QImage imageQ;
    cv::Mat _tmp;

    switch (frame.type()) {
    case CV_8UC1:
        cvtColor(frame, _tmp, CV_GRAY2RGB);
        break;
    case CV_8UC3:
        cvtColor(frame, _tmp, CV_BGR2RGB);

        break;
    }
    assert(_tmp.isContinuous());
    imageQ = QImage(_tmp.data, _tmp.cols, _tmp.rows, _tmp.cols*3, QImage::Format_RGB888);
    
    QPixmap p = QPixmap::fromImage(imageQ);
    
    int w, h;

    int alturaLabelMAX = donde->maximumSize().height();
    int anchoLabelMAX = donde->maximumSize().width();

    if( _tmp.rows <= alturaLabelMAX && _tmp.cols <= anchoLabelMAX ){
        w = anchoLabelMAX;
        h = alturaLabelMAX;
    }
    else{
        w = donde->width();
        h = donde->height();
    }

    p = p.scaled(w,h,Qt::KeepAspectRatio, Qt::SmoothTransformation);

    donde->setPixmap(p);
}

void VentanaPrincipal::pintarCruz(QLabel * donde, int xs, int ys)
{
    //int posXRelativa = xs - donde->geometry().x() - (donde->size().width() - donde->pixmap()->size().width())/2;
    int posXRelativa = xs - donde->geometry().x();
    int posYRelativa = ys - donde->geometry().y() - (donde->size().height() - donde->pixmap()->size().height())/2;

    QPixmap px(*donde->pixmap());
    QPainter p(&px);
    p.setPen(Qt::red);
    p.drawLine(posXRelativa, posYRelativa, posXRelativa, posYRelativa-10);
    p.drawLine(posXRelativa, posYRelativa, posXRelativa, posYRelativa+10);
    p.drawLine(posXRelativa, posYRelativa, posXRelativa-10, posYRelativa);
    p.drawLine(posXRelativa, posYRelativa, posXRelativa+10, posYRelativa);
    p.end();
    
    donde->setPixmap(px);
}










/// Funciones auxiliares sobre los datos ///
void VentanaPrincipal::operacionConFuentesContinua()
{
    switch (fuente){
    case 2:

        if(play){
            this->imagen = cvQueryFrame(video);
            operacionConImagen();
        }
        break;

    case 3:

        if(play){
            this->imagen = cvQueryFrame(camara);
            operacionConImagen();    
        }
        break;

    default:


        break;
    }
}



void VentanaPrincipal::operacionConImagen()
{
    IplImage* image;
    IplImage* image_b;
    IplImage* imageAux;
    IplImage* imageDst;
    IplImage* imageSmo;
    IplImage* imageAng;
    IplImage* imageGrd;
    CvSize dst_size;

    QMessageBox error;

    image = this->imagen;
    if(image != NULL){
        dst_size.width = image->width;
        dst_size.height = image->height;

        imageAux = cvCreateImage (dst_size, IPL_DEPTH_8U, 1);
        imageDst = cvCreateImage (dst_size, IPL_DEPTH_8U, 1);

        ponerImagen(this->imagen, imagelabelSource);

        switch (this->filtro){
        case 1: // Roberts Cross
        {
            if(esAssembler){
                monocromatizar_uno_asm((unsigned char*)image->imageData, (unsigned char*)imageAux->imageData, imageAux->height, imageAux->width, image->widthStep, imageAux->widthStep);
                roberts_cross_asm((unsigned char*)imageAux->imageData, (unsigned char*)imageDst->imageData, imageDst->height, imageDst->width, imageAux->widthStep, imageDst->widthStep);
            }
            else{
                monocromatizar_uno_c((unsigned char*)image->imageData, (unsigned char*)imageAux->imageData, imageAux->height, imageAux->width, image->widthStep, imageAux->widthStep);
                roberts_cross_c((unsigned char*)imageAux->imageData, (unsigned char*)imageDst->imageData, imageDst->height, imageDst->width, imageAux->widthStep, imageDst->widthStep);
            }
            ponerImagen(imageDst, imagelabelDestiny);
            if(pintaPrimerClick)
                pintarCruz(imagelabelDestiny, posXPrimerClick, posYPrimerClick);
            if(pintaSegundoClick)
                pintarCruz(imagelabelDestiny, posXSegundoClick, posYSegundoClick);
        }
            break;

        case 2: // Sobel
        {
            if(esAssembler){
                monocromatizar_uno_asm((unsigned char*)image->imageData, (unsigned char*)imageAux->imageData, imageAux->height, imageAux->width, image->widthStep, imageAux->widthStep);
                sobel_asm((unsigned char*)imageAux->imageData, (unsigned char*)imageDst->imageData, imageDst->height, imageDst->width, imageAux->widthStep, imageDst->widthStep);
            }
            else{
                monocromatizar_uno_c((unsigned char*)image->imageData, (unsigned char*)imageAux->imageData, imageAux->height, imageAux->width, image->widthStep, imageAux->widthStep);
                sobel_c((unsigned char*)imageAux->imageData, (unsigned char*)imageDst->imageData, imageDst->height, imageDst->width, imageAux->widthStep, imageDst->widthStep);
            }
            ponerImagen(imageDst, imagelabelDestiny);
            if(pintaPrimerClick)
                pintarCruz(imagelabelDestiny, posXPrimerClick, posYPrimerClick);
            if(pintaSegundoClick)
                pintarCruz(imagelabelDestiny, posXSegundoClick, posYSegundoClick);
        }
            break;

        case 3: // Prewitt
        {
            if(esAssembler){
                monocromatizar_uno_asm((unsigned char*)image->imageData, (unsigned char*)imageAux->imageData, imageAux->height, imageAux->width, image->widthStep, imageAux->widthStep);
                prewitt_asm((unsigned char*)imageAux->imageData, (unsigned char*)imageDst->imageData, imageDst->height, imageDst->width, imageAux->widthStep, imageDst->widthStep);
            }
            else{
                monocromatizar_uno_c((unsigned char*)image->imageData, (unsigned char*)imageAux->imageData, imageAux->height, imageAux->width, image->widthStep, imageAux->widthStep);
                prewitt_c((unsigned char*)imageAux->imageData, (unsigned char*)imageDst->imageData, imageDst->height, imageDst->width, imageAux->widthStep, imageDst->widthStep);
            }
            ponerImagen(imageDst, imagelabelDestiny);
            if(pintaPrimerClick)
                pintarCruz(imagelabelDestiny, posXPrimerClick, posYPrimerClick);
            if(pintaSegundoClick)
                pintarCruz(imagelabelDestiny, posXSegundoClick, posYSegundoClick);
        }
            break;

        case 4: // Canny
        {   
            imageSmo = cvCreateImage (dst_size, IPL_DEPTH_8U, 1);
            imageAng = cvCreateImage (dst_size, IPL_DEPTH_8U, 1);
            imageGrd = cvCreateImage (dst_size, IPL_DEPTH_8U, 1);

            if(esAssembler){
                monocromatizar_uno_asm((unsigned char*)image->imageData, (unsigned char*)imageAux->imageData, imageAux->height, imageAux->width, image->widthStep, imageAux->widthStep);
                smoothing_asm((unsigned char*)imageAux->imageData, (unsigned char*)imageSmo->imageData, imageDst->height, imageDst->width, imageAux->widthStep, imageDst->widthStep);
                anguloSobel_asm((unsigned char*) imageSmo->imageData, (unsigned char *) imageGrd->imageData, (unsigned char *) imageAng->imageData, imageSmo->height, imageSmo->width, imageSmo->widthStep, imageGrd->widthStep, imageAng->widthStep);
                nonMaxSup_asm((unsigned char*) imageGrd->imageData, (unsigned char *) imageAng->imageData, (unsigned char *) imageDst->imageData, imageDst->height, imageDst->width, imageGrd->widthStep, imageAng->widthStep, imageDst->widthStep, thresholdHigh, thresholdLow);
            }
            else{
                monocromatizar_uno_c((unsigned char*)image->imageData, (unsigned char*)imageAux->imageData, imageAux->height, imageAux->width, image->widthStep, imageAux->widthStep);
                smoothing_c((unsigned char*)imageAux->imageData, (unsigned char*)imageSmo->imageData, imageDst->height, imageDst->width, imageAux->widthStep, imageDst->widthStep);
                anguloSobel_c((unsigned char*) imageSmo->imageData, (unsigned char *) imageGrd->imageData, (unsigned char *) imageAng->imageData, imageSmo->height, imageSmo->width, imageSmo->widthStep, imageGrd->widthStep, imageAng->widthStep);
                nonMaxSup_c((unsigned char*) imageGrd->imageData, (unsigned char *) imageAng->imageData, (unsigned char *) imageDst->imageData, imageDst->height, imageDst->width, imageGrd->widthStep, imageAng->widthStep, imageDst->widthStep, thresholdHigh, thresholdLow);
            }
            doubleThresholding_c((unsigned char*)imageDst->imageData, imageDst->height, imageDst->width, imageDst->widthStep);
            ponerImagen(imageDst, imagelabelDestiny);
            if(pintaPrimerClick)
                pintarCruz(imagelabelDestiny, posXPrimerClick, posYPrimerClick);
            if(pintaSegundoClick)
                pintarCruz(imagelabelDestiny, posXSegundoClick, posYSegundoClick);

            cvReleaseImage(&imageSmo);
            cvReleaseImage(&imageAng);
            cvReleaseImage(&imageGrd);
        }
            break;

        case 5: // Recortar
        {
            dst_size.width = tam;
            dst_size.height = tam;
            cvReleaseImage(&imageDst);
            imageDst = cvCreateImage (dst_size, IPL_DEPTH_8U, 1);            
            if(esAssembler){
                monocromatizar_uno_asm((unsigned char*)image->imageData, (unsigned char*)imageAux->imageData, imageAux->height, imageAux->width, image->widthStep, imageAux->widthStep);
                recortar_asm((unsigned char*)imageAux->imageData, (unsigned char*)imageDst->imageData, imageDst->height, imageDst->width, imageAux->widthStep, imageDst->widthStep, x, y, tam);
            }
            else{
                monocromatizar_uno_c((unsigned char*)image->imageData, (unsigned char*)imageAux->imageData, imageAux->height, imageAux->width, image->widthStep, imageAux->widthStep);
                recortar_c((unsigned char*)imageAux->imageData, (unsigned char*)imageDst->imageData, imageDst->height, imageDst->width, imageAux->widthStep, imageDst->widthStep, x, y, tam);
            }
            ponerImagen(imageDst, imagelabelDestiny);
            if(pintaPrimerClick)
                pintarCruz(imagelabelDestiny, posXPrimerClick, posYPrimerClick);
            if(pintaSegundoClick)
                pintarCruz(imagelabelDestiny, posXSegundoClick, posYSegundoClick);
        }
            break;

        case 6: // Pixelar
        {
            if(esAssembler){
                monocromatizar_uno_asm((unsigned char*)image->imageData, (unsigned char*)imageAux->imageData, imageAux->height, imageAux->width, image->widthStep, imageAux->widthStep);
                pixelar_asm((unsigned char*)imageAux->imageData, (unsigned char*)imageDst->imageData, imageDst->height, imageDst->width, imageAux->widthStep, imageDst->widthStep);
            }
            else{
                monocromatizar_uno_c((unsigned char*)image->imageData, (unsigned char*)imageAux->imageData, imageAux->height, imageAux->width, image->widthStep, imageAux->widthStep);
                pixelar_c((unsigned char*)imageAux->imageData, (unsigned char*)imageDst->imageData, imageDst->height, imageDst->width, imageAux->widthStep, imageDst->widthStep);
            }
            ponerImagen(imageDst, imagelabelDestiny);
            if(pintaPrimerClick)
                pintarCruz(imagelabelDestiny, posXPrimerClick, posYPrimerClick);
            if(pintaSegundoClick)
                pintarCruz(imagelabelDestiny, posXSegundoClick, posYSegundoClick);
        }
            break;

        case 7: // Combinar
        {
            image_b = cvCreateImage(dst_size, IPL_DEPTH_8U, 1);
            if(esAssembler){
                monocromatizar_uno_asm((unsigned char*)image->imageData, (unsigned char*)imageAux->imageData, imageAux->height, imageAux->width, image->widthStep, imageAux->widthStep);
                voltear_horizontal((unsigned char*)imageAux->imageData, (unsigned char*)image_b->imageData, imageAux->height, imageAux->width, imageAux->widthStep);
                combinar_asm((unsigned char*)imageAux->imageData, (unsigned char*)image_b->imageData, (unsigned char*)imageDst->imageData, imageDst->height, imageDst->width, imageDst->widthStep, alpha);
            }
            else{
                monocromatizar_uno_c((unsigned char*)image->imageData, (unsigned char*)imageAux->imageData, imageAux->height, imageAux->width, image->widthStep, imageAux->widthStep);
                voltear_horizontal((unsigned char*)imageAux->imageData, (unsigned char*)image_b->imageData, imageAux->height, imageAux->width, imageAux->widthStep);
                combinar_c((unsigned char*)imageAux->imageData, (unsigned char*)image_b->imageData, (unsigned char*)imageDst->imageData, imageDst->height, imageDst->width, imageDst->widthStep, alpha);
            }
            ponerImagen(imageDst, imagelabelDestiny);
            if(pintaPrimerClick)
                pintarCruz(imagelabelDestiny, posXPrimerClick, posYPrimerClick);
            if(pintaSegundoClick)
                pintarCruz(imagelabelDestiny, posXSegundoClick, posYSegundoClick);
        }
            break;

        case 8: // Monocromatizar uno
        {
            if(esAssembler){
                monocromatizar_uno_asm((unsigned char*)image->imageData, (unsigned char*)imageDst->imageData, imageDst->height, imageDst->width, image->widthStep, imageDst->widthStep);
            }
            else{
                monocromatizar_uno_c((unsigned char*)image->imageData, (unsigned char*)imageDst->imageData, imageDst->height, imageDst->width, image->widthStep, imageDst->widthStep);
            }
            ponerImagen(imageDst, imagelabelDestiny);
            if(pintaPrimerClick)
                pintarCruz(imagelabelDestiny, posXPrimerClick, posYPrimerClick);
            if(pintaSegundoClick)
                pintarCruz(imagelabelDestiny, posXSegundoClick, posYSegundoClick);
        }
            break;

        case 9: // Monocromatizar infinito
        {
            if(esAssembler){
                monocromatizar_inf_asm((unsigned char*)image->imageData, (unsigned char*)imageDst->imageData, imageDst->height, imageDst->width, image->widthStep, imageDst->widthStep);
            }
            else{
                monocromatizar_inf_c((unsigned char*)image->imageData, (unsigned char*)imageDst->imageData, imageDst->height, imageDst->width, image->widthStep, imageDst->widthStep);
            }
            ponerImagen(imageDst, imagelabelDestiny);
            if(pintaPrimerClick)
                pintarCruz(imagelabelDestiny, posXPrimerClick, posYPrimerClick);
            if(pintaSegundoClick)
                pintarCruz(imagelabelDestiny, posXSegundoClick, posYSegundoClick);
        }
            break;            

        case 10: // Normalizar local
        {
            if(esAssembler){
                monocromatizar_uno_asm((unsigned char*)image->imageData, (unsigned char*)imageAux->imageData, imageAux->height, imageAux->width, image->widthStep, imageAux->widthStep);
                normalizar_local_asm((unsigned char*)imageAux->imageData, (unsigned char*)imageDst->imageData, imageDst->height, imageDst->width, imageAux->widthStep);
            }
            else{
                monocromatizar_uno_c((unsigned char*)image->imageData, (unsigned char*)imageAux->imageData, imageAux->height, imageAux->width, image->widthStep, imageAux->widthStep);
                normalizar_local_c((unsigned char*)imageAux->imageData, (unsigned char*)imageDst->imageData, imageDst->height, imageDst->width, imageAux->widthStep);
            }
            ponerImagen(imageDst, imagelabelDestiny);
            if(pintaPrimerClick)
                pintarCruz(imagelabelDestiny, posXPrimerClick, posYPrimerClick);
            if(pintaSegundoClick)
                pintarCruz(imagelabelDestiny, posXSegundoClick, posYSegundoClick);
        }
            break;

        case 11: // Ondas
        {
            // x0 = imageDst->height/2;
            // y0 = imageDst->width/2;
            if(esAssembler){
                monocromatizar_uno_asm((unsigned char*)image->imageData, (unsigned char*)imageAux->imageData, imageAux->height, imageAux->width, image->widthStep, imageAux->widthStep);
                ondas_asm((unsigned char*)imageAux->imageData, (unsigned char*)imageDst->imageData, imageDst->height, imageDst->width, imageAux->widthStep, x0, y0);
            }
            else{
                monocromatizar_uno_c((unsigned char*)image->imageData, (unsigned char*)imageAux->imageData, imageAux->height, imageAux->width, image->widthStep, imageAux->widthStep);
                ondas_c((unsigned char*)imageAux->imageData, (unsigned char*)imageDst->imageData, imageDst->height, imageDst->width, imageAux->widthStep, x0, y0);
            }
            ponerImagen(imageDst, imagelabelDestiny);
            if(pintaPrimerClick)
                pintarCruz(imagelabelDestiny, posXPrimerClick, posYPrimerClick);
            if(pintaSegundoClick)
                pintarCruz(imagelabelDestiny, posXSegundoClick, posYSegundoClick);
        }
            break;

        case 12: // Recortar y multiplicar
        {
            if(dst_size.height < dst_size.width)
                tamRecortar = dst_size.height/2;
            else
                tamRecortar = dst_size.width/2;
            
            dst_size.width = 2*tamRecortar;
            dst_size.height = 2*tamRecortar;
            cvReleaseImage(&imageDst);
            imageDst = cvCreateImage (dst_size, IPL_DEPTH_8U, 1);
            if(esAssembler){
                monocromatizar_uno_asm((unsigned char*)image->imageData, (unsigned char*)imageAux->imageData, imageAux->height, imageAux->width, image->widthStep, imageAux->widthStep);
                recortarMult_asm((unsigned char*)imageAux->imageData, (unsigned char*)imageDst->imageData, imageDst->height, imageDst->width, imageAux->widthStep, imageDst->widthStep, tamRecortar);
            }
            else{
                monocromatizar_uno_c((unsigned char*)image->imageData, (unsigned char*)imageAux->imageData, imageAux->height, imageAux->width, image->widthStep, imageAux->widthStep);
                recortarMult_c((unsigned char*)imageAux->imageData, (unsigned char*)imageDst->imageData, imageDst->height, imageDst->width, imageAux->widthStep, imageDst->widthStep, tamRecortar);
            }
            ponerImagen(imageDst, imagelabelDestiny);
            if(pintaPrimerClick)
                pintarCruz(imagelabelDestiny, posXPrimerClick, posYPrimerClick);
            if(pintaSegundoClick)
                pintarCruz(imagelabelDestiny, posXSegundoClick, posYSegundoClick);
        }
            break;        

        case 13: // Colorizar
        {
            cvReleaseImage(&imageDst);
            imageDst = cvCreateImage (dst_size, IPL_DEPTH_8U, 3);
            if(esAssembler){
                colorizar_asm((unsigned char*)image->imageData, (unsigned char*)imageDst->imageData, imageDst->height, imageDst->width, image->widthStep, imageDst->widthStep, alphaColorizar);
            }
            else{
                colorizar_c((unsigned char*)image->imageData, (unsigned char*)imageDst->imageData, imageDst->height, imageDst->width, image->widthStep, imageDst->widthStep, alphaColorizar);
            }
            ponerImagen(imageDst, imagelabelDestiny);
            if(pintaPrimerClick)
                pintarCruz(imagelabelDestiny, posXPrimerClick, posYPrimerClick);
            if(pintaSegundoClick)
                pintarCruz(imagelabelDestiny, posXSegundoClick, posYSegundoClick);
        }
            break;       

        case 14: // Halftone
        {
            if(esAssembler){
                monocromatizar_uno_asm((unsigned char*)image->imageData, (unsigned char*)imageAux->imageData, imageAux->height, imageAux->width, image->widthStep, imageAux->widthStep);
                halftone_asm((unsigned char*)imageAux->imageData, (unsigned char*)imageDst->imageData, imageDst->height, imageDst->width, imageAux->widthStep, imageDst->widthStep);
            }
            else{
                monocromatizar_uno_c((unsigned char*)image->imageData, (unsigned char*)imageAux->imageData, imageAux->height, imageAux->width, image->widthStep, imageAux->widthStep);
                halftone_c((unsigned char*)imageAux->imageData, (unsigned char*)imageDst->imageData, imageDst->height, imageDst->width, imageAux->widthStep, imageDst->widthStep);
            }
            ponerImagen(imageDst, imagelabelDestiny);
            if(pintaPrimerClick)
                pintarCruz(imagelabelDestiny, posXPrimerClick, posYPrimerClick);
            if(pintaSegundoClick)
                pintarCruz(imagelabelDestiny, posXSegundoClick, posYSegundoClick);
        }
            break;

        case 15: // Rotar
        {
            if(esAssembler){
                monocromatizar_uno_asm((unsigned char*)image->imageData, (unsigned char*)imageAux->imageData, imageAux->height, imageAux->width, image->widthStep, imageAux->widthStep);
                rotar_asm((unsigned char*)imageAux->imageData, (unsigned char*)imageDst->imageData, imageDst->height, imageDst->width, imageAux->widthStep, imageDst->widthStep);
            }
            else{
                monocromatizar_uno_c((unsigned char*)image->imageData, (unsigned char*)imageAux->imageData, imageAux->height, imageAux->width, image->widthStep, imageAux->widthStep);
                rotar_c((unsigned char*)imageAux->imageData, (unsigned char*)imageDst->imageData, imageDst->height, imageDst->width, imageAux->widthStep, imageDst->widthStep);
            }
            ponerImagen(imageDst, imagelabelDestiny);
            if(pintaPrimerClick)
                pintarCruz(imagelabelDestiny, posXPrimerClick, posYPrimerClick);
            if(pintaSegundoClick)
                pintarCruz(imagelabelDestiny, posXSegundoClick, posYSegundoClick);
        }
            break;

        case 16: // Umbralizar
        {
            if(esAssembler){
                monocromatizar_uno_asm((unsigned char*)image->imageData, (unsigned char*)imageAux->imageData, imageAux->height, imageAux->width, image->widthStep, imageAux->widthStep);
                umbralizar_asm((unsigned char*)imageAux->imageData, (unsigned char*)imageDst->imageData, imageDst->height, imageDst->width, imageAux->widthStep, min, max, q);
            }
            else{
                monocromatizar_uno_c((unsigned char*)image->imageData, (unsigned char*)imageAux->imageData, imageAux->height, imageAux->width, image->widthStep, imageAux->widthStep);
                umbralizar_c((unsigned char*)imageAux->imageData, (unsigned char*)imageDst->imageData, imageDst->height, imageDst->width, imageAux->widthStep, min, max, q);
            }
            ponerImagen(imageDst, imagelabelDestiny);
            if(pintaPrimerClick)
                pintarCruz(imagelabelDestiny, posXPrimerClick, posYPrimerClick);
            if(pintaSegundoClick)
                pintarCruz(imagelabelDestiny, posXSegundoClick, posYSegundoClick);
        }
            break;

        case 17: // Waves
        {
            if(esAssembler){
                monocromatizar_uno_asm((unsigned char*)image->imageData, (unsigned char*)imageAux->imageData, imageAux->height, imageAux->width, image->widthStep, imageAux->widthStep);
                waves_asm((unsigned char*)imageAux->imageData, (unsigned char*)imageDst->imageData, imageDst->height, imageDst->width, imageAux->widthStep, x_scale, y_scale, g_scale);
            }
            else{
                monocromatizar_uno_c((unsigned char*)image->imageData, (unsigned char*)imageAux->imageData, imageAux->height, imageAux->width, image->widthStep, imageAux->widthStep);
                waves_c((unsigned char*)imageAux->imageData, (unsigned char*)imageDst->imageData, imageDst->height, imageDst->width, imageAux->widthStep, x_scale, y_scale, g_scale);
            }
            ponerImagen(imageDst, imagelabelDestiny);
            if(pintaPrimerClick)
                pintarCruz(imagelabelDestiny, posXPrimerClick, posYPrimerClick);
            if(pintaSegundoClick)
                pintarCruz(imagelabelDestiny, posXSegundoClick, posYSegundoClick);
        }
            break;

        default:
        {
            ponerImagen(image, imagelabelDestiny);
            if(pintaPrimerClick)
                pintarCruz(imagelabelDestiny, posXPrimerClick, posYPrimerClick);
            if(pintaSegundoClick)
                pintarCruz(imagelabelDestiny, posXSegundoClick, posYSegundoClick);
        }
            break;
        }

        cvReleaseImage(&imageAux);
        cvReleaseImage(&imageDst);
    }
    else{
        switch (this->fuente){
        case 1:     
            error.critical(0,"Error","Se ha producido un error con la imagen.");
            error.setFixedSize(500,200);
            fuentesNinguno();
            fuente = 0;

            cargarImagenBase();
            video = NULL;
            play = false;
            habilitarGuardar();
            taparObjetosVideo();
            camara = NULL;
            killTimer(timer); 

            break;

        case 2:
            error.information(0,"Finalización","El video ha terminado.");
            error.setFixedSize(500,200);
            fuentesNinguno();
            fuente = 0;

            cargarImagenBase();
            video = NULL;
            play = false;
            habilitarGuardar();
            taparObjetosVideo();
            camara = NULL;
            killTimer(timer); 

            break;

        case 3:
            error.critical(0,"Error","No hay conectada ninguna cámara");
            error.setFixedSize(500,200);
            fuentesNinguno();
            fuente = 0;

            cargarImagenBase();
            video = NULL;
            play = false;
            habilitarGuardar();
            taparObjetosVideo();
            camara = NULL;
            killTimer(timer);

            break;
        }
    }
}




















void VentanaPrincipal::reiniciarParamsEscala()
{
    /// Datos del cálculo de escala
    huboPrimerClick = false;
    huboSegundoClick = false;
    posXPrimerClick = -1;
    posYPrimerClick = -1;
    posXSegundoClick = -1;
    posYSegundoClick = -1;
    escalaSeteada = false;
    escala = -1;
    seteandoEscala = false;

    /// Objetos del cálculo de escala
    ui->labelResultado->setVisible(false);
    ui->labelInstruccion->setVisible(false);
    ui->campoEscala->setVisible(false);
    ui->botonEscala->setVisible(false);
    ui->botonResetearMedicion->setVisible(false);
    medicion = -1;
}

void VentanaPrincipal::filtrosNinguno()
{
    ui->actionNinguno->setChecked(true);
    ui->actionRecortar->setChecked(false);
    ui->actionPixelar->setChecked(false);
    ui->actionCombinar->setChecked(false);
    ui->actionMonocromatizar_uno->setChecked(false);
    ui->actionMonocromatizar_infinito->setChecked(false);
    ui->actionNormalizar_local->setChecked(false);
    ui->actionOndas->setChecked(false);
    ui->actionRoberts_Cross->setChecked(false);
    ui->actionSobel->setChecked(false);
    ui->actionPrewitt->setChecked(false);
    ui->actionCanny->setChecked(false);
    ui->actionRecortar_y_multiplicar->setChecked(false);
    ui->actionColorizar->setChecked(false);
    ui->actionHalftone->setChecked(false);
    ui->actionRotar->setChecked(false);
    ui->actionUmbralizar->setChecked(false);
    ui->actionWaves->setChecked(false);
}

void VentanaPrincipal::filtrosRecortar()
{
    ui->actionNinguno->setChecked(false);
    ui->actionRecortar->setChecked(true);
    ui->actionPixelar->setChecked(false);
    ui->actionCombinar->setChecked(false);
    ui->actionMonocromatizar_uno->setChecked(false);
    ui->actionMonocromatizar_infinito->setChecked(false);
    ui->actionNormalizar_local->setChecked(false);
    ui->actionOndas->setChecked(false);
    ui->actionRoberts_Cross->setChecked(false);
    ui->actionSobel->setChecked(false);
    ui->actionPrewitt->setChecked(false);
    ui->actionCanny->setChecked(false);
    ui->actionRecortar_y_multiplicar->setChecked(false);
    ui->actionColorizar->setChecked(false);
    ui->actionHalftone->setChecked(false);
    ui->actionRotar->setChecked(false);
    ui->actionUmbralizar->setChecked(false);
    ui->actionWaves->setChecked(false);
}

void VentanaPrincipal::filtrosPixelar()
{
    ui->actionNinguno->setChecked(false);
    ui->actionRecortar->setChecked(false);
    ui->actionPixelar->setChecked(true);
    ui->actionCombinar->setChecked(false);
    ui->actionMonocromatizar_uno->setChecked(false);
    ui->actionMonocromatizar_infinito->setChecked(false);
    ui->actionNormalizar_local->setChecked(false);
    ui->actionOndas->setChecked(false);
    ui->actionRoberts_Cross->setChecked(false);
    ui->actionSobel->setChecked(false);
    ui->actionPrewitt->setChecked(false);
    ui->actionCanny->setChecked(false);
    ui->actionRecortar_y_multiplicar->setChecked(false);
    ui->actionColorizar->setChecked(false);
    ui->actionHalftone->setChecked(false);
    ui->actionRotar->setChecked(false);
    ui->actionUmbralizar->setChecked(false);
    ui->actionWaves->setChecked(false);
}

void VentanaPrincipal::filtrosCombinar()
{
    ui->actionNinguno->setChecked(false);
    ui->actionRecortar->setChecked(false);
    ui->actionPixelar->setChecked(false);
    ui->actionCombinar->setChecked(true);
    ui->actionMonocromatizar_uno->setChecked(false);
    ui->actionMonocromatizar_infinito->setChecked(false);
    ui->actionNormalizar_local->setChecked(false);
    ui->actionOndas->setChecked(false);
    ui->actionRoberts_Cross->setChecked(false);
    ui->actionSobel->setChecked(false);
    ui->actionPrewitt->setChecked(false);
    ui->actionCanny->setChecked(false);
    ui->actionRecortar_y_multiplicar->setChecked(false);
    ui->actionColorizar->setChecked(false);
    ui->actionHalftone->setChecked(false);
    ui->actionRotar->setChecked(false);
    ui->actionUmbralizar->setChecked(false);
    ui->actionWaves->setChecked(false);
}

void VentanaPrincipal::filtrosMonocromatizarUno()
{
    ui->actionNinguno->setChecked(false);
    ui->actionRecortar->setChecked(false);
    ui->actionPixelar->setChecked(false);
    ui->actionCombinar->setChecked(false);
    ui->actionMonocromatizar_uno->setChecked(true);
    ui->actionMonocromatizar_infinito->setChecked(false);
    ui->actionNormalizar_local->setChecked(false);
    ui->actionOndas->setChecked(false);
    ui->actionRoberts_Cross->setChecked(false);
    ui->actionSobel->setChecked(false);
    ui->actionPrewitt->setChecked(false);
    ui->actionCanny->setChecked(false);
    ui->actionRecortar_y_multiplicar->setChecked(false);
    ui->actionColorizar->setChecked(false);
    ui->actionHalftone->setChecked(false);
    ui->actionRotar->setChecked(false);
    ui->actionUmbralizar->setChecked(false);
    ui->actionWaves->setChecked(false);
}

void VentanaPrincipal::filtrosMonocromatizarInfinito()
{
    ui->actionNinguno->setChecked(false);
    ui->actionRecortar->setChecked(false);
    ui->actionPixelar->setChecked(false);
    ui->actionCombinar->setChecked(false);
    ui->actionMonocromatizar_uno->setChecked(false);
    ui->actionMonocromatizar_infinito->setChecked(true);
    ui->actionNormalizar_local->setChecked(false);
    ui->actionOndas->setChecked(false);
    ui->actionRoberts_Cross->setChecked(false);
    ui->actionSobel->setChecked(false);
    ui->actionPrewitt->setChecked(false);
    ui->actionCanny->setChecked(false);
    ui->actionRecortar_y_multiplicar->setChecked(false);
    ui->actionColorizar->setChecked(false);
    ui->actionHalftone->setChecked(false);
    ui->actionRotar->setChecked(false);
    ui->actionUmbralizar->setChecked(false);
    ui->actionWaves->setChecked(false);
}

void VentanaPrincipal::filtrosNormalizarLocal()
{
    ui->actionNinguno->setChecked(false);
    ui->actionRecortar->setChecked(false);
    ui->actionPixelar->setChecked(false);
    ui->actionCombinar->setChecked(false);
    ui->actionMonocromatizar_uno->setChecked(false);
    ui->actionMonocromatizar_infinito->setChecked(false);
    ui->actionNormalizar_local->setChecked(true);
    ui->actionOndas->setChecked(false);
    ui->actionRoberts_Cross->setChecked(false);
    ui->actionSobel->setChecked(false);
    ui->actionPrewitt->setChecked(false);
    ui->actionCanny->setChecked(false);
    ui->actionRecortar_y_multiplicar->setChecked(false);
    ui->actionColorizar->setChecked(false);
    ui->actionHalftone->setChecked(false);
    ui->actionRotar->setChecked(false);
    ui->actionUmbralizar->setChecked(false);
    ui->actionWaves->setChecked(false);
}

void VentanaPrincipal::filtrosOndas()
{
    ui->actionNinguno->setChecked(false);
    ui->actionRecortar->setChecked(false);
    ui->actionPixelar->setChecked(false);
    ui->actionCombinar->setChecked(false);
    ui->actionMonocromatizar_uno->setChecked(false);
    ui->actionMonocromatizar_infinito->setChecked(false);
    ui->actionNormalizar_local->setChecked(false);
    ui->actionOndas->setChecked(true);
    ui->actionRoberts_Cross->setChecked(false);
    ui->actionSobel->setChecked(false);
    ui->actionPrewitt->setChecked(false);
    ui->actionCanny->setChecked(false);
    ui->actionRecortar_y_multiplicar->setChecked(false);
    ui->actionColorizar->setChecked(false);
    ui->actionHalftone->setChecked(false);
    ui->actionRotar->setChecked(false);
    ui->actionUmbralizar->setChecked(false);
    ui->actionWaves->setChecked(false);
}

void VentanaPrincipal::filtrosRobertsCross()
{
    ui->actionNinguno->setChecked(false);
    ui->actionRecortar->setChecked(false);
    ui->actionPixelar->setChecked(false);
    ui->actionCombinar->setChecked(false);
    ui->actionMonocromatizar_uno->setChecked(false);
    ui->actionMonocromatizar_infinito->setChecked(false);
    ui->actionNormalizar_local->setChecked(false);
    ui->actionOndas->setChecked(false);
    ui->actionRoberts_Cross->setChecked(true);
    ui->actionSobel->setChecked(false);
    ui->actionPrewitt->setChecked(false);
    ui->actionCanny->setChecked(false);
    ui->actionRecortar_y_multiplicar->setChecked(false);
    ui->actionColorizar->setChecked(false);
    ui->actionHalftone->setChecked(false);
    ui->actionRotar->setChecked(false);
    ui->actionUmbralizar->setChecked(false);
    ui->actionWaves->setChecked(false);
}

void VentanaPrincipal::filtrosSobel()
{
    ui->actionNinguno->setChecked(false);
    ui->actionRecortar->setChecked(false);
    ui->actionPixelar->setChecked(false);
    ui->actionCombinar->setChecked(false);
    ui->actionMonocromatizar_uno->setChecked(false);
    ui->actionMonocromatizar_infinito->setChecked(false);
    ui->actionNormalizar_local->setChecked(false);
    ui->actionOndas->setChecked(false);
    ui->actionRoberts_Cross->setChecked(false);
    ui->actionSobel->setChecked(true);
    ui->actionPrewitt->setChecked(false);
    ui->actionCanny->setChecked(false);
    ui->actionRecortar_y_multiplicar->setChecked(false);
    ui->actionColorizar->setChecked(false);
    ui->actionHalftone->setChecked(false);
    ui->actionRotar->setChecked(false);
    ui->actionUmbralizar->setChecked(false);
    ui->actionWaves->setChecked(false);
}

void VentanaPrincipal::filtrosPrewitt()
{
    ui->actionNinguno->setChecked(false);
    ui->actionRecortar->setChecked(false);
    ui->actionPixelar->setChecked(false);
    ui->actionCombinar->setChecked(false);
    ui->actionMonocromatizar_uno->setChecked(false);
    ui->actionMonocromatizar_infinito->setChecked(false);
    ui->actionNormalizar_local->setChecked(false);
    ui->actionOndas->setChecked(false);
    ui->actionRoberts_Cross->setChecked(false);
    ui->actionSobel->setChecked(false);
    ui->actionPrewitt->setChecked(true);
    ui->actionCanny->setChecked(false);
    ui->actionRecortar_y_multiplicar->setChecked(false);
    ui->actionColorizar->setChecked(false);
    ui->actionHalftone->setChecked(false);
    ui->actionRotar->setChecked(false);
    ui->actionUmbralizar->setChecked(false);
    ui->actionWaves->setChecked(false);
}

void VentanaPrincipal::filtrosCanny()
{
    ui->actionNinguno->setChecked(false);
    ui->actionRecortar->setChecked(false);
    ui->actionPixelar->setChecked(false);
    ui->actionCombinar->setChecked(false);
    ui->actionMonocromatizar_uno->setChecked(false);
    ui->actionMonocromatizar_infinito->setChecked(false);
    ui->actionNormalizar_local->setChecked(false);
    ui->actionOndas->setChecked(false);
    ui->actionRoberts_Cross->setChecked(false);
    ui->actionSobel->setChecked(false);
    ui->actionPrewitt->setChecked(false);
    ui->actionCanny->setChecked(true);
    ui->actionRecortar_y_multiplicar->setChecked(false);
    ui->actionColorizar->setChecked(false);
    ui->actionHalftone->setChecked(false);
    ui->actionRotar->setChecked(false);
    ui->actionUmbralizar->setChecked(false);
    ui->actionWaves->setChecked(false);
}

void VentanaPrincipal::filtrosRecortarMult()
{
    ui->actionNinguno->setChecked(false);
    ui->actionRecortar->setChecked(false);
    ui->actionPixelar->setChecked(false);
    ui->actionCombinar->setChecked(false);
    ui->actionMonocromatizar_uno->setChecked(false);
    ui->actionMonocromatizar_infinito->setChecked(false);
    ui->actionNormalizar_local->setChecked(false);
    ui->actionOndas->setChecked(false);
    ui->actionRoberts_Cross->setChecked(false);
    ui->actionSobel->setChecked(false);
    ui->actionPrewitt->setChecked(false);
    ui->actionCanny->setChecked(false);
    ui->actionRecortar_y_multiplicar->setChecked(true);
    ui->actionColorizar->setChecked(false);
    ui->actionHalftone->setChecked(false);
    ui->actionRotar->setChecked(false);
    ui->actionUmbralizar->setChecked(false);
    ui->actionWaves->setChecked(false);
}

void VentanaPrincipal::filtrosColorizar()
{
    ui->actionNinguno->setChecked(false);
    ui->actionRecortar->setChecked(false);
    ui->actionPixelar->setChecked(false);
    ui->actionCombinar->setChecked(false);
    ui->actionMonocromatizar_uno->setChecked(false);
    ui->actionMonocromatizar_infinito->setChecked(false);
    ui->actionNormalizar_local->setChecked(false);
    ui->actionOndas->setChecked(false);
    ui->actionRoberts_Cross->setChecked(false);
    ui->actionSobel->setChecked(false);
    ui->actionPrewitt->setChecked(false);
    ui->actionCanny->setChecked(false);
    ui->actionRecortar_y_multiplicar->setChecked(false);
    ui->actionColorizar->setChecked(true);
    ui->actionHalftone->setChecked(false);
    ui->actionRotar->setChecked(false);
    ui->actionUmbralizar->setChecked(false);
    ui->actionWaves->setChecked(false);
}

void VentanaPrincipal::filtrosHalftone()
{
    ui->actionNinguno->setChecked(false);
    ui->actionRecortar->setChecked(false);
    ui->actionPixelar->setChecked(false);
    ui->actionCombinar->setChecked(false);
    ui->actionMonocromatizar_uno->setChecked(false);
    ui->actionMonocromatizar_infinito->setChecked(false);
    ui->actionNormalizar_local->setChecked(false);
    ui->actionOndas->setChecked(false);
    ui->actionRoberts_Cross->setChecked(false);
    ui->actionSobel->setChecked(false);
    ui->actionPrewitt->setChecked(false);
    ui->actionCanny->setChecked(false);
    ui->actionRecortar_y_multiplicar->setChecked(false);
    ui->actionColorizar->setChecked(false);
    ui->actionHalftone->setChecked(true);
    ui->actionRotar->setChecked(false);
    ui->actionUmbralizar->setChecked(false);
    ui->actionWaves->setChecked(false);
}

void VentanaPrincipal::filtrosRotar()
{
    ui->actionNinguno->setChecked(false);
    ui->actionRecortar->setChecked(false);
    ui->actionPixelar->setChecked(false);
    ui->actionCombinar->setChecked(false);
    ui->actionMonocromatizar_uno->setChecked(false);
    ui->actionMonocromatizar_infinito->setChecked(false);
    ui->actionNormalizar_local->setChecked(false);
    ui->actionOndas->setChecked(false);
    ui->actionRoberts_Cross->setChecked(false);
    ui->actionSobel->setChecked(false);
    ui->actionPrewitt->setChecked(false);
    ui->actionCanny->setChecked(false);
    ui->actionRecortar_y_multiplicar->setChecked(false);
    ui->actionColorizar->setChecked(false);
    ui->actionHalftone->setChecked(false);
    ui->actionRotar->setChecked(true);
    ui->actionUmbralizar->setChecked(false);
    ui->actionWaves->setChecked(false);
}

void VentanaPrincipal::filtrosUmbralizar()
{
    ui->actionNinguno->setChecked(false);
    ui->actionRecortar->setChecked(false);
    ui->actionPixelar->setChecked(false);
    ui->actionCombinar->setChecked(false);
    ui->actionMonocromatizar_uno->setChecked(false);
    ui->actionMonocromatizar_infinito->setChecked(false);
    ui->actionNormalizar_local->setChecked(false);
    ui->actionOndas->setChecked(false);
    ui->actionRoberts_Cross->setChecked(false);
    ui->actionSobel->setChecked(false);
    ui->actionPrewitt->setChecked(false);
    ui->actionCanny->setChecked(false);
    ui->actionRecortar_y_multiplicar->setChecked(false);
    ui->actionColorizar->setChecked(false);
    ui->actionHalftone->setChecked(false);
    ui->actionRotar->setChecked(false);
    ui->actionUmbralizar->setChecked(true);
    ui->actionWaves->setChecked(false);
}

void VentanaPrincipal::filtrosWaves()
{
    ui->actionNinguno->setChecked(false);
    ui->actionRecortar->setChecked(false);
    ui->actionPixelar->setChecked(false);
    ui->actionCombinar->setChecked(false);
    ui->actionMonocromatizar_uno->setChecked(false);
    ui->actionMonocromatizar_infinito->setChecked(false);
    ui->actionNormalizar_local->setChecked(false);
    ui->actionOndas->setChecked(false);
    ui->actionRoberts_Cross->setChecked(false);
    ui->actionSobel->setChecked(false);
    ui->actionPrewitt->setChecked(false);
    ui->actionCanny->setChecked(false);
    ui->actionRecortar_y_multiplicar->setChecked(false);
    ui->actionColorizar->setChecked(false);
    ui->actionHalftone->setChecked(false);
    ui->actionRotar->setChecked(false);
    ui->actionUmbralizar->setChecked(false);
    ui->actionWaves->setChecked(true);
}

void VentanaPrincipal::fuentesNinguno()
{
    ui->actionNinguno_2->setChecked(true);
    ui->actionImagen->setChecked(false);
    ui->actionVideo->setChecked(false);
    ui->actionWebcam->setChecked(false);
}

void VentanaPrincipal::fuentesImagen()
{
    ui->actionNinguno_2->setChecked(false);
    ui->actionImagen->setChecked(true);
    ui->actionVideo->setChecked(false);
    ui->actionWebcam->setChecked(false);
}

void VentanaPrincipal::fuentesVideo()
{
    ui->actionNinguno_2->setChecked(false);
    ui->actionImagen->setChecked(false);
    ui->actionVideo->setChecked(true);
    ui->actionWebcam->setChecked(false);
}

void VentanaPrincipal::fuentesWebcam()
{
    ui->actionNinguno_2->setChecked(false);
    ui->actionImagen->setChecked(false);
    ui->actionVideo->setChecked(false);
    ui->actionWebcam->setChecked(true);
}

void VentanaPrincipal::mostrarObjetosUmbral()
{
    ui->labelTH->setVisible(true);
    ui->labelTL->setVisible(true);
    ui->campoTH->setVisible(true);
    ui->campoTL->setVisible(true);
    ui->botonDatosIngreso->setVisible(true);
    ui->botonUmbralesDefault->setVisible(true);
}

void VentanaPrincipal::taparObjetosUmbral()
{
    ui->labelTH->setVisible(false);
    ui->labelTL->setVisible(false);
    ui->campoTH->setVisible(false);
    ui->campoTL->setVisible(false);
    ui->botonDatosIngreso->setVisible(false);
    ui->botonUmbralesDefault->setVisible(false);
}

void VentanaPrincipal::aplicarEnC()
{
    esAssembler = false;    // Entonces es C

    ui->actionAssembler->setChecked(false);
    ui->actionC->setChecked(true);

    if(fuente == 1)
        operacionConImagen();    
}

void VentanaPrincipal::aplicarEnAsm()
{
    esAssembler = true;    // Entonces no puede ser C

    ui->actionAssembler->setChecked(true);
    ui->actionC->setChecked(false);

    if(fuente == 1)
        operacionConImagen();    
}

void VentanaPrincipal::taparObjetosVideo()
{

    ui->botonPlayPausa->setVisible(false);
}

void VentanaPrincipal::mostrarObjetosVideo()
{
    ui->botonPlayPausa->setText("Reproducir");
    ui->botonPlayPausa->setVisible(true);        
}

void VentanaPrincipal::cargarImagenBase()
{
    this->imagen = cvLoadImage(rutaImagenBase);
    ponerImagen(this->imagen, imagelabelSource);
    ponerImagen(this->imagen, imagelabelDestiny);   
}

void VentanaPrincipal::habilitarGuardar()
{
    if(fuente == 2 || fuente == 3){
        if(play)
            ui->actionGuardar_imagen->setEnabled(false);
        else
            ui->actionGuardar_imagen->setEnabled(true);
    }
}

void VentanaPrincipal::mostrarObjetosColorizar()
{
    ui->labelColorizar->setVisible(true);
    ui->campoAlpha->setVisible(true);
    ui->botonDatosIngreso->setVisible(true);
}

void VentanaPrincipal::taparObjetosColorizar()
{
    ui->labelColorizar->setVisible(false);
    ui->campoAlpha->setVisible(false);
    ui->botonDatosIngreso->setVisible(false);
}

void VentanaPrincipal::mostrarObjetosUmbralizar()
{
    ui->labelMinimo->setVisible(true);
    ui->labelMaximo->setVisible(true);
    ui->labelQ->setVisible(true);
    ui->campoMinimo->setVisible(true);
    ui->campoMaximo->setVisible(true);
    ui->campoQ->setVisible(true);
    ui->botonDatosIngreso->setVisible(true);
}

void VentanaPrincipal::taparObjetosUmbralizar()
{
    ui->labelMinimo->setVisible(false);
    ui->labelMaximo->setVisible(false);
    ui->labelQ->setVisible(false);
    ui->campoMinimo->setVisible(false);
    ui->campoMaximo->setVisible(false);
    ui->campoQ->setVisible(false);
    ui->botonDatosIngreso->setVisible(false);
}

void VentanaPrincipal::mostrarObjetosWaves()
{
    ui->labelx_scale->setVisible(true);
    ui->labely_scale->setVisible(true);
    ui->labelg_scale->setVisible(true);
    ui->campox_scale->setVisible(true);
    ui->campoy_scale->setVisible(true);
    ui->campog_scale->setVisible(true);
    ui->botonDatosIngreso->setVisible(true);
}

void VentanaPrincipal::taparObjetosWaves()
{
    ui->labelx_scale->setVisible(false);
    ui->labely_scale->setVisible(false);
    ui->labelg_scale->setVisible(false);
    ui->campox_scale->setVisible(false);
    ui->campoy_scale->setVisible(false);
    ui->campog_scale->setVisible(false);
    ui->botonDatosIngreso->setVisible(false);
}





/// Funciones private slots ///

// Funciones del menú de filtros
void VentanaPrincipal::on_actionNinguno_triggered()
{
    filtro = 0;
    filtrosNinguno();
    taparObjetosUmbral();
    taparObjetosColorizar();
    taparObjetosUmbralizar();
    taparObjetosWaves();

    operacionConImagen(); 
}

void VentanaPrincipal::on_actionRecortar_triggered()
{
    filtro = 5;
    filtrosRecortar();
    taparObjetosUmbral();
    taparObjetosColorizar();
    taparObjetosUmbralizar();
    taparObjetosWaves();

    operacionConImagen(); 
    
    if(fuente == 0){
        QMessageBox msgSinFuente;
        msgSinFuente.warning(0,"Atención","Aún no ha seleccionado ninguna fuente. Para elegir alguna, diríjase a 'Fuente'");
        msgSinFuente.setFixedSize(500,200);
    }
}

void VentanaPrincipal::on_actionPixelar_triggered()
{
    filtro = 6;
    filtrosPixelar();
    taparObjetosUmbral();
    taparObjetosColorizar();
    taparObjetosUmbralizar();
    taparObjetosWaves();

    operacionConImagen(); 
    
    if(fuente == 0){
        QMessageBox msgSinFuente;
        msgSinFuente.warning(0,"Atención","Aún no ha seleccionado ninguna fuente. Para elegir alguna, diríjase a 'Fuente'");
        msgSinFuente.setFixedSize(500,200);
    }
}

void VentanaPrincipal::on_actionCombinar_triggered()
{
    filtro = 7;
    filtrosCombinar();
    taparObjetosUmbral();
    taparObjetosColorizar();
    taparObjetosUmbralizar();
    taparObjetosWaves();

    operacionConImagen(); 
    
    if(fuente == 0){
        QMessageBox msgSinFuente;
        msgSinFuente.warning(0,"Atención","Aún no ha seleccionado ninguna fuente. Para elegir alguna, diríjase a 'Fuente'");
        msgSinFuente.setFixedSize(500,200);
    }
}

void VentanaPrincipal::on_actionMonocromatizar_uno_triggered()
{
    filtro = 8;
    filtrosMonocromatizarUno();
    taparObjetosUmbral();
    taparObjetosColorizar();
    taparObjetosUmbralizar();
    taparObjetosWaves();

    operacionConImagen(); 
    
    if(fuente == 0){
        QMessageBox msgSinFuente;
        msgSinFuente.warning(0,"Atención","Aún no ha seleccionado ninguna fuente. Para elegir alguna, diríjase a 'Fuente'");
        msgSinFuente.setFixedSize(500,200);
    }
}

void VentanaPrincipal::on_actionMonocromatizar_infinito_triggered()
{
    filtro = 9;
    filtrosMonocromatizarInfinito();
    taparObjetosUmbral();
    taparObjetosColorizar();
    taparObjetosUmbralizar();
    taparObjetosWaves();

    operacionConImagen(); 
    
    if(fuente == 0){
        QMessageBox msgSinFuente;
        msgSinFuente.warning(0,"Atención","Aún no ha seleccionado ninguna fuente. Para elegir alguna, diríjase a 'Fuente'");
        msgSinFuente.setFixedSize(500,200);
    }
}

void VentanaPrincipal::on_actionNormalizar_local_triggered()
{
    filtro = 10;
    filtrosNormalizarLocal();
    taparObjetosUmbral();
    taparObjetosColorizar();
    taparObjetosUmbralizar();
    taparObjetosWaves();

    operacionConImagen(); 
    
    if(fuente == 0){
        QMessageBox msgSinFuente;
        msgSinFuente.warning(0,"Atención","Aún no ha seleccionado ninguna fuente. Para elegir alguna, diríjase a 'Fuente'");
        msgSinFuente.setFixedSize(500,200);
    }
}

void VentanaPrincipal::on_actionOndas_triggered()
{
    filtro = 11;
    filtrosOndas();
    taparObjetosUmbral();
    taparObjetosColorizar();
    taparObjetosUmbralizar();
    taparObjetosWaves();

    operacionConImagen(); 
    
    if(fuente == 0){
        QMessageBox msgSinFuente;
        msgSinFuente.warning(0,"Atención","Aún no ha seleccionado ninguna fuente. Para elegir alguna, diríjase a 'Fuente'");
        msgSinFuente.setFixedSize(500,200);
    }
}

void VentanaPrincipal::on_actionRecortar_y_multiplicar_triggered()
{
    filtro = 12;
    filtrosRecortarMult();
    taparObjetosUmbral();
    taparObjetosColorizar();
    taparObjetosUmbralizar();
    taparObjetosWaves();

    operacionConImagen(); 
    
    if(fuente == 0){
        QMessageBox msgSinFuente;
        msgSinFuente.warning(0,"Atención","Aún no ha seleccionado ninguna fuente. Para elegir alguna, diríjase a 'Fuente'");
        msgSinFuente.setFixedSize(500,200);
    }
}

void VentanaPrincipal::on_actionColorizar_triggered()
{
    filtro = 13;
    filtrosColorizar();
    taparObjetosUmbral();
    taparObjetosUmbralizar();
    taparObjetosWaves();
    mostrarObjetosColorizar();


    operacionConImagen(); 
    
    if(fuente == 0){
        QMessageBox msgSinFuente;
        msgSinFuente.warning(0,"Atención","Aún no ha seleccionado ninguna fuente. Para elegir alguna, diríjase a 'Fuente'");
        msgSinFuente.setFixedSize(500,200);
    }
}

void VentanaPrincipal::on_actionHalftone_triggered()
{
    filtro = 14;
    filtrosHalftone();
    taparObjetosUmbral();
    taparObjetosColorizar();
    taparObjetosUmbralizar();
    taparObjetosWaves();

    operacionConImagen(); 
    
    if(fuente == 0){
        QMessageBox msgSinFuente;
        msgSinFuente.warning(0,"Atención","Aún no ha seleccionado ninguna fuente. Para elegir alguna, diríjase a 'Fuente'");
        msgSinFuente.setFixedSize(500,200);
    }
}

void VentanaPrincipal::on_actionRotar_triggered()
{
    filtro = 15;
    filtrosRotar();
    taparObjetosUmbral();
    taparObjetosColorizar();
    taparObjetosUmbralizar();
    taparObjetosWaves();

    operacionConImagen(); 
    
    if(fuente == 0){
        QMessageBox msgSinFuente;
        msgSinFuente.warning(0,"Atención","Aún no ha seleccionado ninguna fuente. Para elegir alguna, diríjase a 'Fuente'");
        msgSinFuente.setFixedSize(500,200);
    }
}

void VentanaPrincipal::on_actionUmbralizar_triggered()
{
    filtro = 16;
    filtrosUmbralizar();
    taparObjetosUmbral();
    taparObjetosColorizar();
    taparObjetosWaves();
    mostrarObjetosUmbralizar();

    operacionConImagen(); 
    
    if(fuente == 0){
        QMessageBox msgSinFuente;
        msgSinFuente.warning(0,"Atención","Aún no ha seleccionado ninguna fuente. Para elegir alguna, diríjase a 'Fuente'");
        msgSinFuente.setFixedSize(500,200);
    }
}

void VentanaPrincipal::on_actionWaves_triggered()
{
    filtro = 17;
    filtrosWaves();
    taparObjetosUmbral();
    taparObjetosColorizar();
    taparObjetosUmbralizar();
    mostrarObjetosWaves();

    operacionConImagen(); 
    
    if(fuente == 0){
        QMessageBox msgSinFuente;
        msgSinFuente.warning(0,"Atención","Aún no ha seleccionado ninguna fuente. Para elegir alguna, diríjase a 'Fuente'");
        msgSinFuente.setFixedSize(500,200);
    }
}

void VentanaPrincipal::on_actionRoberts_Cross_triggered()
{
    filtro = 1;
    filtrosRobertsCross();
    taparObjetosUmbral();
    taparObjetosColorizar();
    taparObjetosUmbralizar();
    taparObjetosWaves();

    operacionConImagen(); 
    
    if(fuente == 0){
        QMessageBox msgSinFuente;
        msgSinFuente.warning(0,"Atención","Aún no ha seleccionado ninguna fuente. Para elegir alguna, diríjase a 'Fuente'");
        msgSinFuente.setFixedSize(500,200);
    }
}

void VentanaPrincipal::on_actionSobel_triggered()
{
    filtro = 2;
    filtrosSobel();
    taparObjetosUmbral();
    taparObjetosColorizar();
    taparObjetosUmbralizar();
    taparObjetosWaves();

    operacionConImagen();  

    if(fuente == 0){
        QMessageBox msgSinFuente;
        msgSinFuente.warning(0,"Atención","Aún no ha seleccionado ninguna fuente. Para elegir alguna, diríjase a 'Fuente'");
        msgSinFuente.setFixedSize(500,200);
    }
}

void VentanaPrincipal::on_actionPrewitt_triggered()
{
    filtro = 3;
    filtrosPrewitt();
    taparObjetosUmbral();
    taparObjetosColorizar();
    taparObjetosUmbralizar();
    taparObjetosWaves();

    operacionConImagen();    

    if(fuente == 0){
        QMessageBox msgSinFuente;
        msgSinFuente.warning(0,"Atención","Aún no ha seleccionado ninguna fuente. Para elegir alguna, diríjase a 'Fuente'");
        msgSinFuente.setFixedSize(500,200);
    }    
}

void VentanaPrincipal::on_actionCanny_triggered()
{
    filtro = 4;
    filtrosCanny();
    taparObjetosColorizar();
    taparObjetosUmbralizar();
    taparObjetosWaves();
    mostrarObjetosUmbral();

    operacionConImagen();    

    if(fuente == 0){
        QMessageBox msgSinFuente;
        msgSinFuente.warning(0,"Atención","Aún no ha seleccionado ninguna fuente. Para elegir alguna, diríjase a 'Fuente'");
        msgSinFuente.setFixedSize(500,200);
    }

    QMessageBox msgConfigUmbral;
    QString thD = QString::number(TH_DEFAULT);
    QString tlD = QString::number(TL_DEFAULT);
    QString info1("Para configurar los valores, ingréselos en los siguientes campos y presione 'Ingresar datos'. \nSino, presione 'Datos por defecto' para que el umbral alto sea ");
    QString info2(" y el bajo sea ");
    msgConfigUmbral.information(0,"Configuración de valores de umbral de Canny",info1 + thD + info2 + tlD);
    msgConfigUmbral.setFixedSize(500,200); 
}





// Funciones del menú en general
void VentanaPrincipal::on_actionSetear_Escala_triggered()
{
    huboPrimerClick = false;
    huboSegundoClick = false;
    ui->labelResultado->setVisible(false);

    ui->labelInstruccion->setVisible(true);
    ui->campoEscala->setVisible(true);
    ui->botonEscala->setVisible(true);
    seteandoEscala = true;

    huboPrimerClick = false;
    huboSegundoClick = false;
}

void VentanaPrincipal::on_actionGuardar_imagen_triggered()
{
    QString path;
    if(medicion == -1){ // No hay medición
        path = ultimoPathGuardar + "/imagen.bmp";
    }
    else{
        path = ultimoPathGuardar + "/imagen" + QString::number(medicion) + ".bmp";
    }
    
    QString filename = QFileDialog::getSaveFileName(this, tr("Guardar imagen"), path, tr("Imágenes (*.bmp *.png *.jpg *.jpeg *.tiff)"));

    // Si el path es vacío 
    if(!filename.isEmpty()){
        // Para que quede guardado en la próxima
        QFileInfo fi(filename);
        ultimoPathGuardar = fi.absolutePath();

        QFile file(filename);
        
        // Intenta abrir el archivo, si falla lo avisa con un mensaje
        if(!file.open(QIODevice::WriteOnly)){
            QMessageBox errorAbrir;
            errorAbrir.critical(0,"Error","La imagen no pudo ser guardada. Inténtelo nuevamente.");
            errorAbrir.setFixedSize(500,200);
        }
        else{
            // Intenta guardar la imagen, si falla lo avisa con un mensaje
            if(!(imagelabelDestiny->pixmap())->save(&file, 0, -1)){
                QMessageBox errorSave;
                errorSave.critical(0,"Error","La imagen no pudo ser guardada. Inténtelo nuevamente.");
                errorSave.setFixedSize(500,200);
            }
            else
                file.close();  
        }
    }
}

void VentanaPrincipal::on_actionSalir_triggered()
{

    close();
}





// Funciones del menu de implementaciones
void VentanaPrincipal::on_actionC_triggered()
{
    aplicarEnC();

    if(fuente == 0){
        QMessageBox msgSinFuente;
        msgSinFuente.warning(0,"Atención","Aún no ha seleccionado ninguna fuente. Para elegir alguna, diríjase a 'Fuente'");
        msgSinFuente.setFixedSize(500,200);
    }

    operacionConImagen();     
}

void VentanaPrincipal::on_actionAssembler_triggered()
{
    aplicarEnAsm();

    if(fuente == 0){
        QMessageBox msgSinFuente;
        msgSinFuente.warning(0,"Atención","Aún no ha seleccionado ninguna fuente. Para elegir alguna, diríjase a 'Fuente'");
        msgSinFuente.setFixedSize(500,200);
    }

    operacionConImagen();     
}







// Funciones del menú de fuente
void VentanaPrincipal::on_actionNinguno_2_triggered()
{
    if(video != NULL)
        cvReleaseCapture(&video);
    if(camara != NULL)
        cvReleaseCapture(&camara);

    fuente = 0;

    cargarImagenBase();
    video = NULL;
    play = false;
    habilitarGuardar();
    taparObjetosVideo();
    camara = NULL;

    fuentesNinguno();

    reiniciarParamsEscala();
}

void VentanaPrincipal::on_actionImagen_triggered()
{
    if(timer)
        killTimer(timer);
    if(video != NULL)
        cvReleaseCapture(&video);
    if(camara != NULL)
        cvReleaseCapture(&camara);

    fuente = 1;

    imagen = NULL;
    video = NULL;
    play = false;
    habilitarGuardar();
    taparObjetosVideo();
    camara = NULL;

    fuentesImagen();

    QString path = ultimoPathAbrir;
    QString filename = QFileDialog::getOpenFileName(this, tr("Abrir imagen"), path, tr("Imágenes (*.bmp *.png *.jpg *.jpeg *.tiff)"));
    // Si el path es vacío 
    if(!filename.isEmpty()){
        // Para que quede guardado en la próxima
        QFileInfo fi(filename);
        ultimoPathAbrir = fi.absolutePath();

        this->imagen = cvLoadImage(filename.toStdString().c_str());
        if(!this->imagen){ // Se fija si lo pudo abrir
            // Si no pudo, mensaje de error y sigue
            QMessageBox messageBox;
            messageBox.critical(0,"Error","La imagen no pudo ser cargada. Inténtelo nuevamente.");
            messageBox.setFixedSize(500,200);
            fuentesNinguno();

            cargarImagenBase();
            fuente = 0;
        }
        else{
            operacionConImagen();
        }
    }

    reiniciarParamsEscala();
}

void VentanaPrincipal::on_actionVideo_triggered()
{
    if(video != NULL)
        cvReleaseCapture(&video);
    if(camara != NULL)
        cvReleaseCapture(&camara);

    fuente = 2;

    imagen = NULL;
    video = NULL;
    play = false;
    habilitarGuardar();
    taparObjetosVideo();
    camara = NULL;

    killTimer(timer);

    fuentesVideo();

    QString path = ultimoPathAbrir;
    QString filename = QFileDialog::getOpenFileName(this, tr("Abrir video"), path, tr("Videos (*.avi *.gif *.flv *.mpeg *.mpg *.wmv *.mov)"));
    // Si el path es vacío 
    if(!filename.isEmpty()){
        // Para que quede guardado en la próxima
        QFileInfo fi(filename);
        ultimoPathAbrir = fi.absolutePath();

        this->video = cvCreateFileCapture(filename.toStdString().c_str());

        if(!this->video){ // Se fija si lo pudo abrir
            // Si no pudo, mensaje de error y sigue
            QMessageBox messageBox;
            messageBox.critical(0,"Error","El video no pudo ser cargado. Inténtelo nuevamente.");
            messageBox.setFixedSize(500,200);
            fuentesNinguno();

            cargarImagenBase();
            fuente = 0;
        }
        else{
            double fps = cvGetCaptureProperty(this->video, CV_CAP_PROP_FPS); 
            double intervalo = 1000 * (1 / fps);
            timer = startTimer(intervalo);

            play = false;
            mostrarObjetosVideo();

            this->imagen = cvQueryFrame(video);
            operacionConImagen();            

            QMessageBox msgInfoPlay;
            msgInfoPlay.information(0,"Reproducción","Para comenzar a reproducir el video presione 'Play'.");
            msgInfoPlay.setFixedSize(500,200);
        }
    }

    reiniciarParamsEscala();
}

void VentanaPrincipal::on_actionWebcam_triggered()
{
    if(video != NULL)
        cvReleaseCapture(&video);
    if(camara != NULL)
        cvReleaseCapture(&camara);

    imagen = NULL;
    video = NULL;
    play = false;
    taparObjetosVideo();
    camara = NULL;

    killTimer(timer);

    time_t start, end;

    time(&start);

    this->camara = cvCreateCameraCapture(-1);

    if(!this->camara){ // Se fija si lo pudo abrir
        // Si no pudo, mensaje de error y sigue
        QMessageBox messageBox;
        messageBox.critical(0,"Error","No hay conectada ninguna cámara");
        messageBox.setFixedSize(500,200);
        fuentesNinguno();

        cargarImagenBase();
        fuente = 0;

        operacionConImagen();
    }
    else{

        // Calcula el tiempo con el que tiene que refrescar
        IplImage* aux = cvRetrieveFrame(this->camara);

        time(&end);

        double fps = 1 / difftime(end, start);
        //int fps = (int)cvGetCaptureProperty(this->camara, CV_CAP_PROP_FPS);
 
        double intervalo = 1000 * (1 / fps);
        timer = startTimer(intervalo);

        fuente = 3;
        fuentesWebcam();

        play = true;
        mostrarObjetosVideo();
        ui->botonPlayPausa->setText("Pausa");
    }

    habilitarGuardar();
    reiniciarParamsEscala();
}














// Funciones de mouse
void VentanaPrincipal::mousePressEvent(QMouseEvent *event)
{
    if(filtro == 1 || filtro == 2 || filtro == 3 || filtro == 4){ // Es alguno de bordes
        // Si son clicks cuando uno setea la escala
        if(seteandoEscala){
            if( (event->pos().x() >= ui->labelDestiny->x()) &&
                (event->pos().x() <= (ui->labelDestiny->x() + ui->labelDestiny->frameGeometry().width())) && 
                (event->pos().y() >= ui->labelDestiny->y()) && 
                (event->pos().y() <= (ui->labelDestiny->y() + ui->labelDestiny->frameGeometry().height())) ){

                if(huboPrimerClick){
                    posXSegundoClick = event->pos().x() + posXManito;
                    posYSegundoClick = event->pos().y() - tamMenu + posYManito;
                    huboSegundoClick = true;
                    pintaSegundoClick = true;

                    distancia = sqrt( (posXSegundoClick - posXPrimerClick)*(posXSegundoClick - posXPrimerClick) + (posYSegundoClick - posYPrimerClick)*(posYSegundoClick - posYPrimerClick) );

                    // Ya se marcaron dos puntos mientras se seteaba
                    escalaSeteada = true;
                    seteandoEscala = false;
                }
                else{
                    posXPrimerClick = event->pos().x() + posXManito;
                    posYPrimerClick = event->pos().y() - tamMenu + posYManito;
                    huboPrimerClick = true;
                    pintaPrimerClick = true;
                }

                operacionConImagen();
            }
        }
        else{ // Si son clicks sobre la imagen
            if( (event->pos().x() >= ui->labelDestiny->x()) &&
                (event->pos().x() <= (ui->labelDestiny->x() + ui->labelDestiny->frameGeometry().width())) && 
                (event->pos().y() >= ui->labelDestiny->y()) && 
                (event->pos().y() <= (ui->labelDestiny->y() + ui->labelDestiny->frameGeometry().height())) ){

                if(escalaSeteada){
                    if(!huboSegundoClick){
                        if(huboPrimerClick){
                            posXSegundoClick = event->pos().x() + posXManito;
                            posYSegundoClick = event->pos().y() - tamMenu + posYManito;
                            huboSegundoClick = true;
                            pintaSegundoClick = true;

                            medicion = escala * sqrt( (posXSegundoClick - posXPrimerClick)*(posXSegundoClick - posXPrimerClick) + (posYSegundoClick - posYPrimerClick)*(posYSegundoClick - posYPrimerClick) );
                            QString texto = "La medición es: ";
                            ui->labelResultado->setText(texto + QString::number(medicion));
                            ui->labelResultado->setVisible(true);
                        }
                        else{
                            posXPrimerClick = event->pos().x() + posXManito;
                            posYPrimerClick = event->pos().y() - tamMenu + posYManito;
                            huboPrimerClick = true;
                            pintaPrimerClick = true;
                        }
                    }

                    operacionConImagen();
                }
                else{
                    QMessageBox msgSinEscala;
                    msgSinEscala.warning(0,"Atención","La escala aún no ha sido seteada. \n Para hacerlo diríjase a 'Opciones' --> 'Setear Escala'");
                    msgSinEscala.setFixedSize(500,200);
                }
            }
        }
    }
    else if(filtro == 11){
        if( (event->pos().x() >= ui->labelDestiny->x()) &&
            (event->pos().x() <= (ui->labelDestiny->x() + ui->labelDestiny->frameGeometry().width())) && 
            (event->pos().y() >= ui->labelDestiny->y()) && 
            (event->pos().y() <= (ui->labelDestiny->y() + ui->labelDestiny->frameGeometry().height())) ){
            
            x0 = event->pos().y() - ui->labelDestiny->y() + posYManito;
            y0 = event->pos().x() - ui->labelDestiny->x() + posXManito;
        }        
    }
}

void VentanaPrincipal::on_botonResetearMedicion_clicked()
{
    if(escalaSeteada){
        pintaPrimerClick = false;
        pintaSegundoClick = false;
        ui->labelResultado->setVisible(false);
        huboPrimerClick = false;
        huboSegundoClick = false;
    }
    else{
        QMessageBox msgSinEscala;
        msgSinEscala.warning(0,"Atención","La escala aún no ha sido seteada. \n Para hacerlo diríjase a 'Opciones' --> 'Setear Escala'");
        msgSinEscala.setFixedSize(500,200);        
    }

    medicion = -1;

    operacionConImagen();
}

void VentanaPrincipal::on_botonEscala_clicked()
{
    if(escalaSeteada){

        QString dLeida = ui->campoEscala->text();
        escala = (dLeida.toDouble()) / distancia;

        ui->labelInstruccion->setVisible(false);
        ui->campoEscala->setVisible(false);
        ui->botonEscala->setVisible(false);

        pintaPrimerClick = false;
        pintaSegundoClick = false;
        huboPrimerClick = false;
        huboSegundoClick = false;

        ui->botonResetearMedicion->setVisible(true);

        QMessageBox msgMedir;
        msgMedir.information(0,"Medición","Para realizar una medición, haga dos clicks sobre la imagen.");
        msgMedir.setFixedSize(500,200); 
    }
    else{
        QMessageBox error;
        error.critical(0,"Error","Aún no se hicieron dos clicks sobre la pantalla.");
        error.setFixedSize(500,200);
    }

    operacionConImagen();
}

void VentanaPrincipal::on_botonUmbralesDefault_clicked()
{
    thresholdHigh = TH_DEFAULT;
    thresholdLow = TL_DEFAULT;
    ui->campoTH->setValue(TH_DEFAULT);
    ui->campoTL->setValue(TL_DEFAULT);

    operacionConImagen();
}

void VentanaPrincipal::on_botonDatosIngreso_clicked()
{
    if(filtro == 4){
        if(ui->campoTH->value() >= ui->campoTL->value()){
            thresholdHigh = ui->campoTH->value();
            thresholdLow = ui->campoTL->value();

            QMessageBox msgConfigUmbral;
            QString thD = QString::number(thresholdHigh);
            QString tlD = QString::number(thresholdLow);
            QString info1("El valor de umbral alto ahora es ");
            QString info2(" y y el valor bajo es ");
            msgConfigUmbral.information(0,"Configuración de valores de umbral de Canny",info1 + thD + info2 + tlD);
            msgConfigUmbral.setFixedSize(500,200); 
        }
        else{
            QMessageBox messageBox;
            messageBox.critical(0,"Error","El valor alto debe ser mayor al bajo. Inténtelo nuevamente.");
            messageBox.setFixedSize(500,200);

            ui->campoTH->setValue(ui->campoTH->minimum());
            ui->campoTL->setValue(ui->campoTL->minimum());
        }
    }
    else if(filtro == 13){
        alphaColorizar = ui->campoAlpha->value();
    }
    else if(filtro == 16){
        if(ui->campoMinimo->value() <= ui->campoMaximo->value()){
            min = ui->campoMinimo->value();
            max = ui->campoMaximo->value();
            q = ui->campoQ->value();
        }
        else{
            QMessageBox messageError;
            messageError.critical(0,"Error","El valor alto debe ser mayor al bajo. Inténtelo nuevamente.");
            messageError.setFixedSize(500,200);

            ui->campoMinimo->setValue(64);
            ui->campoMaximo->setValue(128);
            ui->campoQ->setValue(16);
        }
    }
    else if(filtro == 17){
        x_scale = ui->campox_scale->value();
        y_scale = ui->campoy_scale->value();
        g_scale = ui->campog_scale->value();
    }

    operacionConImagen();  
}

void VentanaPrincipal::on_botonPlayPausa_clicked()
{
    if(play){
        ui->botonPlayPausa->setText("Reproducir");
        play = false;
    }
    else{
        ui->botonPlayPausa->setText("Pausa");
        play = true;
    }
}































/// Funciones protected ///
void VentanaPrincipal::timerEvent(QTimerEvent*)
{

    operacionConFuentesContinua();
}



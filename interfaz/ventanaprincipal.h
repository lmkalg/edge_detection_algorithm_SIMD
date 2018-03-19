#ifndef VENTANAPRINCIPAL_H
#define VENTANAPRINCIPAL_H

#include <QMainWindow>
#include <QWidget>
#include <QVBoxLayout>
#include <QPixmap>
#include <QMouseEvent>
#include <QMessageBox>
#include <QLabel>
#include <QString>
#include <QImage>
#include <QPainter>
#include <QFileDialog>
#include <QFileInfo>
#include <opencv/cv.h>
#include <opencv/highgui.h>
#include <opencv2/imgproc/imgproc.hpp>

#include <time.h>



namespace Ui {
    class VentanaPrincipal;
}

class VentanaPrincipal : public QMainWindow
{
    Q_OBJECT

public:
    explicit VentanaPrincipal(QWidget *parent = 0);
    ~VentanaPrincipal();
    void Iniciar();




private:
    int filtro;
    bool esAssembler;
    int fuente;

    bool huboPrimerClick;
    bool huboSegundoClick;
    int posXPrimerClick;
    int posYPrimerClick;
    int posXSegundoClick;
    int posYSegundoClick;
        
    float medicion;

    bool pintaPrimerClick;
    bool pintaSegundoClick;

    bool escalaSeteada;
    float escala;
    bool seteandoEscala;
    float distancia;

    int timer;

    unsigned char thresholdHigh;
    unsigned char thresholdLow;

    bool play;

    QString ultimoPathGuardar;
    QString ultimoPathAbrir;


    Ui::VentanaPrincipal *ui;
    IplImage cuadro;
    IplImage* imagen;
    CvCapture* video;
    CvCapture* camara;

    QLabel *imagelabelDestiny;
    QLabel *imagelabelSource;


    // Variables para los filtros
    int x; // Para recortar
    int y; // Para recortar
    int tam; // Para recortar
    int x0; // Para ondas
    int y0; // Para ondas
    int tamRecortar; // Para recortarMult
    float alpha; // Para combinar
    float alphaColorizar; // Para colorizar
    unsigned char min; // Para umbralizar
    unsigned char max; // Para umbralizar
    unsigned char q; // Para umbralizar
    float x_scale; // Para waves
    float y_scale; // Para waves
    float g_scale; // Para waves

   

    void voltear_horizontal(unsigned char *, unsigned char *, int, int, int);

    void ponerImagen(IplImage*&, QLabel *);
    void pintarCruz(QLabel *, int, int);






    /// Funciones auxiliares sobre los datos ///
    void operacionConFuentesContinua();
    void operacionConImagen();
    
    void reiniciarParamsEscala();
    
    void filtrosNinguno();
    void filtrosRecortar();
    void filtrosPixelar();
    void filtrosCombinar();
    void filtrosMonocromatizarUno();
    void filtrosMonocromatizarInfinito();
    void filtrosNormalizarLocal();
    void filtrosOndas();
    void filtrosRecortarMult();
    void filtrosColorizar();
    void filtrosHalftone();
    void filtrosRotar();
    void filtrosUmbralizar();
    void filtrosWaves();
    void filtrosRobertsCross();
    void filtrosSobel();
    void filtrosPrewitt();
    void filtrosCanny();

    void fuentesNinguno();
    void fuentesImagen();
    void fuentesVideo();
    void fuentesWebcam();
    void mostrarObjetosUmbral();
    void taparObjetosUmbral();
    void aplicarEnC();
    void aplicarEnAsm();
    void taparObjetosLecturaFuente();
    void mostrarObjetosLecturaFuente();
    void taparObjetosVideo();
    void mostrarObjetosVideo();
    void cargarImagenBase();
    void mostrarObjetosColorizar();
    void taparObjetosColorizar();
    void mostrarObjetosUmbralizar();
    void taparObjetosUmbralizar();
    void mostrarObjetosWaves();
    void taparObjetosWaves();
    void habilitarGuardar();


private slots:
    void on_botonResetearMedicion_clicked();
    void on_botonEscala_clicked();
    void on_botonUmbralesDefault_clicked();
    void on_botonDatosIngreso_clicked();
    void on_botonPlayPausa_clicked();

    void on_actionWebcam_triggered();
    void on_actionVideo_triggered();
    void on_actionNinguno_2_triggered();
    void on_actionImagen_triggered();
    
    void on_actionSetear_Escala_triggered();
    void on_actionAssembler_triggered();
    void on_actionC_triggered();
    void on_actionGuardar_imagen_triggered();
    void on_actionSalir_triggered();

    void on_actionNinguno_triggered();
    void on_actionRecortar_triggered();
    void on_actionPixelar_triggered();
    void on_actionCombinar_triggered();
    void on_actionMonocromatizar_uno_triggered();
    void on_actionMonocromatizar_infinito_triggered();
    void on_actionNormalizar_local_triggered();
    void on_actionOndas_triggered();
    void on_actionRecortar_y_multiplicar_triggered();
    void on_actionColorizar_triggered();
    void on_actionHalftone_triggered();
    void on_actionRotar_triggered();
    void on_actionUmbralizar_triggered();
    void on_actionWaves_triggered();
    void on_actionRoberts_Cross_triggered();
    void on_actionSobel_triggered();
    void on_actionPrewitt_triggered();
    void on_actionCanny_triggered();
    
    void mousePressEvent(QMouseEvent *event);

    

protected:
    void timerEvent(QTimerEvent*);
};

#endif // VENTANAPRINCIPAL_H

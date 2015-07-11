#include <opencv/cv.h>
#include <opencv/highgui.h>
#include <stdio.h>
#include <assert.h>
#include <sstream>
#include <QTextCodec>
#include <QApplication>
#include <QWidget>
#include <QVBoxLayout>

#include "ventanaprincipal.h"



int main(int argc, char **argv) {
    /// Para que los tildes se vean correctamente
    QTextCodec *linuxCodec = QTextCodec::codecForName("UTF-8");
    QTextCodec::setCodecForTr(linuxCodec);
    QTextCodec::setCodecForCStrings(linuxCodec);
    QTextCodec::setCodecForLocale(linuxCodec);



    QApplication app(argc, argv);
    VentanaPrincipal *mainVentana = new VentanaPrincipal();

    mainVentana->Iniciar();

    mainVentana->show();;




    int retval = app.exec();
    

    
    return retval;
}


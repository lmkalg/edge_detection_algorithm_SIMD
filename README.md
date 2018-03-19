# Brief description

Tool to show the difference in time between C and Assembly implementations of well-known edge detection algorithms.

## Authors

* Federico Nicolás Landini (fnlandini)
* Pablo Artuso (partu18)

From the Department of Computer Science of the University of Buenos Aires, Argentina. 

## Prerequisites

Install the following libraries:

* libqt-dev-bin
* Download [opencv](https://github.com/opencv/opencv.git) and compile it (here is a [guide](https://docs.opencv.org/trunk/d7/d9f/tutorial_linux_install.html) you can follow).
* qt4-dev-tools

## How to compile it

After successfully accomplishing the prerequisites, go to the **interfaz** directory, you'll find a Makefile. Just.. make it! 

## How to use the tool

Once you compiled it, go to the **bin** directory and execute the **tpfinal** binary.

## Troubleshooting

If at the moment of running the file, you encounter something related with a missing .so, it's because you didn't put the library in a place where the linker can find it. 
Here is some [Help](https://stackoverflow.com/questions/12335848/opencv-program-compile-error-libopencv-core-so-2-4-cannot-open-shared-object-f) to solve that issue. 





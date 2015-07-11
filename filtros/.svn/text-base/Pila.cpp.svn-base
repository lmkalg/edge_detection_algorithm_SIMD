/// Implementación

#include "Pila.h"


Pila::Pila() : primero(NULL) {}

Pila::~Pila(){
	while(!EsVacia()) SacarTope();
}

bool Pila::EsVacia() const{
    return primero == NULL;
}

void Pila::SacarTope(){
	assert(not EsVacia());
	Nodo* aux = primero;
	aux = primero->siguiente;
	delete primero;
	primero = aux;
}

void Pila::Apilar(int abc, int ord){
	Nodo* nuevo = new Nodo(abc, ord);
	nuevo->siguiente = primero;
	primero = nuevo;
}

int Pila::AbcisaTope() const{
	assert(not EsVacia());
	return primero->abcisa;
}

int Pila::OrdenadaTope() const{
	assert(not EsVacia());
	return primero->ordenada;
}

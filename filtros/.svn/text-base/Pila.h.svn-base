#ifndef PILA_H_INCLUDED
#define PILA_H_INCLUDED
#include <stddef.h>
#include <assert.h>

struct Pila{
	
	/// Constructor de pila vacía
	Pila();
	/// Destructor
	~Pila();
	
	/// Operaciones
	bool EsVacia() const;
	void SacarTope();
	void Apilar(int abc, int ord);
	int AbcisaTope() const;
	int OrdenadaTope() const;

	struct Nodo{
		Nodo(int abc, int ord) : abcisa(abc), ordenada(ord), siguiente(NULL) {};

		int abcisa;
		int ordenada;
		Nodo* siguiente;
	};
	
    Nodo* primero;

};





#endif // PILA_H_INCLUDED

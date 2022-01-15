/**
 * Title : Balanced Search Trees , Hashing and Graphs
 * Author : Yekta Seçkin Satýr
 * ID: 21903227
 * Section : 2
 * Assignment : 4
 * Description : Header File for the WordNetwork
 */
#ifndef WORDNETWORK_H
#define WORDNETWORK_H

#include "HashTable.h"
#include "Queue.h"
#include <fstream>
#include <string.h>
#include <stdlib.h>

class WordNetwork {
public:
    WordNetwork( const string vertexFile , const string edgeFile );
    ~WordNetwork();
    void listNeighbors( const string word ) ;
    void listNeighbors( const string word , const int distance );
    void listConnectedComponents() ;
    void findShortestPath( const string word1 , const string word2 ) ;
private:
    HashTable*  ht;
    string*     words;
    int         matrixSize;
    bool**      adjMatrix;   // symmetrical Matrix

    void listNeighborsHelper( int indiceOfWord , const int distance, bool*& visited);
    void listConnectedComponentsHelper( int indiceOfWord , bool*& visited);
};
#endif

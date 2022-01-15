/**
 * Title : Balanced Search Trees , Hashing and Graphs
 * Author : Yekta Seçkin Satýr
 * ID: 21903227
 * Section : 2
 * Assignment : 4
 * Description : A simple HashTable implementation using separate chaining.
 */
#include "HashTable.h"
HashTable::HashTable(int size){
    tableSize = size;
    hashTable = new List*[tableSize];
    for ( int i = 0; i < size; i++)
        hashTable[i] = new List();
}

HashTable::~HashTable(){
    for (int i = 0; i < tableSize; i++)
        delete hashTable[i];
    delete [] hashTable;
}

bool HashTable::insert(int indice, string word){
    return hashTable[hashFunction(word)]->insert( 1, indice, word);
}

bool HashTable::retrieve(string key, int& indice){
    return hashTable[hashFunction(key)]->getIndiceOf(key, indice);
}

/**
 * The given function in slides for hashing
 */
int HashTable::hashFunction(const string &key){
    int hashVal = 0;
    for (int i = 0; i < key.length(); i++)
        hashVal = 37 * hashVal + key[i];
    hashVal %=tableSize;
    if (hashVal < 0) /* in case overflows occurs */
        hashVal += tableSize;
    return hashVal;
}

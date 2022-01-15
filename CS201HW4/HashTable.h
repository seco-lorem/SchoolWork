/**
 * Title : Balanced Search Trees , Hashing and Graphs
 * Author : Yekta Seçkin Satýr
 * ID: 21903227
 * Section : 2
 * Assignment : 4
 * Description : Header file for the HashTable
 */
#ifndef HASHTABLE_H
#define HASHTABLE_H

#include "LinkedList.h"

class HashTable{
// constructors and destructor:
public:
    // constructor-destructor
    HashTable(int size);
    ~HashTable();
    // operations:
    bool retrieve(string key, int& indice);
    bool insert(int indice, string word);
private:
    int     tableSize;
    List**  hashTable;
    int hashFunction(const string &key);
};
#endif

#include "WordNetwork.h"

int main() {
    // HastTable works fine: int b;    HashTable* a = new HashTable(37);    cout << a->insert(5,"yaa");    cout << a->insert(15,"f");    cout << a->insert(25,"b");    cout << a->retrieve("yaa",b);    cout << b;    cout << a->retrieve("üf",b);    cout << b;    delete a;

    WordNetwork* w = new WordNetwork( "words_vertices.txt", "words_edges.txt");
    w->listNeighbors("cages");
    w->listNeighbors("roger", 2);
    w->listConnectedComponents();
    w->findShortestPath( "nodes", "graph");
    delete w;
/*
    string edgeFile = "words_vertices.txt";
    const char * edges = edgeFile.c_str();

    ifstream readFile;
    readFile.open(edges, ios_base::in);
    string temp;
//    for( wordCount = 0; !readFile.eof(); wordCount++) {
    getline(readFile, temp, '\n');
    cout << readFile.eof() << readFile.eof() << endl;

    cout << "-" << temp << "-" << endl;
    readFile.close();*/

    return 0;
}

/**
 * Title : Balanced Search Trees , Hashing and Graphs
 * Author : Yekta Seçkin Satýr
 * ID: 21903227
 * Section : 2
 * Assignment : 4
 * Description : The implementation for the described word network by graphs that uses an adjacency matrix, a string array, and a hashtable.
 */
#include "WordNetwork.h"

/**
 * Does not Check if multiple entries of the same word, neither does the Hash Table.
 * Reads the files in the same directory to construct a WordNetwork
 * getLine() function's property of getting the last char varies according to version, in our case codeBlocks and Dijkstra.
 * So uncomment/re-comment the given lines with ctrl+F: // 123
 */
WordNetwork::WordNetwork( const string vertexFile , const string edgeFile ){
    // Variables
    int wordCount;
    int end1 = -1;
    int end2 = -1;
    bool success = true;
    string  temp;

    ht = new HashTable(37);
    const char * vertices = vertexFile.c_str();
    const char * edges = edgeFile.c_str();

    // Read the Vertex File
    ifstream readFile;
    readFile.open(vertices, ios_base::in);
    for( wordCount = 0; !readFile.eof(); wordCount++) {
        getline(readFile, temp, '\n');
        temp = temp.substr(0,temp.size()-1);        // 123
        if (temp == "")
            break;
        ht->insert( wordCount, temp);
    }
    readFile.close();

    // Re-iterate the Vertex File for words Array
    ifstream readFile3;
    readFile3.open(vertices, ios_base::in);
    words = new string[wordCount];

    for( int i = 0; !readFile3.eof(); i++) {
        getline(readFile3, temp, '\n');
        temp = temp.substr(0,temp.size()-1);        // 123
        if (temp == "")
            break;
        words[i] = temp;
    }
    readFile3.close();


    // Initialize the adjacency matrix
    adjMatrix = new bool*[wordCount];
    for (int i = 0; i < wordCount; i++) {
        adjMatrix[i] = new bool[wordCount];
        for (int j = 0; j < wordCount; j++)
            adjMatrix[i][j] = false;
    }
    matrixSize = wordCount;

    // Read the Edge File
    ifstream readFile2;
    readFile2.open(edges, ios_base::in);

    while(!readFile2.eof()) {
        getline(readFile2, temp, ',');
        if (temp == "")
            break;
        success &= ht->retrieve( temp, end1);
        getline(readFile2, temp, '\n');
        temp = temp.substr(0,temp.size()-1);        // 123
        success &= ht->retrieve( temp, end2);

        adjMatrix[end1][end2] = true;
        adjMatrix[end2][end1] = true;
    }
    readFile2.close();

    if(!success)
        cout << "Error constructing WorldNetwork: edge file contains a word that vertex file does not." << endl;    // Unnoticed overwrite will lead to a corrupt hash table.
}

/**
 * Destructor
 */
WordNetwork::~WordNetwork(){
    delete ht;
    for (int i = 0; i < matrixSize; i++)
        delete [] adjMatrix[i];
    delete [] adjMatrix;
    delete [] words;
}

/**
 * Simply iterate the first level neighbors of given word
 */
void WordNetwork::listNeighbors( const string word ){
    int indice = -1;
    if(ht->retrieve(word, indice)){
        cout << "Neighbors of " << word << ":" << endl;
        for (int i = 0; i < matrixSize; i++) {
            if(adjMatrix[indice][i])
                cout << words[i] << endl;
        }
    }
    else
        cout << "the word does not exist in the graph" << endl;
}

/**
 * Recursively traverse the graph depth-first,
 * printing all neighbors of parameter until the given depth
 */
void WordNetwork::listNeighborsHelper( int indiceOfWord , const int distance, bool*& visited){
    if (0 < distance) {
        for (int i = 0; i < matrixSize; i++) {
            if(adjMatrix[indiceOfWord][i] && !visited[i]){
                cout << words[i] << endl;
                visited[i] = true;
                listNeighborsHelper(i, distance - 1, visited);
            }
        }
    }
}
void WordNetwork::listNeighbors( const string word , const int distance ){
    // Initalise the recursion
    int indice = -1;
    bool* visited = new bool[matrixSize];
    for (int i = 0; i < matrixSize; i++)
        visited[i] = false;
    if(ht->retrieve(word, indice)){
        // Call the recursive helperfunction
        cout << "Neighbors of " << word << " for disance: " << distance << endl;
        visited[indice] = true;
        listNeighborsHelper( indice, distance, visited);
    }
    else
        cout << "the word does not exist in the graph" << endl;
    delete [] visited;
}

/**
 * Iterate the graph for each connected component
 *     Recursively traverse the graph depth-first
 */
void WordNetwork::listConnectedComponentsHelper( int indiceOfWord , bool*& visited){
    for (int i = 0; i < matrixSize; i++) {
        if(adjMatrix[indiceOfWord][i] && !visited[i]){
            cout << words[i] << endl;
            visited[i] = true;
            listConnectedComponentsHelper(i, visited);
        }
    }
}
void WordNetwork::listConnectedComponents(){
    // Initialise variables
    int connectedComponentCount = 0;
    bool* visited = new bool[matrixSize];
    for (int i = 0; i < matrixSize; i++)
        visited[i] = false;

    // for each element, check if it has neighbors and has been visited
    for (int i = 0; i < matrixSize; i++) {
        if(!visited[i]){
            bool hasNeighbor = false;
            for (int j = 0; j < matrixSize; j++) {
                if (adjMatrix[i][j]) {
                    hasNeighbor = true;
                    break;
                }
            }
            // Call the recursive helperfunction
            if(hasNeighbor){
                connectedComponentCount++;
                cout << "Connected component " << connectedComponentCount << ":\n" << words[i] << endl;
                visited[i] = true;
                listConnectedComponentsHelper( i, visited);
            }
            else
                visited[i] = true;
        }
    }

    delete [] visited;
}

/**
 * Traverse the graph Breath first to find a shortest path
 * Store the path in an int array indicating their predecessor: visited[]
 */
void WordNetwork::findShortestPath( const string word1 , const string word2 ){
    // Variables
    Queue* q = new Queue();
    int indice = -1;
    int target = -1;

    // The intiger: indice of predecessor,
    //          -1: not visited,
    //          -2: starting node
    int* visited = new int[matrixSize];
    for (int i = 0; i < matrixSize; i++)
        visited[i] = -1;

    // Start the traverse Breadth-First
    ht->retrieve( word1, indice);
    ht->retrieve( word2, target);
    q->enqueue(indice);
    visited[indice] = -2;

    while(!q->isEmpty()) {
        q->dequeue(indice);
        // If reached the destination, trace&output the path
        if( indice == target) {
            string output = "\n";
            while (visited[indice] != -2){
                if(visited[indice] < 0)
                    cout << "The program should have not reached here: WordNetwork::findShortestPath" << endl;
                output = "\n" + words[indice] + output;
                indice = visited[indice];
            }
            cout << "Shortest path from " << word1 << " to " << word2 << ":\n" << word1 << output;
            delete [] visited;
            delete q;
            return;
        }
        // Traverse
        for ( int i = 0; i < matrixSize; i++) {
            if( adjMatrix[indice][i] && visited[i] == -1) {
                visited[i] = indice;
                q->enqueue(i);
            }
        }
    }
    cout << "Could not find a path" << endl;
    delete [] visited;
    delete q;
}

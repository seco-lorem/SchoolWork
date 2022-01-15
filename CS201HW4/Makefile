hw4: main.o LinkedList.o HashTable.o WordNetwork.o Queue.o
	g++ main.o LinkedList.o HashTable.o WordNetwork.o Queue.o -o hw4

main.o: main.cpp
	g++ -c main.cpp

LinkedList.o: LinkedList.cpp LinkedList.h
	g++ -c LinkedList.cpp

WordNetwork.o: WordNetwork.cpp WordNetwork.h
	g++ -c WordNetwork.cpp

HashTable.o: HashTable.cpp HashTable.h
	g++ -c HashTable.cpp

Queue.o: Queue.cpp Queue.h
	g++ -c Queue.cpp

clean:
	rm *.o hw4

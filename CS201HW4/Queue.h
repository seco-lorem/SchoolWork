/**
 * Title : Balanced Search Trees , Hashing and Graphs
 * Author : Yekta Seçkin Satýr (original author is the one prepared the previous semesters cs201 course material)
 * ID: 21903227
 * Section : 2
 * Assignment : 4
 * Description : Header File for Queue.
 */
#ifndef QUEUE_H
#define QUEUE_H

#include <cstddef>
typedef int QueueItemType;

class Queue{
public:
    Queue(); // default constructor
    ~Queue(); // destructor
    // Queue operations:
    bool isEmpty() const;
    bool enqueue(QueueItemType newItem);
    bool dequeue();
    bool dequeue(QueueItemType& queueFront);
    bool getFront(QueueItemType& queueFront) const;
private:
    // The queue is implemented as a linked list with one external
    // pointer to the front of the queue and a second external
    // pointer to the back of the queue.
    struct QueueNode{
        QueueItemType item;
        QueueNode *next;
    };
    QueueNode *backPtr;
    QueueNode *frontPtr;
};
#endif

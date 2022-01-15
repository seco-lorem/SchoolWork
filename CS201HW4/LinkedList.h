/**
 * Title : Balanced Search Trees , Hashing and Graphs
 * Author : Yekta Seçkin Satýr (slight modifier, original author is the one prepared the previous semesters cs201 course material)
 * ID: 21903227
 * Section : 2
 * Assignment : 4
 * Description : Header File for the Linked List
 */
#ifndef LINKEDLIST_H
#define LINKEDLIST_H

#include <cstddef>
#include <iostream>
#include <cstdlib>
#include <bits/stdc++.h>

using namespace std;

typedef int ListItemType;
class List{
// constructors and destructor:
public:
    List(); // default constructor
    List(const List& aList); // copy constructor
    ~List(); // destructor
    // list operations:
    bool isEmpty() const;
    int getLength() const;
    bool retrieve(int index, ListItemType& dataItem) const;
    bool getIndiceOf(string key, ListItemType& dataItem) const;
    bool insert(int index, ListItemType newItem, string key);
    bool remove(int index);
private:
    struct ListNode{ // a node on the list
        ListItemType item; // a data item on the list
        ListNode *next; // pointer to next node
        string key;
    };
    int size; // number of items in list
    ListNode *head; // pointer to linked list of items
    ListNode *find(int index) const;    // Returns a pointer to the index-th node in the linked list
};
#endif

/**
 * Title : Balanced Search Trees , Hashing and Graphs
 * Author : Yekta Se�kin Sat�r (slight modifier, original author is the one prepared the previous semesters cs201 course material)
 * ID: 21903227
 * Section : 2
 * Assignment : 4
 * Description : LinkedList from the Fall CS201 course material, modified by adding the getIndiceOf function.
 */
// **********************************************
// Implementation file ListP.cpp for the ADT list
// Pointer-based implementation.
// **********************************************
#include "LinkedList.h" // header file
#include <cstddef> // for NULL
List::List(): size(0), head(NULL){
}

List::List(const List& aList): size(aList.size){
    if (aList.head == NULL)
        head = NULL; // original list is empty
    else {
        // copy first node
        head = new ListNode;
        head->item = aList.head->item;
        // copy rest of list
        ListNode *newPtr = head; // new list ptr
        for (ListNode *origPtr = aList.head->next; origPtr != NULL; origPtr = origPtr->next){
            newPtr->next = new ListNode;
            newPtr = newPtr->next;
            newPtr->item = origPtr->item;
        }
        newPtr->next = NULL;
    }
} // end copy constructor

List::~List(){
    while (!isEmpty())
    remove(1);
} // end destructor

bool List::isEmpty() const{
    return size == 0;
} // end isEmpty

int List::getLength() const{
    return size;
} // end getLength

List::ListNode *List::find(int index) const{
    // Locates a specified node in a linked list.
    // Precondition: index is the number of the
    // desired node.
    // Postcondition: Returns a pointer to the
    // desired node. If index < 1 or index > the
    // number of nodes in the list, returns NULL.
    if ( (index < 1) || (index > getLength()) )
        return NULL;
    else{ // count from the beginning of the list
        ListNode *cur = head;
        for (int skip = 1; skip < index; ++skip)
        cur = cur->next;
        return cur;
    }
} // end find

bool List::retrieve(int index, ListItemType& dataItem) const {
    if ((index < 1) || (index > getLength()))
        return false;
    // get pointer to node, then data in node
    ListNode *cur = find(index);
    dataItem = cur->item;
    return true;
} // end retrieve

bool List::getIndiceOf(string key, ListItemType& dataItem) const {
    // return the intiger indice of the node that contains the given string
    for (ListNode *cur = head; cur != NULL; cur = cur->next) {
        if(cur->key == key){
            dataItem = cur->item;
            return true;
        }
    }
    return false;
} // end getIndiceOf

bool List::insert(int index, ListItemType newItem, string key) {
    int newLength = getLength() + 1;
    if ((index < 1) || (index > newLength))
        return false;
    ListNode *newPtr = new ListNode;
    size = newLength;
    newPtr->item = newItem;
    newPtr->key = key;
    if (index == 1){
        newPtr->next = head;
        head = newPtr;
    }
    else{
        ListNode *prev = find(index-1);
        newPtr->next = prev->next;
        prev->next = newPtr;
    }
    return true;
} // end insert

bool List::remove(int index) {
    ListNode *cur;
    if ((index < 1) || (index > getLength()))
        return false;
    --size;
    if (index == 1){
        cur = head;
        head = head->next;
    }
    else{
        ListNode *prev = find(index-1);
        cur = prev->next;
        prev->next = cur->next;
    }
    cur->next = NULL;
    delete cur;
    cur = NULL;
    return true;
} // end remove

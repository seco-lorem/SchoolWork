# Main program for 3rd lab work.
# Calls subprograms for part 3, 4 and 5 respectively
# and provides a user interface using the given sub-programs.	Modified from:	# CS224 Spring 2021, Program to be used in Lab3
# March 4, 2021									# February 23, 2021
	.text

#listNode* listHead = createLinkedList(10);	// listHead = $s0;
	li	$a0, 10
	jal	createLinkedList
	addi	$s0, $v0, 0

#printLinkedList(listHead);
	addi	$a0, $s0, 0
	jal 	printLinkedList

#DisplayReverseOrderRecursively(listHead);
	addi	$a0, $s0, 0
	addi	$a1, $0, 1	# Optional parameter: To format indexing of nodes in the output
	jal 	DisplayReverseOrderRecursively

#duplicate = DuplicateListIterative(listHead);	// duplicate = $s1;
	addi	$a0, $s0, 0
	jal 	DuplicateListIterative
	addi	$s1, $v0, 0
	
#printLinkedList(duplicate);
	addi	$a0, $s1, 0
	jal 	printLinkedList
	
#duplicate = DuplicateListRecursive(listHead);
	addi	$a0, $s0, 0
	jal 	DuplicateListRecursive
	addi	$s1, $v0, 0

#printLinkedList(duplicate);
	addi	$a0, $s1, 0
	jal 	printLinkedList
	
#exit();
	li	$v0, 10
	syscall

createLinkedList:
# $a0: No. of nodes to be created ($a0 >= 1)
# $v0: returns list head
# Node 1 contains 4 in the data field, node i contains the value 4*i in the data field.
# By 4*i inserting a data value like this
# when we print linked list we can differentiate the node content from the node sequence no (1, 2, ...).
	addi	$sp, $sp, -24
	sw	$s0, 20($sp)
	sw	$s1, 16($sp)
	sw	$s2, 12($sp)
	sw	$s3, 8($sp)
	sw	$s4, 4($sp)
	sw	$ra, 0($sp) 	# Save $ra just in case we may want to call a subprogram
	
	move	$s0, $a0	# $s0: no. of nodes to be created.
	li	$s1, 1		# $s1: Node counter
# Create the first node: header.
# Each node is 8 bytes: link field then data field.
	li	$a0, 8
	li	$v0, 9
	syscall
# OK now we have the list head. Save list head pointer 
	move	$s2, $v0	# $s2 points to the first and last node of the linked list.
	move	$s3, $v0	# $s3 now points to the list head.
	sll	$s4, $s1, 2	
# sll: So that node 1 data value will be 4, node i data value will be 4*i
	sw	$s4, 4($s2)	# Store the data value.
	
addNode:
# Are we done?
# No. of nodes created compared with the number of nodes to be created.
	beq	$s1, $s0, allDone
	addi	$s1, $s1, 1	# Increment node counter.
	li	$a0, 8 		# Remember: Node size is 8 bytes.
	li	$v0, 9
	syscall
# Connect the this node to the lst node pointed by $s2.
	sw	$v0, 0($s2)
# Now make $s2 pointing to the newly created node.
	move	$s2, $v0	# $s2 now points to the new node.
	sll	$s4, $s1, 2	
# sll: So that node 1 data value will be 4, node i data value will be 4*i
	sw	$s4, 4($s2)	# Store the data value.
	j	addNode
allDone:
# Make sure that the link field of the last node cotains 0.
# The last node is pointed by $s2.
	sw	$zero, 0($s2)
	move	$v0, $s3	# Now $v0 points to the list head ($s3).
	
# Restore the register values
	lw	$ra, 0($sp)
	lw	$s4, 4($sp)
	lw	$s3, 8($sp)
	lw	$s2, 12($sp)
	lw	$s1, 16($sp)
	lw	$s0, 20($sp)
	addi	$sp, $sp, 24
	
	jr	$ra
#=========================================================
printLinkedList:
# Print linked list nodes in the following format
# --------------------------------------
# Node No: xxxx (dec)
# Address of Current Node: xxxx (hex)
# Address of Next Node: xxxx (hex)
# Data Value of Current Node: xxx (dec)
# --------------------------------------

# Save $s registers used
	addi	$sp, $sp, -20
	sw	$s0, 16($sp)
	sw	$s1, 12($sp)
	sw	$s2, 8($sp)
	sw	$s3, 4($sp)
	sw	$ra, 0($sp) 	# Save $ra just in case we may want to call a subprogram

# $a0: points to the linked list.
# $s0: Address of current
# s1: Address of next
# $2: Data of current
# $s3: Node counter: 1, 2, ...
	move	$s0, $a0	# $s0: points to the current node.
	li	$s3, 0
printNextNode:
	beq	$s0, $zero, printedAll
				# $s0: Address of current node
	lw	$s1, 0($s0)	# $s1: Address of  next node
	lw	$s2, 4($s0)	# $s2: Data of current node
	addi	$s3, $s3, 1
# $s0: address of current node: print in hex.
# $s1: address of next node: print in hex.
# $s2: data field value of current node: print in decimal.
	la	$a0, line
	li	$v0, 4
	syscall		# Print line seperator
	
	la	$a0, nodeNumberLabel
	li	$v0, 4
	syscall
	
	move	$a0, $s3	# $s3: Node number (position) of current node
	li	$v0, 1
	syscall
	
	la	$a0, addressOfCurrentNodeLabel
	li	$v0, 4
	syscall
	
	move	$a0, $s0	# $s0: Address of current node
	li	$v0, 34
	syscall

	la	$a0, addressOfNextNodeLabel
	li	$v0, 4
	syscall
	move	$a0, $s1	# $s0: Address of next node
	li	$v0, 34
	syscall	
	
	la	$a0, dataValueOfCurrentNode
	li	$v0, 4
	syscall
		
	move	$a0, $s2	# $s2: Data of current node
	li	$v0, 1		
	syscall	

# Now consider next node.
	move	$s0, $s1	# Consider next node.
	j	printNextNode
printedAll:
# Restore the register values
	lw	$ra, 0($sp)
	lw	$s3, 4($sp)
	lw	$s2, 8($sp)
	lw	$s1, 12($sp)
	lw	$s0, 16($sp)
	addi	$sp, $sp, 20
	jr	$ra
#=========================================================
########################################################################################################################
########				Lab work for:	P A R T   3						########
########		A subprogram takes the head node of a linked list of given implementation		########
########			Prints the list in reverse order. Works recursively.				########
########################################################################################################################
#DisplayReverseOrderRecursively(listNode* listHead, int nodeNo) {	// listHead = $a0;	// nodeNo = $a1;
DisplayReverseOrderRecursively:
	sw	$ra,($sp)
	sw	$s0,-4($sp)	# $s0 stores the head of the current Nodes pointer
	addi	$sp,$sp,-8
#	if(listHead != NULL) {
	beq	$0,$a0,endif
#		DisplayReverseOrderRecursively(listHead->next, nodeNo + 1);
	sw	$a0,($sp)
	sw	$a1,-4($sp)
	addi	$sp,$sp,-8
	lw	$a0,($a0)
	addi	$a1,$a1,1
	jal	DisplayReverseOrderRecursively
	addi	$sp,$sp,8
	lw	$a0,($sp)
	lw	$a1,-4($sp)
#		print(listHead*);	// Use the alreadily implemented dormatting in given file
	addi	$s0,$a0,0
	
	la	$a0, line
	li	$v0, 4
	syscall			# Print line seperator
	
	la	$a0, nodeNumberLabel
	li	$v0, 4
	syscall
	
	move	$a0, $a1	# $a1: Node number (position) of current node
	li	$v0, 1
	syscall
	
	la	$a0, addressOfCurrentNodeLabel
	li	$v0, 4
	syscall
	
	move	$a0, $s0	# $s0: Address of current node
	li	$v0, 34
	syscall

	la	$a0, addressOfNextNodeLabel
	li	$v0, 4
	syscall
	
	lw	$a0,($s0)	# ($s0): Address of next node
	li	$v0, 34
	syscall	
	
	la	$a0, dataValueOfCurrentNode
	li	$v0, 4
	syscall
	
	lw	$a0,4($s0)	# 4($s0): Data of current node
	li	$v0, 1		
	syscall
#	}
endif:
#}
	addi	$sp,$sp,8
	lw	$ra,($sp)
	lw	$s0,-4($sp)
	jr	$ra

########################################################################################################################
########				Lab work for:	P A R T   4						########
########	A copy-constructor subprogram for given linked list implementation that works iteratively	########
########################################################################################################################
#DuplicateListIterative(ListNode* original) {	// original = $a0 -> $s0;
DuplicateListIterative:
	sw	$s0,($sp)
	sw	$s1,-4($sp)
	sw	$s2,-8($sp)
	sw	$ra,-12($sp)
	addi	$sp,$sp,-16
	
	addi	$s0,$a0,0
#	Listnode* headNode = new ListNode;	// headNode = $s1 -> $v0;
	li	$a0, 8
	li	$v0, 9
	syscall
	addi	$s1,$v0,0
#	Listnode* n = headNode			// n = $s2;
	addi	$s2,$s1,0
#	for ( ListNode* cur = original; cur != NULL; cur = cur->next) {	// cur = $s0;
for:	beq	$s0,$0,endfor
#		n->item = cur->item;
	lw	$s3,4($s0)
	sw	$s3,4($s2)
#		if (cur->next != NULL)
	lw	$s3,($s0)
	beq	$s3,$0,endif1
#			n->next = new ListNode;
	li	$a0, 8
	li	$v0, 9
	syscall
	sw	$v0,($s2)
endif1:
#		n = n->next;
	lw	$s2,($s2)
#	}
	lw	$s0,($s0)
	j	for
endfor:
#	return headNode;
	addi	$v0,$s1,0
#}
	addi	$sp,$sp,16
	lw	$s0,($sp)
	lw	$s1,-4($sp)
	lw	$s2,-8($sp)
	lw	$ra,-12($sp)
	jr	$ra

########################################################################################################################
########				Lab work for:	P A R T   5						########
########	A copy-constructor subprogram for given linked list implementation that works recursively	########
########################################################################################################################
#DuplicateListRecursive(ListNode* headNode) {	headNode = $a0;
DuplicateListRecursive:
	sw	$s0,($sp)
	sw	$s1,-4($sp)
	sw	$ra,-8($sp)
	addi	$sp,$sp,-12
#	Node* n = new ListNode;			n = $s0;
	sw	$a0,($sp)
	li	$a0, 8
	li	$v0, 9
	syscall
	lw	$a0,($sp)
	addi	$s0,$v0,0
#	n->item = headNode->item;
	lw	$s1,4($a0)
	sw	$s1,4($s0)
#	if (headNode->next != NULL)
	lw	$s1,($a0)
	beq	$0,$s1,endif2
#		n->next = DuplicateListRecursive(headNode->next);
	lw	$a0,($a0)
	jal	DuplicateListRecursive
	sw	$v0,($s0)
endif2:
#	retun n;
	addi	$v0,$s0,0
#}
	addi	$sp,$sp,12
	lw	$s0,($sp)
	lw	$s1,-4($sp)
	lw	$ra,-8($sp)
	jr	$ra
	
	.data
line:	
	.asciiz "\n --------------------------------------"

nodeNumberLabel:
	.asciiz	"\n Node No.: "
	
addressOfCurrentNodeLabel:
	.asciiz	"\n Address of Current Node: "
	
addressOfNextNodeLabel:
	.asciiz	"\n Address of Next Node: "
	
dataValueOfCurrentNode:
	.asciiz	"\n Data Value of Current Node: "

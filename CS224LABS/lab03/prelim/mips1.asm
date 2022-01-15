
	.text		
	.globl main
#print("Function Name    add count  lw count\nmain:             " + instructionCount(main, endmain));
main:	la $a0,str1
	li $v0,4
	syscall

	la $a0,main
	la $a1,endmain
	jal instructionCount
	addi $a0,$v0,0
	li $v0,1
	syscall
	
	la $a0,str
	li $v0,4
	syscall

	addi $a0,$v1,0
	li $v0,1
	syscall
#print("\ninstructionCount: " + instructionCount(instructionCount, endinstructionCount));
	la $a0,str2
	li $v0,4
	syscall

	la $a0,instructionCount
	la $a1,endinstructionCount
	jal instructionCount
	addi $a0,$v0,0
	li $v0,1
	syscall
	
	la $a0,str
	li $v0,4
	syscall
	
	addi $a0,$v1,0
	li $v0,1
	syscall
#exit();
	li $v0,10
	syscall
endmain:
	syscall
#instructionCount( firstInst, lastInst) {	$a0 = firstInst;	$a1 = lastInst;
instructionCount:
	sw $s0, ($sp)
	sw $s1, -4($sp)
	sw $s2, -8($sp)
	sw $s3, -12($sp)
	sw $s4, -16($sp)
	sw $s5, -20($sp)
	sw $s6, -24($sp)
	addi $sp, $sp, -28
#	int addCounter = 0;		addCounter = $s0;
	addi $s0,$0,0
#	int lwCounter = 0;		lwCounter = $s1;
	addi $s1,$0,0
#	int n = lastInst - firstInst + 1;	n = $s2
	sub $s2,$a1,$a0
	srl $s2,$s2,2
	addi $s2,$s2,1
#	for (int i = 0; i < n; i++) {		i = $s3;
	addi $s3,$0,0
for:	slt $s4,$s3,$s2
	beq $0,$s4,endfor
#		extract the operation code
	sll $s4,$s3,2
	add $s6,$s4,$a0
	lw $s6,($s6)
	srl $s4,$s6,26
#		if(opcode == 100011)		// opcode for lw
	addi $s5,$0,35
	bne $s4,$s5,else
#			lwCounter++;
	addi $s1,$s1,1
#		else if(opcode == 000000) {	// opcode for r-type instructions
else:	addi $s5,$0,0
	bne $s4,$s5,endelse
#			extract the function 
	sll $s4,$s6,26
	srl $s4,$s4,26
#			if (funct == 100000)
	addi $s5,$0,32
	bne $s4,$s5,endelse
#				addCounter++;
	addi $s0,$s0,1
#		}
endelse:
#	}
	addi $s3,$s3,1
	j for
endfor:
#	return addCounter, lwCounter;
	addi $v0,$s0,0
	addi $v1,$s1,0
#}
	addi $sp, $sp, 28
	lw $s0, ($sp)
	lw $s1, -4($sp)
	lw $s2, -8($sp)
	lw $s3, -12($sp)
	lw $s4, -16($sp)
	lw $s5, -20($sp)
	lw $s6, -24($sp)
endinstructionCount:
	jr $ra
	.data
str:	.asciiz "          "
str1:	.asciiz "Function Name    add count  lw count\nmain:             "
str2:	.asciiz "\ninstructionCount: "

## end of file mips1.asm

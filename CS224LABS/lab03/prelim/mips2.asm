
	.text		
	.globl __start 

__start:
#dividend = input("For integer division,\nEnter dividend: ");
	la $a0,str
	li $v0,4
	syscall

	li $v0,5
	syscall
	addi $s0,$v0,0
#divisor = input("\nEnter divisor: ");
	la $a0,str1
	li $v0,4
	syscall

	li $v0,5
	syscall
	addi $s1,$v0,0
#print("\nFollowing is the result of the integer division:\n" + divident + " / " + divisor + " = " + divide( divident, divisor));
	la $a0,str2
	li $v0,4
	syscall

	addi $a0,$s0,0
	li $v0,1
	syscall
	
	la $a0,str3
	li $v0,4
	syscall

	addi $a0,$s1,0
	li $v0,1
	syscall
	
	la $a0,str4
	li $v0,4
	syscall

	addi $a0,$s0,0
	addi $a1,$s1,0
	jal divide
	
	addi $a0,$v0,0
	li $v0,1
	syscall
#exit();
	li $v0,10
	syscall
#divide(x,y) {
divide:
#	if (x < y)
	slt $s3,$a0,$a1
	beq $s3,$0,else
#		return 0;
	addi $v0,$0,0
	jr $ra
#	else
else:
#		return divide(x-y,y) + 1
	sw $a0,($sp)
	sw $ra,-4($sp)
	addi $sp,$sp,-8
	
	sub $a0,$a0,$a1
	jal divide
	addi $v0,$v0,1
	
	addi $sp,$sp,8
	lw $a0,($sp)
	lw $ra,-4($sp)
	
	jr $ra
#}

	.data
str:	.asciiz "For integer division,\nEnter dividend: "
str1:	.asciiz "\nEnter divisor: "
str2:	.asciiz "\nFollowing is the result of the integer division:\n"
str3:	.asciiz " / "
str4:	.asciiz " = "

## end of file mips2.asm

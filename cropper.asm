#name: Vincent Huang
#studentID:260761859

.data

#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "C:/Users/chenz/Downloads/test1.txt"
output:	.asciiz "cropped.pgm"	#used as output
.align 4
buffer:  .space 2048		# buffer for upto 2048 bytes
.align 4
newbuff: .space 2048
x1: .word 1
x2: .word 2
y1: .word 3
y2: .word 4
headerbuff: .space 2048
#any extra .data you specify MUST be after this line 



tempbuff: .space 2048		#for holding the ascii digits of the original array
tempbuff2: .space 2048		#for holding the ascii digits of the flipped array
P2: .ascii "P2\n"
Exception: .asciiz "Error while opening the file"
space: .asciiz " "

data: .space 6
Enter: .ascii "Enter in order of X1,X2,Y1,Y2\n"
line: .ascii "\n"




	.text
	.globl main

main:	la $a0,input		#readfile takes $a0 as input
	jal readfile


    #load the appropriate values into the appropriate registers/stack positions
    #appropriate stack positions outlined in function*
    	addi $sp,$sp,-24
	
	li $v0,4
	la $a0,Enter
	syscall

    	li $v0,5		
	syscall
	sw $v0,($sp)
	
    	li $v0,5		
	syscall
	sw $v0,4($sp)
	
    	la $a0,4($sp)
    	li $v0,5		
	syscall
	sw $v0,8($sp)
	
	
    	la $a0,12($sp)
    	li $v0,5		
	syscall
	sw $v0,12($sp)
	
	la $t1,buffer
	sw $t1,16($sp)
	la $t2,newbuff
	sw $t2,20($sp)
	
	lw $a0,($sp)
	lw $a1,4($sp)
	lw $a2,8($sp)
	lw $a3,12($sp)
	
	jal crop

	la $a0, output		#writefile will take $a0 as file location
	la $a1,newbuff		#$a1 takes location of what we wish to write.
	#add what ever else you may need to make this work.
	jal writefile

	li $v0,10		# exit
	syscall

readfile:
#done in Q1
	li $v0,13           	# open_file syscall code = 13
    	la $a0,($a0)     	# get the file name
    	li $a1,0           	# file flag = read (0)
    	syscall
    	
    	beq $v0,-1,Error
    	move $s0,$v0        	# save the file descriptor. $s0 = file
	
	#read the file
	li $v0, 14		# read_file syscall code = 14
	move $a0,$s0		# file descriptor
	la $a1,tempbuff  	# The tempbuff that holds the string of the WHOLE file
	la $a2,2048		# hardcoded buffer length
	syscall
	

	# print whats in the file
	li $v0, 4		# read_string syscall code = 4
	la $a0,tempbuff
	
	syscall

	

	
	#Close the file
    	li $v0, 16         		# close_file syscall code
    	move $a0,$s0      		# file descriptor to close
    	syscall
    	
	jr $ra
    	
Error: 
	li $v0,4
	la $a0,Exception
	syscall
	
	j Exit

crop:
#a0=x1
#a1=x2
#a2=y1
#a3=y2
#16($sp)=buffer
#20($sp)=newbuffer that will be made
#Remember to store ALL variables to the stack as you normally would,
#before starting the routine.
#Try to understand the math before coding!
#There are more than 4 arguments, so use the stack accordingly.

	la $t0,tempbuff			#tempbuff: for the strings
	la $s5,buffer
	la $s6,newbuff
	la $t4,($s5)			#buffer: for the converted integers
	la $t5,($s6)
	la $t6,($s6)

	
	
loop1:	lb $t1,0($t0)
	addi $t0,$t0,1			#point $t1 to the first element of the string buffer
	beq $t1,0,Fin			#end of the file
	beq $t1,' ',loop1
	beq $t1,'\n',loop1
	addi $t1,$t1,-48

	lb $t2,($t0)			#store the next byte in $t2
	addi $t0,$t0,1
	beq $t2,0,Fin
	beq $t2,' ',store
	beq $t2,'\n',store		#if the next byte is space or newline
					#store the word

	addi $t2,$t2,-48			#Convert from ascii digits to integers
	mul $t1,$t1,10
	add $t1,$t1,$t2			#else store a part of the integer to $t3
	

store:	sw $t1,	($t4)			#store the word in $t4


	
	addi $t4,$t4,4			#advance to the next word (next position
	
	
	j loop1			#in the array)

Fin:	
	lw $s6,16($sp)
	lw $s7,20($sp)
	la $t0,($s6)
	la $t1,($s7)
	lw $a0,0($sp)
	lw $a1,4($sp)
	lw $a2,8($sp)
	lw $a3,12($sp)
	sub $t2,$a1,$a0		#get the length of the new img
	addi $t2,$t2,1
	sub $t3,$a3,$a2		#get the width of the new img
	addi $s0,$zero,0	#set the index of the loop i=0
	addi $t3,$t3,1
	
Loop:	

	addi $s1,$zero,24
	div $s0,$s1		
	mfhi $t4		#remainer represents the x coordinate in the array
	mflo $t5		#quotient represents the y coordinate in the array
	
	lw $a0,0($sp)
	
	blt $t4,$a0,else	
	bgt $t4,$a1,else
	blt $t5,$a2,else
	bgt $t5,$a3,else
	


	
	lw $t6,($t0)
	sw $t6,($t1)		#if its in the range of cropping store the number
	addi $t0,$t0,4
	addi $t1,$t1,4
	addi $s0,$s0,1
	blt $s0,168,Loop
	j Fin2
	
else:
	addi $s0,$s0,1
	addi $t0,$t0,4
	blt $s0,168,Loop
	j Fin2
Fin2:	
	addi $t1,$t1,4
	li $t9,-1
	sw $t9,($t1)
	addi $sp,$sp,24
	addi $sp,$sp,-12
	sw $t2,0($sp)
	sw $t3,4($sp)		#restore the stack and store the length and width for writing
	
	jr $ra
writefile:
#slightly different from Q1.
#use as many arguments as you would like to get this to work.
#make sure the header matches the new dimensions!
	sw $ra, 8($sp)
	la $t0,($a1)		#$t0 points to the beginning 
	la $t1,tempbuff2
	li $t2,0		#outer index i

	#conver back to ascii
outerloop2:
	lw $t7,4($sp)
	beq $t2,$t7,endouter2
	li $t3,0		#set the index for j
innerloop2:
	lw $t8,0($sp)
	beq $t3,$t8,endinner2
	lw $t5,($t0)

	bge $t5,10,two
	addi $t5,$t5,48
	sb $t5,($t1)
	addi $t0,$t0,4
	addi $t1,$t1,1
	la $t4,' '
	sb $t4,($t1)
	addi $t1,$t1,1
	la $t4,' '
	sb $t4,($t1)
	addi $t1,$t1,1
	addi $t3,$t3,1

	j innerloop2
	
two:	

	li $t4,10
	div $t5,$t4
	mfhi $t5		#extract the two digits: remainder
	
	mflo $t6		#quotient
	
	addi $t6,$t6,48
	sb $t6,($t1)
	addi $t1,$t1,1
	addi $t5,$t5,48
	sb $t5,($t1)
	addi $t1,$t1,1

	la $t4,' '
	sb $t4,($t1)
	addi $t1,$t1,1
	
	add $t0,$t0,4
	addi $t3,$t3,1
				
	j innerloop2
	
	
	
endinner2:
	la $t3,'\n'
	sb $t3,($t1)
	addi $t1,$t1,1
	addi $t2,$t2,1

	j outerloop2
	
endouter2:


	#open file 
    	li $v0,13           	# open_file syscall code = 13
    	la $a0,output     	# get the file name
    	li $a1,1           	# file flag = write (1)
    	syscall
    	move $s1,$v0        	# save the file descriptor. $s0 = file
    	
    	lw $s2,($sp)		#length
    	lw $s3,4($sp)		#width
    	
    	la $s0,headerbuff
    	li $t0,'P'
    	sb $t0,($s0)
    	addi $s0,$s0,1
    	
    	li $t0, '2'
	sb $t0,($s0)
	addi $s0,$s0,1
	
	li $t0, '\n'
	sb $t0,($s0)
	addi $s0,$s0,1
	
	move $a0,$s2
	jal num
	
	li $t0, ' '
	sb $t0,($s0)
	addi $s0,$s0,1
	
	move $a0,$s3
	jal num
	
	li $t0, '\n'
	sb $t0,($s0)
	addi $s0,$s0,1
	
	li $t0, '1'
	sb $t0,($s0)
	addi $s0,$s0,1
	
	li $t0, '5'
	sb $t0,($s0)
	addi $s0,$s0,1
	
	li $t0, '\n'
	sb $t0,($s0)
	addi $s0,$s0,1
	
	#header
    	
    	
    	j write
    	
    #subroutine for coverting a number back to ascii
num:	blt $a0,10,onedigit
	li $t5,10
	div   $a0,$t5   #  Hi contains the remainder,  Lo contains quotient
	mfhi  $t3        
	mflo  $t4
	addi $t4,$t4,48
	sb $t4,($s0)
	addi $s0,$s0,1
	addi $t3,$t3,48
	sb $t3,($s0)
	addi $s0,$s0,1
	jr $ra
onedigit: addi $t3,$a0,48
	sb $t3,($s0)
	addi $s0,$s0,1
	li $t3,' '
	sb $t3,($s0)
	addi $s0,$s0,1
	jr $ra    	
    	
    	
    	
write:  
	
	li $v0,15		# write_file syscall code = 15
    	move $a0,$s1		# file descriptor
    	la $a1,	headerbuff	# the string that will be written
    	la $a2,12		# length of the toWrite string
    	syscall
    	
    	#Write the buffer to the file
    	li $v0,15		# write_file syscall code = 15
    	move $a0,$s1		# file descriptor
    	la $a1,	tempbuff2	# the string that will be written
    	la $a2,2048		# length of the toWrite string
    	syscall
    	
	#MUST CLOSE FILE IN ORDER TO UPDATE THE FILE
    	li $v0,16         		# close_file syscall code
    	move $a0,$s1      		# file descriptor to close
    	syscall
    	
	lw $ra,8($sp)	
	jr $ra


Exit:
	nop
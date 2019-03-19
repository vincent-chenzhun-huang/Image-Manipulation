#name: Vincent Huang
#studentID: 260761859

.data

#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "C:/Users/chenz/Downloads/test1.txt"
output:	.asciiz "transposed.pgm"	#used as output
.align 4
buffer:  .space 2048		# buffer for upto 2048 bytes
.align 2
newbuff: .space 2048

#any extra data you specify MUST be after this line 

tempbuff: .space 2048
tempbuff2: .space 2048
Exception: .asciiz "Error while opening the file"

Info : .asciiz "P2\n7 24\n15\n"

space: .asciiz " "
line: .ascii "\n"

	.text
	.globl main

main:	la $a0,input 		#readfile takes $a0 as input
	jal readfile


	la $a0,buffer		#$a0 will specify the "2D array" we will be flipping
	la $a1,newbuff		#$a1 will specify the buffer that will hold the flipped array.
    jal transpose


	la $a0, output		#writefile will take $a0 as file location
	la $a1,newbuff		#$a1 takes location of what we wish to write.
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

transpose:
#Can assume 24 by 7 again for the input.txt file
#Try to understand the math before coding!

	la $t0,tempbuff			#tempbuff: for the strings
	la $t4,($a0)			#buffer: for the converted integers
	la $t5,($a1)
	la $t6,($a1)

	
	
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

Fin:	la $t0,($a0)
	la $t1,($a1)		#two pointers point to the beginning of the buffer and newbuff
	li $s0,0		#set the index i=0
	
outerloop:
	li $s1,0		#set the index j=0
	
innerloop:
	lw $t2,($t0)		#load the number to $t2
	addi $t0,$t0,96		#advance the pointer to the next row of the buffer
	

	

	sw $t2,($t1)		#store the pointer in the corresponding position in the newbuff
	addi $t1,$t1,4		#advance the newbuff pointer to the next slot
	addi $s1,$s1,1
	blt $s1,7,innerloop	#if i<7 go back to innerloop
	addi $t0,$t0,-668		#go to the next column of the buffer, 24*4*7-4=668 #go to the next row
	addi $s0,$s0,1
	blt $s0,24,outerloop
	
	jr $ra
	
writefile:
#slightly different from Q1.
#use as many arguments as you would like to get this to work.
#make sure the header matches the new dimensions!

	la $t0,($a1)		#$t0 points to the beginning 
	la $t1,tempbuff2
	li $t2,0		#outer index i

	#conver back to ascii
outerloop2:
	beq $t2,24,endouter2
	li $t3,0		#set the index for j
innerloop2:
	beq $t3,7,endinner2
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
    	

	#Write the info to the file
    	li $v0,15		# write_file syscall code = 15
    	move $a0,$s1		# file descriptor
    	la $a1,Info		# the string that will be written
    	la $a2,11		# length of the toWrite string
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
    	
		
	jr $ra


Exit:
	nop

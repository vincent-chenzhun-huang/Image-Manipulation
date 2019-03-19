#name: Vincent Huang
#studentID: 260761859

.data

#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt"
output:	.asciiz "borded.pgm"	#used as output

borderwidth: .word 2    #specifies border width
buffer:  .space 2048		# buffer for upto 2048 bytes
newbuff: .space 2048
headerbuff: .space 2048  #stores header

#any extra data you specify MUST be after this line 
Exception: .asciiz "Error while opening the file"
tempbuff: .space 2048		#for holding the ascii digits of the original array
tempbuff2: .space 2048	
space: .asciiz " "
line: .ascii "\n"

	.text
	.globl main

main:	la $a0,input		#readfile takes $a0 as input
	jal readfile
	
	li $v0,5		
	syscall	
	addi $a2,$v0,0
	
	la $a0,buffer		#$a1 will specify the "2D array" we will be flipping
	la $a1,newbuff		#$a2 will specify the buffer that will hold the flipped array.

	jal bord


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

bord:
#a0=buffer
#a1=newbuff
#a2=borderwidth
#Can assume 24 by 7 as input
#Try to understand the math before coding!
#EXAMPLE: if borderwidth=2, 24 by 7 becomes 28 by 11.
	la $t0,tempbuff			#tempbuff: for the strings
	la $t4,($a0)			#buffer: for the converted integers
	la $t5,($a1)
	la $t6,($a1)
	
	
loop1:	lb $t1,0($t0)
	addi $t0,$t0,1			#point $t1 to the first element of the string buffer
	beq $t1,0,Fini			#end of the file
	beq $t1,' ',loop1
	beq $t1,'\n',loop1
	addi $t1,$t1,-48

	lb $t2,($t0)			#store the next byte in $t2
	addi $t0,$t0,1
	beq $t2,0,Fini
	beq $t2,' ',store
	beq $t2,'\n',store		#if the next byte is space or newline
					#store the word

	addi $t2,$t2,-48			#Convert from ascii digits to integers
	mul $t1,$t1,10
	add $t1,$t1,$t2			#else store a part of the integer to $t3
	

store:	sw $t1,	($t4)			#store the word in $t4


	
	addi $t4,$t4,4			#advance to the next word (next position
	
	
	j loop1			#in the array)




Fini:	la $t0,($a0)
	addi $sp,$sp,-12
	la $t1,($a1)
	addi $s0,$a2,0
	addi $s1,$zero,0	#set the index i=0
	addi $s2,$s0,24		
	add $s2,$s2,$s0		#total length
	sw $s2,0($sp)
	addi $s3,$s0,7
	add $s3,$s3,$s0		#width
	sw $s3,4($sp)
	addi $s4,$s0,24
	addi $s5,$s0,7
	mul $s6,$s2,$s3
Loop:

	div $s1,$s2
	mflo $t3		#y

	mfhi $t4		#x
	blt $t4,$s0,else	#if not in the range, fill it in with 15
	bge $t4,$s4,else
	blt $t3,$s0,else
	bge $t3,$s5,else
	lw $t5,($t0)
	sw $t5,($t1)
	addi $t0,$t0,4
	addi $t1,$t1,4
	addi $s1,$s1,1
	beq $s1,$s6,Fin
	
	
	j Loop
	
else:
	addi $t5,$zero,15
	sw $t5,($t1)
	addi $s1,$s1,1
	addi $t1,$t1,4
	
	beq $s1,$s6,Fin
	j Loop
	
Fin:
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
	addi $sp,$sp,12
	jr $ra
	
Exit:
	nop

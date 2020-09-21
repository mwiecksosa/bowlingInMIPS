# Michael Wieck-Sosa
# Professor Deleon
# December 6, 2019
# Computer Organization Project
# Bowling Game

.data # data section
array: .space 84 # 21 element integer array
prompt_part1: .asciiz "Enter integer roll "
prompt_part2: .asciiz "/21 to be put into the array: "
oneSpace: .asciiz " "
output: .asciiz "You input the numbers: "
scoringMessage: .asciiz "\nGenerating score for game..."
finalScoreMessage: .asciiz "\nScore for this game: "

.text # text section
main: # main label
	li $t1, 0 # counter for readLoop $t1 = 0 
	la $a1, array # load array address to $a1
	readLoop: # readLoop label
		addi $t1, $t1, 1 # increment counter by 1
		li $v0, 4 # load 4 to $v0 for print string
		la $a0, prompt_part1 # load prompt string to $a0
		syscall #call to print string
		li $v0, 1 # load 1 to $v0 for print int
		addi $a0, $t1, 0 # load int to print
		syscall #call to print int		
		li $v0, 4 # load 4 to $v0 for print string
		la $a0, prompt_part2 # load prompt string to $a0
		syscall #call to print string
		li $v0, 5 # load 5 to $v0 for read integer
		syscall # call to get integer
		sw $v0, 0($a1) # save input in $v0 to array $a1 offset 0 
		addi $a1, $a1, 4 # increment array by 1 index 
		bne $t1, 21, readLoop # restart loop if counter $t1 not eq 21
		la $a1, array # load array address to $a1 
		 
	# prompt user
	li $v0, 4 # load 4 to $v0, to print string
	la $a0, output # load output message to $a0
	syscall # call to print
	
	li $t1, 0 # counter for printLoop $t1 = 0
	printLoop: # printLoop label
		li $v0, 1 # load 1 to $v0, print integer
		lw $a0,0($a1) # load value at address $a1 offset 0 to $a0
		syscall # call to print value
		li $v0, 4 # load 4 to $v0 for print string
		la $a0, oneSpace # load one space to $a0
		syscall # call to print space
		addi $a1,$a1, 4 # add 4 to $a1, increment to next index
		addi $t1, $t1, 1 # add 1 to $t1, increment oop counter 
		bne $t1, 21, printLoop # loop if counter $t1 not 21
		
	li $v0, 4 # load 4 to $v0, print string
	la $a0, scoringMessage # load message
	syscall	# call to print
	
	li $s0, 0 # int score = 0
	li $s1, 0 # frameIndex (counter for scoreLoop) $t0 = 0	
	la $a1, array # load array address to $a0, will be used as argument
	li $a2, 0 # int rollIndex = 0, will be used as argument
	scoreLoop: #for (int frameIndex = 0; frameIndex < 10; frameIndex++) 			
 		if: # if (isStrike(rollIndex)) 
 			jal isStrike # jump and link to isStrike procedure
			jal getStrikeScore # jump and link to getStrikeScore procedure
			# return value from getStrikeScore stored in $v1		 	    
			add $s0, $s0, $v1 #score += getStrikeScore(rollIndex);
			addi $a2, $a2, 4 # rollIndex++;	
			j endIf # jump to endIf label

 		elseIf: # else if (isSpare(rollIndex)) 
 			jal isSpare # jump and link to isSpare procedure
			jal getSpareScore # jump and link to getSpareScore procedure
 			# return value from getStrikeScore stored in $v1 		
			add $s0, $s0, $v1 #score += getSpareScore(rollIndex);
			addi $a2, $a2, 8 # #rollIndex += 2;
			j endIf # jump to endIf label
 
 		else: # else 
			jal getStandardScore # jump and link to getStandardScore procedure		
 			# return value from getStandardScore stored in $v1 
 			add $s0, $s0, $v1 #score += getStandardScore(rollIndex);
			addi $a2, $a2, 8 #rollIndex += 2;	
			j endIf # jump to endIf label
		 	
		endIf: # end if, else if, else statements
			# back to top of loop if frameindex != 10			
			addi $s1, $s1, 1 # incr frameIndex by 1 (counter for scoreLoop) 
			bne $s1, 10, scoreLoop # loop if counter $s1 not 10				
					
	li $v0,4 # load 4 to $v0 for command print string
	la $a0, finalScoreMessage # load finalScoreMessage in argument register to print
	syscall # print above

	li $v0,1 # load 1 to $v0 for command print integer
	addi $a0, $s0, 0 # put score in argument register to print
	syscall # return final score
	
	j exit # jump to exit label
		
isStrike: # isStrike procedure label
	add $t0, $a1, $a2, # address of rolls array + current rollIndex 
	lw $t1, 0($t0) # load value stored in rolls[rollIndex] 
	bne $t1, 10, elseIf # if value of rolls[rollIndex] != 10
			    # then go to elseIf
	jr $ra # if rolls[rollIndex] == 10
	       # jump return to return address where function was called
	       
isSpare: # isSpare procedure label
	add $t0, $a1, $a2 # address of rolls array + current rollIndex 
	lw $t1, 0($t0) # load value stored in rolls[rollIndex] 
	lw $t2, 4($t0) # load value stored in rolls[rollIndex+1] 
	add $t3, $t2, $t1 #rolls[rollIndex] + rolls[rollIndex+1] 		
	bne $t3, 10, else # if value of rolls[rollIndex] != 10
			    # then go to elseIf		    
	jr $ra # if rolls[rollIndex] + rolls[rollIndex+1] == 10
	       # jump return to return address where function was called
	       
		
getStrikeScore: # getStrikeScore procedure label
	add $t0, $a1, $a2 # address of rolls array + current rollIndex 
	lw $t1,0($t0) # load value at address rolls[rollIndex] 
 	lw $t2,4($t0) # load value at address rolls[rollIndex+1] 	
 	lw $t3,8($t0) # load value at address rolls[rollIndex+2] 
	add $t4, $t2, $t1 # rolls[rollIndex] + rolls[rollIndex+1] 
	add $v1, $t3, $t4 # rolls[rollIndex] + rolls[rollIndex+1] + rolls[rollIndex+2]
			  # store the value in $v1 return register  
	jr $ra # jump return to return address where function was called
	
getSpareScore: # getSpareScore procedure label
	add $t0, $a1, $a2 # address of rolls array + current rollIndex 
	lw $t1,0($t0) # load value at address rolls[rollIndex] 
 	lw $t2,4($t0) # load value at address rolls[rollIndex+1] 	
 	lw $t3,8($t0) # load value at address rolls[rollIndex+2]  
	add $t4, $t2, $t1 # rolls[rollIndex] + rolls[rollIndex+1] 
	add $v1, $t3, $t4 # rolls[rollIndex] + rolls[rollIndex+1] + rolls[rollIndex+2]
			  # store the value in $v1 return register  
	jr $ra # jump return to return address where function was called
	
getStandardScore: # getStandardScore procedure label
	add $t0, $a1, $a2 # address of rolls array + current rollIndex 
	lw $t1,0($t0) # load value at address rolls[rollIndex] 
 	lw $t2,4($t0) # load value at address rolls[rollIndex+1] 	
	add $v1, $t2, $t1 # rolls[rollIndex] + rolls[rollIndex+1] 
			  # store the value in $v1 return register  
	jr $ra # jump return to return address where function was called

exit: # exit label
	li $v0, 10 # load 10 to $v0 to exit
	syscall # call command above


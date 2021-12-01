.data
instructions: .asciiz "Choose your type, X or O: \n"
youchose: .asciiz "\nYou chose: "

choice: .byte 'X' #this will store the choice that player1 has chosen
otherchoice: .byte 'O' #this will store the choice that the cpu is assigned

p2choice1: .asciiz "Player 2 will be: O\n"
p2choice2: .asciiz "Player 2 will be: X\n"
exiting: .asciiz "The Tic Tac Toe program is now exiting"
newline: .asciiz "\n"
border: .asciiz "\n-----------\n"
instructions1: .asciiz "Player 1, choose a row on the board\n"
instructions2: .asciiz "Player 1, choose a column on the board\n"
invalidchoicemsg: .asciiz "That slot is already taken \n"

cpuhaschosen: .asciiz "The CPU has chosen their slot!\n"

checking: .asciiz "Checking row\n"

wonmsg: .asciiz "won won"
notwonmsg: .asciiz "not won won"

#the board, initially marked with numbers so that they can choose where they want
board: .word row1, row2, row3
row1: .word 0, 0, 0
row2: .word 0, 0, 0
row3: .word 0, 0, 0

.text

main:
la $a0, instructions
li $v0, 4
syscall

li $v0, 12
syscall
move $t0,$v0
sb $t0, choice

jal tellchoice

#there are 9 slots in the board, so run that amount of times
jal pchoose
jal cchoose
jal pchoose
jal checkgameover
jal cchoose
jal checkgameover
jal pchoose
jal checkgameover
jal cchoose
jal checkgameover
jal pchoose
jal checkgameover
jal cchoose
jal checkgameover
jal pchoose
jal checkgameover

#jal pchoose
#jal printboard
#jal pchoose
#jal printboard
#jal checkRow1

j exit

#a game is over if a row is filled all the same, a column is all the same, or if a diagnol is all the same
checkgameover:

addi $sp, $sp, -4
sw $ra, 0($sp)

#check rows
jal checkRow1

lw $ra, 0($sp)
addi $sp, $sp, 4

#return
jr $ra

#have the cpu choose a spot on the board
cchoose:

#find the first available slot by checking each row one by one
la $a1, row1

#the index in the row
li $t1, 0

#multiply by 4 to get the proper shift amount based on the index
sll $t3, $t1, 2
#add this onto the address so we know where to get the slot address
add $a1, $a1, $t3

#get the value at that slot
lw $t0, 0($a1)

beqz $t0, select

#move to the next slot in the row
addi $a1, $a1, 4

#get the value at that slot
lw $t0, 0($a1)

beqz $t0, select

#move to the next slot in the row
addi $a1, $a1, 4

#get the value at that slot
lw $t0, 0($a1)

beqz $t0, select

#if it got this far, there is no space in row1. check row 2 now
#get the value at that slot
la $a1, row2
lw $t0, 0($a1)
beqz $t0, select

addi $a1, $a1, 4
lw $t0, 0($a1)
beqz $t0, select

addi $a1, $a1, 4
lw $t0, 0($a1)
beqz $t0, select

la $a1, row3
lw $t0, 0($a1)
beqz $t0, select

addi $a1, $a1, 4
lw $t0, 0($a1)
beqz $t0, select

addi $a1, $a1, 4
lw $t0, 0($a1)
beqz $t0, select

jr $ra

#a1 contains the address of where to set the selection
select:

#get the letter the cpu is playing as
lb $t3, otherchoice
#set it in that place
sw $t3, 0($a1)

la $a0, cpuhaschosen
li $v0, 4
syscall

jr $ra

#have player 1 choose a spot on the board
pchoose:

#TODO push the return address onto the stack
#save the current return address before calling another function
add $t4, $ra, $zero

rechoose:

#show the board choices
jal printboard

#tell them to give us the number of the row and column they want to choose
la $a0, instructions1
li $v0, 4
syscall

#get the input
li $v0, 5
syscall
move $t0,$v0

la $a0, instructions2
li $v0, 4
syscall

#get the input
li $v0, 5
syscall
move $t1,$v0

#t0 holds row, t1 holds column

subi $t0, $t0, 1
#multiply the row numbers by 2 so we can get the number of bytes to shift by
sll $t3, $t0, 2

la $a1, board #load the board address into the register
add $a1, $a1, $t3 #add the shift amount to the board
lw $a2, 0($a1) #load the address of row1

subi $t1, $t1, 1
sll $t3, $t1, 2
add $a2, $a2, $t3

lw $a0, 0($a2) #a2 is the address of the slot, we can keep this in mind for modification after checking

#at this point, a0 contains the contents of the slot targetted.

li $v0, 1 #print the slot contents for debugging
syscall

#check to see if it is taken already
beqz $a0, nextstep

la $a0, invalidchoicemsg
li $v0, 4
syscall

j rechoose

nextstep:

#get the X or O that the player chose at the beginning
lb $t1, choice

#modify the slot
sw $t1, 0($a2)

#return to where this function was called
jr $t4

tellchoice:
la $a0, youchose
li $v0, 4
syscall

#print the character they inputted
lb $a0, choice
li $v0, 11
syscall

#newline
la $a0, newline
li $v0, 4
syscall

#tell them what the other player will be
li $t1, 'X'
beq $t0, $t1, other

#they chose O, so p2 will be X
la $a0, p2choice2
li $v0, 4
syscall

li $t3, 'X'
sb $t3, otherchoice

jr $ra

other:
la $a0, p2choice1
li $v0, 4
syscall

li $t3, 'O'
sb $t3, otherchoice

jr $ra

printslot:

#jump to label if the slot value zero, otherwise print it as a byte
beqz $a0, pnormal
li $v0, 11
syscall

jr $ra

pnormal:
li $v0, 1
syscall

jr $ra

printboard:

addi $sp, $sp, -4
sw $ra, 0($sp)

#try printing the current board state
la $a0, border
li $v0, 4
syscall

li $t0, ' '
move $a0, $t0
li $v0, 11
syscall

la $a1, row1
lw $a0, 0($a1)
jal printslot

li $t0, ' '
move $a0, $t0
li $v0, 11
syscall

li $t0, '|'
move $a0, $t0
li $v0, 11
syscall

li $t0, ' '
move $a0, $t0
li $v0, 11
syscall

lw $a2, 4($a1)
move $a0,$a2
jal printslot

li $t0, ' '
move $a0, $t0
li $v0, 11
syscall

li $t0, '|'
move $a0, $t0
li $v0, 11
syscall

li $t0, ' '
move $a0, $t0
li $v0, 11
syscall

lw $a2, 8($a1)
move $a0,$a2
jal printslot

#row2

li $t0, '\n'
move $a0, $t0
li $v0, 11
syscall

li $t0, ' '
move $a0, $t0
li $v0, 11
syscall

la $a1, row2
lw $a2, 0($a1)
move $a0,$a2
jal printslot

li $t0, ' '
move $a0, $t0
li $v0, 11
syscall

li $t0, '|'
move $a0, $t0
li $v0, 11
syscall

li $t0, ' '
move $a0, $t0
li $v0, 11
syscall

lw $a2, 4($a1)
move $a0,$a2
jal printslot

li $t0, ' '
move $a0, $t0
li $v0, 11
syscall

li $t0, '|'
move $a0, $t0
li $v0, 11
syscall

li $t0, ' '
move $a0, $t0
li $v0, 11
syscall

lw $a2, 8($a1)
move $a0,$a2
jal printslot

#row3

li $t0, '\n'
move $a0, $t0
li $v0, 11
syscall

li $t0, ' '
move $a0, $t0
li $v0, 11
syscall

la $a1, row3
lw $a2, 0($a1)
move $a0,$a2
jal printslot

li $t0, ' '
move $a0, $t0
li $v0, 11
syscall

li $t0, '|'
move $a0, $t0
li $v0, 11
syscall

li $t0, ' '
move $a0, $t0
li $v0, 11
syscall

lw $a2, 4($a1)
move $a0,$a2
jal printslot

li $t0, ' '
move $a0, $t0
li $v0, 11
syscall

li $t0, '|'
move $a0, $t0
li $v0, 11
syscall

li $t0, ' '
move $a0, $t0
li $v0, 11
syscall

lw $a2, 8($a1)
move $a0,$a2
jal printslot

la $a0, border
li $v0, 4
syscall

lw $ra, 0($sp)
addi $sp, $sp, 4

jr $ra

checkRow1:

addi $sp, $sp, -4
sw $ra, 0($sp)

la $a0, checking
li $v0, 4
syscall

#load the address of row1
la $a1, row1

lw $t0, 0($a1)
lw $t1, 4($a1)
lw $t2, 8($a1)

#if the first slot in the row is zero, there is no point in checking
beqz $t0, exitcheckrow1

bne $t0, $t1, exitcheckrow1
beq $t1, $t2, checkwhowon

exitcheckrow1:

lw $ra, 0($sp)
addi $sp, $sp, 4

jr $ra

checkwhowon:

#t0 should contain if the winner is X or O

#if t0 is equal to "choice" from the .data, then player1(human) won
lb $t1, choice

beq $t0, $t1, p1Wins

j p2Wins

la $a0, wonmsg
li $v0, 4
syscall

j exit

p1Wins:

la $a0, wonmsg
li $v0, 4
syscall

j exit

p2Wins:

la $a0, notwonmsg
li $v0, 4
syscall

j exit

exit:
la $a0, exiting
li $v0, 4
syscall

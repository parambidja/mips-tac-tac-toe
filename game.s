	.data				#data segment
board:	.word line1, line2, line3
line1:		.word 0, 0, 0
line2:		.word 0, 0, 0
line3:		.word 0, 0, 0

size:		.word 3
.eqv		DATA_SIZE 4


instructions:	.asciiz "This game of tic-tac-toe follows certain rules:\n"
rule1:	.asciiz "1. For input, players must enter the X-position of a desired move, then a new line (i.e. enter/return), then the Y-position. For example: for the position (0,1) enter 0, hit enter, enter 1\n"
rule2: .asciiz "2. The coordinates are 0-indexed and have the form (row, column). Meaning the top left cell is (0, 0) and bottom right cell is (2, 2). Make sure to only enter #s between 0 - 2 for X and Y.\n"
rule3: .asciiz "3. If the given coordinate is occupied, you will be prompted to re-enter a valid move\n"
rule4: .asciiz "4. In this implementation, 0 represents an empty cell, 1 represents an 'X', and 2 represents an 'O'\n"

newline: .asciiz "\n"
space: .asciiz "  "
player1Input: .asciiz "Player 1, input move: "
player2Input: .asciiz "Player 2, input move: "

player1WinStr: .asciiz "Player 1 wins!!"
player2WinStr: .asciiz "Player 2 wins!!"
tieGameStr: .asciiz "Tie game. No players won!!"

	.align 2
buffer: .space 8		# reserve space for two words
n_in:	.space 4		# get input from the user

	.text			# Code segment
	.globl	main		# declare main to be global

main:
	j play_a_game
	j exit	# in case of error

play_a_game:
	 # print instructions
 	 la $a0, instructions
 	 li $v0, 4
	 syscall

	 la $a0, rule1
	 li $v0, 4
	 syscall

	 la $a0, rule2
	 li $v0, 4
	 syscall

	 la $a0, rule3
	 li $v0, 4
	 syscall

	 la $a0, rule4
	 li $v0, 4
	 syscall

	 # 4 set of moves
	 jal draw_board
	 jal XMove
	 jal draw_board
	 jal YMove

	 jal draw_board
	 jal XMove
	 jal draw_board
	 jal YMove

	 jal draw_board
	 jal XMove
	 jal draw_board
	 jal YMove

	 jal draw_board
	 jal XMove
	 jal draw_board
	 jal YMove

	 # last move
	 jal draw_board
	 jal XMove
	 # if no one has won yet, its a tie
	 jal tieGame

	 j exit

tieGame:

	# draw board
	jal draw_board

	# print player 1 wins
	la $a0, tieGameStr
	li $v0, 4
	syscall

	j exit		# game over

XMove:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	# print command
	la $a0, player1Input
	li $v0, 4
	syscall

	# get input (seperated by new line)
	# system call no. 5, read an integer.
	li	$v0, 5		# prepare a system call. Type 5.
	syscall			# read an int
	move $a1, $v0

	li	$v0, 5		# prepare a system call. Type 5.
	syscall			# read an int
	move $a2, $v0

	jal play_x

	beq $v0, -1, XMove

	lw $ra, 0($sp)
	addi $sp, $sp, 4

	jr $ra

YMove:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	# print command
	la $a0, player2Input
	li $v0, 4
	syscall

	# get input (seperated by new line)
	# system call no. 5, read an integer.
	li	$v0, 5		# prepare a system call. Type 5.
	syscall			# read an int
	move $a1, $v0

	li	$v0, 5		# prepare a system call. Type 5.
	syscall			# read an int
	move $a2, $v0

	jal play_y

	beq $v0, -1, YMove

	lw $ra, 0($sp)
	addi $sp, $sp, 4

	jr $ra


initialize:
	la $v0, board
	jr	$ra

# play_X(g, x, y) - changes g[x][y] = 1, returns 0 on success, -1 on error, and 1 if player 1 wins
play_x:

	addi $sp, $sp, -16	# push args onto stack
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	sw $a2, 12($sp)

	la $t0, board         # put address of list into $t0
	sll $t1, $a1, 2		# t1 = i*4
	add $t1, $t1, $t0	#t1 = (i*4) + rowAddr
	lw $t2, 0($t1)	# t2 = base address of the row

	sll $t1, $a2, 2		# t1 = y*4
	add $s0, $t1, $t2	# s0 = (y*4) + colAddr
	lw $t2, 0($s0)		# t2 now has the item at g[x][y]

	bne $t2, $zero, InvalidMove	# if cell != 0, invalid move
	addi $t3, $zero, 1	# a valid move, so change g[x][y] = 1
	sw $t3, 0($s0)

	# check for winner with win(x,y)
	move $a0, $a1
	move $a1, $a2
	jal win
	beq $v0, 1, player1Win

	addi $v0, $zero, 0	# return 0 to signal valid non-winning move

	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	lw $a2, 12($sp)

	addi $sp, $sp, 16	# pop ra from stack

	jr $ra

player1Win:

	# draw board
	jal draw_board

	# print player 1 wins
	la $a0, player1WinStr
	li $v0, 4
	syscall


	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	lw $a2, 12($sp)

	addi $sp, $sp, 16	# pop ra from stack

	j exit		# game over



# play_y(g, x, y) - changes g[x][y] = 1, returns 0 on success, -1 on error, and 1 if player 1 wins
play_y:

	addi $sp, $sp, -16	# push args onto stack
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	sw $a2, 12($sp)

	la $t0, board         # put address of list into $t0
	sll $t1, $a1, 2		# t1 = i*4
	add $t1, $t1, $t0	#t1 = (i*4) + rowAddr
	lw $t2, 0($t1)	# t2 = base address of the row

	sll $t1, $a2, 2		# t1 = y*4
	add $s0, $t1, $t2	# s0 = (y*4) + colAddr
	lw $t2, 0($s0)		# t2 now has the item at g[x][y]

	bne $t2, $zero, InvalidMove	# if cell != 0, invalid move
	addi $t3, $zero, 2	# a valid move, so change g[x][y] = 2
	sw $t3, 0($s0)

	# check for winner with win(x,y)
	move $a0, $a1
	move $a1, $a2
	jal win
	beq $v0, 1, player2Win

	addi $v0, $zero, 0	# return 0 to signal valid move

	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	lw $a2, 12($sp)

	addi $sp, $sp, 16	# pop ra from stack

	jr $ra


player2Win:

	# draw board
	jal draw_board

	# print player 1 wins
	la $a0, player2WinStr
	li $v0, 4
	syscall


	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	lw $a2, 12($sp)

	addi $sp, $sp, 16	# pop ra from stack

	j exit		# game over

InvalidMove:
	addi $v0, $zero, -1	# return -1 to signal invalid move

	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	lw $a2, 12($sp)

	addi $sp, $sp, 16	# pop ra from stack

	jr $ra

draw_board:
	addi $sp, $sp, -8	# push ra onto stack
	sw $ra, 0($sp)
	sw $a0, 4($sp)

	addi $t1, $zero, 0	# $t1 is i; i = 0
	la $t2, board		# t2 = board

	# print g[0][0]
	lw $t1, 0($t2)
	lw $t3, 0($t1)

	move $a0, $t3
	li $v0, 1
	syscall

	# print space
	la $a0, space
	li $v0, 4
	syscall

	# print g[0][1]
	lw $t3, 4($t1)
	move $a0, $t3
	li $v0, 1
	syscall

	# print space
	la $a0, space
	li $v0, 4
	syscall

	# print g[0][2]
	lw $t3, 8($t1)
	move $a0, $t3
	li $v0, 1
	syscall


	# print new line
	la $a0, newline
	li $v0, 4
	syscall

	# print g[1][0]
	lw $t1, 4($t2)
	lw $t3, 0($t1)

	move $a0, $t3
	li $v0, 1
	syscall

	# print space
	la $a0, space
	li $v0, 4
	syscall

	# print g[1][1]
	lw $t1, 4($t2)
	lw $t3, 4($t1)

	move $a0, $t3
	li $v0, 1
	syscall

	# print space
	la $a0, space
	li $v0, 4
	syscall

	# print g[1][2]
	lw $t1, 4($t2)
	lw $t3, 8($t1)

	move $a0, $t3
	li $v0, 1
	syscall

	# print new line
	la $a0, newline
	li $v0, 4
	syscall

	# print g[2][0]
	lw $t1, 8($t2)
	lw $t3, 0($t1)

	move $a0, $t3
	li $v0, 1
	syscall

	# print space
	la $a0, space
	li $v0, 4
	syscall

	# print g[2][1]
	lw $t3, 4($t1)
	move $a0, $t3
	li $v0, 1
	syscall

	# print space
	la $a0, space
	li $v0, 4
	syscall

	# print g[2][2]
	lw $t3, 8($t1)
	move $a0, $t3
	li $v0, 1
	syscall

	# print new line
	la $a0, newline
	li $v0, 4
	syscall
	# print new line
	la $a0, newline
	li $v0, 4
	syscall

	lw $ra, 0($sp)
	lw $a0, 4($sp)
	addi $sp, $sp, 8	# pop from stack

	jr $ra

# win(x,y) check if a move to (x,y) creates a win
# returns 1 if win is found, 0 otherwise
win:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	jal winRow0
	jal winRow1
	jal winRow2
	jal winCol0
	jal winCol1
	jal winCol2
	jal winDiag0
	jal winDiag1


	addi $v0, $zero, 0	# return 0 - which means no winner
	lw $ra, 0($sp)
	addi $sp, $sp, 4	# pop from stack

	jr $ra



winRow0:
	# g[0][X]

	la $t2, board		# t2 = board
	lw $t1, 0($t2)		# t1 = board[0]
	lw $t3, 0($t1)		# t3 = board[0][0]
	lw $t4, 4($t1)		# t3 = board[0][1]
	lw $t5, 8($t1)		# t3 = board[0][2]

	and $t6, $t3, $t4	# and the cells, if they are the same we should get 1 or 2
	and $t6, $t6, $t5
	bne $t6, $zero, winReturn	# if winner found, return 1

	addi $v0, $zero, 0	# return 0 - no winner in this row

	jr $ra

winRow1:
	# g[1][X]

	la $t2, board		# t2 = board
	lw $t1, 4($t2)		# t1 = board[1]
	lw $t3, 0($t1)		# t3 = board[1][0]
	lw $t4, 4($t1)		# t3 = board[1][1]
	lw $t5, 8($t1)		# t3 = board[1][2]

	and $t6, $t3, $t4	# and the cells, if they are the same we should get 1 or 2
	and $t6, $t6, $t5
	bne $t6, $zero, winReturn	# if winner found, return 1

	addi $v0, $zero, 0	# return 0 - no winner in this row

	jr $ra

winRow2:
	# g[2][X]

	la $t2, board		# t2 = board
	lw $t1, 8($t2)		# t1 = board[2]
	lw $t3, 0($t1)		# t3 = board[2][0]
	lw $t4, 4($t1)		# t3 = board[2][1]
	lw $t5, 8($t1)		# t3 = board[2][2]

	and $t6, $t3, $t4	# and the cells, if they are the same we should get 1 or 2
	and $t6, $t6, $t5
	bne $t6, $zero, winReturn	# if winner found, return 1

	addi $v0, $zero, 0	# return 0 - no winner in this row

	jr $ra

winCol0:
	# g[X][0]

	la $t2, board		# t2 = board
	lw $t1, 0($t2)		# t1 = board[0]
	lw $t3, 0($t1)		# t3 = board[0][0]

	lw $t1, 4($t2)		# t1 = board[1]
	lw $t4, 0($t1)		# t3 = board[1][0]

	lw $t1, 8($t2)		# t1 = board[2]
	lw $t5, 0($t1)		# t3 = board[2][0]

	and $t6, $t3, $t4	# and the cells, if they are the same we should get 1 or 2
	and $t6, $t6, $t5
	bne $t6, $zero, winReturn	# if winner found, return 1

	addi $v0, $zero, 0	# return 0 - no winner in this row

	jr $ra

winCol1:
	# g[X][1]

	la $t2, board		# t2 = board
	lw $t1, 0($t2)		# t1 = board[0]
	lw $t3, 4($t1)		# t3 = board[0][1]

	lw $t1, 4($t2)		# t1 = board[1]
	lw $t4, 4($t1)		# t3 = board[1][1]

	lw $t1, 8($t2)		# t1 = board[2]
	lw $t5, 4($t1)		# t3 = board[2][1]

	and $t6, $t3, $t4	# and the cells, if they are the same we should get 1 or 2
	and $t6, $t6, $t5
	bne $t6, $zero, winReturn	# if winner found, return 1

	addi $v0, $zero, 0	# return 0 - no winner in this row

	jr $ra

winCol2:
	# g[X][2]

	la $t2, board		# t2 = board
	lw $t1, 0($t2)		# t1 = board[0]
	lw $t3, 8($t1)		# t3 = board[0][2]

	lw $t1, 4($t2)		# t1 = board[1]
	lw $t4, 8($t1)		# t3 = board[1][2]

	lw $t1, 8($t2)		# t1 = board[2]
	lw $t5, 8($t1)		# t3 = board[2][2]

	and $t6, $t3, $t4	# and the cells, if they are the same we should get 1 or 2
	and $t6, $t6, $t5
	bne $t6, $zero, winReturn	# if winner found, return 1

	addi $v0, $zero, 0	# return 0 - no winner in this row

	jr $ra

winDiag0:


	la $t2, board		# t2 = board
	lw $t1, 0($t2)		# t1 = board[0]
	lw $t3, 0($t1)		# t3 = board[0][0]

	lw $t1, 4($t2)		# t1 = board[1]
	lw $t4, 4($t1)		# t3 = board[1][1]

	lw $t1, 8($t2)		# t1 = board[2]
	lw $t5, 8($t1)		# t3 = board[2][2]

	and $t6, $t3, $t4	# and the cells, if they are the same we should get 1 or 2
	and $t6, $t6, $t5
	bne $t6, $zero, winReturn	# if winner found, return 1

	addi $v0, $zero, 0	# return 0 - no winner in this row

	jr $ra

winDiag1:


	la $t2, board		# t2 = board
	lw $t1, 0($t2)		# t1 = board[0]
	lw $t3, 8($t1)		# t3 = board[0][2]

	lw $t1, 4($t2)		# t1 = board[1]
	lw $t4, 4($t1)		# t3 = board[1][1]

	lw $t1, 8($t2)		# t1 = board[2]
	lw $t5, 0($t1)		# t3 = board[2][0]

	and $t6, $t3, $t4	# and the cells, if they are the same we should get 1 or 2
	and $t6, $t6, $t5
	bne $t6, $zero, winReturn	# if winner found, return 1

	addi $v0, $zero, 0	# return 0 - no winner in this row

	jr $ra

winReturn:
	addi $v0, $zero, 1	# return 1
	lw $ra, 0($sp)
	addi $sp, $sp, 4	# pop from stack

	jr $ra
exit:
	li $v0, 10
	syscall

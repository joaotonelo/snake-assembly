.globl play_sound  
play_sound:
	#### CONSTROI PILHA ####
	addi $sp, $sp, -32
	sw $a0, 0($sp)
	sw $a1, 4($sp)
	sw $a2, 8($sp)
	sw $ra, 28($sp)
	#########################
	
	li	$v0, 33
	li	$a0, 66
	li	$a1, 50
	li	$a2, 0
	li	$a3, 100
	syscall
	
	lw	 $a0, 0($sp)
	lw	 $a1, 4($sp)
	lw	 $a2, 8($sp)
	lw 	 $ra, 28($sp)
	addi $sp, $sp, 32
	jr   $ra

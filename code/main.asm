#	Projeto Final Microprocessadores - 2019/2
#
#	Guilherme Camargo Valese
#	João Pedro Tonelo
#	Nicolas de Abreu Coelho

#.include "keyboard.asm"

.text
init:
	li $sp, 0x7fffeffc
	jal main
	li      $v0, 10	
	syscall


main:
	jal 	enable_keyboard_int
	

	#ori	$t1, $0, 0
loop:
	#addi	$t1, $t1, 1
	b	loop

	
	

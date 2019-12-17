#################################################
#	Projeto Final Microprocessadores - 2019/2	#
#				Snake game						#
#												#
#	Guilherme Camargo Valese					#
#	Joao Pedro Tonelo							#
#	Nycolas	de Abreu Coelho						#
#################################################

.include "graphics.inc"
.include "macros.asm"

.eqv	SNAKE_SPRITE_ID			26

.data
intro_msg:			.asciiz	"SNAKE GAME\n\n"
end_msg:			.asciiz	"Jogo finalizado. Pontuacao "
keyboard_init_msg:	.asciiz "keyboard... "
grid_init_msg:		.asciiz "grid....... "
fruit_spawn_msg:	.asciiz "fruit...... "
ok_msg:				.asciiz "OK!\n"
new_fruit_msg:		.asciiz "new fruit\n"		# <! Debug
check_fruit_y_msg:	.asciiz "fruit y\n"			# <! Debug

buffer(0, 0, moveSnake)
sprites(20, 20, 0, 1, 3, 0, snake)

pontuacao:			.word 0

.text
.globl main
main:
	print_string	intro_msg

	# INICIALIZACOES
	print_string	keyboard_init_msg
	jal enable_keyboard_int		# habilita teclado
	print_string	ok_msg

	print_string	grid_init_msg
    li $a0, GRID_COLS
    li $a1, GRID_ROWS
    la $a2, grid_hard			# mapa desenhado (grid_easy/grid_hard)
    jal draw_grid
	print_string	ok_msg
	
	la	$s0, snake	
_main_loop:
	delay 50				# delay em ms (impacta na velocidade do jogo)
	la	$s1, moveSnake
	la	$a2, grid_hard
	
	lw	$s2, 0($s1)				# carrega em $s2 o mov_x
	lw	$s3, 4($s1)				# carrega em $s3 o mov_y
	lw	$a0, 0($s0)				# obtem a posicao 'x' da cobra
	lw	$a1, 4($s0)				# obtem a posicao 'y' da cobra
	
	div $t3, $t1, 7				# divide a coordenada x por 7
	mfhi	$t4
	div	$t5, $t2, 7				# divide a coordenada y por 7
	mfhi	$t6
	
	add	$a0, $s2, $t3			# atualiza a coordenada x
	add	$a1, $s3, $t5			# atualiza a coordenada y
	
	sw	$s2, 8($s0)
	sw	$s3, 12($s0)
	
	#jal check_fruit				# confere se atingiu a fruta
	#beq $v0, 1, draw_fruit		# desenha em nova posicao

	lw	$t0, 8($s0)
	lw	$t7, 12($s0)
	
	lw	$t1, 0($s0)				# carrega em $t1 a coordenada x
	lw	$t2, 4($s0)				# carrega em $t2 a coordenada y
	div $t3, $t1, 7				# divide a coordenada x por 7
	mfhi	$t4
	div	$t5, $t2, 7				# divide a coordenada y por 7
	mfhi	$t6

	add	$a0, $t0, $t3			# atualiza a coordenada x	
	add	$a1, $t7, $t5			# atualiza a coordenada y
	
	jal collision_check			# checa se colidiu em algo
	beq	$v0, 1, end_game		# encerra o jogo	
	
	#j update_snake_position
	#bnez	$t4, move_snake_end
	#bnez	$t6, move_snake_end
	
update_snake_position:
	add	$a0, $t0, $t1
	sw	$a0, 0($s0)				# salva a nova coordenada
	add $a1, $t2, $t7
	sw	$a1, 4($s0)				# salva a nova coordenada
	
	li	$a2, SNAKE_SPRITE_ID	# <-- PROBLEMA NESTA PARTE
	jal draw_sprite

move_snake_end:
	j _main_loop
	
	
# draw_grid(width, height, grid_table)
# $a0 -> largura
# $a1 -> altura
# $a2 -> endereco para a tabela
.globl draw_grid
draw_grid:
	cria_pilha	$a1, $a2, $s0, $s1, $s2, $s3, $s4

	li $s0, 0		# i
	move $s2, $a0	# largura
	move $s3, $a1	# altura
	move $s4, $a2	# endereco do grid

draw_grid_altura:
	bge $s0, $s3, draw_grid_altura_end
	li $s1, 0

draw_grid_largura:
	bge $s1, $s2, draw_grid_largura_end
	lb $a2, 0($s4)
	addi $a2, $a2, -64
	add $a0, $s1, $0
	mul $a0, $a0, 7
	add $a1, $s0, $0
	mul $a1, $a1, 7
	jal draw_sprite
	addi $s4, $s4, 1
	addi $s1, $s1, 1
	b draw_grid_largura

draw_grid_largura_end:
	addi $s0, $s0, 1
	b draw_grid_altura

# desfaz a pilha e retorna
draw_grid_altura_end:
	desfaz_pilha $s0, $s1, $s2, $s3, $s4


# draw_sprite(X, Y, sprite_id)
# $a0 -> X
# $a1 -> Y
# $a2 -> sprite_id
draw_sprite:
	cria_pilha	$s0, $s1, $s2, $s3
	move $s2, $a0
	move $s3, $a1
	la $s0, sprites					# carrega endereco base dos sprites

	mul $t0, $a2, SPRITE_SIZE  		# $t0 -> (indice*sprit_size)
	add $s0, $t0, $s0  				# acessa o endereco do sprite especifico
	li $t1, 0 						# i = 0 (usado para controle dos sprites)
	la $s1, colors

draw:
	bge $t1, SPRITE_SIZE, draw_end	# if(i >= SPRITE_SIZE) draw_end;

	# controle das cores
	lbu $t2, 0($s0)
	sll $t2, $t2, 2
	add $t2, $t2, $s1
	lw $a2, 0($t2)

	div $t3, $t1, X_SCALE
	mfhi $t4
	add $a0, $s2, $t4
	add $a1, $s3, $t3

	jal set_pixel

	addi $t1, $t1, 1 		# i++;
	addi $s0, $s0, 1		# proximo sprite...

	b draw

draw_end:
	desfaz_pilha $s0, $s1, $s2, $s3


# set_pixel(X, Y, color)
# $a0 -> x
# $a1 -> y
# $a2 -> color
draw_fruit:
	cria_pilha	$a0, $a1, $a2
	new_fruit_sound
	li $v0, 42
	li $a1, 300
	syscall
	#increment the X position so it doesnt draw on a border
	addiu $a0, $a0, 7
	sw $a0, fruitPositionX
	syscall
	#increment the Y position so it doesnt draw on a border
	addiu $a0, $a0, 7
	sw $a0, fruitPositionY
	lw 	$a0, fruitPositionX
	div $a0, $a0, 7
	mfhi $t0
	lw 	$a1, fruitPositionY
	div $a1, $a1, 7
	mfhi $t1
	li 	$a2, 3
	
	#beq $t0, $t1, draw_fruit_end
	jal draw_sprite
	
draw_fruit_end:
	desfaz_pilha $a0, $a1, $a2

set_pixel:
   la  $t0, FB_PTR			# endereco do display
   mul $a1, $a1, FB_XRES	# y * 256
   add $a0, $a0, $a1		# x + (y * 256)
   sll $a0, $a0, 2			# multiplica por 4
   add $a0, $a0, $t0		# posicao de escrita no display
   sw  $a2, 0($a0)			# joga a cor para o endereco
   jr  $ra					# retorna


end_game:
	li $v0, 31
	li $a0, 28
	li $a1, 250
	li $a2, 32
	li $a3, 127
	syscall
		
	li $a0, 33
	li $a1, 250
	li $a2, 32
	li $a3, 127
	syscall
	
	li $a0, 47
	li $a1, 1000
	li $a2, 32
	li $a3, 127
	syscall

	li $v0, 56
	la $a0, end_msg
	lw $a1, pontuacao
	syscall

	exit
	
collision_check:
	cria_pilha $s0, $s1, $s2, $s3
	mul $s0, $a1, 36       
	add $s1, $a0, $s0   
	add $s1, $s1, $a2 			
	lb $s0, 0($s1) 
	addi $s0, $s0, -64 				
	move $v0, $zero 			

	bge $s0, 5, collision						# parede
	beq $s0, 3,  incrementa_pontuacao			# fruta rosa
	beq $s0, 0,  incrementa_pontuacao_amarela	# fruta amarela
	
	j	collision_check_end

collision:
  	jal end_game
  	
collision_check_end:
	desfaz_pilha $s0, $s1, $s2, $s3


# Check fruit
#	$v0 = 1 -> Colidiu com a fruta
check_fruit:
	lw 	$t0, fruitPositionX
	lw 	$t1, fruitPositionY
	lw	$a0, 0($s0)				# obtem a posicao 'x' da cobra
	lw	$a1, 4($s0)				# obtem a posicao 'y' da cobra
	move $v0, $zero
	
	sub	$t0, $t0, $a0
	ble	$t0, 2, check_fruit_x
	beq	$a0, $t0, check_fruit_x
	j	check_fruit_end
check_fruit_x:
	beq	$a1, $t1, check_fruit_y
	j	check_fruit_end
check_fruit_y:
	lw	$t3, pontuacao
	add $t3, $t3, 10
	sw	$t3, pontuacao
	li 	$v0, 1
check_fruit_end:
	jr	$ra

incrementa_pontuacao:
	sw $ra, 0($s7)
	li	$t0, 10
	lw	$t1, pontuacao
	add $t1, $t1, $t0
	sw  $t1, pontuacao
	lw $ra, 0($s7)
    jr $ra
	
incrementa_pontuacao_amarela:
	sw $ra, 0($s7)
	li	$t0, 20
	lw	$t1, pontuacao
	add $t1, $t1, $t0
	sw  $t1, pontuacao
    lw $ra, 0($s7)
    jr $ra



# Global Interrupt Handle Routines
enable_int:
    mfc0	$t0, $12	 		# record interrupt state
	ori		$t0, $t0, 0x0001 	# set int enable flag
	mtc0    $t0, $12	 		# Turn interrupts on.
	jr      $ra
	
disable_int:
	mfc0	$t0, $12	 		# record interrupt state
	andi	$t0, $t0, 0xFFFE 	# clear int enable flag
	mtc0    $t0, $12         	# Turn interrupts off.
	jr      $ra
	
# RX Interrupts Enable (Keyboard)
.globl enable_keyboard_int
enable_keyboard_int:
	addi 	$sp, $sp, -8
	sw   	$ra, 0($sp)
	jal  disable_int
	lui  	$t0,0xffff
	lw   	$t1,0($t0)      	# read rcv ctrl
	ori  	$t1,$t1,0x0002  	# set the input interupt enable
	sw   	$t1,0($t0)	     	# update rcv ctrl
	jal  enable_int
	
	lw   	$ra, 0($sp)
	addi 	$sp, $sp, 8
	jr		$ra

.ktext 0x80000180
interupt:
	addiu	$sp,$sp,-16
	sw		$at,12($sp)
	sw		$t2,8($sp)
	sw		$t1,4($sp)
	sw		$t0,0($sp)

	lui     $t0,0xffff     		# get address of control regs
	lw		$t1,0($t0)     		# read rcv ctrl
	andi	$t1,$t1,0x0001 		# extract ready bit
	beq     $t1,$0,intDone 		#
	lw      $t1,4($t0)     		# read key
	lw      $t2,8($t0)     		# read tx ctrl
	andi	$t2,$t2,0x0001 		# extract ready bit
	beq     $t2,$0,intDone 		# still busy discard
	sw      $t1, 0xc($t0)  		# write key
	
	# controle dos movimentos
	beq		$t1, 119, set_move_up
	beq		$t1, 115, set_move_down
	beq		$t1, 97,  set_move_left
	beq		$t1, 100, set_move_right
	beq		$t1, 32,  pause_game

###################################################
#   	  	CONTROLE DOS MOVIMENTOS
# altera o incremento das coordenadas
# seleciona o sprite
# x = (x + x_pos) x_pos (-1 esquerda, 1 direita)
# y = (y + y_pos) y_pos (-1 cima, 1 baixo)
###################################################
.globl set_move_down
set_move_down:
	li	 $t8, 0
	li   $t9, 1
  	sw	 $t8, 0($s1)
  	sw	 $t9, 4($s1)
	j	 intDone

set_move_up:
	li	 $t8, 0
	li   $t9, -1
  	sw	 $t8, 0($s1)
  	sw	 $t9, 4($s1)
	j intDone

set_move_left:
	li   $t8, -1
	li	 $t9, 0
	sw	 $t8, 0($s1)
  	sw	 $t9, 4($s1)
	j intDone

set_move_right:
	li   $t8, 1
	li	 $t9, 0
	sw	 $t8, 0($s1)
  	sw	 $t9, 4($s1)
	j intDone

pause_game:
	li	$v0, 32
	syscall
	jr	$ra
	
intDone:
	## Clear Cause register
	mfc0	$t0,$13				# get Cause register, then clear it
	mtc0	$0, $13

	## restore registers
	lw	$t0,0($sp)
	lw	$t1,4($sp)
	lw	$t2,8($sp)
	lw 	$at,12($sp)
	addiu	$sp,$sp,16
	eret						# rtn from int and reenable ints


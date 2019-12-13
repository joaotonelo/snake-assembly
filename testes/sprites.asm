#	Projeto Final Microprocessadores - 2019/2
#
#
.include "graphics.inc"

.text
.globl main
main:
	# INICIALIZACOES
	jal enable_keyboard_int		# habilita teclado

	# CHAMA DRAW GRID
    li $a0, GRID_COLS
    li $a1, GRID_ROWS
    la $a2, grid_easy			# mapa desenhado (grid_easy/grid_hard)
    jal draw_grid

	#jal draw_snake
	# TESTE DRAW SPRITE
    li  $t6, 20					# posicao x inicial
    li	$t7, 20					# posicao y inicial
    li	$t8, 0					# incremento de x
    li	$t9, 0					# incremento de y
    #jal set_move_right			# inicia o jogo com a cobra se movendo para direita
    jal draw_fruit			# insere o primeiro elemento no mapa

main2:									# aqui esta o loop principal do jogo

		jal check_wall_colision

		move $a0, $t6
		move $a1, $t7
		move $a2, $s7
   	jal  draw_sprite

 		add $t6, $t6, $t8			# coordenada x atualizada
   	add $t7, $t7, $t9			# coordenada y atualizada

	# incluir teste de colisao
	# incluir geracao das frutas

    li $v0, 32
    li $a0, 100					# delay em ms
    syscall


    b main2

# draw_grid(width, height, grid_table)
# $a0 -> largura
# $a1 -> altura
# $a2 -> endere�o para a tabela
.globl draw_grid
draw_grid:
		addi $sp, $sp, -40
		sw $a0, 0($sp)
    sw $a1, 4($sp)
    sw $a2, 8($sp)
    sw $s0, 12($sp)
    sw $s1, 16($sp)
    sw $s2, 20($sp)
    sw $s3, 24($sp)
    sw $s4, 28($sp)
    sw $ra, 36($sp)

		li $s0, 0		# i
		move $s2, $a0	# largura
		move $s3, $a1	# altura
		move $s4, $a2	# endere�o do grid

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
    lw $s0, 12($sp)
    lw $s1, 16($sp)
    lw $s2, 20($sp)
    lw $s3, 24($sp)
    lw $s4, 28($sp)
    lw $ra, 36($sp)
		addi $sp, $sp, 40
		jr $ra


# draw_sprite(X, Y, sprite_id)
# $a0 -> X
# $a1 -> Y
# $a2 -> sprite_id
.globl draw_sprite
draw_sprite:
	#### CONSTROI PILHA ####
	addi $sp, $sp, -32
	sw $s0, 12($sp)
	sw $s1, 16($sp)
	sw $s2, 20($sp)
	sw $s3, 24($sp)
	sw $ra, 28($sp)
	#########################

	move $s2, $a0
	move $s3, $a1
	la $s0, sprites					# carrega endere�o base dos sprites

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

# desfaz a pilha e retorna...
draw_end:
	lw $s0, 12($sp)
	lw $s1, 16($sp)
	lw $s2, 20($sp)
	lw $s3, 24($sp)
	lw $ra, 28($sp)
	addi $sp, $sp, 32
	jr   $ra



# set_pixel(X, Y, color)
# $a0 -> x
# $a1 -> y
# $a2 -> color
.globl set_pixel
set_pixel:
   la  $t0, FB_PTR			# endereco do display
   mul $a1, $a1, FB_XRES	# y * 256
   add $a0, $a0, $a1		# x + (y * 256)
   sll $a0, $a0, 2			# multiplica por 4
   add $a0, $a0, $t0		# posicao de escrita no display
   sw  $a2, 0($a0)			# joga a cor para o endereco
   jr  $ra					# retorna


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
	addi $t9, $t9, 1
  li   $s7, 29
	jr 	 $ra

set_move_up:
	li	 $t8, 0
	addi $t9, $t9, -1
  li   $s7, 29		 # <-- CORRIGIR ESTA PARTE!!!
	jr	 $ra

set_move_left:
	addi $t8, $t8, -1
	li	 $t9, 0
	li   $s7, 25
	jr	 $ra

set_move_right:
	addi $t8, $t8, 1
	li	 $t9, 0
	li   $s7, 25		# <-- CORRIGIR SPRITE!!!
	jr	 $ra


#######################################################
#				TESTE DE COLISOES
# Encerra o jogo se a cobra colidir com algo
# CORRIGIR COORDENADAS DA PAREDE
#######################################################
check_wall_colision:
	beq	$t6, 240, end_game
	beq $t6, 2,   end_game
	beq $t7, 2,   end_game
	beq $t7, 240, end_game
	jr	$ra



# insere elementos em posicoes aleatorias do mapa
draw_fruit:
	li $v0, 42
	li $a1, 62
	syscall

	#increment the X position so it doesnt draw on a border
	addiu $a0, $a0, 7
	sw $a0, fruitPositionX
	syscall

	#increment the Y position so it doesnt draw on a border
	addiu $a0, $a0, 7
	sw $a0, fruitPositionY

	lw 	$a0, fruitPositionX
	lw 	$a1, fruitPositionY
	li 	$a2, 3
	jal draw_sprite

	jr	$ra

end_game:
######################################################
# Fill Screen to Black, for reset
######################################################
	lw $a0, FB_YRES
	lw $a1, BLACK
	mul $a2, $a0, $a0 								#total number of pixels on screen
	mul $a2, $a2, 4 									#align addresses
	add $a2, $a2, FB_PTR
	add $a0, FB_PTR, $zero 						#loop counter
FillLoop:
	beq $a0, $a2, exit
	sw $a1, 0($a0) 										#store color
	addiu $a0, $a0, 4 								#increment counter
	j FillLoop

exit:
	li 	$v0, 10
	syscall

#	Projeto Final Microprocessadores - 2019/2
#
#
.include "graphics.inc"

.text
.globl main
main:	
	# INICIALIZACOES
	jal enable_keyboard_int		# habilita teclado
	li $t0, 31
	sw $t0, snakeHeadX
	sw $t0, snakeHeadY
	sw $t0, snakeTailX
	li $t0, 37
	sw $t0, snakeTailY
	li $t0, 119
	sw $t0, direction
	sw $t0, tailDirection
	li $t0, 10
	sw $t0, scoreGain
	li $t0, 200
	sw $t0, gameSpeed
	sw $zero, arrayPosition
	sw $zero, locationInArray
	sw $zero, scoreArrayPosition
	sw $zero, score

	# CHAMA DRAW GRID
    li $a0, GRID_COLS
    li $a1, GRID_ROWS
    la $a2, grid_easy			# mapa desenhado (grid_easy/grid_hard)
    jal draw_grid
    
    jal draw_fruit				# insere o primeiro elemento no mapa
    
    li  $t6, 20					# posicao x inicial
    li	$t7, 20					# posicao y inicial
    li	$t8, 0					# incremento de x
    li	$t9, 0					# incremento de y
    
    jal	snake_move_down
   # jal initial_move_direction	# inicia o jogo com a cobra se movendo para direita

main2:							# aqui esta o loop principal do jogo

	jal check_wall_colision
	
	jal check_fruit
	
	move $a0, $t6
	move $a1, $t7
	move $a2, $s7
   	jal  draw_sprite

 	add $t6, $t6, $t8			# coordenada x atualizada
   	add $t7, $t7, $t9			# coordenada y atualizada

	#jal snake_move_down
	# incluir teste de colisao
	# incluir geracao das frutas

    li $v0, 32
    li $a0, 50					# delay em ms
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



check_fruit:
	addi $sp, $sp, -32
#	sw	$a0, 0($sp)
#	sw	$s1, 4($sp)
#	sw	$s2, 8($sp)
	sw $ra, 28($sp)
	lw	$s0, fruitPositionX
	lw	$s1, fruitPositionY
	
	beq	$t6, $s0, check_fruit_y
	j check_fruit_end
	
check_fruit_y:
	#bne	$t7, $s1, check_fruit_end
	jal	play_sound
	jal draw_fruit				# desenha em nova posicao
	# INCLUIR AUMENTO NO COMPRIMENTO
	j check_fruit_end

	
check_fruit_end:
	lw 	 $ra, 28($sp)
	addi $sp, $sp, 32
	jr   $ra
	jr	$ra
	
# insere elementos em posicoes aleatorias do mapa
draw_fruit:
	addi $sp, $sp, -32
	sw $ra, 28($sp)
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
	
	lw 	 $ra, 28($sp)
	addi $sp, $sp, 32
	jr   $ra

# Confirma saida do jogo
end_game:
	jal play_sound
	j exit
	
exit:
	li 	$v0, 10
	syscall


snake_move_down:
	#### CONSTROI PILHA ####
	addi $sp, $sp, -32
	sw $ra, 28($sp)
	#########################
	lw $a0, snakeHeadX
	lw $a1, snakeHeadY
	
	#draw head in new position, move Y position up
	lw $t0, snakeHeadX
	lw $t1, snakeHeadY
	addiu $t1, $t1, 1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	li	$a2, 25
	jal draw_sprite

	sw  $t1, snakeHeadY
	#j UpdateTailPosition #head updated, update tail
	
	#erase behind the snake
	lw $t0, snakeTailX
	lw $t1, snakeTailY
	addiu $t1, $t1, -1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	li $a2, 25
	jal		draw_sprite					# jump to draw_sprite and save position to $ra
	
	j		UpdateTailPosition			# jump to UpdateTailPosition
	
	
	lw 	 $ra, 28($sp)
	addi $sp, $sp, 32
	jr   $ra

UpdateTailPosition:	
	lw $t2, tailDirection
	#branch based on which direction tail is moving
	beq  $t2, 119, MoveTailUp
	beq  $t2, 115, MoveTailDown
	#beq  $t2, 97, MoveTailLeft
	#beq  $t2, 100, MoveTailRight

MoveTailUp:
	#get the screen coordinates of the next direction change
	lw $t8, locationInArray
	la $t0, directionChangeAddressArray #get direction change coordinate
	add $t0, $t0, $t8
	lw $t9, 0($t0)
	lw $a0, snakeTailX  #get snake tail position
	lw $a1, snakeTailY
	#if the index is out of bounds, set back to zero
	beq $s1, 1, IncreaseLengthUp #branch if length should be increased
	addiu $a1, $a1, -1 #change tail position if no length change
	sw $a1, snakeTailY
	
IncreaseLengthUp:
	li $s1, 0 #set flag back to false
	bne $t9, $a0, DrawTailUp #change direction if needed
	la $t3, newDirectionChangeArray  #update direction
	add $t3, $t3, $t8
	lw $t9, 0($t3)
	sw $t9, tailDirection
	addiu $t8,$t8,4
	#if the index is out of bounds, set back to zero
	bne $t8, 396, StoreLocationUp
	li $t8, 0
StoreLocationUp:
	sw $t8, locationInArray 
DrawTailUp:
	jal		draw_sprite				# jump to draw_sprite and save position to $ra
	
	#erase behind the snake
	lw $t0, snakeTailX
	lw $t1, snakeTailY
	addiu $t1, $t1, 1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	add $a2, $zero, 25				# selecao do sprite
	jal		draw_sprite				# jump to draw_sprite and save position to $ra
	j		draw_fruit				# jump to draw_fruit

MoveTailDown:
	#get the screen coordinates of the next direction change
	lw $t8, locationInArray
	la $t0, directionChangeAddressArray #get direction change coordinate
	add $t0, $t0, $t8
	lw $t9, 0($t0)
	lw $a0, snakeTailX  #get snake tail position
	lw $a1, snakeTailY
	beq $s1, 1, IncreaseLengthDown #branch if length should be increased
	addiu $a1, $a1, 1 #change tail position if no length change
	sw $a1, snakeTailY

IncreaseLengthDown:
	li $s1, 0 #set flag back to false
	bne $t9, $a0, DrawTailDown #change direction if needed
	la $t3, newDirectionChangeArray  #update direction
	add $t3, $t3, $t8
	lw $t9, 0($t3)
	sw $t9, tailDirection
	addiu $t8,$t8,4
	#if the index is out of bounds, set back to zero
	bne $t8, 396, StoreLocationDown
	li $t8, 0
StoreLocationDown:
	sw $t8, locationInArray  
DrawTailDown:	
	li	$a2, 25
	jal		draw_sprite				# jump to draw_sprite and save position to $ra
		
	#erase behind the snake
	lw $t0, snakeTailX
	lw $t1, snakeTailY
	addiu $t1, $t1, -1
	add $a0, $t0, $zero				# x
	add $a1, $t1, $zero				# y
	add	$a2, $zero, 25
	jal		draw_sprite				# jump to draw_sprite and save position to $ra
	j		draw_fruit				# jump to draw_fruit
	

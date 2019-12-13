#	Projeto Final Microprocessadores - 2019/2
#
#
.include "graphics.inc"

.text
.globl main
main:
	# CHAMA DRAW GRID
    li $a0, GRID_COLS
    li $a1, GRID_ROWS
    la $a2, grid_easy
    jal draw_grid    

	# TESTE DRAW SPRITE
    #li   $t8,20
    #li   $t9,20
    main2:
    #move $a0,$t8
    #move $a1,$t9
    #li   $a2,32
    #jal  draw_sprite
    #addi $t8, $t8, 1
	
	jal move_up
	
	## DELAY(50)
    li $v0, 32
    li $a0, 50
    syscall
	
	##=========
    b main2
    
# draw_grid(width, height, grid_table)
# $a0 -> largura
# $a1 -> altura
# $a2 -> endereço para a tabela
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
	move $s4, $a2	# endereço do grid

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
	la $s0, sprites					# carrega endereço base dos sprites
	
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


.globl move_up
move_up:
	lw $t0, snakeHeadX
	lw $t1, snakeHeadY
	addiu $t1, $t1, -1		# movimentar para cima, subtraimos 1 da coordenada Y
	move $a0, $t0
	move $a1, $t1
	li   $a2, 28
	jal draw_sprite
	sw	$t1, snakeHeadY
	jr $ra

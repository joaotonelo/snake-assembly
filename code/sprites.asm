.include "graphics.inc"

.text
.globl main
main:
	# CHAMA DRAW GRID
    li $a0, 36
    li $a1, 36
    la $a2, grid_easy
    jal draw_grid    
    
    #hlt: b hlt

	# TESTE DRAW SPRITE
    li   $t8,0
    li   $t9,0
    main2:
    move $a0,$t8
    move $a1,$t9
    li   $a2,14
    jal  draw_sprite
    addi $t8, $t8, 1
	
	## DELAY(50)
    li $v0, 32
    li $a0, 50
    syscall
	
	##=========
    b main2
    
    
# draw_grid(width, height, grid_table)
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
	
	li $s0, 0	# i
	move $s2, $a0	# largura
	move $s3, $a1	# altura
	move $s4, $a2	# grid

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
# $a0 -> x
# $a1 -> y
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
	la $s0, sprites		# carrega endereço base dos sprites
	
	mul $t0, $a2, 49  	# $t0 -> (indice*sprit_size)
	add $s0, $t0, $s0  	# acessa o endereço do sprite específico
	li $t1, 0 		# 'i' 
	la $s1, colors 		
	
draw:	
	bge $t1, SPRITE_SIZE, draw_end	# if(i >= SPRITE_SIZE) draw_end;
	
	##### CORES #####
	lbu $t2, 0($s0) 		#pega o valor correspondente ao �ndice da tabela de cores
	sll $t2, $t2, 2 		#multiplica por 4 pq a tabela de cores � um vetor de word
	add $t2, $t2, $s1 	
	lw $a2, 0($t2) 			
	#################
	
	jal set_pixel
	
	addi $t1, $t1, 1 		# i++;
	addi $s0, $s0, 1		# proximo sprite
	
	b draw				# executa novamente...
	
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
   la  $t0, FB_PTR			# endereço do display
   mul $a1, $a1, FB_XRES		# y * 256
   add $a0, $a0, $a1			# x + (y * 256)
   sll $a0, $a0, 2			# multiplica por 4
   add $a0, $a0, $t0			# posição de escrita no display
   sw  $a2, 0($a0)			# joga a cor para o endereço
   jr  $ra				# retorna

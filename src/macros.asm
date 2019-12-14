# MAV120
# Mathew Varughese
#
# Modified by Guilherme Camargo

.macro sprites(%pos_x, %pos_y, %mov_x, %mov_y, %id, %struct)
%struct:
.align	2			# 2 -> word
	.word	%pos_x
	.word	%pos_y
	.word	%mov_x
	.word	%mov_y
	.word	%id
.end_macro

.macro	buffer(%mov_x, %mov_y, %struct)
%struct:
.align	2			# 2 -> word
	.word	%mov_x
	.word	%mov_y
.end_macro


# print an int to the console from a register.
# smashes a0 and v0
.macro print_int %reg
	move $a0, %reg
	li $v0, 1
	syscall
.end_macro

# print a string to the console. give it a label to an .asciiz thing in the .data segment
# smashes a0 and v0
.macro print_string %str
	la $a0, %str
	li $v0, 4
	syscall
.end_macro

.macro	delay %ms
	li	$a0, %ms
	li	$v0, 32
	syscall
.end_macro

.macro	popup_message %str
	la $a0, %str
	li $a1, 1
	li $v0, 55
	syscall
.end_macro

# input an integer from a user and put it in the given register.
# smashes v0
.macro read_int %reg
	li $v0, 5
	syscall
	move %reg, v0
.end_macro

# exit the program.
.macro exit
	li $v0, 10
	syscall
.end_macro

# these all push ra as well as any registers you list after them.
# so "enter s0, s1" will save ra, s0, and s1, letting you use those s regs.
.macro cria_pilha
	addi $sp, $sp, -4
	sw $ra, 0($sp)
.end_macro

.macro cria_pilha %r1
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw %r1, 4($sp)
.end_macro

.macro cria_pilha %r1, %r2
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw %r1, 4($sp)
	sw %r2, 8($sp)
.end_macro

.macro cria_pilha %r1, %r2, %r3
	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw %r1, 4($sp)
	sw %r2, 8($sp)
	sw %r3, 12($sp)
.end_macro

.macro cria_pilha %r1, %r2, %r3, %r4
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw %r1, 4($sp)
	sw %r2, 8($sp)
	sw %r3, 12($sp)
	sw %r4, 16($sp)
.end_macro

.macro cria_pilha %r1, %r2, %r3, %r4, %r5
	addi $sp, $sp, -24
	sw $ra, 0($sp)
	sw %r1, 4($sp)
	sw %r2, 8($sp)
	sw %r3, 12($sp)
	sw %r4, 16($sp)
	sw %r5, 20($sp)
.end_macro

.macro cria_pilha %r1, %r2, %r3, %r4, %r5, %r6
	addi $sp, $sp, -28
	sw $ra, 0($sp)
	sw %r1, 4($sp)
	sw %r2, 8($sp)
	sw %r3, 12($sp)
	sw %r4, 16($sp)
	sw %r5, 20($sp)
	sw %r6, 24($sp)
.end_macro

.macro cria_pilha %r1, %r2, %r3, %r4, %r5, %r6, %r7
	addi $sp, $sp, -32
	sw $ra, 0($sp)
	sw %r1, 4($sp)
	sw %r2, 8($sp)
	sw %r3, 12($sp)
	sw %r4, 16($sp)
	sw %r5, 20($sp)
	sw %r6, 24($sp)
	sw %r7, 28($sp)
.end_macro

.macro cria_pilha %r1, %r2, %r3, %r4, %r5, %r6, %r7, %r8
	addi $sp, $sp, -36
	sw $ra, 0($sp)
	sw %r1, 4($sp)
	sw %r2, 8($sp)
	sw %r3, 12($sp)
	sw %r4, 16($sp)
	sw %r5, 20($sp)
	sw %r6, 24($sp)
	sw %r7, 28($sp)
	sw %r8, 32($sp)
.end_macro

.macro cria_pilha %r1, %r2, %r3, %r4, %r5, %r6, %r7, %r8, %r9
	addi sp, sp, -40
	sw $ra, 0($sp)
	sw %r1, 4($sp)
	sw %r2, 8($sp)
	sw %r3, 12($sp)
	sw %r4, 16($sp)
	sw %r5, 20($sp)
	sw %r6, 24($sp)
	sw %r7, 28($sp)
	sw %r8, 32($sp)
	sw %r9, 36($sp)
.end_macro


# the counterpart to enter. these pop the registers, and ra, and then return.
.macro desfaz_pilha
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
.end_macro

.macro desfaz_pilha %r1
	lw $ra, 0($sp)
	lw %r1, 4($sp)
	addi $sp, $sp, 8
	jr $ra
.end_macro

.macro desfaz_pilha %r1, %r2
	lw $ra, 0($sp)
	lw %r1, 4($sp)
	lw %r2, 8($sp)
	addi $sp, $sp, 12
	jr $ra
.end_macro

.macro desfaz_pilha %r1, %r2, %r3
	lw $ra, 0($sp)
	lw %r1, 4($sp)
	lw %r2, 8($sp)
	lw %r3, 12($sp)
	addi $sp, $sp, 16
	jr $ra
.end_macro

.macro desfaz_pilha %r1, %r2, %r3, %r4
	lw $ra, 0($sp)
	lw %r1, 4($sp)
	lw %r2, 8($sp)
	lw %r3, 12($sp)
	lw %r4, 16($sp)
	addi $sp, $sp, 20
	jr $ra
.end_macro

.macro desfaz_pilha %r1, %r2, %r3, %r4, %r5
	lw $ra, 0($sp)
	lw %r1, 4($sp)
	lw %r2, 8($sp)
	lw %r3, 12($sp)
	lw %r4, 16($sp)
	lw %r5, 20($sp)
	addi $sp, $sp, 24
	jr $ra
.end_macro

.macro desfaz_pilha %r1, %r2, %r3, %r4, %r5, %r6
	lw $ra, 0($sp)
	lw %r1, 4($sp)
	lw %r2, 8($sp)
	lw %r3, 12($sp)
	lw %r4, 16($sp)
	lw %r5, 20($sp)
	lw %r6, 24($sp)
	addi $sp, $sp, 28
	jr $ra
.end_macro

.macro desfaz_pilha %r1, %r2, %r3, %r4, %r5, %r6, %r7
	lw $ra, 0($sp)
	lw %r1, 4($sp)
	lw %r2, 8($sp)
	lw %r3, 12($sp)
	lw %r4, 16($sp)
	lw %r5, 20($sp)
	lw %r6, 24($sp)
	lw %r7, 28($sp)
	addi $sp, $sp, 32
	jr $ra
.end_macro

.macro desfaz_pilha %r1, %r2, %r3, %r4, %r5, %r6, %r7, %r8
	lw $ra, 0($$sp)
	lw %r1, 4($sp)
	lw %r2, 8($sp)
	lw %r3, 12($sp)
	lw %r4, 16($sp)
	lw %r5, 20($sp)
	lw %r6, 24($sp)
	lw %r7, 28($sp)
	lw %r8, 32($sp)
	addi $sp, $sp, 36
	jr $ra
.end_macro

.macro desfaz_pilha %r1, %r2, %r3, %r4, %r5, %r6, $r7, %r8, %r9
	lw $ra, 0($sp)
	lw %r1, 4($sp)
	lw %r2, 8($sp)
	lw %r3, 12($sp)
	lw %r4, 16($sp)
	lw %r5, 20($sp)
	lw %r6, 24($sp)
	lw %r7, 28($sp)
	lw %r8, 32($sp)
	lw %r9, 36($sp)
	addi $sp, $sp, 40
	jr $ra
.end_macro

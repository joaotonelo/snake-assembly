#	Projeto Final Microprocessadores - 2019/2
#
#	Guilherme Camargo Valese
#	Joao Pedro Tonelo
#	Nycolas de Abreu Coelho

.data
welcome_msg: .asciiz	"\n ============== Snake game ================\n utilize as teclas W,A,S,D para mover a cobra\n ESPACO para pausar o jogo\n\n Informe o numero correspondente ao nivel de dificuldade\n 0 - Facil\n 1 - Dificil"
load_msg:	 .asciiz	"\n\n Carregando mapa...\n"
exit_msg:	 .asciiz	"game finalizado, score total: "
total_score: .word		0

.text
init:
	la $a0, welcome_msg
	li $v0, 4
	syscall
	
	la $a0, load_msg
	li $v0, 4
	syscall
	
	jal main
	
	la $a0, exit_msg
	li $v0, 4
	syscall
	la $a0, total_score
	li $v0, 1
	syscall
	
	li	$v0, 10	
	syscall

main:
	jal enable_keyboard_int			# habilita teclado
	jal sprite_init					# inicializa sprites
	jal game_run
	

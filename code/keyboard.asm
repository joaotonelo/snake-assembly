#	Projeto Final Microprocessadores 2019/2
#	Modulo teclado

# Global Interrupt Handle Routines
enable_int:
        mfc0	$t0, $12	 # record interrupt state
	ori	$t0, $t0, 0x0001 # set int enable flag
	mtc0    $t0, $12	 # Turn interrupts on.
	jr      $ra
	
disable_int:
	mfc0	$t0, $12	 # record interrupt state
	andi	$t0, $t0, 0xFFFE # clear int enable flag
	mtc0    $t0, $12         # Turn interrupts off.
	jr      $ra
	
# RX Interrupts Enable (Keyboard)
.globl enable_keyboard_int
enable_keyboard_int:
	addi $sp, $sp, -8
	sw   $ra, 0($sp)
	
	jal  disable_int
	lui  $t0,0xffff
	lw   $t1,0($t0)      # read rcv ctrl
	ori  $t1,$t1,0x0002  # set the input interupt enable
	sw   $t1,0($t0)	     # update rcv ctrl
	jal  enable_int
	
	lw   $ra, 0($sp)
	addi $sp, $sp, 8
	jr	$ra

.ktext 0x80000180
interupt:
	addiu	$sp,$sp,-16
	sw	$at,12($sp)
	sw	$t2,8($sp)
	sw	$t1,4($sp)
	sw	$t0,0($sp)

	lui     $t0,0xffff     # get address of control regs
	lw	$t1,0($t0)     # read rcv ctrl
	andi	$t1,$t1,0x0001 # extract ready bit
	beq     $t1,$0,intDone #
	lw      $t1,4($t0)     # read key
	lw      $t2,8($t0)     # read tx ctrl
	andi	$t2,$t2,0x0001 # extract ready bit
	beq     $t2,$0,intDone # still busy discard
	sw      $t1, 0xc($t0)  # write key

intDone:
	## Clear Cause register
	mfc0	$t0,$13			# get Cause register, then clear it
	mtc0	$0, $13

	## restore registers
	lw	$t0,0($sp)
	lw	$t1,4($sp)
	lw	$t2,8($sp)
	lw 	$at,12($sp)
	addiu	$sp,$sp,16
	eret				# rtn from int and reenable ints

# http://www.cs.uwm.edu/classes/cs315/Bacon/Lecture/HTML/ch14s03.html
#
# Use "Tools->Keyboard and Display MMIO Simulator"


main:
	lui     $t0, 0xffff
	
	addi    $t8, $zero,1
	sll     $t8, $zero,20    # LOOP_COUNT = 2^20

OUTER_LOOP:
	lw      $t1, 0($t0)      # read control register
	andi    $t1, $t1,0x1     # mask off all but bit 0 (the 'ready' bit)

.data
NOT_READY_MSG: .asciiz "Ready bit is zero, looping until I find something else...\n"
.text
	bne     $t1,$zero, READY

	# print_str(NOT_READY_MSG)
	addi    $v0, $zero,4
	la      $a0, NOT_READY_MSG
	syscall

NOT_READY_LOOP:
	lw      $t1, 0($t0)      # read control register
	andi    $t1, $t1,0x1     # mask off all but bit 0 (the 'ready' bit)
	beq     $t1,$zero, NOT_READY_LOOP

READY:
	# read the actual typed character
	lw      $t1, 4($t0)

	# print_int(t1)
	addi    $v0, $zero,1
	add     $a0, $t1,$zero
	syscall

	# print_chr(' ')
	addi    $v0, $zero,11
	addi    $a0, $zero,' '
	syscall
	
	# print_chr(t1)
	addi    $v0, $zero,11
	add     $a0, $t1,$zero
	syscall

	# print_chr('\n')
	addi    $v0, $zero,11
	addi    $a0, $zero,'\n'
	syscall
	
DELAY_LOOP:
	addi    $t2, $zero,0      # i=0
	slt     $t3, $t2,$t8      # i < LOOP_COUNT
	beq     $t3,$zero, DELAY_DONE

	addi    $t2, $t2,1        # i++
	j       DELAY_LOOP
	
DELAY_DONE:
	j       OUTER_LOOP


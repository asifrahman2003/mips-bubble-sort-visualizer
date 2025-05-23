### Author: Asifur Rahman
### Course: CSc 252 - Sp25

        .data
promptN:        .asciiz "Enter number of elements (1 to 32): "
invalidStr:     .asciiz "Invalid count. Please try again.\n"
newline:        .asciiz "\n"
promptElem:     .asciiz "Enter element #"
colon:          .asciiz ": "
spaceStr:       .asciiz " "
sortedStr:      .asciiz "Sorted!\n"
passStr:        .asciiz "Pass #: "
swapCountStr:   .asciiz "Total swaps: "
swapCount:      .word 0
binaryStr:      .asciiz "Binary:\n"
initArrayStr:   .asciiz "Initial array:\n"
compCountStr:   .asciiz "Total comparisons: "
compCount:      .word 0
maxSize:        .word 32
array:          .space 128           # space for up to 32 words (32*4)

        .text
        .globl main
main:
readN:
        la    $a0, promptN
        li    $v0, 4                # syscall for print string
        syscall

        li    $v0, 5                # syscall for read integer
        syscall
        addu  $s0, $v0, $zero       # $s0 = N

        # if N < 1 show error message
        li    $t0, 1
        slt   $t2, $s0, $t0         # t2 = 1 if s0 < 1
        bne   $t2, $zero, invalidInput

        # if N > maxSize, show error message
        lw    $t1, maxSize
        slt   $t2, $t1, $s0         # t2 =1 if maxSize< s0
        bne   $t2, $zero, invalidInput

        # N is valid: proceed program
            j     readElements
    
readElements:
        # Read and store array elements
        li    $t3, 0             # t3 = index = 0

readLoop:
        # prompt for "Enter element #n: "
        la    $a0, promptElem
        li    $v0, 4
        syscall
        addu  $a0, $t3, $zero    # a0 = index
        addiu $a0, $a0, 1        # index+1
        li    $v0, 1
        syscall
        la    $a0, colon
        li    $v0, 4
        syscall

        # read integer
        li    $v0, 5
        syscall
        addu  $t4, $v0, $zero    # t4 = value

        # newline after input
        la    $a0, newline
        li    $v0, 4
        syscall
        
        # compute address & store it
        la    $t5, array
        sll   $t6, $t3, 2        # offset = index * 4
        addu  $t5, $t5, $t6
        sw    $t4, 0($t5)

        # increment index
        addiu $t3, $t3, 1

        # loop if t3 < s0
        slt   $t6, $t3, $s0
        bne   $t6, $zero, readLoop

        # proceed to sort
        j     sortArray

sortArray:
	    # initializes swap counter to 0
        la    $t0, swapCount
        li    $t2, 0
        sw    $t2, 0($t0)

        # print initial array
        la    $a0, initArrayStr
        li    $v0, 4
        syscall
        li    $s5, 0              # k = 0 for initial print

initPrintLoop:
        slt   $t6, $s5, $s0
        beq   $t6, $zero, endInitPrint
        la    $t7, array
        sll   $t8, $s5, 2
        addu  $t7, $t7, $t8
        lw    $a0, 0($t7)
        li    $v0, 1
        syscall
        la    $a0, spaceStr
        li    $v0, 4
        syscall
        addiu $s5, $s5, 1
        j     initPrintLoop
endInitPrint:
        la    $a0, newline
        li    $v0, 4
        syscall

        # initialize comparison counter
        la    $t2, compCount
        li    $s1, 0            # use s1 for compCount
        sw    $s1, 0($t2)

        # Prepare N-1 in t1
        addiu  $t1, $s0, -1       # t1 = N-1

        # outer loop i = 0 to N-2
        li     $t3, 0             # t3 = i = 0
outerLoop:

        slt    $t6, $t3, $t1      # t6 = 1 if i < N-1
        beq    $t6, $zero, doneSorting

        # print current pass (i+1)
        la    $a0, passStr
        li    $v0, 4
        syscall
        addu  $a0, $t3, $zero
        addiu $a0, $a0, 1
        li    $v0, 1
        syscall
        la    $a0, newline
        li    $v0, 4
        syscall

        # inner loop j = 0
        li     $t4, 0             # t4 = j = 0

innerLoop:
        # compute limit = N - i - 1 into t7
        addu   $t7, $s0, $zero    # t7 = N
        subu   $t7, $t7, $t3      # t7 = N - i
        addiu  $t7, $t7, -1       # t7 = N - i - 1
        slt    $t6, $t4, $t7      # if j < limit
        beq    $t6, $zero, endInner

        # load A[j] into t8
        la     $t9, array
        sll    $s2, $t4, 2       # offset = j*4
        addu   $t9, $t9, $s2
        lw     $t8, 0($t9)

        # load A[j+1] into $s3
        addiu  $s2, $t4, 1       # j+1
        sll    $s2, $s2, 2
        la     $s4, array
        addu   $s4, $s4, $s2
        lw     $s3, 0($s4)

        # increment comparison counter
        la    $t2, compCount
        lw    $s1, 0($t2)       # load into s1
        addiu $s1, $s1, 1
        sw    $s1, 0($t2)

        # if A[j] <= A[j+1], skip swap
        slt    $t6, $t8, $s3     # t6 = 1 if A[j] < A[j+1]
        bne    $t6, $zero, noSwap

        # swap A[j] and A[j+1]
        sw     $s3, 0($t9)
        sw     $t8,  0($s4)
        
        # increment swap counter
        la    $t0, swapCount
        lw    $t2, 0($t0)
        addiu $t2, $t2, 1
        sw    $t2, 0($t0)

        # print the entire array
        li     $s5, 0            # k = 0

printLoop:
        slt    $t6, $s5, $s0
        beq    $t6, $zero, endPrint
        la     $s6, array
        sll    $s7, $s5, 2
        addu   $s6, $s6, $s7
        lw     $a0, 0($s6)
        li     $v0, 1
        syscall
        
        la     $a0, spaceStr
        li     $v0, 4
        syscall
        addiu  $s5, $s5, 1
        j      printLoop

endPrint:
        la     $a0, newline
        li     $v0, 4
        syscall
        # a brief pause 
        li     $v0, 32
        li     $a0, 100
        syscall
    
noSwap:
        # increment j
        addiu  $t4, $t4, 1
        j      innerLoop
endInner:
        # increment i
        addiu  $t3, $t3, 1
        j      outerLoop

doneSorting:
        la     $a0, sortedStr
        li     $v0, 4
        syscall
        
        # print total number of  swaps
        la    $a0, swapCountStr
        li    $v0, 4
        syscall
        la    $t0, swapCount
        lw    $a0, 0($t0)
        li    $v0, 1
        syscall
        la    $a0, newline
        li    $v0, 4
        syscall

	    # print total number of comparisons
        la    $a0, compCountStr
        li    $v0, 4
        syscall
        la    $t2, compCount
        lw    $a0, 0($t2)
        li    $v0, 1
        syscall
        la    $a0, newline
        li    $v0, 4
        syscall

        # print binary of each element
        la    $a0, binaryStr
        li    $v0, 4
        syscall
        li    $t3, 0
binaryLoop:
        slt   $t6, $t3, $s0
        beq   $t6, $zero, endBinary
        la    $t7, array
        sll   $t8, $t3, 2
        addu  $t7, $t7, $t8
        lw    $a0, 0($t7)
        li    $v0, 35          # print integer in binary
        syscall
        la    $a0, newline
        li    $v0, 4
        syscall
        addiu $t3, $t3, 1
        j     binaryLoop
endBinary:

        j      readN

invalidInput:
        la    $a0, invalidStr
        li    $v0, 4
        syscall
        j     readN

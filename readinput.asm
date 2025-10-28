.data
fileName:   .asciiz "C:/Users/a/Desktop/input.txt"
fileWords:  .space 2048        # buffer for file content
.align 2                        # ensure word alignment
int_array:  .space 2000        # 500 integers * 4 bytes
newline:    .asciiz "\n"

.text
.globl main

main:
    # --- OPEN FILE FOR READING ---
    li $v0, 13
    la $a0, fileName
    li $a1, 0           # read mode
    li $a2, 0
    syscall
    move $s0, $v0       # file descriptor

    # --- READ FILE ---
    li $v0, 14
    move $a0, $s0
    la $a1, fileWords
    li $a2, 2048        # buffer size
    syscall
    move $s1, $v0       # number of bytes read

    # --- CLOSE FILE AFTER READING ---
    li $v0, 16
    move $a0, $s0
    syscall

    # --- PARSE NUMBERS INTO ARRAY ---
    li $t0, 0       # buffer index
    li $t1, 0       # array index
    li $t2, 0       # accumulator for current number
    li $t9, 0       # neg_flag
    li $t5, 0       # number_pending flag

parse_loop:
    beq $t0, $s1, store_last_number   # end of buffer

    lb $t6, fileWords($t0)

    li $t7, 45       # '-'
    beq $t6, $t7, set_neg

    li $t7, 10       # newline
    beq $t6, $t7, store_number

    li $t8, 48       # '0'
    li $t4, 57       # '9'
    blt $t6, $t8, next_char
    bgt $t6, $t4, next_char

    sub $t6, $t6, $t8
    mul $t2, $t2, 10
    add $t2, $t2, $t6
    li $t5, 1       # number pending

next_char:
    addi $t0, $t0, 1
    j parse_loop

set_neg:
    li $t9, 1
    addi $t0, $t0, 1
    j parse_loop

store_number:
    beq $t5, 0, skip_store  # no number accumulated

    beq $t9, 0, store_positive
    neg $t2, $t2
store_positive:
    sll $t7, $t1, 2
    la $t8, int_array
    add $t8, $t8, $t7
    sw $t2, 0($t8)

    addi $t1, $t1, 1
    li $t2, 0
    li $t9, 0
    li $t5, 0       # reset number_pending

skip_store:
    addi $t0, $t0, 1
    j parse_loop

store_last_number:
    beq $t5, 0, print_numbers  # store only if number pending
    j store_number

# --- PRINT NUMBERS ---
print_numbers:
    li $t3, 0        # print loop index
print_loop:
    bge $t3, $t1, exit

    sll $t7, $t3, 2
    la $t8, int_array
    add $t8, $t8, $t7
    lw $a0, 0($t8)

    li $v0, 1           # print integer
    syscall

    li $v0, 4           # print newline
    la $a0, newline
    syscall

    addi $t3, $t3, 1
    j print_loop

exit:
    li $v0, 10
    syscall

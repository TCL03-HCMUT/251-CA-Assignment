.data
fileName:   .asciiz "C:/Users/a/Desktop/input.txt"
fileWords:  .space 4096        # buffer for file content
.align 2
int_array:  .space 4000        # 500 floats × 4 bytes (stored as int*10)
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
    li $a2, 4096        # buffer size
    syscall
    move $s1, $v0       # number of bytes read

    # --- CLOSE FILE ---
    li $v0, 16
    move $a0, $s0
    syscall

    # --- PARSE FLOAT NUMBERS INTO ARRAY ---
    li $t0, 0       # buffer index
    li $t1, 0       # array index
    li $t2, 0       # accumulator for integer part
    li $t3, 0       # decimal digit
    li $t9, 0       # neg_flag
    li $t5, 0       # number_pending flag
    li $t6, 0       # decimal_flag (0=no decimal, 1=decimal seen)

parse_loop:
    beq $t0, $s1, store_last_number

    lb $t7, fileWords($t0)

    # check negative sign
    li $t8, 45        # '-'
    beq $t7, $t8, set_neg

    # check newline
    li $t8, 10
    beq $t7, $t8, store_number

    # check decimal point
    li $t8, 46        # '.'
    beq $t7, $t8, set_decimal

    # check digits 0-9
    li $t8, 48
    li $t4, 57
    blt $t7, $t8, next_char_parse
    bgt $t7, $t4, next_char_parse

    sub $t7, $t7, $t8

    beq $t6, 0, accumulate_int
    # decimal digit
    move $t3, $t7
    li $t6, 2         # decimal processed
    j next_char_parse

accumulate_int:
    mul $t2, $t2, 10
    add $t2, $t2, $t7
    li $t5, 1         # number pending

next_char_parse:
    addi $t0, $t0, 1
    j parse_loop

set_neg:
    li $t9, 1
    addi $t0, $t0, 1
    j parse_loop

set_decimal:
    li $t6, 1
    addi $t0, $t0, 1
    j parse_loop

store_number:
    beq $t5, 0, skip_store

    # combine integer and decimal
    beq $t6, 0, no_decimal
    mul $t2, $t2, 10
    add $t2, $t2, $t3
    j after_decimal
no_decimal:
    mul $t2, $t2, 10  # no decimal, scale by 10
after_decimal:
    # apply negative sign
    beq $t9, 0, store_val
    neg $t2, $t2
store_val:
    sll $t7, $t1, 2
    la $t8, int_array
    add $t8, $t8, $t7
    sw $t2, 0($t8)

    addi $t1, $t1, 1
    li $t2, 0
    li $t3, 0
    li $t5, 0
    li $t6, 0
    li $t9, 0

skip_store:
    addi $t0, $t0, 1
    j parse_loop

store_last_number:
    beq $t5, 0, print_numbers
    j store_number

# --- PRINT FLOATS ---
print_numbers:
    li $t3, 0

print_loop:
    bge $t3, $t1, exit

    sll $t7, $t3, 2
    la $t8, int_array
    add $t8, $t8, $t7
    lw $t2, 0($t8)

    # extract integer and decimal
    li $t9, 10
    div $t2, $t9
    mflo $a0       # integer part
    mfhi $t4       # decimal digit

    # print integer part
    li $v0, 1
    syscall

    # print dot
    li $v0, 11
    li $a0, 46
    syscall

    # print decimal digit
    move $a0, $t4
    li $v0, 1
    syscall

    # print newline
    li $v0, 4
    la $a0, newline
    syscall

    addi $t3, $t3, 1
    j print_loop

exit:
    li $v0, 10
    syscall

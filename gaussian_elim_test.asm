.data
A: .float 2, 1, -1,
          -3, -1, 2,
          -2, 1, 2

b: .float 8, -11, -3

msg: .asciiz "Solution x = \n"

.text
main:
    la $a0, A        # matrix A
    la $a1, b        # vector b
    li $a2, 3        # n = 3
    jal gaussian_elim

    # print solution (stored in b)
    li $v0, 4
    la $a0, msg
    syscall

    li $t0, 0
print_loop:
    bge $t0, 3, exit

    sll $t1, $t0, 2
    la $t2, b
    add $t2, $t2, $t1
    l.s $f12, 0($t2)

    li $v0, 2          # print float
    syscall

    # newline
    li $v0, 11
    li $a0, 10
    syscall

    addi $t0, $t0, 1
    j print_loop

exit:
    li $v0, 10
    syscall
.text

# ============================================================
# gaussian_elim(A, b, n)
# Solves A x = b, results stored in b (x replaces b)
# A: n x n matrix (float, row-major)
# b: n vector (float)
# ============================================================
gaussian_elim:
    add $s0, $a0, $zero     # s0 = A base
    add $s1, $a1, $zero     # s1 = b base
    add $s2, $a2, $zero     # s2 = n

# ---------- FORWARD ELIMINATION ----------
fe_i:
    move $t0, $zero         # i = 0
fe_i_loop:
    bge $t0, $s2, back_sub  # done forward phase

    # Load pivot A[i][i]
    mul $t1, $t0, $s2
    add $t1, $t1, $t0
    sll $t1, $t1, 2
    add $t2, $s0, $t1
    l.s $f0, 0($t2)         # f0 = A[i][i]

    # j = i+1
    addi $t3, $t0, 1
fe_j_loop:
    bge $t3, $s2, fe_i_inc

    # Load A[j][i]
    mul $t4, $t3, $s2
    add $t4, $t4, $t0
    sll $t4, $t4, 2
    add $t5, $s0, $t4
    l.s $f2, 0($t5)         # f2 = A[j][i]

    div.s $f2, $f2, $f0     # f2 = factor

    # k = i..n-1 update row j
    move $t6, $t0
fe_k_loop:
    bge $t6, $s2, fe_b_update

    # A[j][k]
    mul $t7, $t3, $s2
    add $t7, $t7, $t6
    sll $t7, $t7, 2
    add $t8, $s0, $t7
    l.s $f6, 0($t8)

    # A[i][k]
    mul $t9, $t0, $s2
    add $t9, $t9, $t6
    sll $t9, $t9, 2
    add $t9, $s0, $t9
    l.s $f8, 0($t9)

    mul.s $f8, $f8, $f2
    sub.s $f6, $f6, $f8
    s.s $f6, 0($t8)

    addi $t6, $t6, 1
    j fe_k_loop

# Update b[j] = b[j] - factor * b[i]
fe_b_update:
    sll $t9, $t0, 2
    add $t9, $t9, $s1
    l.s $f8, 0($t9)        # b[i]

    sll $t7, $t3, 2
    add $t7, $t7, $s1
    l.s $f6, 0($t7)        # b[j]

    mul.s $f8, $f8, $f2
    sub.s $f6, $f6, $f8
    s.s $f6, 0($t7)

    addi $t3, $t3, 1
    j fe_j_loop

fe_i_inc:
    addi $t0, $t0, 1
    j fe_i_loop

# ---------- BACK SUBSTITUTION ----------
back_sub:
    addi $t0, $s2, -1        # i = n-1
bs_i:
    bltz $t0, done

    # sum = b[i]
    sll $t1, $t0, 2
    add $t1, $t1, $s1
    l.s $f0, 0($t1)

    # j = i+1..n-1
    addi $t3, $t0, 1
bs_j:
    bge $t3, $s2, bs_compute

    # A[i][j]
    mul $t4, $t0, $s2
    add $t4, $t4, $t3
    sll $t4, $t4, 2
    add $t5, $s0, $t4
    l.s $f2, 0($t5)

    # x[j] in b[j]
    sll $t6, $t3, 2
    add $t6, $t6, $s1
    l.s $f4, 0($t6)

    mul.s $f2, $f2, $f4
    sub.s $f0, $f0, $f2

    addi $t3, $t3, 1
    j bs_j

bs_compute:
    # x[i] = sum / A[i][i]
    mul $t4, $t0, $s2
    add $t4, $t4, $t0
    sll $t4, $t4, 2
    add $t5, $s0, $t4
    l.s $f6, 0($t5)

    div.s $f0, $f0, $f6
    s.s $f0, 0($t1)

    addi $t0, $t0, -1
    j bs_i

done:
    jr $ra
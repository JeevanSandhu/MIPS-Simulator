.data
a: .word 10
b: .word 20
s: .word 0

.text
.globl main
main:
	lw $t0, a
	lw $t1, b
	add $t0, $t1, $t2
	sw $t2, s
	li $t3, 5
.end main

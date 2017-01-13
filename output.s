.data
 msg: .asciiz "\n" 
 a: .word 0
 y: .word 0
 c: .word 0
.text
main:
  li $t0, 30
  sw $t0, a
  li $t0, 10
  sw $t0, y
  lw $t0, y
  li $t1, 2
  add $t2, $t0, $t1
  lw $t0, a
  add $t3, $t0, $t2
  sw $t3, c
  li $v0, 1
  lw $a0, c
  syscall
  li $v0, 4
  la $a0, msg 
  syscall
 li $v0, 10
 syscall

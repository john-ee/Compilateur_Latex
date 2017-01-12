.data
 msg: .asciiz "\n" 
 d: .word 0
 b: .word 0
.text
main:
  li $t0, 42
  sw $t0, d
  li $t0, 24
  sw $t0, b
  li $v0, 1
  lw $a0, d
  syscall
  li $v0, 4
  la $a0, msg 
  syscall
  li $v0, 1
  lw $a0, b
  syscall
  li $v0, 4
  la $a0, msg 
  syscall
 li $v0, 10
 syscall

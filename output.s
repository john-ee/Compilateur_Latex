.data
 msg: .asciiz "\n" 
 a: .word 0
 y: .word 0
 c: .word 0
 d: .word 0
 msg0: .asciiz "a vaut 30, y vaut 10 \n" 
 msg1: .asciiz "c=a+y+2 vaut : \n" 
 msg2: .asciiz "Si on multiplie par 10 \n" 
.text
main:
  li $v0, 4
  la $a0, msg0 
  syscall
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
  li $v0, 4
  la $a0, msg1 
  syscall
  li $v0, 1
  lw $a0, c
  syscall
  li $v0, 4
  la $a0, msg 
  syscall
  lw $t0, c
  li $t1, 10
  mult $t0, $t1
  mflo $t4
  sw $t4, d
  li $v0, 4
  la $a0, msg2 
  syscall
  li $v0, 1
  lw $a0, d
  syscall
  li $v0, 4
  la $a0, msg 
  syscall
 li $v0, 10
 syscall

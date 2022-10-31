.bss

input_adress: .skip 20  # buffer
output_adress: .skip 5

.data

lineBreak: .byte '\n'

.text

read:
    li a0, 0 # file descriptor = 0 (stdin)
    la a1, input_adress #  buffer
    li a2, 20 # size em bytes
    li a7, 63 # syscall read (63)
    ecall
ret

write: 
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, output_adress       # buffer
    li a2, 5          # size
    li a7, 64           # syscall write (64)
    ecall
ret

writeBreak:
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, lineBreak
    li a2, 1       # size
    li a7, 64           # syscall write (64)
    ecall
ret 

stringToInt: //recebe um endereco de string e coloca em a2 o valor numerico da string
    li a7, 10

    lb a1, 3(a0)
    addi a2, a1, -48

    lb a1, 2(a0)
    addi a3, a1, -48
    mul a3, a3, a7
    add a2, a2, a3

    lb a1, 1(a0)
    addi a3, a1, -48
    mul a3, a3, a7
    mul a3, a3, a7
    add a2, a2, a3

    lb a1, 0(a0)
    addi a3, a1, -48
    mul a3, a3, a7
    mul a3, a3, a7
    mul a3, a3, a7
    add a2, a2, a3

ret

writeSqrt:
    li a7, 0 //variavel de contagem da iteracao
    li a6, 10 
    li a2, 2
    div a3, a0, a2
    1:
        mv a1, a3 # a1 = k
        div a3, a0, a1 
        add a3, a3, a1
        div a3, a3, a2 #a3 = k'
        mv a1, a3
        addi a7, a7, 1
    blt a7, a6, 1b

    mv s0, a3
    li a0, 10
    la a7, output_adress
    rem a1, s0, a0
    div s0, s0, a0
    addi a1, a1, 48
    sb a1, 3(a7)

    rem a1, s0, a0
    div s0, s0, a0
    addi a1, a1, 48
    sb a1, 2(a7)

    rem a1, s0, a0
    div s0, s0, a0
    addi a1, a1, 48
    sb a1, 1(a7)

    rem a1, s0, a0
    div s0, s0, a0
    addi a1, a1, 48
    sb a1, 0(a7)

    li a1, ' '
    sb a1, 4(a7)
    mv t1, ra
    jal ra, write
    mv ra, t1

ret

.globl _start
_start:
jal ra, read

la a0, input_adress #a0 guarda o endereco do inicio da string de entrada

jal ra, stringToInt
mv s0, a2

addi a0, a0, 5 #incrementa-se a0 em 5 unidades para alinha-lo com o comeco do proximo numero
jal ra, stringToInt
mv s1, a2

addi a0, a0, 5
jal ra, stringToInt
mv s2, a2

addi a0, a0, 5
jal ra, stringToInt
mv s3, a2

mv a0, s0 #a0 sera usado como entrada da funcao writeSqrt
jal ra, writeSqrt

mv a0, s1
jal ra, writeSqrt

mv a0, s2
jal ra, writeSqrt

mv a0, s3
jal ra, writeSqrt

jal ra, writeBreak
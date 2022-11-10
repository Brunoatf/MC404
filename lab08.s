.data

base: .word 0xFFFF0100

.text

#int time()
time:
    addi sp, sp, -16
    mv a0, sp #buffer_timeval
    mv a1, zero #buffer time zone
    li a7, 169 # chamada de sistema gettimeofday
    ecall
    lw t1, 0(sp) # tempo em segundos
    lw t2, 8(sp) # fração do tempo em microssegundos
    li t3, 1000
    mul t1, t1, t3
    div t2, t2, t3
    add a0, t2, t1
    addi sp, sp, 16
ret

#void sleep(int ms)
sleep:
    addi sp, sp, -16
    sw a0, 0(sp) #0(sp) guarda a duração desejada em ms
    sw ra, 12(sp)
    jal time
    li t0, -1
    mul a0, a0, t0
    sw a0, 4(sp) #4(sp) guarda o valor negativo do tempo inicial
    break1:
    1:
        jal time
        lw t0, 4(sp)
        lw t1, 0(sp) #t1 guarda a duração desejada
        break2:
        add a0, a0, t0 #a0 passa a guardar o tempo decorrido
        bgeu a0, t1, 2f
        j 1b 
    2:
    lw ra, 12(sp)
    addi sp, sp, 16
ret

.globl _start

_start:

li t0, 1
li t1, -1
lw s0, base

# posicao final: x: 73, y: 1, z: -19
li s1, 73
li s2, -19

li s5, 165
li s6, -114

#sb t0, 0(s0) #le as coordenadas atuais
#busy_wait:
#    lb t6, 0(s0)
#bne t6, zero, busy_wait
#lw s5, 0x10(s0) #s5 guarda x atual
#lw s6, 0x18(s0) #s6 guarda z atual

sb t0, 0x21(s0)
li a0, 1000
jal sleep
li t0, 1
li t1, -1
sb zero, 0x21(s0)

1:

    sb t0, 0x21(s0)
    li a0, 1000
    jal sleep
    li t0, 1
    li t1, -1
    sb t1, 0x21(s0)
    li a0, 550
    jal sleep
    li t0, 1
    li t1, -1

    mv s3, s5 #s3 guarda o x anterior 
    mv s4, s6 #s6 guarda o z anterior
    
    sb t0, 0(s0) #le as coordenadas atuais

    busy_wait2:
        lb t6, 0(s0)
    bne t6, zero, busy_wait2

    lw s5, 0x10(s0) #s5 guarda x atual
    lw s6, 0x18(s0) #s6 guarda z atual

    #s8 e s9 guardarão o vetor deslocamento do carro
    sub s8, s5, s3
    sub s9, s6, s4

    #s10 e s11 guardarão o vetor que liga o ponto atual ao ponto final rotacionado -90 graus ((x,y) --> (y, -x))
    
    sub s10, s1, s5 #x do vetor que liga o ponto atual ao final
    sub s11, s2, s6 #y do vetor que liga o ponto atual ao final
    mul s10, s10, t1 #-x

    #sai do while se estivermos na região a um raio de 15 unidades do alvo
    mul t3, s11, s11
    mul t4, s10, s10
    add t3, t3, t4
    li t4, 225
    ble t3, t4, 2f

    #Agora calcula-se em s7 o produto interno entre os vetores (s8,s9) e (s11, s10). Não usei s7 ate agora, ta livre
    mul t3, s8, s11
    mv s7, t3
    mul t3, s9, s10
    add s7, s7, t3

    li t5, 20
    li t6, -20
    bge s7, zero, 3f #se o produto interno for positivo (precisando virar para a esquerda), pula para 3
        sb t5, 0x20(s0)
        addi a1, a1, 1
        j 4f
    3:
        sb t6, 0x20(s0)
    4:

    j 1b
2:

#liga o freio de mão e para o carro
sb t1, 0x21(s0)
li a0, 2000
jal sleep
li t0, 1
li t1, -1
sb t0, 0x22(s0)
li a7, 93
ecall
.data

base: .word 0xFFFF0100

.text

.globl _start

_start:

li t0, 1
li t1, -1
lw s0, base

# posicao final: x: 73, y: 1, z: -19
li s1, 73
li s2, -19

li s3, 165
li s4, -114

1:

    mv s3, s5 #s3 guarda o x anterior 
    mv s4, s6 #s6 guarda o z anterior
    mul s3, s3, t1
    mul s4, s4, t1
    
    sb t0, 0(s0) #le as coordenadas atuais

    busy_wait:
        lb t6, 0(s0)
    bne t6, zero, busy_wait

    lw s5, 0x10(s0) #s5 guarda x atual
    lw s6, 0x18(s0) #s6 guarda z atual

    #se o carro estiver a menos de 15 metros da posicao final, sai do while
    mul t2, s5, s5
    mul t3, s6, s6
    add t2, t2, t3
    li t3, 225
    ble t2, t3, 2f

    #liga o motor para frente
    sb t0, 0x21(s0)

    #s8 e s9 guardarão o vetor deslocamento do carro
    add s8, s5, s3
    add s9, s6, s4

    #s10 e s11 guardarão o vetor que liga o ponto atual ao ponto final rotacionado -90 graus ((x,y) --> (y, -x))
    mul t2, s5, t1
    mul t3, s6, t1
    
    addi s10, t2, 73
    mul s10, s10, t1 #y do vetor desejado
    
    addi s11, t3, -19 #x do vetor desejado

    #Agora calcula-se em s7 o produto interno entre os vetores (s8,s9) e (s11, s10). Não usei s7 ate agora, ta livre
    li s7, 0
    mul t3, s8, s11
    add s7, s7, t3
    mul t3, s9, s10
    add s7, s7, t3
    li t5, 20
    li t6, -20
    bge s7, zero, 3f #se o produto interno for positivo, pula para 3
        sb t5, 0x20(s0)
        j 4f
    3:
        sb t6, 0x20(s0)
    4:
    
    j 1b
2:

#sb t0, 0x21(s0)
sb t0, 0x22(s0)
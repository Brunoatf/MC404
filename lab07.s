.rodata 

quebra_linha: .asciz "\n"

.data

teste: .asciz "    256 a"
tempo1: .asciz "tempo1"
tempo2: .asciz "tempo2"

.bss

string: .skip 0xa0

.text

#recebe endereço de string no a0
puts:

    li t0, 0
    li a2, 0 #a2 guarda o tamanho da string de a0
    mv t1, a0 #t1 guarda o endereço do próximo char
    1:
        lb t2, 0(t1)
        addi t1, t1, 1
        beq t2, t0, 2f
        addi a2, a2, 1  
        j 1b
    2:

    mv a1, a0 #buffer 
    li a0, 1            # file descriptor = 1 (stdout)
    li a7, 64           # syscall write (64)
    ecall   

    li a0, 1
    li a7, 64
    li a2, 1
    la a1, quebra_linha
    ecall
ret

#recebe uma string de stdin e guarda no endereço de a0
gets:

    li t0, 0
    li t1, '\n'
    li t2, 26

    mv a6, a0
    mv a1, a0 #a1 guarda o endereço de salvamento pro byte
    1:
        li a2, 1 #leremos 1 byte por vez
        li a0, 0 #stdin
        li a7, 63 # syscall read (63)
        ecall
        lbu a3, 0(a1)
        beq a3, t1, addlastchar #se a3 for '\n', encerramos o while e escrevemos \0 ao final da string
        beq a3, t2, addlastchar #se a3 for um final de arquivo, encerramos o while e escrevemos \0 ao final da string
        beq a3, t0, 2f #se a3 for \0, não precisamos mais fazer leituras
        addi a1, a1, 1
        j 1b
        addlastchar:
        sb t0, 0(a1)
        j 2f
    2:
    
    mv a0, a6

ret

#primeiro descarta caracteres em branco e transforma a string apontada por a0 em int
atoi:

    li t0, ' '
    li a2, 0 #offset de espaços em branco até o número desejado
    mv t1, a0
    1:
        lbu t2, 0(t1)
        bne t2, t0, 2f
        addi a2, a2, 1
        addi t1, t1, 1
        j 1b
    2:

    add a1, a0, a2 #a1 passa a apontar para o número desejado
    li a0, 0
    li t0, 10
    li t1, '0'
    li t2, '9'
    1:
        lbu a3, 0(a1)
        addi a1, a1, 1
        blt a3, t1, 2f
        bgt a3, t2, 2f
        mul a0, a0, t0
        addi a3, a3, -'0'
        add a0, a0, a3
        j 1b
    2:

ret

#char *  itoa ( int value, char * str, int base );
itoa:
    mv a7, a1
    li t0, 16
    li t1, 10
    beq a2, t0, hex

        #base decimal:
        bge a0, zero, positivo
        li t2, '-'
        sb t2, 0(a1)
        addi a1, a1, 1
        positivo:
        
        li t2, 0 #representa o número de dígitos de value
        mv t3, a0
        1:
            addi t2, t2, 1
            div t3, t3, t1
        bne t3, zero, 1b

        li t4, 0  
        add t3, t2, a1 #t3 passa a guardar o endereço do \0 após o número, que possui t2 dígitos
        sb t4, 0(t3) #seta o último dígito da string como \0
        addi t3, t3, -1 #t3 será decrementado ao longo da montagem do número, até ser igual a a1

        1:  
            rem t4, a0, t1 #t4 passa a receber o resto da divisão de a0 por 10
            addi t4, t4, '0'
            div a0, a0, t1 #divide-se a0 por 10 
            sb t4, 0(t3) #guardamos no endereço de t3 o dígito ascii t4
            beq t3, a1, 2f
            addi t3, t3, -1
            j 1b
        2:
        
        j 3f

    hex: #base hexadecimal:

        li t2, 0 #representa o número de dígitos de value
        mv t3, a0
        1:
            addi t2, t2, 1
            div t3, t3, t0
        bne t3, zero, 1b

        li t4, 0   
        add t3, t2, a1 #t3 passa a guardar o endereço do \0 após o número, que possui t2 dígitos
        sb t4, 0(t3) #seta o último dígito da string como \0
        addi t3, t3, -1 #t3 será decrementado ao longo da montagem do número, até ser igual a a1

        1:  
            rem t4, a0, t0 #t4 passa a receber o resto da divisão de a0 por 16
            bge t4, t1, 3f #se t4 for maior ou igual a 10
            addi t4, t4, '0'
            j 4f
            3:
            addi t4, t4, 'a'-10
            4:
            div a0, a0, t0
            sb t4, 0(t3) #guardamos no endereço de t3 o dígito t4
            beq t3, a1, 2f
            addi t3, t3, -1
            j 1b
        2:

    3:
    mv a0, a7
ret

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

#int approx_sqrt(int x, int iterations)
approx_sqrt:

#void imageFilter(char * img, int width, int height, char filter[3][3]);
imageFilter:

#void exit(int code)
exit:
    li a7, 1
    ecall
ret

.globl _start
_start:

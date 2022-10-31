.text

#recebe endereço de string no a0
.globl puts
puts:

    addi sp, sp, -16
    li t0, '\n'
    sb t0, 0(sp)

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
    mv a1, sp
    ecall

    addi sp, sp, 16
ret

#recebe uma string de stdin e guarda no endereço de a0
.globl gets
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
        addi a1, a1, 1
        j 1b
        addlastchar:
        sb t0, 0(a1)
    2:
    
    mv a0, a6

ret

#primeiro descarta caracteres em branco e transforma a string apontada por a0 em int
.globl atoi
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

    add a1, a0, a2 #a1 passa a apontar possivelmente para o sinal do número desejado
    li t0, '+'
    lbu a3, 0(a1)
    beq a3, t0, 1f //se o numero for positivo com caractere de sinal, vai para 1f
    li t0, '-'
    beq a3, t0, 2f //se for negativo, vai para 2f
    li a7, 1
    j 3f
    1:
        li a7, 1
        addi a1, a1, 1
    2:
        li a7, -1
        addi a1, a1, 1
    3:

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

    mul a0, a0, a7

ret

#char *  itoa ( int value, char * str, int base );
.globl itoa
itoa:
    mv a7, a1

    bge a0, zero, positivo
    li t2, '-'
    sb t2, 0(a1)
    addi a1, a1, 1
    positivo:
    
    li t2, 0 #representa o número de dígitos de value
    
    mv t3, a0
    1:
        addi t2, t2, 1
        div t3, t3, a2
    bne t3, zero, 1b
    
    li t4, 0  
    add t3, t2, a1 #t3 passa a guardar o endereço do \0 após o número, que possui t2 dígitos
    sb t4, 0(t3) #seta o último dígito da string como \0
    addi t3, t3, -1 #t3 será decrementado ao longo da montagem do número, até ser igual a a1
    li t6, 9
    1:  
        rem t4, a0, a2 #t4 passa a receber o resto da divisão de a0 por a2
        ble t4, t6, 3f
            addi t4, t4, 'a'-10
            j 4f
        3:
            addi t4, t4, '0'
        4:
        div a0, a0, a2 #divide-se a0 por a2
        sb t4, 0(t3) #guardamos no endereço de t3 o dígito ascii t4
        beq t3, a1, 2f
        addi t3, t3, -1
        j 1b
    2:

    mv a0, a7
ret

#int time()
.globl time
time:
    addi sp, sp, -16
    mv a0, sp #buffer_timeval
    mv a1, zero #buffer time zone
    li a7, 169 # chamada de sistema gettimeofday
    ecall
    mv a0, sp
    lw t1, 0(sp) # tempo em segundos
    lw t2, 8(sp) # fração do tempo em microssegundos
    li t3, 1000
    mul t1, t1, t3
    div t2, t2, t3
    add a0, t2, t1
    addi sp, sp, 16
ret

#void sleep(int ms)
.globl sleep
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

#int approx_sqrt(int x, int iterations); a1 é número
.globl approx_sqrt
approx_sqrt:

    li a7, 0 //variavel de contagem da iteracao
    li a2, 2
    div a3, a0, a2 //a3 recebe k e guardará o resultado final
    1:
        mv a6, a3 # a6 = k
        div a3, a0, a6 //a3 = y/k
        add a3, a3, a6 //a3 = k + y/k
        div a3, a3, a2 #a3 = k'
        #mv a6, a3 #a6 = k'
        addi a7, a7, 1
    blt a7, a1, 1b

    mv a0, a3

ret

#void imageFilter(char * img, int width, int height, char filter[3][3]);
.globl imageFilter
imageFilter:

    addi sp, sp, -48
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    sw s8, 32(sp)

    mul t6, a1, a2 //t0 guarda o numero de posicoes da matriz
    li t1, 4
    mul t6, t6, t1
    li t1, 16
    rem t2, t6, t1
    sub t2, t1, t2 //t2 passa a receber 16-(t0 % 16)
    add t6, t6, t2 //agora t6 é multiplo de 16
    
    sub sp, sp, t6
    mv t4, sp //t4 guardará o endereço do próximo elemento da matriz a ser guardado na pilha
    
    li t0, ' '
    li t1, '\n'
    li t2, 10

    mv s0, a0 #s0 passa a ter o endereço das informações, pois a0 será usado em syscalls
    mv a0, a1 #na syscall a0 deve ter a largura
    mv a1, a2 #e a1 a altura

    mv s3, a0 #largura
    mv s4, a1 #altura

    li s1, 0 #i do for
    li s2, 0 #j do for
    addi t0, s3, -1 #indice da ultima coluna
    addi t1, s4, -1 #indice da ultima linha
    1: #for que percorre as linhas da matriz
        bge s1, s4, 2f #sai do for se s1 for igual a height
        li s2, 0
        3: #for que percorre as colunas da matriz
            bge s2, s3, 4f #sai do for se s2 for igual a width

            #se estamos na primeira coluna, na última coluna, na primeira linha ou na última linha
            beq s1, zero, 5f
            beq s1, t1, 5f
            beq s2, zero, 5f
            beq s2, t0, 5f

            li s5, 0 #guardará o resultado final
            sub t3, s0, s3 #t3 será a posicao i-1 j da matriz da imagem

            lw s7, 0(a3) #s7 será a posição 1x1 da matriz de filtro
            lbu s6, -1(t3) #s6 guarda o pixel M[i-1][j-1]
            mul s6, s6, s7 #multilplica o pixel de s6 por s7
            add s5, s5, s6
            
            lw s7, 1(a3) #s7 será a posição 1x2 da matriz de filtro
            lbu s6, 0(t3) #s6 guarda o pixel M[i-1][j]
            mul s6, s6, s7 #multiplica o pixel de s6 por s7
            add s5, s5, s6

            lw s7, 2(a3) #s7 será a posição 1x3 da matriz de filtro
            lbu s6, 1(t3) #s6 guarda o pixel M[i-1][j+1]
            mul s6, s6, s7 #multiplica o pixel de s6 por s7
            add s5, s5, s6

            lw s7, 3(a3) #s7 será a posição 2x1 da matriz de filtro
            lbu s6, -1(s0) #s6 guarda o pixel M[i][j-1]
            mul s6, s6, s7 #multiplica o pixel de s6 por s7
            add s5, s5, s6
            
            lw s7, 4(a3) #s7 será a posição 2x2 da matriz de filtro
            lbu s6, 0(s0) #s6 guarda o pixel M[i][j]
            mul s6, s6, s7 #multiplica o pixel de s6 por s7
            add s5, s5, s6

            lw s7, 5(a3) #s7 será a posição 2x3 da matriz de filtro
            lbu s6, 1(s0) #s6 guarda o pixel M[i][j+1]
            mul s6, s6, s7 #multiplica o pixel de s6 por -1
            add s5, s5, s6

            add t3, s0, s3

            lw s7, 5(a3) #s7 será a posição 3x1 da matriz de filtro
            lbu s6, -1(t3) #s6 guarda o pixel M[i+1][j-1]
            mul s6, s6, s7 #multiplica o pixel de s6 por -1
            add s5, s5, s6

            lw s7, 6(a3) #s7 será a posição 3x2 da matriz de filtro
            lbu s6, 0(t3) #s6 guarda o pixel M[i+1][j]
            mul s6, s6, s7 #multiplica o pixel de s6 por -1
            add s5, s5, s6

            lw s7, 7(a3) #s7 será a posição 3x3 da matriz de filtro
            lbu s6, 1(t3) #s6 guarda o pixel M[i+1][j+1]
            mul s6, s6, s7 #multiplica o pixel de s6 por -1
            add s5, s5, s6

            li s8, 255
    
            blt s5, zero, 1f
            bge s5, s8, 2f
            j store_in_stack

            1: //s5 é menor que 0
            li s5, 0
            j store_in_stack

            2: //s5 é maior que 255
            li s5, 255
            j store_in_stack

            5: 
            li s5, 0 #estamos em uma posição de borda que deve ser pintada de preto
            
            store_in_stack: #rotulo apontando para o final desse for, onde guardaremos o valor na stack

            sw s5, 0(t4)
            addi t4, t4, 4

            addi s2, s2, 1
            j 3b
        4:
        addi s1, s1, 1
        j 1b
    2:


    mv t4, sp //t4 passa a apontar para o primeiro elemento da matriz na stack
    li s1, 0 #i do for
    li s2, 0 #j do for
    1: #for que percorre as linhas da matriz
        bge s1, s4, 2f #sai do for se s1 for igual a height
        li s2, 0
        3: #for que percorre as colunas da matriz
            bge s2, s3, 4f #sai do for se s2 for igual a width

            lw s5, 0(t4)
            addi t4, t4, 4
            sw s5, 0(s0)
            addi s0, s0, 4 

            addi s2, s2, 1
            j 3b
        4:
        addi s1, s1, 1
        j 1b
    2:

    addi sp, sp, 48
    add sp, sp, t6

ret

#void exit(int code)
.globl exit
exit:
    li a7, 93
    ecall
ret

#.globl _start
#_start:
#la a0, teste
#jal gets
#jal puts
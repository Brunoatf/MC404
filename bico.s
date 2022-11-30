/*
  Define os valores para o deslocamento vertical e horizontal do carro.
  Paramêtros:
  * vertical:   um byte que define o deslocamento vertical, entre -1 e 1.
                Valor -1 faz o carro andar para trás e 1 para frente
  * horizontal: define o valor para o deslocamento horizontal, entre -127 e 127.
                Valores negativos gera deslocamento para a direita e positivos
                para a esquerda.
  Retorna:
  * 0 em caso de sucesso.
  * -1 caso algum parametro esteja fora de seu intervalo.
*/
.globl set_motor
set_motor:
    li a7, 10
    ecall
ret

/*
  Aciona o freio de mão do carro.
  Paramêtros:
  * valor:  um byte que define se o freio será acionado ou não.
            1 para acionar o freio e 0 para não acionar.
  Retorna:
  * 0 em caso de sucesso.
  * -1 caso algum parametro esteja fora de seu intervalo .
*/
.globl set_handbreak
set_handbreak:
    li a7, 11
    ecall
ret

/*
  Lê os valores da camera de linha.
  Paramêtros:
  * img:  endereço de um vetor de 256 elementos que armazenará os
          valores lidos da camera de linha.
  Retorna:
    Nada
*/
.globl read_camera
read_camera:
    li a7, 12
    ecall
ret

/*
  Lê a distancia do sensor ultrasônico
  Paramêtros:
    Nenhum
  Retorna:
    O inteiro com a distância do sensor, em centímetros.
*/
.globl read_sensor_distance
read_sensor_distance:
    li a7, 13
    ecall
ret

/*
  Lê a posição aproximada do carro usano um dispositivo de GPS
  Parametros:
  * x:  endereço da variável que armazenará o valor da posição x
  * y:  endereço da variável que armazenará o valor da posição y
  * z:  endereço da variável que armazenará o valor da posição z
  Retorna:
    Nada
*/
.globl get_position
get_position:
    li a7, 15
    ecall
ret

/*
  Lê a rotação global do dispositivo de giroscópio
  Parametros:
  * x:  endereço da variável que armazenará o valor do angulo de Euler em x
  * y:  endereço da variável que armazenará o valor do angulo de Euler em y
  * z:  endereço da variável que armazenará o valor do angulo de Euler em z
  Retorna:
    Nada
*/
.globl get_rotation
get_rotation:
    li a7, 16
    ecall
ret

/*
  Lê o tempo do sistema
  Paramêtros:
    Nenhum
  Retorna:
    O tempo do sistema, em milisegundos.
*/
.globl get_time
get_time:
    li a7, 20
    ecall
ret

/*
  Filtra uma imagem unidimensional utilizando um filtro unidimensional (similar ao lab 6b, mas para apenas uma dimensão). 
  Paramêtros:
    img: array representando a imagem.
    filter: vetor de 3 posições representando o filtro 1D.
  Retorna:
    Nada
*/
.globl filter_1d_image
filter_1d_image:

/*
  Mostra uma imagem 1D (1x256) no canvas. 
  Paramêtros:
    img: array representando a imagem.
  Retorna:
    Nada
*/
.globl display_image
display_image:
    li a7, 19
    ecall
ret

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
    li a7, 18           # syscall write (18)
    ecall   

    li a0, 1
    li a7, 18
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
        li a7, 17 # syscall read (17)
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

#void sleep(int ms)
.globl sleep
sleep:
    addi sp, sp, -16
    sw a0, 0(sp) #0(sp) guarda a duração desejada em ms
    sw ra, 12(sp)
    jal get_time
    li t0, -1
    mul a0, a0, t0
    sw a0, 4(sp) #4(sp) guarda o valor negativo do tempo inicial
    break1:
    1:
        jal get_time
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
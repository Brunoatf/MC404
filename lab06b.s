.data

input_file: .asciz "imagem.pgm"

.bss

input_adress: .skip 262159

.text

write:
li a0, 1            # file descriptor = 1 (stdout)
la a1, input_adress       # buffer
li a2, 17           # size
li a7, 64           # syscall write (64)
ecall
ret

read:
la a1, input_adress #  buffer
li a2, 262159 # size
li a7, 63 # syscall read (63)
ecall
ret

open:
la a0, input_file    # endereço do caminho para o arquivo
li a1, 0             # flags (0: rdonly, 1: wronly, 2: rdwr)
li a2, 0             # modo
li a7, 1024          # syscall open 
ecall
ret

setPixel:
li a7, 2200 # syscall setGSPixel (2200)
ecall
ret

setCanvasSize: 
#a0: largura do canvas (valor entre 0 e 512)
#a1: altura do canvas (valor entre 0 e 512)
#a7: 2201 (número da syscall)
li a7, 2201
ecall
ret

display:
    la a0, input_adress
    addi a0, a0, 3
    li t0, ' '
    li t1, '\n'
    li t2, 10

    li a1, 0 #width
    1: #while que roda até montarmos a width da imagem
        lb a3, 0(a0)
        addi a0, a0, 1
        beq a3, t0, 2f #sai do while se a3 for um espaço em branco
        beq a3, t1, 2f #sai do while se a3 for um \n
        mul a1, a1, t2
        addi a3, a3, -'0'
        add a1, a1, a3
        j 1b
    2:

    li a4, 0 #height
    1: #while que roda até montarmos a height
        lb a3, 0(a0)
        beq a3, t0, 2f #sai do while se a3 for um espaço em branco
        beq a3, t1, 2f #sai do while se a3 for um \n
        addi a0, a0, 1
        mul a4, a4, t2
        addi a3, a3, -'0'
        add a4, a4, a3
        j 1b
    2:

    addi a0, a0, 5 #ajusta a0 para receber a próxima informação útil
    mv s0, a0 #s0 passa a ter o endereço das informações, pois a0 será usado em syscalls
    mv a0, a1 #na syscall a0 deve ter a largura
    mv a1, a4 #e a1 a altura
    jal setCanvasSize

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
            beq s1, zero, borda
            beq s1, t1, borda
            beq s2, zero, borda
            beq s2, t0, borda

            li s5, 0 #guardará o resultado final
            sub t3, s0, s3 #t3 será a posicao i-1 j da matriz da imagem
            li s7, -1
            
            lbu s6, -1(t3) #s6 guarda o pixel M[i-1][j-1]
            mul s6, s6, s7 #multilplica o pixel de s6 por -1
            add s5, s5, s6
            
            lbu s6, 0(t3) #s6 guarda o pixel M[i-1][j]
            mul s6, s6, s7 #multiplica o pixel de s6 por -1
            add s5, s5, s6

            lbu s6, 1(t3) #s6 guarda o pixel M[i-1][j+1]
            mul s6, s6, s7 #multiplica o pixel de s6 por -1
            add s5, s5, s6

            lbu s6, -1(s0) #s6 guarda o pixel M[i][j-1]
            mul s6, s6, s7 #multiplica o pixel de s6 por -1
            add s5, s5, s6
            
            li s7, 8
            lbu s6, 0(s0) #s6 guarda o pixel M[i][j]
            mul s6, s6, s7 #multiplica o pixel de s6 por 8
            add s5, s5, s6
            li s7, -1

            lbu s6, 1(s0) #s6 guarda o pixel M[i][j+1]
            mul s6, s6, s7 #multiplica o pixel de s6 por -1
            add s5, s5, s6

            add t3, s0, s3

            lbu s6, -1(t3) #s6 guarda o pixel M[i+1][j-1]
            mul s6, s6, s7 #multiplica o pixel de s6 por -1
            add s5, s5, s6

            lbu s6, 0(t3) #s6 guarda o pixel M[i+1][j]
            mul s6, s6, s7 #multiplica o pixel de s6 por -1
            add s5, s5, s6

            lbu s6, 1(t3) #s6 guarda o pixel M[i+1][j+1]
            mul s6, s6, s7 #multiplica o pixel de s6 por -1
            add s5, s5, s6

            li s8, 255
    
            blt s5, zero, less_than_0
            bge s5, s8, more_than_255
            j print

            less_than_0:
            li s5, 0
            j print

            more_than_255:
            li s5, 255
            j print

            borda:
            li s5, 0 #estamos em uma posição de borda que deve ser pintada de preto
            
            print: #rotulo apontando para o final desse for, onde ocorre o set pixel

            li t3, 256
            mv a0, s2 #a0 recebe a coordenada x
            mv a1, s1 #a1 recebe a coordenada y
            li a7, 2200 # syscall setGSPixel (2200)
            li a2, 0
            add a2, a2, s5
            mul a2, a2, t3
            add a2, a2, s5
            mul a2, a2, t3
            add a2, a2, s5
            mul a2, a2, t3
            addi a2, a2, 255
            jal setPixel
            addi s0, s0, 1

            addi s2, s2, 1
            j 3b
        4:
        addi s1, s1, 1
        j 1b
    2:
ret
    
.globl _start
_start:
jal open
jal read
jal display
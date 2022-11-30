.bss

.align 4

isr_stack: .skip 1024
isr_stack_end:

.text

.align 4

.set base_gpt, 0xFFFF0100
.set base_carro, 0xFFFF0300
.set base_port, 0xFFFF0500
.set base_canvas, 0xFFFF0700

###### Tratador de interrupções e syscalls ######
int_handler:

    csrrw sp, mscratch, sp # Troca sp com mscratch
    addi sp, sp, -64 # Aloca espaço na pilha da isl
    sw t0, 0(sp)
    sw t1, 4(sp)
    sw t2, 8(sp)
    sw t3, 12(sp)
    sw t4, 16(sp)
    sw t5, 20(sp)
    sw t6, 24(sp)

    li t0, 10
    beq a7, t0, set_engine_and_steering
    li t0, 11
    beq a7, t0, set_handbreak
    li t0, 12
    beq a7, t0, read_sensors 
    li t0, 13
    beq a7, t0, read_sensor_distance
    li t0, 15
    beq a7, t0, get_position
    li t0, 16
    beq a7, t0, get_rotation
    li t0, 17
    beq a7, t0, read
    li t0, 18
    beq a7, t0, write
    li t0, 19
    beq a7, t0, draw_line
    li t0, 20
    beq a7, t0, get_systime

    j 1f

    set_engine_and_steering:

        li t3, 2
        li t4, -1
        li t5, 128
        li t6, -126
        bge a0, t3, error
        blt a0, t4, error
        bge a1, t5, error
        blt a1, t6, error

        li t6, base_carro
        sb a0, 0x21(t6)
        sb a1, 0x20(t6) 

        li a0, 0
        j 1f
        error:
        li a0, -1

    j 1f
    set_handbreak:

        li t6, base_carro
        sb a0, 0x22(t6)
        li a0, 0

    j 1f
    read_sensors: //a0 é o endereço de um vetor de 256 bytes 

        li t6, base_carro
        li t5, 1
        sb t5, 1(t6)
        2:
            lb t5, 1(t6)
        bne t5, zero, 2b

        addi t6, t6, 0x24 #apontamos t6 para a posição inicial do vetor MMIO
        li t4, 256
        li t3, 0 #variável de iteração do for
        2:

            lw t2, 0(t6) 
            sw t2, 0(a0) 
            addi a0, a0, 4
            addi t6, t6, 4
            addi t3, t3, 4

        blt t3, t4, 2b

    j 1f
    read_sensor_distance:
        
        li t6, base_carro
        li t5, 1
        sb t5, 2(t6)
        
        2:
            lb t5, 2(t6)
        bne t5, zero, 2b

        lw a0, 0x1c(t6)

    j 1f
    get_rotation:

        li t6, base_carro
        li t5, 1
        sb t5, 0(t6)
        
        2:
            lb t5, 0(t6)
        bne t5, zero, 2b

        lw t0, 0x4(t6)
        lw t1, 0x8(t6)
        lw t2, 0xc(t6)

        sw t0, 0(a0)
        sw t1, 0(a1)
        sw t2, 0(a2)

    j 1f
    read: #a0: file descriptor a1: buffer a2: size

        li t6, base_port
        li t4, 0 #variável de iteração. guarda o número de bytes lidos tb
        3:
            li t5, 1
            sb t5, 2(t6)

            2:
                lb t5, 2(t6)
            bne t5, zero, 2b

            lb t5, 3(t6)
            addi t4, t4, 1
            sb t5, 0(a1)

            li t0, '\n'
            beq t5, t0, 2f
            beq t5, zero, 2f

            addi a1, a1, 1
        
        blt t4, a2, 3b 
        2:

        mv a0, t4

    j 1f
    write: #a0: file descriptor a1: buffer a2: size
        li t6, base_port
        li t4, 0 #variável de iteração. guarda o número de bytes escritos tb
        3:

            lb t5, 0(a1)
            beq t5, zero, 2f
            sb t5, 1(t6)

            li t5, 1
            sb t5, 0(t6)

            2:
                lb t5, 0(t6)
            bne t5, zero, 2b

            addi a1, a1, 1
            addi t4, t4, 1
        
        blt t4, a2, 3b 
        2:

    j 1f
    draw_line: #a0 aponta para o vetor que deve ser printado no canva
        
        li t6, base_canvas
        li t4, 0
        li t3, 256
        2:

            #transforma-se grayscale em RGBA:
            lb t2, 0(a0) #lemos o byte relativo ao pixel que iremos printar
            li t1, 255 #t1 representará o byte em RGBA
            slli t1, t1, 8
            add t1, t1, t2
            slli t1, t1, 8
            add t1, t1, t2
            slli t1, t1, 8
            addi t1, t1, 255
            sw t2, 0x08(t6)
            
            #seta-se o tamanho do array que será colocado no canvas:
            li t5, 4
            sh t5, 0x02(t6)

            #seta a posição no canvas que iremos printar o pixel:
            li t5, 4
            mul t5, t5, t4
            sw t5, 0x04(t6)

            #chama o canvas para printar o pixel e espera terminar:
            li t5, 1
            sb t5, 0(t6)
            2:
                lb t5, 0(s0)
            bne t5, zero, 2b

            addi a0, a0, 1 #incremento a0 para ler o proximo byte para printar
            addi t4, t4, 1 #incrementa-se a variável de iteração
        blt t4, t3, 2b

    j 1f
    get_position:

        li t6, base_carro
        li t5, 1
        sb t5, 0(t6)
        
        2:
            lb t5, 0(t6)
        bne t5, zero, 2b

        mv t0, a0

        lw t0, 0x10(t6)
        lw t1, 0x14(t6)
        lw t2, 0x18(t6)

        sw t0, 0(a0)
        sw t1, 0(a1)
        sw t2, 0(a2)

    j 1f
    get_systime:

        li t6, base_gpt
        li t5, 1
        sb t5, 0(t6)
        
        2:
            lb t5, 0(t6)
        bne t5, zero, 2b

        lw a0, 4(t6)

    1:

    lw t6, 24(sp)
    lw t5, 20(sp)
    lw t4, 16(sp)
    lw t3, 12(sp)
    lw t2, 8(sp)
    lw t1, 4(sp)
    lw t0, 0(sp)

    addi sp, sp, 64 # Desaloca espaço da pilha
    csrrw sp, mscratch, sp # Troca sp com mscratch novamente
    csrr t0, mepc  # carrega endereço de retorno (endereço da instrução que invocou a syscall)
    addi t0, t0, 4 # soma 4 no endereço de retorno (para retornar após a ecall) 
    csrw mepc, t0  # armazena endereço de retorno de volta no mepc

mret # Recuperar o restante do contexto (pc <- mepc)

.globl _start
_start:

la t0, int_handler  # Carregar o endereço da rotina que tratará as interrupções
csrw mtvec, t0      # (e syscalls) em no registrador MTVEC para configurar o vetor de interrupções.

csrr t1, mstatus # Update the mstatus.MPP
li t2, ~0x1800 # field (bits 11 and 12)
and t1, t1, t2 # with value 00 (U-mode)
csrw mstatus, t1
la t0, main # Loads the user software
csrw mepc, t0 # entry point into mepc

li sp, 0x07FFFFFC
la t0, isr_stack_end
csrw mscratch, t0

mret # PC <= MEPC; mode <= M
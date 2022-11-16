.bss

.align 4
isr_stack: .skip 1024
isr_stack_end:

.data

.globl _system_time

_system_time: .word 0

.text

.set base_gpt, 0xFFFF0100
.set base_midi, 0xFFFF0300

.globl play_note
#void play_note(int ch, int inst, int note, int vel, int dur);
play_note:
    li t0, base_midi
    sb a0, 0(t0)
    sh a1, 2(t0)
    sb a2, 4(t0)
    sb a3, 5(t0)
    sb a4, 6(t0)
ret

#Deixei vazias as rotinas para int. internas e exceções. No futuro, eu poderia preenchê-las caso precisasse tratar coisas diferentes de int. externas

isr_interrupcao_interna:
ret

isr_excecao:
ret

isr_interrupcao_externa:
    #Faz com que o GPT gere uma interrupção em 100 ms
    li t0, 100
    li t1, base_gpt
    sw t0, 8(t1)

    #Incrementa o system time em 100 unidades
    la t0, _system_time
    lw t1, 0(t0)
    addi t1, t1, 100
    sw t1, 0(t0)
ret

.globl main_isr
main_isr:

    #Salva-se o contexto do programa no momento da interrupção:
    csrrw sp, mscratch, sp
    addi sp, sp, -124
    sw x1, 0(sp)
    sw x2, 4(sp)
    sw x3, 8(sp)
    sw x4, 12(sp)
    sw x5, 16(sp)
    sw x6, 20(sp)
    sw x7, 24(sp)
    sw x8, 28(sp)
    sw x9, 32(sp)
    sw x10, 36(sp)
    sw x11, 40(sp)
    sw x12, 44(sp)
    sw x13, 48(sp)
    sw x14, 52(sp)
    sw x15, 56(sp)
    sw x16, 60(sp)
    sw x17, 64(sp)
    sw x18, 68(sp)
    sw x19, 72(sp)
    sw x20, 76(sp)
    sw x21, 80(sp)
    sw x22, 84(sp)
    sw x23, 88(sp)
    sw x24, 92(sp)
    sw x25, 96(sp)
    sw x26, 100(sp)
    sw x27, 104(sp)
    sw x28, 108(sp)
    sw x29, 112(sp)
    sw x30, 116(sp)
    sw x31, 120(sp)

    # Trata a interrupção
    csrr a1, mcause # lê a causa da interrupção
    bgez a1, isr_excecao # Verifica se é exceção ou interrupção

    andi a1, a1, 0x3f # Isola a causa de interrupção
    li a2, 11 # a2 = interrupção externa
    bne a1, a2, isr_interrupcao_interna # desvia se não for interrupção externa

    #Agora trataremos a interrupção externa:

    jal isr_interrupcao_externa

    #Restaura o contexto:
    lw x1, 0(sp)
    lw x2, 4(sp)
    lw x3, 8(sp)
    lw x4, 12(sp)
    lw x5, 16(sp)
    lw x6, 20(sp)
    lw x7, 24(sp)
    lw x8, 28(sp)
    lw x9, 32(sp)
    lw x10, 36(sp)
    lw x11, 40(sp)
    lw x12, 44(sp)
    lw x13, 48(sp)
    lw x14, 52(sp)
    lw x15, 56(sp)
    lw x16, 60(sp)
    lw x17, 64(sp)
    lw x18, 68(sp)
    lw x19, 72(sp)
    lw x20, 76(sp)
    lw x21, 80(sp)
    lw x22, 84(sp)
    lw x23, 88(sp)
    lw x24, 92(sp)
    lw x25, 96(sp)
    lw x26, 100(sp)
    lw x27, 104(sp)
    lw x28, 108(sp)
    lw x29, 112(sp)
    lw x30, 116(sp)
    lw x31, 120(sp)
    addi sp, sp, 124
    csrrw sp, mscratch, sp

mret

.globl _start
_start:

#Estabelece qual é a ISR a ser usada
la t0, main_isr
csrw mtvec, t0

#Faz mscratch apontar para a base da pilha da ISR
la t0, isr_stack_end
csrw mscratch, t0

#Habilita interrupções externas
csrr t1, mie
li t2, 0x800
or t1, t1, t2
csrw mie, t1

# Habilita interrupções globais
csrr t1, mstatus
ori t1, t1, 0x8
csrw mstatus, t1

#Faz com que o GPT gere uma interrupção em 100 ms
li t0, 100
li t1, base_gpt
sw t0, 8(t1)

jal main
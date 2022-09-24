#include <fcntl.h>
#include <unistd.h>
#include <stdio.h> //remover futuramente
#define MAX_BYTES 110000
#define ELF32_ST_VISIBILITY(o) ((o)&0x3)

typedef struct
{
    unsigned char e_ident[16];  
    unsigned short e_type;       
    unsigned short e_machine;   
    unsigned int e_version;     
    unsigned int e_entry;       
    unsigned int e_phoff;       
    unsigned int e_shoff;       
    unsigned int e_flags;       
    unsigned short e_ehsize;    
    unsigned short e_phentsize; 
    unsigned short e_phnum;     
    unsigned short e_shentsize; 
    unsigned short e_shnum;   
    unsigned short e_shstrndx;  
} Elf32_Ehdr;

typedef struct
{
    unsigned int sh_name;    
    unsigned int sh_type;      
    unsigned int sh_flags;     
    unsigned int sh_addr;     
    unsigned int sh_offset;   
    unsigned int sh_size;     
    unsigned int sh_link;     
    unsigned int sh_info;     
    unsigned int sh_addralign;
    unsigned int sh_entsize;  
} Elf32_Shdr;

typedef struct
{
    unsigned int st_name;
    unsigned int st_value;
    unsigned int st_size;  
    unsigned char st_info; 
    unsigned char st_other;
    unsigned short st_shndx; 
} Elf32_Sym; //cada entrada da symbol table ocupa 16 bytes

int str_len(char * str) {
    int i = 0, len = 0;
    while (str[i] != '\0') {
        len++;
        i++;
    }
    return len;
}

void write_dec(int num) {
    char decimal_invertido[20], decimal[20];
    int i = 0, negativo = 0;
    if (num < 0) {
        negativo = 1;
    }
    if (num == 0) {
        write(1, "0", 1);
    }
    else {
        while (num != 0) {
            decimal_invertido[i] = '0' + num % 10;
            num /= 10;
            i++;
        }
        if (negativo) {
            decimal_invertido[i++] = '-';
        }
        for (int j=0; j<i; j++) {
            decimal[j] = decimal_invertido[i-j-1];
        }
        write(1, decimal, i);
    }
}

void write_hex_from_dec(int decimal, int mode) { //mode = 0: hex com 8 dígitos. mode = 1: hex compacto. mode = 2: hex com 2 digitos
    char hex_invertido[9], hex[9];
    int num_digits = 0;
    while (decimal != 0) {
        if (decimal % 16 >= 10) {
            hex_invertido[num_digits++] = 87 + decimal % 16;
        }
        else {
            hex_invertido[num_digits++] = '0' + decimal % 16;
        }
        decimal /= 16;
    }
    if (!mode) {
        while (num_digits < 8) {
            hex_invertido[num_digits++] = '0';
        }
    }
    if (mode == 2) {
        while (num_digits < 2) {
            hex_invertido[num_digits++] = '0';
        }
    }
    for (int j=0; j<num_digits; j++) {
        hex[j] = hex_invertido[num_digits - 1 - j];
    }
    write(1, hex, num_digits);
}

int str_compare(char * str1, char * str2) {
    if (str_len(str1) == str_len(str2)) {
        for (int i = 0; i < str_len(str1); i++) {
            if (str1[i] != str2[i]) {
                return 0;
            }
        }
        return 1;
    }
    return 0;
}

int pow2(int i) {
    int result = 1;
    for (int j = 0; j < i; j++) {
        result *= 2;
    }
    return result;
}

void write_register(int registrador) {
    switch (registrador) {
        case 0:
            write(1, "zero", 4);
            break;
        case 1:
            write(1, "ra", 2);
            break;
        case 2:
            write(1, "sp", 2);
            break;
        case 3:
            write(1, "gp", 2);
            break;
        case 4:
            write(1, "tp", 2);
            break;
        case 5:
            write(1, "t0", 2);
            break;
        case 6:
            write(1, "t1", 2);
            break;
        case 7:
            write(1, "t2", 2);
            break;
        case 8:
            write(1, "s0", 2);
            break;
        case 9:
            write(1, "s1", 2);
            break;
        case 10:
            write(1, "a0", 2);
            break;
        case 11:
            write(1, "a1", 2);
            break;
        case 12:
            write(1, "a2", 2);
            break;
        case 13:
            write(1, "a3", 2);
            break;
        case 14:
            write(1, "a4", 2);
            break;
        case 15:
            write(1, "a5", 2);
            break;
        case 16:
            write(1, "a7", 2);
            break;
        case 17:
            write(1, "a8", 2);
            break;
        case 18:
            write(1, "s2", 2);
            break;
        case 19:
            write(1, "s3", 2);
            break;
        case 20:
            write(1, "s4", 2);
            break;
        case 21:
            write(1, "s5", 2);
            break;
        case 22:
            write(1, "s6", 2);
            break;
        case 23:
            write(1, "s7", 2);
            break;
        case 24:
            write(1, "s8", 2);
            break;
        case 25:
            write(1, "s9", 2);
            break;
        case 26:
            write(1, "s10", 2);
            break;
        case 27:
            write(1, "s11", 2);
            break;
        case 28:
            write(1, "t3", 2);
            break;
        case 29:
            write(1, "t4", 2);
            break;
        case 30:
            write(1, "t5", 2);
            break;
        case 31:
            write(1, "t6", 2);
            break;
    }
}

int swap_Endians(int value)
{
 
    // This var holds the leftmost 8
    // bits of the output.
    int leftmost_byte;
 
    // This holds the left middle
    // 8 bits of the output
    int left_middle_byle;
 
    // This holds the right middle
    // 8 bits of the output
    int right_middle_byte;
 
    // This holds the rightmost
    // 8 bits of the output
    int rightmost_byte;
 
    // To store the result
    // after conversion
    int result;
 
    // Get the rightmost 8 bits of the number
    // by anding it 0x000000FF. since the last
    // 8 bits are all ones, the result will be the
    // rightmost 8 bits of the number. this will
    // be converted into the leftmost 8 bits for the
    // output (swapping)
    leftmost_byte = (value & 0x000000FF) >> 0;
 
    // Similarly, get the right middle and left
    // middle 8 bits which will become
    // the left_middle bits in the output
    left_middle_byle = (value & 0x0000FF00) >> 8;
 
    right_middle_byte = (value & 0x00FF0000) >> 16;
 
    // Get the leftmost 8 bits which will be the
    // rightmost 8 bits of the output
    rightmost_byte = (value & 0xFF000000) >> 24;
 
    // Left shift the 8 bits by 24
    // so that it is shifted to the
    // leftmost end
    leftmost_byte <<= 24;
 
    // Similarly, left shift by 16
    // so that it is in the left_middle
    // position. i.e, it starts at the
    // 9th bit from the left and ends at the
    // 16th bit from the left
    left_middle_byle <<= 16;
 
    right_middle_byte <<= 8;
 
    // The rightmost bit stays as it is
    // as it is in the correct position
    rightmost_byte <<= 0;
 
    // Result is the concatenation of all these values.
    result = (leftmost_byte | left_middle_byle |
              right_middle_byte | rightmost_byte);
 
    return result;
}

void write_instruction(int instruction) {
    char bin[33], first_7[8], digits_12_to_14[4];
    for (int i = 0; i < 32; i++) {
        bin[i] = '0' + ((instruction >> i) & 1); 
    }
    bin[32] = '\0';
    int rd = 0, rs1 = 0, rs2 = 0;
    for (int i = 0; i < 7; i++) {
        first_7[6-i] = bin[i]; //pela maneira com que escrevi as strings nos ifs abaixo, lemos first 7 dessa maneira
    }
    first_7[7] = '\0';
    for (int i = 0; i < 3; i++) {
        digits_12_to_14[i] = bin[12 + i];
    }
    digits_12_to_14[3] = '\0';
    for (int i = 0; i < 5; i++) {
        rd += pow2(i) * (bin[7+i] - '0');
        rs1 += pow2(i) * (bin[15+i] - '0');
        rs2 += pow2(i) * (bin[20+i] - '0');
    }
    int im3; //im3 representa os imediatos compostos pelos últimos 12 bits de bin
    im3 = ((instruction >> 20) & 0b111111111111);
    printf("%s\n", bin);
    if (str_compare(first_7, "0110111")) {
        write(1, "lui", 3);
        write(1, " ", 1);
        write_register(rd);
        write(1, ", ", 2);
    } else if (str_compare(first_7, "0010111")) {
        write(1, "auipc", 5);
        write(1, " ", 1);
        write_register(rd);
        write(1, ", ", 2);
    } else if (str_compare(first_7, "1101111")) {
        write(1, "jal", 3);
        write(1, " ", 1);
        write_register(rd);
        write(1, ", ", 2);
    } else if (str_compare(first_7, "1100111")) {
        write(1, "jalr", 4);
        write(1, " ", 1);
        write_register(rd);
        write(1, ", ", 2);
        write_register(rs1);
    } else if (str_compare(first_7, "1100011")) {
        if (str_compare(digits_12_to_14, "000")) {
            write(1, "beq", 3);
        } else if (str_compare(digits_12_to_14, "100")) {
            write(1, "bne", 3);
        } else if (str_compare(digits_12_to_14, "001")) {
            write(1, "blt", 3);
        } else if (str_compare(digits_12_to_14, "101")) {
            write(1, "bge", 3);
        } else if (str_compare(digits_12_to_14, "011")) {
            write(1, "bltu", 4);
        } else {
            write(1, "bgeu", 4);
        }
        write_register(rs1);
    } else if (str_compare(first_7, "0000011")) {
        if (str_compare(digits_12_to_14, "000")) {
            write(1, "lb", 2);
        } else if (str_compare(digits_12_to_14, "100")) {
            write(1, "lh", 2);
        } else if (str_compare(digits_12_to_14, "010")) {
            write(1, "lw", 2);
        } else if (str_compare(digits_12_to_14, "100")) {
            write(1, "lbu", 3);
        } else {
            write(1, "lhu", 3);
        }
        write(1, " ", 1);
        write_register(rd);
        write(1, ", ", 2);
        write_register(rs1);
        write(1, ", ", 2);
        write_dec(im3);
    } else if (str_compare(first_7, "0100011")) {
        if (str_compare(digits_12_to_14, "000")) {
            write(1, "sb", 2);
        } else if (str_compare(digits_12_to_14, "100")) {
            write(1, "sh", 2);
        } else {
            write(1, "sw", 2);
        }
        write_register(rs1);
    } else if (str_compare(first_7, "0010011")) {
        if (str_compare(digits_12_to_14, "000")) {
            write(1, "addi", 4);
        } else if (str_compare(digits_12_to_14, "010")) {
            write(1, "slti", 4);
        } else if (str_compare(digits_12_to_14, "110")) {
            write(1, "sltiu", 5);
        } else if (str_compare(digits_12_to_14, "001")) {
            write(1, "xori", 4);
        } else if (str_compare(digits_12_to_14, "011")) {
            write(1, "ori", 3);
        } else if (str_compare(digits_12_to_14, "111")) {
            write(1, "andi", 4);
        } else if (str_compare(digits_12_to_14, "100")) {
            write(1, "slli", 4);
        } else if (str_compare(digits_12_to_14, "101")) {
            if (bin[30] == '0') {
                write(1, "srli", 4);
            } else {
                write(1, "srai", 4);
            }
        }
        write(1, " ", 1);
        write_register(rd);
        write(1, ", ", 2);
        write_register(rs1);
    } else if (str_compare(first_7, "0110011")) {
        if (str_compare(digits_12_to_14, "000")) {
            if (bin[30] == '0') {
                write(1, "add", 3);
            } else {
                write(1, "sub", 3);
            }
        } else if (str_compare(digits_12_to_14, "100")) {
            write(1, "sll", 3);
        } else if (str_compare(digits_12_to_14, "010")) {
            write(1, "slt", 3);
        } else if (str_compare(digits_12_to_14, "110")) {
            write(1, "sltu", 4);
        } else if (str_compare(digits_12_to_14, "001")) {
            write(1, "xor", 3);
        } else if (str_compare(digits_12_to_14, "101")) {
            if (bin[30] == '0') {
                write(1, "srl", 3);
            } else {
                write(1, "sra", 3);
            }
        } else if (str_compare(digits_12_to_14, "011")) {
            write(1, "or", 2);
        } else {
            write(1, "and", 3);
        }
        write(1, " ", 1);
        write_register(rd);
        write(1, ", ", 2);
        write_register(rs1);
    } else if (str_compare(first_7, "0001111")) {
        if (str_compare(digits_12_to_14, "000")) {
            write(1, "fence", 5);
        } else {
            write(1, "fence.i", 7);
        }
    } else if (str_compare(first_7, "1110011")) {
        if (str_compare(digits_12_to_14, "000")) {
            if (bin[20] == '0') {
                write(1, "ecall", 5);
            }
            else {
                write(1, "ebreak", 6);
            }
        } else if (str_compare(digits_12_to_14, "100")) {
            write(1, "csrrw", 5);
        } else if (str_compare(digits_12_to_14, "010")) {
            write(1, "csrrs", 5);
        } else if (str_compare(digits_12_to_14, "110")) {
            write(1, "csrrc", 5);
        } else if (str_compare(digits_12_to_14, "101")) {
            write(1, "csrrwi", 6);
        } else if (str_compare(digits_12_to_14, "110")) {
            write(1, "csrrsi", 6);
        } else {
            write(1, "csrrci", 6);
        }
        write(1, " ", 1);
        write_register(rd);
        if (str_compare(digits_12_to_14, "100") || str_compare(digits_12_to_14, "010") || str_compare(digits_12_to_14, "110")) {
            write(1, ", ", 2);
            write_register(rs1);
        }
    } else {
        write(1, "<unknown>", 9);
    }
}

int main(int argc, char *argv[]) {
    
    char elf[MAX_BYTES]; 
    int file = open(argv[2], O_RDONLY);
    read(file, elf, MAX_BYTES);

    Elf32_Ehdr * p_file_header = (Elf32_Ehdr *) &elf; //ponteiro para a file header com endereço inicial dado como o do início do elf
    Elf32_Shdr * section_headers = (Elf32_Shdr *) &elf[p_file_header->e_shoff]; //ponteiro para a primeira das section headers
    int shstrtab_offset = section_headers[p_file_header->e_shstrndx].sh_offset; //offset da shstrtab
    char * name; //ponteiro para o caractere de inicio do nome de uma section
    
    int symtab_index, strtab_index, symtab_size;
    for (int i = 0;i < p_file_header->e_shnum; i++) {
        name = &elf[shstrtab_offset + section_headers[i].sh_name];
        if (str_compare(name, ".symtab")) {
            symtab_index = i;
        }
        if (str_compare(name, ".strtab")) {
            strtab_index = i;
        }
    }
    Elf32_Sym * symtab = (Elf32_Sym *) &elf[section_headers[symtab_index].sh_offset]; //ponteiro que aponta para a symbol table
    symtab_size = section_headers[symtab_index].sh_size / 16;
    char * symbol_name;
    char * strtab = &elf[section_headers[strtab_index].sh_offset]; //ponteiro que aponta para a string table da symbol table

    write(1, "\n", 1);
    write(1, argv[2], str_len(argv[2]));
    write(1, ": file format elf32-littleriscv\n", 32);
    write(1, "\n", 1);

    if (argv[1][1] == 'd') { //Dissasembly of section .text
        write(1, "\n", 1);
        write(1, "Disassembly of section .text:", 29);
        write(1, "\n", 1);
        int text_index, size;
        for (int i = 0;i < p_file_header->e_shnum; i++) {
            name = &elf[shstrtab_offset + section_headers[i].sh_name];
            if (str_compare(name, ".text")) {
                text_index = i;
            }
        } 
        size = section_headers[text_index].sh_size;
        int adress;
        unsigned char hex_byte;
        unsigned int hex_number;
        unsigned int * instruction;
        for (int i = 0; i < size; i+=4) {
            adress = i + section_headers[text_index].sh_addr;  
            instruction = (unsigned int *) &elf[section_headers[text_index].sh_offset + i];
            for (int j = 0; j < symtab_size; j++) {
                if (adress == symtab[j].st_value) {
                    symbol_name = &strtab[symtab[j].st_name];   
                    write(1, "\n", 1);
                    write_hex_from_dec(adress, 0);
                    write(1, " <", 2);
                    write(1, symbol_name, str_len(symbol_name));
                    write(1, ">:\n", 3);
                    break;
                }
            }  
            write(1, "   ", 3);
            write_hex_from_dec(adress, 1);
            write(1, ": ", 2);
            for (int j = 0; j < 4; j++) {
                hex_byte = elf[i + section_headers[text_index].sh_offset + j]; //hex_byte guarda um byte que será escrito como hexadecimal
                hex_number = (unsigned int) hex_byte;
                write_hex_from_dec(hex_number, 2);
                write(1, " ", 1);
            }
            write_instruction(*instruction);
            write(1, "\n", 1);
        }

    } else if (argv[1][1] == 't') {
        write(1, "SYMBOL TABLE:\n", 14);
        char binding[2];
        for (int i = 1; i < symtab_size; i++) { //consideramos que a primeira linha da symtab é nula
            write_hex_from_dec(symtab[i].st_value,0);
            write(1, " ", 1);
            binding[0] = symtab[i].st_info >> 4 ? 'g' : 'l';
            binding[1] = '\0';
            write(1, binding, 1);
            write(1, " ", 1);
            if (symtab[i].st_shndx < p_file_header->e_shnum) {
                name = &elf[shstrtab_offset + section_headers[symtab[i].st_shndx].sh_name];
                write(1, name, str_len(name));
            }
            else {
                write(1, "*ABS*", 5);
            }
            write(1, " ", 1);
            write_hex_from_dec(symtab[i].st_size, 0);
            write(1, " ", 1);
            symbol_name = &strtab[symtab[i].st_name];
            write(1, symbol_name, str_len(symbol_name));
            write(1, "\n", 1);
        }

    } else { //h
        unsigned int size;
        unsigned int vma;
        write(1, "Sections:\n", 10);
        write(1, "Idx Name Size VMA\n", 18);
        for (int i = 0; i < p_file_header->e_shnum; i++) {
            name = &elf[shstrtab_offset + section_headers[i].sh_name]; //pega automaticamente a string inteira até \0
            size = section_headers[i].sh_size; //type punning
            vma = section_headers[i].sh_addr;
            write_dec(i);
            write(1, " ", 1);
            write(1, name, str_len(name));
            write(1, " ", 1);
            write_hex_from_dec(size, 0);
            write(1, " ", 1);
            write_hex_from_dec(vma, 0);
            write(1, "\n", 1);
        }
        write(1, "\n", 1);
    }
}
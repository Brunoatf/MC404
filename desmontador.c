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
    char st_other;
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
    int i = 0;
    if (num == 0) {
        write(0, "0", 1);
    }
    else {
        while (num != 0) {
            decimal_invertido[i] = '0' + num % 10;
            num /= 10;
            i++;
        }
        for (int j=0; j<i; j++) {
            decimal[j] = decimal_invertido[i-j-1];
        }
        write(0, decimal, i);
    }
}

void write_hex_from_dec(int decimal) {
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
    while (num_digits < 8) {
        hex_invertido[num_digits++] = '0';
    }
    for (int j=0; j<num_digits; j++) {
        hex[j] = hex_invertido[num_digits - 1 - j];
    }
    write(0, hex, 8);
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

int main(int argc, char *argv[]) {
    
    char elf[MAX_BYTES]; 
    int file = open(argv[2], O_RDONLY);
    read(file, elf, MAX_BYTES);

    Elf32_Ehdr * p_file_header = (Elf32_Ehdr *) &elf; //ponteiro para a file header com endereço inicial dado como o do início do elf
    Elf32_Shdr * section_headers = (Elf32_Shdr *) &elf[p_file_header->e_shoff]; //ponteiro para a primeira das section headers
    int shstrtab_offset = section_headers[p_file_header->e_shstrndx].sh_offset; //offset da shstrtab
    char * name; //ponteiro para o caractere de inicio do nome de uma section

    if (argv[1][1] == 'd') { //Dissasembly of section .text
        
    } else if (argv[1][1] == 't') {
        int symtab_index, strtab_index, symtab_size;
        write(0, "SYMBOL TABLE:\n", 14);
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
        char * strtab = &elf[section_headers[strtab_index].sh_offset]; //ponteiro que aponta para a string table da symbol table
        char * symbol_name;
        char binding[2];
        symtab_size = section_headers[symtab_index].sh_size / 16;
        for (int i = 1; i < symtab_size; i++) { //consideramos que a primeira linha da symtab é nula
            write_hex_from_dec(symtab[i].st_value);
            write(0, " ", 1);
            binding[0] = symtab[i].st_info >> 4 ? 'g' : 'l';
            binding[1] = '\0';
            write(0, binding, 1);
            write(0, " ", 1);
            write_hex_from_dec(symtab[i].st_size);
            write(0, " ", 1);
            symbol_name = &strtab[symtab[i].st_name];
            write(0, symbol_name, str_len(symbol_name));
            write(0, "\n", 1);
        }

    } else { //h
        unsigned int size;
        unsigned int vma;
        write(0, "Sections:\n", 10);
        write(0, "Idx Name Size VMA Type\n", 24);
        for (int i = 0; i < p_file_header->e_shnum; i++) {
            name = &elf[shstrtab_offset + section_headers[i].sh_name]; //pega automaticamente a string inteira até \0
            size = section_headers[i].sh_size; //type punning
            vma = section_headers[i].sh_addr;
            write(0, "  ", 2);
            write_dec(i);
            write(0, " ", 2);
            write(0, name, str_len(name));
            write(0, " ", 1);
            write_hex_from_dec(size);
            write(0, " ", 1);
            write_hex_from_dec(vma);
            write(0, "\n", 1);
        }
    }
}
int read(int __fd, const void *__buf, int __n){
  int bytes;
  __asm__ __volatile__(
    "mv a0, %1           # file descriptor\n"
    "mv a1, %2           # buffer \n"
    "mv a2, %3           # size \n"
    "li a7, 63           # syscall read (63) \n"
    "ecall \n"
    "mv %0, a0"
    : "=r"(bytes)  // Output list
    :"r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
  return bytes;
}
 
void write(int __fd, const void *__buf, int __n){
  __asm__ __volatile__(
    "mv a0, %0           # file descriptor\n"
    "mv a1, %1           # buffer \n"
    "mv a2, %2           # size \n"
    "li a7, 64           # syscall write (64) \n"
    "ecall"
    :   // Output list
    :"r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
}

char checkbase(char str[20]) {
    if (str[1] == 'x') {
        return 'h'; //hexadecimal
    }
    else if (str[0] == '-') {
        return 'n'; //decimal negativo
    }
    else return 'd'; //decimal positivo
}

int pow(int x, int y) {
    int result = 1;
    for (int i=0; i<y; i++) {
        result =* x;
    }
    return result;
}

int hex_to_decimal(char str[20]) {
    int decimal = 0;
    int i = 19;
    while (str[i] != 'x') {
        decimal += pow(16, i-19) * (str[i] - '0');
        i--;
    }
    return decimal;
}

void decimal_to_binario(int decimal) {
    char binario[34];
    binario[0] = '0';
    binario[1] = 'b';
    char binarioInvertido;
    if (decimal > 0) {
        int i = 0;
        while (decimal != 0) {
            binarioInvertido[i] = decimal % 2;
            decimal =/ 2;
        }
        for (int i=0; i<32; i++) {
            binario[i+2] = binarioInvertido[31-i];
        }
    }
    write(1, binario, n);
}
 
int main() {
    char str[20];
    char binario[34];
    int decimal;
    int n = read(0, str, 20);
    char type = checkbase(str);
    if (type == 'h') {
        decimal = hex_to_decimal(str);
        decimal_to_binario(decimal); //printa o numero em binario
    }
    else if (type == 'd') {
        decimal_to_binario(str);
    }
    else {

    }
    write(1, str, n);
    return 0;
}
 
void _start(){
    main();
}

#include <stdio.h>
#define sys main(int argc, char* argv[]){
#define import void
#define len(a) }
#define first_var FILE * fil
#define second_var int c
#define ord(a) 1;
#define open(a) fopen(argv[1], "r");
#define print(a) if(fil) {while ((c = getc(fil)) != EOF) {putchar(c);} fclose(fil); }
import sys
first_var = open(sys.argv[1])
second_var = ord("a")
print(first_var.read())
len("")
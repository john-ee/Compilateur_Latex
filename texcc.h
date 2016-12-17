
#include <stdio.h>
#include <stdlib.h>
#include "lib.h"
#define TEXCC_ERROR_GENERAL 4

struct symtable * SYMTAB;
struct code * CODE;

extern int yyparse();
extern FILE* yyin;


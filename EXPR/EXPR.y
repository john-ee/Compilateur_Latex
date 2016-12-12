
%{

#include "EXPRc.h"

extern void yyerror(const char * s);
extern int yylex();

%}

%union {
    long int intval;
    name_t strval;
    struct {
        struct symbol * ptr;
    } exprval;
}

%token PRINT SEMICOLON PLUS MINUS MULT ASSIGN OPAR CPAR
%token <strval> ID
%token <intval> NUM

%left PLUS MINUS
%left MULT
%nonassoc UMINUS

%type <exprval> expr

%start instrlist

%%

instrlist 
: instr SEMICOLON instrlist
| instr
;

instr 
: ID ASSIGN expr
  {    
    struct symbol * id = symtable_get(SYMTAB,$1);
    if ( id == NULL )
        id = symtable_put(SYMTAB,$1);
    gencode(CODE,COPY,id,$3.ptr,NULL);
  }
| PRINT ID
  {
    struct symbol * id = symtable_get(SYMTAB,$2);
    if ( id == NULL )
    {
        fprintf(stderr,"Name '%s' undeclared\n",$2);
        exit(1);
    }
    gencode(CODE,CALL_PRINT,id,NULL,NULL);
  }
;

expr
: expr PLUS expr
  { 
     $$.ptr = newtemp(SYMTAB);
     gencode(CODE,BOP_PLUS,$$.ptr,$1.ptr,$3.ptr); 
  }
| expr MINUS expr
  { 
     $$.ptr = newtemp(SYMTAB);
     gencode(CODE,BOP_MINUS,$$.ptr,$1.ptr,$3.ptr); 
  }
| expr MULT expr
  { 
     $$.ptr = newtemp(SYMTAB);
     gencode(CODE,BOP_MULT,$$.ptr,$1.ptr,$3.ptr); 
  }
| MINUS expr %prec UMINUS
  { 
     $$.ptr = newtemp(SYMTAB);
     gencode(CODE,UOP_MINUS,$$.ptr,$2.ptr,NULL); 
  }
| OPAR expr CPAR
  { 
     $$.ptr = $2.ptr;
  }
| ID
  { 
    struct symbol * id = symtable_get(SYMTAB,$1);
    if ( id == NULL )
    {
        fprintf(stderr,"Name '%s' undeclared\n",$1);
        exit(1);
    }
    $$.ptr = id;
  }
| NUM
  { 
    $$.ptr = symtable_const(SYMTAB,$1);
  }
;

%%

void yyerror(const char * s)
{
    fprintf(stderr,"%s\n",s);
}


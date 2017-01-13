%{
  #include <stdio.h>
  #include <stdlib.h>
  #include "texcc.h"

  extern void yyerror(const char * s);

  // Functions and global variables provided by Lex.
  int yylex();
  extern int yylineno;
  %}

%union {
  char* value;
  char* name;
  char* string;
  struct {
      struct symbol * ptr;
  } exprval;  
}
%left FOIS
%token TEXSCI_BEGIN TEXSCI_END BLANKLINE RETOUR
%token CONSTANTE INPUT OUTPUT GLOBAL LOCAL MBOX EMPTY
%token INTEGER BOOLEAN LEFTARROW IN
%token <value> INT BOOL
%token PLUS FOIS MINUS
%token PRINTINT PRINTTEXT
%token <string> STRING
%token <name> ID 

%type <exprval> expr_e expr_t expr_f

%%

algorithm_list:
    algorithm_list algorithm
  | algorithm
  ;

algorithm:
    TEXSCI_BEGIN '{' ID '}' declarations BLANKLINE liste_instructions TEXSCI_END
    {
      fprintf(stderr, "[texcc] info: algorithm \"%s\" parsed\n", $3);
      free($3);
    }
  ;

liste_instructions:
    liste_instructions instruction
  | instruction
  ;

instruction:
     '$' ID LEFTARROW expr_e '$' RETOUR
    {
      struct symbol * id = symtable_get(SYMTAB,$2);
      if ( id == NULL )
      {
        fprintf(stderr, "line %d: semantic error \n", yylineno);
        exit(3);
      }
      gencode(CODE,COPY,id,$4.ptr,NULL);
    }
  | '$' MBOX '{' print '}' '$' RETOUR
  |
  ;

print:
     PRINTINT '(' '$' ID '$' ')'
    {
      struct symbol * id = symtable_get(SYMTAB,$4);
      if ( id == NULL )
      {
        fprintf(stderr, "line %d: semantic error \n", yylineno);
        exit(3);
      }
      gencode(CODE,CALL_PRINT,id,NULL,NULL);
    }

  | PRINTTEXT '(' '$'  STRING  '$' ')'
    {
      put_print(out, $4, SYMTAB);
      char nom[10];
      sprintf(nom, "msg%d", SYMTAB->msg-1);
      symtable_put(SYMTAB, nom);
      struct symbol * id = symtable_get(SYMTAB,nom);
      gencode(CODE,CALL_PRINT_TEXT,id,NULL,NULL);
    }
  |
  ;

expr_e:
    expr_t
  | expr_t PLUS expr_e
    {
      $$.ptr = newtemp(SYMTAB);
      gencode(CODE,BOP_PLUS,$$.ptr,$1.ptr,$3.ptr);
    }

  | expr_t MINUS expr_e
    {
      $$.ptr = newtemp(SYMTAB);
      gencode(CODE,BOP_MINUS,$$.ptr,$1.ptr,$3.ptr);
    }
  ;

expr_t:
    expr_f
  | expr_t FOIS expr_f
    {
      $$.ptr = newtemp(SYMTAB);
      gencode(CODE,BOP_MULT,$$.ptr,$1.ptr,$3.ptr);
    }

expr_f:
    INT
    {
      $$.ptr = symtable_const(SYMTAB, $1);
    }

  | BOOL
    {
      $$.ptr = symtable_const(SYMTAB, $1);
    }

  | ID
    { 
      struct symbol * id = symtable_get(SYMTAB,$1);
      if ( id == NULL )
      {
        fprintf(stderr, "line %d: semantic error \n", yylineno);
        exit(3);
      }
      $$.ptr = id;
    }
  ;



declarations:
   liste_constant liste_input liste_output liste_global liste_local
  ;

liste_constant:
    CONSTANTE '{' '$' liste_declarations '$' '}'
  | CONSTANTE '{' '$' EMPTY '$' '}'
  |
  ;

liste_input:
    INPUT '{' '$' liste_declarations '$' '}'
  | INPUT '{' '$' EMPTY '$' '}'
  |
  ;

liste_output:
    OUTPUT '{' '$' liste_declarations '$' '}'
  | OUTPUT '{' '$' EMPTY '$' '}'
  |
  ;

liste_global:
    GLOBAL '{' '$' liste_declarations '$' '}'
  | GLOBAL '{' '$' EMPTY '$' '}'
  |
  ;

liste_local:
    LOCAL '{' '$' liste_declarations '$' '}'
  | LOCAL '{' '$' EMPTY '$' '}'
  |
  ;

liste_declarations:
    liste_declarations ',' declaration
  | declaration
  ;

declaration:
    ID IN type
    {
      struct symbol * id = symtable_get(SYMTAB,$1);
      if ( id == NULL ) {
        id = symtable_put(SYMTAB,$1);
        put_integer_id(out, $1);
      }
      else
      {
        fprintf(stderr, "line %d: semantic error \n", yylineno);
        exit(3);
      }
    }

  ;

type:
    INTEGER

  | BOOLEAN

  ;


%%
void yyerror(const char * s)
{
  char error[] = "syntax error";
  fprintf(stderr, "line %d: %s \n", yylineno, s);
  if(strcmp (error,s) == 0)
    exit(2);
  else
    exit(4);
}

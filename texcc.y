%{
  #include <stdio.h>
  #include <stdlib.h>
  #include "texcc.h"

  extern void yyerror(const char * s);

  // Functions and global variables provided by Lex.
  int yylex();
  %}

%union {
  char* value;
  char* name;
  char* string;
  struct {
      struct symbol * ptr;
  } exprval;  
}

%token TEXSCI_BEGIN TEXSCI_END BLANKLINE RETOUR
%token INPUT OUTPUT LOCAL MBOX
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
    {
      printf("Liste d'instructions 1\n");
    }

  | instruction
    {
      printf("Liste d'instructions 2\n");
    }
  ;

instruction:
     '$' ID LEFTARROW expr_e '$' RETOUR
    {
      printf("Affectation expression arithmetique\n");
      struct symbol * id = symtable_get(SYMTAB,$2);
      if ( id == NULL )
          id = symtable_put(SYMTAB,$2);
      gencode(CODE,COPY,id,$4.ptr,NULL);
    }
  | '$' MBOX '{' print '}' '$' RETOUR
   {
      printf("Appel de la fonction d'affichage\n");
   }

  |
  ;

print:
     PRINTINT '(' '$' ID '$' ')'
    {
      printf("affichage entier \n");
      struct symbol * id = symtable_get(SYMTAB,$4);
      if ( id == NULL )
      {
          fprintf(stderr,"Name '%s' undeclared\n",$4);
          exit(1);
      }
      gencode(CODE,CALL_PRINT,id,NULL,NULL);
    }

  | PRINTTEXT '(' '$'  STRING  '$' ')'
    {
      printf("affichage d'un string \n");
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
    {
      printf("Expression arithmétique\n");
    }

  | expr_t PLUS expr_e
    {
      printf("Addition\n");
      $$.ptr = newtemp(SYMTAB);
      gencode(CODE,BOP_PLUS,$$.ptr,$1.ptr,$3.ptr);
    }

  | expr_t MINUS expr_e
    {
      printf("Soustraction\n");
      $$.ptr = newtemp(SYMTAB);
      gencode(CODE,BOP_MINUS,$$.ptr,$1.ptr,$3.ptr);
    }
  ;

expr_t:
    expr_f
    {
      printf("Expression arithmétique\n");
    }

  | expr_t FOIS expr_f
    {
      printf("Multiplication\n");
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

  | '(' expr_e ')'
    {
      printf("Affectation\n");
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
  ;



declarations:
    liste_input liste_output liste_local
  ;

liste_input:
    INPUT '{' '$' liste_declarations '$' '}'
    {
      printf("REGLE INPUT\n");
    }

  |
  ;

liste_output:
    OUTPUT '{' '$' liste_declarations '$' '}'
    {
      printf("REGLE OUPUT\n");
      
    }

  |
  ;

liste_local:
    LOCAL '{' '$' liste_declarations '$' '}'
    {
      printf("REGLE LOCAL\n");
    }

  |
  ;

liste_declarations:
    liste_declarations ',' declaration
    {
      printf("REGLE LISTE DECLARATION\n");
    }

  | declaration
    {
      printf("SECONDE REGLE DECLARATION\n");
    }
  ;

declaration:
    ID IN type
    {
      printf("REGLE DECLARATION\n");
      struct symbol * id = symtable_get(SYMTAB,$1);
      if ( id == NULL ) {
        id = symtable_put(SYMTAB,$1);
        put_integer_id(out, $1);
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
    fprintf(stderr,"%s\n",s);
}

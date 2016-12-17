%{
  #include <stdio.h>
  #include <stdlib.h>
  #include "texcc.h"

 extern void yyerror(const char * s);

  // Functions and global variables provided by Lex.
  int yylex();
  void texcc_lexer_free();
  %}

%union {
  int ivalue;
  float fvalue;
  char* name;
  char* string;
}

%token TEXSCI_BEGIN TEXSCI_END BLANKLINE RETOUR
%token INPUT OUTPUT LOCAL MBOX
%token INTEGER BOOLEAN REAL LEFTARROW IN
%token INT BOOL FLOAT
%token PLUS FOIS
%token PRINTINT PRINTTEXT
%token <string> STRING
%token <name> ID 

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
    }

  | PRINTTEXT '(' '$'  STRING  '$' ')'
    {
      printf("affichage d'un string \n");

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
    }


expr_f:
    valeur
    {
      printf("Affectation\n");
    }

  | '(' expr_e ')'
    {
      printf("Affectation\n");
    }

  | ID
  ;

valeur:
    INT

  | BOOL

  | FLOAT

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
    }

  ;

type:
    INTEGER

  | REAL

  | BOOLEAN

  ;


%%
void yyerror(const char * s)
{
    fprintf(stderr,"%s\n",s);
}

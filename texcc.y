%{
  #include <stdio.h>
  #include <stdlib.h>
  #define TEXCC_ERROR_GENERAL 4

  void yyerror(char*);

  // Functions and global variables provided by Lex.
  int yylex();
  void texcc_lexer_free();
  extern FILE* yyin;
%}

%union {
  int ivalue;
  float fvalue;
  char* name;
}

%token TEXSCI_BEGIN TEXSCI_END BLANKLINE
%token INPUT OUTPUT LOCAL
%token INTEGER BOOLEAN REAL LEFTARROW IN
%token INT BOOL FLOAT
%token PLUS FOIS AFFECTATION
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
      printf("Liste d'instructions\n");
    }

  | instruction
    {
      printf("Liste d'instructions\n");
    }
  ;

instruction:
    expr_e
    {
      printf("Expression arithmétique\n");
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
  ;

valeur:
    INT

  | BOOL

  | FLOAT

  ;



declarations:
    liste_input liste_output liste_local

  |
  
  ;

liste_input:
    INPUT '{' '$' liste_declarations '$' '}'
  ;

liste_output:
    OUTPUT '{' '$' liste_declarations '$' '}'
  ;

liste_local:
    LOCAL '{' '$' liste_declarations '$' '}'
  ;

liste_declarations:
    liste_declarations declaration

  | declaration
  ;

declaration:
    ID IN type

  ;

type:
    INTEGER

  | REAL

  | BOOLEAN

  ;


%%

int main(int argc, char* argv[]) {
  if (argc == 2) {
    if ((yyin = fopen(argv[1], "r")) == NULL) {
      fprintf(stderr, "[texcc] error: unable to open file %s\n", argv[1]);
      exit(TEXCC_ERROR_GENERAL);
    }
  } else {
    fprintf(stderr, "[texcc] usage: %s input_file\n", argv[0]);
    exit(TEXCC_ERROR_GENERAL);
  }

  yyparse();
  fclose(yyin);
  texcc_lexer_free();
  return EXIT_SUCCESS;
}

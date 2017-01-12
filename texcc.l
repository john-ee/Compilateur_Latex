%{
  #include <stdlib.h>
  #include <string.h>
  #include "y.tab.h"
  #include "lib.h"
%}

%s texsci
%option yylineno

begin     "\\begin{texsci}"
end       "\\end{texsci}"
blankline "\\BlankLine"
input     "\\Input"
output    "\\Output"
local     "\\Local"
mbox      "\\mbox"

integer   "\\Integer"
boolean   "\\Boolean"

leftarrow "\\leftarrow"
in        "\\in"

printint "printInt"
printtext "printText"

id        [a-zA-Z_][a-zA-Z0-9_]*
int       -?[0-9]+
bool      "\\true"|"\\false"

dollar    "$"
retour    "\\;"

string \"(\\.|[^"])*\" 

%%

{begin}             { BEGIN(texsci);   // Start TexSci scanning mode
                      return TEXSCI_BEGIN;
                    }

<texsci>{end}       { BEGIN(INITIAL); // Reset to default scanning mode
                      return TEXSCI_END;
                    }

<texsci>{blankline} { printf("BLANKLINE"); return BLANKLINE; }

<texsci>[{}]        { return yytext[0]; }

<texsci>[()]        { return yytext[0]; }

[\n]                { }
[ ]                { }

<texsci>{input}     { printf("INPUT");  return INPUT; }

<texsci>{output}    { printf("OUTPUT");  return OUTPUT; }

<texsci>{local}     { printf("LOCAL"); return LOCAL; }

<texsci>{integer}   { printf("INTEGER");  return INTEGER; }

<texsci>{boolean}   { printf("BOOLEAN");  return BOOLEAN; }

<texsci>{leftarrow} { printf("LEFTARROW"); return LEFTARROW; }

<texsci>{in}        { printf("IN");  return IN; }

<texsci>{dollar}   { return yytext[0]; }

<texsci>{retour}   { return RETOUR; }

<texsci>[+]        { return PLUS; }

<texsci>[-]        { return MINUS; }

<texsci>[*]        { return FOIS; }

<texsci>{mbox}     { return MBOX; }

<texsci>{printint} { return PRINTINT; }

<texsci>{printtext} { return PRINTTEXT; }

<texsci>[,]        { return yytext[0]; }

<texsci>{id}        { yylval.name = strdup(yytext);
                      return ID;
                    }

<texsci>{int}       {
                      printf("INT ");
                      yylval.value = strdup(yytext);
                      return INT;
                    }

<texsci>{bool}      {
                      printf("BOOL ");
                      if(strcmp(yytext, "\\true") == 0)
                        {
                          yylval.value = "1";
                        }
                         else
                        {
                          yylval.value = "0";
                        }
                      return BOOL;
                    }

<texsci>{string}    {
                      yylval.string = strdup(yytext);
                      return STRING; 
                    }

<texsci>.        { fprintf(stderr, "line:%d: lexical error \n",yylineno); exit(1);}
.                  { }

%%

/*
 * texcc_lexer_free function:
 * this function frees the memory allocated for the lexer. It frees
 * flex's buffer (it supposes there is only one buffer) since flex does
 * never free it itself.
 */
void texcc_lexer_free() {
  yy_delete_buffer(YY_CURRENT_BUFFER);
  free(yy_buffer_stack);
}

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
constant  "\\Constant"
input     "\\Input"
output    "\\Output"
global    "\\Global"
local     "\\Local"
mbox      "\\mbox"

integer   "\\Integer"
boolean   "\\Boolean"
emptyset  "\\emptyset"

leftarrow "\\leftarrow"
egal      "="
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

<texsci>{blankline} { return BLANKLINE; }

<texsci>[{}]        { return yytext[0]; }

<texsci>[()]        { return yytext[0]; }

[\n]                { }
[ ]                 { }

<texsci>{constant}  { return CONSTANTE; }

<texsci>{input}     { return INPUT; }

<texsci>{output}    { return OUTPUT; }

<texsci>{global}    { return GLOBAL; }

<texsci>{local}     { return LOCAL; }

<texsci>{integer}   { return INTEGER; }

<texsci>{boolean}   { return BOOLEAN; }

<texsci>{emptyset}   { return EMPTY; }

<texsci>{leftarrow} { return LEFTARROW; }

<texsci>{egal}      { return EGAL; }

<texsci>{in}        { return IN; }

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
                      yylval.value = strdup(yytext);
                      return INT;
                    }

<texsci>{bool}      {
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

<texsci>.        { fprintf(stderr, "line %d: lexical error [%s] \n",yylineno,yytext); exit(1);}
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

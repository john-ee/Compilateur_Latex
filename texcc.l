%{
  #include <stdlib.h>
  #include <string.h>
  #include "y.tab.h"
%}

%s texsci

begin     "\\begin{texsci}"
end       "\\end{texsci}"
blankline "\\BlankLine"
input     "\\Input"
output    "\\Output"
local     "\\Local"

integer   "\\Integer"
boolean   "\\Boolean"
real      "\\Real"

leftarrow "\\leftarrow"
in        "\\in"

id        [a-zA-Z_][a-zA-Z0-9_]*
int       [0-9]+
float     [0-9]+.[0-9]+
bool      "\\true"|"\\false"

%%

{begin}             { BEGIN(texsci);   // Start TexSci scanning mode
                      return TEXSCI_BEGIN;
                    }
<texsci>{end}       { BEGIN(INITIAL); // Reset to default scanning mode
                      return TEXSCI_END;
		    }
<texsci>{id}        { yylval.name = strdup(yytext);
                      return ID;
                    }
<texsci>{blankline} { return BLANKLINE; }
<texsci>[{}]        { return yytext[0]; }
[\n]                { }
.                   { }

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

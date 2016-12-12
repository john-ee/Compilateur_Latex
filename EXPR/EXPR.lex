
%{
#include "lib.h"
#include "EXPR.tab.h"
%}

%option nounput
%option noyywrap

%%

"print" return PRINT;
"=" return ASSIGN;
";" return SEMICOLON;

"+" return PLUS;
"-" return MINUS;
"*" return MULT;

"(" return OPAR;
")" return CPAR;

[[:alpha:]][[:alnum:]]* {
    if ( yyleng > 7 )
        fprintf(stderr,"Identifier '%s' too long, truncated\n",yytext);
    strncpy(yylval.strval,yytext,7);
    yylval.strval[7] = '\0';
    return ID;
}
0|[1-9][0-9]*|0[0-7]+|0x[0-9a-fA-F]+ {
    sscanf(yytext,"%li",&(yylval.intval));
    return NUM;
}

[[:space:]] ;

. fprintf(stderr,"Warning: char %d ignored\n",yytext[0]);

%%

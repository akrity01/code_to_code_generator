%{
#include "codegen.tab.h"
#include <string.h>
#include <stdlib.h>
%}

%%
"print"     { return PRINT; }
"if"        { return IF; }
"then"      { return THEN; }
"else"      { return ELSE; }
"end"       { return END; }
"while"     { return WHILE; }
"for"       { return FOR; }
"to"        { return TO; }
"=="        { return EQ; }
"int"       { yylval.str = strdup("int"); return TYPE; }
"float"     { yylval.str = strdup("float"); return TYPE; }
"char"      { yylval.str = strdup("char"); return TYPE; }
"string"    { yylval.str = strdup("string"); return TYPE; }
"="         { return '='; }
"+"         { return '+'; }
"-"         { return '-'; }
"*"         { return '*'; }
"/"         { return '/'; }
">"         { return '>'; }
"<"         { return '<'; }
\"[^\"]*\"    { yylval.str = strdup(yytext); return STRING; }
[0-9]+\.[0-9]+ { yylval.str = strdup(yytext); return NUMBER; }
[0-9]+         { yylval.str = strdup(yytext); return NUMBER; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.str = strdup(yytext); return ID; }
[ \t\n]+     { /* skip whitespace */ }
.             { return yytext[0]; }
%%

int yywrap(){
return 1;
}
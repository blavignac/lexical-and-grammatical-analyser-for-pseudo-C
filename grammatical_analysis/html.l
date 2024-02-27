%option noyywrap
%option noinput
%option nounput

%{
#include "html.tab.h"
%}

%%

"<div>"   { return tDIV; }
"</div>"  { return tCDIV; }
"<span>"  { return tSPAN; }
"</span>" { return tCSPAN; }
[a-z]*    { yylval.s = strdup(yytext); return tTEXT; }

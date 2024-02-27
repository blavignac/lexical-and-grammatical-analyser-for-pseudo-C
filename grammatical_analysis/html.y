%{
#include <stdio.h>
#include <stdlib.h>
%}

%code provides {
  int yylex (void);
  void yyerror (const char *);
}

%union { char *s; }

%token <s> tTEXT
%token tDIV tCDIV tSPAN tCSPAN

%%

divs:
    %empty
  | divs tDIV divs tCDIV { printf("get a div\n"); }
  | spans
  ;

spans:
    tTEXT { printf("get a text: '%s'\n", $1); }
  | spans tSPAN spans tCSPAN { printf("get a span\n"); }
  ;

%%

void yyerror(const char *msg) {
  fprintf(stderr, "error: %s\n", msg);
  exit(1);
}

int main(void) {
  yyparse();
}

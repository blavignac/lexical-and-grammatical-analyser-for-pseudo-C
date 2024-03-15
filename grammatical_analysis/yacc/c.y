%{
    #include <stdio.h>
    #include <stdlib.h>
    int yylex (void);
    void yyerror (const char *);
%}

%code provides {
  int yylex (void);
  void yyerror (const char *);
}

%union { char name[32]; int val;}

%token tMUL tVOID tEQ tAMPER tMAIN tSEMI tLPAR tRPAR tRBRACE tLBRACE tADD tCOMMA tINT tSUB tELSE tDIV tIF tAND tNE tGT tGE tLT tLE tOR tWHILE tRETURN tASSIGN tNOT tERROR tPRINT
%token <name> tID
%token <val> tNB

%%


main:
        type tMAIN tLPAR tVOID tRPAR block {printf("main fonction\n");}
;

type:
        tINT
    |   tVOID
;

block:
        tLBRACE expression_list tRBRACE
;

expression_list:
      %empty
    | expression expression_list
    ;

expression:
        var_dec
    |   assign
    |   if
    |   sys_fonc_call
;

sys_fonc_call:
    tPRINT tLPAR value tRPAR tSEMI {printf("printf fonction call with arg ");}
;

assign:
        tID tASSIGN arithmetic tSEMI {printf("var assign %s \n",$1);}
;

var_dec:
        tINT tID tSEMI {printf("var dec: %s;\n",$2);}
    |   tINT tID tASSIGN arithmetic tSEMI {printf("var dec: %s;\n",$2);}
;

arithmetic_operator:
      tADD {printf("+\n");}
    | tMUL {printf("*\n");}
    | tSUB {printf("-\n");}
    | tDIV {printf("DIV\n");}
;

arithmetic:
        value   
    |   arithmetic arithmetic_operator arithmetic 
;

value:
        tID {printf("%s\n",$1);}
    |   tNB {printf("%d\n",$1);}
;

if:
        tIF tLPAR condition tRPAR block {printf("IF\n");}
;

bool_operator:
        tEQ {printf("==\n");}
    |   tNE {printf("!=\n");}
    |   tGT {printf(">\n");}
    |   tGE {printf(">=\n");}
    |   tLT {printf("<\n");}
    |   tLE {printf("<=\n");}
    |   tAND {printf("AND\n");}
    |   tOR {printf("OR\n");}
    |   tNOT {printf("NOT\n");}
;

bool:
        value 
    |   bool bool_operator bool
    |   tNOT bool {printf("NOT\n");}
;

condition:
        bool
    ;

%%

void yyerror(const char *msg) {
  fprintf(stderr, "error: %s\n", msg);
  exit(1);
}

int main(void) {
  yyparse();
}
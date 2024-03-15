%{
    #include <stdio.h>
    #include <stdlib.h>
    void yyerror (const char *);    
    extern int yylineno;
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

program:
        statement_list  
;

statement_list:
        %empty
    |   statement statement_list
;

statement:
        var_dec
    |   func_dec
    |   main
;

func_dec:
        tINT tID tLPAR param_list tRPAR block  {printf("$ line no: %d -- function %s declared $\n", yylineno,$2);}
;

param_list:
        %empty 
    |   param
    |   param tCOMMA param_list
;

param:
        type tID
;

main:
        type tMAIN tLPAR tVOID tRPAR block  {printf("$ line no: %d -- main function $\n", yylineno);}
;

type:
        tINT    {printf("$ line no: %d -- int $\n", yylineno);}
    |   tVOID   {printf("$ line no: %d -- void $\n", yylineno);}
;

block:
        tLBRACE expression_list tRBRACE
;

expression_list:
        %empty
    |   expression expression_list
;

return:
        tRETURN arithmetic tSEMI    {printf("$ line no: %d -- return $\n", yylineno);}
    |   tRETURN bool tSEMI          {printf("$ line no: %d -- return $\n", yylineno);}
;

expression:
        var_dec
    |   assign
    |   if
    |   if_else
    |   while
    |   sys_fonc_call
    |   return
;

sys_fonc_call:
        tPRINT tLPAR arithmetic tRPAR tSEMI {printf("$ line no: %d -- printf fonction call $\n", yylineno);}
;

func_call:
        tID tLPAR func_call_param_list tRPAR  {printf("$ line no: %d -- %s fonction call $\n", yylineno, $1);}
;

func_call_param_list:
        %empty 
    |   func_call_param
    |   func_call_param tCOMMA func_call_param_list
;

func_call_param:
        tID
    |   arithmetic
;

assign:
        tID tASSIGN arithmetic tSEMI {printf("$ line no: %d -- var assign: %s $\n", yylineno,$1);}
;

id_list:
        %empty
    |   tCOMMA tID id_list
;

var_dec:
        tINT tID id_list tSEMI {printf("$ line no: %d -- var dec: %s $\n", yylineno,$2);}
    |   tINT tID id_list tASSIGN arithmetic tSEMI {printf("$ line no: %d -- var dec: %s $\n", yylineno,$2);}
;

arithmetic_operator:
        tADD {printf("$ line no: %d -- add $\n", yylineno);}
    |   tMUL {printf("$ line no: %d -- mul $\n", yylineno);}
    |   tSUB {printf("$ line no: %d -- sub $\n", yylineno);}
    |   tDIV {printf("$ line no: %d -- div $\n", yylineno);}
;

while:
        tWHILE tLPAR condition tRPAR block {printf("$ line no: %d -- while $\n", yylineno);}
;

arithmetic:
        value   
    |   arithmetic arithmetic_operator arithmetic 
;

value:
        tID         {printf("$ line no: %d -- val: %s $\n", yylineno,$1);}
    |   tNB         {printf("$ line no: %d -- num: %d $\n", yylineno,$1);}
    |   func_call   
;

if:
        tIF tLPAR condition tRPAR block {printf("$ line no: %d -- if $\n", yylineno);}
;

if_else:
        tIF tLPAR condition tRPAR block tELSE block {printf("$ line no: %d -- if_else $\n", yylineno);}
;

bool_operator:
        tEQ {printf("$ line no: %d -- eq $\n", yylineno);}
    |   tNE {printf("$ line no: %d -- ne $\n", yylineno);}
    |   tGT {printf("$ line no: %d -- gt $\n", yylineno);}
    |   tGE {printf("$ line no: %d -- ge $\n", yylineno);}
    |   tLT {printf("$ line no: %d -- lt $\n", yylineno);}
    |   tLE {printf("$ line no: %d -- le $\n", yylineno);}
    |   tAND{printf("$ line no: %d -- and $\n", yylineno);}
    |   tOR {printf("$ line no: %d -- or $\n", yylineno);}
    |   tNOT {printf("$ line no: %d -- not $\n", yylineno);}
;

bool:
        value 
    |   bool bool_operator bool
    |   tNOT bool
;

condition:
        bool
;

%%

void yyerror(const char *msg) {
  fprintf(stderr, "error on line %d: %s\n", yylineno, msg);
  exit(1);
}

int main(void) {
  yyparse();
}
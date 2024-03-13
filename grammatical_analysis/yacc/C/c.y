%{
    #include <stdio.h>
    #include <stdlib.h>
    int yylex (void);
    void yyerror (const char *);
%}

%union { char *name; int val;}

%token tMUL tVOID tEQ tAMPER tSEMI tLPAR tRPAR tRBRACE tLBRACE tADD tCOMMA tINT tSUB tELSE tDIV tIF 
%token <name> tID
%token <val> tNB


%%

type:
      tINT
    | tVOID
    ;

program:
      %empty
    | statement_list
    ;

statement_list:
      statement
    | statement statement_list
    ;

statement:
      var_dec
    | func_dec
    ;

var_dec:
      type tMUL tID tSEMI 
    | type tMUL tID tEQ tID tSEMI
    | tINT tID tSEMI {}
    | tINT tID tEQ tNB tSEMI {}
    ;


func_dec:
      tVOID tID tLPAR func_param tRPAR block tSEMI
    ;


func_param:
      %empty
    | tVOID
    | param
    ;

param:
      type tID tCOMMA param
    | type tID
    ;

block:
      tLBRACE expression_list tRBRACE
    ;

expression_list:
      %empty
    | expression expression_list
    ;

expression:
    t_expression
    | if
    | if_else
    ;

t_expression:
    | var_dec 
    | arithmetic
    ;


arithmetic:
      value tADD value
    | value tMUL value
    | value tSUB value
    | value tDIV value
    ;

value:
      tID
    | tNB
    ;

if_else:
      tIF tLPAR condition tRPAR block tELSE block
    | tIF tLPAR condition tRPAR t_expression tELSE block
    ;

if:
      tIF tLPAR condition tRPAR block
    ;

condition:
    ;
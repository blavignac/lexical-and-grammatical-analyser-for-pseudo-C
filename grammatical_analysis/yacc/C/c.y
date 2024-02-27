%{
    #include <stdio.h>
    #include <stdlib.h>
    int yylex (void);
    void yyerror (const char *);
%}

%%

program:
      %empty
    | statement_list

statement_list:
      statement
    | statement statement_list

statement:
    | var_dec
    | fonc_dec

var_dec:
    | tVOID tMUL tID;
    | tVOID tMUL tID tEQ ;


tINT
tID: 'a'
tSEMI
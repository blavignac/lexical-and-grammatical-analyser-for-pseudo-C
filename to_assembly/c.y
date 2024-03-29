%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "manip.h"
    void yyerror (const char *);    
    extern int yylineno;
    table * symbol_table;
    table * temp_table;
%}

%code provides {
    int yylex (void);
    void yyerror (const char *);
}

%union { char name[32]; int val;}

%token tMUL tVOID tEQ tAMPER tMAIN tSEMI tLPAR tRPAR tRBRACE tLBRACE tADD tCOMMA tINT tSUB tELSE tDIV tIF tAND tNE tGT tGE tLT tLE tOR tWHILE tRETURN tASSIGN tNOT tERROR tPRINT
%token <name> tID
%token <val> tNB

%left tLT tGT tEQ tNE tLE tGE
%left tADD tSUB
%left tMUL tDIV


%%

program:
        statement_list  
;

statement_list:
        %empty
    |   statement statement_list
;

statement:
        func_dec
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
        type tMAIN tLPAR tVOID tRPAR block  {}
;

type:
        tINT    {printf("$ line no: %d -- int $\n", yylineno);}
    |   tVOID   {printf("$ line no: %d -- void $\n", yylineno);}
;

block:
        tLBRACE expression_list tRBRACE
				{
					printf("$ assembly jump if condition not verified: %d -- jump: $\n", yylineno);
				}
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
        tID tASSIGN arithmetic tSEMI {
					printf("$ line no: %d -- var assign assembly instruction: $", yylineno);
					table_entry * entry = lookup(symbol_table,$1);
					if (entry == NULL) {
						printf("erreur : variable non déclarée\n");
					}
					table_entry * value = pop(temp_table);

					if(value == NULL) {
						printf("erreur expression assign\n\n");
					}

					if(value->entry_type == constant) {
						printf("AFC %s #%d\n",entry->entry_name,value->entry_value);
					}
					else if(value->entry_type == var) {
						printf("AFC %s %s\n",entry->entry_name,value->entry_name);
					}

					entry->entry_value = value->entry_value;
				}
;

dec_id: 
        tID {
                printf("$ line no: %d -- var declaration assembly instruction: ", yylineno);
                table_entry entry;
                strncpy(entry.entry_name, $1, 16);
                entry.entry_type = var;
                push(symbol_table,entry); 
								printf("LDR %s =%p \n", $1, &(lookup(symbol_table,$1)->entry_value));
        }
;

id_list:
        %empty
    |   tCOMMA dec_id id_list
;

var_dec:
        tINT dec_id id_list tSEMI {}
;


while:
        tWHILE tLPAR condition tRPAR block {printf("$ line no: %d -- while $\n", yylineno);}
;

arithmetic:  
        arithmetic tADD arithmetic {
					table_entry * val1 = pop(temp_table);
					table_entry * val2 = pop(temp_table);
					if (val2 == NULL || val1 == NULL) {
						printf("erreur val2 null\n");
					}
					table_entry result;


					printf("$ line no: %d -- addition assembly instruction : ADD %p %p\n",yylineno,&(val1->entry_value),&(val2->entry_value));

					val1->entry_value = val1->entry_value + val2->entry_value;
					val1->entry_type=var;
					strncpy(val1->entry_name,"res_addition",16);
					printf("$ line no: %d -- resultat addition dans : %p\n",yylineno, &(val1->entry_value));
					
					push(temp_table,*val1);
				}
    |   arithmetic tMUL arithmetic 
    |   arithmetic tSUB arithmetic
    |   arithmetic tDIV arithmetic
    |   value 
;

value:
        tID         { 
											table_entry * entry = lookup(symbol_table,$1);
											push(temp_table,*entry);
											printf("$ line no: %d -- assembly known value %s added in temporary : %p $\n",yylineno, entry->entry_name, &(top(temp_table)->entry_value));
											
										}
    |   tNB         {
											table_entry entry;
											entry.entry_value = $1;
											entry.entry_type = constant;
											push(temp_table,entry);
											printf("$ line no: %d -- assembly affectation temporary number: AFC %p %d $\n",yylineno, &(top(temp_table)->entry_value),$1);
											
										}
    |   func_call   
;

if:
        tIF tLPAR condition tRPAR block {printf("$ line no: %d -- if $\n", yylineno);}
;

if_else:
        tIF tLPAR condition tRPAR block tELSE block {printf("$ line no: %d -- if_else $\n", yylineno);}
;

bool:
        value 
    |   bool tEQ bool {
												table_entry * val1 = pop(temp_table);
												table_entry * val2 = pop(temp_table);
												printf("$ line no: %d -- assembly condition equal : cmp %p %p $\n",yylineno,&(val1->entry_value),&(val2->entry_value));
												printf("$ line no: %d -- assembly condition equal : BEQ jump $\n",yylineno);
											}
    |   bool tNE bool
    |   bool tGT bool
    |   bool tGE bool
    |   bool tLT bool
    |   bool tLE bool
    |   bool tAND bool
    |   bool tOR bool
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
  symbol_table = init_table();
  temp_table = init_table();
  yyparse();
  table_print(symbol_table);

}
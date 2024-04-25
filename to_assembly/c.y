%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "manip.h"
    long asm_line_no = 0;
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

main:
        type tMAIN tLPAR tVOID tRPAR block  {}
;

type:
        tINT    {}
    |   tVOID   {}
;

block:
        tLBRACE expression_list tRBRACE
;

id_list:
        %empty
    |   tCOMMA dec_id id_list
;

dec_id: 
        tID {   
                int var_exists = lookup(symbol_table,$1);
		if (var_exists != -1) {
			printf("%d: error : variable already declared with that name %s\n", yylineno, $1);
		}
                table_entry entry;
                strncpy(entry.entry_name, $1, 16);
                entry.entry_type = var;
		printf("%d: AFC %i 0 \n",yylineno, symbol_table->current_index);
                push(symbol_table,entry); 
        }
;

var_dec:
        tINT dec_id id_list tSEMI {}
;

var_dec_assign_arith:
        tINT tID tASSIGN arithmetic tSEMI{
                                        int var_exists = lookup(symbol_table,$2);
                                        if (var_exists != -1) {
                                                printf("%d: error : variable already declared with that name %s\n",yylineno, $2);
                                        }

                                        table_entry entry;
                                        strncpy(entry.entry_name, $2, 16);
                                        entry.entry_type = var;
                                        push(symbol_table,entry); 
		                        printf("%d: AFC %i 0 \n", yylineno, symbol_table->current_index);
                                        printf("%d: COP %d %d\n", yylineno, symbol_table->current_index, top_index_temp(temp_table));
                                        table_entry * value = pop(temp_table);
        }

/* assign:
        tID tASSIGN tNB tSEMI {
					int entry = lookup(symbol_table,$1);
					if (entry == -1) {
						printf("%d: erreur : variable non déclarée\n", yylineno);
					}
					

					printf("%d: AFC %d %d\n",yylineno,  entry, $3);
				}
; */

assign_arith:
        tID tASSIGN arithmetic tSEMI {
					int entry = lookup(symbol_table,$1);
					if (entry == -1) {
						printf("%d: erreur : variable non déclarée\n",yylineno);
					}
					

					printf("%d: COP %d %d\n", yylineno, entry, top_index_temp(temp_table));
                                        table_entry * value = pop(temp_table);
				}
;

/* assign_val:
        tID tASSIGN tID tSEMI {

                                        int var = lookup(symbol_table,$3);
					if (var == -1) {
						printf("%d: error: variable %s not declared\n", yylineno, $3);
					}

					int entry = lookup(symbol_table,$1);
					if (entry == -1) {
						printf("%d: error: variable %s not declared\n", yylineno, $1);
					}
					

					printf("%d: COP %d %d\n", yylineno, entry, var);
				}
; */

arithmetic:  
        arithmetic tADD arithmetic {
					int i1 = top_index_temp(temp_table);
                                        int i2 = top_index_temp(temp_table) - 1;
                                        pop(temp_table);
                                        printf("%d: ADD (%d) (%d) (%d)\n", yylineno, i2, i2, i1);
				}
    |   arithmetic tMUL arithmetic {
					int i1 = top_index_temp(temp_table);
                                        int i2 = top_index_temp(temp_table) - 1;
                                        pop(temp_table);
                                        printf("%d: MUL (%d) (%d) (%d)\n", yylineno, i2, i2, i1);
				}
    |   arithmetic tSUB arithmetic {
					int i1 = top_index_temp(temp_table);
                                        int i2 = top_index_temp(temp_table) - 1;
                                        pop(temp_table);
                                        printf("%d: SUB (%d) (%d) (%d)\n", yylineno, i2, i2, i1);
				}
    |   arithmetic tDIV arithmetic {
					int i1 = top_index_temp(temp_table);
                                        int i2 = top_index_temp(temp_table) - 1;
                                        pop(temp_table);
                                        printf("%d: DIV (%d) (%d) (%d)\n", yylineno, i2, i2, i1);
				}
    |   value 
;

value:
        tID    { 
                        	int entry = lookup(symbol_table,$1);
                        	push(temp_table, symbol_table->data[entry]);
                                int i = top_index_temp(temp_table);
                                printf("%d: COP %d %d\n",yylineno ,i , entry);

                }
    |   tNB    {
	 			table_entry entry;
				push(temp_table,entry);
                                int i = top_index_temp(temp_table);
                                printf("%d: AFC %d %d\n", yylineno, i,$1);
				
		}
    |   func_call   
;

if:
        tIF tLPAR condition tRPAR block {}
;

if_else:
        tIF tLPAR condition tRPAR block tELSE block {printf("%d:-- if_else $\n",yylineno);}
;


while:
        tWHILE tLPAR condition tRPAR block {}
;

func_dec:
        tINT tID tLPAR param_list tRPAR block  {}
;

param:
        type tID
;

param_list:
        %empty 
    |   param
    |   param tCOMMA param_list
;

expression_list:
        %empty
    |   expression expression_list
;

return:
        tRETURN arithmetic tSEMI    {}
    |   tRETURN bool tSEMI          {}
;

expression:
        var_dec
    |   var_dec_assign_arith
    /* |   assign */
    |   assign_arith
    /* |   assign_val */
    |   if
    |   if_else
    |   while
    |   sys_fonc_call
    |   return
;

sys_fonc_call:
        tPRINT tLPAR arithmetic tRPAR tSEMI {}
;

func_call:
        tID tLPAR func_call_param_list tRPAR  {}
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






bool:
        value 
    |   bool tEQ bool  {

                                        int i1 = top_index_temp(temp_table);
                                        int i2 = top_index_temp(temp_table) - 1;
                                        pop(temp_table);
                                        printf("%d: EQ %d %d %d\n", yylineno,i2, i2, i1);
			}
    |   bool tNE bool  {

                                        int i1 = top_index_temp(temp_table);
                                        int i2 = top_index_temp(temp_table) - 1;
                                        pop(temp_table);
                                        printf("%d: EQ %d %d %d\n", yylineno,i2, i2, i1);
                                        printf("%d: NOT  %d %d\n", yylineno,i2, i2);

			}
    |   bool tGT bool   {

                                        int i1 = top_index_temp(temp_table);
                                        int i2 = top_index_temp(temp_table) - 1;
                                        pop(temp_table);
                                        printf("%d: SUP  %d %d %d\n", yylineno,i2, i2, i1);
			}
    |   bool tLT bool   {

                                        int i1 = top_index_temp(temp_table);
                                        int i2 = top_index_temp(temp_table) - 1;
                                        pop(temp_table);
                                        printf("%d: INF  %d %d %d\n", yylineno,i2, i2, i1);
			}
    |   bool tGE bool   {               
                                        table_entry entry;
				        push(temp_table,entry);
                                        table_entry entry1;
				        push(temp_table,entry1);
                                        int i1 = top_index_temp(temp_table);
                                        int i2 = top_index_temp(temp_table) - 1;
                                        int i3 = top_index_temp(temp_table) - 2;
                                        int i4 = top_index_temp(temp_table) - 3;
                                        printf("%d: SUP  %d %d %d\n", yylineno,i1, i3, i4);
                                        printf("%d: EQ %d %d %d\n", yylineno,i2, i3, i4);
                                        printf("%d: AND  %d %d %d\n", yylineno,i4, i2, i1);
                                        pop(temp_table);
                                        pop(temp_table);
                                        pop(temp_table);
                        }
    |   bool tLE bool   {
                                        table_entry entry;
				        push(temp_table,entry);
                                        table_entry entry1;
				        push(temp_table,entry1);
                                        int i1 = top_index_temp(temp_table);
                                        int i2 = top_index_temp(temp_table) - 1;
                                        int i3 = top_index_temp(temp_table) - 2;
                                        int i4 = top_index_temp(temp_table) - 3;
                                        printf("%d: INF  %d %d %d\n", yylineno,i1, i3, i4);
                                        printf("%d: EQ %d %d %d\n", yylineno,i2, i3, i4);
                                        printf("%d: AND  %d %d %d\n", yylineno,i4, i2, i1);
                                        pop(temp_table);
                                        pop(temp_table);
                                        pop(temp_table);
                        }
    |   bool tAND bool  {
                                      int i1 = top_index_temp(temp_table);
                                      int i2 = top_index_temp(temp_table) - 1;
                                      pop(temp_table);
                                      printf("%d: AND  %d %d %d\n", yylineno,i2, i2, i1);  
                        }
    |   bool tOR bool   {
                                      int i1 = top_index_temp(temp_table);
                                      int i2 = top_index_temp(temp_table) - 1;
                                      pop(temp_table);
                                      printf("%d: OR  %d %d %d\n", yylineno,i2, i2, i1);  
                        }
    |   tNOT bool       {
                                        int i1 = top_index_temp(temp_table);
                                        printf("%d: NOT  %d %d\n", yylineno,i1, i1);
                        }
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
  FILE* fp = fopen("asm.txt", "w");
  yyparse();
  table_print(symbol_table);

}
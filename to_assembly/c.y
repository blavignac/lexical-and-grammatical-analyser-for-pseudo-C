%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "manip.h"
    #define INSTRUCTION_SIZE 128
    long asm_line_no = 0;
    void yyerror (const char *);    
    extern int yylineno;
    table * symbol_table;
    table * func_table;
    int depth = 0;
    
    FILE* fptr ;

    typedef struct instruction_list{
        int max_instructions;
        int current_index;
        char ** instructions;
    } instruction_list;
    
    instruction_list * inst_list;

    instruction_list * get_instruction_list(int max_ins){
        instruction_list* t =  (instruction_list *)malloc(sizeof(instruction_list));
        t->current_index = 0;
        t->max_instructions=max_ins;
        t->instructions = (char**)malloc(sizeof(char*)*max_ins);
        return t;
    }

    char * add_instruction(instruction_list * list){
        char* inst = (char *)calloc(INSTRUCTION_SIZE,sizeof(char));
        int index = list->current_index;
        list->instructions[index] = inst;
        list->current_index++;
        return list->instructions[index];
    }

    void fill_jmf_instruction(instruction_list * list, int jmp){
        for(int i = list->current_index -1; i > 0; i--){
                char str[]=".jmf";
                if(strncmp(list->instructions[i],str,4) == 0){
                        snprintf(list->instructions[i],INSTRUCTION_SIZE,"JMF %d %d\n",symbol_table->current_index, jmp);
                        
                }
        }
    }

    int fun(instruction_list * list, int jmp){
        for(int i = list->current_index -1; i > 0; i--){
                char str[]=".jmf";
                if(strncmp(list->instructions[i],str,4) == 0){
                        char ** end;
                        int addr = atoi(list->instructions[i]+4);
                        snprintf(list->instructions[i],INSTRUCTION_SIZE,"JMF %d %d\n", addr, jmp);
                        return addr;
                }
        }
    }

    int fill_while_instruction(instruction_list * list, int jmp){
        for(int i = list->current_index -1; i > 0; i--){
                char str[]=".while";
                if(strncmp(list->instructions[i],str,6) == 0){
                        char ** end;
                        int addr = atoi(list->instructions[i]+6);
                        snprintf(list->instructions[i],INSTRUCTION_SIZE,"JMF %d %d\n",addr, jmp);
                        return addr;
                }
        }
    }

    int fill_jmp_instruction(instruction_list * list, int jmp){
        for(int i = list->current_index -1; i > 0; i--){
                char str[]=".jmp";
                if(strncmp(list->instructions[i],str,4) == 0){
                        char ** end;
                        int addr = atoi(list->instructions[i]+4);
                        snprintf(list->instructions[i],INSTRUCTION_SIZE,"JMP %d\n", jmp);
                        return addr;
                }
        }
    }

    void fill_main_instruction(instruction_list * list, int jmp){
        for(int i = list->current_index -1; i >= 0; i--){
                char str[]=".main";
                if(strncmp(list->instructions[i],str,5) == 0){
                        snprintf(list->instructions[i],INSTRUCTION_SIZE,"JMP %d\n", jmp);
                }
        }
    }

    void write_to_file(FILE * fptr, instruction_list * list){
        for(int i = 0; i < list->current_index; i++){
                fprintf(fptr, "%s", list->instructions[i]);
        }
    }
%}

%code provides {
    int yylex (void);
    void yyerror (const char *);
}

%union { char name[32]; int val; int line;}

%token tMUL tVOID tEQ tAMPER tMAIN tSEMI tIF tLPAR tRPAR tRBRACE tLBRACE tADD tCOMMA tINT tSUB tELSE tDIV tAND tNE tGT tGE tLT tLE tOR tRETURN tASSIGN tNOT tERROR tPRINT
%token <name> tID
%token <val> tNB
%token <line> tWHILE


%nonassoc tELSE
%left tCOMMA
%right tASSIGN 
%left tOR
%left tAND
%left tEQ
%left tLT tGT tNE tLE tGE
%left tADD tSUB
%left tMUL tDIV
%left tNOT tAMPER 
%left tLPAR
%right tRPAR


%%
program:
        {snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,".main\n");} statement_list 
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
        type tMAIN {
                fill_main_instruction(inst_list,inst_list->current_index+2);
                snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"\n");
                snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,".main\n");
                symbol_table->current_index = 0;
                symbol_table->current_index = 0;
                depth = 0;
        } tLPAR tVOID tRPAR main_block  {}
;

func_dec:
        tINT tID {
                snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"\n");
                snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,".%s\n",  $2);
                printf("%s",$2);

                int var_exists = lookup(func_table,depth,$2);
		if (var_exists != -1) {
			snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"error  line %d: function with this name already declared%s\n", yylineno, $2);
		}
                table_entry entry;
                strncpy(entry.entry_name, $2, 16);
                entry.val = inst_list->current_index;
                push(func_table,entry); 

                symbol_table->current_index = 0;
                symbol_table->current_index = 0;

        } tLPAR {
                table_entry entry;
                table_entry entry1;
                strncpy(entry1.entry_name, "return_val", 16);
                strncpy(entry.entry_name, "return_addr", 16);
                entry.val = depth;
                entry1.val = depth;

                push(symbol_table,entry);
                push(symbol_table,entry1);  
        } param_list tRPAR block  {

        }
;

param_list:
        %empty 
    |   param
    |   param tCOMMA param_list
;

param:
        type tID {
                int var_exists = lookup(symbol_table,depth,$2);
		if (var_exists != -1) {
			snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"error  line %d: function parameter already has that name %s\n", yylineno, $2);
		}
                table_entry entry;
                strncpy(entry.entry_name, $2, 16);
                entry.val = depth;
                push(symbol_table,entry); 
        }
;


func_call:
        tID tLPAR func_call_param_list tRPAR  {}
;



final:
        arithmetic
    |   bool
;

type:
        tINT    {}
    |   tVOID   {}
;

block:
        tLBRACE expression_list tRBRACE {}
;
main_block:
        tLBRACE expression_list tRBRACE
;


func_call_param_list: 
        func_call_param
    |   func_call_param tCOMMA func_call_param_list
;

func_call_param:
        %empty
    |   final
;
id_list:
        %empty
    |   tCOMMA dec_id id_list
;

dec_id: 
        tID {   
                int var_exists = lookup(symbol_table,depth,$1);
		if (var_exists != -1) {
			snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"error line %d: variable already declared with that name %s\n", yylineno, $1);
		}
                table_entry entry;
                strncpy(entry.entry_name, $1, 16);
                entry.val = depth;
		snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"AFC %i 0\n", symbol_table->current_index);
                push(symbol_table,entry); 
        }
;

var_dec:
        tINT dec_id id_list tSEMI {}
;

var_dec_assign_arith:
        tINT tID tASSIGN {
                int var_exists = lookup(symbol_table,depth,$2);
                if (var_exists != -1) {
                        snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"error line %d: variable already declared with that name %s\n",yylineno, $2);
                }
                table_entry entry;
                strncpy(entry.entry_name, $2, 16);
                entry.val = depth;
                snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"AFC %i 0\n",  symbol_table->current_index);
                push(symbol_table,entry); 
        } arithmetic tSEMI{
                pop(symbol_table);
                snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"COP %d %d\n",  symbol_table->current_index-1, symbol_table->current_index);
                
        }



assign_arith:
        tID tASSIGN arithmetic tSEMI {
					int entry = lookup(symbol_table,depth,$1);
					if (entry == -1) {
						snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"%d: erreur : variable non déclarée\n",yylineno);
					}
                                        pop(symbol_table);
					snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"COP %d %d\n", entry, symbol_table->current_index);
				}
;


arithmetic:  
    
        arithmetic tADD arithmetic {    
                pop(symbol_table);
                int i1 = symbol_table->current_index;
                int i2 = symbol_table->current_index - 1;

                snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"ADD %d %d %d\n", i2, i2, i1);
                }
    |   arithmetic tMUL arithmetic {
                pop(symbol_table);
                int i1 = symbol_table->current_index;
                int i2 = symbol_table->current_index - 1;
                snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"MUL %d %d %d\n", i2, i2, i1);
        }
    |   arithmetic tSUB arithmetic {
                pop(symbol_table);
                int i1 = symbol_table->current_index;
                int i2 = symbol_table->current_index - 1;
                snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"SUB %d %d %d\n",  i2, i2, i1);
        }
    |   arithmetic tDIV arithmetic {
                pop(symbol_table);
                int i1 = symbol_table->current_index;
                int i2 = symbol_table->current_index - 1;
                snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"DIV %d %d %d\n",  i2, i2, i1);
        }
    |   value 
    
;

value:
        func_call 
     |   tID    { 
                        	int entry = lookup(symbol_table,depth,$1);
                                int i = symbol_table->current_index;
                                push(symbol_table, symbol_table->data[entry]);
                                snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"COP %d %d\n",i , entry);

                }
    |   tNB    {
	 			table_entry entry;
                                int i = symbol_table->current_index;
                                push(symbol_table,entry);
                                snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"AFC %d %d\n",  i,$1);
				
		}
      
;

expression:
        var_dec
    |   var_dec_assign_arith
    |   assign_arith
    |   branch  
    |   while
    |   sys_fonc_call
    |   return
;


branch:
        if {
                symbol_table->current_index = fun(inst_list,inst_list->current_index);
                }
    |   if_else {}
;

condition:
        bool
;


if:
        tIF tLPAR condition tRPAR {
                snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,".jmf %d\n", symbol_table->current_index-1);
                pop(symbol_table);
        } block 
;

if_else:
        if {    symbol_table->current_index = fun(inst_list,inst_list->current_index+1);
                snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,".jmp %d\n", symbol_table->current_index);
        } tELSE block { 
                symbol_table->current_index = fill_jmp_instruction(inst_list,inst_list->current_index);
        } 
;



while:
        tWHILE tLPAR {
                $1 = inst_list->current_index;
        } condition {
                snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,".while %d\n", symbol_table->current_index-1);
                pop(symbol_table);
        } tRPAR block {
                symbol_table->current_index = fill_while_instruction(inst_list,inst_list->current_index+1);
                snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"JMP %d\n",$1);
        }       

;



expression_list:
        %empty
    |   expression expression_list
;

return:
        tRETURN arithmetic tSEMI    {}
;


sys_fonc_call:
        tPRINT tLPAR arithmetic tRPAR tSEMI {
                table_entry * value = pop(symbol_table);
                snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"PRINT %d\n",symbol_table->current_index);
        }
;

bool:
        bool tEQ bool  {

                                        pop(symbol_table);
                                        int i1 = symbol_table->current_index;
                                        int i2 = symbol_table->current_index - 1;
                                        snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"EQ %d %d %d\n", i2, i2, i1);
			}
    |   bool tNE bool  {

                                        pop(symbol_table);
                                        int i1 = symbol_table->current_index;
                                        int i2 = symbol_table->current_index - 1;
                                        snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"EQ %d %d %d\n", i2, i2, i1);
                                        snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"NOT %d %d\n", i2, i2);

			}
    |   bool tGT bool   {

                                        pop(symbol_table);
                                        int i1 = symbol_table->current_index;
                                        int i2 = symbol_table->current_index - 1;
                                        snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"SUP %d %d %d\n", i2, i2, i1);
			}
    |   bool tLT bool   {

                                        pop(symbol_table);
                                        int i1 = symbol_table->current_index;
                                        int i2 = symbol_table->current_index - 1;
                                        snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"INF %d %d %d\n", i2, i2, i1);
			}
    |   bool tGE bool   {               
                                        table_entry entry;
				        push(symbol_table,entry);
                                        table_entry entry1;
				        push(symbol_table,entry1);
                                        int i1 = symbol_table->current_index;
                                        int i2 = symbol_table->current_index - 1;
                                        int i3 = symbol_table->current_index - 2;
                                        int i4 = symbol_table->current_index - 3;
                                        snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"SUP %d %d %d\n", i1, i3, i4);
                                        snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"EQ %d %d %d\n", i2, i3, i4);
                                        snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"AND %d %d %d\n", i4, i2, i1);
                                        pop(symbol_table);
                                        pop(symbol_table);
                                        pop(symbol_table);
                        }
    |   bool tLE bool   {
                                        table_entry entry;
				        push(symbol_table,entry);
                                        table_entry entry1;
				        push(symbol_table,entry1);
                                        int i1 = symbol_table->current_index;
                                        int i2 = symbol_table->current_index - 1;
                                        int i3 = symbol_table->current_index - 2;
                                        int i4 = symbol_table->current_index - 3;
                                        snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"INF %d %d %d\n", i1, i3, i4);
                                        snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"EQ %d %d %d\n", i2, i3, i4);
                                        snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"AND %d %d %d\n", i4, i2, i1);
                                        pop(symbol_table);
                                        pop(symbol_table);
                                        pop(symbol_table);
                        }
    |   bool tAND bool  {
                                      int i1 = symbol_table->current_index;
                                      int i2 = symbol_table->current_index - 1;
                                      pop(symbol_table);
                                      snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"AND %d %d %d\n", i2, i2, i1);  
                        }
    |   bool tOR bool   {
                                      int i1 = symbol_table->current_index;
                                      int i2 = symbol_table->current_index - 1;
                                      pop(symbol_table);
                                      snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"OR %d %d %d\n", i2, i2, i1);  
                        }
    |   tNOT bool       {
                                        int i1 = symbol_table->current_index;
                                        snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"NOT %d %d\n", i1, i1);
                        }
    |   value
;



%%


void yyerror(const char *msg) {
  fprintf(stderr, "error line %d: %s\n", yylineno, msg);
  exit(1);
}

int main(void) {
  symbol_table = init_table();
  func_table = init_table();
  inst_list = get_instruction_list(1024);
  depth = 0;
  fptr = fopen("asm", "w");
  yyparse();

  table_print(symbol_table);
  write_to_file(fptr,inst_list);
  fclose(fptr);
  free(symbol_table);

}
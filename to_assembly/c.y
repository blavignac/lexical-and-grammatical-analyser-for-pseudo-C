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

    int fill_ret_instruction(instruction_list * list, int jmp){
        for(int i = list->current_index -1; i > 0; i--){
                char str[]=".ret";
                if(strncmp(list->instructions[i],str,4) == 0){
                        char ** end;
                        int addr = atoi(list->instructions[i]+4);
                        snprintf(list->instructions[i],INSTRUCTION_SIZE,"AFC %d %d\n", addr, jmp);
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
        } tLPAR tVOID tRPAR main_block  {}
;


param_list:
        %empty 
    |   tVOID
    |   param  param_pattern
;

param_pattern:
        %empty
    |   tCOMMA param param_pattern
;

param:
        tINT tID {
                int var_exists = lookup(symbol_table,$2);
		if (var_exists != -1) {
			snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"error  line %d: function parameter already has that name %s\n", yylineno, $2);
		}
                table_entry entry;
                strncpy(entry.entry_name, $2, 16);
                push(symbol_table,entry);
                func_table->data[func_table->current_index-1].num_param+=1;
        }
;

func_call:
        tID {   
                int func_exits = lookup(func_table,$1);
		if (func_exits == -1) {
			snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"error  line %d: function not declared with name :%s\n", yylineno, $1);
		}
                
                //verifier si voidfill_ret_instruction
                //return value push
                table_entry ret_val;
		snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"AFC %i 0\n", symbol_table->current_index);
                push(symbol_table,ret_val);

                //return address push
                table_entry ret_addr;
	        snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,".ret %d\n", symbol_table->current_index);
                push(symbol_table,ret_addr);

                
        } tLPAR func_call_param_list tRPAR  {
                int func_exits = lookup(func_table,$1);
                int offset = offset + symbol_table->current_index - func_table->data[func_exits].num_param -2;

                snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"OFFSETP %d\n",offset);

                snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"CALL %d %d\n", func_table->data[func_exits].fun_line, symbol_table->current_index - func_table->data[func_exits].num_param - 2);

                symbol_table->current_index = fill_ret_instruction(inst_list,inst_list->current_index);

                snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"OFFSETN %d\n",offset);
                

        }
;

func_call_param_list: 
        %empty 
    |   func_call_param func_call_param_list_mutiple_pattern
;


func_call_param_list_mutiple_pattern:
        %empty
    |   tCOMMA func_call_param func_call_param_list_mutiple_pattern
;

func_call_param:
        arithmetic
;


  
func_dec :
        tINT tID {
                snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"\n");
                snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,".%s\n",  $2);
                //printf("%s",$2);

                int var_exists = lookup(func_table,$2);
		if (var_exists != -1) {
			snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"error  line %d: function with this name already declared%s\n", yylineno, $2);
		}
                table_entry entry;
                entry.fun_type = int_fun;
                strncpy(entry.entry_name, $2, 16);
                entry.fun_line = inst_list->current_index;
                entry.num_param = 0;
                push(func_table,entry); 

                symbol_table->current_index = 0;
                symbol_table->current_index = 0;

        } tLPAR {
                table_entry entry;
                table_entry entry1;

                push(symbol_table,entry);
                push(symbol_table,entry1);  
        } param_list tRPAR block  {
                snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"RET 1\n");
        }
        |
        tVOID tID {
                snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"\n");
                snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,".%s\n",  $2);
                //printf("%s",$2);

                int var_exists = lookup(func_table,$2);
		if (var_exists != -1) {
			snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"error  line %d: function with this name already declared%s\n", yylineno, $2);
		}
                table_entry entry;
                strncpy(entry.entry_name, $2, 16);
                entry.fun_line = inst_list->current_index;
                entry.num_param = 0;
                entry.fun_type = void_fun;
                push(func_table,entry); 

                symbol_table->current_index = 0;
                symbol_table->current_index = 0;

        } tLPAR {
                table_entry entry;
                table_entry entry1;

                push(symbol_table,entry);
                push(symbol_table,entry1);  
        } param_list tRPAR block  {
                snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"RET 1\n");
        }

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



id_list:
        %empty
    |   tCOMMA dec_id id_list
;

dec_id: 
        tID {   
                int var_exists = lookup(symbol_table,$1);
		if (var_exists != -1) {
			snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"error line %d: variable already declared with that name %s\n", yylineno, $1);
		}
                table_entry entry;
                strncpy(entry.entry_name, $1, 16);
		snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"AFC %i 0\n", symbol_table->current_index);
                push(symbol_table,entry); 
        }
;

var_dec:
        tINT dec_id id_list tSEMI {}
;

var_dec_assign_arith:
        tINT tID tASSIGN {
                int var_exists = lookup(symbol_table,$2);
                if (var_exists != -1) {
                        snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"error line %d: variable already declared with that name %s\n",yylineno, $2);
                }
                table_entry entry;
                strncpy(entry.entry_name, $2, 16);
                snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"AFC %i 0\n",  symbol_table->current_index);
                push(symbol_table,entry); 
        } arithmetic tSEMI{
                pop(symbol_table);
                snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"COP %d %d\n",  symbol_table->current_index-1, symbol_table->current_index);
                
        }



assign_arith:
        tID tASSIGN arithmetic tSEMI {
					int entry = lookup(symbol_table,$1);
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
    |   arithmetic tEQ arithmetic  {

                                        pop(symbol_table);
                                        int i1 = symbol_table->current_index;
                                        int i2 = symbol_table->current_index - 1;
                                        snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"EQ %d %d %d\n", i2, i2, i1);
			}
    |   arithmetic tNE arithmetic  {

                                        pop(symbol_table);
                                        int i1 = symbol_table->current_index;
                                        int i2 = symbol_table->current_index - 1;
                                        snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"EQ %d %d %d\n", i2, i2, i1);
                                        snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"NOT %d %d\n", i2, i2);

			}
    |   arithmetic tGT arithmetic   {

                                        pop(symbol_table);
                                        int i1 = symbol_table->current_index;
                                        int i2 = symbol_table->current_index - 1;
                                        snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"SUP %d %d %d\n", i2, i2, i1);
			}
    |   arithmetic tLT arithmetic   {

                                        pop(symbol_table);
                                        int i1 = symbol_table->current_index;
                                        int i2 = symbol_table->current_index - 1;
                                        snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"INF %d %d %d\n", i2, i2, i1);
			}
    |   arithmetic tGE arithmetic   {               
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
    |   arithmetic tLE arithmetic   {
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
    |   arithmetic tAND arithmetic  {
                                      int i1 = symbol_table->current_index;
                                      int i2 = symbol_table->current_index - 1;
                                      pop(symbol_table);
                                      snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"AND %d %d %d\n", i2, i2, i1);  
                        }
    |   arithmetic tOR arithmetic   {
                                      int i1 = symbol_table->current_index;
                                      int i2 = symbol_table->current_index - 1;
                                      pop(symbol_table);
                                      snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"OR %d %d %d\n", i2, i2, i1);  
                        }
    |   tNOT arithmetic       {
                                        int i1 = symbol_table->current_index;
                                        snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"NOT %d %d\n", i1, i1);
                        }
    |   value 
    
;

value:
        func_call {

        }
     |   tID    { 
                        	int entry = lookup(symbol_table,$1);
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
    |   func_call {pop(symbol_table);}
    |   return
;


branch:
        if {
                symbol_table->current_index = fun(inst_list,inst_list->current_index);
                }
    |   if_else {}
;

condition:
        arithmetic
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
        tRETURN arithmetic tSEMI    {
                snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"COP %d %d\n",  0, symbol_table->current_index-1);
                }
;


sys_fonc_call:
        tPRINT tLPAR arithmetic tRPAR tSEMI {
                table_entry * value = pop(symbol_table);
                snprintf(add_instruction(inst_list),INSTRUCTION_SIZE,"PRINT %d\n",symbol_table->current_index);
        }
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

  //table_print(symbol_table);
  //table_print(func_table);
  write_to_file(fptr,inst_list);
  fclose(fptr);
  free(symbol_table);

}
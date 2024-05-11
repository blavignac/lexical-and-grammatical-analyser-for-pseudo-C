#ifndef MANIP_H
#define MANIP_H

#define TABLE_SIZE 1024

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum type {void_fun, int_fun} type;

typedef struct table_entry
{
    char entry_name[16];
    int fun_line;
    int num_param;
    type fun_type;
    
} table_entry;

typedef struct table
{
    int taille;
    int current_index;
    table_entry data[TABLE_SIZE];
} table;



void table_print(table * t);

table * init_table();

void push(table * t,table_entry add);

table_entry * pop(table * t);

int lookup(table *t, char * entry_name);

table_entry * top(table * t);

int top_index_temp(table *t);


#endif
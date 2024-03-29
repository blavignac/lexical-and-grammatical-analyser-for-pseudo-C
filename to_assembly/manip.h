#ifndef MANIP_H
#define MANIP_H

#define TABLE_SIZE 1024

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum type {func, var, sys_func, constant} type;

typedef struct table_entry
{
    char entry_name[16];
    type entry_type;
    int entry_value;
    
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
table_entry * lookup(table *t, char * entry_name);
table_entry * top(table * t);


#endif
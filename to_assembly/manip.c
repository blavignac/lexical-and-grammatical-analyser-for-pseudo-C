#include "manip.h"


table *init_table(){
    table* t =  (table *)calloc(1,sizeof(table));
    t->taille = TABLE_SIZE;
    t->current_index = 0;
    return t;
}

void push(table * t,table_entry add){
    t->data[t->current_index] = add;
    t->current_index += 1;
}



char is_empty(table * t){
    return (t->current_index == 0);
}


void table_print(table * t){
    for (int i = 0; i < t->current_index; i++)  {
        printf("\n\nTable entry %d is: name = %s, val = %d\n\n ",i,t->data[i].entry_name,t->data[i].entry_value);
    }
}

table_entry * pop(table * t){
    if (is_empty(t)){
        return NULL;
    }else{
        t->current_index -= 1;
        return &(t->data[t->current_index]);
    }
}

table_entry * lookup(table *t, char * entry_name){
    for(int i = 0; i < t->current_index; i++){
        if (strncmp(t->data[i].entry_name, entry_name, 16) == 0 )
        {
            return &(t->data[i]);
        }
    }
    return NULL;
}
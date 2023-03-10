#include <stdlib.h>
#include <string.h>
#include <stdio.h>
extern int yylineno;


struct Symbols{
char name[30];
char type[30];

 
};

struct variable {
    char name[20], type[20];
    int scope;
};
//struct variable Variables[30];
void Insert(char var[], char type[]);
char* Lookup(char var[], int scope);
int EnterScope(char var[], int scope);
void ExitScope(); // we might not need it
int CheckAssignment(char var1[], char var2[]);

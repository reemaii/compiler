%{
#include <stdio.h>
#include "phase2.h"
#include "phase2.tab.h"
#include <string.h>
#include <stdlib.h>
extern int yylineno;
extern FILE* yyin;
extern int yyerror (char* msg);
extern char * yytext;
extern int yylex();
extern int yyparse();

int numOfVariables = 0, scope = 1;
void duplicateError(char var[]);
void assignmentError(char var1[], char var2[]);
void relationalError(char dataType1[], char dataType2[]);
void conditinalStmtError(char msg[]);
void undeclaredVariableError(char var[]);

struct variable Variables[30];
struct Symbols S;

%}
%union {struct Symbols S;}
%type <S>ID;
%type <S>factor;
%type <S>exp;
%type <S>simple_exp;
%type <S>INT;
%type <S>DOUBLE;
%type <S>type;
%type <S>STRING_LITERAL; 
%token START END IF THEN ELSE IFEND READ WRITE REPEAT UNTIL
%token INT DOUBLE end SEMICOLON AND OR NOT
%token INT_LITERAL STRING_LITERAL DBL_LITERAL ID
%token ASSIGN PLUS MINUS MULT DIV EQ LT LE GT GE NE LPAREN RPAREN

%right ASSIGN
%left  LE GE EQ NE LT GT
%left MULT DIV MINUS PLUS

%%
    Program :START stmt_sequence END ;
    
    stmt_sequence :statment SEMICOLON stmt_sequence
    		  | statment SEMICOLON 
    		  ;
    
    statment :dec_stmt
    | if_stmt
    | repeat_stmt
    | assign_stmt
    | read_stmt
    | write_stmt ;
    
    dec_stmt :type ID {
    
        strcpy($2.type, $1.type);
        
        if(EnterScope($2.name, scope) == 0){
            undeclaredVariableError($2.name); 
        }
        
        else {
           Insert($2.name, $2.type);
        }
    };
    
    /////////////////////////////////////////////////
    
    
    type :INT 		{  strcpy($$.type, "int");}
    	 | DOUBLE 	{   strcpy($$.type, "double");};
    
    /////////////////////////////////////////////////
    
    if_stmt :IF exp THEN stmt_sequence end {
    	 if(EnterScope($2.name, scope) == 1){
           undeclaredVariableError($2.name); 
        }	
    		if( (strcmp($2.type,"int") == 0) || (strcmp($2.type,"double") == 0 )) 
			conditinalStmtError("IF exprition not type Boolean");
    }
    								
    									
    |IF exp THEN stmt_sequence ELSE stmt_sequence end {
    		 if(EnterScope($2.name, scope) ==1){
           undeclaredVariableError($2.name); 
        }
    		if( ( strcmp($2.type,"int") == 0 )|| (strcmp($2.type,"double") == 0) )
    			conditinalStmtError("IF exprition not type Boolean");
    }
    ;
    		
   //////////////////////////////////////////////////////////
    
    repeat_stmt :REPEAT stmt_sequence UNTIL exp {
    		
    		if( (strcmp($4.type,"int") == 0 )|| (strcmp($4.type,"double") == 0 ))
    			conditinalStmtError("Repeat exprition not type Boolean");
    }
    ;
        
     ///////////////////////////////////////////////////////////// 
       
    assign_stmt :ID ASSIGN exp  {
   
     	if (EnterScope($1.name, scope)== 0){
     	if(CheckAssignment(Lookup($1.name, scope),$3.type)==0)
     	assignmentError(Lookup($1.name,scope), $3.type);
     	}
     	else
     	undeclaredVariableError($1.name);
     	
     	
    };
    
    ////////////////////////////////////////////////////////
    
    read_stmt :READ ID ;
    
    write_stmt :WRITE LPAREN exp RPAREN 
    | WRITE LPAREN STRING_LITERAL RPAREN   {if(EnterScope($3.name, scope) ==1){
                 undeclaredVariableError($3.name); 
        }};
    
    
    exp :simple_exp comparison_op simple_exp{
    	 if(EnterScope($1.name, scope) ==1){
                undeclaredVariableError($1.name); 
        }
         if(EnterScope($3.name, scope) ==1){
                undeclaredVariableError($3.name); 
        }
    	if(CheckAssignment($1.type,$3.type) == 0)
    		relationalError($1.type, $3.type);
    		 
    		else
            strcpy($$.type,"bool");
    }
    	| simple_exp
    	;
    	
    comparison_op :EQ
    |LT
    |LE
    |GT
    |GE
    |NE;
 /////////////////////////////////////////////////
 
  simple_exp : factor a_opt simple_exp   	{
   
							if((strcmp($1.type,"int") == 0 || strcmp($1.type,"double") == 0) && (strcmp($3.type,"int") == 0 || strcmp($3.type,"double") == 0)){
				
								if(strcmp($3.type,"double") == 0 || strcmp($1.type,"double") == 0)
									strcpy($$.type, "double");
								else 
									strcpy($$.type, "int");
							}
							
							else
                            relationalError($1.type, $3.type);
						}
		|factor ;
						
						
    	a_opt:PLUS
    		|MINUS
    		|MULT
    		|DIV
    		;
    	           	 
    	 
    factor : LPAREN exp RPAREN		{;}
    	   | INT_LITERAL		{ strcpy($$.type, "int");}
    	   | DBL_LITERAL		{ strcpy($$.type, "double");} 
    	   | ID				{if(EnterScope($1.name, scope) ==1){
                 undeclaredVariableError($1.name); 
        }else strcpy($$.type, (Lookup($1.name, scope)) );}
    	   ;
    
%%
    int main (int argc, char *argv[])
    {
        yyin=fopen(argv[1],"r");
        
        if(!yyparse())
        printf("\nParsing complete\n");
        else
        printf("\nParsing failed\n");
        
        fclose(yyin);
        return 0;
    }
    
    extern int yyerror(char* msg)
    {
        printf("\n %s in line: %d %s \n", msg, (yylineno), yytext);
        return 0;
    }
    
    void relationalError(char dataType1[], char dataType2[])
{
	printf("\nLine %d: Incompatible type: Comprison operator between '%s' and '%s'\n", yylineno, dataType1, dataType2);
}

void conditinalStmtError(char msg[])
{
	printf("\nLine %d: Conditional Statement Error : %s\n", yylineno, msg);
}

void assignmentError(char dataType1[], char dataType2[])
{
    printf("\nLine %d: Incompatible type: Assigning '%s' and '%s'\n", yylineno, dataType1, dataType2);
}
    
    void Insert(char var[], char type[])
    {
        strcpy(Variables[numOfVariables].name, var);
        strcpy(Variables[numOfVariables].type, type);
        Variables[numOfVariables].scope = scope;
        numOfVariables++;
    }
    
    char* Lookup(char var[], int scope){
        for (int i = 0; i < numOfVariables; i++){
            if (strcmp(Variables[i].name, var) == 0 && Variables[i].scope == scope){
                return Variables[i].type;
            }
        }
        return NULL;
    }
    
    int EnterScope(char var[], int scope){
        for (int i = 0; i < numOfVariables; i++){
            if (strcmp(Variables[i].name, var) == 0 && Variables[i].scope == scope){
                return 0;//error
            }
        }
        return 1;
    }
    
    int CheckAssignment(char var1[], char var2[]){
        if(strcmp(var1, var2) == 0){
            return 1;
        }
        else return 0;
    }
    
  
    
    void undeclaredVariableError(char var[])
    {
        printf("\nLine %d: cannot find symbol \"%s\" \n",yylineno, var);
    }

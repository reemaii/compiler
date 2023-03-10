/*
 Group#7
 Atheer Alkhamali
 Shroog Alharbi
 Shahad Al-Khalifa
 Reema Aldawood
 */

%{
#include "phase2.h"
#include "phase2.tab.h"
#include <stdio.h>
#include <string.h>	
%}

 /* KEEP TRACK OF LINE NUMBER*/

%option yylineno
whitespace [" "\t] 
Comment [@][^@]*[@]

%%

{Comment}	;	
"repeat"	{return REPEAT;}
"until"		{return UNTIL;}
"if"		{return IF;}
"else"		{return ELSE;}
"end"		{return end;}
"int"		{return INT;}
"double" 	{return DOUBLE;}
"START"		{return START;}
"END"		{return END;}
"read"          {return READ;}
"write"         {return WRITE;}
"then"          {return THEN;}
":="		{return ASSIGN;}
"(" 		{return LPAREN;}
")"		{return RPAREN;}
"+" 		{return PLUS;}
"-"		{return MINUS;}
"/"		{return DIV;}
"*"	        {return MULT;}	
"<"		{return LT;}
">"		{return GT;}
"<=" 		{return LE;}
">=" 		{return GE;}
"==" 		{return EQ;}
"<>" 		{return NE;}
"!"		{return NOT;}
"&"		{return AND;}
"|"		{return OR;}
";"		{return SEMICOLON;}
[A-Z][0-9A-Za-z_]* { strcpy((yylval.S).name,yytext);return ID;}
[0-9]+		{return INT_LITERAL;}
["].*["]	{return STRING_LITERAL;}
[0-9]+\.[0-9]+	{return DBL_LITERAL;}
\n		{;}
{whitespace}* {;}
.		{return *yytext;}

%%

int yywrap(){
	
	return(1);
}



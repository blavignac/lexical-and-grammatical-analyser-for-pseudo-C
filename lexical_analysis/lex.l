%{
	#include <stdio.h> 
	#include <stdlib.h> 


	union yyvalue {
		int value;
	};
%}
DIGIT	[0-9]
ID		[a-z][a-z0-9]*
HEX		((0x|X)[a-fA-F0-9]+)
%x C_MULTI_LINE_COMMENT		
%x C_SINGLE_LINE_COMMENT
%option noyywrap
%option noinput
%option nounput

%%
" "					;
"\t"				;
"\n"				;

"/*"						{BEGIN(C_MULTI_LINE_COMMENT);};
<C_MULTI_LINE_COMMENT>"*/"	{BEGIN(INITIAL);};
<C_MULTI_LINE_COMMENT>.|\n  ;

"//"						{BEGIN(C_SINGLE_LINE_COMMENT);};
<C_SINGLE_LINE_COMMENT>\n	{BEGIN(INITIAL);};
<C_SINGLE_LINE_COMMENT>. 	;

"if"				printf("tIF\n");
"else"				printf("tELSE\n");
"while"				printf("tWHILE\n");
"print"				printf("tPRINT\n");
"return"			printf("tRETURN\n");
"int"				printf("tINT\n");
"void"				printf("tVOID\n");
{ID}		printf("tID: \'%s\'\n",yytext);
{HEX}				{	
						int conv = (int)strtol(yytext+2,NULL, 16);// +2 for removing the 0x at the beginning of the string and only maintaint the hexadecimal part (!WARNING POINTER ARITHMETIC!)
						printf("tNB: '%d[0x%x]'\n",conv,conv);
					}
					
{DIGIT}+			{	
						int conv = (int)strtol(yytext,NULL, 10);
						printf("tNB: '%d[0x%x]'\n",conv,conv);
					}
"+"					printf("tADD\n");
"-"					printf("tSUB\n");
"*"					printf("tMUL\n");
"/"					printf("tDIV\n");
"<"					printf("tLT\n");
">"					printf("tGT\n");
"!="				printf("tNE\n");
"=="				printf("tEQ\n");
">="				printf("tGE\n");
"<="				printf("tLE\n");
"="					printf("tASSIGN\n");
"&&"				printf("tAND\n");
"&"					printf("tAMPER\n");
"||"				printf("tOR\n");
"!"					printf("tNOT\n");
"{"					printf("tLBRACE\n");
"}"					printf("tRBRACE\n");
"("					printf("tLPAR\n");
")"					printf("tRPAR\n");
";"					printf("tSEMI\n");
","					printf("tCOMMA\n");
.					printf("tERROR\n");
%%

int main(void) {
	yylex();
	return 0;
}


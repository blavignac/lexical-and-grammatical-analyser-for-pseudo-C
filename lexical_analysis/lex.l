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

"if"				return ("tIF");
"else"				return ("tELSE");
"while"				return ("tWHILE");
"print"				return ("tPRINT");
"return "			return ("tRETURN");
"int"				return ("tINT");
"void"				return ("tVOID");
[a-z][a-z0-9]*		return ("tID: \'%s\'",yytext);
{HEX}				{	
						int conv = (int)strtol(yytext+2,NULL, 16);// +2 for removing the 0x at the beginning of the string and only maintaint the hexadecimal part (!WARNING POINTER ARITHMETIC!)
						yylval.val = conv;
						return ("tNB");
					}
					
{DIGIT}+			{	
						int conv = (int)strtol(yytext,NULL, 10);
						yyval = conv;
						return ("tNB");
					}
"+"					return ("tADD");
"-"					return ("tSUB");
"*"					return ("tMUL");
"/"					return ("tDIV");
"<"					return ("tLT");
">"					return ("tGT");
"!="				return ("tNE");
"=="				return ("tEQ");
">="				return ("tGE");
"<="				return ("tLE");
"="					return ("tASSIGN");
"&&"				return ("tAND");
"&"					return ("tAMPER");
"||"				return ("tOR");
"!"					return ("tNOT");
"{"					return ("tLBRACE");
"}"					return ("tRBRACE");
"("					return ("tLPAR");
")"					return ("tRPAR");
";"					return ("tSEMI");
","					return ("tCOMMA");
.					return ("tERROR");
%%

int main(void) {
	yylex();
	return  0;
}


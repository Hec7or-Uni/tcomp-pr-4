%{
#include "y.tab.h"
%}

	/* AUXILIARIES */
DIGIT	[0-9]
NATURAL	{DIGIT}+
REAL	{NATURAL}*"."{DIGIT}+
	/* PATTERNS */
HEIGHT 	{NATURAL}|{REAL}
NAME	[^","":"";"""("")"\t\n ]*
SPAIN	Spain{NAME}

%%

{HEIGHT}	{ 	yylval.datos.altura = atof(yytext);
			  	return(HEIGHT); }

{SPAIN}		{ 	yylval.datos.nombre = strdup(yytext);
				yylval.datos.esspain = 1;
				return(SPAIN); }

{NAME}		{ 	yylval.datos.nombre = strdup(yytext);
				return(NAME); }
","			{ 	return CM; }
":"			{ 	return DP; }
";"			{ 	return PC; }
"("			{ 	return OP; }
")"			{ 	return CP; }
%%

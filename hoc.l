/**
 *	\file		hoc.l
 *	\version	2.0
 *	\date		24 Janvier 2022
 *	\author	Samir El Khattabi
 */
%{
#define _HOC_L_
#include "hoc.h"
%}
%option noyywrap
entier		[0-9]+
reel		([0-9]+\.?)|([0-9]*\.[0-9]+)
ident		[a-zA-Z][a-zA-Z_0-9]*
operateur	[-+*/#(){}?<>]|"??"|"=="|"!="
carExclu	[^;\-+*>/(){}?<@=a-zA-Z_0-9\n \t]

%%
"debug"		return DBG;
";"			return ENDSEQ;
{entier}    { yylval.symb = installIntSymbol("",DAT,atoi(yytext),"*(int *)");
			return (yylval.symb)->type; };
{reel}      { yylval.symb = installFloSymbol("",DAT,atof(yytext),"*(double *)");
			return (yylval.symb)->type; };
{ident}		{ yylval.symb =  lookUpSymbol(yytext);
    		if (yylval.symb==NULL) yylval.symb=installSymbol(yytext,VAR,UNDEF,0,NULL,NULL);
            return (yylval.symb)->type; };
{operateur}	{ yylval.symb =  lookUpSymbol(yytext);
			if (yylval.symb==NULL) exeError("Opérateur [%s] inconnu", yytext);
			return (yylval.symb)->type; };
"="         return AFF;
"@"			return DBG_TS;
\n			return RC;
{carExclu}+	lexError("Unkown Word : #%s#[%d]", yytext, yyleng);
.			;
			/* Tout ce qui n'est pas spécifié, sera ignoré */
<<EOF>>		return 0;	/* ^D = fin de ... */
%%

/**
 *	\file		hoc.y
 *	\version	2.0
 *	\date		24 Janvier 2022
 *	\author	Samir El Khattabi
*/
%{
#define _HOC_Y_
#include "hoc.h"
extern int yylex(void);
int isFloat = 0;
/**
 *	\var		myError
 *	\brief	Numéro d'erreur
 *	\note		A déclarer avec l'attribut "extern" par les utilisateurs
 */
extern int myError;
#define MYERROR		if (myError) YYERROR;
%}
/* YYSTYPE  : Définition des valeurs sémantiques (yylval renseignée par lex) */
%union {
	int			entier;
	double		reel;
	pSymbol_t	symb;
}
/* Tokens fictifs : déclaration des classes */
%token DAT CST VAR PRG
/* Tokens nombres */
%token	<symb> ENTIER REEL
/* Token pour identifiant non reconnu */
%token	<symb> UNDEF
/* Tokens pour les variables : passage de UNDEF vers IVAR/FVAR */
%token	<symb> IVAR FVAR
/* Token pour fonction prédéfinie */
%token	<symb> PREDEF
/* Typage des unités syntaxiques */
%type		<reel> expr assgn
%type		<symb> opAlg var

// Typage des tokens d'opérations arithmétiques
%token 	<symb> ADD SUB MUL DIV POW LT GT EQ NE
%token 	<symb> PO PF
%token	<symb> PR_TS PR_TS2
%token RC
%token AFF
%token DBG_TS
/* Associativités & priorités */
%right AFF
%left ADD SUB
%left MUL DIV
%nonassoc UNARY_MINUS
%right POW

%%
//	US : liste de ... (commande, assignation, expression)
liste :	/* VIDE */
	| liste error RC    { yyerrok; yyclearin; code (STOP); return 1;}
	| liste RC 			{ code (STOP); MYERROR; return 2;}
	| liste expr  RC	{ code((instr_t)printExprCode); code (STOP); MYERROR; return 3;}
	| liste assgn RC    { code((instr_t)printExprCode); code (STOP); MYERROR; return 4; }
	| liste cmd	  RC 	{ code (STOP); MYERROR; return 5;}
	;
cmd	: PR_TS			{ code ((instr_t)*($1->U.pFct));}
	| PR_TS2		{ code ((instr_t)*($1->U.pFct));}
	| DBG_TS			{ dbgSymbolList(); }
	;
// US : Assignation
var : IVAR | FVAR | UNDEF
	;
assgn :
  var AFF expr		{ code3((instr_t)varPush, (instr_t)$1, (instr_t)varAssign); }
	;
// US : Expression algébrique
opAlg : ADD | SUB | MUL | DIV | POW | GT | LT | EQ | NE;
//opAlg : ADD | SUB | MUL | DIV | POW | AND | OR | NOT | EQ | NE | GT | LT ;

expr : ENTIER { code2((instr_t)intPush, (instr_t)$1); }
	| REEL { code2((instr_t)floPush, (instr_t)$1); isFloat=1;}
	| var { code3((instr_t)varPush, (instr_t)$1, (instr_t)varEval); }
	| PO expr PF { $$=$2; }
	| expr opAlg expr { code ((instr_t)*($2->U.pFct)); }
	
	// A faire pour après : 
	//| NOT expr { code ((instr_t)notCode); }
	//| expr AND expr { code ((instr_t)andCode); }
	//| expr OR expr { code ((instr_t)orCode); }
	//| expr EQ expr { code ((instr_t)eqCode); }
	//| expr NE expr { code ((instr_t)neCode); }
	//| expr GT expr { code ((instr_t)gtCode); }

%%

/**
 *	\var        progName
 *	\brief		Nom du programme
 *	\note 		A déclarer avec l'attribut "extern" par les utilisateurs
 */
char * progName;
int main(int argc, char **argv) {
    int resParse;
    
	progName = argv[0];
	printMessage(0);
    installDefaultSymbols();

	for (initCode(); ((resParse=yyparse()) !=0 ) ; initCode()) {
		execute(PC);
/*		switch (resParse) {
			case 1 : printMessage(46, "\t--- Une erreur a été comise ---"); break;
			case 2 : printMessage(46, "\t--- Un retour à la ligne a été demandé ---"); break;
			case 3 : printMessage(46, "\t--- Une expression algébrique a été évaluée ---"); break;
			case 4 : printMessage(46, "\t--- Une variable a été assignée ---"); break;
			case 5 : printMessage(46, "\t--- Une commande a été demandée ---"); break;
			default : printMessage(46, "\t--- OVNI ---"); break;
		}		
*/	}
	printMessage(2);
return 0;
}


%{
#include <stdio.h>
#include <string.h>

/* Variables */
int NA  = 0;	/* Number of nodes in the tree */
int NAE = 0;	/* Number of spanish nodes in the tree */
int NH  = 0;	/* Number of leaves in the tree */
int NHE = 0;	/* Number of spanish leaves in the tree */

void results(float AT,char *RA, int NA, int NAE, int NH, int NHE, float ATE) {
	printf("AT:  %.2f\n", AT);	/* Height from the fardest node to the root */
	printf("RA:  %s\n", RA);	/* Name of the root */
	printf("NA:  %i\n", NA);	/* Number of nodes in the tree */
	printf("NAE: %i\n", NAE);	/* Number of spanish nodes in the tree */
	printf("NH:  %i\n", NH);	/* Number of leaves in the tree */
	printf("NHE: %i\n", NHE);	/* Number of spanish leaves in the tree */
	printf("ATE: %.2f\n", ATE);	/* Height from the fardest spanish node to the root */
}

%}

%union {
	struct nodo {			/* Node <- tree info */
		char* nombre;		/* Node's name  */
		float altura;		/* Height to it's fardest leaf  */
		float alturaEsp;	/* Height to it's fardest spanish leaf */
		int esspain;		/* If node is marked with: "Spain", esspain = 1; otherwires, esspain = 0 */
	} datos;
}

%start tree
/* declare tokens */
%token<datos> NAME SPAIN
%token<datos> HEIGHT
%token CM DP PC					/* CM = ','; DP = ':'; PC = ';' */
%token OP CP					/* OP = '('; CP = ')'; */

%type<datos> tree forest leaf	/* Those are tree nodes (tree nodes = Nodes <- tree info) */

%%

tree: tree PC 			{	results($1.altura, $1.nombre, NA, NAE, NH, NHE, $1.alturaEsp); 
                        }
	| OP forest CP leaf	{	$$.nombre = $4.nombre;					/* tree->nombre = leaf->nombre */
							$$.altura = $2.altura + $4.altura;		/* tree->height = forest->height + leaf->height */
                            if ($2.esspain == 1) {					/* Update of a spanish TREE height */
                                $$.esspain = 1;
                                $$.alturaEsp = $2.alturaEsp + $4.altura;
                            }
	 					}
	| leaf				{	$$.nombre = $1.nombre;				/* tree->nombre = leaf->nombre */
							$$.altura = $1.altura;				/* tree->height = leaf->height */
                            if ($1.esspain == 1)  {				/* Take the height of the spanish node to process it later in forest */
                                $$.esspain = 1;
                                $$.alturaEsp = $1.alturaEsp;
                                NHE += 1;						/* Number of spaish leaves++ */
                            }
                            NH += 1;							/* Number of leaves++ */
						}
	;

forest: forest CM tree	{	/* forest->height = MAX(tree->height) of the forest */
							if ($1.altura < $3.altura) $$.altura = $3.altura;
                            else $$.altura = $1.altura;
							/* forest->spaish-height = MAX(tree->spanish-height) of the forest */
                            if ($1.esspain == 1 || $3.esspain == 1) {
                                $$.esspain = 1;
                                if ($1.alturaEsp < $3.alturaEsp) $$.alturaEsp = $3.alturaEsp;
                                else $$.alturaEsp = $1.alturaEsp;
                            }
						}
	| tree				{	/* forest->height = tree->height */
							$$.altura = $1.altura;
							/* forest->spanish-height = tree->spanish-height */
                            if ($1.esspain == 1) {
                                $$.esspain = 1;
                                $$.alturaEsp = $1.alturaEsp;
                            }
						}
	;

leaf: NAME DP HEIGHT	{	$$.nombre   = yylval.datos.nombre;	/* leaf->nombre  = NAME */
							$$.altura   = yylval.datos.altura;	/* leaf->altura  = HEIGHT */
							$$.esspain  = 0;					/* leaf->esspain = 0 */
							NA += 1;							/* number of nodes++ */
						}
	| NAME				{	$$.nombre   = yylval.datos.nombre;	/* leaf->nombre  = NAME */
							$$.altura   = 1;					/* leaf->altura  = 1 */
							$$.esspain  = 0;					/* leaf->esspain = 0 */
							NA += 1;							/* number of nodes++ */
						}

	| SPAIN DP HEIGHT	{	$$.nombre   = yylval.datos.nombre;	/* leaf->nombre  = NAME */
							$$.altura   = yylval.datos.altura;	/* leaf->altura  = HEIGHT */
                            $$.alturaEsp= yylval.datos.altura;	/* leaf->altura  = HEIGHT */
							$$.esspain  = yylval.datos.esspain;	/* leaf->esspain = true */
							NA  += 1;							/* number of nodes++ */
							NAE += 1;							/* number of spanish nodes++ */
						}
	| SPAIN				{	$$.nombre   = yylval.datos.nombre;	/* leaf->nombre  = NAME */
							$$.altura   = 1;					/* leaf->altura  = 1 */
                            $$.alturaEsp= 1;	                /* leaf->altura  = 1 */
							$$.esspain  = yylval.datos.esspain;
							NA  += 1;							/* number of nodes++ */
							NAE += 1;							/* number of spanish nodes++ */
						}
    | DP HEIGHT	        {	$$.nombre   = "VAC";	            /* leaf->nombre  = NAME */
							$$.altura   = yylval.datos.altura;	/* leaf->altura  = HEIGHT */
							$$.esspain  = 0;					/* leaf->esspain = 0 */
							NA += 1;							/* number of nodes++ */
						}
    |   				{	$$.nombre   = "VAC";	            /* leaf->nombre  = VAC */
							$$.altura   = 1;	                /* leaf->altura  = 1 */
							$$.esspain  = 0;					/* leaf->esspain = 0 */
							NA += 1;							/* number of nodes++ */
						}
	;

%%

int yyerror(char* s) {
	printf("%s\n", s);
	return -1; 
}

int main() {
	int error = yyparse();
	return error;
}

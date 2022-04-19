%{
#include <stdio.h>
#include <stdlib.h>

extern int linenum;             /* declared in lex.l */
extern FILE *yyin;              /* declared by lex */
extern char *yytext;            /* declared by lex */
extern char buf[256];           /* declared in lex.l */
%}

%token DOE FAN MAO RIGUA LEGUA RIJON LEJON ADD SUB STAR SHOE MOD ASSIGN SMALLER SMAEQUAL BIGSMA BIGEQUAL BIGGER EQUAL AND OR NOT KWARRAY KWBEGIN KWBOOLEN KWDEF KWDO KWELSE KWEND KWFALSE KWFOR KWINT KWIF KWOF KWPRINT KWREAD KWREAL KWSTRING KWTHEN KWTO KWTRUE KWRETURN KWVAR KWWHILE OCTAL IDENTIFIER INTEGER FLOAT SCIENTIFIC STRING

%left OR
%left AND
%left NOT
%left SMALLER SMAEQUAL EQUAL BIGEQUAL BIGGER BIGSMA
%left ADD SUB
%left STAR SHOE MOD




%%

program		: programname FAN programbody KWEND IDENTIFIER
		;

programbody : datadeclarss functionss comstmt
		;

programname	: identifier
		;

identifier	: IDENTIFIER
		;

function	: IDENTIFIER LEGUA arguments RIGUA MAO type FAN comstmt KWEND IDENTIFIER
			| IDENTIFIER LEGUA arguments RIGUA FAN comstmt KWEND IDENTIFIER
		;

functionss	: functionss function
			| function
			|
		;

arguments 	: arglist MAO type
			|
		;

arglist 	: arglist DOE IDENTIFIER 
			| IDENTIFIER 
		;

type		: KWINT | KWSTRING | KWBOOLEN | KWREAL
			| array
		;

array		: KWARRAY integer KWTO integer KWOF type
		;

integer 	: INTEGER
			| OCTAL
		;

datadeclar	: KWVAR idlist MAO type FAN
			| KWVAR idlist MAO litcons FAN
		;

datadeclarss: datadeclarss datadeclar
			| datadeclar
			|
		;

idlist		: idlist DOE IDENTIFIER
			| IDENTIFIER
		;



litcons		: INTEGER | STRING | FLOAT | SCIENTIFIC | KWTRUE | KWFALSE | OCTAL
		;

comstmt		: KWBEGIN datadeclarss stmtss KWEND
		;

stmt		: comstmt | simstmt | condition | while | for | return | stfuncinvo
		;

stmtss		: stmtss stmt
			| stmt
			|
		;

simstmt		: varref ASSIGN expr FAN
			| KWPRINT varref FAN
			| KWPRINT expr FAN	
			| KWREAD varref	FAN
		;

varref		: IDENTIFIER
			| IDENTIFIER arrref
		;

arrref		: arrref LEJON expr RIJON
			| LEJON expr RIJON
		;

operand		: litcons 
            | funcinvo 
            | varref
        ;

boolexpr	: operand SMALLER operand 
            | operand SMAEQUAL operand 
            | operand EQUAL operand 
            | operand BIGEQUAL operand 
            | operand BIGGER operand 
            | operand BIGSMA operand 
        ;

expr		: LEGUA expr RIGUA
			| SUB expr %prec STAR 
			| expr STAR expr 
            | expr SHOE expr 
            | expr MOD expr 
            | expr ADD expr 
            | expr SUB expr
            | NOT expr 
            | expr AND expr 
            | expr OR expr 
            | boolexpr
            | litcons 
            | funcinvo 
            | varref
        ;

funcinvo	: IDENTIFIER LEGUA exprss RIGUA
		;

exprss		: exprss DOE expr
			| expr
			|
		;

condition	: KWIF expr KWTHEN stmtss KWELSE stmtss KWEND KWIF
			| KWIF expr KWTHEN stmtss KWEND KWIF
		;

while  		: KWWHILE expr KWDO stmtss KWEND KWDO
		;

for 		: KWFOR IDENTIFIER ASSIGN integer KWTO integer KWDO stmtss KWEND KWDO
		;

return 		: KWRETURN expr FAN
		;

stfuncinvo	: funcinvo FAN
		;




%%

int yyerror( char *msg )
{
        fprintf( stderr, "\n|--------------------------------------------------------------------------\n" );
	fprintf( stderr, "| Error found in Line #%d: %s\n", linenum, buf );
	fprintf( stderr, "|\n" );
	fprintf( stderr, "| Unmatched token: %s\n", yytext );
        fprintf( stderr, "|--------------------------------------------------------------------------\n" );
        exit(-1);
}

int  main( int argc, char **argv )
{
	if( argc != 2 ) {
		fprintf(  stdout,  "Usage:  ./parser  [filename]\n"  );
		exit(0);
	}

	FILE *fp = fopen( argv[1], "r" );
	
	if( fp == NULL )  {
		fprintf( stdout, "Open  file  error\n" );
		exit(-1);
	}
	
	yyin = fp;
	yyparse();

	fprintf( stdout, "\n" );
	fprintf( stdout, "|--------------------------------|\n" );
	fprintf( stdout, "|  There is no syntactic error!  |\n" );
	fprintf( stdout, "|--------------------------------|\n" );
	exit(0);
}

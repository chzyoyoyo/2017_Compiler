/**
 * Introduction to Compiler Design by Prof. Yi Ping You
 * Prjoect 2 main function
 */

#include <stdio.h>
#include <stdlib.h>
#include <cstring>

extern int yyparse();	/* declared by yacc */
extern FILE* yyin;	/* declared by lex */
extern char argue[33];
extern int perfect;

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

	int len = strlen(argv[1]);
	int pivot = 0;

	for (int i = len-1; i > -1; i--)
	{
		if (argv[1][i] == '/')
		{
			pivot = i+1;
			break;
		}
	}

	//char argue[33];

	for (int i = pivot; i < len; ++i)
	{
		if (argv[1][i] != '.' && argv[1][i+1] != 'p')
		{
			argue[i-pivot] = argv[1][i];

		}
		// if (argv[1][i] == '.' && argv[1][i+1] == 'p')
		// {
		// 	argue[]
		// }
		else
			break;
	}
	argue[strlen(argue)] = '\0';
	//printf( "%s ooooooooo\n", argue);

	
	yyin = fp;
	yyparse();	/* primary procedure of parser */
	
	if (perfect == 0) {
        printf("|-------------------------------------------|\n");
        printf("| There is no syntactic and semantic error! |\n");
        printf("|-------------------------------------------|\n");
    }
	// fprintf( stdout, "\n|--------------------------------|\n" );
	// fprintf( stdout, "|  There is no syntactic error!  |\n" );
	// fprintf( stdout, "|--------------------------------|\n" );
	exit(0);
}


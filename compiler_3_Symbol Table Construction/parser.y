%{
/**
 * Introduction to Compiler Design by Prof. Yi Ping You
 * Project 2 YACC sample
 */
#include <stdio.h>
#include <stdlib.h>
#include <cstring>
#include "symbol.h"

extern int linenum;		/* declared in lex.l */
extern FILE *yyin;		/* declared by lex */
extern char *yytext;		/* declared by lex */
extern char buf[256];		/* declared in lex.l */
extern int yylex(void);
int yyerror(char* );
bool funcflag = false;
int forflag = 0;
std::vector<int> dimdim;


std::vector<forfor> forvar;

%}

%union {
	char* str;
	Type type;
	int num;
	double flosien;
	bool trfal;
	LIconst liconst;
}


/* tokens */
%token ARRAY
%token BEG
%token <str> BOOLEAN
%token DEF
%token DO
%token ELSE
%token END
%token <trfal> FALSE
%token FOR
%token <str> INTEGER
%token IF
%token OF
%token PRINT
%token READ
%token <str> REAL
%token RETURN
%token <str> STRING
%token THEN
%token TO
%token <trfal> TRUE
%token VAR
%token WHILE

%token <str> ID
%token <num> OCTAL_CONST
%token <num> INT_CONST
%token <flosien> FLOAT_CONST
%token <flosien> SCIENTIFIC
%token <str> STR_CONST

%token OP_ADD
%token OP_SUB
%token OP_MUL
%token OP_DIV
%token OP_MOD
%token OP_ASSIGN
%token OP_EQ
%token OP_NE
%token OP_GT
%token OP_LT
%token OP_GE
%token OP_LE
%token OP_AND
%token OP_OR
%token OP_NOT

%token MK_COMMA
%token MK_COLON
%token MK_SEMICOLON
%token MK_LPAREN
%token MK_RPAREN
%token MK_LB
%token MK_RB

%type <type> scalar_type
%type <type> array_type
%type <type> type
%type <liconst> literal_const
%type <num> int_const


/* start symbol */
%start program
%%

program			: ID MK_SEMICOLON 
				{ 
					addSymbolTable(); 
					addEntry($1);
					editEntry(none1, program);
				}
			  program_body
			  END ID { tables[tables.size()-1].PrintTable() ;subSymbolTable(); }
			;

program_body		: opt_decl_list opt_func_decl_list compound_stmt
			;

opt_decl_list		: decl_list
			| /* epsilon */
			;

decl_list		: decl_list decl
			| decl
			;

decl			: VAR id_list MK_COLON scalar_type MK_SEMICOLON 
					{
						//tables[tables.size()-1].entry[tables[tables.size()-1].entry.size()-1].kind = variable;
						editEntry($4, variable);
					}      /* scalar type declaration */
			| VAR id_list MK_COLON array_type MK_SEMICOLON 
					{
						//tables[tables.size()-1].entry[tables[tables.size()-1].entry.size()-1].kind = variable;
						for (int i = 0; i < tables[tables.size()-1].entry.size(); ++i)
						{
							if(tables[tables.size()-1].entry[i].kind == none0)
							{
								tables[tables.size()-1].entry[i].dim = dimdim;
							}
						}

						editEntry($4, variable);
						
						// while(dimdim.size() != 0)
						// {
						// 	tables[tables.size()-1].entry[tables[tables.size()-1].entry.size()-1].dim.push_back(dimdim[dimdim.size()-1]);
						// 	dimdim.pop_back();
						// }
						//tables[tables.size()-1].entry[tables[tables.size()-1].entry.size()-1].dim = dimdim;
						dimdim.clear();

					}        /* array type declaration */
			| VAR id_list MK_COLON literal_const MK_SEMICOLON 
					{
						//tables[tables.size()-1].entry[tables[tables.size()-1].entry.size()-1].kind = constant;
						
						editEntry($4.type, constant);
						editEntryAtt(constant, $4);

						//printf("%s\n", $4.listring);
					}     /* const declaration */
			;
int_const	:	INT_CONST{$$ = $1;}
			|	OCTAL_CONST{$$ = $1;}
			;

literal_const		: int_const  {$$.type = integer; $$.number = $1; }
			| OP_SUB int_const  {$$.type = integer; $$.number = -$2; }
			| FLOAT_CONST       {$$.type = real; $$.realnum = $1; }
			| OP_SUB FLOAT_CONST {$$.type = real; $$.realnum = -$2; }
			| SCIENTIFIC    {$$.type = real; $$.realnum = $1;}
			| OP_SUB SCIENTIFIC   {$$.type = real; $$.realnum = -$2;}
			| STR_CONST   {$$.type = Tstring; strcpy($$.listring ,$1); }
			| TRUE   {$$.type = boolean; $$.yesorno = true; }
			| FALSE  {$$.type = boolean; $$.yesorno = false; }
			;

opt_func_decl_list	: func_decl_list
			| /* epsilon */
			;

func_decl_list		: func_decl_list func_decl
			| func_decl
			;

func_decl		: ID{   
						addEntry($1); 
						tables[tables.size()-1].entry[tables[tables.size()-1].entry.size()-1].kind = Kfunction;
						addSymbolTable(); funcflag = true;
					}
	   		  MK_LPAREN opt_param_list MK_RPAREN opt_type MK_SEMICOLON 
	   		  compound_stmt
			  END ID
			;

opt_param_list		: param_list
			| /* epsilon */
			;

param_list		: param_list MK_SEMICOLON param
			| param 
					
			;

param			: id_list MK_COLON type
				{
					//tables[tables.size()-1].entry[tables[tables.size()-1].entry.size()-1].kind = parameter;
					
					for (int i = 0; i < tables[tables.size()-1].entry.size(); ++i)
					{
						if (tables[tables.size()-1].entry[i].type == none1)
						{
							
						
							FunAtt funatt;
							funatt.attype = $3;
						// while(dimdim.size() != 0)
						// {
							// tables[tables.size()-1].entry[tables[tables.size()-1].entry.size()-1].dim.push_back(dimdim[dimdim.size()-1]);
							// //cout << tables[tables.size()-1].entry[tables[tables.size()-1].entry.size()-1].dim.back() << endl;
							// funatt.atdim.push_back(dimdim[dimdim.size()-1]);
							// dimdim.pop_back();
							tables[tables.size()-1].entry[i].dim = dimdim;
							funatt.atdim = dimdim;
						//}
						
							tables[tables.size()-2].entry[tables[tables.size()-2].entry.size()-1].funatt.push_back(funatt);
						}
					}
					dimdim.clear();
					editEntry($3,parameter);
				} 
			;

id_list			: id_list MK_COMMA ID { addEntry($3);}
			| ID { addEntry($1);}
			;

opt_type		: MK_COLON type	
					{

						
						//editEntry($2, function);
						tables[tables.size()-2].entry[tables[tables.size()-2].entry.size()-1].type = $2;
						tables[tables.size()-2].entry[tables[tables.size()-2].entry.size()-1].dim = dimdim;
						//cout << "dimdim: " << tables[tables.size()-2].entry[tables[tables.size()-2].entry.size()-1].dim.size() << endl;
						dimdim.clear();
						
					}
			| /* epsilon */
			;

type			: scalar_type{$$ = $1;}
			| array_type{$$ = $1;}
			;

scalar_type		: INTEGER{$$ = integer;}
			| REAL{$$ = real;}
			| BOOLEAN{$$ = boolean;}
			| STRING{$$ = Tstring;}
			;

array_type		: ARRAY int_const TO int_const OF type{dimdim.push_back($4-$2+1); $$ = $6; }
			;

stmt			: compound_stmt
			| simple_stmt
			| cond_stmt
			| while_stmt
			| for_stmt
			| return_stmt
			| proc_call_stmt
			;

compound_stmt		: BEG {if(!funcflag){addSymbolTable(); } funcflag = false;}
			  opt_decl_list
			  opt_stmt_list
			  END { tables[tables.size()-1].PrintTable(); subSymbolTable(); }
			;

opt_stmt_list		: stmt_list
			| /* epsilon */
			;

stmt_list		: stmt_list stmt
			| stmt
			;

simple_stmt		: var_ref OP_ASSIGN boolean_expr MK_SEMICOLON
			| PRINT boolean_expr MK_SEMICOLON
			| READ boolean_expr MK_SEMICOLON
			;

proc_call_stmt		: ID MK_LPAREN opt_boolean_expr_list MK_RPAREN MK_SEMICOLON
			;

cond_stmt		: IF boolean_expr THEN
			  opt_stmt_list
			  ELSE
			  opt_stmt_list
			  END IF
			| IF boolean_expr THEN opt_stmt_list END IF
			;

while_stmt		: WHILE boolean_expr DO
			  opt_stmt_list
			  END DO
			;

for_stmt		: FOR ID{ 
							if (forvar.size() == 0)
							{
								forfor tempfor;
								strncpy(tempfor.forname, $2, 32);
								forvar.push_back(tempfor); 
								forflag++; 
							}
							else
							{
								for (int i = 0; i < forvar.size(); ++i)
								{
									//cout << "hfkfyf:" << forvar[i].forname;
									if (strcmp($2, forvar[i].forname) == 0)
									{
										cout << "<Error> found in Line " << linenum << ": symbol " << $2 << " is redeclared" << endl;
										
									}
									else
									{
										forfor tempfor;
										strncpy(tempfor.forname, $2, 32);
										forvar.push_back(tempfor); 
										forflag++;
									}
								}
							}
							//cout << "for level: " << forvar.size() << endl;
						} 
			  OP_ASSIGN int_const TO int_const DO
			  opt_stmt_list
			  END DO{if(forflag > 0 ){forvar.pop_back(); forflag--;}}
			;

return_stmt		: RETURN boolean_expr MK_SEMICOLON
			;

opt_boolean_expr_list	: boolean_expr_list
			| /* epsilon */
			;

boolean_expr_list	: boolean_expr_list MK_COMMA boolean_expr
			| boolean_expr
			;

boolean_expr		: boolean_expr OP_OR boolean_term
			| boolean_term
			;

boolean_term		: boolean_term OP_AND boolean_factor
			| boolean_factor
			;

boolean_factor		: OP_NOT boolean_factor 
			| relop_expr
			;

relop_expr		: expr rel_op expr
			| expr
			;

rel_op			: OP_LT
			| OP_LE
			| OP_EQ
			| OP_GE
			| OP_GT
			| OP_NE
			;

expr			: expr add_op term
			| term
			;

add_op			: OP_ADD
			| OP_SUB
			;

term			: term mul_op factor
			| factor
			;

mul_op			: OP_MUL
			| OP_DIV
			| OP_MOD
			;

factor			: var_ref
			| OP_SUB var_ref
			| MK_LPAREN boolean_expr MK_RPAREN
			| OP_SUB MK_LPAREN boolean_expr MK_RPAREN
			| ID MK_LPAREN opt_boolean_expr_list MK_RPAREN
			| OP_SUB ID MK_LPAREN opt_boolean_expr_list MK_RPAREN
			| literal_const
			;

var_ref			: ID
			| var_ref dim
			;

dim			: MK_LB boolean_expr MK_RB
			;

%%

int yyerror( char *msg )
{
	(void) msg;
	fprintf( stderr, "\n|--------------------------------------------------------------------------\n" );
	fprintf( stderr, "| Error found in Line #%d: %s\n", linenum, buf );
	fprintf( stderr, "|\n" );
	fprintf( stderr, "| Unmatched token: %s\n", yytext );
	fprintf( stderr, "|--------------------------------------------------------------------------\n" );
	exit(-1);
}


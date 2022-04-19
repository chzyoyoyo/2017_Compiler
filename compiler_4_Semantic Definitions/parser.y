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
//extern char argue[33];
int yyerror(char* );
bool funcflag = false;
int forflag = 0;
std::vector<int> dimdim;


std::vector<forfor> forvar;
std::vector<int> errfor;
char argue[33];
//char *proname;
int modflag;
int paracount = 0;
std::vector<Boolexpr> exprlist;
// int arrparadim = 0;
// std::vector<int> arrparadims;
int cancel = 0;
int perfect = 0;
//const char* kindToStr[] = {"program", "function", "parameter", "variable", "constant"};
extern const char* typeToStr[];// = {"integer", "real", "boolean", "string", " ","void"};

%}



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
%type <entries> var_ref
%type <boolexpr> factor
%type <boolexpr> term
%type <boolexpr> expr
%type <boolexpr> relop_expr
%type <boolexpr> boolean_factor
%type <boolexpr> boolean_term
%type <boolexpr> boolean_expr 
%type <boolexpr> condition 
// %type <exprlist> boolean_expr_list
// %type <exprlist> opt_boolean_expr_list


/* start symbol */
%start program
%%

program			: ID MK_SEMICOLON 
				{ 
					if (strcmp($1,argue)!=0)
					{
						perfect = 1;
						cout << "<Error> found in Line " << linenum << ": program beginning ID inconsist with file name" << endl;
						
					}
					
						addSymbolTable(); 
						addEntry($1);
						editEntry(none1, program);
				}
				  program_body
				  END ID { 
				  			if (strcmp($6,$1)!=0)
				  			{
				  				perfect = 1;
				  				cout << "<Error> found in Line " << linenum << ": program end ID inconsist with the beginning ID" << endl;
				  			}
				  			if (strcmp($6,argue)!=0)
				  			{
				  				perfect = 1;
				  				cout << "<Error> found in Line " << linenum << ": program end ID inconsist with file name" << endl;
				  			}
				  			else
				  			{
					  			tables[tables.size()-1].PrintTable() ;
					  			subSymbolTable(); 
					  		}
				  		 }
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
	   		  MK_LPAREN opt_param_list MK_RPAREN opt_type 
	   		  {
	   		  	if (tables[tables.size()-2].entry[tables[tables.size()-2].entry.size()-1].dim.size() != 0)
	   		  	{
	   		  		perfect = 1;
	   		  		cout << "<Error> found in Line " << linenum << ": a function cannot return an array type" << endl;
	   		  		cancel = 1;	   		  	
	   		  	}
	   		  }
	   		  MK_SEMICOLON 
	   		  compound_stmt
			  END ID{
			  			if (strcmp($1,$11)!=0)
			  			{
			  				perfect = 1;
			  				cout << "<Error> found in Line " << linenum << ": function end ID inconsist with the beginning ID" << endl;			  				
			  				
			  			}
					}	
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
							// // << tables[tables.size()-1].entry[tables[tables.size()-1].entry.size()-1].dim.back() << endl;
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
						// << "dimdim: " << tables[tables.size()-2].entry[tables[tables.size()-2].entry.size()-1].dim.size() << endl;
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

array_type		: ARRAY int_const TO int_const OF type
				    {
				    	if($2>=$4)
				    	{
							perfect = 1;
							cout << "<Error> found in Line " << linenum << ": wrong dimension declaration for array" << endl;
						}
						
						dimdim.push_back($4-$2+1); 
						$$ = $6; 
				    }
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
			  END {   
			  		if (cancel == 0)
			  		{
			  			tables[tables.size()-1].PrintTable();
			  		}
			  		else
			  		{
			  			tables[0].entry.pop_back();
			  			cancel = 0;
			  		}
			  		subSymbolTable();
			  	  }
			;

opt_stmt_list		: stmt_list 
			| /* epsilon */
			;

stmt_list		: stmt_list stmt
			| stmt
			;

simple_stmt		: var_ref OP_ASSIGN boolean_expr
					{
						// if ($1.type != none1 && $3.type != none1)
						// {
						int i;
						for (i = 0; i < forvar.size(); ++i)
						{	
							if (strcmp($1.name, forvar[i].forname) == 0)
							{
								perfect = 1;
								cout << "<Error> found in Line " << linenum << ": loop variable cannot be assigned" << endl;
								break;
							}
						}
						if (i == forvar.size())
						{
							if ($1.kind == constant)
							{
								perfect = 1;
								cout << "<Error> found in Line " << linenum << ": constant " << $1.name << " cannot be assigned" << endl;
							}
							if ($1.type != $3.type)
							{
								if ($1.type != real || $3.type != integer)
								{

									perfect = 1;
									cout << "<Error> found in Line " << linenum << ": type mismatch, LHS = ";
									if ($1.type == none1)
									{
										cout << "  ," << " RHS = " ;
									}
									else if ($1.type == void3)
									{
										cout << "void," << " RHS = " ;
									}
									else
										cout << typeToStr[$1.type] << " RHS = " ;
									if ($3.type == none1)
									{
										cout << "  " << endl ;
									}
									else if ($3.type == void3)
									{
										cout << "void" << endl ;
									}
									else
										cout << typeToStr[$3.type] << endl;
								}

							}
							else if ($1.dim.size() != 0 || $3.dimnum != 0)
							{
								perfect = 1;
								cout << "<Error> found in Line " << linenum << ": array assignment is not allowed" << endl;
							}
						}
							
						//}
					}
			  MK_SEMICOLON
			| PRINT boolean_expr 
				{
					if ($2.dimnum != 0 || $2.type == none1)
					{
						perfect = 1;
						cout << "<Error> found in Line " << linenum << ": operand of print statement is invalid" << endl;
					}
				}
			MK_SEMICOLON
			| READ boolean_expr 
				{
					if ($2.dimnum != 0 || $2.type == none1)
					{
						perfect = 1;
						cout << "<Error> found in Line " << linenum << ": operand of print statement is invalid" << endl;
					}
				}
			MK_SEMICOLON
			;

proc_call_stmt		: ID MK_LPAREN opt_boolean_expr_list MK_RPAREN
						{
							int j = 0;
							int i;
							for (i = tables.size()-1; i > -1; i--)
							{
								for (j = 0; j < tables[i].entry.size(); ++j)
								{
									if (strcmp($1, tables[i].entry[j].name) == 0 && tables[i].entry[j].kind == Kfunction)
									{
										// if (tables[i].entry[j].type != none1)
										// {
										// 	 << "<Error> found in Line " << linenum << ": a procedure is a function that has no return value" << endl;
										// }
										if (tables[i].entry[j].funatt.size() > exprlist.size())
										{
											perfect = 1;
											cout << "<Error> found in Line " << linenum << ": too few arguments to function '" << tables[i].entry[j].name << "'" << endl;
										}
										else if (tables[i].entry[j].funatt.size() < exprlist.size())
										{
											perfect = 1;
											cout << "<Error> found in Line " << linenum << ": too many arguments to function '" << tables[i].entry[j].name << "'" << endl;
										}
										else
										{
											for (int k = 0; k < exprlist.size(); ++k)
											{
												if (tables[i].entry[j].funatt[k].attype != exprlist[k].type )
												{
													if (tables[i].entry[j].funatt[k].attype != real ||  exprlist[k].type != integer)
													{
														perfect = 1;
														cout << "<Error> found in Line " << linenum << ": parameter type mismatch " << endl;
													}
												}
												if (tables[i].entry[j].funatt[k].atdim != exprlist[k].dim)
												{
													perfect = 1;
													cout << "<Error> found in Line " << linenum << ": parameter type mismatch " << endl;
												}
											}
										}

										break;
									}

								}
								if (strcmp($1, tables[i].entry[j].name ) == 0 && tables[i].entry[j].kind == Kfunction)
									break;
							}

							if (i == -1)
							{
								perfect = 1;
								cout << "<Error> found in Line " << linenum << ": function '" << $1 << "' does not exist" << endl;
								//$$ = none1;
							}
							exprlist.clear();
						}
					 MK_SEMICOLON
			;

cond_stmt		: IF condition
				 THEN
				 opt_stmt_list
			  ELSE
			  opt_stmt_list
			  END IF
			| IF condition
			THEN opt_stmt_list END IF
			;

condition     	: boolean_expr
				{
					if ($1.type != boolean)
					{
						perfect = 1;
						cout << "<Error> found in Line " << linenum << ": The conditional expression part of conditional statements must be Boolean types" << endl;
					}
				}

while_stmt		: WHILE boolean_expr 
					{
						if ($2.type != boolean)
						{
							perfect = 1;
							cout << "<Error> found in Line " << linenum << ": The conditional expression part of while statements must be Boolean types" << endl;
						}
					}
			  DO
			  opt_stmt_list
			  END DO
			;

for_stmt		: FOR ID{ 

							int err = 0;
							if (forvar.size() == 0)
							{
								forfor tempfor;
								strncpy(tempfor.forname, $2, 32);
								//cout << tempfor.forname << endl;
								forvar.push_back(tempfor); 
								forflag++;
							}
							else
							{
								int forsize = forvar.size();
								for (int i = 0; i < forsize; ++i)
								{
									// << "hfkfyf:" << forvar[i].forname;
									if (strcmp($2, forvar[i].forname) == 0)
									{
										perfect = 1;
										cout << "<Error> found in Line " << linenum << ": symbol " << $2 << " is redeclared" << endl;
										err++;
										break;
									}
								}
								if (err == 0)
								{
									forfor tempfor;
									strncpy(tempfor.forname, $2, 32);
									//cout << tempfor.forname << endl;
									forvar.push_back(tempfor); 
									forflag++;
								}
							}
							// << "for level: " << forvar.size() << endl;
							errfor.push_back(err);
						} 
			  OP_ASSIGN int_const TO int_const 
			  	{
			  		if ($5 > $7)
			  		{
			  			perfect = 1;
			  			cout << "<Error> found in Line " << linenum << ": an iteration count must be in the incremental order" << endl;
			  		}
			  	}
			  DO
			  opt_stmt_list
			  END DO{if(forflag > 0 && errfor.back() == 0){forvar.pop_back(); forflag--;} errfor.pop_back();}
			;

return_stmt		: RETURN boolean_expr 
					{
						if (tables[tables.size()-1].level == 0)
						{
							perfect = 1;
							cout << "<Error> found in Line " << linenum << ": program has no return value" << endl;
						}
						else if (tables[tables.size()-2].entry.back().type != $2.type )
						{
							
							perfect = 1;
							cout << "<Error> found in Line " << linenum << ": The type of the return statement must be the same as the return type of the function declaration." << endl;
						}
						else if ($2.dimnum != tables[tables.size()-2].entry.back().dim.size())
						{
							perfect = 1;
							cout << "<Error> found in Line " << linenum << ": return dimension number mismatch" << endl;
						}
					}
				MK_SEMICOLON
			;

opt_boolean_expr_list	: boolean_expr_list
			| /* epsilon */
			;

boolean_expr_list	: boolean_expr_list MK_COMMA boolean_expr
						{
							
							//arrparadims.push_back(arrparadim);
							exprlist.push_back($3); 
							 // << "??????" << endl;
						}
			| boolean_expr{ exprlist.push_back($1); }
			;

boolean_expr		: boolean_expr OP_OR boolean_term
						{

							if ($1.dimnum != 0 || $3.dimnum != 0)
							{
								perfect = 1;
								cout << "<Error> found in Line " << linenum << ": array arithmetic is not allowed " << endl;
								$$.type = none1;
							}
							$$.dimnum = 0;
							if ($1.type != boolean || $3.type != boolean)
							{
								perfect = 1;
								cout << "<Error> found in Line " << linenum << ": the operands must be boolean types" << endl;
								$$.type = none1;
							}
							else
								$$.type = boolean;
						}
			| boolean_term{$$ = $1;}
			;

boolean_term		: boolean_term OP_AND boolean_factor
						{

								if ($1.dimnum != 0 || $3.dimnum != 0)
							{
								perfect = 1;
								cout << "<Error> found in Line " << linenum << ": array arithmetic is not allowed " << endl;
								$$.type = none1;
							}
							$$.dimnum = 0;
							if ($1.type != boolean || $3.type != boolean)
							{
								perfect = 1;
								cout << "<Error> found in Line " << linenum << ": the operands must be boolean types" << endl;
								$$.type = none1;
							}
							else
								$$.type = boolean;
						}
			| boolean_factor{$$ = $1;}
			;

boolean_factor		: OP_NOT boolean_factor 
					{
						if ($2.dimnum != 0)
						{
							perfect = 1;
							cout << "<Error> found in Line " << linenum << ": array arithmetic is not allowed " << endl;
							$$.type = none1;
						}
						$$.dimnum = 0;
						if ($2.type != boolean )
						{
							perfect = 1;
							cout << "<Error> found in Line " << linenum << ": the operands must be boolean types" << endl;
							$$.type = none1;
						}
						else
							$$.type = boolean;
					}
			| relop_expr{$$ = $1;}
			;

relop_expr		: expr rel_op expr
					{
						if ($1.dimnum != 0 || $3.dimnum != 0)
						{
							perfect = 1;
							cout << "<Error> found in Line " << linenum << ": array arithmetic is not allowed " << endl;
							$$.type = none1;
						}
						$$.dimnum = 0;
						if (($1.type != real || $3.type != real) && ($1.type != integer || $3.type != integer))
						{
							perfect = 1;
							cout << "<Error> found in Line " << linenum << ": the operands are not both integer or both real" << endl;
							$$.type = none1;
						}
						else
							$$.type = boolean;
					}
			| expr{$$ = $1;}
			;

rel_op			: OP_LT
			| OP_LE
			| OP_EQ
			| OP_GE
			| OP_GT
			| OP_NE
			;

expr			: expr add_op term
					{
						if ($1.dimnum != 0 || $3.dimnum != 0)
						{
							perfect = 1;
							cout << "<Error> found in Line " << linenum << ": array arithmetic is not allowed " << endl;
							$$.type = none1;
						}
						$$.dimnum = 0;
						if ($1.type == Tstring && $3.type == Tstring)
						{
							$$.type = Tstring;
						}
						else if (($1.type != real && $1.type != integer) || ($3.type != real && $3.type != integer))
						{
							perfect = 1;
							cout << "<Error> found in Line " << linenum << ": the operands must be integer or real types" << endl;
							$$.type = none1;
						}
						else
						{
							$$ = $1;
							if ($3.type == real)
							{
								$$ = $3;
							}
						}
					}
			| term{$$ = $1;}
			;

add_op			: OP_ADD
			| OP_SUB
			;

term			: term mul_op factor
					{
						if ($1.dimnum != 0 || $3.dimnum != 0)
						{
							perfect = 1;
							cout << "<Error> found in Line " << linenum << ": array arithmetic is not allowed " << endl;
							$$.type = none1;
						}
						$$.dimnum = 0;
						if (modflag > 0)
						{
							if ($1.type != integer || $3.type != integer)
							{
								perfect = 1;
								cout << "<Error> found in Line " << linenum << ": the operands must be integer types" << endl;
								$$.type = none1;
							}
							else
								$$.type = integer;
							modflag = 0;
						}
						else if (($1.type != real && $1.type != integer) || ($3.type != real && $3.type != integer))
						{
							perfect = 1;
							cout << "<Error> found in Line " << linenum << ": the operands must be integer or real types" << endl;
							$$.type = none1;
						}
 

						else
						{
							$$ = $1;
							if ($3.type == real)
							{
								$$ = $3;
							}
						}
					}
			| factor{$$ = $1;}
			;

mul_op			: OP_MUL
			| OP_DIV
			| OP_MOD{modflag++;}
			;

factor			: var_ref
					{ 
						$$.dim = $1.dim;
						$$.dimnum = $1.dim.size();
						$$.type = $1.type;
						if ($1.kind == Kfunction)
						{
							perfect = 1;
							cout << "<Error> found in Line " << linenum << ": " << $1.name << "is a function" << endl;
							$$.type = none1;
						}
					 	
					}
			| OP_SUB var_ref
				{ 
					if ($2.dim.size() != 0)
					{
						perfect = 1;
						cout << "<Error> found in Line " << linenum << ": operand of unary - is not integer/real" << endl;
						$$.type = none1;
					}
					if ($2.type != real || $2.type != integer)
					{
						perfect = 1;
						cout << "<Error> found in Line " << linenum << ": operand of unary - is not integer/real" << endl;
						$$.type = none1;
					}
					else
						$$.type = $2.type;
					if ($2.kind == Kfunction)
					{
						perfect = 1;
						cout << "<Error> found in Line " << linenum << ": " << $2.name << "is a function" << endl;
						$$.type = none1;
					}
				 	
				}

			| MK_LPAREN boolean_expr MK_RPAREN
				{
					$$.dim = $2.dim;
					$$.dimnum = $2.dim.size();
					$$.type = $2.type;
				}
			| OP_SUB MK_LPAREN boolean_expr MK_RPAREN
				{
					$$.dim = $3.dim;
					$$.dimnum = $3.dim.size();
					$$.type = $3.type;
				}
			| ID MK_LPAREN opt_boolean_expr_list MK_RPAREN
				{
					int j = 0;
					int i;
					for (i = tables.size()-1; i > -1; i--)
					{
						for (j = 0; j < tables[i].entry.size(); ++j)
						{
							if (strcmp($1, tables[i].entry[j].name) == 0 && tables[i].entry[j].kind == Kfunction)
							{

								int flaggg = 0;
								if (tables[i].entry[j].type == none1)
								{
									$$.type = void3;
								}
								if (tables[i].entry[j].funatt.size() > exprlist.size())
								{
									perfect = 1;
									cout << "<Error> found in Line " << linenum << ": too few arguments to function '" << tables[i].entry[j].name << "'" << endl;
									$$.type = none1;

								}
								else if (tables[i].entry[j].funatt.size() < exprlist.size())
								{
									perfect = 1;
									cout << "<Error> found in Line " << linenum << ": too many arguments to function '" << tables[i].entry[j].name << "'" << endl;
									$$.type = none1;
								}

								else
								{
									for (int k = 0; k < exprlist.size(); ++k)
									{
										if (tables[i].entry[j].funatt[k].attype != exprlist[k].type)
										{
											if (tables[i].entry[j].funatt[k].attype != real ||  exprlist[k].type != integer)
											{
												perfect = 1;
												cout << "<Error> found in Line " << linenum << ": parameter type mismatch" << endl;
												flaggg = 1;
											}
										}
										if (tables[i].entry[j].funatt[k].atdim != exprlist[k].dim)
										{
											perfect = 1;
											cout << "<Error> found in Line " << linenum << ": parameter type mismatch" << endl;
											flaggg = 1;
										}
									}

									$$.type = tables[i].entry[j].type;
								}
								

								if (flaggg != 0)
								{
									$$.type = none1;
								}
								break;
							}

						}
						if (strcmp($1, tables[i].entry[j].name ) == 0 && tables[i].entry[j].kind == Kfunction)
							break;
					}
					if (i == -1)
					{
						perfect = 1;
						cout << "<Error> found in Line " << linenum << ": function '" << $1 << "' does not exist" << endl;
						//cout << i << endl;
						$$.type = none1;
					}
					exprlist.clear();
					$$.dimnum = 0;
				}
			| OP_SUB ID MK_LPAREN opt_boolean_expr_list MK_RPAREN
				{
					int j = 0;
					int i;
					for (i = tables.size()-1; i > -1; i--)
					{
						for (j = 0; j < tables[i].entry.size(); ++j)
						{
							if (strcmp($2, tables[i].entry[j].name) == 0 && tables[i].entry[j].kind == Kfunction)
							{
								int flaggg = 0;
								if (tables[i].entry[j].funatt.size() > exprlist.size())
								{
									perfect = 1;
									cout << "<Error> found in Line " << linenum << ": too few arguments to function '" << tables[i].entry[j].name << "'" << endl;
									$$.type = none1;
								}
								else if (tables[i].entry[j].funatt.size() < exprlist.size())
								{
									perfect = 1;
									cout << "<Error> found in Line " << linenum << ": too many arguments to function '" << tables[i].entry[j].name << "'" << endl;
									$$.type = none1;
								}
								else
								{
									for (int k = 0; k < exprlist.size(); ++k)
									{
										if (tables[i].entry[j].funatt[k].attype != exprlist[k].type)
										{
											if (tables[i].entry[j].funatt[k].attype != real ||  exprlist[k].type != integer)
											{
												perfect = 1;
												cout << "<Error> found in Line " << linenum << ": parameter type mismatch" << endl;
												flaggg = 1;
											}
										}
										if (tables[i].entry[j].funatt[k].atdim != exprlist[k].dim)
										{
											perfect = 1;
											cout << "<Error> found in Line " << linenum << ": parameter type mismatch" << endl;
											flaggg = 1;
										}
									}
								}

								if (tables[i].entry[j].type != real || tables[i].entry[j].type != integer)
								{
									perfect = 1;
									cout << "<Error> found in Line " << linenum << ": operand of unary - is not integer/real" << endl;
									$$.type = none1;
								}
								//exprlist.clear();
								$$.type = tables[i].entry[j].type;
								if (flaggg != 0)
								{
									$$.type = none1;
								}
								break;
							}

						}
						if (strcmp($2, tables[i].entry[j].name ) == 0 && tables[i].entry[j].kind == Kfunction)
							break;
					}
					if (i == -1)
					{
						perfect = 1;
						cout << "<Error> found in Line " << linenum << ": function '" << $2 << "' does not exist" << endl;
						$$.type = none1;
					}
					exprlist.clear();
					$$.dimnum = 0;
					
					
				}
			| literal_const{$$.type = $1.type; $$.dimnum = 0;}
			;

var_ref			: ID{
						int j = 0;
						int i;
						int k;
						for ( k = 0; k < forvar.size(); ++k)
						{	
							if (strcmp($1, forvar[k].forname) == 0)
							{
								//$$.name = forvar[k].forname;
								strncpy($$.name, forvar[k].forname, 33);
								break;
							}
						}
						if (k == forvar.size())
						{
							for (i = tables.size()-1; i > -1; i--)
							{
								for (j = 0; j < tables[i].entry.size(); ++j)
								{
									if (strcmp($1, tables[i].entry[j].name) == 0)
									{
										$$ = tables[i].entry[j];
										break;
									}

								}

										// cout   << i << "    " << j << endl;
										// cout << tables[i].entry.size() << endl;
								if (tables[i].entry.size() > 0)
								{
									if (strcmp($1, tables[i].entry[j].name) == 0)
										break;
								}
							}
						}
						if (i == -1 )
						{

								perfect = 1;
								cout << "<Error> found in Line " << linenum << ": symbol '" << $1 << "' does not exist" << endl;
								$$.type = none1;
							
						}
					}//////////如果我們要的是Array 怎麼辦
			| var_ref dim
				{
					$1.dim.pop_back();
					$$ = $1;
				}
			;

dim			: MK_LB boolean_expr 
				{
					if ($2.type != integer || $2.dimnum != 0)
					{
						perfect = 1;
						cout << "<Error> found in Line " << linenum << ": invalid array index" << endl;
					}
				}
			MK_RB
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


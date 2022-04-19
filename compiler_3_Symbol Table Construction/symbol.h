#include <vector>
#include <cstring>
#include <iostream>

using namespace std;

typedef struct 
{
	char forname[33];
}forfor;

typedef enum 
{
	program, Kfunction, parameter, variable, constant, none0
}Kind;

typedef enum 
{
	integer, real, boolean, Tstring, none1
}Type;

typedef struct
{
	vector<int> atdim;
	Type attype;
}FunAtt;

typedef struct
{
	Type type;
	int number;
	double realnum;
	char listring[100];
	bool yesorno;
	bool write;
	// iteral_const		: int_const
	// 		| OP_SUB int_const
	// 		| FLOAT_CONST
	// 		| OP_SUB FLOAT_CONST
	// 		| SCIENTIFIC
	// 		| OP_SUB SCIENTIFIC
	// 		| STR_CONST
	// 		| TRUE
	// 		| FALSE
}LIconst;

class entries
{
public:
	entries();
	~entries();
	
	char name[40]; 
	Kind kind;
	Type type;
	vector<int> dim;
	LIconst att;
	vector<FunAtt> funatt;


};

class table
{
public:
	table();
	~table();
	
	int level;
	vector<entries> entry;
	void PrintTable();



};

extern vector<table> tables;

void addEntry(char*);
void editEntry(Type, Kind);
void editEntryAtt(Kind, LIconst);

void addSymbolTable();
void subSymbolTable();



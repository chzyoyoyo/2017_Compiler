#include "symbol.h"
#include <vector>
#include <cstring>


using namespace std;

vector<table> tables;


extern int linenum;
extern vector<forfor> forvar;
extern int Opt_D;

const char* kindToStr[] = {"program", "function", "parameter", "variable", "constant"};
const char* typeToStr[] = {"integer", "real", "boolean", "string", "void"};

void addSymbolTable()
{

	table newtable;
	//printf("Symbol!\n");
	newtable.level = tables.size();
	//printf("push %d\n", newtable.level);
	tables.push_back(newtable);



}

void addEntry(char* name)
{
	entries newentry;
	strncpy(newentry.name, name, 33);
	// cout << "!!!!!!" << name << endl;
	// cout << "!!!!!!" << newentry.name << endl;
	for (int i = 0; i < tables[tables.size()-1].entry.size(); ++i)
	{
		
		if (strcmp(newentry.name, tables[tables.size()-1].entry[i].name) == 0)
		{
			cout << "<Error> found in Line " << linenum << ": symbol " << newentry.name << " is redeclared" << endl;
			return;
		}
	}
	for (int i = 0; i < forvar.size(); ++i)
	{
		
		if (strcmp(newentry.name, forvar[i].forname) == 0)
		{
			cout << "<Error> found in Line " << linenum << ": symbol " << newentry.name << " is redeclared" << endl;
			return;
		}
	}


	newentry.kind = none0;
	newentry.type = none1;
	newentry.att.write = false;
	//printf("%s\n", newentry.name);

	tables[tables.size()-1].entry.push_back(newentry);

}

void editEntry(Type type, Kind kind)
{
	for (int i = 0; i < tables[tables.size()-1].entry.size(); ++i)
	{
		
			

			if (tables[tables.size()-1].entry[i].type == none1 && tables[tables.size()-1].entry[i].kind != program && tables[tables.size()-1].entry[i].kind != Kfunction)
			{
				tables[tables.size()-1].entry[i].type = type;
				tables[tables.size()-1].entry[i].kind = kind;
			}
		

		
	}
}

void editEntryAtt(Kind kind, LIconst li)
{
	for (int i = 0; i < tables[tables.size()-1].entry.size(); ++i)
	{

		
		if (li.type == integer && tables[tables.size()-1].entry[i].att.write == false)
		{

			tables[tables.size()-1].entry[i].att.number = li.number;
			//cout << "gdhgdhjdj: " << li.number << endl;
		}
		
		else if (li.type == real && tables[tables.size()-1].entry[i].att.write == false)
		{
			tables[tables.size()-1].entry[i].att.realnum = li.realnum; 
		}

		else if (li.type == Tstring && tables[tables.size()-1].entry[i].att.write == false)
		{
			strcpy(tables[tables.size()-1].entry[i].att.listring, li.listring);
		}
		
		else if (li.type == boolean && tables[tables.size()-1].entry[i].att.write == false)
		{
			tables[tables.size()-1].entry[i].att.yesorno = li.yesorno;
		}
		tables[tables.size()-1].entry[i].att.write = true;
		
	}
}


void table::PrintTable() 
{
	if (Opt_D)
	{
	  // Print header.
	  int i;
	  for(i=0;i< 110;i++) {
	    printf("=");
	  }
	  printf("\n");
	  // printf("level = %d\n", level);
	  printf("%-33s%-11s%-11s%-17s%-11s\n","Name","Kind","Level","Type","Attribute");
	  for(i=0;i< 110;i++) {
	    printf("-");
	  }
	  printf("\n");

	  // Print contents.
	  for(i=0; i<entry.size(); i++) 
	  {
	    // Name
	    printf("%-33s", entry[i].name);

	    // Kind
	    printf("%-11s", kindToStr[entry[i].kind]);
	    
	    // Level
	    printf("%d%-10s", tables[tables.size()-1].level, (level==0? "(global)": "(local)"));

	    // Type
	    // char buf[200];
	    // TypeToString(buf, entries[i].type);
	    // printf("%-17s", buf);  
	    //cout << entry[i].dim.size();

	    if (entry[i].dim.size() != 0)
	    {

	    	string arstr;
	    	arstr = typeToStr[entry[i].type];
	    	arstr += " ";
	    	while(entry[i].dim.size() != 0)
	    	{
	    		char strrr[10];
	    		sprintf(strrr, "[%d]", entry[i].dim[entry[i].dim.size()-1]);
	    		arstr += strrr;
	    		entry[i].dim.pop_back();
	    	}
	    	printf("%-17s", arstr.c_str());
	    	//cout << "gkygiugiu";
	    }

	    else 
	    {
	    	printf("%-17s", typeToStr[entry[i].type]);
	    }


	    // Attribute
	    string output;
	    if (entry[i].kind == Kfunction) 
	    {
	      if (entry[i].funatt.size() > 0) 
	      {
	    	char strrr[10];

	        vector<FunAtt> v = entry[i].funatt;
	        output = typeToStr[v[0].attype];
	        while(v[0].atdim.size() != 0)
	        {
	        	sprintf(strrr, " [%d]", v[0].atdim[v[0].atdim.size()-1]);
	        	output +=  strrr ;
	        	v[0].atdim.pop_back();
	        }

	        for(int k=1; k<v.size(); k++) 
	        {
	          output += ", " ;
	          output += typeToStr[v[k].attype];
	          while(v[k].atdim.size() != 0)
		        {
		        	sprintf(strrr, "[%d]", v[k].atdim[v[k].atdim.size()-1]);
		        	output +=  strrr ;
		        	v[k].atdim.pop_back();
		        }
	        }
	        printf("%-11s", output.c_str());
	        //cout << entry[i].funatt.size();
	      }
	    } 
	    else if (entry[i].kind == constant) 
	    {
	      switch (entry[i].type) 
		    {
		        case integer: printf("%-11d", entry[i].att.number); break;
		        case real: printf("%-11f", entry[i].att.realnum); break;
		        case boolean: printf("%-11s", entry[i].att.yesorno? "true": "false"); break;
		        case Tstring: printf("\"%-11s\"", entry[i].att.listring); break;
		        default:;
		    }
	    }
	    printf("\n");
	  }

	  // Print
	  for(i=0;i< 110;i++) {
	    printf("-");
	  }
	  printf("\n");
	}
}






void subSymbolTable()
{

	//printf("pop %d\n", tables.size()-1);

	tables.pop_back();

}

entries::entries(){

}

entries::~entries(){

}

table::table() {

}

table::~table() {

}

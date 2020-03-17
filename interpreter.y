/***
 Purpose: TODO add purpose


first,second,asde
2a,"2b",asdd
3asdf,234a,asdf

table: line EOL multiline
	| line
line: cell COMMA line
	| cell
cell: QUOTE contents QUOTE
	| contents

 
**/

%{
#include <iostream>
#include <map>
#include <cstring>
#include <math.h>
#include <string.h>

extern "C" int yylex();
extern "C" int yyparse();

void yyerror(const char *s);

// Helper function to compare const char * for map iterator
class StrCompare {
public:
  bool operator ()(const char*a, const char*b) const {
	return strcmp(a,b) < 0;
  }
};


%}

/*** union of all possible data return types from grammar ***/
%union {
	char* sVal;
}

/*** Define token identifiers for flex regex matches ***/
%token COMMA
%token QUOTE
%token ESCAPEDQUOTE
%token CELLCONTENTS
%token WS
%token EOL
%token SOL

/*** Define return type for grammar rules ***/
%type<sVal> row
%type<sVal> cell

%type<sVal> CELLCONTENTS
%%

start: row cell EOL {
	std::string rowString($1), cellString($2), output;
	output = rowString + ",\"" + cellString + "\"";
	std::cout << "The input was " << output << std::endl << std::endl;

		} start
		|
		row EOL { // the row ended with a comma
			std::string rowString($1), output;
			output = rowString + ",\"\"";
			std::cout << "The input was " << output << std::endl << std::endl;
		  }
		|
	;
	
row: row cell COMMA{
	std::string rowString($1), cellString($2), output;
	output =  rowString + ",\"" + cellString + "\"";
  std::cout << "out: " << output << std::endl;
  free($$);
  $$ = (char*)malloc(sizeof(char) * output.length());
  strcpy($$, output.c_str()); // add quotes around cells
  printf("rcc: %s\n",$$);
}
| row COMMA {
  std::string rowString($1);
  free($$);
  $$ = (char*)malloc(sizeof(char) * (rowString.length() + 4));
  strcpy($$, (rowString + ",\"\"").c_str()); // add a blank cell
  printf("rcc: blank cell\n");
}
| cell COMMA {
  std::string cellString($1);
  free($$);
  $$ = (char*)malloc(sizeof(char) * (cellString.length() + 3));
  strcpy($$, ("\"" + cellString + "\"").c_str());
  printf("start of new row\n");
 }
| COMMA {
	free($$);
	$$ = (char*)malloc(sizeof(char) * 3);
	strcpy($$, "\"\"");
	printf("start of new row with empty cell\n");
  }
;

cell: CELLCONTENTS {
			printf("c: %s\n",$$);
		}
		| cell QUOTE {
			std::string cell1String($1);
			strcpy($$, (cell1String + "\\\"").c_str());
			printf("appending two cells: %s\n",$$);

		}
		| cell CELLCONTENTS {
			std::string cell1String($1), cell2String($2);
			strcpy($$, (cell1String + cell2String).c_str());
			printf("appending two cells: %s\n",$$);
			
		}
	| QUOTE {
			strcpy($$, "\\\"");
			printf("encountered quotes: %s\n",$$);
		}
	;

%%

int main(int argc, char **argv) {
	yyparse();
}

/* Display error messages */
void yyerror(const char *s) {
	printf("ERROR: %s\n", s);
}

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

/*** Define return type for grammar rules ***/
%type<sVal> row
%type<sVal> cell

%type<sVal> CELLCONTENTS
%%

start: row { 
				 printf("The input was%s\n\n", $1); 
		} start
	| /* NULL */
	;
	
row: cell COMMA row {
			std::string cellString($1), rowString($3);
			strcpy($$, (cellString + "," + rowString).c_str());
			printf("rcc: %s\n",$$);
		}
	|
		cell EOL {
			$$ = $1;
			printf("cell(row): %s\n",$$);
		}
	;

cell: QUOTE cell QUOTE {
			$$ = $2;
		}
	| CELLCONTENTS {
			std::string cellString($1);
			strcpy($$, ("\"" + cellString + "\"").c_str());
			printf("c: %s\n",$$);
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

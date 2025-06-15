%{
#include "parser.tab.h" 
#include <string.h>
%}

%%

"CREATE"|"Create"|"create"     { return CREATE; }
"DELETE"|"Delete"|"delete"|"del"     { return DELETE; }
"READ"|"Read"|"read"|"r"       { return READ; }

"ADD"|"Add"|"add"           { return ADD; }
"REMOVE"|"Remove"|"remove"|"rem"     { return REMOVE; }
"TOGGLE"|"Toggle"|"toggle"|"tgl"     { return TOGGLE; }

[a-zA-Z_][a-zA-Z0-9_]* {
    yylval.str = strdup(yytext);
    return ID;
}

";"          { return ';'; }
[ \t\r\n]+   { /* ignora espaços, tabs e quebras de linha */ }

.            { printf("Caractere inválido: %s\n", yytext); }

%%

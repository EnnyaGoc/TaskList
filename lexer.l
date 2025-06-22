%{
#include "parser.tab.h" 
#include <string.h>
%}

%%

"CREATE"|"Create"|"create"		          { return CREATE; }
"DELETE"|"Delete"|"delete"|"del"		  { return DELETE; }
"READ"|"Read"|"read"|"r"		          { return READ;   }

"ADD"|"Add"|"add"		                  { return ADD;    }
"REMOVE"|"Remove"|"remove"|"rem"|"rm"     { return REMOVE; }
"TOGGLE"|"Toggle"|"toggle"|"tgl" 		  { return TOGGLE; }

"LOAD"|"Load"|"load"                      { return LOAD;   }
"SAVE"|"Save"|"save"                      { return SAVE;   }

[a-zA-Z_][a-zA-Z0-9_]* {
    yylval.str = strdup(yytext);
    return ID;
}

";"          { return ';'; }
"?"          { 
	printf("Comandos válidos:\
	\
	\n\tOperações com Listas:\
	\n\t\tCREATE | Create | create\
	\n\t\tDELETE | Delete | delete | del\
	\n\t\tREAD | Read | read | r\
	\n\t\tLOAD | Load | load\
	\n\t\tSAVE | Save | save | save\
	\
	\n\tOperações com Tarefas: \
	\n\t\tADD | Add | add \
	\n\t\tREMOVE | Remove | remove | rem | rm\
	\n\t\tTOGGLE | Toggle | toggle | tgl\n");
	}
[ \t\r\n]+   { /* ignora espaços, tabs e quebras de linha */ }



.            { printf("Caractere inválido: %s\n", yytext); }

%%

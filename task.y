%{
#include <stdio.h>
#include <stdlib.h>
%}

%token CREATE DELETE READ ADD RM TOGGLE
%token <string> id

%%

program:
    commands
;

commands:
    command ';' commands
    | command
;

command:
    create_list
    | delete_list
    | read_list
    | add_task
    | remove_task
    | toggle_task
;

create_list:
    CREATE id {
        printf("Criando lista: %s\n", $3);
    }
;

delete_list:
    DELETE id {
        printf("Deletando lista: %s\n", $3);
    }
;

read_list:
    READ id {
        printf("Lendo lista %s", $3);
    }
    | READ {
        printf("Lendo todas as listas\n");
    }
;

add_task:
    ADD LIST id TASK id {
        printf("Adicionando tarefa %s à lista %s\n", $3, $2);
    }
;

remove_task:
    RM LIST id TASK id {
        printf("Removendo tarefa %s da lista %s\n", $3, $2);
    }
;

toggle_task:
    TOGGLE LIST id TASK id {
        printf("Alternando o status da tarefa %s na lista %s\n", $3, $2);
    }
;

%%

int main(void) {
    yyparse();
    return 0;
}

int yyerror(char *s) {
    fprintf(stderr, "Erro: %s\n", s);
    return 0;
}
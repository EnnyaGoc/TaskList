%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#include "parser.tab.h"  


#define MAX_LISTAS 100
#define MAX_TAREFAS 100


struct id_list {
    char* id;
    struct id_list* next;
};

typedef struct {
	char* task_name;
	bool completed;	
} Task;

typedef struct {
    char* nome;
    Task* tarefas[MAX_TAREFAS];
    int qtd_tarefas;
} Lista;

Lista listas[MAX_LISTAS];
int qtd_listas = 0;


void yyerror(const char *s);
int yylex(void);

int find_lista(const char* nome);
void print_listas(void);
int create_lista(const char* nome);




%}

%union {
    char* str;
	struct id_list* idlist;
    // int op;
}

%token <str> ID
%type <idlist> N;

%type <str> list_operations
%token CREATE READ DELETE

%type <str> task_operations
%token ADD REMOVE TOGGLE


%%

seq: command ';' seq 
| command ';'
;

command: list_command | task_command ;

list_operations:
    CREATE { $$ = "CREATE"; }
	| DELETE { $$ = "DELETE"; }
    | READ { $$ = "READ"; }
;

list_command:
    list_operations N {
        if ($1 == "CREATE") {
			printf("Criando lista(s)...\n");
			struct id_list* current = $2;

			while (current) {
				int res = create_lista(current->id);
				if ( res == -1) {
					printf("Erro ao criar lista: %s\n", current->id);
				} else {
					printf("Lista criada: %s\n", current->id);
				}
				current = current->next;
			}
		} 
		if ($1 == "DELETE") {
			printf("Deletando lista(s)...\n");
			struct id_list* current = $2;

			while (current) {
				int i = find_lista(current->id);
				if (i != -1) {
					// Não verifiquei se isso pode grear algum bug...
					free(listas[i].nome);
					for (int j = 0; j < listas[i].qtd_tarefas; j++) {
						free(listas[i].tarefas[j]);
					}
					
					// OK, mas Porque?
					for (int j = i; j < qtd_listas - 1; j++) {
						listas[j] = listas[j + 1];
					}

					qtd_listas--;
					printf("Lista %s deletada.\n", current->id);
				} else {
					printf("Erro. '%s' nao encontrada.\n", current->id);
				}
				current = current->next;
			}
			
		} 
		if ($1 == "READ") {
			printf("Lendo lista(s):\n", $2);
			struct id_list* current = $2;
			while (current) {
				// Verifica se a lista existe
				int i = find_lista(current->id);
				if (i != -1) {
					printf("%s:\n", current->id);

					// Imprime as tarefas da lista
					if (listas[i].qtd_tarefas == 0) {
						printf("Lista %s está vazia.\n", listas[i].nome);
					} else {
						for (int j = 0; j < listas[i].qtd_tarefas; j++) {
							printf(" - %s - %s\n", listas[i].tarefas[j]->task_name, (listas[i].tarefas[j]->completed) ? "Completa" : "Pendente");
						}
					}
				} else {
					printf("Erro. '%s' nao encontrada.\n", current->id);
				}
				current = current->next;
			}
		}
		// Ideia: Autoremove 
		// Remover automaticamente tarefas já concluidas das listas informadas
		
		free($2);
    }

    | READ {
		printf("Lendo todas as listas:\n");
		print_listas();
    }
;

task_operations:
	ADD { $$ = "ADD"; }
	| REMOVE { $$ = "REMOVE"; }
	| TOGGLE { $$ = "TOGGLE"; }
;

task_command:
	task_operations ID N {
		int i = find_lista($2);
		if (i == -1) {
			printf("Erro. Lista '%s' nao encontrada.\n", $2);
		} else {
			struct id_list* current = $3;
			while (current) {
				if ($1 == "ADD") {
					if (listas[i].qtd_tarefas < MAX_TAREFAS) {

						Task* new_task = malloc(sizeof(Task));
						new_task->task_name = strdup(current->id);
						new_task->completed = false;

						listas[i].tarefas[listas[i].qtd_tarefas] = new_task;
						listas[i].qtd_tarefas++;


						printf("Tarefa '%s' adicionada à lista '%s'.\n", current->id, listas[i].nome);
					} else {
						printf("Limite de tarefas atingido para a lista '%s'.\n", listas[i].nome);
					}
				} 
				else if ($1 == "REMOVE") {
					int found = 0;
					for (int j = 0; j < listas[i].qtd_tarefas; j++) {
						if (strcmp(listas[i].tarefas[j]->task_name, current->id) == 0) {

							free(listas[i].tarefas[j]);

							// Move o último elemento para a posição do removido
							listas[i].tarefas[j] = listas[i].tarefas[listas[i].qtd_tarefas - 1];
							listas[i].tarefas[listas[i].qtd_tarefas - 1] = NULL;
							listas[i].qtd_tarefas--;

							printf("Tarefa '%s' removida da lista '%s'.\n", current->id, listas[i].nome);
							found = 1;
							break;
						}
					}
					if (!found) {
						printf("Tarefa '%s' nao encontrada na lista '%s'.\n", current->id, listas[i].nome);
					}
				} else if ($1 == "TOGGLE") {
					int found = 0;
					for (int j = 0; j < listas[i].qtd_tarefas; j++) {
						if (strcmp(listas[i].tarefas[j]->task_name, current->id) == 0) {
							
							listas[i].tarefas[j]->completed = !listas[i].tarefas[j]->completed;
							printf("Tarefa '%s' na lista '%s' atualizada.\n", current->id, listas[i].nome);
							found = 1;
							break;
						}
					}
					if (!found) {
						printf("Tarefa '%s' nao encontrada na lista '%s'.\n", current->id, listas[i].nome);
					}
				}
				current = current->next;
			}
		}
		free($3);
	}


N:
    ID N {
		struct id_list* new_node = malloc(sizeof(struct id_list));
		new_node->id = $1;
		new_node->next = $2;
        $$ = new_node;
    }
    | ID {
		struct id_list* new_node = malloc(sizeof(struct id_list));
		new_node->id = $1;
		new_node->next = NULL;
		$$ = new_node;
    }
;
%%

/* Implementação de funções em C */


int create_lista(const char* nome) {
	if (qtd_listas >= MAX_LISTAS) {
		printf("Limite de listas atingido.\n");
		return -1;
	}
	listas[qtd_listas].nome = strdup(nome);
	listas[qtd_listas].qtd_tarefas = 0;
	qtd_listas++;
	return 1;
}


int find_lista(const char* nome) {
	for (int i = 0; i < qtd_listas; i++) {
		if (strcmp(listas[i].nome, nome) == 0) {
			return i;
		}
	}
	return -1; 
}


void print_listas(){
	if (qtd_listas == 0) {
		printf("Nenhuma lista criada.\n");
		return;
	}
	for (int i = 0; i < qtd_listas; i++) {
		printf("Lista %s contém %d tarefas\n", listas[i].nome, listas[i].qtd_tarefas);
	}
}

void free_id_list(struct id_list* node) {
    while (node) {
        struct id_list* tmp = node;
        node = node->next;
        free(tmp->id);
        free(tmp);
    }
}	


int main(void) {
    return yyparse();
}

void yyerror(const char *s) {
    fprintf(stderr, "Erro de sintaxe: %s\n", s);
}

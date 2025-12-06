%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(); 
void yyerror(const char *s);
extern FILE *yyin;

/* --- Data Types --- */
#define TYPE_SHONGKHA 1
#define TYPE_DOSHOMIK 2
#define TYPE_LEKHA 3

/* --- Symbol Table Structure --- */
union Value {
    int intVal;
    float floatVal;
    char *strVal;
};

struct Symbol {
    char *name;
    int type;
    union Value value;
};

/* Simple Symbol Table (Max 100 variables) */
struct Symbol symbolTable[100];
int symbolCount = 0;

/* Function: Variable Add kora */
void insertSymbol(char *name, int type) {
    // Check jodi already thake
    for(int i=0; i<symbolCount; i++) {
        if(strcmp(symbolTable[i].name, name) == 0) {
            yyerror("Error: Ei variable-ti agei declare kora hoyeche!");
            return;
        }
    }
    symbolTable[symbolCount].name = strdup(name);
    symbolTable[symbolCount].type = type;
    symbolCount++;
}

/* Function: Variable Khuje Ber kora */
struct Symbol* findSymbol(char *name) {
    for(int i=0; i<symbolCount; i++) {
        if(strcmp(symbolTable[i].name, name) == 0) {
            return &symbolTable[i];
        }
    }
    return NULL;
}
%}

/* --- Bison Values --- */
%union {
    char *str;
    int intVal;
    float floatVal;
}

/* --- Token Declarations --- */
%token TOKEN_SHONGKHA TOKEN_DOSHOMIK TOKEN_LEKHA
%token TOKEN_PORO TOKEN_DEKHAW
%token OP_ASSIGN SEMICOLON

%token <str> TOKEN_IDENTIFIER
%token <intVal> TOKEN_SHONGKHA_VALUE
%token <floatVal> TOKEN_DOSHOMIK_VALUE
%token <str> TOKEN_LEKHA_VALUE

/* Type define kora jate value pass kora jay */
%type <intVal> expression_int
%type <floatVal> expression_float
%type <str> expression_str

%start program

%%

program:
    statements
    ;

statements:
    | statements statement
    ;

statement:
    variable_declaration
    | assignment_statement
    | print_statement
    | input_statement
    ;

/* --- 1. Variable Declaration --- */
variable_declaration:
    TOKEN_SHONGKHA TOKEN_IDENTIFIER SEMICOLON {
        insertSymbol($2, TYPE_SHONGKHA);
        printf("Declared shongkha: %s\n", $2);
    }
    | TOKEN_DOSHOMIK TOKEN_IDENTIFIER SEMICOLON {
        insertSymbol($2, TYPE_DOSHOMIK);
        printf("Declared doshomik: %s\n", $2);
    }
    | TOKEN_LEKHA TOKEN_IDENTIFIER SEMICOLON {
        insertSymbol($2, TYPE_LEKHA);
        printf("Declared lekha: %s\n", $2);
    }
    ;

/* --- 2. Input/Output Operations --- */

/* Output (dekhaw) */
print_statement:
    TOKEN_DEKHAW TOKEN_IDENTIFIER SEMICOLON {
        struct Symbol* s = findSymbol($2);
        if(s) {
            if(s->type == TYPE_SHONGKHA) printf("Output: %d\n", s->value.intVal);
            else if(s->type == TYPE_DOSHOMIK) printf("Output: %.2f\n", s->value.floatVal);
            else if(s->type == TYPE_LEKHA) printf("Output: %s\n", s->value.strVal);
        } else {
            yyerror("Undeclared variable in dekhaw!");
        }
    }
    | TOKEN_DEKHAW TOKEN_LEKHA_VALUE SEMICOLON {
        printf("Output: %s\n", $2);
    }
    ;

/* Input (poro) */
input_statement:
    TOKEN_PORO TOKEN_IDENTIFIER SEMICOLON {
        struct Symbol* s = findSymbol($2);
        if(s) {
            printf("Input chai (%s): ", s->name);
            if(s->type == TYPE_SHONGKHA) scanf("%d", &s->value.intVal);
            else if(s->type == TYPE_DOSHOMIK) scanf("%f", &s->value.floatVal);
            else if(s->type == TYPE_LEKHA) {
                s->value.strVal = malloc(100);
                scanf("%s", s->value.strVal);
            }
        } else {
            yyerror("Undeclared variable in poro!");
        }
    }
    ;

/* --- Assignment (Simple Value Assign) --- */
assignment_statement:
    TOKEN_IDENTIFIER OP_ASSIGN expression_int SEMICOLON {
        struct Symbol* s = findSymbol($1);
        if(s && s->type == TYPE_SHONGKHA) s->value.intVal = $3;
    }
    | TOKEN_IDENTIFIER OP_ASSIGN expression_float SEMICOLON {
        struct Symbol* s = findSymbol($1);
        if(s && s->type == TYPE_DOSHOMIK) s->value.floatVal = $3;
    }
    | TOKEN_IDENTIFIER OP_ASSIGN TOKEN_LEKHA_VALUE SEMICOLON {
        struct Symbol* s = findSymbol($1);
        if(s && s->type == TYPE_LEKHA) s->value.strVal = $3;
    }
    ;

/* Helper rules for values */
expression_int: TOKEN_SHONGKHA_VALUE { $$ = $1; };
expression_float: TOKEN_DOSHOMIK_VALUE { $$ = $1; };
expression_str: TOKEN_LEKHA_VALUE { $$ = $1; };

%%

int main(int argc, char* argv[]) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if(!yyin) {
            printf("File khola jachhe na: %s\n", argv[1]);
            return 1;
        }
    }
    yyparse();
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int yywrap() { return 1; }
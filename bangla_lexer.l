%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "bangla_parser.tab.h"
%}

/* Multi-line comment (mcc) er jonno state */
%x MCC_COMMENT

%%

    /* --- 1. Keywords for Data Types --- */
"shongkha"    { return TOKEN_SHONGKHA; }
"doshomik"    { return TOKEN_DOSHOMIK; }
"lekha"       { return TOKEN_LEKHA; }

    /* --- 2. Keywords for Input/Output --- */
"poro"        { return TOKEN_PORO; }
"dekhaw"      { return TOKEN_DEKHAW; }

    /* --- 3. Comments --- */
"cc".* { /* Single-line comment: Ignore koro */ }
"mcc"              { BEGIN(MCC_COMMENT); }
<MCC_COMMENT>"mcc" { BEGIN(INITIAL); }
<MCC_COMMENT>.     { /* Multi-line er bhitorer text ignore koro */ }
<MCC_COMMENT>\n    { /* Multi-line er new line ignore koro */ }

    /* --- Values (Numbers & Strings) --- */
[0-9]+\.[0-9]+  { 
    yylval.floatVal = atof(yytext); 
    return TOKEN_DOSHOMIK_VALUE; 
}

[0-9]+          { 
    yylval.intVal = atoi(yytext); 
    return TOKEN_SHONGKHA_VALUE; 
}

\"[^\"]*\"      { 
    /* String theke quotation mark remove kora hocche */
    yytext[strlen(yytext)-1] = '\0'; 
    yylval.str = strdup(yytext+1);   
    return TOKEN_LEKHA_VALUE; 
}

    /* --- Variable Names (Identifiers) --- */
[a-zA-Z_][a-zA-Z0-9_]* { 
    yylval.str = strdup(yytext); 
    return TOKEN_IDENTIFIER; 
}

    /* --- Operators & Punctuation --- */
"="     { return OP_ASSIGN; }
";"     { return SEMICOLON; }

    /* --- Whitespace --- */
[ \t\n\r]+ { /* Space, Tab, Newline ignore koro */ }

    /* --- Unknown Character Error --- */
.       { printf("LEXICAL ERROR: Unknown character '%s'\n", yytext); }

%%
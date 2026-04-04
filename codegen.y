%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
int yyerror(const char *s);
extern char *yytext;
FILE *out;
int is_cpp = 0;

char *append_code(const char *a, const char *b) {
    char *res = malloc(strlen(a) + strlen(b) + 1);
    strcpy(res, a);
    strcat(res, b);
    return res;
}
%}

%union {
    char *str;
}

%token <str> NUMBER STRING ID TYPE
%token PRINT IF THEN ELSE END WHILE FOR TO EQ

%left '+' '-'
%left '*' '/'
%left '>' '<' EQ

%type <str> statement statements expression

%%
program:
    statements {
        if (is_cpp) {
            fprintf(out, "#include <iostream>\n#include <string>\nusing namespace std;\nint main() {\n%sreturn 0;\n}\n", $1);
        } else {
            fprintf(out, "#include <stdio.h>\n#include <string.h>\nint main() {\nchar buffer[256];\n%sreturn 0;\n}\n", $1);
        }
        free($1);
    }
    ;

statements:
    statements statement { $$ = append_code($1, $2); free($1); free($2); }
    | statement { $$ = $1; }
    ;

statement:
    PRINT expression {
        char *buf = malloc(1024);
        if (is_cpp)
            sprintf(buf, "    cout << %s << endl;\n", $2);
        else {
            if ($2[0] == '"' || strstr($2, "strcpy") || strstr($2, "strcat"))
                sprintf(buf, "    printf(\"%%s\\n\", %s);\n", $2);
            else
                sprintf(buf, "    printf(\"%%f\\n\", (double)(%s));\n", $2);
        }
        $$ = buf;
        free($2);
    }
    | TYPE ID '=' expression {
        char buf[1024];
        if (is_cpp) {
            sprintf(buf, "    %s %s = %s;\n", $1, $2, $4);
        } else {
            if (strcmp($1, "string") == 0)
                sprintf(buf, "    char %s[100]; strcpy(%s, %s);\n", $2, $2, $4);
            else if (strcmp($1, "char") == 0)
                sprintf(buf, "    char %s = %s[0];\n", $2, $4);
            else
                sprintf(buf, "    %s %s = %s;\n", $1, $2, $4);
        }
        $$ = strdup(buf);
        free($1); free($2); free($4);
    }
    | ID '=' expression {
         char buf[1024];
         if (is_cpp) {
        // Assume undeclared, declare as string
             sprintf(buf, "    string %s = %s;\n", $1, $3);
         } else {
             if (strstr($3, "strcat") || strstr($3, "strcpy"))
                 sprintf(buf, "    strcpy(%s, %s);\n", $1, $3);
             else
                 sprintf(buf, "    %s = %s;\n", $1, $3);
         }
        $$ = strdup(buf);
        free($1); free($3);
      }

       | IF expression THEN statements ELSE statements END {
        char buf[2048];
        sprintf(buf, "    if (%s) {\n%s    } else {\n%s    }\n", $2, $4, $6);
        $$ = strdup(buf);
        free($2); free($4); free($6);
    }
    | WHILE expression statements END {
        char buf[2048];
        sprintf(buf, "    while (%s) {\n%s    }\n", $2, $3);
        $$ = strdup(buf);
        free($2); free($3);
    }
    | FOR NUMBER TO NUMBER statements END {
        char buf[2048];
        sprintf(buf, "    for (int i = %s; i <= %s; i++) {\n%s    }\n", $2, $4, $5);
        $$ = strdup(buf);
        free($2); free($4); free($5);
    }
    ;

expression:
    NUMBER { $$ = strdup($1); free($1); }
    | STRING { $$ = strdup($1); free($1); }
    | ID { $$ = strdup($1); free($1); }
    | expression '+' expression {
        char *buf = malloc(strlen($1) + strlen($3) + 64);
        if (is_cpp)
            sprintf(buf, "(%s + %s)", $1, $3);
        else
            sprintf(buf, "strcat(strcpy(buffer, %s), %s)", $1, $3);
        $$ = buf;
        free($1); free($3);
    }
    | expression '-' expression {
        $$ = malloc(strlen($1) + strlen($3) + 8);
        sprintf($$, "(%s - %s)", $1, $3);
        free($1); free($3);
    }
    | expression '*' expression {
        $$ = malloc(strlen($1) + strlen($3) + 8);
        sprintf($$, "(%s * %s)", $1, $3);
        free($1); free($3);
    }
    | expression '/' expression {
        $$ = malloc(strlen($1) + strlen($3) + 8);
        sprintf($$, "(%s / %s)", $1, $3);
        free($1); free($3);
    }
    | expression '>' expression {
        $$ = malloc(strlen($1) + strlen($3) + 8);
        sprintf($$, "(%s > %s)", $1, $3);
        free($1); free($3);
    }
    | expression '<' expression {
        $$ = malloc(strlen($1) + strlen($3) + 8);
        sprintf($$, "(%s < %s)", $1, $3);
        free($1); free($3);
    }
    | expression EQ expression {
        $$ = malloc(strlen($1) + strlen($3) + 8);
        sprintf($$, "(%s == %s)", $1, $3);
        free($1); free($3);
    }
    ;

%%

int yyerror(const char *s) {
    fprintf(stderr, "Error: %s at '%s'\n", s, yytext);
    return 1;
}

int main(int argc, char *argv[]) {
    FILE *in = fopen("input.txt", "r");
    if (argc > 1 && strcmp(argv[1], "cpp") == 0) {
        out = fopen("output.cpp", "w");
        is_cpp = 1;
    } else {
        out = fopen("output.c", "w");
    }

    if (!in || !out) {
        perror("File error");
        return 1;
    }

    extern FILE *yyin;
    yyin = in;

    yyparse();

    fclose(in);
    fclose(out);
    return 0;
}

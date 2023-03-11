
%{
    #include <stdio.h>
    #include <string.h>

    int yyparse();
    int yylex();

    extern FILE *yyin;

    void yyerror(const char *str)
    {
        fprintf(stderr,"error: %s\n",str);
    }

    int yywrap()
    {
        return 1;
    }

    char canvas[200][200];

    int main(int argc, char *argv[])
    {
        if(argc == 2){
            yyin = fopen(argv[1], "r");
            if(yyin == NULL){
                printf("File not found.\n");
                return 1;
            }
            for(int i = 0; i < 200; i++){
                for(int j = 0; j < 200; j++){
                    canvas[i][j] = ' ';
                }
            }
            yyparse();
            printf("\n");
        }
        else{
            printf("Invalid arguments, usage: ./interpreter <filename>\n");
            return 1;
        }
    }

    int canvasX, canvasY;
    int cursorX, cursorY;
    char *identifier;
    char *message;

    char *identifiers[100];
    int idCount = 0;
    int heights[100];
    int widths[100];
%}

%token TOKPROGRAM TOKSEMICOLON TOKCANVASINITSECTION TOKCOLON TOKID TOKCANVASX TOKCONST TOKINTLIT TOKEQUAL TOKCANVASY TOKCOMMENT TOKCURSORX TOKCURSORY
%token TOKBRUSHDECLARATIONSECTION TOKBRUSH TOKCOMMA TOKDRAWINGSECTION TOKRENEWBRUSH TOKMESSAGE TOKPAINTCANVAS TOKEXHIBITCANVAS TOKMOVE TOKTO TOKPLUS TOKMINUS
%token TOKERROR
%%

peakasso:
    TOKPROGRAM id TOKSEMICOLON canvas_init_section brush_declaration_section drawing_section
    ;

canvas_init_section:
    TOKCANVASINITSECTION TOKCOLON canvas_size_init cursor_pos_init
    ;

canvas_size_init:
    TOKCONST TOKCANVASX TOKEQUAL TOKINTLIT TOKSEMICOLON TOKCONST TOKCANVASY TOKEQUAL TOKINTLIT TOKSEMICOLON
    {
        if($4 >= 5 && $4 <= 200){
            canvasX = $4;
        } else{
            printf("Invalid X value for Canvas, choosing 100 instead...\n");
            canvasX = 100;
        }
        if($9 >= 5 && $9 <= 200){
            canvasY = $9;
        } else{
            printf("Invalid Y value for Canvas, choosing 100 instead...\n");
            canvasY = 100;
        }
    }
    ;

cursor_pos_init:
    TOKCURSORX TOKEQUAL TOKINTLIT TOKSEMICOLON TOKCURSORY TOKEQUAL TOKINTLIT TOKSEMICOLON
    {
        cursorX = $3;
        cursorY = $7;
    }
    ;

brush_declaration_section:
    TOKBRUSHDECLARATIONSECTION TOKCOLON
    | TOKBRUSHDECLARATIONSECTION TOKCOLON variable_definition
    ;

variable_definition:
    TOKBRUSH brush_list TOKSEMICOLON
    ;

brush_list:
    brush_init_name 
    | brush_init_name TOKCOMMA brush_list
    ;

brush_init_name:
    id
    {
        heights[idCount] = 1;
        widths[idCount] = 1;
        identifiers[idCount++] = strdup(identifier);
    }
    | id TOKEQUAL TOKINTLIT TOKINTLIT
    {
        if($3 > 0)
            heights[idCount] = $3;
        else{
            heights[idCount] = 1;
            printf("invalid height value (min=1), setting height to 1...");
        }
        if($4 > 0)
            widths[idCount] = $4;
        else{
            widths[idCount] = 1;
            printf("invalid width value (min=1), setting width to 1...");
        }
        identifiers[idCount++] = strdup(identifier);
    }
    ;

brush_name:
    id
    {
        int idFound = 0;
        for(int i = 0; i < idCount; i++){
            if(!strcmp(identifier, identifiers[i])){
                idFound = 1;
                break;
            }
        }
        if(!idFound){
            yyerror("Identifier not found");
            return 1;
        }
    }
    | id TOKEQUAL TOKINTLIT TOKINTLIT
    {
        int idFound = 0;
        for(int i = 0; i < idCount; i++){
            if(!strcmp(identifier, identifiers[i])){
                idFound = 1;
                heights[i] = $3;
                widths[i] = $4;
                break;
            }
        }
        if(!idFound){
            yyerror("Identifier not found");
            return 1;
        }
    }
    ;

id:
    TOKID
    ;

drawing_section:
    TOKDRAWINGSECTION TOKCOLON statement_list
    ;

statement_list:
    | statement TOKSEMICOLON
    | statement TOKSEMICOLON statement_list
    ;

statement:
    renew_statement
    | paint_statement
    | exhibit_statement
    | cursor_move_statement
    ;

renew_statement:
    TOKRENEWBRUSH TOKMESSAGE brush_name
    {
        printf("\n%s ", message);
        FILE *temp = yyin;
        yyin = NULL; // stdin;
        int height, width;
        scanf("%d", &height);
        scanf("%d", &width);
        int idFound = 0;
        for(int i = 0; i < idCount; i++){
            if(!strcmp(identifiers[i], identifier)){
                if(height > 0)
                    heights[i] = height;
                else
                    printf("invalid height value (min=1), not changing height...\n");
                if(width > 0)
                    widths[i] = width;
                else
                    printf("invalid width value (min=1), not changing width...\n");
                idFound = 1;
                break;
            }
        }
        if(!idFound){
            yyerror("Identifier not found");
            return 1;
        }
        yyin = temp;
    }
    ;

paint_statement:
    TOKPAINTCANVAS brush_name
    {
        int height, width;
        for(int i = 0; i < idCount; i++){
            if(!strcmp(identifiers[i], identifier)){
                height = heights[i];
                width = widths[i];
                break;
            }
        }
        for(int i = 0; i < height; i++){
            for(int j = 0; j < width; j++){
                canvas[cursorY+i][cursorX+j] = '*';
            }
        }
    }
    ;

exhibit_statement:
    TOKEXHIBITCANVAS
    {
        for(int i = 0; i < canvasY; i++){
            for(int j = 0; j < canvasX; j++){
                printf("%c", canvas[i][j]);
            }
            printf("\n");
        }
        printf("\n");
    }
    ;

cursor_move_statement:
    TOKMOVE TOKCURSORX TOKTO expression
    {
        if($4 <= canvasX && $4 >= 0){
            cursorX = $4;
        } else{
            printf("Trying to move out of canvas, operation neglected...");
        }
    }
    | TOKMOVE TOKCURSORY TOKTO expression
    {
        if($4 <= canvasY && $4 >= 0){
            cursorY = $4;
        } else{
            printf("Trying to move out of canvas, operation neglected...");
        }
    }
    ;

cursor:
    TOKCURSORX
    {
        $$ = cursorX;
    }
    | TOKCURSORY
    {
        $$ = cursorY;
    }
    ;

expression:
    expression TOKPLUS term
    {
        $$ = $1 + $3;
    }
    | expression TOKMINUS term
    {
        $$ = $1 - $3;
    }
    |
    term
    {
        $$ = $1;
    }
    ;

term:
    factor
    {
        $$ = $1;
    }
    ;

factor:
    TOKINTLIT
    {
        $$ = $1;
    }
    | cursor
    {
        $$ = $1;
    }
    | TOKCANVASX
    {
        $$ = canvasX;
    }
    | TOKCANVASY
    {
        $$ = canvasY;
    }
    | expression
    {
        $$ = $1;
    }
    ;

%%
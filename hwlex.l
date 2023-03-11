%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include "y.tab.h"

    extern char *message;
    extern char *identifier;
%}

%%

"PROGRAM"                       return TOKPROGRAM;
";"                             return TOKSEMICOLON;
":"                             return TOKCOLON;
","                             return TOKCOMMA;
"CANVAS-INIT-SECTION"           return TOKCANVASINITSECTION;
"CONST"                         return TOKCONST;
"CanvasX"                       return TOKCANVASX;
"CanvasY"                       return TOKCANVASY;
"CursorX"                       return TOKCURSORX;
"CursorY"                       return TOKCURSORY;
"="                             return TOKEQUAL;
"BRUSH-DECLARATION-SECTION"     return TOKBRUSHDECLARATIONSECTION;
"BRUSH"                         return TOKBRUSH;
"DRAWING-SECTION"               return TOKDRAWINGSECTION;
"RENEW-BRUSH"                   return TOKRENEWBRUSH;
"PAINT-CANVAS"                  return TOKPAINTCANVAS;
"EXHIBIT-CANVAS"                return TOKEXHIBITCANVAS;
"MOVE"                          return TOKMOVE;
"TO"                            return TOKTO;
"PLUS"                          return TOKPLUS;
"MINUS"                         return TOKMINUS;
\'.*\'                          message=strdup(yytext);message[strlen(message)-1]='\0';message++;return TOKMESSAGE;
!!.*\n                          ;
[+-]?[0-9]+                     yylval=atoi(yytext);return TOKINTLIT;
[a-zA-Z0-9]+                    identifier=strdup(yytext);return TOKID;
[^\n ]                          return TOKERROR;
\n                              ;

%%
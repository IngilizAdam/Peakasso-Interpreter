interpreter:
	yacc -d hwyacc.y
	lex hwlex.l
	gcc y.tab.c lex.yy.c -ll -o interpreter
	rm lex.yy.c
	rm y.tab.c
	rm y.tab.h
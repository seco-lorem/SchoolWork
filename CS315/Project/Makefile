parser: y.tab.c lex.yy.c
	gcc -o parser y.tab.c
	rm -f lex.yy.c
	rm -f y.tab.c

y.tab.c: CS315f21_team09.yacc
	yacc CS315f21_team09.yacc

lex.yy.c: CS315f21_team09.lex
	lex CS315f21_team09.lex

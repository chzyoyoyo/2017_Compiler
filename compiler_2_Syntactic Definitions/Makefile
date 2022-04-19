OBJECT = lex.yy.c y.tab.h y.tab.c
LEX = flex
YACC = yacc -d -v
all: lex.yy.c y.tab.c
	gcc -g lex.yy.c y.tab.c -o parser -lfl -ly

y.tab.c: yacctemplate.y
	$(YACC) yacctemplate.y

lex.yy.c: lex.l
	$(LEX) lex.l

clean:
	rm -f $(TARGET) $(OBJECT)
CC = gcc
CCFLAG = -lfl
LEX = lex

all: lex.yy.c 
	$(CC) -o scanner lex.yy.c $(CCFLAG)

lex.yy.c: lextemplate.l
	$(LEX) lextemplate.l

clean:
	rm -f scanner
UNAME := $(shell uname)
ifeq ($(UNAME), Linux)
	GCC_EXTRA_PARAM := 
else ifeq ($(UNAME), Darwin)
	GCC_EXTRA_PARAM := -ll
endif

TARGET_NAME := parser

all: parser clean

clean:
	rm lex.yy.c
	rm y.output
	rm y.tab.c
	rm y.tab.h

y.tab.c: parser.y
	yacc -d -v parser.y

lex.yy.c: lex.l
	lex lex.l

y.tab.h: parser.y
	yacc -d -v parser.y

parser: lex.yy.c y.tab.c y.tab.h
	g++ y.tab.c lex.yy.c main.c symbol.cpp -o $(TARGET_NAME) -ly $(GCC_EXTRA_PARAM)

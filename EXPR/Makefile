
CC=gcc
CFLAGS=-g

all: EXPRc

EXPRc: EXPRc.c EXPR.tab.o lex.yy.o lib.o
	gcc -o $@ $^

EXPR.tab.o: EXPR.tab.c lib.h

EXPR.tab.c: EXPR.y
	bison -d $<

lex.yy.o: lex.yy.c

lex.yy.c: EXPR.lex EXPR.tab.c
	flex EXPR.lex

lib.o: CFLAGS+=-Wall -Wextra
lib.o: lib.c lib.h

clean:
	rm -f EXPRc *.o EXPR.tab.c EXPR.tab.h lex.yy.c *~

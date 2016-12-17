CC = gcc
LEX = lex
YACC = yacc -d
CFLAGS = -O2 -Wall -g
LDFLAGS = -ly -lfl # Linux: -lfl / OSX: -ll
CC=gcc
CFLAGS=-g

all: texcc

texcc: texcc.c y.tab.o lex.yy.o lib.o
	gcc -o $@ $^ $(LDFLAGS)

y.tab.o: y.tab.c lib.h

y.tab.c: texcc.y
	yacc -d $<

lex.yy.o: lex.yy.c

lex.yy.c: texcc.l y.tab.c
	lex texcc.l

lib.o: CFLAGS+=-Wall -Wextra
lib.o: lib.c lib.h

clean:
	rm -f texcc *.o y.tab.c y.tab.h lex.yy.c *~

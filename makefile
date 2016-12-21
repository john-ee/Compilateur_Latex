CC = gcc
LEX = lex
YACC = yacc -d
EXEC = texcc
LDFLAGS = -ly -lfl # Linux: -lfl / OSX: -ll
CFLAGS=-g

all: $(EXEC)

texcc: $(EXEC).c y.tab.o lex.yy.o lib.o
	$(CC) -o $@ $^ $(LDFLAGS)

y.tab.o: y.tab.c lib.h

y.tab.c: $(EXEC).y
	$(YACC) $<

lex.yy.o: lex.yy.c

lex.yy.c: $(EXEC).l y.tab.c
	$(LEX) $(EXEC).l

lib.o: CFLAGS+=-Wall -Wextra
lib.o: lib.c lib.h

clean:
	rm -f texcc *.o y.tab.c y.tab.h lex.yy.c *~

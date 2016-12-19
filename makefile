CC = gcc
LEX = lex
YACC = yacc -d
CFLAGS = -O2 -Wall -g
LDFLAGS = -ly -ll # Linux: -lfl / OSX: -ll
EXEC = texcc
SRC = 
OBJ = $(SRC:.c=.o)

all: $(OBJ) y.tab.c lex.yy.c lib.c
	$(CC) -o $(EXEC) $^ $(LDFLAGS)

y.tab.c: $(EXEC).y
	$(YACC) $(EXEC).y

lex.yy.c: $(EXEC).l
	$(LEX) $(EXEC).l

%.o: %.c %.h
	$(CC) -o $@ -c $< $(CFLAGS)

clean:
	/bin/rm $(EXEC) y.tab.c y.tab.h lex.yy.c

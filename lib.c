
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "lib.h"

struct symtable * symtable_new()
{
    struct symtable * t = malloc(sizeof(struct symtable));
    t->capacity = 1024;
    t->symbols = malloc(t->capacity*sizeof(struct symbol));
    t->temporary = 2;
    t->msg = 0;
    t->size = 0;
    return t;
}

static void symtable_grow(struct symtable * t) 
{
    t->capacity += 1024;
    t->symbols = realloc(t->symbols,t->capacity*sizeof(struct symbol));
    if(t->symbols == NULL) 
    {
      fprintf(stderr,"Error attempting to grow symbol table (actual size is %d)\n",t->size);
        exit(1);
    }
}

struct symbol * symtable_const(struct symtable * t, char* v) 
{
    unsigned int i;
    for ( i=0 ; i<t->size && t->symbols[i].u.value != v; i++ );
    if(i==t->size)
    {
        if(t->size==t->capacity)
          symtable_grow(t);
        struct symbol *s = &(t->symbols[t->size]);
        s->kind = CONSTANT;
        s->u.value = v;
        ++ (t->size);
        return s;
    }
    else 
    {
        return &(t->symbols[i]);
    }
}

struct symbol * symtable_get(struct symtable * t, const char * id) 
{
    unsigned int i;
    for ( i=0 ; i<t->size && strcmp(t->symbols[i].u.name,id) != 0; i++ );
    if(i<t->size)
      return &(t->symbols[i]);
    return NULL;
}

struct symbol * symtable_put(struct symtable * t, const char * id) 
{
    if(t->size==t->capacity)
      symtable_grow(t);
    struct symbol *s = &(t->symbols[t->size]);
    s->kind = NAME;
    s->u.name = strdup(id);
    //strcpy(s->u.name,id);
    ++ (t->size);
    return s;
}

void symtable_dump(struct symtable * t)
{
    unsigned int i;
    for ( i=0 ; i<t->size; i++ )
    {
      if(t->symbols[i].kind==CONSTANT)
        printf("       %p = %s\n",&(t->symbols[i]),t->symbols[i].u.value);
      if(t->symbols[i].kind==NAME)
        printf("       %p = %s\n",&(t->symbols[i]),t->symbols[i].u.name);
    }
    printf("       --------\n");
}

void symtable_free(struct symtable * t)
{
    free(t->symbols);
    free(t);
}

struct code * code_new()
{
    struct code * r = malloc(sizeof(struct code));
    r->capacity = 1024;
    r->quads = malloc(r->capacity*sizeof(struct quad));
    r->nextquad = 0;
    return r;
}

static void code_grow(struct code * c)
{
    c->capacity += 1024;
    c->quads = realloc(c->quads,c->capacity*sizeof(struct quad));
    if(c->quads == NULL) 
    {
      fprintf(stderr,"Error attempting to grow quad list (actual size is %d)\n",c->nextquad);
        exit(1);
    }
}

void gencode(struct code * c,
              enum quad_kind k,
              struct symbol * s1,
              struct symbol * s2,
              struct symbol * s3)
{
    if ( c->nextquad == c->capacity )
        code_grow(c);
    struct quad * q = &(c->quads[c->nextquad]);
    q->kind = k;
    q->sym1 = s1;
    q->sym2 = s2;
    q->sym3 = s3;
    ++ (c->nextquad);
}

struct symbol *newtemp(struct symtable * t)
{
  struct symbol * s;
  char name[32];
  sprintf(name,"$t%d",t->temporary);
  s = symtable_put(t,name);
  ++ (t->temporary);
  return s;
}

static void symbol_dump(struct symbol * s)
{
    switch ( s->kind )
    {
        case NAME:
            printf("%s",s->u.name);
            break;
        case CONSTANT:
            printf("%s",s->u.value);
            break;
        default:
            break;
    }
}

static void quad_dump(struct quad * q)
{
    switch ( q->kind )
    {
        case BOP_PLUS:
            symbol_dump(q->sym1);
            printf(" := ");
            symbol_dump(q->sym2);
            printf(" + ");
            symbol_dump(q->sym3);
            break;
        case BOP_MINUS:
            symbol_dump(q->sym1);
            printf(" := ");
            symbol_dump(q->sym2);
            printf(" - ");
            symbol_dump(q->sym3);
            break;
        case BOP_MULT:
            symbol_dump(q->sym1);
            printf(" := ");
            symbol_dump(q->sym2);
            printf(" * ");
            symbol_dump(q->sym3);
            break;
        case UOP_MINUS:
            symbol_dump(q->sym1);
            printf(" := ");
            printf("- ");
            symbol_dump(q->sym2);
            break;
        case CALL_PRINT:
            printf("print ");
            symbol_dump(q->sym1);
            break;
        case CALL_PRINT_TEXT:
            printf("print ");
            symbol_dump(q->sym1);
            break;
        case COPY:
            symbol_dump(q->sym1);
            printf(" := ");
            symbol_dump(q->sym2);
            break;
        default:
            printf("BUG\n");
            break;
    }
}

static char * symbol_print(struct symbol * s)
{
    switch ( s->kind )
    {
        case NAME:
            return s->u.name;
            break;
        case CONSTANT:
            return s->u.value;
            break;
        default:
            return NULL;
            break;
    }
}

static void quad_print(struct quad * q, FILE * out)
{
    char * nom1 = NULL;
    char * nom2 = NULL;
    char * nom3 = NULL;
    switch ( q->kind )
    {
        case BOP_PLUS:
            nom1 = symbol_print(q->sym1);
            nom2 = symbol_print(q->sym2);
            nom3 = symbol_print(q->sym3);

            if (q->sym2->kind == CONSTANT)
                fprintf(out, "  li $t0, %s\n", nom2);
            else if (nom2[0] != '$')
                fprintf(out, "  lw $t0, %s\n", nom2);

            if (q->sym3->kind == CONSTANT)
                fprintf(out, "  li $t1, %s\n", nom3);
            else if (nom3[0] != '$')
                fprintf(out, "  lw $t1, %s\n", nom3);

            if (nom2[0] != '$' && nom3[0] != '$')
                fprintf(out, "  add %s, $t0, $t1\n", nom1);

            else{
                if (nom2[0]=='$' && nom3[0]=='$')
                    fprintf(out, "  add %s, %s, %s\n", nom1, nom2, nom3);
                else if (nom2[0]=='$')
                    fprintf(out, "  add %s, %s, $t1\n", nom1, nom2);
                else if (nom3[0]=='$')
                    fprintf(out, "  add %s, $t0, %s\n", nom1, nom3);
            }
            break;

        case BOP_MINUS:
            nom1 = symbol_print(q->sym1);
            nom2 = symbol_print(q->sym2);
            nom3 = symbol_print(q->sym3);

            if (q->sym2->kind == CONSTANT)
                fprintf(out, "  li $t0, %s\n", nom2);
            else if (nom2[0] != '$')
                fprintf(out, "  lw $t0, %s\n", nom2);

            if (q->sym3->kind == CONSTANT)
                fprintf(out, "  li $t1, %s\n", nom3);
            else if (nom3[0] != '$')
                fprintf(out, "  lw $t1, %s\n", nom3);

            if (nom2[0] != '$' && nom3[0] != '$')
                fprintf(out, "  sub %s, $t0, $t1\n", nom1);

            else{
                if (nom2[0]=='$' && nom3[0]=='$')
                    fprintf(out, "  sub %s, %s, %s\n", nom1, nom2, nom3);
                else if (nom2[0]=='$')
                    fprintf(out, "  sub %s, %s, $t1\n", nom1, nom2);
                else if (nom3[0]=='$')
                    fprintf(out, "  sub %s, $t0, %s\n", nom1, nom3);
}
            break;

        case BOP_MULT:
            nom1 = symbol_print(q->sym1);
            nom2 = symbol_print(q->sym2);
            nom3 = symbol_print(q->sym3);

            if (q->sym2->kind == CONSTANT)
                fprintf(out, "  li $t0, %s\n", nom2);
            else if (nom2[0] != '$')
                fprintf(out, "  lw $t0, %s\n", nom2);

            if (q->sym3->kind == CONSTANT)
                fprintf(out, "  li $t1, %s\n", nom3);
            else if (nom3[0] != '$')
                fprintf(out, "  lw $t1, %s\n", nom3);

            if (nom2[0] != '$' && nom3[0] != '$')
                fprintf(out, "  mult $t0, $t1\n");

            else{
                if (nom2[0]=='$' && nom3[0]=='$')
                    fprintf(out, "  mult %s, %s\n", nom2, nom3);
                else if (nom2[0]=='$')
                    fprintf(out, "  mult %s, $t1\n", nom2);
                else if (nom3[0]=='$')
                    fprintf(out, "  mult $t0, %s\n", nom3);
            }

            if (nom1[0] == '$')
                fprintf(out, "  mflo %s\n", nom1);
            else
            {
                fprintf(out, "  mflo $t0\n");
                fprintf(out, "  sw $t0 %s\n", nom1);
            }
            break;

        case COPY:
            nom1 = symbol_print(q->sym1);
            nom2 = symbol_print(q->sym2);
            if (nom2[0] == '$')
                fprintf(out, "  sw %s, %s\n", nom2, nom1);
            else {
                fprintf(out, "  li $t0, %s\n", nom2);
                fprintf(out, "  sw $t0, %s\n", nom1);
            }
            break;
        case CALL_PRINT:
            nom1 = symbol_print(q->sym1);
            fprintf(out, "  li $v0, 1\n");
            fprintf(out, "  lw $a0, %s\n", nom1);
            fprintf(out, "  syscall\n");
            fprintf(out, "  li $v0, 4\n");
            fprintf(out, "  la $a0, msg \n");
            fprintf(out, "  syscall\n");
            break;
        case CALL_PRINT_TEXT:
            nom1 = symbol_print(q->sym1);
            fprintf(out, "  li $v0, 4\n");
            fprintf(out, "  la $a0, %s \n", nom1);
            fprintf(out, "  syscall\n");
            break;
        default:
            printf("BUG\n");
            break;
    }
}

void code_print(struct code * c, FILE * out)
{
    unsigned int i;
    for ( i=0 ; i<c->nextquad ; i++ )
    {
        quad_print(&(c->quads[i]), out);
    }
}

void code_dump(struct code * c)
{
    unsigned int i;
    for ( i=0 ; i<c->nextquad ; i++ )
    {
        printf("%4u | ",i);
        quad_dump(&(c->quads[i]));
        printf("\n");
    }
}

void code_free(struct code * c)
{
    free(c->quads);
    free(c);
}


void put_print(FILE* out, char * c, struct symtable * t)
{
    fprintf(out," msg%d: .asciiz %s \n", t->msg, c);
    ++ (t->msg);
}

void put_integer_id(FILE * out, char * c)
{
    fprintf(out, " %s: .word 0\n", c);
}


void put_integer_id_constant(FILE * out, char * c, char * v)
{
    fprintf(out, " %s: .word %s\n", c, v);
}
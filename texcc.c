#include <stdio.h>
#include <stdlib.h>
#include "texcc.h"

int main(int argc, char* argv[]) {
  if (argc == 2) {
    if ((yyin = fopen(argv[1], "r")) == NULL) {
      fprintf(stderr, "[texcc] error: unable to open file %s\n", argv[1]);
      exit(TEXCC_ERROR_GENERAL);
    }
  } else {
    fprintf(stderr, "[texcc] usage: %s input_file\n", argv[0]);
    exit(TEXCC_ERROR_GENERAL);
  }

  SYMTAB = symtable_new();
  CODE = code_new();
  yyparse();
  fclose(yyin);
  symtable_dump(SYMTAB);
  code_dump(CODE);
  symtable_free(SYMTAB);
  code_free(CODE);
  return EXIT_SUCCESS;
}

/* driver.c -- test-only harness for natural_sort's strnatcmp conformance fixture.

   Reads NUL-delimited fields from stdin: a\0b\0a\0b\0...  For each (a, b) pair it
   prints the sign of strnatcmp(a, b) -- -1, 0, or 1 -- on its own line.

   Plain ANSI C (getchar only), so it builds anywhere a C compiler exists without
   POSIX feature macros. NOT part of the natural_sort gem or the vendored
   reference; see script/regen_strnatcmp_fixture.rb. */

#include <stdio.h>
#include <stdlib.h>
#include "strnatcmp.h"

/* Read one NUL-terminated field into a growable buffer. Sets *eof and returns
   NULL when stdin ends before any byte of a field. */
static char *read_field(int *eof)
{
     size_t cap = 16, len = 0;
     char *buf = malloc(cap);
     int c;

     while ((c = getchar()) != EOF && c != '\0') {
          if (len + 1 >= cap) {
               cap *= 2;
               buf = realloc(buf, cap);
          }
          buf[len++] = (char) c;
     }

     if (c == EOF && len == 0) {
          *eof = 1;
          free(buf);
          return NULL;
     }

     buf[len] = '\0';
     return buf;
}

int main(void)
{
     int eof = 0;
     char *a, *b;

     while ((a = read_field(&eof)) != NULL) {
          b = read_field(&eof);
          if (b == NULL) {
               free(a);
               break;
          }

          int r = strnatcmp(a, b);
          printf("%d\n", (r > 0) - (r < 0));

          free(a);
          free(b);
     }

     return 0;
}

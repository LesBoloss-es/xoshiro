#include <stdint.h>
#include <stdio.h>

uint64_t next(void);

int u30mask = (1 << 30) - 1;

uint64_t n;
int res;

int b = 0;
int r = 0;

int bits () {
  if (b) {
    b = 0;
    return r;
  } else {
    n = next();
    r = n & u30mask;
    b = 1;
    return (n >> 34);
  }
}

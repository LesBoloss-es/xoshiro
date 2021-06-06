#include <stdint.h>

#define CAML_NAME_SPACE
#include <caml/mlvalues.h>
#include <caml/alloc.h>

static inline uint64_t rotl(const uint64_t x, int k) {
	return (x << k) | (x >> (64 - k));
}

uint64_t next(uint64_t *s) {
	const uint64_t result = rotl(s[0] + s[3], 23) + s[0];

	const uint64_t t = s[1] << 17;

	s[2] ^= s[0];
	s[3] ^= s[1];
	s[1] ^= s[2];
	s[0] ^= s[3];

	s[2] ^= t;

	s[3] = rotl(s[3], 45);

	return result;
}

int u30mask = (1 << 30) - 1;

uint64_t ll_state[4] = { 0xdeadbeefdeadbeef, 0x4242424242424242, 0x3737373737373737, 0xca7aca7aca7aca7a };

int second;

int bits () {
  if (second > 0) {
    int result = second;
    second = -1;
    return result;
  } else {
    uint64_t result = next(ll_state);
    second = result & u30mask;
    return (result >> 34);
  }
}

CAMLprim value caml_bits () {
  return Val_long(bits ());
}

#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

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

/* ************************ [ OCaml-like interface ] ************************ */

#define state_t uint64_t*

uint64_t bits(state_t state) {
  return next(state);
}

state_t new_state () {
  return malloc(4 * sizeof(uint64_t));
}

void assign(state_t state1, state_t state2) {
  for (int i = 0; i < 4; i++) state1[i] = state2[i];
}

void full_init(state_t state, uint64_t* seed) {
  assign(state, seed);
}

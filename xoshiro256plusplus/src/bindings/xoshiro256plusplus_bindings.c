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

struct state {
  uint64_t *b_state;
  int *second;
};

#define state_t struct state

static int u30mask = (1 << 30) - 1;

unsigned int bits (state_t state) {
  if (*state.second > 0) {
    int result = *state.second;
    *state.second = -1;
    return result;
  }
  else {
    uint64_t result = next(state.b_state);
    *state.second = result & u30mask;
    return ((result >> 34) & u30mask);
  }
}

state_t new_state () {
  state_t state;
  state.b_state = malloc(4 * sizeof(uint64_t));
  state.second = malloc(sizeof(int));
  *state.second = -1;
  return state;
}

void assign(state_t state1, state_t state2) {
  for (int i = 0; i < 4; i++)
    state1.b_state[i] = state2.b_state[i];
  state1.second = state2.second;
}

void init(state_t state, uint64_t* seed) {
  state_t state2;
  state2.b_state = seed;
  *state2.second = -1;
  assign(state, state2);
}

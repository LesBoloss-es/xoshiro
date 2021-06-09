#include <stdint.h>

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

uint64_t ll_state[4] =
  { -8834433206116304641L,
    -8946337071913336723L,
    -2713122746316408295L,
    979864279706444564L };

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

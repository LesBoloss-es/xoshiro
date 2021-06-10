#include <stdint.h>

#define state_t uint64_t*

uint64_t bits(state_t state);

state_t new_state();
void assign(state_t state1, state_t state2);

void init(state_t state, uint64_t* seed);

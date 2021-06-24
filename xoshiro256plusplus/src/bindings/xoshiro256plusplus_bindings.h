#include <stdint.h>

struct state {
  uint64_t *b_state;
  int *second;
};

#define state_t struct state

#define unbox_state(bstate) (* (state_t*) Data_custom_val(bstate))
#define box_state(state, bstate, ops) ({ bstate = caml_alloc_custom(&state_ops, sizeof(state_t), 0, 1); memcpy(Data_custom_val(bstate), &state, sizeof(state_t)); })

int bits(state_t state);

state_t new_state();
void assign(state_t state1, state_t state2);

void init(state_t state, uint64_t* seed);

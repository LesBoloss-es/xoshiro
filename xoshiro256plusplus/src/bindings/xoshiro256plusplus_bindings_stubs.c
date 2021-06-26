#include <string.h>

#define CAML_NAME_SPACE
#include <caml/mlvalues.h>
#include <caml/alloc.h>
#include <caml/memory.h>
#include <caml/custom.h>

#include "xoshiro256plusplus_bindings.h"
#include "xoshiro256plusplus_bindings_stubs.h"

/* ******************************** [ bits ] ******************************** */

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

CAMLprim value caml_bits(value bstate) {
  CAMLparam1(bstate);
  state_t state = unbox_state(bstate);
  int result = bits(state);
  CAMLreturn(Val_int(result));
}

/* ***************************** [ new_state ] ****************************** */

state_t new_state () {
  state_t state;
  state.b_state = malloc(4 * sizeof(uint64_t));
  state.second = malloc(sizeof(int));
  *state.second = -1;
  return state;
}

CAMLprim value caml_new_state(value unit) {
  CAMLparam1(unit);
  CAMLlocal1(bstate);
  state_t state = new_state();
  box_state(state, bstate, state_ops);
  CAMLreturn(bstate);
}

/* ******************************* [ assign ] ******************************* */

void assign(state_t state1, state_t state2) {
  for (int i = 0; i < 4; i++)
    state1.b_state[i] = state2.b_state[i];
  *state1.second = *state2.second;
}

CAMLprim value caml_assign(value bstate1, value bstate2) {
  CAMLparam2(bstate1, bstate2);
  state_t state1 = unbox_state(bstate1);
  state_t state2 = unbox_state(bstate2);
  assign (state1, state2);
  CAMLreturn(Val_unit);
}

/* ******************************** [ init ] ******************************** */

void init(state_t state, uint64_t* seed) {
  state_t state2;
  state2.b_state = seed;
  state2.second = malloc(sizeof(int));
  *state2.second = -1;
  assign(state, state2);
}

CAMLprim value caml_init(value bstate, value bseed) {
  CAMLparam2(bstate, bseed);
  state_t state = unbox_state(bstate);

  uint64_t *seed = malloc(4 * sizeof(uint64_t));
  seed[0] = Int64_val(Field(bseed, 0));
  seed[1] = Int64_val(Field(bseed, 1));
  seed[2] = Int64_val(Field(bseed, 2));
  seed[3] = Int64_val(Field(bseed, 3));

  init (state, seed);
  CAMLreturn(Val_unit);
}

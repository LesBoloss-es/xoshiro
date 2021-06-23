#include <string.h>

#define CAML_NAME_SPACE
#include <caml/mlvalues.h>
#include <caml/alloc.h>
#include <caml/memory.h>
#include <caml/custom.h>

#include "xoshiro256plusplus_bindings.h"

static struct custom_operations state_ops = {
  .identifier = "fr.boloss.xoshiro.bindings.256++.state_t",
  .finalize = custom_finalize_default,
  .compare = custom_compare_default,
  .hash = custom_hash_default,
  .serialize = custom_serialize_default,
  .deserialize = custom_deserialize_default
};

CAMLprim value caml_bits(value bstate) {
  CAMLparam1(bstate);
  state_t state = unbox_state(bstate);
  uint64_t result = bits(state);
  CAMLreturn(caml_copy_int64(result));
}

CAMLprim value caml_new_state(value unit) {
  CAMLparam1(unit);
  CAMLlocal1(bstate);
  state_t state = new_state();
  box_state(state, bstate, state_ops);
  CAMLreturn(bstate);
}

CAMLprim value caml_assign(value bstate1, value bstate2) {
  CAMLparam2(bstate1, bstate2);
  state_t state1 = unbox_state(bstate1);
  state_t state2 = unbox_state(bstate2);
  assign (state1, state2);
  CAMLreturn(Val_unit);
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

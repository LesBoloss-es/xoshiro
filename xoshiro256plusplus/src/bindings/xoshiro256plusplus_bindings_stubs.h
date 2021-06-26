#include <string.h>

#define CAML_NAME_SPACE
#include <caml/mlvalues.h>
#include <caml/alloc.h>
#include <caml/memory.h>
#include <caml/custom.h>

struct state {
  uint64_t *b_state;
  int *second;
};

#define state_t struct state

#define unbox_state(bstate) (* (state_t*) Data_custom_val(bstate))

#define box_state(state, bstate, ops) ({                              \
      bstate = caml_alloc_custom(&state_ops, sizeof(state_t), 0, 1);  \
      memcpy(Data_custom_val(bstate), &state, sizeof(state_t));       \
    })

void finalize_state(value bstate) {
  state_t state = unbox_state(bstate);
  free(state.b_state);
  free(state.second);
}

static struct custom_operations state_ops = {
  .identifier = "fr.boloss.xoshiro.bindings.256++.state",
  .finalize = finalize_state,
  .compare = custom_compare_default,
  .hash = custom_hash_default,
  .serialize = custom_serialize_default,
  .deserialize = custom_deserialize_default
};

CAMLprim value caml_bits(value bstate);
CAMLprim value caml_new_state(value unit);
CAMLprim value caml_assign(value bstate1, value bstate2);
CAMLprim value caml_init(value bstate, value bseed);

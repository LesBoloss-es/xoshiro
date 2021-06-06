#define CAML_NAME_SPACE
#include <caml/mlvalues.h>
#include <caml/alloc.h>

#include "xoshiro256plusplus_bindings.h"

CAMLprim value caml_bits () {
  return Val_long(bits ());
}

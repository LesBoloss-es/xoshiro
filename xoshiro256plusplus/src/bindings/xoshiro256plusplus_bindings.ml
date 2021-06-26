(** {1 xoshiro256++} *)

(** {2 Low-level Interface}

   Direct bindings of the functions provided in the original implementation. The
   state is an [int64 array] of 4 values. More will be useless; less will lead
   to segmentation faults (this is how low-level it is). *)

module LowLevel = struct
  type int64_array = (int64, Bigarray.int64_elt, Bigarray.c_layout) Bigarray.Array1.t

  external next : int64_array -> int64 = "caml_x256pp_next"

  external jump : int64_array -> unit = "caml_x256pp_jump"
  (** This is the jump function for the generator. It is equivalent to 2^128
     calls to {!next}; it can be used to generate 2^128 non-overlapping
     subsequences for parallel computations. *)

  external long_jump : int64_array -> unit = "caml_x256pp_long_jump"
  (** This is the long-jump function for the generator. It is equivalent to
     2^192 calls to {!next}; it can be used to generate 2^64 starting points,
     from each of which {!jump} will generate 2^64 non-overlapping subsequences
     for parallel distributed computations. *)
end

(** {2 OCaml-y Interface}

   An interface resembling that of the Random module of the standard library. *)

include MakeRandom.Full30Init64(struct
    type state

    external bits : state -> int = "caml_x256pp_bits"
    external new_state : unit -> state = "caml_x256pp_new_state"
    external assign : state -> state -> unit = "caml_x256pp_assign"

    let init_size = 4
    external init : state -> int64 array -> unit = "caml_x256pp_init"

    let default_seed = 135801055
  end)

(* Note to self [from Niols]: One can see that the basic functions (eg. [val
   bits: unit -> int]) in fact hide an OCaml default state which will be passed
   to C every time, which means that, in order to run a [unit -> int], we have
   to copy and unbox a state. It is then tempting to duplicate the code, to
   write C function using a C state, and to bind these functions to OCaml. I
   have tried, and it really increases the complexity of the code for...
   nothing. like at all. like it is even possibly slower than before. *)

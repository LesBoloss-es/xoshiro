include MakeRandom.Full30Init64(struct
    type state

    external bits : state -> int = "caml_bits"
    external new_state : unit -> state = "caml_new_state"
    external assign : state -> state -> unit = "caml_assign"

    let init_size = 4
    external init : state -> int64 array -> unit = "caml_init"

    let default_seed = 135801055
  end)

(* Note to self [from Niols]: One can see that the basic functions (eg. [val
   bits: unit -> int]) in fact hide an OCaml default state which will be passed
   to C every time, which means that, in order to run a [unit -> int], we have
   to copy and unbox a state. It is then tempting to duplicate the code, to
   write C function using a C state, and to bind these functions to OCaml. I
   have tried, and it really increases the complexity of the code for...
   nothing. like at all. like it is even possibly slower than before. *)

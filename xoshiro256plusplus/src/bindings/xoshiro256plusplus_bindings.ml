(* We use the pure implementation for everything that is state related. *)
include Xoshiro256plusplus_pure

(* We use the basic functions from the C interface. *)
(* FIXME: this does not work for set_state and get_state *)
include MakeRandom.Basic(struct
    external bits : unit -> int = "caml_bits"
  end)

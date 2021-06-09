module type NEXT_INT64 = sig
  type state
  val next : state -> int64
end

module type BITS = sig
  type ll_state
  type state

  val make_state : ll_state -> state
  val reset_state : state -> (ll_state -> unit) -> unit
  val make_assign : (ll_state -> ll_state -> unit) -> state -> state -> unit

  val bits : state -> int
end

module BitsOfNextInt64 : functor (N: NEXT_INT64) -> BITS with type ll_state = N.state

val full_init_int64_array : size:int -> int array -> int64 array
(** [full_init_int64_array ~size seed] returns an array of size [size]
   containing initialised [int64] values, reasonable for initialising the state
   of a PRNG. It is highly inspired from {!Random.full_init}. *)

val full_init_int64 : int array -> int64
(** Same as {!full_init_int64_array} but for only one int64 value. *)

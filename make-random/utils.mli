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

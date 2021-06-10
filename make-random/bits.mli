(** {1 Bits Providers}

   This module contains the signatures of the modules that can be given to the
   various functors in {!MakeRandom}, specifying how to provide bits. {!BASIC}
   only provides bits, while {!FULL} provides bits as well as state
   manipulations. *)

(** {2 Basic}

   To use in {!MakeRandom.Basic}. *)

module type Basic30 = sig
  val bits : unit -> int
  (** Must return a random number on 30 bits, that is between 0 (inclusive) and
      [2^30-1] (exclusive). *)
end

module type Basic64 = sig
  val bits : unit -> int64
  (** Similar to {!Basic.bits} except it returns an [int64] number. All the 64
      bits must be random. *)
end

(** {2 State} *)

module type State30 = sig
  type state
  (** The type of PRNG states. *)

  val bits : state -> int
  (** Provide 30 random bits in an integer. *)
end

module type State64 = sig
  type state

  val bits : state -> int64
  (** Similar to {!State.bits} except it returns an [int64] number. All the 64
      bits must be random. *)
end

(** {2 Init} *)

module type Init30 = sig
  type state

  val new_state : unit -> state
  (** Create a new non-initialised state. *)

  val assign : state -> state -> unit
  (** [assign s1 s2] copies [s2] into [s1]. *)

  val init_size : int
  (** Required size for the array in {!init}. *)

  val init : state -> int array -> unit
  (** Initialise the state based on the values in the array. The array contains
     {!init_size} random 30-bits integers. *)

  val default_seed : int
  (** Seed that will be given to {!init} to generate the default state. *)
end

module type Init64 = sig
  type state

  val new_state : unit -> state
  val assign : state -> state -> unit

  val init_size : int

  val init : state -> int64 array -> unit
  (** Same as Init.init except receives an array of [int64] where all the bits
      are random. *)

  val default_seed : int
end

(** {2 Full} *)

module type Full30 = sig
  type state
  include State30 with type state := state
  include Init30 with type state := state
end

module type Full64 = sig
  type state
  include State64 with type state := state
  include Init64 with type state := state
end

module type Full30Init64 = sig
  type state
  include State30 with type state := state
  include Init64 with type state := state
end

module type Full64Init30 = sig
  type state
  include State64 with type state := state
  include Init30 with type state := state
end

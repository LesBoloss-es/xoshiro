(** {1 Bits Providers}

   This module contains the signatures of the modules that can be given to the
   various functors in {!MakeRandom}, specifying how to provide bits. {!BASIC}
   only provides bits, while {!FULL} provides bits as well as state
   manipulations. *)

(** {2 Basic}

   To use in {!MakeRandom.Basic}. *)

module type BASIC = sig
  val bits : unit -> int
  (** Must return a random number on 30 bits, that is between 0 (inclusive) and
      [2^30-1] (exclusive). *)
end

module type BASIC64 = sig
  val bits : unit -> int64
  (** Similar to {!BASIC.bits} except it returns an [int64] number. All the 64
      bits must be random. *)
end

(** {2 Full}

   To use in {!MakeRandom.Full}. *)

module type FULL = sig
  type state
  (** The type of PRNG states. *)

  val bits : state -> int
  (** Provide 30 random bits in an integer. *)

  val default : state
  (** The default state to use for basic functions. *)

  val new_state : unit -> state
  (** Create a new non-initialised state. *)

  val assign : state -> state -> unit
  (** [assign s1 s2] copies [s2] into [s1]. *)

  val full_init : state -> int array -> unit
  (** Initialise a given state with a given seed. *)
end

module type FULL64 = sig
  type state

  val bits : state -> int64
  (** Similar to {!FULL.bits} except it returns an [int64] number. All the 64
      bits must be random. *)

  val default : state
  val new_state : unit -> state
  val assign : state -> state -> unit
  val full_init : state -> int array -> unit
end

(** {2 Full with Helper for Initialisation} *)

module type FULLHI64 = sig
  type state

  val bits : state -> int64

  val new_state : unit -> state
  val assign : state -> state -> unit

  val full_init_size : int
  (** Number of [int64] numbers required by {!full_init}. *)

  val full_init : state -> int64 array -> unit
  (** Similar to {!FULL.full_init} except it receives an array of size
     {!full_init_size} containing “good” [int64] values. *)

  val default_seed : int
  (** Default seed instead of default state. The state will be obtained by
      calling {!new_state} and then {!full_init} on an array derived from the
      seed, similar to what {!Random} does. *)
end

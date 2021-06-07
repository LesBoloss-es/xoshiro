(** {1 Bits Providers}

   This module contains the signatures of the modules that can be given to the
   various functors in {!MakeRandom}, specifying how to provide bits. {!BASIC}
   only provides bits, while {!FULL} provides bits as well as state
   manipulations. *)

(** {2 Basic}

   To use in {!MakeRandom.Basic}. *)

module type BASIC = sig
  val bits : unit -> int
end

(** {2 Full}

   To use in {!MakeRandom.Full}. *)

module type FULL = sig
  type state
  (** The type of PRNG states. *)

  val new_state : unit -> state
  (** Create a new non-initialised state. *)

  val assign : state -> state -> unit
  (** [assign s1 s2] copies [s2] into [s1]. *)

  val full_init : state -> int array -> unit
  (** Initialise a given state with a given seed. *)

  val bits : state -> int
  (** Provide 30 random bits in an integer. *)

  val default : state
  (** The default state to use for basic functions. *)
end

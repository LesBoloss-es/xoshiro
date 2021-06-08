(** {1 Functors for the Random Module}

    This module provide functors to reproduce the interface of the standard
    library's Random module with other pseudo-random number generators. *)

module Bits = Bits
(** Signatures for providers of bits (input signatures of the functors in this
   module). *)

module Sig = Sig
(** Output signatures of the functors in this module. *)

(** {2 Functor for the Basic Interface} *)

module Basic : functor (B: Bits.BASIC) -> Sig.BASIC

(** {2 Functor for the Full Interface} *)

module Full  : functor (B: Bits.FULL)  -> Sig.FULL

(** {2 Others} *)

module Utils = Utils

(** {1 Functors for the Random Module}

    This module provide functors to reproduce the interface of the standard
    library's Random module with other pseudo-random number generators. *)

module Bits = Bits
(** Signatures for providers of bits (input signatures of the functors in this
   module). *)

module Sig = Sig
(** Output signatures of the functors in this module. *)

(** {2 Functor for the Basic Interface} *)

module Basic30 : functor (B: Bits.Basic30) -> Sig.Basic
(* module Basic64 : functor (B: Bits.Basic64) -> Sig.Basic *)

(** {2 Functor for the Full Interface} *)

module Full30 : functor (B: Bits.Full30) -> Sig.Full
module Full64 : functor (B: Bits.Full64) -> Sig.Full

(** {1 Functor for the Random Module}

    This module provide functors to reproduce the interface of the standard
    library's Random module with other pseudo-random number generators. *)


(** {2 Functor for the Basic Interface}

    In case it is not possible to provide what the full interface asks for, one
    can only provide the bits function. Most of the functions of the {!Random}
    module will still be provided. The ones manipulating the state will not. Note
    that this includes all the initialisation functions; the initialisation will
    therefore have to be done by hand, outside of this module. *)

module Basic : functor (B: Bits.BASIC) -> Sig.BASIC

(** {2 Functor for the Full Interface} *)

module Full  : functor (B: Bits.FULL)  -> Sig.FULL

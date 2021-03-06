(** {1 Signatures}

   This module contains the signatures of the modules generated by functors in
   {!MakeRandom}. {!Basic} contains only the basic/usual functions from the
   {!Random} interface, while {!Full} also contains the {!Random.State} module
   and the state manipulations functions. *)

(** {2 Type of the basic functions}

   The module type {!Basic} includes the basic/usual functions from the
   {!Random} interface. For initialisation functions and PRNG state, see
   {!Full}. *)

module type Basic = sig
  val bits : unit -> int
  (** Return 30 random bits in a nonnegative integer. *)

  val int : int -> int
  (** [int bound] returns a random integer between 0 (inclusive) and [bound]
     (exclusive). [bound] must be greater than 0 and less than 2{^30}. *)

  val int32 : Int32.t -> Int32.t
  (** [int32 bound] returns a random integer between 0 (inclusive) and [bound]
     (exclusive). [bound] must be greater than 0. *)

  val nativeint : Nativeint.t -> Nativeint.t
  (** [nativeint bound] returns a random integer between 0 (inclusive) and
     [bound] (exclusive). [bound] must be greater than 0. *)

  val int64 : Int64.t -> Int64.t
  (** [int64 bound] returns a random integer between 0 (inclusive) and [bound]
     (exclusive). [bound] must be greater than 0. *)

  val float : float -> float
  (** [float bound] returns a random floating-point number between 0 and [bound]
     (inclusive). If [bound] is negative, the result is negative or zero. If
     [bound] is 0, the result is 0. *)

  val bool : unit -> bool
  (** [bool ()] returns [true] or [false] with probability 0.5 each. *)
end

(** {2 Complete type of the module}

   The module type {!Full} is identical to that of {!Random} except for the type
   {!Full.State.t} which is, of course, different. It can be used as a drop-in
   replacement of {!Random}. *)

module type Full = sig
  val init : int -> unit
  (** Initialize the generator, using the argument as a seed. The same seed will
     always yield the same sequence of numbers. *)

  val full_init : int array -> unit
  (** Same as {!init} but takes more data as seed. *)

  val self_init : unit -> unit
  (** Initialize the generator with a random seed chosen in a system-dependent
     way. If [/dev/urandom] is available on the host machine, it is used to
     provide a highly random initial seed. Otherwise, a less random seed is
     computed from system parameters (current time, process IDs). *)

  include Basic

  (** {3 Advanced functions} *)

  (** The functions from module {!State} manipulate the current state of the
     random generator explicitly. This allows using one or several deterministic
     PRNGs, even in a multi-threaded program, without interference from other
     parts of the program. *)

  module State : sig
    type t
    (** The type of PRNG states. *)

    val make : int array -> t
    (** Create a new state and initialize it with the given seed. *)

    val make_self_init : unit -> t
    (** Create a new state and initialize it with a system-dependent low-entropy
       seed. *)

    val copy : t -> t
    (** Return a copy of the given state. *)

    val bits : t -> int
    val int : t -> int -> int
    val int32 : t -> Int32.t -> Int32.t
    val nativeint : t -> Nativeint.t -> Nativeint.t
    val int64 : t -> Int64.t -> Int64.t
    val float : t -> float -> float
    val bool : t -> bool
    (** These functions are the same as the basic functions, except that they
       use (and update) the given PRNG state instead of the default one. *)
  end

  val get_state : unit -> State.t
  (** Return the current state of the generator used by the basic functions. *)

  val set_state : State.t -> unit
  (** Set the state of the generator used by the basic functions. *)
end

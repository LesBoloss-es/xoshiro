(** {1 Xoshiro}

   This library includes OCaml implementation of some pseudorandom number
   generators (PRNGs) designed by David Blackman and Sebastiano Vigna behind an
   interface that mimmics that of the {!Random} module of the standard library.

   The Xoshiro generators (for XOR/shift/rotate) are all-purpose generators ({b
   not cryptographically secure}). Compared to the standard library, they:

   - {b have a bigger state space}: [xoshiro256++]/[xoshiro256**] generators
     have a period of 2²⁵⁶-1.

   - {b pass more tests}: [xoshiro256++]/[xoshiro256**] pass the whole
     {{: http://simul.iro.umontreal.ca/testu01/tu01.html}BigCrush} test suite
     while the {!Random} module of the standard library systematically fails ......

   This module and all the variants (see below) are drop-in replacements of the
   {!Random} module of the standard library. This means you can use {!Xoshiro}
   everywhere where you would use {!Random}. For instance:

   - use [Xoshiro.bits] instead of [Random.bits]
   - (same for [int], [bool], etc. and also for the [State] submodule)
   - use [open Xoshiro] instead of [open Random]
   - or even write [module Random = Xoshiro] at the beginning of every file. *)

(** {2 Variants}

   David Blackman and Sebastiano Vigna present several variants of their
   generators depending on the state size and implementation details. *)

module Xoshiro256plusplus : MakeRandom.Sig.FULL

(** {2 Default}

   The module {!Xoshiro} includes by default an implementation of
   {!Xoshiro256plusplus}. *)

include module type of Xoshiro256plusplus

(** {2 Others} *)

module Splitmix64 : MakeRandom.Sig.FULL

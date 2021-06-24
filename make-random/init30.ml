(** {1 Init30}

   This module contains one unique functor which, provided a type [state] and a
   few functions to initialise and manipulate it, returns a module similar to
   that of {!Stdlib.Random.State}, containing all the functions that initialise
   and manipulate the state.

   In particular, this functor provide convenient initialisation: it takes a
   number [init_size] and a function [init] able to initialise a state when
   given {b an array of size [init_size] containing already "good" bits} and
   derives from it the function [full_init] generating "good" bits out of an
   array of anything containing any kind integers (the array {b can} be empty
   and {b can} contain only low-entropy integers).

   This is the 30-bits version: the function [init] takes an array of [int]
   whose 30 lower bits {b only} are set. It is meant to be used for PRNGs whose
   state is made of 30-bits integers (eg. the one from the standard library). *)

external random_seed: unit -> int array = "caml_sys_random_seed"

module Make (B : Bits.Init30) = struct
  type t = B.state

  let int_array_of_seed ~size seed =
    let combine accu x = Digest.string (accu ^ string_of_int x) in
    let extract d =
      let extract8 i = Char.code d.[i] lsl (i * 8) in
      extract8 0 + extract8 1 + extract8 2 + extract8 3
    in
    let seed = if Array.length seed = 0 then [| 0 |] else seed in
    let l = Array.length seed in
    let arr = Array.init size (fun i -> i) in
    let accu = ref "x" in
    for i = 0 to size-1 + max size l do
      let j = i mod size in
      let k = i mod l in
      accu := combine !accu seed.(k);
      arr.(j) <- (arr.(j) lxor extract !accu) land 0x3FFFFFFF
    done;
    arr

  let full_init state seed =
    B.init state (int_array_of_seed ~size:B.init_size seed)

  let make seed =
    let state = B.new_state () in
    full_init state seed;
    state

  let make_self_init () = make (random_seed ())

  let copy state1 =
    let state2 = B.new_state () in
    B.assign state2 state1;
    state2

  let default =
    let state = B.new_state () in
    full_init state [|B.default_seed|];
    state
end

module Bits = Bits
module Sig = Sig

external random_seed: unit -> int array = "caml_sys_random_seed"

module Init30 (B : Bits.Init30) = struct
  type t = B.state

  let int_array_of_seed ~size seed =
    let combine accu x = Digest.string (accu ^ string_of_int x) in
    let extract d =
      let extract8 i = Char.code d.[i] lsl (i * 8) in
      List.fold_left (+) 0 (List.init 4 extract8)
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

module Init64 (B : Bits.Init64) = struct
  type t = B.state

  let int64_array_of_seed ~size seed =
    let combine accu x = Digest.string (accu ^ string_of_int x) in
    let extract d =
      let extract8 i =
        Int64.(shift_left (of_int (Char.code d.[i])) (i * 8))
      in
      List.fold_left Int64.add 0L (List.init 8 extract8)
    in
    let seed = if Array.length seed = 0 then [| 0 |] else seed in
    let l = Array.length seed in
    let arr = Array.init size Int64.of_int in
    let accu = ref "x" in
    for i = 0 to size-1 + max size l do
      let j = i mod size in
      let k = i mod l in
      accu := combine !accu seed.(k);
      arr.(j) <- Int64.logxor arr.(j) (extract !accu)
    done;
    arr

  let full_init state seed =
    B.init state (int64_array_of_seed ~size:B.init_size seed)

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

module State30 (B : Bits.State30) = struct
  let bits = B.bits

  (* The following is copied from Stdlib.Random.State.

     Copyright 1996 Institut National de Recherche en Informatique et en
     Automatique. *)

  let rec intaux s n =
    let r = bits s in
    let v = r mod n in
    if r - v > 0x3FFFFFFF - n + 1 then intaux s n else v

  let int s bound =
    if bound > 0x3FFFFFFF || bound <= 0
    then invalid_arg "Random.int"
    else intaux s bound

  let rec int32aux s n =
    let b1 = Int32.of_int (bits s) in
    let b2 = Int32.shift_left (Int32.of_int (bits s land 1)) 30 in
    let r = Int32.logor b1 b2 in
    let v = Int32.rem r n in
    if Int32.sub r v > Int32.add (Int32.sub Int32.max_int n) 1l
    then int32aux s n
    else v

  let int32 s bound =
    if bound <= 0l
    then invalid_arg "Random.int32"
    else int32aux s bound

  let rec int64aux s n =
    let b1 = Int64.of_int (bits s) in
    let b2 = Int64.shift_left (Int64.of_int (bits s)) 30 in
    let b3 = Int64.shift_left (Int64.of_int (bits s land 7)) 60 in
    let r = Int64.logor b1 (Int64.logor b2 b3) in
    let v = Int64.rem r n in
    if Int64.sub r v > Int64.add (Int64.sub Int64.max_int n) 1L
    then int64aux s n
    else v

  let int64 s bound =
    if bound <= 0L
    then invalid_arg "Random.int64"
    else int64aux s bound

  let nativeint =
    if Nativeint.size = 32
    then fun s bound -> Nativeint.of_int32 (int32 s (Nativeint.to_int32 bound))
    else fun s bound -> Int64.to_nativeint (int64 s (Int64.of_nativeint bound))

  let rawfloat s =
    let scale = 1073741824.0  (* 2^30 *)
    and r1 = float_of_int (bits s) (* note: in original file, Stdlib.float is used *)
    and r2 = float_of_int (bits s) (* note: in original file, Stdlib.float is used *)
    in (r1 /. scale +. r2) /. scale

  let float s bound = rawfloat s *. bound

  let bool s = (bits s land 1 = 0)
end

module Full30 (B : Bits.Full30) : Sig.Full = struct
  module State = struct
    include State30(B)
    include Init30(B)
  end

  let bits () = State.bits State.default
  let int bound = State.int State.default bound
  let int32 bound = State.int32 State.default bound
  let nativeint bound = State.nativeint State.default bound
  let int64 bound = State.int64 State.default bound
  let float scale = State.float State.default scale
  let bool () = State.bool State.default

  let full_init seed = State.full_init State.default seed
  let init seed = State.full_init State.default [|seed|]
  let self_init () = full_init (random_seed ())

  let get_state () = State.copy State.default
  let set_state s = B.assign State.default s
end

module Full64 (B : Bits.Full64) : Sig.Full = struct
  type state =
    { b_state : B.state ;
      mutable second : int }

  module B30 = struct
    type nonrec state = state

    let u30mask = (1 lsl 30) - 1

    let bits state =
      if state.second > 0 then
        (
          let result = state.second in
          state.second <- -1;
          result
        )
      else
        (
          let result = B.bits state.b_state in
          state.second <- Int64.to_int result land u30mask;
          Int64.(to_int (shift_right_logical result 34))
        )
  end

  module B64 = struct
    type nonrec state = state

    let new_state () =
      { b_state = B.new_state ();
        second = -1 }

    let assign state1 state2 =
      B.assign state1.b_state state2.b_state;
      state1.second <- state2.second

    let init_size = B.init_size

    let init state seed =
      B.init state.b_state seed;
      state.second <- -1

    let default_seed = B.default_seed
  end

  module State = struct
    include State30(B30)
    include Init64(B64)
  end

  let bits () = State.bits State.default
  let int bound = State.int State.default bound
  let int32 bound = State.int32 State.default bound
  let nativeint bound = State.nativeint State.default bound
  let int64 bound = State.int64 State.default bound
  let float scale = State.float State.default scale
  let bool () = State.bool State.default

  let full_init seed = State.full_init State.default seed
  let init seed = State.full_init State.default [|seed|]
  let self_init () = full_init (random_seed ())

  let get_state () = State.copy State.default
  let set_state s = B64.assign State.default s
end

module Basic30 (B : Bits.Basic30) : Sig.Basic = struct
  include Full30 (struct
      type state = unit

      let new_state () = ()
      let assign () () = ()
      let init_size = 1
      let init () _ = ()
      let default_seed = 0

      let bits = B.bits
    end)
end

(* module Basic64 (B : Bits.Basic64) : Sig.Basic = Basic30(struct
 *     let second = ref (-1)
 *
 *     let u30mask = (1 lsl 30) - 1
 *
 *     let bits () =
 *       if !second > 0 then
 *         (
 *           let result = !second in
 *           second := -1;
 *           result
 *         )
 *       else
 *         (
 *           let result = B.bits () in
 *           second := Int64.to_int result land u30mask;
 *           Int64.(to_int (shift_right_logical result 34))
 *         )
 *   end) *)

module StdRandom = Stdlib.Random

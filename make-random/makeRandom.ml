module Bits = Bits
module Sig = Sig

external random_seed: unit -> int array = "caml_sys_random_seed"

module Full (B : Bits.FULL) : Sig.FULL = struct

  module State = struct
    type t = B.state

    let make seed =
      let result = B.new_state () in
      B.full_init result seed;
      result

    let make_self_init () = make (random_seed ())

    let copy s =
      let result = B.new_state () in
      B.assign result s;
      result

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

  let bits () = State.bits B.default
  let int bound = State.int B.default bound
  let int32 bound = State.int32 B.default bound
  let nativeint bound = State.nativeint B.default bound
  let int64 bound = State.int64 B.default bound
  let float scale = State.float B.default scale
  let bool () = State.bool B.default

  let full_init seed = B.full_init B.default seed
  let init seed = B.full_init B.default [|seed|]
  let self_init () = full_init (random_seed ())

  let get_state () = State.copy B.default
  let set_state s = B.assign B.default s
end

module Full64 (B : Bits.FULL64) : Sig.FULL = Full(struct
    type state =
      { b_state : B.state ;
        mutable second : int }

    let new_state () =
      { b_state = B.new_state ();
        second = -1 }

    let assign state1 state2 =
      B.assign state1.b_state state2.b_state;
      state1.second <- state2.second

    let full_init state seed =
      B.full_init state.b_state seed;
      state.second <- -1

    let default =
      { b_state = B.default ;
        second = -1 }

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
  end)

module FullHI64 (B : Bits.FULLHI64) : Sig.FULL = Full64(struct
    type state = B.state
    let bits = B.bits
    let new_state = B.new_state
    let assign = B.assign

    let generate_int64_array ~size seed =
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
      B.full_init state (generate_int64_array ~size:B.full_init_size seed)

    let default =
      let default = new_state () in
      full_init default [|B.default_seed|];
      default
  end)

module Basic (B : Bits.BASIC) : Sig.BASIC = struct
  include Full (struct
      type state = unit

      let new_state () = ()
      let assign () () = ()
      let full_init () _ = ()

      let bits = B.bits

      let default = ()
    end)
end

module Basic64 (B : Bits.BASIC64) : Sig.BASIC = Basic(struct
    let second = ref (-1)

    let u30mask = (1 lsl 30) - 1

    let bits () =
      if !second > 0 then
        (
          let result = !second in
          second := -1;
          result
        )
      else
        (
          let result = B.bits () in
          second := Int64.to_int result land u30mask;
          Int64.(to_int (shift_right_logical result 34))
        )
  end)

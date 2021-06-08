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

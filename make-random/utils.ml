module type NEXT_INT64 = sig
  type state
  val next : state -> int64
end

module type BITS = sig
  type ll_state
  type state

  val make_state : ll_state -> state
  val reset_state : state -> (ll_state -> unit) -> unit
  val make_assign : (ll_state -> ll_state -> unit) -> state -> state -> unit

  val bits : state -> int
end

module BitsOfNextInt64 (N : NEXT_INT64) = struct
  type ll_state = N.state
  type state =
    { ll_state : ll_state ;
      mutable second : int }

  let make_state ll_state = { ll_state ; second = -1 }

  let reset_state state setter =
    setter state.ll_state;
    state.second <- -1

  let make_assign assign s1 s2 =
    assign s1.ll_state s2.ll_state;
    s1.second <- s2.second

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
        let result = N.next state.ll_state in
        state.second <- Int64.to_int result land u30mask;
        Int64.(to_int (shift_right_logical result 34))
      )
end

let full_init_int64_array ~size seed =
  let combine accu x = Digest.string (accu ^ Int.to_string x) in
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

let full_init_int64 seed =
  (full_init_int64_array ~size:1 seed).(0)

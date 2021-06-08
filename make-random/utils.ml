module type NEXT_INT64 = sig
  type state
  val next : state -> int64
end

module BitsOfNextInt64 (N : NEXT_INT64) = struct
  type state =
    { ll_state : N.state ;
      mutable second : int }

  let make_state ll_state = { ll_state ; second = -1 }

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

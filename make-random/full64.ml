external random_seed: unit -> int array = "caml_sys_random_seed"

module Make (B : Bits.Full64) : Sig.Full = struct
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
    include State30.Make(B30)
    include Init64.Make(B64)
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

external random_seed: unit -> int array = "caml_sys_random_seed"

module Make (B : Bits.Full30) : Sig.Full = struct
  module State = struct
    include State30.Make(B)
    include Init30.Make(B)
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

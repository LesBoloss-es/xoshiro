include MakeRandom.Full30Init64(struct
    type state

    external bits : state -> int = "caml_bits"
    external new_state : unit -> state = "caml_new_state"
    external assign : state -> state -> unit = "caml_assign"

    let init_size = 4
    external init : state -> int64 array -> unit = "caml_init"

    let default_seed = 135801055
  end)

let next x =
  let open Int64 in
  x := add !x 0x9e3779b97f4a7c15L;
  let z = !x in
  let z = mul (logxor z (shift_right_logical z 30)) 0xbf58476d1ce4e5b9L in
	let z = mul (logxor z (shift_right_logical z 27)) 0x94d049bb133111ebL in
	logxor z (shift_right_logical z 31)

include MakeRandom.Full(struct
    include MakeRandom.Utils.BitsOfNextInt64(struct
        type state = int64 ref
        let next = next
      end)

    let new_state () = make_state (ref 0L)

    let assign = make_assign (fun s1 s2 -> s1 := !s2)

    let full_init state seed =
      reset_state state @@ fun state ->
      state := MakeRandom.Utils.full_init_int64 seed

    let default = make_state (ref 0x945b4bb1ded856eeL)
    (* the result of [full_init] on 135801055 *)
  end)

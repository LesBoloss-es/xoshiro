let next x =
  let open Int64 in
  x := add !x 0x9e3779b97f4a7c15L;
  let z = !x in
  let z = mul (logxor z (shift_right_logical z 30)) 0xbf58476d1ce4e5b9L in
	let z = mul (logxor z (shift_right_logical z 27)) 0x94d049bb133111ebL in
	logxor z (shift_right_logical z 31)

type state =
  { ll_state : int64 ref ;
    mutable second : int }

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
      let result = next state.ll_state in
      state.second <- Int64.to_int result land u30mask;
      Int64.(to_int (shift_right_logical result 34))
    )

include MakeRandom.Basic(struct
    let state =
      { ll_state = ref 7876453234234L;
        second = -1 }

    let bits () = bits state
  end)

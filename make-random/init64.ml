external random_seed: unit -> int array = "caml_sys_random_seed"

module Make (B : Bits.Init64) = struct
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

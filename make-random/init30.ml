external random_seed: unit -> int array = "caml_sys_random_seed"

module Make (B : Bits.Init30) = struct
  type t = B.state

  let int_array_of_seed ~size seed =
    let combine accu x = Digest.string (accu ^ string_of_int x) in
    let extract d =
      let extract8 i = Char.code d.[i] lsl (i * 8) in
      List.fold_left (+) 0 (List.init 4 extract8)
    in
    let seed = if Array.length seed = 0 then [| 0 |] else seed in
    let l = Array.length seed in
    let arr = Array.init size (fun i -> i) in
    let accu = ref "x" in
    for i = 0 to size-1 + max size l do
      let j = i mod size in
      let k = i mod l in
      accu := combine !accu seed.(k);
      arr.(j) <- (arr.(j) lxor extract !accu) land 0x3FFFFFFF
    done;
    arr

  let full_init state seed =
    B.init state (int_array_of_seed ~size:B.init_size seed)

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

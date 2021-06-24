let rotl x k =
  let open Int64 in
  logor (shift_left x k) (shift_right_logical x (64 - k))

let next s =
  let open Int64 in

  (* const uint64_t result = rotl(s[0] + s[3], 23) + s[0]; *)
  let result = Int64.add (rotl (Int64.add s.(0) s.(3)) 23) s.(0) in

  (* const uint64_t t = s[1] << 17; *)
  let t = shift_left s.(1) 17 in

  (* s[2] ^= s[0]; *)
  s.(2) <- logxor s.(2) s.(0);
  (* s[3] ^= s[1]; *)
  s.(3) <- logxor s.(3) s.(1);
  (* s[1] ^= s[2]; *)
  s.(1) <- logxor s.(1) s.(2);
  (* s[0] ^= s[3]; *)
  s.(0) <- logxor s.(0) s.(3);

  (* s[2] ^= t; *)
  s.(2) <- logxor s.(2) t;

  (* s[3] = rotl(s[3], 45); *)
  s.(3) <- rotl s.(3) 45;

  (* return result; *)
  result

include MakeRandom.Full64(struct
    type state = int64 array
    let bits = next

    let new_state () =
      Array.make 4 Int64.zero

    let assign state1 state2 =
      Array.blit state2 0 state1 0 4

    let init_size = 4
    let init state seed =
      assign state seed

    let default_seed = 135801055
  end)

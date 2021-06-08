let[@inline] rotl x k =
  let open Int64 in
  logor (shift_left x k) (shift_right_logical x (64 - k))

let ( .!() ) = Array.unsafe_get
let ( .!()<- ) = Array.unsafe_set

let next s =
  let open Int64 in

  (* const uint64_t result = rotl(s[0] + s[3], 23) + s[0]; *)
  let result = Int64.add (rotl (Int64.add s.!(0) s.!(3)) 23) s.!(0) in

  (* const uint64_t t = s[1] << 17; *)
  let t = shift_left s.!(1) 17 in

  (* s[2] ^= s[0]; *)
  s.!(2) <- logxor s.!(2) s.!(0);
  (* s[3] ^= s[1]; *)
  s.!(3) <- logxor s.!(3) s.!(1);
  (* s[1] ^= s[2]; *)
  s.!(1) <- logxor s.!(1) s.!(2);
  (* s[0] ^= s[3]; *)
  s.!(0) <- logxor s.!(0) s.!(3);

  (* s[2] ^= t; *)
  s.!(2) <- logxor s.!(2) t;

  (* s[3] = rotl(s[3], 45); *)
  s.!(3) <- rotl s.!(3) 45;

  (* return result; *)
  result

include MakeRandom.Full(struct
    include MakeRandom.Utils.BitsOfNextInt64(struct
        type state = int64 array
        let next = next
      end)

    let new_state () =
      make_state (Array.make 4 Int64.zero)

    let default =
      make_state
        [| 0xdeadbeefdeadbeefL;
           0x4242424242424242L;
           0x3737373737373737L;
           0xca7aca7aca7aca7aL |] (* FIXME *)

    let assign s1 s2 =
      Array.blit s2.ll_state 0 s1.ll_state 0 4;
      s1.second <- s2.second

    let full_init _state _seed =
      assert false
  end)

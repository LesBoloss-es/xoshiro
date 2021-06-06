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

(* include MakeRandom.Full(struct
 *     type state =
 *       { ll_state : int64 array ;
 *         mutable second : int ;
 *         mutable use_second : bool }
 *
 *     let new_state () =
 *       { ll_state = Array.make 4 Int64.zero ;
 *         second = 0 ;
 *         use_second = false }
 *
 *     let default =
 *       { ll_state =
 *           [| 0xdeadbeefdeadbeefL;
 *              0x4242424242424242L;
 *              0x3737373737373737L;
 *              0xca7aca7aca7aca7aL |] ; (\* FIXME *\)
 *         second = 0 ;
 *         use_second = false }
 *
 *     let assign s1 s2 =
 *       Array.blit s2.ll_state 0 s1.ll_state 0 4;
 *       s1.second <- s2.second;
 *       s1.use_second <- s2.use_second
 *
 *     let full_init _state _seed =
 *       assert false
 *
 *     let u30mask = (1 lsl 30) - 1
 *
 *     let bits state =
 *       if state.use_second then
 *         (
 *           state.use_second <- false;
 *           state.second
 *         )
 *       else
 *         (
 *           let result = next state.ll_state in
 *           state.second <- Int64.to_int result land u30mask;
 *           state.use_second <- true;
 *           Int64.(to_int (shift_right_logical result 34))
 *         )
 *   end) *)

include MakeRandom.Full(struct
    type state =
      { ll_state : int64 array ;
        mutable second : int }

    let new_state () =
      { ll_state = Array.make 4 Int64.zero ;
        second = -1 }

    let default =
      { ll_state =
          [| 0xdeadbeefdeadbeefL;
             0x4242424242424242L;
             0x3737373737373737L;
             0xca7aca7aca7aca7aL |] ; (* FIXME *)
        second = -1 }

    let assign s1 s2 =
      Array.blit s2.ll_state 0 s1.ll_state 0 4;
      s1.second <- s2.second

    let full_init _state _seed =
      assert false

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
  end)

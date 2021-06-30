module Pure = Xoshiro256plusplus_pure.LowLevel
module Bindings = Xoshiro256plusplus_bindings.LowLevel

(* According to David Blackman and Sebastiano Vigna, an easy way to xoshiro256++
   is to take splitmix64, seed it to anything and use its output. Since we
   manipulate the low-level interface here which does not have the fancy
   initialisation of MakeRandom, let us go the splitmix way. *)

let rnd_int64 () =
  let int64 = Splitmix64_pure.int64 Int64.max_int in
  if Splitmix64_pure.bool () then
    int64
  else
    Int64.neg int64

let state = [| rnd_int64 (); rnd_int64 (); rnd_int64 (); rnd_int64 () |]

let p_state = Pure.of_int64_array state
let b_state = Bindings.of_int64_array state

let test_case =
  LibSameBits.make_test_case
    ~name:"next"
    ~pp:(fun fmt -> Format.fprintf fmt "0x%Lx")
    "pure" (fun () -> Pure.next p_state)
    "bindings" (fun () -> Bindings.next b_state)

let () = LibSameBits.print_header ()

let () =
  Format.printf "basic test:@.";
  LibSameBits.run_test_case test_case;
  Format.printf "@."

let () =
  Format.printf "after jump:@.";
  Pure.jump p_state;
  Bindings.jump b_state;
  LibSameBits.run_test_case test_case;
  Format.printf "@."

let () =
  Format.printf "after long jump:@.";
  Pure.long_jump p_state;
  Bindings.long_jump b_state;
  LibSameBits.run_test_case test_case;
  Format.printf "@."

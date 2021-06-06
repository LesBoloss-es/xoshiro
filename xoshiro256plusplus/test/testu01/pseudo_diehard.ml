open TestU01

let () = Swrite.set_basic false

(* DIEHARD assumes 32 bits so we provide 32 bits via a float between 0 and 1. *)

let gen = Unif01.create_extern_gen_01 "xoshiro256plusplus" @@ fun () ->
  Xoshiro256plusplus_pure.float 1.

let () = Bbattery.pseudo_diehard gen

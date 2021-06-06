open TestU01

let () = Swrite.set_basic false

let _2_25 = float_of_int (1 lsl 25)

(* Rabbit assumes 32 bits so we provide 32 bits via a float between 0 and 1. *)

let gen = Unif01.create_extern_gen_01 "xoshiro256plusplus" @@ fun () ->
  Xoshiro256plusplus_pure.float 1.

let () = Bbattery.rabbit gen _2_25

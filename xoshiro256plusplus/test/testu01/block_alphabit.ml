open TestU01

let () = Swrite.set_basic false

let _2_25 = float_of_int (1 lsl 25)

let () =
  let gen = Unif01.create_extern_gen_bits "xoshiro256plusplus" Xoshiro256plusplus_pure.bits in
  Bbattery.block_alphabit gen _2_25 0 30;
  Bbattery.block_alphabit gen _2_25 0 15;
  Bbattery.block_alphabit gen _2_25 15 15

open TestU01

let () = Swrite.set_basic false

let () =
  let gen = Unif01.create_extern_gen_bits "xoshiro256++" Xoshiro256plusplus_pure.bits in
  Bbattery.small_crush gen

open TestU01

let () =
  let gen = Unif01.create_extern_gen_bits "xoshiro256plusplus" Xoshiro256plusplus_pure.bits in
  Bbattery.big_crush gen

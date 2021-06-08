open TestU01

let () =
  let gen = Unif01.create_extern_gen_bits "splitmix64" Splitmix64_pure.bits in
  Bbattery.crush gen

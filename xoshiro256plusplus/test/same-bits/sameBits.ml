let () =
  SameBits.run
    "pure"     (module Xoshiro256plusplus_pure)
    "bindings" (module struct
    include Xoshiro256plusplus_bindings
  end)

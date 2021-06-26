let () =
  let open Xoshiro256plusplus_bindings.LowLevel in
  let s = of_int64_array [| 1L; 2L; 3L; 4L |] in
  for _ = 1 to 10 do
    Format.printf "  0x%016Lx@." (next s)
  done;
  Format.printf "@."

let () =
  let open Xoshiro256plusplus_pure.LowLevel in
  let s = of_int64_array [| 1L; 2L; 3L; 4L |] in
  for _ = 1 to 10 do
    Format.printf "  0x%016Lx@." (next s)
  done;
  Format.printf "@."

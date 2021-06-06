module P = Xoshiro256plusplus_pure
module B = Xoshiro256plusplus_bindings

let () =
  for i = 1 to 10_000_000 do
    let p = P.bits () in
    let b = B.bits () in
    if p <> b then
      (
        Format.eprintf "Try #%d yield different bits!@\n" i;
        Format.eprintf "      pure version yields %x@\n" p;
        Format.eprintf "  bindings version yields %x@." b;
        exit 1
      )
  done

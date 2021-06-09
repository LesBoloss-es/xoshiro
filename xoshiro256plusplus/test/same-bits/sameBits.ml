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

let () = P.full_init [|576983; 9809; 66543467|]
let () = B.full_init [|576983; 9809; 66543467|]

let () =
  for i = 1 to 10_000_000 do
    let p = P.bits () in
    let b = B.bits () in
    if p <> b then
      (
        Format.eprintf "Try #%d (after initialisation) yield different bits!@\n" i;
        Format.eprintf "      pure version yields %x@\n" p;
        Format.eprintf "  bindings version yields %x@." b;
        exit 1
      )
  done

let pstate = P.State.make [|67589898; 5643347; 98765456|]
let bstate = B.State.make [|67589898; 5643347; 98765456|]

let () =
  for i = 1 to 10_000_000 do
    let p = P.State.bits pstate in
    let b = B.State.bits bstate in
    if p <> b then
      (
        Format.eprintf "Try #%d (with state) yield different bits!@\n" i;
        Format.eprintf "      pure version yields %x@\n" p;
        Format.eprintf "  bindings version yields %x@." b;
        exit 1
      )
  done

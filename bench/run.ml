module type GEN = MakeRandom.Sig.BASIC

let generators : (string * (module GEN)) list = [
  "stdlib",                  (module Random);
  "splitmix64 (pure)",       (module Splitmix64_pure);
  "xoshiro256++ (pure)",     (module Xoshiro256plusplus_pure);
  "xoshiro256++ (bindings)", (module Xoshiro256plusplus_bindings);
]

type gen_to_test = GTT : ((module GEN) -> unit -> 'a) -> gen_to_test

let tests : (string * gen_to_test) list = [
  "bits",      GTT (fun (module Gen : GEN) () -> Gen.bits ());
  "int",       GTT (fun (module Gen : GEN) () -> Gen.int (1 lsl 30 - 1));
  "int32",     GTT (fun (module Gen : GEN) () -> Gen.int32 Int32.max_int);
  "int64",     GTT (fun (module Gen : GEN) () -> Gen.int64 Int64.max_int);
  "nativeint", GTT (fun (module Gen : GEN) () -> Gen.nativeint Nativeint.max_int);
  "float",     GTT (fun (module Gen : GEN) () -> Gen.float 1.);
  "bool",      GTT (fun (module Gen : GEN) () -> Gen.bool ());
]

let print_header test_name =
  let free = 70 - (12 + String.length test_name) in
  let right = free / 2 in
  let left = free - right in
  Format.printf "\n## %s [ %s ] %s ##@."
    (String.make left '=') test_name (String.make right '=')

let run_test gen_to_test =
  Core.Command.run @@ Core_bench.Bench.make_command (
    List.map
      (fun (name, (module Gen : GEN)) ->
         Core_bench.Bench.Test.create ~name (gen_to_test (module Gen : GEN)))
      generators
  )

let () =
  List.iter
    (fun (test_name, GTT gen_to_test) ->
       print_header test_name;
       run_test gen_to_test)
    tests

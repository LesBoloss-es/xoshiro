module B = Core_bench.Bench
module C = Core.Command

module Pure = Xoshiro256plusplus_pure
module Bindings = Xoshiro256plusplus_bindings

let bits () =
  Format.printf "\n## ================================ [ bits ] ================================ ##\n";
  C.run @@ B.make_command [
    B.Test.create ~name:"stdlib" (fun () -> Random.bits ());
    B.Test.create ~name:"xoshiro256++ (pure)" (fun () -> Pure.bits ());
    B.Test.create ~name:"xoshiro256++ (bindings)" (fun () -> Bindings.bits ());
  ]

let int () =
  Format.printf "\n## ================================ [ int ] ================================= ##\n";
  C.run @@ B.make_command [
    B.Test.create ~name:"stdlib" (fun () -> Random.int (1 lsl 30 - 1));
    B.Test.create ~name:"xoshiro256++ (pure)" (fun () -> Pure.int (1 lsl 30 - 1));
    B.Test.create ~name:"xoshiro256++ (bindings)" (fun () -> Bindings.int (1 lsl 30 - 1));

  ]

let int32 () =
  Format.printf "\n## =============================== [ int32 ] ================================ ##\n";
  C.run @@ B.make_command [
    B.Test.create ~name:"stdlib" (fun () -> Random.int32 Int32.max_int);
    B.Test.create ~name:"xoshiro256++ (pure)" (fun () -> Pure.int32 Int32.max_int);
    B.Test.create ~name:"xoshiro256++ (bindings)" (fun () -> Bindings.int32 Int32.max_int);
  ]

let nativeint () =
  Format.printf "\n## ============================= [ nativeint ] ============================== ##\n";
  C.run @@ B.make_command [
    B.Test.create ~name:"stdlib" (fun () -> Random.nativeint Nativeint.max_int);
    B.Test.create ~name:"xoshiro256++ (pure)" (fun () -> Pure.nativeint Nativeint.max_int);
    B.Test.create ~name:"xoshiro256++ (bindings)" (fun () -> Bindings.nativeint Nativeint.max_int);
  ]

let int64 () =
  Format.printf "\n## =============================== [ int64 ] ================================ ##\n";
  C.run @@ B.make_command [
    B.Test.create ~name:"stdlib" (fun () -> Random.int64 Int64.max_int);
    B.Test.create ~name:"xoshiro256++ (pure)" (fun () -> Pure.int64 Int64.max_int);
    B.Test.create ~name:"xoshiro256++ (bindings)" (fun () -> Bindings.int64 Int64.max_int);
  ]

let float () =
  Format.printf "\n## =============================== [ float ] ================================ ##\n";
  C.run @@ B.make_command [
    B.Test.create ~name:"stdlib" (fun () -> Random.float 1.);
    B.Test.create ~name:"xoshiro256++ (pure)" (fun () -> Pure.float 1.);
    B.Test.create ~name:"xoshiro256++ (bindings)" (fun () -> Bindings.float 1.);
  ]

let bool () =
  Format.printf "\n## ================================ [ bool ] ================================ ##\n";
  C.run @@ B.make_command [
    B.Test.create ~name:"stdlib" (fun () -> Random.bool ());
    B.Test.create ~name:"xoshiro256++ (pure)" (fun () -> Pure.bool ());
    B.Test.create ~name:"xoshiro256++ (bindings)" (fun () -> Bindings.bool ());
  ]

let () =
  bits ();
  int (); int32 (); int64 (); nativeint ();
  bool (); float ()

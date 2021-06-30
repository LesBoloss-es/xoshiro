let epf = Format.eprintf
let fpf = Format.fprintf

let time_limit = 1.
let iterations_limit = 10_000_000
let batch_size = 1000
let refresh_frequency = 0.1

let prec_time =
  1 + int_of_float (ceil (log10 time_limit))

let prec_iterations =
  1 + int_of_float (ceil (log10 (float_of_int iterations_limit)))

(* Test one function *)

let test_function name pp r_name (r : unit -> 'a) s_name (s : unit -> 'a) =

  let begin_time = Sys.time () in (* not real time but portable *)

  let rec test_batch size nb =
    if size > 0 then
      (
        let rv = r () in
        let sv = s () in
        if not (rv = sv) then
          (
            epf "  fail!@.";
            epf "    Try #%d on %s yield different results!@." nb name;
            let len = max (String.length r_name) (String.length s_name) in
            epf "    - %*s yield %a@." len r_name pp rv;
            epf "    - %*s yield %a@." len s_name pp sv;
            exit 1 (* FIXME: better interface *)
          );
        test_batch (size-1) (nb+1)
      )
    else
      nb
  in

  let rec test_all last_refresh nb =
    let curr_time = Sys.time () in
    let time_spent = curr_time -. begin_time in
    if time_spent > time_limit || nb > iterations_limit then
      (     epf "\r  %*.2fs  %*d  %s  OK!@."
              prec_time (Sys.time () -. begin_time)
              prec_iterations (nb - 1)
              name
      )
    else if curr_time > last_refresh +. refresh_frequency then
      (
        epf "\r  %*.2fs  %*d  %s@?" prec_time time_spent prec_iterations nb name;
        let nb = test_batch batch_size nb in
        test_all curr_time nb
      )
    else
      (
        let nb = test_batch batch_size nb in
        test_all last_refresh nb
      )
  in

  test_all 0. 1

(* Test several functions *)

type function_ =
    F :
      string
      * (Format.formatter -> 'a -> unit)
      * (unit -> 'a)
      * (unit -> 'a)
      -> function_

let test_functions r_name s_name (functions : function_ list) =
  epf "  %*s  %*s@."
    (4 + prec_time) "time"
    prec_iterations "#iter";

  List.iter
    (fun (F (name, pp, r, s)) ->
       test_function name pp r_name r s_name s)
    functions

module type BASIC = MakeRandom.Sig.Basic
module type FULL = MakeRandom.Sig.Full

let functions_of_basic (module R : BASIC) (module S : BASIC) =
  [
    F (
      "bits",
      (fun fmt -> fpf fmt "0x%x"),
      (fun () -> R.bits ()),
      (fun () -> S.bits ())
    );
    F (
      "int",
      (fun fmt -> fpf fmt "0x%x"),
      (fun () -> R.int (1 lsl 30 - 1)),
      (fun () -> S.int (1 lsl 30 - 1))
    );
    F (
      "int32",
      (fun fmt -> fpf fmt "0x%lx"),
      (fun () -> R.int32 Int32.max_int),
      (fun () -> S.int32 Int32.max_int)
    );
    F (
      "int64",
      (fun fmt -> fpf fmt "0x%Lx"),
      (fun () -> R.int64 Int64.max_int),
      (fun () -> S.int64 Int64.max_int)
    );
    F (
      "nativeint",
      (fun fmt -> fpf fmt "0x%nx"),
      (fun () -> R.nativeint Nativeint.max_int),
      (fun () -> S.nativeint Nativeint.max_int)
    );
    F (
      "float",
      Format.pp_print_float,
      (fun () -> R.float 1.),
      (fun () -> S.float 1.)
    );
    F (
      "bool",
      Format.pp_print_bool,
      (fun () -> R.bool ()),
      (fun () -> S.bool ())
    );
  ]

type state = S : (module FULL with type State.t = 'a) * 'a -> state

let functions_of_state (S ((module R), r_state)) (S ((module S), s_state)) =
  [
    F (
      "State.bits",
      (fun fmt -> fpf fmt "0x%x"),
      (fun () -> R.State.bits r_state),
      (fun () -> S.State.bits s_state)
    );
    F (
      "State.int",
      (fun fmt -> fpf fmt "0x%x"),
      (fun () -> R.State.int r_state (1 lsl 30 - 1)),
      (fun () -> S.State.int s_state (1 lsl 30 - 1))
    );
    F (
      "State.int32",
      (fun fmt -> fpf fmt "0x%lx"),
      (fun () -> R.State.int32 r_state Int32.max_int),
      (fun () -> S.State.int32 s_state Int32.max_int)
    );
    F (
      "State.int64",
      (fun fmt -> fpf fmt "0x%Lx"),
      (fun () -> R.State.int64 r_state Int64.max_int),
      (fun () -> S.State.int64 s_state Int64.max_int)
    );
    F (
      "State.nativeint",
      (fun fmt -> fpf fmt "0x%nx"),
      (fun () -> R.State.nativeint r_state Nativeint.max_int),
      (fun () -> S.State.nativeint s_state Nativeint.max_int)
    );
    F (
      "State.float",
      Format.pp_print_float,
      (fun () -> R.State.float r_state 1.),
      (fun () -> S.State.float s_state 1.)
    );
    F (
      "State.bool",
      Format.pp_print_bool,
      (fun () -> R.State.bool r_state),
      (fun () -> S.State.bool s_state)
    );
  ]

let run
    r_name (module R : FULL)
    s_name (module S : FULL)
  =
  epf "========== [ SameBits ] ==========@\n@.";
  epf "time limit: %.2fs@." time_limit;
  epf "iterations limit: %d@." iterations_limit;
  epf "batch size: %d@." batch_size;
  epf "@.";

  epf "basic tests:@.";
  test_functions r_name s_name (functions_of_basic (module R) (module S));
  epf "@.";

  epf "(saving current state for further tests)@.@.";
  let r_state = R.get_state () in
  let s_state = S.get_state () in

  epf "after re-initialisation with `init`:@.";
  R.init 566631242;
  S.init 566631242;
  test_functions r_name s_name (functions_of_basic (module R) (module S));
  epf "@.";

  epf "after re-initialisation with `full_init`:@.";
  R.full_init [| 566631242; 1112354; 99999999; 0; 12 |];
  S.full_init [| 566631242; 1112354; 99999999; 0; 12 |];
  test_functions r_name s_name (functions_of_basic (module R) (module S));
  epf "@.";

  epf "after loading previously-saved state:@.";
  R.set_state r_state;
  S.set_state s_state;
  test_functions r_name s_name (functions_of_basic (module R) (module S));
  epf "@.";

  epf "still using that same state:@.";
  test_functions r_name s_name (functions_of_state (S ((module R), r_state)) (S ((module S), s_state)));
  epf "@.";

  epf "using a newly-created state:@.";
  let r_state = R.State.make [| 555789242; 1245788956; 1111111; 0; 7 |] in
  let s_state = S.State.make [| 555789242; 1245788956; 1111111; 0; 7 |] in
  test_functions r_name s_name (functions_of_state (S ((module R), r_state)) (S ((module S), s_state)));
  epf "@."

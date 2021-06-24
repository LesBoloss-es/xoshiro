module type BASIC = MakeRandom.Sig.Basic
module type FULL = MakeRandom.Sig.Full

let epf = Format.eprintf
let fpf = Format.fprintf

let prec_time time_limit =
  1 + int_of_float (ceil (log10 time_limit))

let prec_iterations iterations_limit =
  1 + int_of_float (ceil (log10 (float_of_int iterations_limit)))

let test_function
    ~time_limit ~iterations_limit
    ~batch_size ~name
    pp
    r_name (r : unit -> 'a)
    s_name (s : unit -> 'a)
  =
  let prec_time = prec_time time_limit in
  let prec_iterations = prec_iterations iterations_limit in

  let begin_time = Sys.time () in (* not real time but portable *)

  let rec test_batch size nb =
    if size > 0 then
      (
        let rv = r () in
        let sv = s () in
        if not (rv = sv) then
          (
            epf "@.";
            epf "  Try #%d on %s yield different results!@." nb name;
            epf "    %s yield %a@." r_name pp rv;
            epf "    %s yield %a@." s_name pp sv;
            exit 1 (* FIXME: better interface *)
          );
        test_batch (size-1) (nb+1)
      )
    else
      nb
  in

  let rec test_all nb =
    let time_spent = Sys.time () -. begin_time in
    if time_spent > time_limit
       || nb > iterations_limit
    then
      nb
    else
      (
        epf "\r  %*.2fs  %*d  %s@?" prec_time time_spent prec_iterations nb name;
        let nb = test_batch batch_size nb in
        test_all nb
      )
  in

  let nb = test_all 1 in
  epf "\r  %*.2fs  %*d  %s  OK!@."
    prec_time (Sys.time () -. begin_time)
    prec_iterations nb
    name

type test =
    T :
      string
      * (Format.formatter -> 'a -> unit)
      * (unit -> 'a)
      * (unit -> 'a)
      -> test

let test_basic
    ~time_limit ~iterations_limit ~batch_size
    r_name (module R : BASIC)
    s_name (module S : BASIC)
  =

  epf "  %*s  %*s@."
    (4 + prec_time time_limit) "time"
    (prec_iterations iterations_limit) "#iter";

  [
    T (
      "bits",
      Format.pp_print_int,
      (fun () -> R.bits ()),
      (fun () -> S.bits ())
    );
    T (
      "int",
      Format.pp_print_int,
      (fun () -> R.int (1 lsl 30 - 1)),
      (fun () -> S.int (1 lsl 30 - 1))
    );
    T (
      "int32",
      (fun fmt -> fpf fmt "%lx"),
      (fun () -> R.int32 Int32.max_int),
      (fun () -> S.int32 Int32.max_int)
    );
    T (
      "int64",
      (fun fmt -> fpf fmt "%Lx"),
      (fun () -> R.int64 Int64.max_int),
      (fun () -> S.int64 Int64.max_int)
    );
    T (
      "nativeint",
      (fun fmt -> fpf fmt "%nx"),
      (fun () -> R.nativeint Nativeint.max_int),
      (fun () -> S.nativeint Nativeint.max_int)
    );
    T (
      "float",
      Format.pp_print_float,
      (fun () -> R.float 1.),
      (fun () -> S.float 1.)
    );
    T (
      "bool",
      Format.pp_print_bool,
      (fun () -> R.bool ()),
      (fun () -> S.bool ())
    );
  ]

  |> List.iter @@ fun (T (name, pp, r, s)) ->
  test_function
    ~time_limit ~iterations_limit ~batch_size
    ~name pp r_name r s_name s

type state = S : (module FULL with type State.t = 'a) * 'a -> state

let test_state
    ~time_limit ~iterations_limit ~batch_size
    r_name (S ((module R), r_state))
    s_name (S ((module S), s_state))
  =

  epf "  %*s  %*s@."
    (4 + prec_time time_limit) "time"
    (prec_iterations iterations_limit) "#iter";

  [
    T (
      "State.bits",
      Format.pp_print_int,
      (fun () -> R.State.bits r_state),
      (fun () -> S.State.bits s_state)
    );
    T (
      "State.int",
      Format.pp_print_int,
      (fun () -> R.State.int r_state (1 lsl 30 - 1)),
      (fun () -> S.State.int s_state (1 lsl 30 - 1))
    );
    T (
      "State.int32",
      (fun fmt -> fpf fmt "%lx"),
      (fun () -> R.State.int32 r_state Int32.max_int),
      (fun () -> S.State.int32 s_state Int32.max_int)
    );
    T (
      "State.int64",
      (fun fmt -> fpf fmt "%Lx"),
      (fun () -> R.State.int64 r_state Int64.max_int),
      (fun () -> S.State.int64 s_state Int64.max_int)
    );
    T (
      "State.nativeint",
      (fun fmt -> fpf fmt "%nx"),
      (fun () -> R.State.nativeint r_state Nativeint.max_int),
      (fun () -> S.State.nativeint s_state Nativeint.max_int)
    );
    T (
      "State.float",
      Format.pp_print_float,
      (fun () -> R.State.float r_state 1.),
      (fun () -> S.State.float s_state 1.)
    );
    T (
      "State.bool",
      Format.pp_print_bool,
      (fun () -> R.State.bool r_state),
      (fun () -> S.State.bool s_state)
    );
  ]

  |> List.iter @@ fun (T (name, pp, r, s)) ->
  test_function
    ~time_limit ~iterations_limit ~batch_size
    ~name pp r_name r s_name s

let run
    r_name (module R : FULL)
    s_name (module S : FULL)
  =
  epf "========== [ SameBits ] ==========@\n@.";

  let time_limit = 1. in
  let iterations_limit = 10_000_000 in
  let batch_size = 1000 in
  epf "time limit: %.2fs@." time_limit;
  epf "iterations limit: %d@." iterations_limit;
  epf "batch size: %d@." batch_size;
  epf "@.";

  epf "basic tests:@.";
  test_basic
    ~time_limit ~iterations_limit ~batch_size
    r_name (module R) s_name (module S);
  epf "@.";

  epf "(saving current state for further tests)@.@.";
  let r_state = R.get_state () in
  let s_state = S.get_state () in

  epf "after re-initialisation with `init`:@.";
  R.init 566631242;
  S.init 566631242;
  test_basic
    ~time_limit ~iterations_limit ~batch_size
    r_name (module R) s_name (module S);
  epf "@.";

  epf "after re-initialisation with `full_init`:@.";
  R.full_init [| 566631242; 1112354; 99999999; 0; 12 |];
  S.full_init [| 566631242; 1112354; 99999999; 0; 12 |];
  test_basic
    ~time_limit ~iterations_limit ~batch_size
    r_name (module R) s_name (module S);
  epf "@.";

  epf "after loading previously-saved state:@.";
  R.set_state r_state;
  S.set_state s_state;
  test_basic
    ~time_limit ~iterations_limit ~batch_size
    r_name (module R) s_name (module S);
  epf "@.";

  epf "still using that same state:@.";
  test_state
    ~time_limit ~iterations_limit ~batch_size
    r_name (S ((module R), r_state))
    s_name (S ((module S), s_state));
  epf "@.";

  epf "using a newly-created state:@.";
  let r_state = R.State.make [| 555789242; 1245788956; 1111111; 0; 7 |] in
  let s_state = S.State.make [| 555789242; 1245788956; 1111111; 0; 7 |] in
  test_state
    ~time_limit ~iterations_limit ~batch_size
    r_name (S ((module R), r_state))
    s_name (S ((module S), s_state));
  epf "@."

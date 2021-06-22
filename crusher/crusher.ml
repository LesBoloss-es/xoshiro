open TestU01

let () = Swrite.set_basic false

let nb_suspect_p_values = ref 0

let collect_suspect_p_values () =
  let suspectp = Probdist.Gofw.get_suspectp () in
  Bbattery.get_p_val ()
  |> Array.iter
    (fun pval ->
       if pval <= suspectp || 1. -. pval <= suspectp then
         incr nb_suspect_p_values)

let check_suspect_p_values_and_die () =
  if !nb_suspect_p_values > 0 then
    (
      Format.eprintf "There were %d suspect p-values. Exiting!@." !nb_suspect_p_values;
      exit 7
    );
  exit 0

let make ~name bits =
  let gen = Unif01.create_extern_gen_bits name bits in
  Bbattery.small_crush gen;
  collect_suspect_p_values ();
  check_suspect_p_values_and_die ()

(lang dune 2.8)

(name xoshiro)
(source (github LesBoloss-es/xoshiro))
(documentation https://lesboloss-es.github.io/xoshiro/)

(authors
 "Niols “Niols” Jeannerod <niols@niols.fr>"
 "Martin Pépin <kerl@wkerl.me>")
(license LGPL-3.0-or-later)

(maintainers
 "Niols “Niols” Jeannerod <niols@niols.fr>")

(generate_opam_files true)

(package
 (name make-random)
 (version 0.1))

(package
 (name xoshiro)
 (version 0.1)
 (depends
  make-random
  (core_bench :with-test)
  (testu01    (and :with-test (>= 1.2.3-0.2)))))

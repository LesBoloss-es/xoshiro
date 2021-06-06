(lang dune 2.8)

(package
 (name make-random)
 (version 0.1))

(package
 (name xoshiro)
 (version 0.1)
 (depends make-random))

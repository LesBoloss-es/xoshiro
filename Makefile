.PHONY: build doc test install uninstall clean

build:
	dune build @install
	[ -e bin ] || ln -sf _build/install/default/bin bin
	[ -e lib ] || ln -sf _build/install/default/lib lib

doc:
	dune build @doc
	[ -e doc ] || ln -sf _build/default/_doc/_html doc

test:
	dune test

install:
	dune install

uninstall:
	dune uninstall

clean:
	dune clean
	rm -f *.opam
	rm -f bin lib doc

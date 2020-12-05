run:
	make compile test

compile:
	idris --build sae.ipkg
	idris src/Main.idr -p contrib -o sae

test:
	cd ~/tmp/idris/idris-js/; ~/git/sae/build/exec/sae

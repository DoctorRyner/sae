run:
	make compile test

compile:
	idris src/Main.idr --build sae.ipkg -p contrib -o sae

test:
	cd ~/tmp/idris/idris-js/; ~/git/sae/build/exec/sae

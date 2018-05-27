all: bbt.html

bbt.html: bbt.rkt
	racket $< > $@

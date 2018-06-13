all: index.html

index.html: bbt.rkt reveal.rkt
	racket $< > $@.tmp && mv $@.tmp $@ || rm $@.tmp

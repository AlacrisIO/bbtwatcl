x := bbt

src = evo2017.scrbl
lib = utils.rkt bibliography.scrbl

all: PDF

.PHONY: all dsss splash-i slides html pdf PDF wc mrproper clean

dsss: vdacoab.html
vdacoab.html: vdacoab.rkt reveal.rkt
	racket $< > $@.tmp && mv $@.tmp $@ || rm $@.tmp

splash-i: splash-i.html
splash-i.html: splash-i.rkt reveal.rkt
	racket $< > $@.tmp && mv $@.tmp $@ || rm $@.tmp

boston-blockchain-meetup-2018-11-06.html: boston-blockchain-meetup-2018-11-06.rkt
	racket $< > $@.tmp && mv $@.tmp $@ || rm $@.tmp

slides: index.html
index.html: bbt.rkt reveal.rkt
	racket $< > $@.tmp && mv $@.tmp $@ || rm $@.tmp

html: ${x}.html
pdf: ${x}.pdf
PDF: pdf ${x}.PDF
wc: ${x}.wc

%.W: %.html
	w3m -T text/html $<

%.wc: %.html
	perl $$(which donuts.pl) unhtml < $< | wc

%.PDF: %.pdf
	#evince -f -i $${p:-1} $<
	xpdf -z page -fullscreen $< $(p)

%.pdf: %.scrbl ${lib}
	time scribble --dest-name $@ --pdf $<

${x}.html: ${x}.scrbl ${lib}
%.html: %.scrbl ${lib}
	time scribble --dest-name $@ --html $<

%.latex: %.scrbl ${lib}
	time scribble --latex --dest tmp $<

clean:
	rm -f *.pdf *.html *.tex *.css *.js
	rm -rf tmp

mrproper:
	git clean -xfd

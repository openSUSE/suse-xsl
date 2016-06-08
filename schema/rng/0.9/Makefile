#
# Makefile to create "flat" RELAX NG schemas
#
# Author:
#   Thomas Schraitle <toms@opensuse.org>
#
# Requirements:
# * trang
# * docbook_5
# * python3-rnginline (from obs://home:thomas-schraitle/python3-rnginline)

SUSESCHEMA := susedoc5
DOCBOOKXI  := /usr/share/xml/docbook/schema/rng/5.1/docbookxi.rnc


.PHONY: all clean
all: $(SUSESCHEMA)-flat.rnc

clean:
	rm $(SUSESCHEMA)-flat.rn{c,g} docbook.rn{c,g} 2>/dev/null || true

docbook.rnc: $(DOCBOOKXI)
	@echo "* Linking $< -> $@"
	ln -sf $<

.INTERMEDIATE: $(SUSESCHEMA).rng
$(SUSESCHEMA).rng: docbookxi.rnc $(SUSESCHEMA).rnc
	@echo "* Converting $< -> $@"
	trang $< $@

$(SUSESCHEMA)-flat.rng: $(SUSESCHEMA).rng
	@echo "* Flattening $< -> $@"
	rnginline $< $@

$(SUSESCHEMA)-flat.rnc: $(SUSESCHEMA)-flat.rng
	@echo "* Converting $< -> $@"
	trang $< $@
	sed -i -r 's/\s+$$//' $@

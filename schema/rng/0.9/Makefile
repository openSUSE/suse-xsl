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


.PHONY: all clean
all: susedoc5-flat.rnc

clean:
	rm susedoc5-flat.rn{c,g} susedoc5.rng docbook.rn{c,g} 2>/dev/null || true

docbook.rnc: /usr/share/xml/docbook/schema/rng/5.1/docbookxi.rnc
	@echo "* Linking $< -> $@"
	ln -sf $< .

susedoc5.rng: docbookxi.rnc susedoc5.rnc
	@echo "* Converting $< -> $@"
	trang $< $@

susedoc5-flat.rng: susedoc5.rng
	@echo "* Flattening $< -> $@"
	rnginline $< $@

susedoc5-flat.rnc: susedoc5-flat.rng
	@echo "* Converting $< -> $@"
	trang $< $@
	@sed -i -r 's/\s+//' $@


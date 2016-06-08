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


.PHONY: all clean flat
all: geekodoc5-flat.rnc

clean:
	rm geekodoc5-flat.rn{c,g} geekodoc5.rng docbookxi.rn{c,g} 2>/dev/null || true

flat: geekodoc5-flat.rnc
	rm geekodoc5{,-flat}.rng docbook.rn{c,g} 2>/dev/null || true

docbookxi.rnc: /usr/share/xml/docbook/schema/rng/5.1/docbookxi.rnc
	@echo "* Linking $< -> $@"
	ln -sf $< .

geekodoc5.rng: docbookxi.rnc geekodoc5.rnc
	@echo "* Converting $< -> $@"
	trang $< $@
	@sed -i -r 's/\s+//' $@

geekodoc5-flat.rng: geekodoc5.rng
	@echo "* Flattening $< -> $@"
	rnginline $< $@.unclean
	xmllint -o $@.unclean --nsclean --format $@
	rm $@.unclean
	@sed -i -r 's/\s+//' $@

geekodoc5-flat.rnc: geekodoc5-flat.rng
	@echo "* Converting $< -> $@"
	trang $< $@
	@sed -i -r 's/\s+//' $@

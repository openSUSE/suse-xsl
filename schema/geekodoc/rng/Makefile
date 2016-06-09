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


.SUFFIXES: .rng rnc

SUSESCHEMA := geekodoc5
DOCBOOKXI_RNC_PATH  := /usr/share/xml/docbook/schema/rng/5.1/docbookxi.rnc
DOCBOOKXI_RNC := $(notdir $(DOCBOOKXI_RNC_PATH))
DOCBOOKXI_RNG := $(patsubst .rnc,.rng,$(DOCBOOKXI_RNC))


.PHONY: all clean

all: $(SUSESCHEMA)-flat.rnc

clean:
	rm $(SUSESCHEMA)-flat.rnc $(DOCBOOKXI_RNC) $(DOCBOOKXI_RNG) 2>/dev/null || true


.INTERMEDIATE: $(SUSESCHEMA).rng $(SUSESCHEMA)-flat.rni $(SUSESCHEMA)-flat.rng


$(DOCBOOKXI_RNC): $(DOCBOOKXI_RNC_PATH)
	@echo "* Linking $< -> $@"
	ln -sf $<

$(SUSESCHEMA).rng: $(DOCBOOKXI_RNC) $(SUSESCHEMA).rnc
	@echo "* Converting $< -> $@"
	trang $< $@

$(SUSESCHEMA)-flat.rni: $(SUSESCHEMA).rng
	@echo "* Flattening $< -> $@"
	rnginline $< $@

$(SUSESCHEMA)-flat.rng: $(SUSESCHEMA)-flat.rni
	echo '* Cleaning up schema contents $< -> $@'
	xmllint -o $@ --nsclean --format $<

$(SUSESCHEMA)-flat.rnc: $(SUSESCHEMA)-flat.rng
	@echo "* Converting $< -> $@"
	trang $< $@
	@sed -i -r 's_\s+$$__' $@


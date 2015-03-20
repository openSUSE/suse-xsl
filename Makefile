# Makefile for suse-xsl-stylesheets
#
# Copyright (C) 2011-2015 SUSE Linux GmbH
#
# Author:
# Frank Sundermeyer <fsundermeyer@opensuse.org>
#

PACKAGE    := suse-xsl-stylesheets
DTDNAME    := novdoc
DTDVERSION := 1.0

SUSEXSL_FOR-CATALOG    := for-catalog-$(PACKAGE).xml
NOVDOC_FOR-CATALOG     := for-catalog-$(DTDNAME)-$(DTDVERSION).xml
NOVDOC_SCHEMA          := /usr/share/xml/novdoc/schema/dtd/$(DTDVERSION)

# html4 stylesheets for STYLEDIR2005 are autogenerated from the xhtml
# stylesheets so we only need to maintain them in one place
#
XHTML2HTML    := xslt2005/common/xhtml2html.xsl
HTMLSTYLESHEETS := $(subst /xhtml/,/html/,$(wildcard xslt2005/xhtml/*.xsl))

#-------
# Directories for installation
ifndef PREFIX
  PREFIX := /usr/share
endif
STYLEDIR2005     := $(DESTDIR)$(PREFIX)/xml/docbook/stylesheet/suse
SUSESTYLEDIR2013 := $(DESTDIR)$(PREFIX)/xml/docbook/stylesheet/suse2013
DAPSSTYLEDIR2013 := $(DESTDIR)$(PREFIX)/xml/docbook/stylesheet/daps2013
OPENSUSESTYLEDIR2013 := $(DESTDIR)$(PREFIX)/xml/docbook/stylesheet/opensuse2013
DOCDIR           := $(DESTDIR)$(PREFIX)/doc/packages/suse-xsl-stylesheets
DTDDIR           := $(DESTDIR)$(PREFIX)/xml/$(DTDNAME)/schema/dtd/$(DTDVERSION)
RNGDIR           := $(DESTDIR)$(PREFIX)/xml/$(DTDNAME)/schema/rng/$(DTDVERSION)
TTF_FONT_DIR     := $(DESTDIR)$(PREFIX)/fonts/truetype
CATALOG_DIR      := $(DESTDIR)/etc/xml
SGML_DIR         := $(DESTDIR)$(PREFIX)/sgml
VAR_SGML_DIR     := $(DESTDIR)/var/lib/sgml

#-------
# Directories for file creation
DEV_CATALOG_DIR := catalogs
DEV_XHTML_DIR   := xslt2005/xhtml

INST_DIRECTORIES := $(STYLEDIR2005) $(SUSESTYLEDIR2013) \
     $(DAPSSTYLEDIR2013) $(OPENSUSESTYLEDIR2013) $(DOCDIR) $(DTDDIR) \
     $(RNGDIR) $(TTF_FONT_DIR) $(CATALOG_DIR) $(SGML_DIR) $(VAR_SGML_DIR)

DEV_DIRECTORIES := $(DEV_CATALOG_DIR) $(DEV_XHTML_DIR)

all: schema/novdocx-core.rnc schema/novdocx-core.rng schema/novdocx.rng
all: schema/novdocxi.rng
all: catalogs/$(NOVDOC_FOR-CATALOG) catalogs/$(SUSEXSL_FOR-CATALOG)
all: catalogs/CATALOG.$(DTDNAME)-$(DTDVERSION)
all: xhtml2html
	@echo "Ready to install..."

install: | $(INST_DIRECTORIES)
	install -m644 schema/*.{rnc,rng} $(RNGDIR)
	install -m644 schema/{*.dtd,*.ent,catalog.xml,CATALOG} $(DTDDIR)
	install -m644 catalogs/CATALOG.$(DTDNAME)-$(DTDVERSION) $(VAR_SGML_DIR)
	ln -s /var/lib/sgml/CATALOG.$(DTDNAME)-$(DTDVERSION) $(SGML_DIR)
	install -m644 catalogs/*.xml $(CATALOG_DIR)
	install -m644 COPYING* $(DOCDIR)
	install -m644 fonts/*.ttf $(TTF_FONT_DIR)
	tar c --mode=u+w,go+r-w,a-s -C xslt2005 . | (cd  $(STYLEDIR2005); tar xpv)
	tar c --mode=u+w,go+r-w,a-s -C suse2013 . | (cd  $(SUSESTYLEDIR2013); tar xpv)
	tar c --mode=u+w,go+r-w,a-s -C daps2013 . | (cd  $(DAPSSTYLEDIR2013); tar xpv)
	tar c --mode=u+w,go+r-w,a-s -C opensuse2013 . | (cd  $(OPENSUSESTYLEDIR2013); tar xpv)


.PHONY: clean
clean:
	rm -rf catalogs/ schema/novdocx-core.rnc schema/novdocx-core.rng \
		schema/novdocx.rng schema/novdocxi.rng xslt2005/html/

# auto-generate the html stylesheets for STYLEDIR2005
#
.PHONY: xhtml2html
xhtml2html: $(HTMLSTYLESHEETS)


#-----------------------------
# Auto-generate HTML stylesheets from XHTML:
xslt2005/html/%.xsl: xslt2005/xhtml/%.xsl | $(DEV_XHTML_DIR)
	xsltproc --output $@  ${XHTML2HTML} $<


#-----------------------------
# Generate SGML catalog for novdoc
#
catalogs/CATALOG.$(DTDNAME)-$(DTDVERSION): | $(DEV_CATALOG_DIR)
catalogs/CATALOG.$(DTDNAME)-$(DTDVERSION):
	echo \
	  "CATALOG \"$(NOVDOC_SCHEMA)/CATALOG\"" \
	  > $@

#-----------------------------
# Generate RELAX NG schemes for novdoc
#

schema/novdocx-core.rnc: schema/novdocx.dtd.tmp
	trang -I dtd -i no-generate-start $< $@

schema/novdocx-core.rng: schema/novdocx.dtd.tmp
	trang -I dtd -i no-generate-start $< $@

schema/novdocx.rng: schema/novdocx.rnc schema/novdocx-core.rng
	trang -I rnc $< $@

schema/novdocxi.rng: schema/novdocxi.rnc schema/novdocx-core.rng
	trang -I rnc $< $@


# To avoid unknown host errors with trang, we have to switch off the external
# entities from DocBook by creating a temporary file novdocx.dtd.tmp.
# As the entities are not used in RELAX NG anyway, this is uncritical.
#
.INTERMEDIATE: schema/novdocx.dtd.tmp
schema/novdocx.dtd.tmp: $(DIRECTORIES)
	sed 's:\(%[ \t]*ISO[^\.]*\.module[ \t]*\)"INCLUDE":\1"IGNORE":g' \
	  < schema/novdocx.dtd > $@

#-----------------------------
# Generate NOVDOC catalog
#

# since xmlcatalog cannot create groups (<group>) we need to use sed
# to fix this; while we are at it, we also remove the DOCTYPE line since
# it may cause problems with some XML parsers (hen/egg problem)
#
catalogs/$(NOVDOC_FOR-CATALOG): | $(DEV_CATALOG_DIR)
catalogs/$(NOVDOC_FOR-CATALOG):
	xmlcatalog --noout --create $@
	xmlcatalog --noout --add "delegatePublic" "-//Novell//DTD NovDoc XML" \
	  "file://$(NOVDOC_SCHEMA)/catalog.xml" $@
	xmlcatalog --noout --add "delegateSystem" "novdocx.dtd" \
	  "file://$(NOVDOC_SCHEMA)/catalog.xml" $@
	sed -i '/^<!DOCTYPE .*>$$/d' $@
	sed -i '/<catalog/a\ <group id="$(DTDNAME)-$(DTDVERSION)">' $@
	sed -i '/<\/catalog/i\ </group>' $@

catalogs/$(SUSEXSL_FOR-CATALOG): | $(DEV_CATALOG_DIR)

# FIXME: None of the below URLs exist. Would be good if they would at least
#        redirect into the SVN instead of 404ing.
catalogs/$(SUSEXSL_FOR-CATALOG):
	xmlcatalog --noout --create $@
	xmlcatalog --noout --add "rewriteSystem" \
	  "http://daps.sourceforge.net/release/suse-xsl/current" \
	  "file://$(subst $(DESTDIR),,$(STYLEDIR2005))" $@
	xmlcatalog --noout --add "rewriteSystem" \
	  "http://daps.sourceforge.net/release/suse2-xsl/current" \
      "file://$(subst $(DESTDIR),,$(SUSESTYLEDIR2013))" $@
	xmlcatalog --noout --add "rewriteSystem" \
	  "http://daps.sourceforge.net/release/daps2-xsl/current" \
      "file://$(subst $(DESTDIR),,$(DAPSSTYLEDIR2013))" $@
	xmlcatalog --noout --add "rewriteSystem" \
	  "http://daps.sourceforge.net/release/opensuse2-xsl/current" \
      "file://$(subst $(DESTDIR),,$(OPENSUSESTYLEDIR2013))" $@
	sed -i '/^<!DOCTYPE .*>$$/d' $@
	sed -i '/<catalog/a\ <group id="$(PACKAGE)">' $@
	sed -i '/<\/catalog/i\ </group>' $@

# create needed directories
#
$(INST_DIRECTORIES) $(DEV_DIRECTORIES):
	mkdir -p $@

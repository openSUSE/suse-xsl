# Makefile for suse-xsl-stylesheets-sbp
#
# Copyright (C) 2011-2018 SUSE Linux GmbH
#
# Author:
# Frank Sundermeyer <fsundermeyer at opensuse dot org>
#
ifndef PREFIX
  PREFIX := /usr/share
endif

SHELL         := /bin/bash
PACKAGE       := suse-xsl-stylesheets-sbp
# HINT: Also raise version number in packaging/suse-xsl-stylesheets.spec
VERSION       := 2.0.16
CDIR          := $(shell pwd)
DIST_EXCLUDES := packaging/exclude-files_for_susexsl_package.txt
SUSE_XML_PATH := $(PREFIX)/xml/suse
DB_XML_PATH   := $(PREFIX)/xml/docbook
SUSE_SCHEMA_PATH := $(SUSE_XML_PATH)/schema
SUSE_STYLES_PATH := $(DB_XML_PATH)/stylesheet
XSL_INST_PATH := /usr/share/xml/docbook/stylesheet/
URL           := https://raw.githubusercontent.com/openSUSE/suse-xsl/master

#--------------------------------------------------------------
# stylesheet directory names

DIR2013_SUSE     := suse2013-sbp

ALL_STYLEDIRS := $(DIR2013_SUSE)

#--------------------------------------------------------------
# Directories and files that will be created

BUILD_DIR       := build
DEV_CATALOG_DIR := $(BUILD_DIR)/catalog.d
DEV_STYLE_DIR   := $(BUILD_DIR)/stylesheet

# Catalog stuff
SUSEXSL_CATALOG    := catalog.d/$(PACKAGE).xml

DEV_SUSEXSL_CATALOG := $(DEV_CATALOG_DIR)/$(PACKAGE).xml

#-------
# Local Stylesheets Directories

DEV_DIR2013_SUSE     := $(DEV_STYLE_DIR)/$(DIR2013_SUSE)-ns

DEV_DIRECTORIES := $(DEV_CATALOG_DIR) $(DEV_HTML_DIR) \
   $(DEV_DIR2013_SUSE)

LOCAL_STYLEDIRS := $(DIR2013_SUSE) $(DEV_DIR2013_SUSE)


#-------------------------------------------------------
# Directories for installation

INST_STYLE_ROOT          := $(DESTDIR)$(SUSE_STYLES_PATH)

SUSESTYLEDIR2013        := $(INST_STYLE_ROOT)/$(DIR2013_SUSE)
SUSESTYLEDIR2013-NS     := $(INST_STYLE_ROOT)/$(DIR2013_SUSE)-ns

DOCDIR        := $(DESTDIR)$(PREFIX)/doc/packages/suse-xsl-stylesheets-sbp
TTF_FONT_DIR  := $(DESTDIR)$(PREFIX)/fonts/truetype
CATALOG_DIR   := $(DESTDIR)/etc/xml/catalog.d
SGML_DIR      := $(DESTDIR)$(PREFIX)/sgml
VAR_SGML_DIR  := $(DESTDIR)/var/lib/sgml

INST_STYLEDIRS := $(SUSESTYLEDIR2013) $(SUSESTYLEDIR2013-NS)

INST_DIRECTORIES := $(INST_STYLEDIRS) $(DOCDIR) $(DTDDIR_10) \
   $(RNGDIR_09) $(RNGDIR_10) $(TTF_FONT_DIR) $(CATALOG_DIR) $(SGML_DIR) \
   $(VAR_SGML_DIR)

#############################################################

all: $(DEV_SUSEXSL_CATALOG)
all: $(HTMLSTYLESHEETS) generate_xslns
	@echo "Ready to install..."

#-----------------------------
install: | $(INST_DIRECTORIES)
	install -m644 $(DEV_CATALOG_DIR)/*.xml $(CATALOG_DIR)
	install -m644 COPYING* $(DOCDIR)
	tar c --mode=u+w,go+r-w,a-s -C $(DIR2013_SUSE) . | (cd  $(SUSESTYLEDIR2013); tar xp)
	tar c --mode=u+w,go+r-w,a-s -C $(DEV_DIR2013_SUSE) . | (cd  $(SUSESTYLEDIR2013-NS); tar xp)
	for SDIR in $(INST_STYLEDIRS); do \
	   sed "s/@@#version@@/$(VERSION)/" $$SDIR/VERSION.xsl > $$SDIR/VERSION.xsl.0; \
	   mv $$SDIR/VERSION.xsl.0 $$SDIR/VERSION.xsl; \
	   cp $$SDIR/VERSION.xsl $$SDIR/VERSION; \
	done

#-----------------------------
.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)

#-----------------------------
# auto-generate the DocBook5 (xsl-ns) stylesheets
# Let's be super lazy and generate them every time make is called by
# making this target PHONY
#
.PHONY: generate_xslns
generate_xslns: | $(LOCAL_STYLEDIRS)
	bin/xslns-build $(DIR2013_SUSE) $(DEV_DIR2013_SUSE)


# Generate XML catalog file:
# * replace xml:base attribute
# * replace "build/stylesheet/" directory part
$(DEV_SUSEXSL_CATALOG): $(SUSEXSL_CATALOG) | $(DEV_CATALOG_DIR)
	@echo "Creating XML catalog $@..."
	@sed 's_xml:base=".."_xml:base="file://$(XSL_INST_PATH)"_g;s_"build/stylesheet/_"_g' $< > $@

# create needed directories
#
$(INST_DIRECTORIES) $(DEV_DIRECTORIES) $(BUILD_DIR):
	@mkdir -p $@

#-----------------------------
# create tarball
#

.PHONY: dist
dist: | $(BUILD_DIR)
	@tar cfjhP $(BUILD_DIR)/$(PACKAGE)-$(VERSION).tar.bz2 \
	  -C $(CDIR) --exclude-from=$(DIST_EXCLUDES) \
	  --transform 's:^$(CDIR):suse-xsl-stylesheets-$(VERSION):' $(CDIR)
	@echo "Successfully created $(BUILD_DIR)/$(PACKAGE)-$(VERSION).tar.bz2"

PHONY: dist-clean
dist-clean:
	rm -f $(BUILD_DIR)/$(PACKAGE)-$(VERSION).tar.bz2	
	rmdir $(BUILD_DIR) 2>/dev/null || true

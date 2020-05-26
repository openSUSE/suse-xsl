# Makefile for suse-xsl-stylesheets
#
# Copyright (C) 2011-2020 SUSE Linux GmbH
#
# Author:
# Frank Sundermeyer <fsundermeyer at opensuse dot org>
#
ifndef PREFIX
  PREFIX := /usr/share
endif

SHELL         := /bin/bash
PACKAGE       := suse-xsl-stylesheets
VERSION       := 2.0.17
CDIR          := $(shell pwd)
SUSE_XML_PATH := $(PREFIX)/xml/suse
DB_XML_PATH   := $(PREFIX)/xml/docbook
SUSE_STYLES_PATH := $(DB_XML_PATH)/stylesheet
XSL_INST_PATH := /usr/share/xml/docbook/stylesheet/

#--------------------------------------------------------------
# stylesheet directory names

DIR2005          := suse
DIR2013_DAPS     := daps2013
DIR2013_OPENSUSE := opensuse2013
DIR2013_SUSE     := suse2013
# SUSE2020 is only available in a namespaced version
DIR2020_SUSE     := suse2020-ns

#--------------------------------------------------------------
# Directories and files that will be created

BUILD_DIR       := $(CDIR)/build
DEV_CATALOG_DIR := $(BUILD_DIR)/catalog.d
DEV_STYLE_DIR   := $(BUILD_DIR)/stylesheet

# Catalog stuff
SUSEXSL_CATALOG    := catalog.d/$(PACKAGE).xml

DEV_SUSEXSL_CATALOG := $(DEV_CATALOG_DIR)/$(PACKAGE).xml

#-------
# Local Stylesheets Directories

DEV_DIR2005          := $(DEV_STYLE_DIR)/$(DIR2005)-ns
DEV_DIR2013_DAPS     := $(DEV_STYLE_DIR)/$(DIR2013_DAPS)-ns
DEV_DIR2013_OPENSUSE := $(DEV_STYLE_DIR)/$(DIR2013_OPENSUSE)-ns
DEV_DIR2013_SUSE     := $(DEV_STYLE_DIR)/$(DIR2013_SUSE)-ns

DEV_DIRECTORIES := $(DEV_CATALOG_DIR) \
   $(DEV_DIR2005) \
   $(DEV_DIR2013_DAPS) $(DEV_DIR2013_OPENSUSE) $(DEV_DIR2013_SUSE)

LOCAL_STYLEDIRS := $(DIR2005) $(DEV_DIR2005) \
   $(DIR2013_DAPS) $(DEV_DIR2013_DAPS) \
   $(DIR2013_OPENSUSE) $(DEV_DIR2013_OPENSUSE) \
   $(DIR2013_SUSE) $(DEV_DIR2013_SUSE) \
   $(DIR2020_SUSE)


#-------------------------------------------------------
# Directories for installation

INST_STYLE_ROOT         := $(DESTDIR)$(SUSE_STYLES_PATH)

STYLEDIR2005            := $(INST_STYLE_ROOT)/$(DIR2005)
STYLEDIR2005-NS         := $(INST_STYLE_ROOT)/$(DIR2005)-ns
DAPSSTYLEDIR2013        := $(INST_STYLE_ROOT)/$(DIR2013_DAPS)
DAPSSTYLEDIR2013-NS     := $(INST_STYLE_ROOT)/$(DIR2013_DAPS)-ns
OPENSUSESTYLEDIR2013    := $(INST_STYLE_ROOT)/$(DIR2013_OPENSUSE)
OPENSUSESTYLEDIR2013-NS := $(INST_STYLE_ROOT)/$(DIR2013_OPENSUSE)-ns
SUSESTYLEDIR2013        := $(INST_STYLE_ROOT)/$(DIR2013_SUSE)
SUSESTYLEDIR2013-NS     := $(INST_STYLE_ROOT)/$(DIR2013_SUSE)-ns
SUSESTYLEDIR2020-NS     := $(INST_STYLE_ROOT)/$(DIR2020_SUSE)

DOCDIR        := $(DESTDIR)$(PREFIX)/doc/packages/suse-xsl-stylesheets
TTF_FONT_DIR  := $(DESTDIR)$(PREFIX)/fonts/truetype
CATALOG_DIR   := $(DESTDIR)/etc/xml/catalog.d

INST_STYLEDIRS := $(STYLEDIR2005) $(STYLEDIR2005-NS) \
   $(DAPSSTYLEDIR2013) $(DAPSSTYLEDIR2013-NS) \
   $(OPENSUSESTYLEDIR2013) $(OPENSUSESTYLEDIR2013-NS) \
   $(SUSESTYLEDIR2013) $(SUSESTYLEDIR2013-NS) \
   $(SUSESTYLEDIR2020-NS)

INST_DIRECTORIES := $(INST_STYLEDIRS) $(DOCDIR) \
   $(TTF_FONT_DIR) $(CATALOG_DIR)

#-------------------------------------------------------
# Variables for SASS->CSS conversion and other web stuff

styles2020_sass = $(sort $(wildcard source-assets/styles2020/sass/*.sass))

#############################################################

all: $(DEV_SUSEXSL_CATALOG) generate_xslns
	@echo "Ready to install..."

#-----------------------------
install: | $(INST_DIRECTORIES)
	install -m644 $(DEV_CATALOG_DIR)/*.xml $(CATALOG_DIR)
	install -m644 COPYING* $(DOCDIR)
	install -m644 fonts/*.ttf $(TTF_FONT_DIR)
	tar c --mode=u+w,go+r-w,a-s -C $(DIR2005) . | (cd $(STYLEDIR2005); tar xp)
	tar c --mode=u+w,go+r-w,a-s -C $(DEV_DIR2005) . | (cd $(STYLEDIR2005-NS); tar xp)
	tar c --mode=u+w,go+r-w,a-s -C $(DIR2013_DAPS) . | (cd $(DAPSSTYLEDIR2013); tar xp)
	tar c --mode=u+w,go+r-w,a-s -C $(DEV_DIR2013_DAPS) . | (cd $(DAPSSTYLEDIR2013-NS); tar xp)
	tar c --mode=u+w,go+r-w,a-s -C $(DIR2013_OPENSUSE) . | (cd $(OPENSUSESTYLEDIR2013); tar xp)
	tar c --mode=u+w,go+r-w,a-s -C $(DEV_DIR2013_OPENSUSE) . | (cd $(OPENSUSESTYLEDIR2013-NS); tar xp)
	tar c --mode=u+w,go+r-w,a-s -C $(DIR2013_SUSE) . | (cd $(SUSESTYLEDIR2013); tar xp)
	tar c --mode=u+w,go+r-w,a-s -C $(DEV_DIR2013_SUSE) . | (cd $(SUSESTYLEDIR2013-NS); tar xp)
	tar c --mode=u+w,go+r-w,a-s -C $(DIR2020_SUSE) . | (cd  $(SUSESTYLEDIR2020-NS); tar xp)
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
	bin/xslns-build $(DIR2005) $(DEV_DIR2005)
	bin/xslns-build $(DIR2013_DAPS) $(DEV_DIR2013_DAPS)
	bin/xslns-build $(DIR2013_OPENSUSE) $(DEV_DIR2013_OPENSUSE)
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
# minor disadvantages of using Git here:
# * you need to commit before things are packaged (combined with a reminder,
#   may actually be positive)
# * it does not work outside of a Git repo (should be inconsequential)

.PHONY: dist
dist: | $(BUILD_DIR)
	@if [[ -n $$(git status -s | sed -n '/^??/!p') ]]; then \
	  echo "There appear to be uncommitted files in this repo. Commit or stash before building a package."; \
	  exit 1; \
	fi
	git archive --format=tar.gz -o $(BUILD_DIR)/$(PACKAGE)-$(VERSION).tar.gz --prefix=$(PACKAGE)-$(VERSION)/ HEAD
	@echo "Successfully created $(BUILD_DIR)/$(PACKAGE)-$(VERSION).tar.gz"

PHONY: sass-css
sass-css: suse2020-ns/static/css/style.css

# The main file is called 0-style.sass, so it will be listed here first.
suse2020-ns/static/css/style.css: $(styles2020_sass)
	sassc $< $@

PHONY: dist-clean
dist-clean:
	rm -f $(BUILD_DIR)/$(PACKAGE)-$(VERSION).tar.gz
	rmdir $(BUILD_DIR) 2>/dev/null || true

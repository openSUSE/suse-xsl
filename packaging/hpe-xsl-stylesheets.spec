#
# spec file for package hpe-xsl-stylesheets
#
# Copyright (c) 2018 SUSE LINUX GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


%define db_xml_dir        %{_datadir}/xml/docbook
%define suse_styles_dir   %{db_xml_dir}/stylesheet
Name:           hpe-xsl-stylesheets
Version:        1.0.0
Release:        0
Summary:        SUSE-Branded Stylesheets for DocBook
License:        GPL-2.0 OR GPL-3.0
Group:          Productivity/Publishing/XML
URL:            https://github.com/openSUSE/suse-xsl
Source0:        suse-xsl-feature-hpe-layout.zip
BuildRequires:  docbook5-xsl-stylesheets >= 1.77
BuildRequires:  fdupes
# BuildRequires:  libxml2-tools
# BuildRequires:  libxslt
BuildRequires:  make
BuildRequires:  suse-xsl-stylesheets
BuildRequires:  unzip
# Korean -- un-fonts, already required
# Arabic:
Requires:       arabic-amiri-fonts
# Monospace -- dejavu-fonts, already required
# Western fonts fallback -- gnu-free-fonts, already required
# Chinese simplified -- wqy-microhei-fonts, already required
# Chinese traditional:
Requires:       arphic-uming-fonts
# "Generic" font for use in cases where we don't want one of the gnu-free-fonts
Requires:       dejavu-fonts
Requires:       docbook-xsl-stylesheets >= 1.77
Requires:       docbook5-xsl-stylesheets >= 1.77
Requires:       docbook_5
# Western fallback: currently necessary for building with XEP, it seems.
Requires:       ghostscript-fonts-std
# Western fallback 2: These should make the Ghostscript fonts unnecessary.
Requires:       gnu-free-fonts
# FONTS USED IN "suse2013" STYLESHEETS
# Western fonts:
Requires:       google-opensans-fonts
#------
# Fonts
#------
# Special fonts only for HPE:
Requires:       hpe-fonts
# Japanese:
Requires:       ipa-pgothic-fonts
Requires:       ipa-pmincho-fonts
# Japanese:
Requires:       sazanami-fonts
Requires:       sgml-skel >= 0.7
Requires:       sil-charis-fonts
# docbook_4/docbook_5 are required to be able to transform DocBook documents
# that use predefined DocBook entities.
Requires:       suse-xsl-stylesheets
# Korean:
Requires:       un-fonts
# Chinese:
Requires:       wqy-microhei-fonts
Requires(post): sgml-skel >= 0.7
Requires(postun): sgml-skel >= 0.7
# FONTS USED IN "suse" (aka "suse2005") STYLESHEETS
# Proprietary Western:
Recommends:     agfa-fonts
# Source1:        susexsl-fetch-source-git
# Source2:        %%{name}.rpmlintrc
BuildArch:      noarch
# Only needed to fix the "have choice" error between xerces-j2 and crimson
%if 0%{?suse_version} == 1210
BuildRequires:  xerces-j2
%endif
# Fallback for proprietary Western:
# (openSUSE provides liberation2-fonts, while SLE 12 is currently stuck on v1.)
# bsc#1044521
%if ( 0%{?is_opensuse} && 0%{?sle_version} > 120200 ) || 0%{?suse_version} > 1320
Requires:       liberation2-fonts
%else
Requires:       liberation-fonts
%endif

%description
These are HPE-branded XSLT 1.0 stylesheets for DocBook 4 and 5 that are be used
to create the HTML, PDF, and EPUB versions of HPE/SUSE documentation.

#--------------------------------------------------------------------------

%prep
%setup -q -n suse-xsl-feature-hpe-layout

#--------------------------------------------------------------------------

%build
make  %{?_smp_mflags}

#--------------------------------------------------------------------------

%install
make install DESTDIR=%{buildroot} LIBDIR=%{_libdir}

# Remove stuff which is covered by suse-xsl-stylesheets
rm -rf %{buildroot}%{_sysconfdir}/xml/catalog.d/suse*.xml
rm -rf %{buildroot}%{suse_styles_dir}/{suse*,daps*,opensuse*} \
       %{buildroot}%{_datadir}/suse-xsl-stylesheets \
       %{buildroot}%{_datadir}/fonts/truetype \
       %{buildroot}%{_defaultdocdir}/suse-xsl-stylesheets/

# create symlinks:
%fdupes -s %{buildroot}/%{_datadir}

#----------------------
%post
# XML Catalogs
update-xml-catalog
exit 0

%postun
update-xml-catalog
exit 0


#----------------------
%files

# Directories
%dir %{suse_styles_dir}
%dir %{suse_styles_dir}/hpe
%dir %{suse_styles_dir}/hpe-ns

# stylesheets
%{suse_styles_dir}/hpe/*
%{suse_styles_dir}/hpe-ns/*

# Catalogs
%config %{_sysconfdir}/xml/catalog.d/%{name}.xml

#----------------------

%changelog

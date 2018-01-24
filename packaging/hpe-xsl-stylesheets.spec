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
#
Name:           hpe-xsl-stylesheets
Version:        1.0.0
Release:        0
Summary:        HPE-Branded Stylesheets for DocBook
License:        GPL-2.0 OR GPL-3.0
Group:          Productivity/Publishing/XML
URL:            https://github.com/openSUSE/suse-xsl
Source0:        suse-xsl-feature-hpe-layout.zip
BuildRequires:  docbook5-xsl-stylesheets >= 1.77
BuildRequires:  fdupes
BuildRequires:  make
BuildRequires:  suse-xsl-stylesheets
BuildRequires:  unzip

Requires:       sgml-skel >= 0.7
Requires:       suse-xsl-stylesheets
# Delegate all font related dependencies to suse-xsl-stylesheets
# However, for HPE, we need special fonts:
Requires:       hpe-fonts
#
Requires(post): sgml-skel >= 0.7
Requires(postun): sgml-skel >= 0.7
#
BuildArch:      noarch


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

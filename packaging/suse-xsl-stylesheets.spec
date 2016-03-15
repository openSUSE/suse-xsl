#
# spec file for package suse-xsl-stylesheets
#
# Copyright (c) 2015 SUSE LINUX GmbH, Nuernberg, Germany.
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


Name:           suse-xsl-stylesheets
Version:        2.0.4
Release:        0

###############################################################
#
# ATTENTION: Do NOT edit this file outside of
#            https://svn.code.sf.net/p/daps/svn/trunk/daps/\
#            suse/packaging/suse-xsl-stylesheets.spec
#
#  Your changes will be lost on the next update
#  If you do not have access to the SVN repository, notify
#  <fsundermeyer@opensuse.org> and <toms@opensuse.org>
#  or send a patch
#
################################################################

%define novdocversion   1.0
%define novdocname      novdoc
%define regcat          %{_bindir}/sgml-register-catalog
%define dbstyles        %{_datadir}/xml/docbook/stylesheet/nwalsh/current
%define suse_schemas_catalog catalog-for-suse_schemas.xml
%define susexsl_catalog      catalog-for-%{name}.xml
%define suse_schemas_groupname suse_schemas

%define suse_xml_dir    %{_datadir}/xml/suse
%define db_xml_dir      %{_datadir}/xml/docbook
%define suse_schema_dir %{suse_xml_dir}/schema
%define suse_styles_dir %{db_xml_dir}/stylesheet

Summary:        SUSE-Branded Stylesheets for DocBook
License:        GPL-2.0 or GPL-3.0
Group:          Productivity/Publishing/XML
Url:            http://sourceforge.net/p/daps/suse-xslt
Source0:        %{name}-%{version}.tar.bz2
Source1:        susexsl-fetch-source-git
Source2:        %{name}.rpmlintrc
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch

BuildRequires:  aspell
BuildRequires:  aspell-en
BuildRequires:  docbook-xsl-stylesheets >= 1.77
BuildRequires:  docbook5-xsl-stylesheets >= 1.77
BuildRequires:  fdupes
BuildRequires:  libxml2-tools
BuildRequires:  libxslt
BuildRequires:  make
# Only needed to fix the "have choice" error between xerces-j2 and crimson
%if 0%{?suse_version} == 1210
BuildRequires:  xerces-j2
%endif
BuildRequires:  fontpackages-devel
BuildRequires:  trang

Requires:       docbook_4
Requires:       docbook_5
Requires:       docbook-xsl-stylesheets >= 1.77
Requires:       docbook5-xsl-stylesheets >= 1.77

Requires:       libxslt

Recommends:     daps

#------
# Fonts
#------
%if 0%{?suse_version} >= 1220
Requires:       dejavu-fonts
Requires:       gnu-free-fonts
Requires:       liberation-fonts
Recommends:     agfa-fonts
# Japanese:
Recommends:     sazanami-fonts
# Korean:
Recommends:     un-fonts
%else
Requires:       dejavu
Requires:       freefont
Requires:       liberation-fonts
Recommends:     aspell aspell-en
Recommends:     agfa-fonts
# Japanese:
Recommends:     sazanami-fonts
# Korean:
Recommends:     unfonts
%endif
# Chinese -- only available from M17N:fonts in Code 11:
Recommends:     wqy-microhei-fonts

%if 0%{?sles_version}
Recommends:     ttf-founder-simplified
%endif

# FONTS USED IN suse2013 STYLESHEETS
# A rather simplistic solution which roughly means that you need M17N:fonts to
# build the new stylesheets on older OS's.
%if 0%{?suse_version} >= 1220
Requires:       google-opensans-fonts
Requires:       sil-charis-fonts
%else
Recommends:     google-opensans-fonts
Recommends:     sil-charis-fonts
%endif
# Monospace -- dejavu-fonts, already required
# Western fonts fallback -- gnu-free-fonts, already required

# Chinese simplified -- wqy-microhei-fonts, already recommended
# Chinese traditional:
Recommends:     arphic-uming-fonts
# Japanese:
Recommends:     ipa-pgothic-fonts
Recommends:     ipa-pmincho-fonts
# Korean:
Recommends:     nanum-fonts
# Arabic:
Recommends:     arabic-amiri-fonts


%description
These are SUSE-branded XSLT 1.0 stylesheets for DocBook 4 and 5 that are be used
to create the HTML, PDF, and EPUB versions of SUSE documentation. These
stylesheets are based on the original DocBook XSLT 1.0 stylesheets.

This package also provides descriptions of two XML formats which authors can
use: The NovDoc DTD, a subset of the DocBook 4 DTD and the SUSEdoc schema, a
subset of the DocBook 5 schema.

#--------------------------------------------------------------------------
%prep
%setup -q -n %{name}

#--------------------------------------------------------------------------
%build
%__make  %{?_smp_mflags}

#--------------------------------------------------------------------------
%install
make install DESTDIR=$RPM_BUILD_ROOT  LIBDIR=%_libdir

# create symlinks:
%fdupes -s $RPM_BUILD_ROOT/%{_datadir}

#----------------------
%post
# register catalogs
#
# SGML CATALOG
#
if [ -x %{regcat} ]; then
  %{regcat} -a %{_datadir}/sgml/CATALOG.%{novdocname}-%{novdocversion} >/dev/null 2>&1 || true
fi
# XML Catalogs
#
# remove existing entries first - needed for
# zypper in, since it does not call postun
# delete ...
if [ "2" = "$1" ]; then
 edit-xml-catalog --group --catalog %{_sysconfdir}/xml/suse-catalog.xml \
  --del %{suse_schemas_groupname} || true
 edit-xml-catalog --group --catalog %{_sysconfdir}/xml/suse-catalog.xml \
  --del %{name} || true
fi

# ... and (re)add it again
edit-xml-catalog --group --catalog %{_sysconfdir}/xml/suse-catalog.xml \
  --add %{_sysconfdir}/xml/%{suse_schemas_catalog}
edit-xml-catalog --group --catalog %{_sysconfdir}/xml/suse-catalog.xml \
  --add %{_sysconfdir}/xml/%{susexsl_catalog}

%reconfigure_fonts_post
exit 0

#----------------------
%postun
#
# Remove catalog entries
#
# delete catalog entries
# only run if package is really uninstalled ($1 = 0) and not
# in case of an update
#
if [ "0" = "$1" ]; then
  if [ ! -f %{_sysconfdir}/xml/%{suse_schemas_catalog} -a -x /usr/bin/edit-xml-catalog ] ; then
    # SGML: novdoc dtd entry
    %{regcat} -r %{_datadir}/sgml/CATALOG.%{novdocname}-%{novdocversion} >/dev/null 2>&1 || true
    # XML
    # schemas entry
    edit-xml-catalog --group --catalog %{_sysconfdir}/xml/suse-catalog.xml \
        --del %{suse_schemas_groupname}
    # susexsl entry
    edit-xml-catalog --group --catalog %{_sysconfdir}/xml/suse-catalog.xml \
        --del %{name}
  fi
  %reconfigure_fonts_post
fi

exit 0

#----------------------
%posttrans
%reconfigure_fonts_posttrans

#----------------------
%files
%defattr(-,root,root)

# Directories
%dir %{_datadir}/suse-xsl-stylesheets
%dir %{_datadir}/suse-xsl-stylesheets/aspell

%dir %{suse_xml_dir}

%dir %{suse_styles_dir}
%dir %{suse_styles_dir}/suse
%dir %{suse_styles_dir}/suse-ns
%dir %{suse_styles_dir}/suse2013
%dir %{suse_styles_dir}/suse2013-ns
%dir %{suse_styles_dir}/daps2013
%dir %{suse_styles_dir}/daps2013-ns
%dir %{suse_styles_dir}/opensuse2013
%dir %{suse_styles_dir}/opensuse2013-ns

%dir %{suse_schema_dir}
%dir %{suse_schema_dir}/dtd
%dir %{suse_schema_dir}/rng
%dir %{suse_schema_dir}/dtd/1.0
%dir %{suse_schema_dir}/rng/0.9
%dir %{suse_schema_dir}/rng/1.0

%dir %{_ttfontsdir}

%dir %{_defaultdocdir}/%{name}

# stylesheets
%{suse_styles_dir}/suse/*
%{suse_styles_dir}/suse-ns/*
%{suse_styles_dir}/suse2013/*
%{suse_styles_dir}/suse2013-ns/*
%{suse_styles_dir}/daps2013/*
%{suse_styles_dir}/daps2013-ns/*
%{suse_styles_dir}/opensuse2013/*
%{suse_styles_dir}/opensuse2013-ns/*

# SUSE Schemas
%{suse_schema_dir}/dtd/*
%{suse_schema_dir}/rng/*

# Catalogs
%config /var/lib/sgml/CATALOG.*
%{_datadir}/sgml/CATALOG.*
%config %{_sysconfdir}/xml/*.xml

# Fonts
%{_ttfontsdir}/*

# Documentation
%doc %{_defaultdocdir}/%{name}/*

# SUSE aspell dictionary
%{_datadir}/suse-xsl-stylesheets/aspell/en_US-suse-addendum.rws

#----------------------

%changelog

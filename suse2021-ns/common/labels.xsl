<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Returns the number only of an element, if it has one. Normally, this
    is done by the original stylesheets, however, some has to be
    explicitly added.

  Author(s):    Thomas Schraitle <toms@opensuse.org>

  Copyright:    2013, Thomas Schraitle

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:exsl="http://exslt.org/common"
  exclude-result-prefixes="exsl d">

  <xsl:template match="d:refsect1/d:title|d:refnamediv" mode="label.markup"/>


</xsl:stylesheet>
<?xml version="1.0" encoding="UTF-8"?>

<!--
   Purpose:
     Transform DocBook document into single XHTML file

   Target:
     SUSE Best Practices

   Changes from the standard SUSE stylesheets:
    * Titlepage

   Input:
     DocBook 5 document

   Output:
     Chunked XHTML files

   See Also:
     * http://doccookbook.sf.net/html/en/dbc.common.dbcustomize.html
     * http://sagehill.net/docbookxsl/CustomMethods.html#WriteCustomization

   Authors:    Thomas Schraitle <toms@opensuse.org>
   Copyright:  2022 Thomas Schraitle

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="docbook.xsl"/>
  <xsl:import href="../../suse2022-ns/xhtml/chunk-common.xsl"/>
  <xsl:include href="http://docbook.sourceforge.net/release/xsl-ns/current/xhtml/manifest.xsl"/>
  <xsl:include href="http://docbook.sourceforge.net/release/xsl-ns/current/xhtml/chunk-code.xsl"/>

  <xsl:param name="is.chunk" select="1"/>

</xsl:stylesheet>
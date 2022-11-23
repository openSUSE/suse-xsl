<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Transform DocBook document into single XHTML file

   Target:
     SUSE Best Practices

   Changes from the standard SUSE stylesheets:
     * Titlepages contains now a list of authors and company logos

   Input:
     DocBook 5 document

   Output:
     Single XHTML file

   See Also:
     * http://doccookbook.sf.net/html/en/dbc.common.dbcustomize.html
     * http://sagehill.net/docbookxsl/CustomMethods.html#WriteCustomization

   Authors:    Thomas Schraitle <toms@opensuse.org>
   Copyright:  2022 Thomas Schraitle

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:d="http://docbook.org/ns/docbook"
    xmlns:exsl="http://exslt.org/common"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="exsl d">

  <xsl:import href="../../suse2022-ns/xhtml/docbook.xsl"/>

  <xsl:include href="../VERSION.xsl"/>
  <xsl:include href="titlepage.templates.xsl"/>

</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Transform DocBook document into XSL-FO file

   Target:
     SUSE Best Practices

   Changes from the standard SUSE stylesheets:
     * Titlepage

   Input:
     DocBook 5 document

   Output:
     Single XSL-FO file

   See Also:
     * http://doccookbook.sf.net/html/en/dbc.common.dbcustomize.html
     * http://sagehill.net/docbookxsl/CustomMethods.html#WriteCustomization

   Authors:    Thomas Schraitle <toms@opensuse.org>
   Copyright:  2022 Thomas Schraitle

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format">

  <xsl:import href="../../suse2022-ns/fo/docbook.xsl"/>

  <xsl:include href="../VERSION.xsl"/>
  <xsl:include href="param.xsl"/>
  <xsl:include href="article.titlepage.templates.xsl"/>
</xsl:stylesheet>

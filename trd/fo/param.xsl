<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Contains all parameters for TRDs

    See Also:
    * http://docbook.sourceforge.net/release/xsl-ns/current/doc/fo/index.html

  Copyright:  2022 Thomas Schraitle

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  exclude-result-prefixes="d">

  <xsl:param name="titlepage.logo.image"><xsl:value-of select="$styleroot"/>images/trd-lightbulb-title.svg</xsl:param>
  <xsl:param name="json-ld-seriesname">Technical Reference Documentation</xsl:param>

  <xsl:attribute-set name="book.titlepage.recto.style">
    <xsl:attribute name="font-family"><xsl:value-of select="$title.font.family"/></xsl:attribute>
    <xsl:attribute name="text-align">left</xsl:attribute>
    <xsl:attribute name="font-weight">normal</xsl:attribute>
  </xsl:attribute-set>
</xsl:stylesheet>
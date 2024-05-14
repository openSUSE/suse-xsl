<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Contains all parameters for SBP

    See Also:
    * http://docbook.sourceforge.net/release/xsl-ns/current/doc/fo/index.html

  Copyright:  2022 Thomas Schraitle

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  exclude-result-prefixes="d">

  <xsl:param name="titlepage.logo.image"><xsl:value-of select="$styleroot"/>images/sbp-tools-title.svg</xsl:param>

  <!-- Used as series name -->
  <xsl:param name="json-ld-seriesname">SUSE Best Practices</xsl:param>
  <xsl:param name="json-ld-seriesnameshort"/>
</xsl:stylesheet>
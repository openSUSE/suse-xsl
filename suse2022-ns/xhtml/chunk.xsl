<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Transform DocBook document into chunked XHTML files

   Parameters:
     Too many to list here, see here:
     http://docbook.sourceforge.net/release/xsl-ns/current/doc/html/index.html

   Input:
     DocBook 4/5 document

   Output:
     Chunked XHTML files

   See Also:
     * http://doccookbook.sf.net/html/en/dbc.common.dbcustomize.html
     * http://sagehill.net/docbookxsl/CustomMethods.html#WriteCustomization

   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle

-->

<!DOCTYPE xsl:stylesheet>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:d="http://docbook.org/ns/docbook"
    xmlns:exsl="http://exslt.org/common"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:t="http://nwalsh.com/docbook/xsl/template/1.0"
    xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0"
    exclude-result-prefixes="exsl l t d">

  <xsl:import href="docbook.xsl"/>
  <xsl:import href="chunk-common.xsl"/>
  <xsl:include href="http://docbook.sourceforge.net/release/xsl-ns/current/xhtml/manifest.xsl"/>
  <xsl:include href="http://docbook.sourceforge.net/release/xsl-ns/current/xhtml/chunk-code.xsl"/>

  <xsl:param name="is.chunk" select="1"/>


  <xsl:template match="/">
    <xsl:apply-imports/>
    <xsl:choose>
      <xsl:when test="$dcfilename != ''">
        <xsl:call-template name="generate-json-ld-external">
          <xsl:with-param name="node" select="*[1]" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="log.message">
          <xsl:with-param name="level">WARN</xsl:with-param>
          <xsl:with-param name="context-desc">
            <xsl:text>JSON-LD</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="message">
            <xsl:text>The parameter $dcfilename is unset. Cannot create the external JSON file.</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>

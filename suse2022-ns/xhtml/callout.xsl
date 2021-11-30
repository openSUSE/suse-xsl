<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Create callout spans with @id attributes on them.

   Author:    Thomas Schraitle <toms@opensuse.org>, Stefan Knorr <sknorr@suse.de>
   Copyright: 2012, 2022, Thomas Schraitle, Stefan Knorr

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:d="http://docbook.org/ns/docbook"
    xmlns:exsl="http://exslt.org/common"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:t="http://nwalsh.com/docbook/xsl/template/1.0"
    xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0"
    exclude-result-prefixes="exsl l t d">


  <!-- Fixes behavior for HTML 5 where self-closing tags are bad.
  Original: <span id="co-..."/><span class="callout">1</span>
  Modified: <span id="co-..." class="callout">1</span> -->
  <xsl:template match="d:co" name="co">
    <!-- Support a single linkend in HTML -->
    <xsl:variable name="targets" select="key('id', @linkends)"/>
    <xsl:variable name="target" select="$targets[1]"/>

    <xsl:choose>
      <xsl:when test="$target">
        <a>
          <xsl:apply-templates select="." mode="common.html.attributes"/>
          <xsl:choose>
            <xsl:when test="$generate.id.attributes = 0">
              <!-- force an id attribute here -->
              <xsl:if test="@xml:id">
                <xsl:attribute name="id">
                  <xsl:value-of select="(@xml:id)[1]"/>
                </xsl:attribute>
              </xsl:if>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="id.attribute"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:attribute name="href">
            <xsl:call-template name="href.target">
              <xsl:with-param name="object" select="$target"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:call-template name="callout-bug"/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="anchor"/>
        <xsl:call-template name="callout-bug">
          <xsl:with-param name="generate.id" select="@xml:id"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- We just want a span. No fancy images or Unicode etc.
  But we may want an ID as well (see below). -->
  <xsl:template name="callout-bug">
    <xsl:param name="generate.id" select="''"/>

    <span class="callout">
      <xsl:if test="string-length($generate.id) &gt; 0">
        <xsl:attribute name="id">
          <xsl:value-of select="$generate.id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:number count="d:co" level="any" from="d:programlisting|d:screen|d:literallayout|d:synopsis" format="1"/>
    </span>
  </xsl:template>

</xsl:stylesheet>

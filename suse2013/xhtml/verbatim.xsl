<?xml version="1.0" encoding="ASCII"?>
<!--
    Purpose:
    Add a wrapper div around screens, so only the inner part of a screen scrolls.
    Also allows highlighting via highlight.js.

    Author(s):    Stefan Knorr <sknorr@suse.de>
    Copyright: 2012, 2016 Stefan Knorr

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="exsl">

<xsl:template match="programlisting|screen|synopsis|computeroutput|userinput|literallayout">
<!-- This list is intentionally quite strict. "Be strict in what you accept, be
     li{b,t}eral in what you output." (Or something.) In any case, this should
     hopefully keep the documents consistent -->
<xsl:variable name="supported" select="'|apache|bash|c++|css|diff|html|xml|http|ini|json|java|javascript|makefile|nginx|php|perl|python|ruby|sql|crmsh|dockerfile|lisp|yaml|'"/>
<div>
  <xsl:attribute name="class">
    <xsl:text>verbatim-wrap</xsl:text>
    <xsl:if test="@language">
      <xsl:choose>
        <xsl:when test="contains($supported, concat('|', string(normalize-space(@language)), '|'))">
          <xsl:text> highlight </xsl:text><xsl:value-of select="normalize-space(@language)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message><xsl:value-of select="concat('|', @language, '|')"/>, <xsl:value-of select="contains($supported, concat('|', string(normalize-space(@language)), '|'))"/></xsl:message>
          <xsl:message>Unsupported language for highlighting detected: "<xsl:value-of select="@language"/>".</xsl:message>
          <xsl:message>Supported values are: <xsl:value-of select="$supported"/></xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:attribute>
  <xsl:apply-imports/>
</div>
</xsl:template>

</xsl:stylesheet>

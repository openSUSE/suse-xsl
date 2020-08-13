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
    xmlns:d="http://docbook.org/ns/docbook"
    xmlns:exsl="http://exslt.org/common"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="exsl d">

<xsl:template match="d:programlisting|d:screen|d:synopsis|d:computeroutput|d:userinput|d:literallayout">
  <xsl:variable name="supported" select="concat('|', $highlight.supported.languages, '|')"/>
  <xsl:variable name="language" select="translate(normalize-space(@language), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ|', 'abcdefghijklmnopqrstuvwxyz')"/>

  <xsl:call-template name="check.screenlength"/>

  <div>
    <xsl:attribute name="class">
      <xsl:text>verbatim-wrap</xsl:text>
      <xsl:if test="$language">
        <xsl:choose>
          <xsl:when test="contains($supported, concat('|', $language, '|'))">
            <xsl:text> highlight </xsl:text><xsl:value-of select="@language"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>Unsupported language for highlighting detected: "<xsl:value-of select="@language"/>".</xsl:message>
            <xsl:message>Supported values are: <xsl:value-of select="$highlight.supported.languages"/></xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:attribute>
    <xsl:apply-imports/>
  </div>
</xsl:template>

</xsl:stylesheet>

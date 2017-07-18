<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Create HTML generator/PDF creator string.

   Author:    Stefan Knorr <sknorr@suse.de>
   Copyright: 2017, Stefan Knorr

-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


<xsl:param name="converter.name" select="''"/>
<xsl:param name="converter.version" select="''"/>
<xsl:param name="converter.url" select="''"/>

<xsl:template name="converter-string">
  <xsl:if test="$converter.name != '' and $converter.version != ''">
    <xsl:value-of select="concat($converter.name, ' ', $converter.version)"/>
    <xsl:if test="$converter.url != ''">
     <xsl:text> (</xsl:text>
     <xsl:value-of select="$converter.url"/>
     <xsl:text>)</xsl:text>
    </xsl:if>
  <xsl:text> using </xsl:text>
  </xsl:if>
  <xsl:value-of select="$STYLE.NAME"/>
  <xsl:text> </xsl:text>
  <xsl:value-of select="$STYLE.VERSION"/>
  <xsl:text> (based on DocBook </xsl:text>
  <xsl:value-of select="$DistroTitle"/>
  <xsl:text> </xsl:text>
  <xsl:value-of select="$VERSION"/>
  <xsl:text>)</xsl:text>
</xsl:template>

</xsl:stylesheet>

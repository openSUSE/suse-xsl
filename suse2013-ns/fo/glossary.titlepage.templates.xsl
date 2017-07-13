<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Restyle glossary titlepage

  Author(s):  Stefan Knorr <sknorr@suse.de>,
              Thomas Schraitle <toms@opensuse.org>

  Copyright:  2013, Stefan Knorr, Thomas Schraitle

-->
<!DOCTYPE xsl:stylesheet
[
  <!ENTITY % fonts SYSTEM "fonts.ent">
  <!ENTITY % colors SYSTEM "colors.ent">
  <!ENTITY % metrics SYSTEM "metrics.ent">
  %fonts;
  %colors;
  %metrics;
]>
<xsl:stylesheet exclude-result-prefixes="d"
                 version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:fo="http://www.w3.org/1999/XSL/Format">


  <!-- Glossary =================================================== -->
  <xsl:template name="glossary.titlepage.recto">
    <fo:block
      xsl:use-attribute-sets="glossary.titlepage.recto.style"
      font-size="{&super-large; * $sans-fontsize-adjust}pt" font-family="{$title.fontset}">
      <xsl:attribute name="margin-{$start-border}">
        <xsl:value-of select="$title.margin.left"/>
      </xsl:attribute>
      <xsl:call-template name="component.title">
        <xsl:with-param name="node" select="ancestor-or-self::d:glossary[1]"/>
      </xsl:call-template>
    </fo:block>
    <xsl:choose>
      <xsl:when test="d:glossaryinfo/d:subtitle">
        <xsl:apply-templates mode="glossary.titlepage.recto.auto.mode" select="d:glossaryinfo/d:subtitle"/>
      </xsl:when>
      <xsl:when test="d:docinfo/d:subtitle">
        <xsl:apply-templates mode="glossary.titlepage.recto.auto.mode" select="d:docinfo/d:subtitle"/>
      </xsl:when>
      <xsl:when test="d:info/d:subtitle">
        <xsl:apply-templates mode="glossary.titlepage.recto.auto.mode" select="d:info/d:subtitle"/>
      </xsl:when>
      <xsl:when test="d:subtitle">
        <xsl:apply-templates mode="glossary.titlepage.recto.auto.mode" select="d:subtitle"/>
      </xsl:when>
    </xsl:choose>

    <xsl:apply-templates mode="glossary.titlepage.recto.auto.mode" select="d:glossaryinfo/d:itermset"/>
    <xsl:apply-templates mode="glossary.titlepage.recto.auto.mode" select="d:docinfo/d:itermset"/>
    <xsl:apply-templates mode="glossary.titlepage.recto.auto.mode" select="d:info/d:itermset"/>
  </xsl:template>

  <xsl:template match="d:title" mode="glossdiv.titlepage.recto.auto.mode">
    <fo:block
      xsl:use-attribute-sets="glossdiv.titlepage.recto.style"
      font-size="{&xxx-large; * $sans-fontsize-adjust}pt" font-family="{$title.fontset}">
      <xsl:attribute name="margin-{$start-border}">
        <xsl:value-of select="$title.margin.left"/>
      </xsl:attribute>
      <xsl:call-template name="component.title">
        <xsl:with-param name="node" select="ancestor-or-self::d:glossdiv[1]"/>
      </xsl:call-template>
    </fo:block>
  </xsl:template>

</xsl:stylesheet>

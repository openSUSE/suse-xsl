<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Restyle titles of chapters, etc.

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

  <xsl:include href="article.titlepage.templates.xsl"/>
  <xsl:include href="appendix.titlepage.templates.xsl"/>
  <xsl:include href="bibliography.titlepage.templates.xsl"/>
  <xsl:include href="book.titlepage.templates.xsl"/>
  <xsl:include href="chapter.titlepage.templates.xsl"/>
  <xsl:include href="glossary.titlepage.templates.xsl"/>
  <xsl:include href="preface.titlepage.templates.xsl"/>


<!-- Set ==================================================== -->
<xsl:template match="d:title" mode="set.titlepage.recto.auto.mode">
  <fo:block xsl:use-attribute-sets="set.titlepage.recto.style"
    font-size="{&ultra-large; * $sans-fontsize-adjust}pt" space-before="&columnfragment;mm"
    font-family="{$title.fontset}">
    <xsl:call-template name="division.title">
      <xsl:with-param name="node" select="ancestor-or-self::d:set[1]"/>
    </xsl:call-template>
  </fo:block>
</xsl:template>


<!-- Part ======================================================== -->
<xsl:template match="d:title" mode="part.titlepage.recto.auto.mode">
  <fo:block
    xsl:use-attribute-sets="part.titlepage.recto.style sans.bold.noreplacement"
    font-size="{&super-large; * $sans-fontsize-adjust}pt" space-before="&columnfragment;mm"
    font-family="{$title.fontset}">
    <xsl:call-template name="division.title">
      <xsl:with-param name="node" select="ancestor-or-self::d:part[1]"/>
    </xsl:call-template>
  </fo:block>
</xsl:template>

<xsl:template match="d:subtitle" mode="part.titlepage.recto.auto.mode">
  <fo:block
    xsl:use-attribute-sets="part.titlepage.recto.style sans.bold.noreplacement"
    font-size="{&xxx-large; * $sans-fontsize-adjust}pt" font-style="normal"
    space-before="&gutter;mm" font-family="{$title.fontset}">
    <xsl:apply-templates select="." mode="part.titlepage.recto.mode"/>
  </fo:block>
</xsl:template>


<!--  TOC ==================================================== -->
<xsl:template name="table.of.contents.titlepage.recto">
    <fo:block
      xsl:use-attribute-sets="table.of.contents.titlepage.recto.style dark-green"
      space-before="{&columnfragment;}mm"
      font-weight="normal"
      font-family="{$title.fontset}">
      <xsl:choose>
        <xsl:when test="self::d:article">
          <xsl:attribute name="start-indent">
            <xsl:value-of select="concat(&columnfragment; + &gutter;, 'mm')"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="start-indent">
            <xsl:value-of select="concat(&column; + &gutter;, 'mm')"/>
          </xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="ancestor-or-self::d:article">
          <xsl:attribute name="space-after">&gutter;mm</xsl:attribute>
          <xsl:attribute name="font-size"><xsl:value-of select="&xxx-large; * $sans-fontsize-adjust"/>pt</xsl:attribute>
        </xsl:when>
        <xsl:when test="ancestor-or-self::d:book">
          <xsl:attribute name="space-after">&column;mm</xsl:attribute>
          <xsl:attribute name="font-size"><xsl:value-of select="&super-large; * $sans-fontsize-adjust"/>pt</xsl:attribute>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
      <xsl:call-template name="gentext">
        <xsl:with-param name="key" select="'TableofContents'"/>
      </xsl:call-template>
    </fo:block>
</xsl:template>


</xsl:stylesheet>

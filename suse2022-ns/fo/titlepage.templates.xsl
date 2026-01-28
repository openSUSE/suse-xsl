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
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:exsl="http://exslt.org/common"
  exclude-result-prefixes="exsl d">

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


  <xsl:template name="table.of.contents.titlepage">
    <!-- Keep the title text and the TOC together -->
    <fo:block keep-with-next.within-column="always">
      <xsl:variable name="recto.content">
        <xsl:call-template name="table.of.contents.titlepage.before.recto"/>
        <xsl:call-template name="table.of.contents.titlepage.recto"/>
      </xsl:variable>
      <xsl:variable name="recto.elements.count">
        <xsl:choose>
          <xsl:when test="function-available('exsl:node-set')"><xsl:value-of select="count(exsl:node-set($recto.content)/*)"/></xsl:when>
          <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:if test="(normalize-space($recto.content) != '') or ($recto.elements.count &gt; 0)">
        <fo:block><xsl:copy-of select="$recto.content"/></fo:block>
      </xsl:if>
      <xsl:variable name="verso.content">
        <xsl:call-template name="table.of.contents.titlepage.before.verso"/>
        <xsl:call-template name="table.of.contents.titlepage.verso"/>
      </xsl:variable>
      <xsl:variable name="verso.elements.count">
        <xsl:choose>
          <xsl:when test="function-available('exsl:node-set')"><xsl:value-of select="count(exsl:node-set($verso.content)/*)"/></xsl:when>
          <xsl:when test="contains(system-property('xsl:vendor'), 'Apache Software Foundation')">
            <!--Xalan quirk--><xsl:value-of select="count(exsl:node-set($verso.content)/*)"/></xsl:when>
          <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:if test="(normalize-space($verso.content) != '') or ($verso.elements.count &gt; 0)">
        <fo:block><xsl:copy-of select="$verso.content"/></fo:block>
      </xsl:if>
      <xsl:call-template name="table.of.contents.titlepage.separator"/>
    </fo:block>
  </xsl:template>
</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Restyle appendix titlepage

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


  <!--  Appendix ================================================== -->
  <xsl:template match="d:title" mode="appendix.titlepage.recto.auto.mode">
    <fo:block
      xsl:use-attribute-sets="appendix.titlepage.recto.style component.title.style"
      font-size="{&super-large; * $sans-fontsize-adjust}pt" font-family="{$title.fontset}">
      <xsl:attribute name="margin-{$start-border}">
        <xsl:value-of select="$title.margin.left"/>
      </xsl:attribute>
      <xsl:call-template name="component.title">
        <xsl:with-param name="node" select="ancestor-or-self::d:appendix[1]"/>
      </xsl:call-template>
    </fo:block>
  </xsl:template>

  <xsl:template match="d:subtitle" mode="appendix.titlepage.recto.auto.mode">
    <fo:block
      xsl:use-attribute-sets="appendix.titlepage.recto.style"
      font-family="{$title.fontset}" font-size="{&small; * $sans-fontsize-adjust}pt">
      <xsl:apply-templates select="." mode="appendix.titlepage.recto.mode"/>
    </fo:block>
  </xsl:template>

  <xsl:template match="d:corpauthor" mode="appendix.titlepage.recto.auto.mode">
    <fo:block
      xsl:use-attribute-sets="appendix.titlepage.recto.style"
      font-family="{$title.fontset}" font-size="{&small; * $sans-fontsize-adjust}pt">
      <xsl:apply-templates select="." mode="appendix.titlepage.recto.mode"/>
    </fo:block>
  </xsl:template>

  <xsl:template match="d:authorgroup" mode="appendix.titlepage.recto.auto.mode">
    <fo:block
      xsl:use-attribute-sets="appendix.titlepage.recto.style"
      font-family="{$title.fontset}" font-size="{&small; * $sans-fontsize-adjust}pt">
      <xsl:apply-templates select="." mode="appendix.titlepage.recto.mode"/>
    </fo:block>
  </xsl:template>

  <xsl:template match="d:author" mode="appendix.titlepage.recto.auto.mode">
    <fo:block
      xsl:use-attribute-sets="appendix.titlepage.recto.style"
      font-family="{$title.fontset}" font-size="{&small; * $sans-fontsize-adjust}pt">
      <xsl:apply-templates select="." mode="appendix.titlepage.recto.mode"/>
    </fo:block>
  </xsl:template>

  <xsl:template match="d:othercredit" mode="appendix.titlepage.recto.auto.mode">
    <fo:block
      xsl:use-attribute-sets="appendix.titlepage.recto.style"
      font-family="{$title.fontset}" font-size="{&small; * $sans-fontsize-adjust}pt">
      <xsl:apply-templates select="." mode="appendix.titlepage.recto.mode"/>
    </fo:block>
  </xsl:template>

</xsl:stylesheet>

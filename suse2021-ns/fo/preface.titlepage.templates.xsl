<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Restyle preface titlepage

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

  <!-- Preface ==================================================== -->
  <xsl:template name="preface.titlepage.recto">
    <fo:block
      xsl:use-attribute-sets="preface.titlepage.recto.style component.title.style"
      font-size="{&super-large; * $sans-fontsize-adjust}pt" font-family="{$title.fontset}">
      <xsl:attribute name="margin-{$start-border}">
        <xsl:value-of select="$title.margin.left"/>
      </xsl:attribute>
      <xsl:call-template name="component.title">
        <xsl:with-param name="node" select="ancestor-or-self::d:preface[1]"/>
      </xsl:call-template>
    </fo:block>
    <xsl:choose>
      <xsl:when test="d:prefaceinfo/d:subtitle">
        <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:prefaceinfo/d:subtitle"/>
      </xsl:when>
      <xsl:when test="d:docinfo/d:subtitle">
        <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:docinfo/d:subtitle"/>
      </xsl:when>
      <xsl:when test="d:info/d:subtitle">
        <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:info/d:subtitle"/>
      </xsl:when>
      <xsl:when test="d:subtitle">
        <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:subtitle"/>
      </xsl:when>
    </xsl:choose>

    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:prefaceinfo/d:corpauthor"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:docinfo/d:corpauthor"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:info/d:corpauthor"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:prefaceinfo/d:authorgroup"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:docinfo/d:authorgroup"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:info/d:authorgroup"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:prefaceinfo/d:author"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:docinfo/d:author"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:info/d:author"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:prefaceinfo/d:othercredit"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:docinfo/d:othercredit"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:info/d:othercredit"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:prefaceinfo/d:releaseinfo"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:docinfo/d:releaseinfo"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:info/d:releaseinfo"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:prefaceinfo/d:copyright"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:docinfo/d:copyright"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:info/d:copyright"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:prefaceinfo/d:legalnotice"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:docinfo/d:legalnotice"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:info/d:legalnotice"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:prefaceinfo/d:pubdate"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:docinfo/d:pubdate"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:info/d:pubdate"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:prefaceinfo/d:revision"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:docinfo/d:revision"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:info/d:revision"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:prefaceinfo/d:revhistory"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:docinfo/d:revhistory"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:info/d:revhistory"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:prefaceinfo/d:abstract"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:docinfo/d:abstract"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:info/d:abstract"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:prefaceinfo/d:itermset"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:docinfo/d:itermset"/>
    <xsl:apply-templates mode="preface.titlepage.recto.auto.mode" select="d:info/d:itermset"/>
  </xsl:template>
</xsl:stylesheet>

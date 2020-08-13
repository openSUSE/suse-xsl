<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Restyle article titlepage

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

  <!-- Article ==================================================== -->
  <xsl:template name="article.titlepage.recto">
    <xsl:variable name="height">
      <xsl:call-template name="get.value.from.unit">
        <xsl:with-param name="string" select="$page.height"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="unit">
      <xsl:call-template name="get.unit.from.unit">
        <xsl:with-param name="string" select="$page.height"/>
      </xsl:call-template>
    </xsl:variable>

    <fo:block space-after="&gutter;mm" text-align="start">
      <xsl:choose>
        <!-- Don't let Geeko overhang the right side of the page - it
             is not mirrored, thus some letters would hang over the side
             of hte page, instead of the tail. -->
        <!-- FIXME: This is not the optimal implementation if we ever
             want to be able to switch out images easily. -->
        <xsl:when test="$writing.mode ='rl'">
          <xsl:attribute name="margin-right">
            <xsl:value-of select="&columnfragment; + &gutter;"/>mm
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="margin-left">
            <xsl:value-of select="&columnfragment; + &gutter; - $titlepage.logo.overhang"/>mm
          </xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <fo:instream-foreign-object content-width="{$titlepage.logo.width}"
        width="{$titlepage.logo.width}">
        <xsl:call-template name="logo-image"/>
      </fo:instream-foreign-object>
    </fo:block>

    <fo:block start-indent="{&columnfragment; + &gutter;}mm" text-align="start"
      role="article.titlepage.recto">
      <fo:block space-after="{&gutterfragment;}mm">
        <xsl:choose>
          <xsl:when test="d:articleinfo/d:title">
            <xsl:apply-templates
              mode="article.titlepage.recto.auto.mode"
              select="d:articleinfo/d:title"/>
          </xsl:when>
          <xsl:when test="d:artheader/d:title">
            <xsl:apply-templates
              mode="article.titlepage.recto.auto.mode"
              select="d:artheader/d:title"/>
          </xsl:when>
          <xsl:when test="d:info/d:title">
            <xsl:apply-templates
              mode="article.titlepage.recto.auto.mode"
              select="d:info/d:title"/>
          </xsl:when>
          <xsl:when test="d:title">
            <xsl:apply-templates
              mode="article.titlepage.recto.auto.mode" select="d:title"/>
          </xsl:when>
        </xsl:choose>
      </fo:block>

    <fo:block padding-before="{2 * &gutterfragment;}mm"
      padding-start="{&column; + &columnfragment; + &gutter;}mm">
      <xsl:attribute name="border-top"><xsl:value-of select="concat(&mediumline;,'mm solid ',$dark-green)"/></xsl:attribute>

      <xsl:choose>
        <xsl:when test="d:articleinfo/d:subtitle">
          <xsl:apply-templates
            mode="article.titlepage.recto.auto.mode"
            select="d:articleinfo/d:subtitle"/>
        </xsl:when>
        <xsl:when test="d:artheader/d:subtitle">
          <xsl:apply-templates
            mode="article.titlepage.recto.auto.mode"
            select="d:artheader/d:subtitle"/>
        </xsl:when>
        <xsl:when test="d:info/d:subtitle">
          <xsl:apply-templates
            mode="article.titlepage.recto.auto.mode"
            select="d:info/d:subtitle"/>
        </xsl:when>
        <xsl:when test="d:subtitle">
          <xsl:apply-templates
            mode="article.titlepage.recto.auto.mode"
            select="d:subtitle"/>
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode"
            select="d:articleinfo/d:productname[not(@role='abbrev')]"/>
    </fo:block>

    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:articleinfo/d:corpauthor"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:corpauthor"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:articleinfo/d:authorgroup"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:authorgroup"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:articleinfo/d:author"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:author"/>

    <xsl:choose>
      <xsl:when test="d:articleinfo/d:abstract or d:info/d:abstract">
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:articleinfo/d:abstract"/>
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:abstract"/>
      </xsl:when>
      <xsl:when test="d:abstract">
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:abstract"/>
      </xsl:when>
    </xsl:choose>

    <fo:block>
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode"  select="d:articleinfo/d:othercredit"/>
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode"  select="d:info/d:othercredit"/>
    </fo:block>

    <fo:block>
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:articleinfo/d:editor"/>
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:editor"/>
    </fo:block>

    <fo:block>
      <xsl:call-template name="date.and.revision"/>
    </fo:block>

    <fo:block>
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:articleinfo/d:mediaobject"/>
    </fo:block>
    </fo:block>
  </xsl:template>


  <xsl:template match="d:articleinfo/d:mediaobject" mode="article.titlepage.recto.auto.mode">
    <fo:block break-after="page">
      <xsl:call-template name="select.mediaobject"/>
    </fo:block>
  </xsl:template>

  <xsl:template match="d:title" mode="article.titlepage.recto.auto.mode">
    <fo:block font-size="{&super-large; * $sans-fontsize-adjust}pt" line-height="{$base-lineheight * 0.85}em"
      xsl:use-attribute-sets="article.titlepage.recto.style dark-green"
      keep-with-next.within-column="always" space-after="{&gutterfragment;}mm">
      <xsl:apply-templates select="." mode="article.titlepage.recto.mode"/>
    </fo:block>
  </xsl:template>

  <xsl:template match="d:subtitle" mode="article.titlepage.recto.auto.mode">
    <fo:block font-size="{&xx-large; * $sans-fontsize-adjust}pt" line-height="{$base-lineheight * 0.75}em"
      xsl:use-attribute-sets="article.titlepage.recto.style mid-green"
      keep-with-next.within-column="always" space-after="{&gutterfragment;}mm">
      <xsl:apply-templates select="." mode="article.titlepage.recto.mode"/>
    </fo:block>
  </xsl:template>

  <xsl:template match="d:productname[1]" mode="article.titlepage.recto.auto.mode">
    <fo:block text-align="start" font-size="{&xx-large; * $sans-fontsize-adjust}pt"
      xsl:use-attribute-sets="mid-green">
      <xsl:apply-templates select="." mode="article.titlepage.recto.mode"/>
      <xsl:if test="../d:productnumber">
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="../d:productnumber[1]" mode="article.titlepage.recto.mode"/>
      </xsl:if>
    </fo:block>
  </xsl:template>

  <xsl:template match="d:authorgroup" mode="article.titlepage.recto.auto.mode">
    <fo:block font-size="{&large; * $sans-fontsize-adjust}pt" space-before="1em" text-align="start">
      <xsl:call-template name="person.name.list">
        <xsl:with-param name="person.list" select="d:author|d:corpauthor"/>
      </xsl:call-template>
    </fo:block>
  </xsl:template>

  <xsl:template match="d:author|d:corpauthor"
    mode="article.titlepage.recto.auto.mode">
    <fo:block space-before="1em" font-size="{&large; * $sans-fontsize-adjust}pt" text-align="start">
      <xsl:apply-templates select="." mode="article.titlepage.recto.mode"/>
    </fo:block>
  </xsl:template>

  <xsl:template match="d:editor|d:othercredit"
    mode="article.titlepage.recto.auto.mode">
    <xsl:if test=". = ((../d:othercredit)|(../d:editor))[1]">
      <fo:block font-size="{&normal; * $sans-fontsize-adjust}pt">
        <xsl:call-template name="gentext">
          <xsl:with-param name="key">
            <xsl:choose>
              <xsl:when test="count((../d:othercredit)|(../d:editor)) > 1"
                >Contributors</xsl:when>
              <xsl:otherwise>Contributor</xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:text>: </xsl:text>
        <xsl:call-template name="person.name.list">
          <xsl:with-param name="person.list"
            select="(../d:othercredit)|(../d:editor)"/>
        </xsl:call-template>
      </fo:block>
    </xsl:if>
  </xsl:template>

  <xsl:template match="d:abstract" mode="article.titlepage.recto.auto.mode">
    <fo:block space-after="1.5em">
      <xsl:apply-templates select="." mode="article.titlepage.recto.mode"/>
    </fo:block>
  </xsl:template>

  <xsl:template match="d:article/d:abstract"/>

</xsl:stylesheet>

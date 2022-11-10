<?xml version="1.0" encoding="UTF-8"?>
<!--

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
  xmlns:fo="http://www.w3.org/1999/XSL/Format">

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
        <xsl:when test="$writing.mode ='rl'">
          <xsl:attribute name="margin-right">
            <xsl:value-of select="&columnfragment; + &gutter;"/>mm
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="margin-left">
            <xsl:value-of select="&columnfragment; + &gutter;"/>mm
          </xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <fo:instream-foreign-object content-width="{$titlepage.logo.width.article}"
        width="{$titlepage.logo.width}">
        <xsl:call-template name="logo-image"/>
      </fo:instream-foreign-object>
    </fo:block>

    <fo:block start-indent="{&columnfragment; + &gutter;}mm" text-align="start"
      role="article.titlepage.recto">
      <fo:block space-after="{&gutterfragment;}mm">
        <xsl:apply-templates mode="article.titlepage.recto.auto.mode"
              select="*[concat(local-name(.), 'info')]/d:productname[not(@role='abbrev')]"/>
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
    </fo:block>

    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:articleinfo/d:corpauthor"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:corpauthor"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:articleinfo/d:authorgroup"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:authorgroup"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:articleinfo/d:author"/>
    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:author"/>

    <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:cover"/>

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

</xsl:stylesheet>
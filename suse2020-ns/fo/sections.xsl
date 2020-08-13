<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Restyle titles of chapters, etc.

  Author(s):  Stefan Knorr <sknorr@suse.de>,
              Thomas Schraitle <toms@opensuse.org>

  Copyright:  2013, 2014, Stefan Knorr, Thomas Schraitle

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

<xsl:template match="d:section/d:title
                     |d:simplesect/d:title
                     |d:sect1/d:title
                     |d:sect2/d:title
                     |d:sect3/d:title
                     |d:sect4/d:title
                     |d:sect5/d:title
                     |d:section/d:info/d:title
                     |d:simplesect/d:info/d:title
                     |d:sect1/d:info/d:title
                     |d:sect2/d:info/d:title
                     |d:sect3/d:info/d:title
                     |d:sect4/d:info/d:title
                     |d:sect5/d:info/d:title
                     |d:section/d:sectioninfo/d:title
                     |d:sect1/d:sect1info/d:title
                     |d:sect2/d:sect2info/d:title
                     |d:sect3/d:sect3info/d:title
                     |d:sect4/d:sect4info/d:title
                     |d:sect5/d:sect5info/d:title"
              mode="titlepage.mode"
              priority="2">

  <xsl:variable name="section"
                select="(ancestor::d:section |
                        ancestor::d:simplesect |
                        ancestor::d:sect1 |
                        ancestor::d:sect2 |
                        ancestor::d:sect3 |
                        ancestor::d:sect4 |
                        ancestor::d:sect5)[position() = last()]"/>

  <fo:block keep-with-next.within-column="always">
    <xsl:variable name="id">
      <xsl:call-template name="object.id">
        <xsl:with-param name="object" select="$section"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="renderas">
      <xsl:choose>
        <xsl:when test="$section/@renderas = 'sect1'">1</xsl:when>
        <xsl:when test="$section/@renderas = 'sect2'">2</xsl:when>
        <xsl:when test="$section/@renderas = 'sect3'">3</xsl:when>
        <xsl:when test="$section/@renderas = 'sect4'">4</xsl:when>
        <xsl:when test="$section/@renderas = 'sect5'">5</xsl:when>
        <xsl:otherwise><xsl:value-of select="''"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="level-candidate">
      <xsl:choose>
        <xsl:when test="$renderas != ''">
          <xsl:value-of select="$renderas"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="section.level">
            <xsl:with-param name="node" select="$section"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="level">
      <xsl:choose>
        <xsl:when test="ancestor::d:article and ancestor::d:appendix">
          <xsl:value-of select="$level-candidate + 1"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$level-candidate"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="marker">
      <xsl:choose>
        <xsl:when test="$level &lt;= $marker.section.level">1</xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="marker.title">
      <xsl:apply-templates select="$section" mode="titleabbrev.markup">
        <xsl:with-param name="allow-anchors" select="0"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:call-template name="section.heading">
      <xsl:with-param name="level" select="$level"/>
      <xsl:with-param name="marker" select="$marker"/>
      <xsl:with-param name="marker.title" select="$marker.title"/>
      <xsl:with-param name="section" select="$section"/>
    </xsl:call-template>
  </fo:block>
</xsl:template>

<xsl:template name="section.heading">
  <xsl:param name="section" select="."/>
  <xsl:param name="level" select="1"/>
  <xsl:param name="marker" select="1"/>
  <xsl:param name="marker.title"/>

  <fo:block xsl:use-attribute-sets="section.title.properties" hyphenate="false">
    <xsl:if test="$marker != 0">
      <fo:marker marker-class-name="section.head.marker.short">
        <xsl:call-template name="shorten-section-markers">
          <xsl:with-param name="title" select="$marker.title"/>
        </xsl:call-template>
      </fo:marker>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="$level=1">
        <fo:block xsl:use-attribute-sets="section.title.level1.properties">
          <xsl:call-template name="title.split">
            <xsl:with-param name="node" select="$section"/>
          </xsl:call-template>
        </fo:block>
      </xsl:when>
      <xsl:when test="$level=2">
        <fo:block xsl:use-attribute-sets="section.title.level2.properties">
          <xsl:call-template name="title.split">
            <xsl:with-param name="node" select="$section"/>
          </xsl:call-template>
        </fo:block>
      </xsl:when>
      <xsl:when test="$level=3">
        <fo:block xsl:use-attribute-sets="section.title.level3.properties">
          <xsl:call-template name="title.split">
            <xsl:with-param name="node" select="$section"/>
          </xsl:call-template>
        </fo:block>
      </xsl:when>
      <xsl:when test="$level=4">
        <fo:block xsl:use-attribute-sets="section.title.level4.properties">
          <xsl:call-template name="title.split">
            <xsl:with-param name="node" select="$section"/>
          </xsl:call-template>
        </fo:block>
      </xsl:when>
      <xsl:when test="$level=5">
        <fo:block xsl:use-attribute-sets="section.title.level5.properties">
          <xsl:call-template name="title.split">
            <xsl:with-param name="node" select="$section"/>
          </xsl:call-template>
        </fo:block>
      </xsl:when>
      <xsl:otherwise>
        <fo:block xsl:use-attribute-sets="section.title.level6.properties">
          <xsl:call-template name="title.split">
            <xsl:with-param name="node" select="$section"/>
          </xsl:call-template>
        </fo:block>
      </xsl:otherwise>
    </xsl:choose>
  </fo:block>
</xsl:template>

<!-- ======================================================================= -->

<xsl:template match="d:sect1[@role='legal']">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <fo:block id="{$id}"
            xsl:use-attribute-sets="section.level1.properties">
    <fo:block font-size="{&small; * $sans-fontsize-adjust}pt" space-before="1.12em" space-after="0.75em"
       keep-with-next="always" xsl:use-attribute-sets="sans.bold">
      <xsl:value-of select="d:title" />
    </fo:block>
    <fo:block font-size="{&xxx-small; * $sans-fontsize-adjust}pt">
      <xsl:apply-templates/>
    </fo:block>
  </fo:block>
</xsl:template>

<xsl:template match="d:bridgehead[parent::d:sect1[@role='legal']]">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <fo:block id="{$id}"
            xsl:use-attribute-sets="section.level2.properties">
    <fo:block font-size="{&x-small; * $sans-fontsize-adjust}pt"
      keep-with-next="always"
      space-before="1.12em" space-after="0.5em"
      space-after.precedence="2">
      <xsl:apply-templates/>
    </fo:block>
  </fo:block>
</xsl:template>

<xsl:template match="d:sect2[parent::d:sect1[@role='legal']]">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <fo:block id="{$id}"
            xsl:use-attribute-sets="section.level2.properties">
    <fo:block font-size="{&x-small; * $sans-fontsize-adjust}pt"
      keep-with-next="always"
      space-before="1.12em" space-after="0.5em"
      space-after.precedence="2">
      <xsl:value-of select="d:title"/>
    </fo:block>
    <fo:block font-size="{&xxx-small; * $sans-fontsize-adjust}pt">
      <xsl:apply-templates/>
    </fo:block>
  </fo:block>
</xsl:template>

<xsl:template match="d:sect3[ancestor::d:sect1[@role='legal']]">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <fo:block id="{$id}" xsl:use-attribute-sets="section.level3.properties">
    <fo:block font-size="{&x-small; * $sans-fontsize-adjust}pt" space-before="1.12em" space-after="0.5em"
      xsl:use-attribute-sets="italicized.noreplacement">
      <xsl:value-of select="d:title"/>
    </fo:block>
    <fo:block font-size="{&xxx-small; * $sans-fontsize-adjust}pt">
      <xsl:apply-templates/>
    </fo:block>
  </fo:block>
</xsl:template>

<xsl:template match="d:sect4[ancestor::d:sect1[@role='legal']]">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <fo:block id="{$id}"
            xsl:use-attribute-sets="section.level4.properties">
    <fo:block font-size="{&x-small; * $sans-fontsize-adjust}pt" font-weight="normal">
      <xsl:value-of select="d:title"/>
    </fo:block>
    <fo:block font-size="{&xxx-small; * $sans-fontsize-adjust}pt">
      <xsl:apply-templates/>
    </fo:block>
  </fo:block>
</xsl:template>

<xsl:template match="d:screen[ancestor::d:sect1[@role='legal']]">
  <fo:block xsl:use-attribute-sets="monospace.verbatim.properties shade.verbatim.style"
            font-size="{(&xxx-small; * $sans-fontsize-adjust) - 1.1}pt"
            white-space-collapse='false'
            white-space-treatment='preserve'
            linefeed-treatment='preserve'>
            <!-- I hope no one is going to beat me up over this font size – but
                 the screens in the GPL really do look better this way, as we
                 can now fit 75 characters on a line even on two-column pages.
                 -->
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

</xsl:stylesheet>

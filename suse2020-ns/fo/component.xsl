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
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:exsl="http://exslt.org/common"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  exclude-result-prefixes="exsl d">

<xsl:template name="component.title">
  <xsl:param name="node" select="."/>
  <xsl:param name="pagewide" select="0"/>

  <xsl:variable name="id">
    <xsl:call-template name="object.id">
      <xsl:with-param name="object" select="$node"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="level">
    <xsl:choose>
      <xsl:when test="ancestor::d:section">
        <xsl:value-of select="count(ancestor::d:section)+1"/>
      </xsl:when>
      <xsl:when test="ancestor::d:sect5">6</xsl:when>
      <xsl:when test="ancestor::d:sect4">5</xsl:when>
      <xsl:when test="ancestor::d:sect3">4</xsl:when>
      <xsl:when test="ancestor::d:sect2">3</xsl:when>
      <xsl:when test="ancestor::d:sect1">2</xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="title">
    <xsl:apply-templates select="$node" mode="title.markup"/>
  </xsl:variable>

  <xsl:variable name="titleabbrev">
    <xsl:apply-templates select="$node" mode="titleabbrev.markup"/>
  </xsl:variable>

  <fo:block xsl:use-attribute-sets="section.title.properties">
    <xsl:if test="$pagewide != 0">
      <!-- Doesn't work to use 'all' here since not a child of fo:flow -->
      <xsl:attribute name="span">inherit</xsl:attribute>
    </xsl:if>
    <xsl:attribute name="hyphenation-character">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key" select="'hyphenation-character'"/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:attribute name="hyphenation-push-character-count">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key" select="'hyphenation-push-character-count'"/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:attribute name="hyphenation-remain-character-count">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key" select="'hyphenation-remain-character-count'"/>
      </xsl:call-template>
    </xsl:attribute>

    <xsl:choose>
      <xsl:when test="$level=2">
        <fo:block xsl:use-attribute-sets="section.title.level2.properties">
          <xsl:call-template name="title.split">
            <xsl:with-param name="node" select="$node"/>
          </xsl:call-template>
        </fo:block>
      </xsl:when>
      <xsl:when test="$level=3">
        <fo:block xsl:use-attribute-sets="section.title.level3.properties">
          <xsl:call-template name="title.split">
            <xsl:with-param name="node" select="$node"/>
          </xsl:call-template>
        </fo:block>
      </xsl:when>
      <xsl:when test="$level=4">
        <fo:block xsl:use-attribute-sets="section.title.level4.properties">
          <xsl:call-template name="title.split">
            <xsl:with-param name="node" select="$node"/>
          </xsl:call-template>
        </fo:block>
      </xsl:when>
      <xsl:when test="$level=5">
        <fo:block xsl:use-attribute-sets="section.title.level5.properties">
          <xsl:call-template name="title.split">
            <xsl:with-param name="node" select="$node"/>
          </xsl:call-template>
        </fo:block>
      </xsl:when>
      <xsl:when test="$level=6">
        <fo:block xsl:use-attribute-sets="section.title.level6.properties">
          <xsl:call-template name="title.split">
            <xsl:with-param name="node" select="$node"/>
          </xsl:call-template>
        </fo:block>
      </xsl:when>
      <xsl:otherwise>
        <fo:block xsl:use-attribute-sets="section.title.level1.properties">
          <xsl:call-template name="title.split">
            <xsl:with-param name="node" select="$node"/>
          </xsl:call-template>
        </fo:block>
      </xsl:otherwise>
    </xsl:choose>
  </fo:block>
</xsl:template>


<xsl:template name="title.split">
  <xsl:param name="node" select="."/>

  <xsl:variable name="title">
    <xsl:apply-templates select="$node" mode="title.markup"/>
  </xsl:variable>

  <xsl:variable name="number">
    <xsl:apply-templates select="$node" mode="label.markup"/>
  </xsl:variable>

  <xsl:if test="$number != ''">
    <fo:inline xsl:use-attribute-sets="title.number.color">
      <xsl:copy-of select="$number"/>
      <fo:leader leader-pattern="space" leader-length="&gutter;mm"/>
    </fo:inline>
  </xsl:if>
  <fo:inline xsl:use-attribute-sets="title.name.color">
    <xsl:copy-of select="$title"/>
  </fo:inline>
</xsl:template>

<!-- FIXME: priority attribute is necessary to overwrite the template
     below, so we get the correct headline style. Ideally, however,
     we would use the template below, though, and still get nice-looking
     headlines. -->
<xsl:template match="d:article/d:appendix|d:article/d:appendix[@role='legal']"
  priority="1">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:variable name="title">
    <xsl:apply-templates select="." mode="object.title.markup"/>
  </xsl:variable>

  <xsl:variable name="titleabbrev">
    <xsl:apply-templates select="." mode="titleabbrev.markup"/>
  </xsl:variable>

  <fo:block id='{$id}'>
    <fo:block>
      <fo:marker marker-class-name="section.head.marker">
        <xsl:choose>
          <xsl:when test="$titleabbrev = ''">
            <xsl:value-of select="$title"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$titleabbrev"/>
          </xsl:otherwise>
        </xsl:choose>
      </fo:marker>

      <fo:marker marker-class-name="section.head.marker.short">
        <xsl:choose>
          <xsl:when test="$titleabbrev = ''">
            <xsl:call-template name="shorten-section-markers">
              <xsl:with-param name="title" select="$title"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="shorten-section-markers">
              <xsl:with-param name="title" select="$titleabbrev"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </fo:marker>

      <xsl:call-template name="component.title"/>
    </fo:block>

    <xsl:call-template name="make.component.tocs"/>

    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<xsl:template name="shorten-section-markers">
  <xsl:param name="title" select="''"/>
  <xsl:param name="cutoff" select="substring-before(58 * $sans-cutoff-factor, '.')"/>
    <!-- FIXME: substring-before gets rid of the decimal places (if any).
         Now, there wouldn't be a function toint() or so that could
         do this for us in a better way, right? -->

  <xsl:variable name="realtitle" select="normalize-space($title)"/>

  <xsl:choose>
    <xsl:when test="string-length($realtitle) &gt; $cutoff">
      <xsl:value-of select="substring($realtitle, 1, $cutoff - 3)"/>…
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$title"/>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:if test="$realtitle=''">
    <xsl:message>Did not receive a title to create a section marker with.</xsl:message>
  </xsl:if>
</xsl:template>



<!-- Below, there are three templates (#1, #2, #3) that roughly do the following:
        #1.1  match appendices that have a role='legal' attribute
        #1.2  apply all upstream templates on it, then converted the tree fragment
              we just created to a node-set
        #1.3, 2
              let said node-set run through a template that copies everything
        #3    except for the part we want to wrap in a fo:block with the span
              attribute set.-->

<xsl:template match="d:appendix[@role='legal']">
  <xsl:variable name="rtf">
    <xsl:apply-imports/>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="function-available('exsl:node-set')">
      <xsl:variable name="converted-fragment" select="exsl:node-set($rtf)/*"/>
      <xsl:apply-templates select="$converted-fragment" mode="span-in-block"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$rtf"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template match="node() | @*" mode="span-in-block">
  <xsl:copy>
    <xsl:apply-templates select="@* | node()" mode="span-in-block"/>
  </xsl:copy>
</xsl:template>


<xsl:template match="fo:flow/fo:block[1]" mode="span-in-block">
  <!-- This template lets us add another block element around the appendix
       template, so we can set the span="all" attribute at the appropriate
       level. -->

    <fo:block span="all">
      <xsl:apply-templates select="@* | node()" mode="span-in-block"/>
    </fo:block>
</xsl:template>

</xsl:stylesheet>

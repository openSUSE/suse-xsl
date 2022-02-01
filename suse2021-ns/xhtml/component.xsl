<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
     Split chapter titles into number and title

   Author(s):    Thomas Schraitle <toms@opensuse.org>
                 Stefan Knorr <sknorr@suse.de>
   Copyright: 2012, 2013, Thomas Schraitle, Stefan Knorr

-->
<xsl:stylesheet  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:exsl="http://exslt.org/common"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="exsl d">


  <xsl:template name="component.title">
   <xsl:param name="node" select="."/>
   <xsl:param name="wrapper"/>

  <!-- This handles the case where a component (bibliography, for example)
       occurs inside a section; will we need parameters for this? -->

  <!-- This "level" is a section level. To compute <h> level, add 1. -->
  <xsl:variable name="level">
    <xsl:choose>
      <!-- If we do single-page HTML, give the <h1> to the book page -->
      <!-- Chunked HTML is different, as we need an <h1> on every page for SEO 
      FIXME suse22 not yet implemented -->
      <xsl:when test="$node/parent::d:book">0</xsl:when>
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
  <xsl:variable name="wrapperplus">
    <xsl:choose>
      <xsl:when test="$wrapper = ''">
        <xsl:value-of select="concat('h', $level+1)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$wrapper"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:element name="{$wrapperplus}">
    <xsl:attribute name="class">title</xsl:attribute>
    <xsl:call-template name="create.header.title">
      <xsl:with-param name="node" select="$node"/>
      <xsl:with-param name="level" select="$level"/>
    </xsl:call-template>
  </xsl:element>
  <!-- FIXME suse22 reenable! -->
  <!-- for SEO, keep the permalink, report bug, and edit links out of the title -->
  <!-- <div class="title-extras">
  <xsl:call-template name="create.permalink">
    <xsl:with-param name="object" select="$node"/>
  </xsl:call-template>
  <xsl:call-template name="editlink"/>
  </div>-->
  <xsl:call-template name="debug.filename-id"/>
</xsl:template>


  <xsl:template match="d:article">
    <xsl:call-template name="id.warning"/>

    <xsl:element name="{$div.element}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:call-template name="common.html.attributes">
        <xsl:with-param name="inherit" select="1"/>
      </xsl:call-template>
      <xsl:call-template name="id.attribute">
        <xsl:with-param name="conditional" select="0"/>
        <xsl:with-param name="force" select="1"/>
      </xsl:call-template>

      <xsl:call-template name="article.titlepage"/>

      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:articleinfo/d:legalnotice"/>
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:artheader/d:legalnotice"/>
      <xsl:apply-templates mode="article.titlepage.recto.auto.mode" select="d:info/d:legalnotice"/>

      <xsl:apply-templates/>
      <xsl:call-template name="process.footnotes"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="d:chapter|d:preface|d:appendix" name="chapter-preface-appendix">
    <!-- Need to be able to call this template via name, too, so we can avoid
         applying imported templates in sections.xsl/template that
         matches "sect1[@role='legal']|…". -->
    <xsl:call-template name="id.warning"/>

    <xsl:element name="{$div.element}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:call-template name="common.html.attributes">
        <xsl:with-param name="inherit" select="1"/>
      </xsl:call-template>
      <xsl:call-template name="id.attribute">
        <xsl:with-param name="force" select="1"/>
      </xsl:call-template>

      <xsl:call-template name="component.separator"/>
      <xsl:choose>
        <xsl:when test="self::d:appendix">
          <xsl:call-template name="appendix.titlepage"/>
        </xsl:when>
        <xsl:when test="self::d:chapter">
          <xsl:call-template name="chapter.titlepage"/>
        </xsl:when>
        <xsl:when test="self::d:preface">
          <xsl:call-template name="preface.titlepage"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="log.message">
             <xsl:with-param name="level" select="'error'"/>
             <xsl:with-param name="context-desc" select="'title page'"/>
             <xsl:with-param name="message">
               <xsl:text>Don't know how to create "titlepage" for </xsl:text>
               <xsl:value-of select="local-name()"/>
               <xsl:text> element.</xsl:text>
             </xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:apply-templates/>
      <xsl:call-template name="process.footnotes"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="d:chapter/d:title|d:chapter/d:chapterinfo/d:title|d:chapter/d:info/d:title" mode="titlepage.mode" priority="2">
    <xsl:call-template name="component.title">
      <xsl:with-param name="node" select="ancestor::d:chapter[1]"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="d:chapter/d:subtitle|d:chapter/d:chapterinfo/d:subtitle|d:chapter/d:info/d:subtitle|d:chapter/d:docinfo/d:subtitle" mode="titlepage.mode" priority="2">
    <xsl:call-template name="component.subtitle">
      <xsl:with-param name="node" select="ancestor::d:chapter[1]"/>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>

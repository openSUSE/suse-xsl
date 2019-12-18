<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
     Create bubble help table of content structures

   Author:    Thomas Schraitle <toms@opensuse.org>
   Copyright: 2012, Thomas Schraitle

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:exsl="http://exslt.org/common"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="exsl d">

  <xsl:template name="bubble-toc">
    <xsl:call-template name="bubble-toc.inner">
      <xsl:with-param name="node" select="((ancestor-or-self::d:set |
        ancestor-or-self::d:book | ancestor-or-self::d:article)|key('id', $rootid))[last()]"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="bubble-toc.inner">
  <xsl:param name="node"/>
    <ol>
      <xsl:apply-templates select="$node" mode="bubble-toc"/>
    </ol>
  </xsl:template>

  <xsl:template name="bubble-subtoc">
    <xsl:param name="toc-context" select="."/>
    <xsl:param name="nodes" select="NOT-AN-ELEMENT"/>

    <xsl:variable name="depth">
      <xsl:choose>
        <xsl:when test="local-name(.) = 'section'">
          <xsl:value-of select="count(ancestor::d:section) + 1"/>
        </xsl:when>
        <xsl:when test="local-name(.) = 'sect1'">1</xsl:when>
        <xsl:when test="local-name(.) = 'sect2'">2</xsl:when>
        <xsl:when test="local-name(.) = 'sect3'">3</xsl:when>
        <xsl:when test="local-name(.) = 'sect4'">4</xsl:when>
        <xsl:when test="local-name(.) = 'sect5'">5</xsl:when>
        <xsl:when test="local-name(.) = 'refsect1'">1</xsl:when>
        <xsl:when test="local-name(.) = 'refsect2'">2</xsl:when>
        <xsl:when test="local-name(.) = 'refsect3'">3</xsl:when>
        <xsl:when test="local-name(.) = 'topic'">1</xsl:when>
        <xsl:when test="local-name(.) = 'simplesect'">
          <!-- sigh... -->
          <xsl:choose>
            <xsl:when test="local-name(..) = 'section'">
              <xsl:value-of select="count(ancestor::d:section)"/>
            </xsl:when>
            <xsl:when test="local-name(..) = 'sect1'">2</xsl:when>
            <xsl:when test="local-name(..) = 'sect2'">3</xsl:when>
            <xsl:when test="local-name(..) = 'sect3'">4</xsl:when>
            <xsl:when test="local-name(..) = 'sect4'">5</xsl:when>
            <xsl:when test="local-name(..) = 'sect5'">6</xsl:when>
            <xsl:when test="local-name(..) = 'topic'">2</xsl:when>
            <xsl:when test="local-name(..) = 'refsect1'">2</xsl:when>
            <xsl:when test="local-name(..) = 'refsect2'">3</xsl:when>
            <xsl:when test="local-name(..) = 'refsect3'">4</xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="depth.from.context" select="count(ancestor::*)-count($toc-context/ancestor::*)"/>
    <xsl:choose>
      <xsl:when test="$depth.from.context = 0">
        <xsl:apply-templates mode="bubble-toc" select="$nodes">
          <xsl:with-param name="toc-context" select="$toc-context"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
      <!--<xsl:call-template name="toc.line">
        <xsl:with-param name="toc-context" select="$toc-context"/>
      </xsl:call-template>-->
      <xsl:if test="$autotoc.label.in.hyperlink = 0">
        <xsl:variable name="label">
          <xsl:apply-templates select="." mode="label.markup"/>
        </xsl:variable>
        <xsl:copy-of select="$label"/>
      </xsl:if>
      <li class="inactive">
        <a>
          <xsl:attribute name="href">
            <xsl:call-template name="href.target">
              <xsl:with-param name="context" select="$toc-context"/>
              <xsl:with-param name="toc-context" select="$toc-context"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:if test="not($autotoc.label.in.hyperlink = 0)">
            <xsl:variable name="label">
              <xsl:apply-templates select="." mode="label.markup"/>
            </xsl:variable>
            <span class="number">
              <xsl:copy-of select="$label"/>
              <xsl:text> </xsl:text>
            </span>
          </xsl:if>
          <span class="name">
            <xsl:apply-templates select="." mode="titleabbrev.markup"/>
          </span>
        </a>

      <xsl:if test="( (self::d:set or self::d:book or self::d:part) or
        $bubbletoc.section.depth &gt; $depth) and
        count($nodes) &gt; 0 and
        $bubbletoc.max.depth &gt; $depth.from.context and
        ($bubbletoc.max.depth.shallow = '0' or
        $bubbletoc.max.depth.shallow &gt; $depth.from.context)">
        <ol>
          <xsl:apply-templates mode="bubble-toc" select="$nodes">
            <xsl:with-param name="toc-context" select="$toc-context"/>
          </xsl:apply-templates>
        </ol>
      </xsl:if>
      </li>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>

    <xsl:template match="d:set" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>

    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
      <xsl:with-param name="nodes"
        select="d:set|d:book|d:bridgehead[$bridgehead.in.toc != 0]"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="d:book" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>

    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
      <xsl:with-param name="nodes"
        select="d:part|d:reference|d:preface|d:chapter|d:appendix|d:article|d:topic|d:bibliography|
        d:glossary|d:index|d:refentry|d:bridgehead[$bridgehead.in.toc != 0]"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="d:part|d:reference" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>

    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
      <xsl:with-param name="nodes"
        select="d:appendix|d:chapter|d:article|d:topic|d:index|d:glossary|d:bibliography|d:preface|
        d:reference|d:refentry|d:bridgehead[$bridgehead.in.toc != 0]"
      />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="d:preface|d:chapter|d:appendix|d:topic" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>

    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
      <xsl:with-param name="nodes"
        select="d:topic|d:refentry|d:glossary|d:bibliography|d:index|
        d:bridgehead[$bridgehead.in.toc != 0]"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="d:article" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>

    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
      <xsl:with-param name="nodes"
        select="d:section|d:sect1|d:simplesect[$simplesect.in.toc != 0]|
        d:topic|d:refentry|d:glossary|d:bibliography|d:index|
        d:bridgehead[$bridgehead.in.toc != 0]|d:appendix"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="d:sect1" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>
    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
      <xsl:with-param name="nodes"
        select="d:sect2|d:bridgehead[$bridgehead.in.toc != 0]"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="d:sect2" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>

    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
      <xsl:with-param name="nodes"
        select="d:sect3|d:bridgehead[$bridgehead.in.toc != 0]"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="d:sect3" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>

    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
      <xsl:with-param name="nodes"
        select="d:sect4|d:bridgehead[$bridgehead.in.toc != 0]"
      />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="d:sect4" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>

    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
      <xsl:with-param name="nodes"
        select="d:sect5|d:bridgehead[$bridgehead.in.toc != 0]"
      />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="d:sect5" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>

    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="d:simplesect" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>

    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="d:section" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>

    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
      <xsl:with-param name="nodes"
        select="d:section|d:refentry|d:simplesect[$simplesect.in.toc != 0]|
        d:bridgehead[$bridgehead.in.toc != 0]"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="d:bibliography|d:glossary" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>

    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="d:title" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>

    <a>
      <xsl:attribute name="href">
        <xsl:call-template name="href.target">
          <xsl:with-param name="object" select=".."/>
          <xsl:with-param name="toc-context" select="$toc-context"/>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:apply-templates/>
    </a>
  </xsl:template>

  <xsl:template match="d:index" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>

    <!-- If the index tag is not empty, it should be in the TOC -->
    <xsl:if test="* or $generate.index != 0">
      <xsl:call-template name="bubble-subtoc">
        <xsl:with-param name="toc-context" select="$toc-context"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>


</xsl:stylesheet>

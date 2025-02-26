<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
     Create (left) sidebar table of contents

   Author:    Thomas Schraitle <toms@opensuse.org>, Stefan Knorr <sknorr@suse.de>
   Copyright: 2012-2022, Thomas Schraitle, Stefan Knorr

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:exsl="http://exslt.org/common"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="exsl d">


  <xsl:template name="side.toc.overall.doc-overview.inner">
    <xsl:param name="node"/>
    <ol role="list">
      <xsl:apply-templates select="$node/d:set|$node/d:book|$node/d:article" mode="doc-overview">
      </xsl:apply-templates>
    </ol>
  </xsl:template>

  <xsl:template match="d:set|d:book|d:article" mode="doc-overview">
    <xsl:param name="toc-context" select="."/>

    <xsl:choose>
      <!-- Skip over books that only contain articles (and license appendixes) -->
      <xsl:when test="self::d:book[not(d:preface or d:chapter or d:part)]/d:article">
        <xsl:apply-templates select="d:article" mode="doc-overview">
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <li role="listitem">
          <a>
            <xsl:attribute name="href">
              <xsl:call-template name="href.target">
                <xsl:with-param name="context" select="$toc-context"/>
                <xsl:with-param name="toc-context" select="$toc-context"/>
              </xsl:call-template>
            </xsl:attribute>
            <span class="title-name">
              <xsl:apply-templates select="." mode="titleabbrev.markup"/>
            </span>
          </a>
        </li>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>



  <xsl:template name="side.toc.overall.inner">
    <xsl:param name="node"/>
    <xsl:param name="page-context"/>
    <ol role="list">
      <xsl:apply-templates select="$node" mode="bubble-toc">
        <xsl:with-param name="page-context-id" select="generate-id($page-context)"/>
      </xsl:apply-templates>
      <xsl:text> </xsl:text>
    </ol>
  </xsl:template>


  <xsl:template match="*" mode="check-descendant-id">
    <xsl:param name="page-context-id"/>
    <xsl:param name="level" select="0"/>
    <!-- I hope checking two levels (0,1) is not completely excessive ... -->
    <xsl:param name="max-level" select="2"/>

    <xsl:choose>
      <xsl:when test="generate-id(.) = $page-context-id">
        <xsl:text>1</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="$level &lt; ($max-level -1)">
          <xsl:apply-templates select="*" mode="check-descendant-id">
            <xsl:with-param name="page-context-id" select="$page-context-id"/>
            <xsl:with-param name="level" select="$level + 1"/>
          </xsl:apply-templates>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="bubble-subtoc">
    <xsl:param name="toc-context" select="."/>
    <xsl:param name="nodes" select="NOT-AN-ELEMENT"/>
    <xsl:param name="page-context-id"/>

    <xsl:variable name="has-descendant-page-context">
      <xsl:apply-templates select="*" mode="check-descendant-id">
        <xsl:with-param name="page-context-id" select="$page-context-id"/>
      </xsl:apply-templates>
    </xsl:variable>

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
          <xsl:with-param name="page-context-id" select="$page-context-id"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="needs.subtoc">
          <xsl:if test="( (self::d:set or self::d:book or self::d:part) or
             $bubbletoc.section.depth &gt; $depth) and
             count($nodes) &gt; 0 and
             $bubbletoc.max.depth &gt; $depth.from.context and
             ($bubbletoc.max.depth.shallow = '0' or
             $bubbletoc.max.depth.shallow &gt; $depth.from.context)">1</xsl:if>
        </xsl:variable>

        <xsl:if test="$autotoc.label.in.hyperlink = 0">
          <xsl:variable name="label">
            <xsl:apply-templates select="." mode="label.markup"/>
          </xsl:variable>
          <xsl:copy-of select="$label"/>
        </xsl:if>
        <li role="listitem">
          <xsl:if test="$needs.subtoc = 1 and
                        (generate-id(.) = $page-context-id or
                        string-length($has-descendant-page-context) &gt; 0)">
            <xsl:attribute name="class">active</xsl:attribute>
          </xsl:if>
          <a>
            <xsl:attribute name="href">
              <xsl:call-template name="href.target">
                <xsl:with-param name="context" select="$toc-context"/>
                <xsl:with-param name="toc-context" select="$toc-context"/>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="class">
              <xsl:if test="$needs.subtoc = 1">has-children</xsl:if>
              <xsl:text> </xsl:text>
              <xsl:if test="generate-id(.) = $page-context-id or
                            string-length($has-descendant-page-context) &gt; 0"
              >you-are-here</xsl:if>
            </xsl:attribute>
            <xsl:if test="not($autotoc.label.in.hyperlink = 0)">
              <xsl:variable name="label">
                <xsl:apply-templates select="." mode="label.markup"/>
              </xsl:variable>
              <span class="title-number">
                <xsl:copy-of select="$label"/>
                <xsl:text> </xsl:text>
              </span>
            </xsl:if>
            <span class="title-name">
              <xsl:apply-templates select="." mode="titleabbrev.markup"/>
            </span>
          </a>

          <xsl:if test="$needs.subtoc = 1">
            <ol role="list">
              <xsl:apply-templates mode="bubble-toc" select="$nodes">
                <xsl:with-param name="toc-context" select="$toc-context"/>
                <xsl:with-param name="page-context-id" select="$page-context-id"/>
              </xsl:apply-templates>
            </ol>
          </xsl:if>
        </li>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="d:set" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>
    <xsl:param name="page-context-id"/>

    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
      <xsl:with-param name="nodes"
        select="d:set|d:book|d:bridgehead[$bridgehead.in.toc != 0]"/>
      <xsl:with-param name="page-context-id" select="$page-context-id"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="d:book" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>
    <xsl:param name="page-context-id"/>

    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
      <xsl:with-param name="nodes"
        select="d:part|d:reference|d:preface|d:chapter|d:appendix|d:article|d:topic|d:bibliography|
        d:glossary|d:index|d:refentry|d:bridgehead[$bridgehead.in.toc != 0]"/>
      <xsl:with-param name="page-context-id" select="$page-context-id"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="d:part|d:reference" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>
    <xsl:param name="page-context-id"/>

    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
      <xsl:with-param name="nodes"
        select="d:appendix|d:chapter|d:article|d:topic|d:index|d:glossary|d:bibliography|d:preface|
        d:reference|d:refentry|d:bridgehead[$bridgehead.in.toc != 0]"/>
      <xsl:with-param name="page-context-id" select="$page-context-id"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="d:preface|d:chapter|d:appendix|d:topic" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>
    <xsl:param name="page-context-id"/>

    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
      <xsl:with-param name="nodes"
        select="d:topic|d:refentry|d:glossary|d:bibliography|d:index|
        d:bridgehead[$bridgehead.in.toc != 0]"/>
      <xsl:with-param name="page-context-id" select="$page-context-id"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="d:article" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>
    <xsl:param name="page-context-id"/>

    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
      <xsl:with-param name="nodes"
        select="d:section|d:sect1|d:simplesect[$simplesect.in.toc != 0]|
        d:topic|d:refentry|d:glossary|d:bibliography|d:index|
        d:bridgehead[$bridgehead.in.toc != 0]|d:appendix"/>
      <xsl:with-param name="page-context-id" select="$page-context-id"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="d:sect1" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>
    <xsl:param name="page-context-id"/>

    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
      <xsl:with-param name="nodes"
        select="d:sect2|d:bridgehead[$bridgehead.in.toc != 0]"/>
      <xsl:with-param name="page-context-id" select="$page-context-id"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="d:sect2" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>
    <xsl:param name="page-context-id"/>

    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
      <xsl:with-param name="nodes"
        select="d:sect3|d:bridgehead[$bridgehead.in.toc != 0]"/>
      <xsl:with-param name="page-context-id" select="$page-context-id"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="d:sect3" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>
    <xsl:param name="page-context-id"/>

    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
      <xsl:with-param name="nodes"
        select="d:sect4|d:bridgehead[$bridgehead.in.toc != 0]"/>
      <xsl:with-param name="page-context-id" select="$page-context-id"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="d:sect4" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>
    <xsl:param name="page-context-id"/>

    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
      <xsl:with-param name="nodes"
        select="d:sect5|d:bridgehead[$bridgehead.in.toc != 0]"/>
      <xsl:with-param name="page-context-id" select="$page-context-id"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="d:sect5" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>
    <xsl:param name="page-context-id"/>

    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
      <xsl:with-param name="page-context-id" select="$page-context-id"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="d:simplesect" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>
    <xsl:param name="page-context-id"/>

    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
      <xsl:with-param name="page-context-id" select="$page-context-id"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="d:section" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>
    <xsl:param name="page-context-id"/>

    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
      <xsl:with-param name="nodes"
        select="d:section|d:refentry|d:simplesect[$simplesect.in.toc != 0]|
        d:bridgehead[$bridgehead.in.toc != 0]"/>
      <xsl:with-param name="page-context-id" select="$page-context-id"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="d:bibliography|d:glossary" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>
    <xsl:param name="page-context-id"/>

    <xsl:call-template name="bubble-subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
      <xsl:with-param name="page-context-id" select="$page-context-id"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="d:title" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>
    <xsl:param name="page-context-id"/>

    <a>
      <xsl:attribute name="href">
        <xsl:call-template name="href.target">
          <xsl:with-param name="object" select=".."/>
          <xsl:with-param name="toc-context" select="$toc-context"/>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:if test="generate-id(.) = $page-context-id">
        <xsl:attribute name="class">you-are-here</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </a>
  </xsl:template>

  <xsl:template match="d:index" mode="bubble-toc">
    <xsl:param name="toc-context" select="."/>
    <xsl:param name="page-context-id"/>

    <!-- If the index tag is not empty, it should be in the TOC -->
    <xsl:if test="* or $generate.index != 0">
      <xsl:call-template name="bubble-subtoc">
        <xsl:with-param name="toc-context" select="$toc-context"/>
        <xsl:with-param name="page-context-id" select="$page-context-id"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>


</xsl:stylesheet>

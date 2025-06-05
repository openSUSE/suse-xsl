<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Returns the number only of an element, if it has one. Normally, this
    is done by the original stylesheets, however, some has to be
    explicitly added.

  Author(s):    Thomas Schraitle <toms@opensuse.org>

  Copyright:    2013, Thomas Schraitle

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:exsl="http://exslt.org/common"
  exclude-result-prefixes="exsl d">

  <xsl:template match="d:refsect1/d:title|d:refnamediv" mode="label.markup"/>


  <xsl:template match="d:question" mode="label.markup">
    <xsl:variable name="lparent" select="(ancestor::d:set
      |ancestor::d:book
      |ancestor::d:chapter
      |ancestor::d:appendix
      |ancestor::d:preface
      |ancestor::d:section
      |ancestor::d:simplesect
      |ancestor::d:sect1
      |ancestor::d:sect2
      |ancestor::d:sect3
      |ancestor::d:sect4
      |ancestor::d:sect5
      |ancestor::d:refsect1
      |ancestor::d:refsect2
      |ancestor::d:refsect3)[last()]"/>
    <xsl:variable name="lparent.prefix">
      <xsl:apply-templates select="$lparent" mode="label.markup"/>
    </xsl:variable>
    <xsl:variable name="prefix">
      <xsl:if test="$qanda.inherit.numeration != 0">
        <xsl:choose>
          <xsl:when test="ancestor::d:qandadiv">
            <xsl:variable name="div.label">
              <xsl:apply-templates select="ancestor::d:qandadiv[1]" mode="label.markup"/>
            </xsl:variable>
            <xsl:if test="string-length($div.label) != 0">
              <xsl:copy-of select="$div.label"/>
              <xsl:apply-templates select="ancestor::d:qandadiv[1]"
                mode="intralabel.punctuation">
                <xsl:with-param name="object" select="."/>
              </xsl:apply-templates>
            </xsl:if>
          </xsl:when>
          <xsl:when test="$lparent.prefix != ''">
            <xsl:apply-templates select="$lparent" mode="label.markup"/>
            <xsl:apply-templates select="$lparent" mode="intralabel.punctuation">
              <xsl:with-param name="object" select="."/>
            </xsl:apply-templates>
          </xsl:when>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="inhlabel"
      select="ancestor-or-self::d:qandaset/@defaultlabel[1]"/>

    <xsl:variable name="deflabel">
      <xsl:choose>
        <xsl:when test="$inhlabel != ''">
          <xsl:value-of select="$inhlabel"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$qanda.defaultlabel"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="label" select="d:label"/>

    <xsl:choose>
      <xsl:when test="count($label)>0">
        <xsl:apply-templates select="$label"/>
      </xsl:when>

      <xsl:when test="$deflabel = 'global'">
        <xsl:number level="any" count="d:qandaentry" format="1."/>
      </xsl:when>

      <xsl:when test="$deflabel = 'qanda' and self::d:question">
        <xsl:call-template name="gentext">
          <xsl:with-param name="key" select="'Question'"/>
        </xsl:call-template>
      </xsl:when>

      <xsl:when test="$deflabel = 'qanda' and self::d:answer">
        <xsl:call-template name="gentext">
          <xsl:with-param name="key" select="'Answer'"/>
        </xsl:call-template>
      </xsl:when>

      <xsl:when test="($deflabel = 'qnumber' or
        $deflabel = 'qnumberanda') and self::d:question">
        <xsl:call-template name="gentext">
          <xsl:with-param name="key" select="'Question'"/>
        </xsl:call-template>
        <xsl:text>&#xA0;</xsl:text>
        <xsl:value-of select="$prefix"/>
        <xsl:number level="multiple" count="d:qandaentry" format="1"/>
      </xsl:when>

      <xsl:when test="$deflabel = 'qnumberanda' and self::d:answer">
        <xsl:call-template name="gentext">
          <xsl:with-param name="key" select="'Answer'"/>
        </xsl:call-template>
      </xsl:when>

      <xsl:when test="$deflabel = 'number' and self::d:question">
        <xsl:value-of select="$prefix"/>
        <xsl:number level="multiple" count="d:qandaentry" format="1"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>


  <!-- Issue #587: Remove double full stop for procedures in appendices -->
  <xsl:template match="d:appendix" mode="intralabel.punctuation">
    <xsl:param name="object" select="."/>
    <xsl:text />
  </xsl:template>

</xsl:stylesheet>
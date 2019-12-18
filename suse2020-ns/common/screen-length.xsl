<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Check length of screen content

  Author:     Thomas Schraitle <toms@suse.de>
  Copyright:  2017 Thomas Schraitle

-->
<xsl:stylesheet exclude-result-prefixes="exsl str d" version="1.0"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook">

  <!-- Maximum preferred screen length of a string before line break -->
  <xsl:param name="screen.max.length" select="80"/>
  <xsl:param name="screen.max.lines" select="250"/>

  <xsl:template name="splitscreen">
    <xsl:param name="text" select="string(.)"/>
    <xsl:param name="linecount" select="1"/>

    <xsl:choose>
      <xsl:when test="contains($text, '&#10;')">
        <xsl:variable name="text-before-first-break">
          <xsl:value-of select="substring-before($text, '&#10;')"/>
        </xsl:variable>
        <xsl:variable name="text-after-first-break">
          <xsl:value-of select="substring-after($text, '&#10;')"/>
        </xsl:variable>

        <xsl:choose>
          <xsl:when test="string-length($text-before-first-break) &gt;
                          $screen.max.length">longlines</xsl:when>
          <xsl:when test="$linecount &gt; $screen.max.lines">manylines</xsl:when>
          <xsl:when test="not($text-after-first-break = '')">
            <xsl:call-template name="splitscreen">
              <xsl:with-param name="text" select="$text-after-first-break"/>
              <xsl:with-param name="linecount" select="$linecount + 1"/>
            </xsl:call-template>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>goodlines</xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="check.screenlength">
    <!-- Transform everything inside <screen> or <programlisting> into a
         string, regardless if there are other child elements or not.
    -->
    <xsl:param name="text" select="string(.)"/>
    <!-- Variable "result" contains only "0" or "1", wheather the string
         is longer or shorter than $screen.max.length
    -->
    <xsl:variable name="result">
      <xsl:call-template name="splitscreen">
        <xsl:with-param name="text" select="$text"/>
      </xsl:call-template>
    </xsl:variable>

    <!-- Apply it only to programlisting and screen -->
    <xsl:if test="(self::d:programlisting or self::d:screen) and $result != 'goodlines'">
      <xsl:call-template name="log.message">
        <xsl:with-param name="level">Warn</xsl:with-param>
        <xsl:with-param name="source">
          <xsl:if test="(./ancestor-or-self::*/@id|./ancestor-or-self::*/@xml:id)">
            <xsl:text>(in </xsl:text>
            <xsl:value-of select="(./ancestor-or-self::*/@id|./ancestor-or-self::*/@xml:id)[last()]"/>
            <xsl:text>)</xsl:text>
          </xsl:if>
        </xsl:with-param>
        <xsl:with-param name="context-desc" select="local-name(.)"/>
        <xsl:with-param name="message">
          <xsl:choose>
            <xsl:when test="$result = 'manylines'">
              <xsl:value-of select="local-name(.)"/>
              <xsl:text> has more than </xsl:text>
              <xsl:value-of select="$screen.max.lines"/>
              <xsl:text> lines.</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>Line in </xsl:text>
              <xsl:value-of select="local-name(.)"/>
              <xsl:text> is longer than </xsl:text>
              <xsl:value-of select="$screen.max.length"/>
              <xsl:text> characters.</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
         </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>

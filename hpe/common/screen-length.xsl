<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Check length of screen content

  Author:     Thomas Schraitle <toms@suse.de>
  Copyright:  2017 Thomas Schraitle

-->
<xsl:stylesheet exclude-result-prefixes="exsl str" version="1.0"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Maximum preferred screen length of a string before line break -->
  <xsl:param name="screen.max.length" select="80"/>


  <xsl:template name="splitscreen">
    <xsl:param name="text" select="string(.)"/>

    <xsl:choose>
      <xsl:when test="contains($text, '&#10;')">
        <xsl:variable name="text-before-first-break">
          <xsl:value-of select="substring-before($text, '&#10;')"/>
        </xsl:variable>
        <xsl:variable name="text-after-first-break">
          <xsl:value-of select="substring-after($text, '&#10;')"/>
        </xsl:variable>

        <xsl:if test="string-length($text-before-first-break) >
                      $screen.max.length">1</xsl:if>

        <xsl:if test="not($text-after-first-break = '')">
          <xsl:call-template name="splitscreen">
            <xsl:with-param name="text" select="$text-after-first-break"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:when>
      <xsl:when test="string-length($text) > $screen.max.length">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
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
    <xsl:if test="(self::programlisting or self::screen) and number($result) > 0">
      <xsl:call-template name="log.message">
        <xsl:with-param name="level">Warn</xsl:with-param>
        <xsl:with-param name="source">
          <xsl:text>(in </xsl:text>
          <xsl:value-of select="(./ancestor-or-self::*/@id|./ancestor-or-self::*/@xml:id)[last()]"/>
          <xsl:text>)</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="context-desc" select="local-name(.)"/>
        <xsl:with-param name="message">
           <xsl:text>String in </xsl:text>
           <xsl:value-of select="local-name(.)"/>
           <xsl:text> is longer than </xsl:text>
           <xsl:value-of select="$screen.max.length"/>
           <xsl:text> characters.</xsl:text>
         </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>

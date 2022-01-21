<?xml version="1.0" encoding="UTF-8"?>
<!--

   Author:    Stefan Knorr <sknorr@suse.de>
   Copyright: 2022

-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Replaces the upstream log message implementation with something that at
  least makes sure log levels are consistent and does not randomly cut off
  messages after 45 characters. What the actual he -->
  <xsl:template name="log.message">
    <xsl:param name="level"/>
    <xsl:param name="context-desc"/>
    <xsl:param name="message"/>
    <xsl:param name="source"/>

    <xsl:variable name="level-indicator"
      select="translate(substring($level, 1, 1), 'fewid', 'FEWID')"/>
    <xsl:variable name="level-displayed">
      <xsl:choose>
        <xsl:when test="$level-indicator = 'F'">
          <xsl:text>FATAL</xsl:text>
        </xsl:when>
        <xsl:when test="$level-indicator = 'E'">
          <xsl:text>ERROR</xsl:text>
        </xsl:when>
        <xsl:when test="$level-indicator = 'W'">
          <xsl:text>WARN </xsl:text>
        </xsl:when>
        <xsl:when test="$level-indicator = 'I'">
          <xsl:text>INFO </xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>DEBUG</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="context-desc-padded">
      <xsl:value-of select="substring(concat($context-desc, '               '), 1, 15)"/>
    </xsl:variable>
    <xsl:variable name="source-displayed">
      <xsl:choose>
        <!-- The caller manually supplied source="0" == explicitly disabled, no op -->
        <xsl:when test="$source = 0"/>
        <!-- The caller manually supplied a source string, use that. -->
        <xsl:when test="string-length($source) &gt; 0">
          <xsl:value-of select="$source"/>
        </xsl:when>
        <!-- Is the context an attribute and does its parent have an xml:id?
        https://web.archive.org/web/20170619143205/http://www.dpawson.co.uk/xsl/sect2/nodetest.html#d7657e255 -->
        <xsl:when test="$source = '' and count(.|../@*)=count(../@*) and ../@xml:id">
          <xsl:text>at xml:id=</xsl:text>
          <xsl:value-of select="../@xml:id"/>
        </xsl:when>
        <!-- Is the context an element that has an xml:id? -->
        <xsl:when test="$source = '' and ./@xml:id">
          <xsl:text>at xml:id=</xsl:text>
          <xsl:value-of select="./@xml:id"/>
        </xsl:when>
        <!-- Anything above us in the tree that has an xml:id? -->
        <xsl:when test="$source = '' and ancestor-or-self::*/@xml:id">
          <xsl:text>within xml:id=</xsl:text>
          <xsl:value-of select="(ancestor-or-self::*/@xml:id)[last()]"/>
          <xsl:text>, at XPath=</xsl:text>
          <xsl:call-template name="xpath.location"/>
        </xsl:when>
        <!-- We can't find an xml:id and there's no manually supplied value,
        maybe the XPath is useful though. -->
        <xsl:otherwise>
          <xsl:text>at XPath=</xsl:text>
          <xsl:call-template name="xpath.location"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="composed-message">
      <xsl:text>[</xsl:text>
      <xsl:value-of select="$level-displayed"/>
      <xsl:text>] </xsl:text>
      <xsl:value-of select="$context-desc-padded"/>
      <xsl:text> | </xsl:text>
      <xsl:value-of select="$message"/>
      <xsl:if test="not($source-displayed = '')">
        <xsl:text> (Source: </xsl:text>
        <xsl:value-of select="$source-displayed"/>
        <xsl:text>)</xsl:text>
      </xsl:if>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$level-indicator = 'F'">
        <xsl:message terminate="yes"><xsl:value-of select="$composed-message"/></xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message><xsl:value-of select="$composed-message"/></xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>

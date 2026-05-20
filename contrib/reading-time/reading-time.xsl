<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Determine the reading time of a DocBook 5 document

   Parameters:
     * wordspermin: The average reading speed. A common assumption is 200 words/min
                    for general reading.

   Input:
     DocBook 5 document

   Output:
     A short XML structure with the word count (<word-count>) and the reading time
     (<reading-time>).

   Author:
      Tom Schraitle <toms@suse.de>
-->
<xsl:stylesheet
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:output indent="yes" method="xml"/>

  <xsl:param name="words-per-min" select="200"/>

  <!-- ### Function templates -->
  <xsl:template name="ceil">
    <xsl:param name="number" />
    <xsl:value-of select="floor($number) + (number($number) != floor($number))" />
</xsl:template>


  <!-- ### Root template -->
  <xsl:template match="/">
    <xsl:variable name="word-count">
      <xsl:call-template name="count-words" />
    </xsl:variable>
    <xsl:variable name="reading-time-minutes">
      <xsl:call-template name="ceil">
        <xsl:with-param name="number" select="$word-count div $words-per-min" />
      </xsl:call-template>
    </xsl:variable>

    <!-- Output the result -->
    <result>
      <word-count><xsl:value-of select="$word-count" /></word-count>
      <reading-time unit="min"><xsl:value-of select="$reading-time-minutes" /></reading-time>
    </result>
  </xsl:template>

  <!-- Count words template -->
  <xsl:template name="count-words">
    <xsl:variable name="text">
      <!-- Apply templates to all relevant text nodes -->
      <xsl:apply-templates mode="count" />
    </xsl:variable>
    <xsl:value-of select="string-length(normalize-space($text)) - string-length(translate(normalize-space($text), ' ', '')) + 1" />
  </xsl:template>

  <!-- Default mode for counting text -->
  <xsl:template match="text()" mode="count">
    <xsl:value-of select="normalize-space(.)" />
    <xsl:text> </xsl:text>
  </xsl:template>

  <!-- Exclude metadata: Add a no-op template for elements to exclude -->
  <xsl:template match="d:info/d:meta" mode="count" />
  <xsl:template match="d:info/d:revhistory" />

  <xsl:template match="comment() | processing-instruction()"/>

  <!-- Add special handling for other elements here -->
  <!-- Example: Special processing for titles -->
  <xsl:template match="title" mode="count">
    <xsl:value-of select="normalize-space(.)" />
    <xsl:text> </xsl:text>
  </xsl:template>
</xsl:stylesheet>


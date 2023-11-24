<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Checks more complex data types

   Input:
     A string

   Output:
     Single XHTML file

   See Also:

   Authors:    Thomas Schraitle <toms@opensuse.org>

-->

<!DOCTYPE xsl:stylesheet [
  <!ENTITY ascii.uc "ABCDEFGHIJKLMNOPQRSTUVWXYZ">
  <!ENTITY ascii.lc "abcdefghijklmnopqrstuvwxy">
]>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:dm="urn:x-suse:ns:docmanager"
  xmlns:exsl="http://exslt.org/common"
  xmlns:date="http://exslt.org/dates-and-times"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="exsl date d dm">


  <!--
    Template function is-valid-iso-8601-date

    Parameter text (string):
        the string to check for the date format "YYYY-MM-DD"
    Return: bool
        true() if the date matches the ISO8601 format, otherwise false()
  -->
  <xsl:template name="is-valid-iso-8601-date">
    <!-- Checks, if $text contains "YYYY-MM-DD" -->
    <xsl:param name="text"/>
    <xsl:param name="check-day" select="1"/>
    <xsl:variable name="year" select="number(substring-before($text, '-'))"/>
    <xsl:variable name="month" select="number(substring($text, 6, 2))"/>
    <xsl:variable name="day" select="number(substring($text, 9, 2))"/>
    <xsl:variable name="bool-check-day">
      <xsl:call-template name="is-valid-boolean">
        <xsl:with-param name="text" select="$check-day"/>
      </xsl:call-template>
    </xsl:variable>

<!--  <xsl:message>is-valid-iso-8601-date:
     text="<xsl:value-of select="$text"/>"
     year="<xsl:value-of select="$year"/>"
    month="<xsl:value-of select="$month"/>"
      day="<xsl:value-of select="$day"/>"
    boolean($check-day)=<xsl:value-of select="$bool-check-day"/>
  </xsl:message>-->

  <xsl:choose>
    <xsl:when test="string-length($text) != 10">
      <xsl:value-of select="false()"/>
    </xsl:when>
    <xsl:when test="$year = 'NaN' or $month = 'NaN'">
      <xsl:value-of select="false()"/>
    </xsl:when>
    <xsl:when test="$bool-check-day = true() and number($day) = 'NaN'">
      <xsl:value-of select="false()"/>
    </xsl:when>
    <xsl:when test="$year &lt; 1999">
      <xsl:value-of select="false()"/>
    </xsl:when>
    <xsl:when test="$month &lt; 1 or $month > 12">
      <xsl:value-of select="false()"/>
    </xsl:when>
    <xsl:when test="$bool-check-day = true() and ($day &lt; 1 or $day > 31)">
      <xsl:value-of select="false()"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="true()"/>
    </xsl:otherwise>
  </xsl:choose>
  </xsl:template>


  <!--
    Template function is-boolean

    Parameter text (string):
        the string to check if it's a boolean. Valid values are:
        * 1, on, yes, YES for true()
        * 0, off, no, NO, "" for false()
    Return: bool
        true() if it's a bool, false() otherwise
  -->
  <xsl:template name="is-valid-boolean">
    <xsl:param name="text"/>
    <xsl:variable name="lc.text" select="translate($text, '&ascii.uc;', '&ascii.lc;')"/>

    <xsl:choose>
      <xsl:when test="$lc.text = 'yes' or $lc.text = 'on' or $lc.text = 'true'">
        <xsl:value-of select="true()"/>
      </xsl:when>
      <xsl:when test="$lc.text = 'no' or $lc.text = 'off' or $lc.text = 'false'">
        <xsl:value-of select="true()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="boolean($text)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
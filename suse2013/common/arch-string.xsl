<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Use SUSE's official architecture names in architecture strings.

  Author:     Stefan Knorr <sknorr@suse.de>
  Copyright:  2014 Stefan Knorr

-->

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template name="readable.arch.string">
    <xsl:param name="input"/>
    <xsl:variable name="zseries-replaced">
      <xsl:call-template name="string-replace">
        <xsl:with-param name="input" select="$input"/>
        <xsl:with-param name="search-string">zseries</xsl:with-param>
        <xsl:with-param name="replace-string">IBM Z</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="power-replaced">
      <xsl:call-template name="string-replace">
        <xsl:with-param name="input" select="$zseries-replaced"/>
        <xsl:with-param name="search-string">power</xsl:with-param>
        <xsl:with-param name="replace-string">POWER</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="x86_64-replaced">
      <xsl:call-template name="string-replace">
        <xsl:with-param name="input" select="$power-replaced"/>
        <xsl:with-param name="search-string">x86_64</xsl:with-param>
        <xsl:with-param name="replace-string">AMD/Intel</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="aarch64-replaced">
      <xsl:call-template name="string-replace">
        <xsl:with-param name="input" select="$x86_64-replaced"/>
        <xsl:with-param name="search-string">aarch64</xsl:with-param>
        <xsl:with-param name="replace-string">Arm</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="candidate">
      <xsl:call-template name="string-replace">
        <xsl:with-param name="input" select="$aarch64-replaced"/>
        <xsl:with-param name="search-string">;</xsl:with-param>
        <xsl:with-param name="replace-string">, </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>

    <xsl:value-of select="normalize-space($candidate)"/>
  </xsl:template>

</xsl:stylesheet>

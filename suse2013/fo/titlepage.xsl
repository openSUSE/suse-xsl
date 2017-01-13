<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Don't add the text "Abstract" before abstracts on title pages.

  Author(s):  Stefan Knorr <sknorr@suse.de>

  Copyright:  2013, Stefan Knorr

-->
<!DOCTYPE xsl:stylesheet
[
  <!ENTITY % fonts SYSTEM "fonts.ent">
  <!ENTITY % colors SYSTEM "colors.ent">
  <!ENTITY % metrics SYSTEM "metrics.ent">
  %fonts;
  %colors;
  %metrics;
]>
<xsl:stylesheet  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:template match="abstract" mode="titlepage.mode">
  <fo:block xsl:use-attribute-sets="abstract.properties">
    <fo:block xsl:use-attribute-sets="abstract.title.properties">
      <xsl:if test="title|info/title">
        <xsl:apply-templates select="title|info/title"/>
      </xsl:if>
    </fo:block>
    <xsl:apply-templates select="*[not(self::title)]" mode="titlepage.mode"/>
  </fo:block>
</xsl:template>

<!-- At the request of both Chinese translation teams, do not use "by Author
x and Author y" and instead use "Authors: Author x and Author y" -->
<xsl:template name="verso.authorgroup">
  <xsl:param name="person.list" select="author|corpauthor|othercredit|editor"/>
  <xsl:param name="person.count" select="count($person.list)"/>
  <fo:block>
    <!-- I will assume Japanese and Korean are similar, even though there was
    no explicit request for a change.
    Also, in none of these languages, plural seems to play a role but I feel
    pedantic today and will include it anyway.
    -->
    <xsl:choose>
      <xsl:when test="starts-with($document.language, 'zh') or
                      starts-with($document.language, 'ko') or
                      starts-with($document.language, 'ja')">
        <xsl:choose>
          <xsl:when test="$person.count = 1">
            <xsl:call-template name="gentext">
              <xsl:with-param name="key" select="'Author'"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="gentext">
              <xsl:with-param name="key" select="'Authors'"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="gentext">
          <xsl:with-param name="key" select="'admonseparator'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="gentext">
          <xsl:with-param name="key" select="'by'"/>
        </xsl:call-template>
        <xsl:text> </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="person.name.list">
      <xsl:with-param name="person.list" select="author|corpauthor|editor"/>
    </xsl:call-template>
  </fo:block>
  <xsl:apply-templates select="othercredit" mode="titlepage.mode"/>
</xsl:template>

</xsl:stylesheet>

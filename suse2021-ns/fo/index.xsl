<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Work around an FOP bug that created unnecessary page breaks in some
    cases where an indexterm followed a headline (see trello:SUSE2013#196).
    Since, we only care about FOP & XEP, that is the only special-casing we
    do. The original stylesheets also special-case for Antenna House.
    AH, however, currently gets the same markup as FOP ... so for the moment,
    we're functionally equivalent.
    The &primary;/&secondary;&tertiary; entities are shamelessly copied from
    {upstream}/fo/common/entities.ent

  Author(s):  Stefan Knorr <sknorr@suse.de>

  Copyright:  2014, Stefan Knorr

-->
<!DOCTYPE xsl:stylesheet
[
  <!ENTITY % fonts SYSTEM "fonts.ent">
  <!ENTITY % colors SYSTEM "colors.ent">
  <!ENTITY % metrics SYSTEM "metrics.ent">
  %fonts;
  %colors;
  %metrics;
  <!ENTITY primary   'normalize-space(concat(d:primary/@sortas, " ", d:primary))'>
  <!ENTITY secondary 'normalize-space(concat(d:secondary/@sortas, " ", d:secondary))'>
  <!ENTITY tertiary  'normalize-space(concat(d:tertiary/@sortas, " ", d:tertiary))'>
]>
<xsl:stylesheet exclude-result-prefixes="d"
                  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:rx="http://www.renderx.com/XSL/Extensions">


<xsl:template match="d:indexterm" name="indexterm">
    <xsl:choose>
      <xsl:when test="$xep.extensions != 0">
        <fo:wrapper>
          <xsl:attribute name="id">
            <xsl:call-template name="object.id"/>
          </xsl:attribute>
          <xsl:attribute name="rx:key">
            <xsl:value-of select="&primary;"/>
            <xsl:if test="@significance='preferred'"><xsl:value-of select="$significant.flag"/></xsl:if>
            <xsl:if test="d:secondary">
              <xsl:text>, </xsl:text>
              <xsl:value-of select="&secondary;"/>
            </xsl:if>
            <xsl:if test="d:tertiary">
              <xsl:text>, </xsl:text>
              <xsl:value-of select="&tertiary;"/>
            </xsl:if>
          </xsl:attribute>
        </fo:wrapper>
      </xsl:when>
      <xsl:otherwise>
        <fo:block margin="0cm" padding="0cm" line-height="0cm" font-size="0pt" space-before="0cm" space-after="0cm" keep-with-previous="always" keep-with-next="always">
          <xsl:attribute name="id">
            <xsl:call-template name="object.id"/>
          </xsl:attribute>
          <xsl:comment>
            <xsl:call-template name="comment-escape-string">
              <xsl:with-param name="string">
                <xsl:value-of select="d:primary"/>
                <xsl:if test="d:secondary">
                  <xsl:text>, </xsl:text>
                  <xsl:value-of select="d:secondary"/>
                </xsl:if>
                <xsl:if test="d:tertiary">
                  <xsl:text>, </xsl:text>
                  <xsl:value-of select="d:tertiary"/>
                </xsl:if>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:comment>
        </fo:block>
      </xsl:otherwise>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>

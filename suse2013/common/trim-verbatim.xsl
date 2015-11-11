<?xml version="1.0" encoding="UTF-8"?>
<!--
    Purpose:
     Trim start/end of verbatim areas (screen, programlisting, synopsis)


    Author:     Stefan Knorr <sknorr@suse.de>
    Copyright:  2015

-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >

<xsl:template match="programlisting/text()|screen/text()|synopsis/text()">
  <xsl:choose>
    <xsl:when test="$trim.verbatim = 1">
      <xsl:choose>
        <xsl:when test="not(preceding-sibling::node()) or preceding-sibling::processing-instruction()[not(preceding-sibling::node())]">
          <xsl:call-template name="trim-verbatim-whitespace-start"/>
        </xsl:when>
        <xsl:when test="not(following-sibling::node()) or following-sibling::processing-instruction()[not(following-sibling::node())]">
          <xsl:call-template name="trim-verbatim-whitespace-end"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="self::text()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="self::text()"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="trim-verbatim-whitespace-start">
  <!-- Goal: At the start of text, trim lines or that are empty or contain only
       spaces.
       Do not trim lines that contain spaces at the beginning and then continue
       with text. Doing that might destroy some content: e.g. command-line
       output formatted as a table. -->
  <xsl:param name="input" select="self::text()"/>
  <xsl:variable name="first-line" select="substring-before($input, '&#10;')"/>
  <!-- We could cover many more invisible characters here (en space, em space,
       zero width space, ...). For simplicity, we focus on space, tab and
       no-break space here. -->
  <xsl:variable name="line-length-no-space"  select="string-length(translate($first-line, ' &#9;&#160;', ''))"/>
  <xsl:variable name="first-character" select="substring($input, 1, 1)"/>
  <xsl:variable name="trimmed">
    <xsl:choose>
      <!-- Check if the line contains a break, otherwise we may end up
           removing spaces from before a <tag> which I am less sure is safe. -->
      <xsl:when test="contains($input, '&#10;')">
        <xsl:choose>
          <xsl:when test="$first-character = '&#10;'">
            <xsl:value-of select="substring($input, 2)"/>
          </xsl:when>
          <xsl:when test="(string-length($first-line &gt; 0)) and ($line-length-no-space = 0)">
            <xsl:value-of select="substring-after($input, '&#10;')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$input"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$input"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="not($input = $trimmed)">
      <xsl:call-template name="trim-verbatim-whitespace-start">
        <xsl:with-param name="input" select="$trimmed"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$trimmed"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="trim-verbatim-whitespace-end">
  <!-- Goal: At the end of text, trim whitespace characters.
       We do this one by one, as that seems the only way possible. -->
  <xsl:param name="input" select="self::text()"/>
  <xsl:variable name="last-character" select="substring($input, string-length($input), 1)"/>
  <xsl:variable name="trimmed">
    <xsl:choose>
      <xsl:when test="string-length(translate($last-character, ' &#9;&#10;&#160;', '')) = 0">
        <xsl:value-of select="substring($input, 1, string-length($input) - 1)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$input"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="not($input = $trimmed)">
      <xsl:call-template name="trim-verbatim-whitespace-end">
        <xsl:with-param name="input" select="$trimmed"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$trimmed"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>

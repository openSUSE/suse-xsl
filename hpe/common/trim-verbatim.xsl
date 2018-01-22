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
  <xsl:variable name="trim.allowed">
    <xsl:choose>
      <xsl:when test="$trim.verbatim = 1 and
                      not(parent::*/processing-instruction('dbsuse-disable-trimming'))">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="trim.start">
    <xsl:choose>
      <xsl:when test="$trim.allowed = 1">
        <!--  We only act on text that does not have a element or actual text
              before/after it. But we do act on text that has before/after it only:
            * PIs
            * comments
            * whitespace nodes -->
        <xsl:choose>
          <xsl:when test="not(preceding-sibling::node()[self::* or normalize-space(self::text())])">
            <xsl:choose>
            <!--  We do not use normalize-space() here, because it also removes
                  CR/LF characters which we may want to keep. It does not remove
                  no-break spaces etc.
                  We could cover many more invisible characters here (en space,
                  em space, zero width space, ...). For simplicity, we focus on
                  space, tab and no-break space here. -->

            <!--  btw: normalize-space() removes exactly this:
                  S ::= (#x20 | #x9 | #xD | #xA)+
                        [space| tab | cr  | lf ]+ -->

            <!-- The following does this:
               * We check that the string itself does not have any content besides
                 whitespace
               * We check that the next following text node starts with a line
                 that is just whitespace
               * We check whether the next text node appears before the next
                 element
               & If all of that is the case, we do nothing, because we have just
                 found a basically empty text node which may be followed by
                 comments/PIs and is then followed by a text node that can be
                 trimmed at the start. -->
              <xsl:when test="(string-length(translate(self::text(), ' &#9;&#160;&#10;', '')) = 0) and
                              contains(following-sibling::text()[1], '&#10;') and
                              (string-length(translate(substring-before(following-sibling::text()[1], '&#10;'), ' &#9;&#160;', '')) = 0) and
                              ( not(following-sibling::*) or
                                (following-sibling::text()[1]/following-sibling::*[1] = following-sibling::*[1]))"/>
                <!-- Safe to remove entirely: no op. -->
              <xsl:otherwise>
                <xsl:call-template name="trim-verbatim-whitespace-start">
                  <xsl:with-param name="input" select="self::text()"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
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
  </xsl:variable>

  <xsl:variable name="trim.end">
    <xsl:choose>
      <xsl:when test="$trim.allowed = 1">
        <!--  We only act on text that does not have a element or actual text
              before/after it. But we do act on text that has before/after it only:
            * PIs
            * comments
            * whitespace nodes -->
        <xsl:choose>
          <xsl:when test="not(following-sibling::node()[self::* or normalize-space(self::text())])">
            <xsl:call-template name="trim-verbatim-whitespace-end">
              <xsl:with-param name="input" select="$trim.start"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$trim.start"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$trim.start"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:value-of select="$trim.end"/>
</xsl:template>

<xsl:template name="trim-verbatim-whitespace-start">
  <!-- Goal: At the start of text, trim lines or that are empty or contain only
       spaces.
       Do not trim lines that contain spaces at the beginning and then continue
       with text. Doing that might destroy some content: e.g. command-line
       output formatted as a table. -->
  <xsl:param name="input" select="'NONE'"/>
  <xsl:variable name="first-line" select="substring-before($input, '&#10;')"/>

  <!--  We do not use normalize-space() here, because it also removes
        CR/LF characters which we may want to keep. It does not remove
        no-break spaces etc.
        We could cover many more invisible characters here (en space, em space,
        zero width space, ...). For simplicity, we focus on space, tab and
        no-break space here. -->
  <xsl:variable name="line-length-no-space" select="string-length(translate($first-line, ' &#9;&#160;', ''))"/>
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
  <xsl:param name="input" select="'NONE'"/>
  <xsl:variable name="last-character" select="substring($input, string-length($input), 1)"/>
  <xsl:variable name="trimmed">
    <xsl:choose>
     <!--  We do not use normalize-space() here, because it also removes
           CR/LF characters which we may want to keep. It does not remove
           no-break spaces etc.
           We could cover many more invisible characters here (en space, em space,
           zero width space, ...). For simplicity, we focus on space, tab and
           no-break space here. -->
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

<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Use sans-serif font in formalpara titles.

  Author(s):  Stefan Knorr <sknorr@suse.de>,
              Thomas Schraitle <toms@opensuse.org>

  Copyright:  2013, 2014, Stefan Knorr, Thomas Schraitle

-->
<!DOCTYPE xsl:stylesheet
[
  <!ENTITY % fonts SYSTEM "fonts.ent">
  <!ENTITY % colors SYSTEM "colors.ent">
  <!ENTITY % metrics SYSTEM "metrics.ent">
  %fonts;
  %colors;
  %metrics;
  <!ENTITY punctuation "!,,.::;?;־׀׃׆׳״؞؟‒–—―․‥…‼‽⁇⁈⁉⁏⁓⁕⁖⁘⁙⁚❓❔❕❗❢❣⸪⸫⸬⸺⸻。〜〰꓾꓿︐︑︒︓︔︕︖︙︱︲﹐﹑﹒﹔﹕﹖﹗﹘！，－．：；？｡､">
]>
<xsl:stylesheet exclude-result-prefixes="d"
                 version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:svg="http://www.w3.org/2000/svg">

<!-- Some people would like to hard code page breaks into their PDFs,
     this gives them a tool to do that. -->
<xsl:template match="processing-instruction('pdfpagebreak')">
  <xsl:variable name="pi-style">
    <xsl:call-template name="pi-attribute">
      <xsl:with-param name="pis" select="."/>
      <xsl:with-param name="attribute">style</xsl:with-param>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="pi-formatter">
    <xsl:call-template name="pi-attribute">
      <xsl:with-param name="pis" select="."/>
      <xsl:with-param name="attribute">formatter</xsl:with-param>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="matching-style">
    <xsl:choose>
      <xsl:when test="$pi-style = '' or $pi-style = 'any' or
                      $pi-style = $STYLE.ID">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="matching-formatter">
    <xsl:choose>
      <xsl:when test="$pi-formatter = '' or $pi-formatter = 'any' or
                      ($pi-formatter = 'fop' and $fop1.extensions = 1) or
                      ($pi-formatter = 'xep' and $xep.extensions = 1)">
        <xsl:text>1</xsl:text>
      </xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:if test="$matching-formatter = 1 and $matching-style = 1">
      <xsl:message>Creating a manual page break.</xsl:message>
      <xsl:if test="$pi-style = ''">
        <xsl:message>(!) Use style="<xsl:value-of select="$STYLE.ID"/>" to limit this page break to these stylesheets.</xsl:message>
      </xsl:if>
      <xsl:if test="$pi-formatter = ''">
        <xsl:message>(!) Use formatter="<xsl:choose>
            <xsl:when test="$fop1.extensions = 1">fop</xsl:when>
            <xsl:when test="$xep.extensions = 1">xep</xsl:when>
            <xsl:otherwise>???</xsl:otherwise>
          </xsl:choose>" to limit this page break to this formatter.</xsl:message>
      </xsl:if>
      <fo:block page-break-after="always"/>
  </xsl:if>
</xsl:template>

<xsl:template match="d:formalpara/d:title|d:formalpara/d:info/d:title">
  <xsl:variable name="title-str">
    <xsl:apply-templates/>
  </xsl:variable>
  <!-- Logic: If there is already a &punctuation; character at the end, we don't
       need to add another one, $last-char allows us to check. -->
  <xsl:variable name="last-char-candidate">
    <xsl:choose>
      <xsl:when test="$title-str != ''">
        <xsl:value-of select="substring($title-str,string-length($title-str),1)"/>
      </xsl:when>
      <xsl:otherwise>FAIL</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="last-char">
    <xsl:value-of select="translate($last-char-candidate, '&punctuation;', '')"/>
  </xsl:variable>

  <xsl:if test="$title-str != ''">
    <fo:inline keep-with-next.within-line="always"
      padding-end="0.2em"
      xsl:use-attribute-sets="variablelist.term.properties">
      <xsl:copy-of select="$title-str"/>
      <xsl:if test="$last-char != ''
                    and not(contains($runinhead.title.end.punct, $last-char))">
        <xsl:call-template name="gentext">
          <xsl:with-param name="key">runinhead.default.title.end.punct</xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <fo:leader leader-pattern="space" leader-length=".3em"/>
    </fo:inline>
  </xsl:if>
</xsl:template>

<!-- Match only all last nodes inside titles which are not element nodes -->
<xsl:template match="d:formalpara/d:title/node()[last()][not(self::*)]">
   <xsl:call-template name="trim-verbatim-whitespace-end">
    <xsl:with-param name="input" select="."/>
   </xsl:call-template>
</xsl:template>


<xsl:template name="arch-arrows">
  <!-- It's enough to have one input param to determine both whether we want a
       start or end arrow and what the arrow should say, as end arrows do not
       contain text. -->
  <xsl:param name="arch-value" select="''"/>

  <xsl:if test="$para.use.arch = 1">
    <xsl:choose>
      <xsl:when test="$arch-value != ''">
        <xsl:variable name="arch-string">
          <xsl:call-template name="readable.arch.string">
            <xsl:with-param name="input" select="$arch-value"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="instream-font-size" select="70 div 4.54"/>
        <xsl:variable name="font-metrics-ratio" select="&mono-ratio;"/>
          <!-- Only use a monospaced font for the arch-string, else this metrics-ratio
               won't work out all that well – it is used for determining the
               width of the arrow image being shown. -->
        <xsl:variable name="width"
          select="string-length(normalize-space($arch-string)) *
                  $instream-font-size * $font-metrics-ratio"/>
        <xsl:variable name="text-start">
          <xsl:choose>
            <xsl:when test="$writing.mode = 'rl'">16</xsl:when>
            <xsl:otherwise>7</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <fo:instream-foreign-object content-height="1em"
          alignment-baseline="alphabetic" alignment-adjust="-0.2em"
          keep-with-next.within-line="always">
          <svg:svg width="{$width + 23}" height="22">
            <svg:g>
              <xsl:if test="$writing.mode = 'rl'">
                <xsl:attribute name="transform">matrix(-1,0,0,1,<xsl:value-of select="$width + 23"/>,0)</xsl:attribute>
              </xsl:if>
              <svg:path d="m 2.5,0.5 c -1.108,0 -2,0.851 -2,1.909 l 0,17.181 c 0,1.058 0.892,1.909 2,1.909 l {$width + 8},0 c 0.693,0 1.22,-0.348 1.656,-0.835 l 8.751,-8.322 c 0.784,-0.748 0.784,-1.937 0,-2.685 L {$width + 12.161},1.336 C {$width + 11.747},0.889 {$width + 11.197},0.5 {$width + 10.505},0.5 z"
                 stroke-width="2" stroke="{$dark-green}" fill="&white;"/>
            </svg:g>
            <svg:text font-family="{$mono-stack}" text-anchor="start"
              x="{$text-start}" y="{$instream-font-size + 1.5}" fill="{$dark-green}" font-weight="bold"
              font-size="{$instream-font-size}"><xsl:value-of select="$arch-string"/></svg:text>
          </svg:svg>
        </fo:instream-foreign-object>
        <fo:leader leader-pattern="space" leader-length="0.1em"
          keep-with-next.within-line="always"/>
      </xsl:when>
      <xsl:otherwise>
        <fo:leader leader-pattern="space" leader-length="0.1em"
          keep-with-previous.within-line="always"/>
        <fo:instream-foreign-object content-height="1em"
          alignment-baseline="alphabetic" alignment-adjust="-0.2em"
          keep-with-previous.within-line="always">
          <svg:svg width="25" height="22">
            <svg:g>
              <xsl:if test="$writing.mode = 'rl'">
                <xsl:attribute name="transform">matrix(-1,0,0,1,25,0)</xsl:attribute>
              </xsl:if>
              <svg:path d="m 21.50025,0.501 c 1.108,0 2,0.851 2,1.909 l 0,17.181 c 0,1.057 -0.892,1.909 -2,1.909 l -10,0 c -0.693,0 -1.22,-0.347 -1.656,-0.835 l -8.751,-8.322 c -0.783,-0.748 -0.783,-1.937 0,-2.685 l 8.751,-8.322 c 0.414,-0.447 0.964,-0.836 1.656,-0.836 z"
                 stroke-width="2" stroke="{$dark-green}" fill="&white;"/>
            </svg:g>
          </svg:svg>
        </fo:instream-foreign-object>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>


<!-- Add special handling for arch attribute + colon as the final character. -->
<xsl:template match="d:para">
  <xsl:variable name="keep.together">
    <xsl:call-template name="pi.dbfo_keep-together"/>
  </xsl:variable>
  <xsl:variable name="content">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:variable>
  <!-- We need only one final character, but there may be
       something in the way, like a space that wasn't removed or so. -->
  <xsl:variable name="final-characters"
    select="substring($content, string-length($content) - 2, string-length($content))"/>

  <fo:block xsl:use-attribute-sets="para.properties">
    <xsl:if test="$keep.together != ''">
      <xsl:attribute name="keep-together.within-column"><xsl:value-of
                      select="$keep.together"/></xsl:attribute>
    </xsl:if>
    <xsl:call-template name="no-break-after-colon"/>

    <xsl:call-template name="anchor"/>

    <xsl:if test="@arch != ''">
      <xsl:call-template name="arch-arrows">
        <xsl:with-param name="arch-value" select="@arch"/>
      </xsl:call-template>
    </xsl:if>

    <xsl:apply-templates/>

    <xsl:if test="@arch != ''">
      <xsl:call-template name="arch-arrows"/>
    </xsl:if>
  </fo:block>
</xsl:template>

<xsl:template match="d:formalpara/d:para">
  <xsl:variable name="keep.together">
    <xsl:call-template name="pi.dbfo_keep-together"/>
  </xsl:variable>

  <fo:inline>
    <xsl:if test="@arch != ''">
      <xsl:call-template name="arch-arrows">
        <xsl:with-param name="arch-value" select="@arch"/>
      </xsl:call-template>
    </xsl:if>

    <xsl:apply-templates/>

    <xsl:if test="@arch != ''">
      <xsl:call-template name="arch-arrows"/>
    </xsl:if>
  </fo:inline>
</xsl:template>

  <!-- If the last sentence ends of a para ends in :, there is probably a list
       or an example that needs to be kept close to the paragraph.
       What if there is no final punctuation? Not handling that case now. -->
<xsl:template name="no-break-after-colon">
  <xsl:param name="content">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:param>
  <!-- We need only one final character, but there may be
       something in the way, like a space that wasn't removed or so. -->
  <xsl:variable name="final-characters"
    select="substring($content, string-length($content) - 2, string-length($content))"/>


  <xsl:if test="contains($final-characters, ':') and
                following-sibling::*">
    <xsl:attribute name="keep-with-next.within-page">always</xsl:attribute>
  </xsl:if>
</xsl:template>

<xsl:template match="d:para[normalize-space(.)='' and not(*)]"/>

</xsl:stylesheet>

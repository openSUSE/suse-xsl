<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Re-Style admonitions

  Author(s):  Stefan Knorr <sknorr@suse.de>,
              Thomas Schraitle <toms@opensuse.org>

  Copyright:  2013, Stefan Knorr, Thomas Schraitle

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
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:svg="http://www.w3.org/2000/svg"
  xmlns:date="http://exslt.org/dates-and-times"
  exclude-result-prefixes="date d">


<xsl:template match="d:note|d:important|d:warning|d:caution|d:tip">
  <xsl:call-template name="graphical.admonition"/>
</xsl:template>

<xsl:template name="admon.symbol">
  <xsl:param name="color" select="'&dark-green;'"/>
  <xsl:param name="node" select="."/>

  <!-- Hierarchy of admonition symbols:
  https://en.wikipedia.org/wiki/Precautionary_statement
  DocBook (currently) does not support "danger," but on the other hand has
  both "note" and "tip" at the lowest end. -->
  <svg:svg width="36" height="36">
    <svg:g>
      <xsl:if test="$writing.mode = 'rl'">
        <xsl:attribute name="transform">matrix(-1,0,0,1,36,0)</xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="local-name($node)='warning'">
            <svg:path d="M 18,0 C 8.06,0 0,8.06 0,18 0,27.94 8.06,36 18,36 27.94,36 36,27.94 36,18 36,8.06 27.94,0 18,0 z m 0,7 c 0.62,0 1,0.51 1,1.13 l 0,9.88 1,0 0,-8.53 c 0,-0.62 0.38,-1.13 1,-1.13 0.62,0 1,0.51 1,1.13 L 22,22 l 1,0 0,-4.78 c 0,-0.62 0.29,-1.13 0.91,-1.13 0.62,0 1.09,0.17 1.09,1.13 L 25,22.5 c -8.8e-4,3.6 -3.41,6.5 -7,6.5 -3.59,-9e-4 -7,-2.92 -7,-5.84 l 0,-9.31 c 0,-0.96 0.38,-1.47 1,-1.47 0.62,0 1,0.51 1,1.13 l 0,5.5 1,0 0,-9.53 c -2e-5,-0.62 0.38,-1.13 1,-1.13 0.62,0 1,0.5 1,1.13 L 16,18 17,18 17,8.13 C 17.04,7.51 17.38,7 18,7 z"
              fill="{$color}"/>
        </xsl:when>
        <xsl:when test="local-name($node)='tip'">
            <svg:path d="M 18,0 C 8.06,0 0,8.06 0,18 0,27.94 8.06,36 18,36 27.94,36 36,27.94 36,18 36,8.06 27.94,0 18,0 z m 0,4.75 c 4.62,0 8.43,3.69 8.38,8.31 -0.052,4.47 -3.11,6.6 -4.19,11.56 l -8.03,2.19 C 14.12,26.35 14.07,25.92 14,25.5 l 4.5,-1.25 -4.78,0 C 12.57,19.55 9.7,17.4 9.66,13.06 9.6,8.44 13.38,4.75 18,4.75 z m -0.88,8.56 -0.41,0.72 -1.97,0 c -1.18,0 -1.39,0.28 -1.19,1 l 1.94,7 c 0.073,0.24 0.31,0.38 0.5,0.38 0.29,0 0.54,-0.16 0.53,-0.5 l -1.88,-6.88 1.47,0 c -0.14,0.24 -0.068,0.58 0.19,0.69 0.47,0.2 0.54,-0.07 0.78,-0.31 0.03,0.12 0.09,0.26 0.22,0.31 0.48,0.19 0.54,-0.07 0.78,-0.31 0.03,0.12 0.11,0.3 0.25,0.34 0.52,0.14 0.51,0.04 0.94,-0.72 l 2.06,0 -1.88,6.88 c 0,0.33 0.25,0.49 0.53,0.5 0.28,0.01 0.45,-0.2 0.5,-0.38 l 1.94,-7 c 0.2,-0.72 0,-1 -1.19,-1 l -1.38,0 C 20.17,13.52 20.12,13.21 19.81,13.13 19.41,13.02 19.27,13.23 19.03,13.47 19.01,13.33 18.96,13.18 18.81,13.13 18.39,12.96 18.27,13.21 18.03,13.47 18.01,13.33 17.97,13.22 17.81,13.13 17.54,12.96 17.24,13.11 17.13,13.31 z M 22,25.69 c -0.07,0.47 -0.1,0.1 -0.13,1.5 l -7.5,2.06 C 14.23,28.75 14.21,28.29 14.19,27.81 z M 21.81,28.25 c 0.029,0.62 -0.18,1.19 -0.44,1.63 l -5.19,1.38 c -0.53,-0.27 -0.99,-0.65 -1.34,-1.13 z"
              fill="{$color}"/>
        </xsl:when>
        <!-- The symbol for these two is currently the same, however,
        important is orange &amp; caution is red. -->
        <xsl:when test="local-name($node)='important' or local-name($node)='caution'">
            <svg:path d="M 18,0 C 8,0 0,8 0,18 0,28 8,36 18,36 28,36 36,28 36,18 36,8 28,0 18,0 z m -2.5,7 5.125,0 -0.75,14.5 -3.625,0 L 15.5,7 z M 18,24 c 0.8,0 1.5,0.25 1.9,0.625 0.45,0.45 0.65,1 0.65,1.9 -10e-6,0.75 -0.25,1.4 -0.65,1.85 C 19.45,28.75 18.8,29 18,29 17.15,29 16.55,28.75 16.1,28.35 15.65,27.9 15.4,27.3 15.4,26.5 c 0,-0.83 0.25,-1.45 0.65,-1.85 C 16.55,24.2 17.15,24 18,24 z"
              fill="{$color}"/>
        </xsl:when>
        <xsl:otherwise>
          <!-- It's a note. (Or something undefined.) -->
            <svg:path d="M 18,0 C 8.061,0 0,8.058 0,18 0,27.94 8.061,36 18,36 27.942,36 36,27.94 36,18 36,8.058 27.942,0 18,0 z m -3.5,5.125 c 0.266,1.75e-4 0.512,0.0745 0.688,0.25 l 12,12 0.7188,8.625 c -6e-5,0.511 -0.172,1.047 -0.563,1.438 -0.39,0.39 -0.928,0.605 -1.438,0.563 l -8.625,-0.719 -12,-12 c -0.391,-0.391 -0.391,-1.016 0,-1.406 0.383,-0.383 1.03,-0.408 1.438,0 L 18.125,25.313 25.906,26 25.188,18.219 14.5,7.5 l -4.25,4.25 8.813,8.813 1.906,0.5 -0.531,-1.938 -7.375,-7.375 1.438,-1.406 7.75,7.75 0.844,3.063 c 8.9e-5,0.511 -0.204,1.047 -0.594,1.438 -0.39,0.39 -0.895,0.532 -1.406,0.531 L 18,22.344 8.125,12.469 c -0.39,-0.39 -0.39,-1.047 0,-1.438 L 13.781,5.375 C 13.958,5.199 14.234,5.125 14.5,5.125 z"
              fill="{$color}"/>
        </xsl:otherwise>
      </xsl:choose>
    </svg:g>
  </svg:svg>
</xsl:template>

<xsl:template name="admon.symbol.color">
  <xsl:param name="node" select="."/>
  <xsl:choose>
    <xsl:when test="$format.print = 1">
      <xsl:text>&darker-gray;</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="local-name($node)='warning' or
                        local-name($node)='caution'">
          <!-- The symbol for these two is currently the same -->
          <xsl:text>&dark-blood;</xsl:text>
        </xsl:when>
        <xsl:when test="local-name($node)='tip'">
          <xsl:text>&dark-green;</xsl:text>
        </xsl:when>
        <xsl:when test="local-name($node)='important'">
          <xsl:text>&mid-orange;</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <!-- It's a note. (Or something undefined.) -->
          <xsl:text>&darker-gray;</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="compact.or.normal.block">
 <xsl:variable name="color">
  <xsl:call-template name="admon.symbol.color"/>
 </xsl:variable>
 <fo:block>
  <xsl:attribute name="color">
   <xsl:choose>
    <xsl:when test="not(@role = 'compact')">
     <xsl:value-of select="$color"/>
    </xsl:when>
    <xsl:otherwise>&darker-gray;</xsl:otherwise>
   </xsl:choose>
  </xsl:attribute>
  <xsl:value-of select="@role"/>
  <xsl:apply-templates select="." mode="object.title.markup">
   <xsl:with-param name="allow-anchors" select="1"/>
  </xsl:apply-templates>
 </fo:block>
</xsl:template>

<xsl:template name="graphical.admonition">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>
  <xsl:variable name="color">
   <xsl:call-template name="admon.symbol.color"/>
  </xsl:variable>
  <xsl:variable name="graphic.width">
    <xsl:choose>
      <xsl:when test="@role='compact'">5</xsl:when>
      <xsl:otherwise>8</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="padding">
    <xsl:choose>
      <xsl:when test="@role='compact'">0.7mm</xsl:when>
      <xsl:otherwise>3mm</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <fo:block id="{$id}" xsl:use-attribute-sets="graphical.admonition.properties">
    <fo:list-block
      provisional-distance-between-starts="{&columnfragment; + &gutterfragment;}mm"
      provisional-label-separation="&gutter;mm">
      <fo:list-item>
          <fo:list-item-label end-indent="label-end()">
            <fo:block text-align="start" padding-before="1.2mm" padding-after="1.2mm">
              <fo:instream-foreign-object content-width="{$graphic.width}mm">
                <xsl:call-template name="admon.symbol">
                  <xsl:with-param name="color" select="$color"/>
                </xsl:call-template>
              </fo:instream-foreign-object>
            </fo:block>
          </fo:list-item-label>
          <fo:list-item-body start-indent="body-start()">
            <fo:block padding-start="{(&gutter; - 0.75) div 2}mm"
              padding-before="{$padding}" padding-after="{$padding}">
              <xsl:if test="((d:title or d:info/d:title) or ($admon.textlabel != 0 and not(@role='compact')))">
                <xsl:choose>
                 <xsl:when test="@role='compact'">
                  <fo:block
                   xsl:use-attribute-sets="admonition.title.properties admonition.compact.title.properties">
                   <xsl:call-template name="compact.or.normal.block"/>
                  </fo:block>
                 </xsl:when>
                 <xsl:otherwise>
                  <fo:block xsl:use-attribute-sets="admonition.title.properties admonition.normal.title.properties">
                   <xsl:call-template name="compact.or.normal.block"/>
                  </fo:block>
                 </xsl:otherwise>
                </xsl:choose>
              </xsl:if>
              <fo:block xsl:use-attribute-sets="admonition.properties">
                <xsl:apply-templates/>
              </fo:block>
            </fo:block>
          </fo:list-item-body>
      </fo:list-item>
    </fo:list-block>
  </fo:block>
</xsl:template>

</xsl:stylesheet>

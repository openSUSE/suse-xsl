<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Restyle qandasets, etc.

  Author(s):  Stefan Knorr <sknorr@suse.de>

  Copyright:  2014, Stefan Knorr, Thomas Schraitle

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
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  exclude-result-prefixes="exsl">

<xsl:template match="question">
  <xsl:variable name="id"><xsl:call-template name="object.id"/></xsl:variable>

  <xsl:variable name="entry.id">
    <xsl:call-template name="object.id">
      <xsl:with-param name="object" select="parent::*"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="deflabel">
    <xsl:apply-templates select="." mode="qanda.defaultlabel"/>
  </xsl:variable>

  <xsl:variable name="label.content">
    <xsl:apply-templates select="." mode="label.markup"/>
    <xsl:if test="contains($deflabel, 'number') and not(label)">
      <xsl:apply-templates select="." mode="intralabel.punctuation"/>
    </xsl:if>
  </xsl:variable>

  <!-- changes v/ upstream: added font-family, font-size and
  keep-with-next.within-column attributes. -->
  <fo:list-item role="{local-name()}" id="{$entry.id}"
   xsl:use-attribute-sets="list.item.spacing"
   keep-with-next.within-column="always">
    <fo:list-item-label id="{$id}" end-indent="label-end()">
      <xsl:choose>
        <xsl:when test="string-length($label.content) &gt; 0">
         <fo:block xsl:use-attribute-sets="sans.bold.noreplacement dark-green"
                   font-family="{$sans-stack}"
                   font-size="{concat($sans-xheight-adjust, 'em')}">
            <xsl:copy-of select="$label.content"/>
          </fo:block>
        </xsl:when>
        <xsl:otherwise>
          <fo:block/>
        </xsl:otherwise>
      </xsl:choose>
    </fo:list-item-label>
    <fo:list-item-body start-indent="body-start()">
      <xsl:choose>
        <xsl:when test="$deflabel = 'none' and not(label)">
          <fo:block>
            <xsl:apply-templates select="*[local-name(.)!='label']"/>
          </fo:block>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="*[local-name(.)!='label']"/>
        </xsl:otherwise>
      </xsl:choose>
      <!-- Uncomment this line to get revhistory output in the question -->
      <!-- <xsl:apply-templates select="preceding-sibling::revhistory"/> -->
    </fo:list-item-body>
  </fo:list-item>
</xsl:template>


<xsl:template match="question/para">
 <fo:block xsl:use-attribute-sets="italicized"
           font-family="{$sans-stack}"
           font-size="{concat($sans-xheight-adjust, 'em')}">
  <xsl:apply-templates/>
 </fo:block>
</xsl:template>


<xsl:template name="qanda.heading">
  <xsl:param name="level" select="1"/>
  <xsl:param name="marker" select="0"/>
  <xsl:param name="title"/>
  <xsl:param name="titleabbrev"/>

  <!--<xsl:message>***** qanda.heading: <xsl:value-of select="concat(local-name(..), '/', local-name())"/>
    level=<xsl:value-of select="$level"/>
  </xsl:message>-->

  <fo:block xsl:use-attribute-sets="qanda.title.properties">
    <xsl:if test="$marker != 0">
      <fo:marker marker-class-name="section.head.marker">
        <xsl:choose>
          <xsl:when test="$titleabbrev = ''">
            <xsl:value-of select="$title"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$titleabbrev"/>
          </xsl:otherwise>
        </xsl:choose>
      </fo:marker>
      <!-- Add this specialty section marker. Apart from that the template is
           the same as the upstream one. -->
      <fo:marker marker-class-name="section.head.marker.short">
        <xsl:choose>
          <xsl:when test="$titleabbrev = ''">
            <xsl:call-template name="shorten-section-markers">
              <xsl:with-param name="title" select="$title"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="shorten-section-markers">
              <xsl:with-param name="title" select="$titleabbrev"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </fo:marker>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="$level=1">
        <fo:block xsl:use-attribute-sets="qanda.title.level1.properties">
          <xsl:call-template name="title.split">
            <xsl:with-param name="node" select=".."/>
          </xsl:call-template>
        </fo:block>
      </xsl:when>
      <xsl:when test="$level=2">
        <fo:block xsl:use-attribute-sets="qanda.title.level2.properties">
          <xsl:call-template name="title.split">
            <xsl:with-param name="node" select=".."/>
          </xsl:call-template>
        </fo:block>
      </xsl:when>
      <xsl:when test="$level=3">
        <fo:block xsl:use-attribute-sets="qanda.title.level3.properties">
          <xsl:call-template name="title.split">
            <xsl:with-param name="node" select=".."/>
          </xsl:call-template>
        </fo:block>
      </xsl:when>
      <xsl:when test="$level=4">
        <fo:block xsl:use-attribute-sets="qanda.title.level4.properties">
          <xsl:call-template name="title.split">
            <xsl:with-param name="node" select=".."/>
          </xsl:call-template>
        </fo:block>
      </xsl:when>
      <xsl:when test="$level=5">
        <fo:block xsl:use-attribute-sets="qanda.title.level5.properties">
          <xsl:call-template name="title.split">
            <xsl:with-param name="node" select=".."/>
          </xsl:call-template>
        </fo:block>
      </xsl:when>
      <xsl:otherwise>
        <fo:block xsl:use-attribute-sets="qanda.title.level6.properties">
          <xsl:call-template name="title.split">
            <xsl:with-param name="node" select=".."/>
          </xsl:call-template>
        </fo:block>
      </xsl:otherwise>
    </xsl:choose>
  </fo:block>
</xsl:template>

</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Transform DocBook's task element and its children

  Author:     Thomas Schraitle <toms@opensuse.org>,
              Stefan Knorr <sknorr@suse.de>
  Copyright:  2017

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
 xmlns:fo="http://www.w3.org/1999/XSL/Format">

  <xsl:template match="task">
  <xsl:variable name="id">
    <xsl:call-template name="object.id"/>
  </xsl:variable>
   <xsl:variable name="preamble"
                select="*[not(self::title or self::titleabbrev)]"/>

  <fo:block id="{$id}" xsl:use-attribute-sets="task.properties">
   <xsl:if test="(title or info/title)">
    <fo:block xsl:use-attribute-sets="task.title.spacing" keep-with-next.within-column="always">
     <xsl:call-template name="formal.object.heading"/>
    </fo:block>
   </xsl:if>
   <fo:block>
    <xsl:attribute name="margin-{$start-border}"><xsl:value-of select="&mediumline;"/>mm</xsl:attribute>
    <xsl:attribute name="padding-{$start-border}"><xsl:value-of select="2* &mediumline;"/>mm</xsl:attribute>
    <xsl:attribute name="border-{$start-border}">
     <xsl:text>&mediumline;mm solid </xsl:text>
     <xsl:choose>
      <xsl:when test="$format.print != 0">
       <xsl:text>&dark-gray;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
       <xsl:text>&dark-green;</xsl:text>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:attribute>
    <xsl:apply-templates select="$preamble"/>
   </fo:block>
  </fo:block>
  </xsl:template>

 <xsl:template match="tasksummary">
  <fo:block xsl:use-attribute-sets="tasksummary.properties">
   <xsl:apply-templates/>
  </fo:block>
 </xsl:template>

 <xsl:template match="taskprerequisites|taskrelated">
  <fo:block>
   <fo:block xsl:use-attribute-sets="task.children.title.properties" keep-with-next.within-column="always">
    <xsl:call-template name="gentext">
     <xsl:with-param name="key" select="local-name(.)"/>
    </xsl:call-template>
   </fo:block>
   <xsl:apply-templates/>
  </fo:block>
 </xsl:template>


<!-- <xsl:template match="tasksummary/para[1]|taskprerequisites/para[1]|taskrelated/para[1]">
  <fo:block>
   <xsl:apply-templates/>
  </fo:block>
 </xsl:template>-->

</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Transform DocBook's task element and its children

  Author:     Thomas Schraitle <toms@opensuse.org>,
              Stefan Knorr <sknorr@suse.de>
  Copyright:  2017

-->

<xsl:stylesheet version="1.0"
 xmlns="http://www.w3.org/1999/xhtml"
 xmlns:exsl="http://exslt.org/common"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 exclude-result-prefixes="exsl">
 
 <xsl:template match="task">
  <xsl:variable name="preamble"
                select="*[not(self::title or self::titleabbrev)]"/>
  <div>
   <xsl:call-template name="common.html.attributes"/>
   <xsl:call-template name="id.attribute">
    <xsl:with-param name="conditional">
     <xsl:choose>
      <xsl:when test="title">0</xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
     </xsl:choose>
    </xsl:with-param>
   </xsl:call-template>
   <xsl:if test="(title or info/title)">
    <xsl:call-template name="formal.object.heading"/>
   </xsl:if>
   <div class="task-contents">
    <xsl:apply-templates select="$preamble"/>
   </div>
  </div>
 </xsl:template>

 <xsl:template match="taskprerequisites|taskrelated">
  <div class="{local-name(.)}">
   <h6 class="task-title name">
    <xsl:call-template name="gentext">
     <xsl:with-param name="key" select="local-name(.)"/>
    </xsl:call-template>
   </h6>
   <xsl:apply-templates/>
  </div>
 </xsl:template>
 
  <xsl:template match="tasksummary">
  <div class="{local-name(.)}">
   <xsl:apply-templates/>
  </div>
 </xsl:template>

</xsl:stylesheet>
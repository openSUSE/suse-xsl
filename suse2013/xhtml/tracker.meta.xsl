<?xml version="1.0" encoding="UTF-8"?>
<!-- 
   Purpose:
     Transform DocManager elements into (X)HTML <meta/> tags to pass 
     information to create a "Report Bug" link

   Parameters:
     None

   Input:
     DocBook 5

   Output:
     HTML <meta/> tags

   See Also:
      * https://github.com/openSUSE/suse-xsl/issues/36
      * https://github.com/openSUSE/docmanager/issues/56

   Authors:    Thomas Schraitle
   Copyright:  2015, Thomas Schraitle

-->

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dm="urn:x-suse:ns:docmanager"
    xmlns:exsl="http://exslt.org/common"
    xmlns:date="http://exslt.org/dates-and-times"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="exsl date dm">
  
  
  <xsl:template name="create.tracker.meta">
    <xsl:param name="node" select="."/>
    <xsl:variable name="all.dm.nodes" select="ancestor-or-self::*/*/dm:docmanager"/>
    <xsl:variable name="bugtracker" select="$all.dm.nodes/dm:bugtracker"/>
    
    <xsl:variable name="tracker.url" select="($bugtracker/dm:url[normalize-space(.) != ''])[last()]"/>
    <xsl:variable name="tracker.type">
      <xsl:choose>
        <xsl:when test="contains($tracker.url, 'bugzilla.suse')">bsc</xsl:when>
        <xsl:when test="contains($tracker.url, 'github')">gh</xsl:when>
        <xsl:otherwise>unknown</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="tracker.assignee" select="($bugtracker/dm:assignee[normalize-space(.) != ''])[last()]"/>
    <xsl:variable name="tracker.component" select="($bugtracker/dm:component[normalize-space(.) != ''])[last()]"/>
    <xsl:variable name="tracker.product" select="($bugtracker/dm:product[normalize-space(.) != ''])[last()]"/>
    <xsl:variable name="tracker.version" select="($bugtracker/dm:version[normalize-space(.) != ''])[last()]"/>
    

    <xsl:message>Tracker: node=<xsl:value-of select="local-name($node)"/>
      len(all.dm.nodes) = <xsl:value-of select="count($all.dm.nodes)"/>
      tracker.url = <xsl:value-of select="$tracker.url"/>
      tracker.type = <xsl:value-of select="$tracker.type"/>
      tracker.assignee = <xsl:value-of select="$tracker.assignee"/>
      tracker.component = <xsl:value-of select="$tracker.component"/>
      tracker.product = <xsl:value-of select="$tracker.product"/>
      tracker.version = <xsl:value-of select="$tracker.version"/>
    </xsl:message>

    
    <xsl:text>&#10;</xsl:text>
    <xsl:comment> Tracker </xsl:comment>

    <xsl:choose>
      <xsl:when test="$tracker.url">
        <meta name="tracker-url" content="{$tracker.url}"/>
        <meta name="tracker-type" content="{$tracker.type}"/>

        <xsl:if test="$tracker.assignee">
          <meta name="tracker-{$tracker.type}-assignee" content="{$tracker.assignee}"/>
        </xsl:if>

        <xsl:if test="$tracker.type = 'bsc'">
          <xsl:if test="$tracker.component">
            <meta name="tracker-bsc-component" content="{$tracker.component}"/>
          </xsl:if>
          <xsl:if test="$tracker.product">
            <meta name="tracker-bsc-product" content="{$tracker.product}"/>
          </xsl:if>
        </xsl:if>

        <xsl:if test="$tracker.version">
          <meta name="tracker-{$tracker.type}-version" content="{$tracker.version}"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="log.message">
          <xsl:with-param name="level">WARNING</xsl:with-param>
          <xsl:with-param name="context-desc">tracker</xsl:with-param>
          <!--<xsl:with-param name="context-desc-field-length" select="8"/>-->
          <xsl:with-param name="message">
            <xsl:text>Tracker URL in dm:docmanager/dm:bugtracker/dm:url not found. </xsl:text>
            <xsl:text>Check if there is an dm:url available inside set?</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:comment> /Tracker </xsl:comment>
  </xsl:template>
  
</xsl:stylesheet>
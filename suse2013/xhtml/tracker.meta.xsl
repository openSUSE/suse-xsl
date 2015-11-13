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


  <xsl:template name="create.bugtracker.information">
    <xsl:param name="node" select="."/>

    <!-- Check for the proper DocBook 5/DocManager elements. -->
    <xsl:variable name="bugtracker-docmanager" select="ancestor-or-self::*/*/dm:docmanager/dm:bugtracker"/>
    <xsl:variable name="bugtracker-docmanager-value"><xsl:value-of select="ancestor-or-self::*/*/dm:docmanager/dm:bugtracker"/></xsl:variable>
    <!-- Check for fallback version via processing instruction. -->
    <xsl:variable name="bugtracker-pi" select="ancestor-or-self::*/*/processing-instruction('suse-bugtracker')"/>
    <xsl:variable name="bugtracker-pi-value"><xsl:value-of select="ancestor-or-self::*/*/processing-instruction('suse-bugtracker')"/></xsl:variable>

    <xsl:message>DocMan |<xsl:value-of select="$bugtracker-docmanager"/>|</xsl:message>
    <xsl:message>PI     |<xsl:value-of select="$bugtracker-pi"/>|</xsl:message>
    <xsl:choose>
      <xsl:when test="$bugtracker-docmanager-value != ''">
        <xsl:message>+docm |<xsl:value-of select="$bugtracker-pi"/>|</xsl:message>
        <xsl:call-template name="create.docmanager.bugtracker">
          <xsl:with-param name="bugtracker" select="$bugtracker-docmanager"/>
          <xsl:with-param name="bugtracker-value" select="$bugtracker-docmanager-value"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$bugtracker-pi-value != ''">
        <xsl:message>+pi   |<xsl:value-of select="$bugtracker-pi"/>|</xsl:message>
        <xsl:call-template name="create.pi.bugtracker">
          <!-- Unfortunately, this behaviour is inconsistent with the DocManager
               version: Whereas the DocManager version always searches through
               all the relevant dm:bugtracker/dm:xy elements to find one that
               has content, with the PI version, you always need to have all
               necessary attributes in the same PI, because traversing the tree
               for PIs is less simple. -->
          <xsl:with-param name="bugtracker-pi" select="$bugtracker-pi[last()]"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="create.docmanager.bugtracker">
    <xsl:param name="bugtracker" select="''"/>
    <xsl:param name="bugtracker-value" select="''"/>

    <xsl:if test="$bugtracker = ''">
      <xsl:message>Bug Tracker integration (DocManager): Got an empty bugtracker variable.</xsl:message>
    </xsl:if>
    <xsl:message>+ |<xsl:value-of select="$bugtracker-value"/>|</xsl:message>

    <xsl:call-template name="create.bugtracker.meta">
      <xsl:with-param name="url-candidate" select="($bugtracker/dm:url[normalize-space(.) != ''])[last()]"/>
      <xsl:with-param name="assignee-candidate" select="($bugtracker/dm:assignee[normalize-space(.) != ''])[last()]"/>
      <xsl:with-param name="component-candidate" select="($bugtracker/dm:component[normalize-space(.) != ''])[last()]"/>
      <xsl:with-param name="product-candidate" select="($bugtracker/dm:product[normalize-space(.) != ''])[last()]"/>
      <xsl:with-param name="version-candidate" select="($bugtracker/dm:version[normalize-space(.) != ''])[last()]"/>
      <xsl:with-param name="labels-candidate" select="($bugtracker/dm:version[normalize-space(.) != ''])[last()]"/>
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="create.pi.bugtracker">
    <xsl:param name="bugtracker" select="''"/>

    <xsl:variable name="url">
      <xsl:call-template name="pi-attribute">
        <xsl:with-param name="pis" select="$bugtracker"/>
        <xsl:with-param name="attribute" select="'url'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="assignee">
      <xsl:call-template name="pi-attribute">
        <xsl:with-param name="pis" select="$bugtracker"/>
        <xsl:with-param name="attribute" select="'assignee'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="component">
      <xsl:call-template name="pi-attribute">
        <xsl:with-param name="pis" select="$bugtracker"/>
        <xsl:with-param name="attribute" select="'component'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="product">
      <xsl:call-template name="pi-attribute">
        <xsl:with-param name="pis" select="$bugtracker"/>
        <xsl:with-param name="attribute" select="'product'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="version">
      <xsl:call-template name="pi-attribute">
        <xsl:with-param name="pis" select="$bugtracker"/>
        <xsl:with-param name="attribute" select="'version'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="labels">
      <xsl:call-template name="pi-attribute">
        <xsl:with-param name="pis" select="$bugtracker"/>
        <xsl:with-param name="attribute" select="'labels'"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:if test="$bugtracker = ''">
      <xsl:message>Bug Tracker integration (PI): Got an empty bugtracker variable.</xsl:message>
    </xsl:if>

    <xsl:call-template name="create.bugtracker.meta">
      <xsl:with-param name="url-candidate" select="$url"/>
      <xsl:with-param name="assignee-candidate" select="$assignee"/>
      <xsl:with-param name="component-candidate" select="$component"/>
      <xsl:with-param name="product-candidate" select="$product"/>
      <xsl:with-param name="version-candidate" select="$version"/>
      <xsl:with-param name="labels-candidate" select="$labels"/>
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="create.bugtracker.meta">
    <xsl:param name="url-candidate" select="''"/>
    <xsl:param name="assignee-candidate" select="''"/>
    <xsl:param name="component-candidate" select="''"/>
    <xsl:param name="product-candidate" select="''"/>
    <xsl:param name="version-candidate" select="''"/>
    <xsl:param name="labels-candidate" select="''"/>

    <xsl:variable name="url" select="normalize-space($url-candidate)"/>
    <xsl:variable name="assignee" select="normalize-space($assignee-candidate)"/>
    <xsl:variable name="component" select="normalize-space($component-candidate)"/>
    <xsl:variable name="product" select="normalize-space($product-candidate)"/>
    <xsl:variable name="version" select="normalize-space($version-candidate)"/>
    <xsl:variable name="labels" select="normalize-space($labels-candidate)"/>

    <xsl:variable name="type">
      <xsl:choose>
        <xsl:when test="contains($url, 'bugzilla.suse.com') or
                        contains($url, 'bugzilla.novell.com')">bsc</xsl:when>
        <xsl:when test="contains($url, 'github.com')">gh</xsl:when>
        <xsl:otherwise>unknown</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:message>Bug Tracker integration:
      node      <xsl:value-of select="local-name(.)"/>
      url       |<xsl:value-of select="$url"/>|
      type      |<xsl:value-of select="$type"/>|
      assignee  |<xsl:value-of select="$assignee"/>|
      component |<xsl:value-of select="$component"/>|
      product   |<xsl:value-of select="$product"/>|
      version   |<xsl:value-of select="$version"/>|
      labels    |<xsl:value-of select="$labels"/>|
    </xsl:message>

    <xsl:choose>
      <xsl:when test="$url">
        <xsl:text>&#10;</xsl:text>
        <meta name="tracker-url" content="{$url}"/>
        <meta name="tracker-type" content="{$type}"/>

        <xsl:if test="$assignee">
          <meta name="tracker-{$type}-assignee" content="{$assignee}"/>
        </xsl:if>

        <xsl:if test="$type = 'bsc'">
          <xsl:if test="$component">
            <meta name="tracker-{$type}-component" content="{$component}"/>
          </xsl:if>
          <xsl:if test="$product">
            <meta name="tracker-{$type}-product" content="{$product}"/>
          </xsl:if>
        </xsl:if>

        <xsl:if test="$type = 'gh'">
          <xsl:if test="$labels">
            <meta name="tracker-{$type}-labels" content="{$labels}"/>
          </xsl:if>
        </xsl:if>

        <xsl:if test="$version">
          <meta name="tracker-{$type}-version" content="{$version}"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="log.message">
          <xsl:with-param name="level">WARNING</xsl:with-param>
          <xsl:with-param name="context-desc">tracker</xsl:with-param>
          <!--<xsl:with-param name="context-desc-field-length" select="8"/>-->
          <xsl:with-param name="message">
            <xsl:text>Tracker URL in dm:docmanager/dm:bugtracker/dm:url not found. </xsl:text>
            <xsl:text>Check if there is a dm:url available inside set.</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
      Transforms DocManager elements (DocBook 5) or dbsuse-bugtracker processing
      instructions into (X)HTML <meta/> tags with information where
      documentation bugs are collected.
      This information can then be used by JavaScript on the page to create
      "Report a Bug" buttons.

   Parameters:
      None

   Input:
      DocBook 4/5

   Output:
      HTML <meta/> tags

   See Also:
      * https://github.com/openSUSE/suse-xsl/issues/36
      * https://github.com/openSUSE/suse-xsl/issues/43
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

    <!-- Check for the proper DocBook 5/DocManager elements. Since this is
    XML, it should support profiling out of the box. -->
    <xsl:variable name="bugtracker-docmanager" select="ancestor-or-self::*/*[contains(local-name(.), 'info')]/dm:docmanager/dm:bugtracker"/>
    <!-- Check for fallback version via processing instruction. We allow this
    PI both (1) in [book|set|article]info elements, and (2) in
    [book|set|article]info/bibliosource[@bugtracker]. (1) is the original
    version. (2) allows for profiling (which is a somewhat important use case
    for release notes). -->
    <xsl:variable name="bugtracker-pi"
      select="(ancestor-or-self::*/*[contains(local-name(.), 'info')]/processing-instruction('dbsuse-bugtracker')|
               ancestor-or-self::*/*[contains(local-name(.), 'info')]/bibliosource[@role='bugtracker']/processing-instruction('dbsuse-bugtracker'))[last()]"/>

    <xsl:choose>
      <xsl:when test="$bugtracker-docmanager != ''">
        <xsl:call-template name="create.docmanager.bugtracker">
          <xsl:with-param name="bugtracker" select="$bugtracker-docmanager"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$bugtracker-pi != ''">
        <xsl:call-template name="create.pi.bugtracker">
          <!-- Unfortunately, this behaviour is inconsistent with the DocManager
               version: Whereas the DocManager version always searches through
               all relevant dm:bugtracker/dm:xy elements to find one that
               has content, with the PI version, you always need to have all
               necessary attributes within a PI, because traversing the tree
               for PIs is less simple. -->
          <xsl:with-param name="bugtracker" select="$bugtracker-pi[last()]"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="create.docmanager.bugtracker">
    <xsl:param name="bugtracker" select="''"/>

    <xsl:call-template name="create.bugtracker.meta">
      <xsl:with-param name="url-candidate" select="($bugtracker/dm:url[normalize-space(.) != ''])[last()]"/>
      <xsl:with-param name="assignee-candidate" select="($bugtracker/dm:assignee[normalize-space(.) != ''])[last()]"/>
      <xsl:with-param name="component-candidate" select="($bugtracker/dm:component[normalize-space(.) != ''])[last()]"/>
      <xsl:with-param name="product-candidate" select="($bugtracker/dm:product[normalize-space(.) != ''])[last()]"/>
      <xsl:with-param name="version-candidate" select="($bugtracker/dm:version[normalize-space(.) != ''])[last()]"/>
      <xsl:with-param name="labels-candidate" select="($bugtracker/dm:labels[normalize-space(.) != ''])[last()]"/>
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

    <!-- normalize-space() is now only applied to some properties where
    extraneous spaces are exceedingly unlikely. Unfortunately, people use
    product strings etc. with extraneous spaces all the time (bsc#1049081,
    and there was at least one bug before that about the same issue).
    However, this fix only works for DocBook 5 - in DocBook 4, we rely on the
    pi-attribute template that comes with the DocBook stylesheets and that
    template hard-codes a normalize-space(). For good reason, I suspect,
    otherwise they probably couldn't even begin to handle PIs "attributes"
    like regular attributes. -->
    <xsl:variable name="url" select="normalize-space($url-candidate)"/>
    <xsl:variable name="assignee" select="normalize-space($assignee-candidate)"/>
    <xsl:variable name="component" select="$component-candidate"/>
    <xsl:variable name="product" select="$product-candidate"/>
    <xsl:variable name="version" select="$version-candidate"/>
    <xsl:variable name="labels" select="$labels-candidate"/>

    <xsl:variable name="type">
      <xsl:choose>
        <xsl:when test="contains($url, 'bugzilla.suse.com') or
                        contains($url, 'bugzilla.novell.com') or
                        contains($url, 'bugzilla.opensuse.org')">bsc</xsl:when>
        <xsl:when test="contains($url, 'github.com')">gh</xsl:when>
        <xsl:otherwise>unknown</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Left in here for debugging... -->
    <!--<xsl:message>Bug Tracker integration:
      node      <xsl:value-of select="local-name(.)"/>
      url       <xsl:value-of select="$url"/>
      type      <xsl:value-of select="$type"/>
      assignee  <xsl:value-of select="$assignee"/>
      component <xsl:value-of select="$component"/>
      product   <xsl:value-of select="$product"/>
      version   <xsl:value-of select="$version"/>
      labels    <xsl:value-of select="$labels"/>
    </xsl:message>-->

    <xsl:choose>
      <xsl:when test="$url">
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
          <xsl:if test="$version">
            <meta name="tracker-{$type}-version" content="{$version}"/>
          </xsl:if>
        </xsl:if>

        <xsl:if test="$type = 'gh'">
          <xsl:if test="$labels">
            <meta name="tracker-{$type}-labels" content="{$labels}"/>
          </xsl:if>
          <xsl:if test="$version">
            <meta name="tracker-{$type}-milestone" content="{$version}"/>
          </xsl:if>
        </xsl:if>

      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="log.message">
          <xsl:with-param name="level">WARNING</xsl:with-param>
          <xsl:with-param name="context-desc">tracker</xsl:with-param>
          <xsl:with-param name="message">
            <xsl:text>Tracker URL in dm:docmanager/dm:bugtracker/dm:url not found. </xsl:text>
            <xsl:text>Check if there is a dm:url available inside set.</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>

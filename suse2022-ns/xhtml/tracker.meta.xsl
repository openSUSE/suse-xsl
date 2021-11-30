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
      DocBook 5

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
    xmlns:d="http://docbook.org/ns/docbook"
    xmlns:dm="urn:x-suse:ns:docmanager"
    xmlns:exsl="http://exslt.org/common"
    xmlns:date="http://exslt.org/dates-and-times"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="exsl date dm d">


  <xsl:template name="create.bugtracker.information">
    <xsl:param name="node" select="."/>
    <!-- evaluate-only is only for finding out whether the feature _could_ be
    used in the current document. -->
    <xsl:param name="evaluate-only" select="0"/>

    <!-- Check for the proper DocBook 5/DocManager elements. Since this is
    XML, it should support profiling out of the box. -->
    <xsl:variable name="bugtracker-docmanager" select="ancestor-or-self::*/d:info/dm:docmanager/dm:bugtracker"/>

    <xsl:choose>
      <xsl:when test="$use.tracker.meta = 1 and $bugtracker-docmanager != ''">
        <xsl:call-template name="create.docmanager.bugtracker">
          <xsl:with-param name="bugtracker" select="$bugtracker-docmanager"/>
          <xsl:with-param name="evaluate-only" select="$evaluate-only"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$evaluate-only = 1">0</xsl:when>
    </xsl:choose>

    <!-- The suse2013 stylesheets also supported defining bug tracker links via
    processing instructions. This is no longer supported, let's at least show a
    message. Feel free to remove ca. 2024. -->
    <xsl:if test="//processing-instruction('dbsuse-bugtracker')">
      <xsl:call-template name="log.message">
        <xsl:with-param name="level">warn</xsl:with-param>
        <xsl:with-param name="context-desc">bugtracker link</xsl:with-param>
        <xsl:with-param name="message">
          <xsl:text>Found &lt;?dbsuse-bugtracker?&gt; processing instruction. </xsl:text>
          <xsl:text>This PI is not handled anymore by these stylesheets. </xsl:text>
          <xsl:text>Use the dm:bugtracker tag set instead.</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>

  </xsl:template>


  <xsl:template name="create.docmanager.bugtracker">
    <xsl:param name="bugtracker" select="''"/>
    <xsl:param name="evaluate-only" select="0"/>

    <xsl:variable name="url-candidate" select="($bugtracker/dm:url[normalize-space(.) != ''])[last()]"/>
    <xsl:variable name="assignee-candidate" select="($bugtracker/dm:assignee[normalize-space(.) != ''])[last()]"/>
    <xsl:variable name="component-candidate" select="($bugtracker/dm:component[normalize-space(.) != ''])[last()]"/>
    <xsl:variable name="product-candidate" select="($bugtracker/dm:product[normalize-space(.) != ''])[last()]"/>
    <xsl:variable name="version-candidate" select="($bugtracker/dm:version[normalize-space(.) != ''])[last()]"/>
    <xsl:variable name="labels-candidate" select="($bugtracker/dm:labels[normalize-space(.) != ''])[last()]"/>
    <xsl:variable name="template-candidate" select="($bugtracker/dm:template[normalize-space(.) != ''])[last()]"/>

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
    <xsl:variable name="template" select="$template-candidate"/>

    <xsl:variable name="type">
      <xsl:choose>
        <xsl:when test="contains($url, 'bugzilla.suse.com') or
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
      template
                <xsl:value-of select="$template"/>
    </xsl:message>-->

    <xsl:choose>
      <xsl:when test="$evaluate-only = 1 and string-length($url) &gt; 0">1</xsl:when>
      <xsl:when test="$evaluate-only = 1 and string-length($url) = 0">0</xsl:when>

      <xsl:when test="string-length($url) &gt; 0">
        <meta name="tracker-url" content="{$url}"/>
        <xsl:text>&#10;</xsl:text>
        <meta name="tracker-type" content="{$type}"/>
        <xsl:text>&#10;</xsl:text>

        <xsl:if test="$assignee">
          <meta name="tracker-{$type}-assignee" content="{$assignee}"/>
          <xsl:text>&#10;</xsl:text>
        </xsl:if>
        <xsl:if test="$template">
          <meta name="tracker-{$type}-template" content="{$template}"/>
          <xsl:text>&#10;</xsl:text>
        </xsl:if>

        <xsl:if test="$type = 'bsc'">
          <xsl:if test="$component">
            <meta name="tracker-{$type}-component" content="{$component}"/>
            <xsl:text>&#10;</xsl:text>
          </xsl:if>
          <xsl:if test="$product">
            <meta name="tracker-{$type}-product" content="{$product}"/>
            <xsl:text>&#10;</xsl:text>
          </xsl:if>
          <xsl:if test="$version">
            <meta name="tracker-{$type}-version" content="{$version}"/>
            <xsl:text>&#10;</xsl:text>
          </xsl:if>
        </xsl:if>

        <xsl:if test="$type = 'gh'">
          <xsl:if test="$labels">
            <meta name="tracker-{$type}-labels" content="{$labels}"/>
            <xsl:text>&#10;</xsl:text>
          </xsl:if>
          <xsl:if test="$version">
            <meta name="tracker-{$type}-milestone" content="{$version}"/>
            <xsl:text>&#10;</xsl:text>
          </xsl:if>
        </xsl:if>

      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="log.message">
          <xsl:with-param name="level">warn</xsl:with-param>
          <xsl:with-param name="context-desc">bugtracker link</xsl:with-param>
          <xsl:with-param name="message">
            <xsl:text>No tracker URL within dm:docmanager/dm:bugtracker/dm:url found. </xsl:text>
            <xsl:text>Could not create Report Bug links. </xsl:text>
            <xsl:text>Check if there is a dm:url available inside set.</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
